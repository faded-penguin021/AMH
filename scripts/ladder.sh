#!/usr/bin/env bash
# AMH — the acceptance ladder: ONE verification entrypoint, shared by the agent and
# CI by construction (P4). CI invokes this exact script, so "green locally, red in
# CI" can only ever mean environment, never a lockstep the humans forgot to update.
#
#   scripts/ladder.sh                 fast guards, then the full verification set
#   scripts/ladder.sh --guards-only   guards only (seconds) — for docs-only work
#
# Repo-agnostic by design, which is what lets a repo verify it runs the harness's
# own artifact byte-for-byte. Everything repo-specific lives in three places:
#   amh.conf          values (branches, size bands, scan scope)
#   scripts/guards/*  extra guards this repo has earned
#   scripts/verify.sh the full test/build/lint set (rung 3)
#
# No `set -e`: every guard must run so one change gets ONE complete report instead of
# a whack-a-mole sequence of first failures. Failures are counted, not thrown.

set -uo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT" || exit 1

GUARDS_ONLY=0
case "${1:-}" in
--guards-only) GUARDS_ONLY=1 ;;
"") ;;
-h | --help)
	sed -n '2,16p' "$0"
	exit 0
	;;
*)
	printf 'usage: %s [--guards-only]\n' "$0" >&2
	exit 2
	;;
esac

# --- configuration ----------------------------------------------------------
DEFAULT_BRANCH=main
BRANCH_PREFIX=session
STATE_FILE=docs/STATE.md
STATE_COMPRESS_TO_KB=9
STATE_WARN_KB=14
STATE_HARD_KB=16
STATE_REQUIRED_SECTIONS='## Project|## Current state|## Changelog'
STATE_OWNER_QUEUE_SECTION='## Owner queue'
LEDGER_DIR=docs
LEDGER_BASENAME=LEDGER
LEDGER_LINE_CAP=800
CITATION_SCAN_PATHS='scripts .github'
CITATION_EXCLUDE=''
POISON_TOKENS='[skip ci]|[ci skip]'
PLAN_DIR=docs/plans
RULE_FILES=''
# shellcheck source=/dev/null
[ -f "$ROOT/amh.conf" ] && . "$ROOT/amh.conf"

FAILS=0
WARNS=0
section() { printf '\n▸ %s\n' "$1"; }
ok() { printf '   ok    %s\n' "$1"; }
warn() {
	printf '   WARN  %s\n' "$1"
	WARNS=$((WARNS + 1))
}
fail() {
	printf '   FAIL  %s\n' "$1"
	FAILS=$((FAILS + 1))
}
skip() { printf '   skip  %s\n' "$1"; }

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

in_ci() { [ -n "${CI:-}" ]; }
has_git() { git rev-parse --git-dir >/dev/null 2>&1; }
upstream_ref() {
	local r="origin/$DEFAULT_BRANCH"
	git rev-parse --verify --quiet "$r" >/dev/null 2>&1 && printf '%s' "$r"
}

# =============================================================================
# 1. GUARDS — seconds, no build. Each one checks an artifact the work produces
#    anyway (P3): file sizes, diffs, commit messages, citations. Never a
#    self-reported attestation, which an agent can emit without doing the work.
# =============================================================================

guard_state_size() {
	section "Working memory: $STATE_FILE size band (hysteresis)"
	if [ ! -f "$STATE_FILE" ]; then
		fail "$STATE_FILE is missing — it is protocol step 1 for every session"
		return
	fi
	local cur warn_b hard_b comp_b prev
	cur=$(wc -c <"$STATE_FILE")
	warn_b=$((STATE_WARN_KB * 1024))
	hard_b=$((STATE_HARD_KB * 1024))
	comp_b=$((STATE_COMPRESS_TO_KB * 1024))

	if [ "$cur" -gt "$hard_b" ]; then
		fail "$((cur / 1024)) KB exceeds the ${STATE_HARD_KB} KB hard cap — compress to ≤ ${STATE_COMPRESS_TO_KB} KB now"
	elif [ "$cur" -gt "$warn_b" ]; then
		warn "$((cur / 1024)) KB is over the ${STATE_WARN_KB} KB soft cap — run ONE deep compression pass to ≤ ${STATE_COMPRESS_TO_KB} KB (not to just under the cap)"
	else
		ok "$((cur / 1024)) KB (soft cap ${STATE_WARN_KB} KB, hard ${STATE_HARD_KB} KB)"
	fi

	# Landing check. Size thresholds alone are Goodhart-able: a trim that stops short of
	# the floor passes and re-arms the warning a session later. Compare against the
	# committed size and require a compression, once started, to actually LAND on the
	# floor.
	#
	# It fires on ANY shrink from over the soft cap that does not reach the floor —
	# including one that stays over the cap. Checking only trims that cross below the
	# cap leaves the same hole one band higher: 15.5 KB → 14.2 KB never crosses, so the
	# check never evaluates, and grow-then-nibble repeats forever under a mere warning.
	# Growth and edits that start below the cap never trip it.
	has_git || return
	prev=$(git show "HEAD:$STATE_FILE" 2>/dev/null | wc -c)
	if [ "$prev" = "$cur" ]; then
		prev=$(git show "HEAD~1:$STATE_FILE" 2>/dev/null | wc -c)
	fi
	[ "${prev:-0}" -gt 0 ] || return
	if [ "$prev" -gt "$warn_b" ] && [ "$cur" -lt "$prev" ] && [ "$cur" -gt "$comp_b" ]; then
		fail "trimmed from $((prev / 1024)) KB to $((cur / 1024)) KB but the floor is ${STATE_COMPRESS_TO_KB} KB — a compression pass that stops short re-arms the warning next session. Go to the floor or leave the file alone."
	fi
}

# A section is present only if its header stands at the start of a line AND something
# non-blank follows before the next header. Header-presence alone is trivially gamed:
# the cheapest way to "survive compression" is to keep four headings and delete every
# body under them. This does not judge whether the content is any GOOD — no guard can —
# it only refuses to call an empty shell a section.
section_has_body() { # <file> <header>
	awk -v h="$2" '
		index($0, h) == 1 && !inside { inside = 1; next }
		inside && /^#{1,6} / { exit }
		inside && NF { found = 1; exit }
		END { exit(found ? 0 : 1) }
	' "$1"
}

guard_state_structure() {
	section "Working memory: required sections"
	[ -f "$STATE_FILE" ] || return
	local problems=0 sec
	while IFS= read -r sec; do
		[ -n "$sec" ] || continue
		if ! grep -q "^${sec}[[:space:]]*$" "$STATE_FILE"; then
			fail "section '$sec' is missing — over-compression deleted it"
			problems=$((problems + 1))
		elif ! section_has_body "$STATE_FILE" "$sec"; then
			fail "section '$sec' is empty — the header survived compression but its content did not"
			problems=$((problems + 1))
		fi
	done < <(printf '%s\n' "$STATE_REQUIRED_SECTIONS" | tr '|' '\n')
	[ "$problems" = 0 ] && ok "all required sections present and non-empty"
	# WARN, not fail: the owner's channel is theirs, and a session that has genuinely
	# closed every item should not be blocked. The asymmetry is deliberate and is
	# stated wherever this section is described as protected.
	if ! grep -q "^${STATE_OWNER_QUEUE_SECTION}[[:space:]]*$" "$STATE_FILE"; then
		warn "'$STATE_OWNER_QUEUE_SECTION' has vanished — that section is the owner's channel; its items are theirs to close"
	fi
}

live_ledger() {
	local f last=''
	for f in "$LEDGER_DIR/$LEDGER_BASENAME.md" "$LEDGER_DIR/${LEDGER_BASENAME}"_*.md; do
		[ -f "$f" ] && last=$f
	done
	printf '%s' "$last"
}

guard_ledger_rollover() {
	section "Permanent memory: ledger file cap"
	local live lines last_row
	live=$(live_ledger)
	if [ -z "$live" ]; then
		skip "no ledger yet"
		return
	fi
	lines=$(wc -l <"$live")
	last_row=$(grep -n '^- D[A-Z]\?-[0-9]\+' "$live" | tail -1 | cut -d: -f1)
	if [ -n "$last_row" ] && [ "$last_row" -gt "$LEDGER_LINE_CAP" ]; then
		fail "$live: a row STARTS at line $last_row, past the ${LEDGER_LINE_CAP}-line cap — open the next volume (rows are never moved or renumbered)"
	elif [ "$lines" -ge $((LEDGER_LINE_CAP * 9 / 10)) ]; then
		warn "$live: $lines lines, approaching the ${LEDGER_LINE_CAP}-line cap — the next rollover is near"
	else
		ok "$live: $lines/$LEDGER_LINE_CAP lines"
	fi
}

guard_citations() {
	section "Citations: code ↔ ledger, both directions"
	local scan_files=$TMP/scanfiles rows=$TMP/rows cited=$TMP/cited marked=$TMP/marked
	# NUL-separated throughout, for the reason the secret scan states below: a
	# word-split file list drops every name containing a space, and the drop is
	# invisible — the guard reports the same green it reports for a clean tree.
	: >"$scan_files"
	# `set -f` for the two config lists below: they are split on whitespace ON PURPOSE,
	# but an unquoted expansion also GLOBS, so an entry containing `?` or `*` would be
	# rewritten into whatever happens to sit in the working directory — a third way for
	# the scanned scope to differ from what amh.conf says it is.
	set -f
	local p
	for p in $CITATION_SCAN_PATHS; do
		[ -e "$p" ] || continue
		if has_git; then
			git ls-files -co --exclude-standard -z -- "$p" >>"$scan_files"
		else
			find "$p" -type f -print0 >>"$scan_files"
		fi
	done
	local ex f
	for ex in $CITATION_EXCLUDE; do
		# Whole paths and directory prefixes, matched literally. The grep form this
		# replaces interpolated $ex as a REGEX and kept the unfiltered list whenever
		# the exclusion emptied it — two more ways for the same scope to drift.
		: >"$scan_files.t"
		while IFS= read -r -d '' f; do
			case $f in "$ex" | "$ex"/*) continue ;; esac
			printf '%s\0' "$f" >>"$scan_files.t"
		done <"$scan_files"
		mv "$scan_files.t" "$scan_files"
	done
	set +f

	# Every ledger row, and whether it carries the machine-synced [cited] marker.
	: >"$rows"
	: >"$marked"
	local f
	for f in "$LEDGER_DIR/$LEDGER_BASENAME.md" "$LEDGER_DIR/${LEDGER_BASENAME}"_*.md; do
		[ -f "$f" ] || continue
		sed -n 's/^- \(D[A-Z]\?-[0-9]\+\)\( \[cited\]\)\?:.*/\1\2/p' "$f" >>"$rows.raw"
	done
	if [ -f "$rows.raw" ]; then
		awk '{print $1}' "$rows.raw" | sort >"$rows"
		awk 'NF>1{print $1}' "$rows.raw" | sort >"$marked"
	else
		: >"$rows"
	fi

	local dupes
	dupes=$(uniq -d <"$rows")
	if [ -n "$dupes" ]; then
		fail "duplicate ledger row numbers: $(printf '%s' "$dupes" | tr '\n' ' ')"
	fi

	: >"$cited"
	if [ -s "$scan_files" ]; then
		xargs -0 grep -hoE 'D[A-Z]?-[0-9]+' <"$scan_files" 2>/dev/null | sort -u >"$cited"
	fi

	local unresolved missing_marker stale_marker
	unresolved=$(comm -23 "$cited" <(sort -u "$rows"))
	if [ -n "$unresolved" ]; then
		fail "cited from code but no such ledger row: $(printf '%s' "$unresolved" | tr '\n' ' ')"
	fi
	missing_marker=$(comm -23 "$cited" <(sort -u "$marked"))
	if [ -n "$missing_marker" ]; then
		fail "cited from code but not marked [cited] in the ledger: $(printf '%s' "$missing_marker" | tr '\n' ' ') — the marker warns the next reader that code depends on the row"
	fi
	stale_marker=$(comm -13 "$cited" <(sort -u "$marked"))
	if [ -n "$stale_marker" ]; then
		fail "marked [cited] but no longer cited from code: $(printf '%s' "$stale_marker" | tr '\n' ' ') — drop the marker (never the row)"
	fi
	[ -z "$unresolved$missing_marker$stale_marker$dupes" ] && ok "$(wc -l <"$cited" | tr -d ' ') citation(s) resolve; markers in sync"
}

guard_secret_shapes() {
	section "Secret-shape scan (the redaction filter IS the scan)"
	# This guard is the repo's ENTIRE secret scan (D-004), so it must not be possible
	# to switch it off by accident. It used to test `-x` and print `skip` when the bit
	# was missing: `chmod -x scripts/redact.sh` — or an archive download, or
	# core.fileMode=false — turned the scan into a green line with a live credential
	# sitting in the tree. Presence is now the question, and the answer to "absent" is
	# a failure, not a skip. The exec bit no longer decides anything: the filter is run
	# through `bash` explicitly.
	if [ ! -f scripts/redact.sh ]; then
		fail "scripts/redact.sh is missing — it IS this repo's secret scan, so its absence is a failure, not a skip"
		return
	fi
	# ...and PRESENCE is not the same as WORKING. The verdict below is "the filter's
	# output differs from the file", which an empty, truncating, crashing or
	# pass-through filter satisfies for nothing at all — every file reads as clean and
	# the rung prints ok. A positive control first, so the scan has to prove it can
	# still catch something before its silence is allowed to mean anything. The token is
	# generated at runtime: a stored literal would make this file fail its own scan
	# (D-004).
	local canary
	canary="AKIA$(LC_ALL=C tr -dc 'A-Z0-9' </dev/urandom | head -c 16)"
	if printf 'x %s x\n' "$canary" | bash scripts/redact.sh 2>/dev/null | grep -qF "$canary"; then
		fail "scripts/redact.sh did not redact a generated test token — the filter is empty, broken or pass-through, and this scan would report green on everything"
		return
	fi
	local list=$TMP/files.nul hits=0
	if has_git; then
		git ls-files -co --exclude-standard -z >"$list"
	else
		find . -type f -not -path './.git/*' -print0 >"$list"
	fi
	# NUL-separated: a word-split list silently skips names with spaces or non-ASCII
	# characters, and a scan with a silent hole is worse than no scan.
	local f pos cmperr=$TMP/cmp.err
	while IFS= read -r -d '' f; do
		[ -f "$f" ] || continue
		LC_ALL=C grep -qI . "$f" 2>/dev/null || continue # text files only
		# `cmp`'s stderr carries the truncation verdict (`EOF on -`) while its stdout
		# carries the difference verdict. Discarding stderr made a filter that stopped
		# mid-stream indistinguishable from a clean file.
		pos=$(bash scripts/redact.sh <"$f" 2>/dev/null | cmp - "$f" 2>"$cmperr")
		if [ -s "$cmperr" ]; then
			fail "scripts/redact.sh did not filter all of $f ($(tr -d '\n' <"$cmperr")) — a truncated stream reads as clean"
			hits=$((hits + 1))
			continue
		fi
		if [ -n "$pos" ]; then
			# Report the POSITION only. A diagnostic that regresses to printing the
			# matched line defeats the entire point of the guard.
			fail "credential-shaped string in $f (${pos#*differ: })"
			hits=$((hits + 1))
		fi
	done <"$list"
	[ "$hits" = 0 ] && ok "no credential-shaped strings in tracked or untracked text files"
}

guard_poison_tokens() {
	section "Commit messages: poison tokens"
	local base
	base=$(upstream_ref)
	if ! has_git || [ -z "$base" ]; then
		# WARN, not skip. Without `origin/$DEFAULT_BRANCH` this guard has nothing to diff
		# against and checks nothing — it ran inert in the reference repo for its entire
		# life while printing a line that read like a considered pass. A guard that is
		# switched off must say so more loudly than one that passed (D-019).
		warn "no $DEFAULT_BRANCH reference to compare against — this guard checked NOTHING. Fetch it (\`git fetch origin $DEFAULT_BRANCH\`) or accept that poison tokens are unguarded locally."
		return
	fi
	local msgs tok hits=0
	msgs=$(git log --format='%B' "$base..HEAD" 2>/dev/null)
	if [ -z "$msgs" ]; then
		ok "no new commits to check"
		return
	fi
	while IFS= read -r tok; do
		[ -n "$tok" ] || continue
		if printf '%s' "$msgs" | grep -qF -- "$tok"; then
			fail "commit message contains '$tok' — a squash merge would fold it onto $DEFAULT_BRANCH, and force-push is forbidden, so it is permanent until merge"
			hits=$((hits + 1))
		fi
	done < <(printf '%s\n' "$POISON_TOKENS" | tr '|' '\n')
	[ "$hits" = 0 ] && ok "clean"
}

guard_rail_selftests() {
	section "Rail self-tests (a silently regressed rail is no rail)"
	local s
	for s in scripts/redact.sh scripts/command-guard.sh; do
		# `[ -x ]` here printed nothing at all when the bit was missing — this whole
		# section went blank and the ladder stayed green. Absence gets a `skip` line,
		# the script's convention everywhere else; the exec bit gets no vote.
		if [ ! -f "$s" ]; then
			skip "$s is not a readable file — nothing self-tested it"
			continue
		fi
		if out=$(bash "$s" --self-test 2>&1); then
			ok "$s"
		else
			fail "$s self-test failed:"
			printf '%s\n' "$out" | sed 's/^/         /'
		fi
	done
}

guard_repo_local() {
	local g found=0
	for g in scripts/guards/*.sh; do
		[ -f "$g" ] || continue
		[ "$found" = 0 ] && section "Repo-local guards"
		found=1
		if out=$(bash "$g" 2>&1); then
			ok "$(basename "$g")${out:+ — $out}"
		else
			fail "$(basename "$g"):"
			printf '%s\n' "$out" | sed 's/^/         /'
		fi
	done
}

# --- local-only advisories --------------------------------------------------
# WARN-only, skipped in CI: they describe the state of a working session, which CI
# does not have. Warn fatigue kills tripwires, so this list stays short.
advisories() {
	in_ci && return
	has_git || return
	local base
	base=$(upstream_ref)
	section "Local advisories (not run in CI)"

	if [ -n "$base" ]; then
		local changed
		changed=$(git diff --name-only "$base...HEAD" 2>/dev/null)
		if [ -n "$changed" ] && ! printf '%s\n' "$changed" | grep -qF "$STATE_FILE"; then
			warn "this branch changes files but not $STATE_FILE — the checkpoint's changelog line is probably missing"
		fi

		if ! git merge-base --is-ancestor "$base" HEAD 2>/dev/null; then
			local mt rc tree
			mt=$(git merge-tree --write-tree "$base" HEAD 2>/dev/null)
			rc=$?
			tree=$(printf '%s' "$mt" | head -1)
			if [ "$rc" -eq 0 ] && [ -n "$mt" ] && [ "$tree" = "$(git rev-parse 'HEAD^{tree}' 2>/dev/null)" ]; then
				warn "behind $base, but a clean test-merge leaves this tree unchanged — structural (the default branch advanced by a squash of this very work). Do NOT merge."
			elif [ "$rc" -eq 0 ] && [ -n "$mt" ]; then
				warn "behind $base and the merge would bring content — inspect what it brings, then merge it in (never rebase pushed history)."
			elif [ -z "$mt" ]; then
				warn "behind $base — could not classify (shallow clone or an older git). Usually structural; inspect before merging."
			else
				warn "behind $base and a test-merge conflicts — inspect what the merge would bring first (a deliberate revert on this branch looks like missing content)."
			fi
		fi
	fi

	if [ -d "$PLAN_DIR" ]; then
		local p
		for p in "$PLAN_DIR"/*; do
			[ -f "$p" ] || continue
			if ! grep -qF "$(basename "$p")" "$STATE_FILE" 2>/dev/null; then
				warn "$p is not referenced from $STATE_FILE — a finished or pivoted plan missed its deletion step. Plans die; code cites ledger rows, never plans."
			fi
		done
	fi

	if [ -n "$RULE_FILES" ]; then
		local dirty rf touched=''
		dirty=$( (
			git diff --name-only
			git diff --cached --name-only
			git ls-files -o --exclude-standard
		) 2>/dev/null | sort -u)
		# Literal whole-path or directory-prefix matches, and `set -f` so an entry is
		# never glob-expanded against the working directory — see guard_citations. The
		# grep form this replaces interpolated each entry as a regex.
		set -f
		local d
		for rf in $RULE_FILES; do
			while IFS= read -r d; do
				case $d in
				"$rf" | "$rf"/*)
					touched="$touched $rf"
					break
					;;
				esac
			done <<<"$dirty"
		done
		set +f
		if [ -n "$touched" ]; then
			warn "uncommitted diff touches legislation:$touched — the rule-review protocol applies (fresh-context reviewer, strongest tier, no self-review fallback) BEFORE commit."
		fi
	fi
	[ "$WARNS" = 0 ] && ok "nothing to flag"
}

# =============================================================================
run_guards() {
	guard_state_size
	guard_state_structure
	guard_ledger_rollover
	guard_citations
	guard_secret_shapes
	guard_poison_tokens
	guard_rail_selftests
	guard_repo_local
	advisories
}

run_guards

if [ "$FAILS" -gt 0 ]; then
	printf '\n✗ guards: %d failure(s), %d warning(s)\n' "$FAILS" "$WARNS"
	exit 1
fi

if [ "$GUARDS_ONLY" = 1 ]; then
	printf '\n✓ guards clean (%d warning(s)) — guards-only run, verification set NOT executed\n' "$WARNS"
	exit 0
fi

# =============================================================================
# 3. The full verification set, in one invocation.
# =============================================================================
section "Verification set (scripts/verify.sh)"
if [ ! -x scripts/verify.sh ]; then
	fail "scripts/verify.sh is missing or not executable — the ladder has no verification rung"
	printf '\n✗ ladder red\n'
	exit 1
fi
if scripts/verify.sh; then
	printf '\n✓ ladder green (%d warning(s))\n' "$WARNS"
	exit 0
fi
printf '\n✗ ladder red — verification set failed\n'
exit 1
