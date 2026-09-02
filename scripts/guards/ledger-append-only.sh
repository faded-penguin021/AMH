#!/usr/bin/env bash
# Guard committed ledger rows against deletion or history-rewriting edits.
#
# Baseline is HEAD, deliberately: rows created in the current uncommitted unit are draft
# material until commit, but any row already committed at HEAD must remain present and
# byte-identical except for the two sanctioned metadata additions: adding `[cited]` to
# the row header and appending a strict standalone pointer line (see POINTER_RE below for
# the two verbs and why the distinction is unenforceable). Rows absent from
# HEAD are new rows and are length-checked before commit against the byte-counted rejection
# boundary, LEDGER_ROW_CHAR_CAP. The paired-unit rationale is DC-003. The sentence-counted
# rejection boundary lives in the ladder's
# own rung; nothing is duplicated here, because a second sentence counter is a second thing to
# keep in step. The
# implementation deliberately counts bytes under LC_ALL=C: that is locale-stable across
# POSIX shells and matches the harness's existing byte-oriented size checks. ASCII text therefore counts as one byte per
# character; non-ASCII UTF-8 counts by encoded bytes, not Unicode scalar values. See DB-012.

set -uo pipefail

LEDGER_DIR=docs
LEDGER_BASENAME=LEDGER
LEDGER_ROW_CHAR_CAP=0
# Default matches scripts/ladder.sh's; amh.conf overrides it below.
PLAN_DIR=docs/plans
# shellcheck source=/dev/null
[ -f amh.conf ] && . ./amh.conf
# Two sanctioned pointer verbs, and the difference between them is LINGUISTIC, not mechanical:
# both append exactly one line and mutate nothing. `Superseded by` says the whole row is
# replaced — read the new one instead. `Corrected by` says one detail went stale while the
# row's principle stands, which is the DB-014 case: DC-011 extends its category rather than
# replacing its rule, so supersession would send a reader to a row that does not carry what
# they came for. This guard checks the FORM and cannot check the CHOICE — writing `Corrected
# by` where you meant superseded passes here, and only a reviewer catches it. Stated because a
# guard that appears to police the distinction would be the D-014 shape.
#
# A row carries at most ONE pointer, and the first is FINAL: a second is refused and so is
# rewriting the first, so a wrong verb cannot be repaired. Leaving that unrepairable is
# deliberate under the D-010/D-023 incident bar — nothing has needed the repair yet — but it
# is a real cost, not a mere inconvenience, and the preambles say so where an author reads.
POINTER_RE='^[[:space:]]*(Superseded|Corrected) by D[A-Z]*-[0-9]+[.]$'

fail() { printf '%s\n' "$*"; exit 1; }

# The ladder's repo-local warn channel: exit 2 with `WARN ` as the first thing printed.
# One line, because the ladder prints it as the warn text verbatim.
warn_exit() { printf 'WARN %s\n' "$*"; exit 2; }

next_suffix() { # next_suffix <suffix>; empty input means A
	local s=${1:-} i c prefix last n
	if [ -z "$s" ]; then
		printf 'A'
		return
	fi
	i=$((${#s} - 1))
	c=${s:$i:1}
	prefix=${s:0:$i}
	if [ "$c" = Z ]; then
		printf '%sA' "$(next_suffix "$prefix")"
	else
		printf -v n '%d' "'$c"
		printf -v last '\\%03o' $((n + 1))
		# shellcheck disable=SC2059 # last is an octal escape produced above.
		printf '%s' "$prefix$(printf "$last")"
	fi
}

ledger_path() { # ledger_path <suffix>
	if [ -z "$1" ]; then
		printf '%s/%s.md' "$LEDGER_DIR" "$LEDGER_BASENAME"
	else
		printf '%s/%s_%s.md' "$LEDGER_DIR" "$LEDGER_BASENAME" "$1"
	fi
}

materialize_head_chain() { # materialize_head_chain <out-dir>
	local out=$1 suffix='' path next
	while :; do
		path=$(ledger_path "$suffix")
		if ! git cat-file -e "HEAD:$path" 2>/dev/null; then
			[ -n "$suffix" ] && break
			fail "ledger append-only: $path is absent from HEAD"
		fi
		mkdir -p "$out/$(dirname "$path")"
		git show "HEAD:$path" >"$out/$path" || exit 1
		next=$(next_suffix "$suffix")
		suffix=$next
	done
}

worktree_chain_paths() { # prints each worktree volume path, in chain order, live volume last
	local suffix='' path
	while :; do
		path=$(ledger_path "$suffix")
		[ -f "$path" ] || break
		printf '%s\n' "$path"
		suffix=$(next_suffix "$suffix")
	done
}

volume_named_by_prefix() { # volume_named_by_prefix <id>; DB-NNN -> docs/LEDGER_B.md, D-NNN -> docs/LEDGER.md
	local id=$1 suffix
	suffix=${id%%-*}   # D, DA, DB…
	suffix=${suffix#D} # '', A, B…
	ledger_path "$suffix"
}

# The chain, read ONCE into an array. Reading it per lookup through a process substitution and
# returning early on the first match closes the pipe while the producer is still writing, and
# the producer then prints `printf: write error: Broken pipe` to stderr. That output arrives
# BEFORE this guard's own first line, so a warning stops beginning with its `WARN ` marker and
# the ladder reads a correctly-detected condition as a broken guard. It is a race — small
# writes usually complete first — so it passed locally and failed in CI, which is the only
# reason it was seen at all. An array cannot half-produce.
CHAIN=()
load_chain() {
	local path
	while IFS= read -r path; do CHAIN+=("$path"); done < <(worktree_chain_paths)
}

volume_holding() { # volume_holding <id>; prints the first chain volume whose text carries the row
	local id=$1 path
	for path in "${CHAIN[@]}"; do
		LC_ALL=C grep -Eq "^- $id( \[cited\])?: " "$path" && { printf '%s' "$path"; return 0; }
	done
	return 1
}

copy_worktree_chain() { # copy_worktree_chain <out-dir>
	local out=$1 suffix='' path next
	while :; do
		path=$(ledger_path "$suffix")
		if [ ! -f "$path" ]; then
			[ -n "$suffix" ] && break
			fail "ledger append-only: $path is absent from the working tree"
		fi
		mkdir -p "$out/$(dirname "$path")"
		cp "$path" "$out/$path" || exit 1
		next=$(next_suffix "$suffix")
		suffix=$next
	done
}

extract_rows() { # extract_rows <tree-dir> <rows-dir>
	local tree=$1 rows=$2 suffix='' path next
	mkdir -p "$rows"
	while :; do
		path=$(ledger_path "$suffix")
		[ -f "$tree/$path" ] || { [ -n "$suffix" ] && break; fail "ledger append-only: $path missing while extracting rows"; }
		awk -v out="$rows" '
			function flush(    file, n) {
				if (id == "") return
				n = count
				while (n > 1 && lines[n] == "") n--
				file = out "/" id
				for (i = 1; i <= n; i++) print lines[i] >file
				close(file)
				delete lines
				count = 0
			}
			/^- D[A-Z]*-[0-9]+( \[cited\])?: / {
				flush()
				id = $2
				sub(/ \[cited\]:$/, "", id)
				sub(/:$/, "", id)
				lines[++count] = $0
				next
			}
			id != "" { lines[++count] = $0 }
			END { flush() }
		' "$tree/$path" || exit 1
		next=$(next_suffix "$suffix")
		suffix=$next
	done
}


validate_row_cap() { # validate_row_cap <row-file> <id>
	local row=$1 id=$2 count
	case ${LEDGER_ROW_CHAR_CAP:-0} in
		''|*[!0-9]*) fail "ledger append-only: LEDGER_ROW_CHAR_CAP must be a non-negative integer, got '${LEDGER_ROW_CHAR_CAP:-}'" ;;
	esac
	[ "${LEDGER_ROW_CHAR_CAP:-0}" -gt 0 ] || return 0
	# Locale-stable character policy: count bytes with LC_ALL=C. For this Markdown ledger's
	# normal ASCII prose that is one byte per character; UTF-8 non-ASCII text is charged by
	# encoded bytes so the same row has the same verdict on every host locale.
	count=$(LC_ALL=C wc -c <"$row") || exit 1
	count=${count//[[:space:]]/}
	if [ "$count" -gt "$LEDGER_ROW_CHAR_CAP" ]; then
		fail "ledger append-only: $id is a new ledger row with $count byte-counted character(s), crossing rejection boundary LEDGER_ROW_CHAR_CAP=$LEDGER_ROW_CHAR_CAP — approaching this rejection boundary means the material probably contains narrative or multiple lessons; split it, keep only the durable conclusion, or route it to docs/history/ with a concise pointer; historical committed rows and sanctioned metadata-only additions are exempt"
	fi
}

# A new row must not name a plan file — in ANY form `scripts/guards/path-refs.sh` resolves.
#
# The reason is the plan tier's own lifecycle, not a guard interaction: a plan is provisional
# context that is archived or deleted when its work completes, so a citation to its path is dead
# the moment that happens — inside a row that is immutable and can never be repaired. Record what
# the plan DELIVERED; name it in prose if you must.
#
# The incident: DC-033 cited a plan's path in backticks while path-refs demanded that every cited
# path exist at HEAD forever, and the archive step went red. That half is FIXED in path-refs, not
# here — a row's immutability covers the row's text, not the lifetime or location of a file it
# names, so a committed citation whose target later moves is historical path drift and the plan
# retires normally. What survives is the rule above, on its own merits.
#
# NEW rows only. A check over the whole chain would fail forever on DC-033, which was authored
# before the rule and whose wording is immutable; the plan it named has since been archived, and
# nothing had to be un-cited to allow that. See the runbook's session discipline 5.
#
# The three forms are path-refs's own, and the FIRST one is why this is not a single grep. That
# guard resolves a markdown link RELATIVE TO THE LINKING FILE (`dir=$(dirname "$f")`), and every
# ledger volume sits in LEDGER_DIR — so the target that pins a plan from a row is `plans/<file>`,
# NOT `docs/plans/<file>`. The obvious spelling is the one that does not pin: `](docs/plans/…)`
# resolves to `docs/docs/plans/…` and path-refs reports it broken whether or not the plan exists.
# A first version of this guard matched the obvious spelling and missed the real one, and its
# fixture asserted on the miss — caught in review by replaying both against path-refs.
#
#   (a) a markdown link whose target, resolved against LEDGER_DIR, lands under PLAN_DIR;
#   (b) a backticked path under PLAN_DIR, resolved from the repo root as path-refs does;
#   (c) a backticked BARE filename that is currently a file in PLAN_DIR — path-refs section (c)
#       resolves those against every tracked basename, so a bare `<plan>.md` pins just as hard.
#
# Both extractions are substituted into a variable and read back, never piped into a consumer
# that exits early. `grep -o ... | head -1` is the fail-OPEN shape DC-034 and DC-038 record: head
# exits after its first line, the writer takes EPIPE, and under `pipefail` a FOUND citation
# becomes a non-zero pipeline that reads as no-match. The first version of this guard had exactly
# that pipeline.
#
# Matched with `case` over extracted tokens rather than by interpolating PLAN_DIR into an ERE:
# the value comes from amh.conf and is adopter-editable, and a regex would silently impose a
# no-metacharacters constraint on it that nothing documents or checks.
#
# (c) can only see plans that exist NOW: a row naming a plan added later is not reachable here,
# and nothing catches it. Stated rather than papered over — the prose rule is what binds, and
# this guard is a tripwire for the shape that already bit us.

# Strip a #fragment and any leading `./`, the two spellings path-refs normalizes before it
# resolves. Without this, `plans/x.md#unit-3` and `./plans/x.md` both pin and both pass.
normalize_ref() { # normalize_ref <target>
	local t=${1%%#*}
	while [ "$t" != "${t#./}" ]; do t=${t#./}; done
	printf '%s' "$t"
}

validate_row_plan_path() { # validate_row_plan_path <row-file> <id>
	local row=$1 id=$2 tok target spans
	[ -n "${PLAN_DIR:-}" ] || return 0

	# (a) markdown links. `](` and not a bare `(`: path-refs only resolves link syntax, so a
	# plan named inside ordinary parentheses pins nothing and must not fail here.
	while IFS= read -r tok; do
		[ -n "$tok" ] || continue
		tok=${tok#](}
		tok=${tok%)}
		case $tok in
		http*://* | '#'* | mailto:* | /*) continue ;;
		esac
		target=$(normalize_ref "$tok")
		[ -n "$target" ] || continue
		# Resolved the way path-refs resolves it: against the linking file's directory,
		# which for every ledger volume is LEDGER_DIR.
		case "$LEDGER_DIR/$target" in
		"$PLAN_DIR"/*) plan_citation_fail "$id" "$LEDGER_DIR/$target" ;;
		esac
	done < <(LC_ALL=C grep -oE '\]\([^)]+\)' "$row")

	# (b) and (c) backticked spans, resolved from the repo root as path-refs does.
	# Hoisted out of the loop so the SC2016 waiver covers ONE command: a directive cannot sit
	# before `done < <(...)` (SC1123), and putting it on the whole `while` would silence the
	# check for the entire body — the same reasoning path-refs.sh records at its own extraction.
	# shellcheck disable=SC2016 # backticks are the pattern's own syntax: this matches markdown
	# code spans literally, so single quotes are required, not a slip.
	spans=$(LC_ALL=C grep -oE '`[^`]+`' "$row")
	while IFS= read -r tok; do
		[ -n "$tok" ] || continue
		tok=${tok#\`}
		tok=${tok%\`}
		target=$(normalize_ref "$tok")
		[ -n "$target" ] || continue
		case $target in
		"$PLAN_DIR"/*) plan_citation_fail "$id" "$target" ;;
		esac
		# (c) a bare filename that is a plan in the tree right now.
		case $target in
		*/*) ;;
		*) [ -n "$target" ] && [ -f "$PLAN_DIR/$target" ] && plan_citation_fail "$id" "$target" ;;
		esac
	done <<<"$spans"
	return 0
}

plan_citation_fail() { # plan_citation_fail <id> <cited>
	fail "ledger append-only: new row $1 names the plan file '$2'. A committed row is immutable and $PLAN_DIR files are archived or deleted when their work completes, so the citation is dead the moment the plan retires and the row can never be repaired — a plan is provisional context, not permanent evidence. Record what the plan DELIVERED in the row itself; name the plan in prose without a citable path if you must refer to it at all."
}

allowed_metadata_only() { # allowed_metadata_only <base-row> <current-row>
	local base=$1 current=$2 trimmed without_pointer base_cited=0
	# Normalize only the two sanctioned, additive metadata transitions before comparing:
	# an uncited header may gain `[cited]`, and one strict pointer sentence (supersession or
	# correction) may be appended. Removing `[cited]`, changing prose, or altering an existing pointer remains
	# a rewrite because normalization is deliberately one-way from current back to HEAD.
	#
	# That one-wayness contradicts the ladder's citation rung, which FAILS a row that is marked
	# but no longer cited and orders the marker dropped. The contradiction stalls the un-cite
	# and does not prevent it: the HEAD baseline above means a commit through the red rung
	# leaves this guard green from then on, and in CI, where the worktree IS HEAD, the early
	# return below examines nothing. So the immutability this enforces is a working-tree
	# property, never a property of history — do not read a green line here as evidence that
	# committed rows were never edited. DC-020 records why that is left standing.
	trimmed=$(mktemp "$TMPDIR/ledger-row.XXXXXX") || exit 1
	cp "$current" "$trimmed" || { rm -f "$trimmed"; return 1; }
	LC_ALL=C sed -n '1{/^- D[A-Z]*-[0-9][0-9]* \[cited\]: /q0};q1' "$base" && base_cited=1
	if [ "$base_cited" -eq 0 ]; then
		LC_ALL=C sed '1s/^\(- D[A-Z]*-[0-9][0-9]*\) \[cited\]: /\1: /' "$trimmed" >"$trimmed.normalized" || exit 1
		mv "$trimmed.normalized" "$trimmed" || exit 1
	fi
	if cmp -s "$base" "$trimmed"; then
		rm -f "$trimmed"
		return 0
	fi
	# A baseline that already carries a pointer ANYWHERE cannot gain a second one. This scans
	# the whole row rather than its last line, and the difference is not theoretical: new rows
	# are never form-checked, so a row committed with a pointer line that is not last was
	# exempt from the one-pointer limit forever — two pointers, guard green, reproduced. The
	# comparison above still permits such a row to gain `[cited]`, because that path returns at
	# `cmp -s` before reaching here.
	LC_ALL=C grep -Eq "$POINTER_RE" "$base" && { rm -f "$trimmed"; return 1; }
	without_pointer=$(mktemp "$TMPDIR/ledger-row.XXXXXX") || exit 1
	awk -v re="$POINTER_RE" '
		{ lines[NR] = $0 }
		END {
			if (NR == 0 || lines[NR] !~ re) exit 1
			for (i = 1; i < NR; i++) print lines[i]
		}
	' "$trimmed" >"$without_pointer" || { rm -f "$trimmed" "$without_pointer"; return 1; }
	cmp -s "$base" "$without_pointer"
	local rc=$?
	rm -f "$trimmed" "$without_pointer"
	return "$rc"
}

if ! git rev-parse --verify -q HEAD >/dev/null; then
	printf 'ledger append-only: no HEAD commit yet; nothing to compare\n'
	exit 0
fi

if ! git diff --name-only HEAD -- "$LEDGER_DIR" | awk -v base="$LEDGER_BASENAME" '
	$0 == "docs/" base ".md" { found = 1 }
	$0 ~ "^docs/" base "_[A-Z]+[.]md$" { found = 1 }
	END { exit found ? 0 : 1 }
'; then
	printf 'no committed ledger rows changed against HEAD'
	exit 0
fi

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT
materialize_head_chain "$TMPDIR/head-tree"
copy_worktree_chain "$TMPDIR/work-tree"
extract_rows "$TMPDIR/head-tree" "$TMPDIR/head-rows"
extract_rows "$TMPDIR/work-tree" "$TMPDIR/work-rows"

checked=0
for base_row in "$TMPDIR"/head-rows/D*-*; do
	[ -e "$base_row" ] || fail 'ledger append-only: checked nothing in HEAD ledger rows'
	id=${base_row##*/}
	current_row="$TMPDIR/work-rows/$id"
	checked=$((checked + 1))
	if [ ! -f "$current_row" ]; then
		fail "ledger append-only: $id existed at HEAD but is missing from the working tree"
	fi
	if ! cmp -s "$base_row" "$current_row" && ! allowed_metadata_only "$base_row" "$current_row"; then
		fail "ledger append-only: $id existed at HEAD and was edited; only adding '[cited]' to its header and/or appending 'Superseded by D-NNN.' or 'Corrected by D-NNN.' as a standalone final line is allowed"
	fi
done

load_chain
[ "${#CHAIN[@]}" -gt 0 ] || fail 'ledger append-only: the ledger chain is empty — nothing to check'
live_volume=${CHAIN[${#CHAIN[@]} - 1]}

new_checked=0
misfiled=''
for current_row in "$TMPDIR"/work-rows/D*-*; do
	[ -e "$current_row" ] || continue
	id=${current_row##*/}
	[ -f "$TMPDIR/head-rows/$id" ] && continue
	new_checked=$((new_checked + 1))
	validate_row_cap "$current_row" "$id"
	validate_row_plan_path "$current_row" "$id"
	# Two independent ways a new row can be filed wrong, and DB-015 (superseded by DB-020, which
	# records how a misfiled row is repaired) is the second one, not
	# the first — a fact worth stating because checking only the obvious half would leave the
	# motivating incident uncovered while the prose claimed otherwise:
	#
	#   (a) it is not in the LIVE volume — the last one the chain walk reaches. New rows go
	#       at the end of the chain; a row appended to a closed volume is easy to miss because
	#       grep still finds it and every rung stays green.
	#   (b) its ID PREFIX names a different volume than the file it sits in. `DB-` resolves in
	#       LEDGER_B.md by the preambles' own rule, so a `D-` row in LEDGER_B.md dangles for a
	#       reader following that rule even though the file is the live one — and (a) alone is
	#       silent about it.
	#
	# Reported together because the fix is the same move and a session that hears one and not
	# the other will make the second mistake correcting the first.
	if ! home=$(volume_holding "$id"); then
		# Not reachable while the row extractor and this locator share a header pattern; if
		# they ever diverge, say so rather than skipping a row in silence — a `continue` here
		# would make the check hollow exactly when it stopped working.
		fail "ledger append-only: $id was extracted as a row but no volume in the chain carries its header — the extractor and the volume locator have diverged"
	fi
	expected=$(volume_named_by_prefix "$id")
	if [ "$home" != "$live_volume" ]; then
		misfiled="$misfiled $id(in $home, live volume is $live_volume)"
	elif [ "$home" != "$expected" ]; then
		misfiled="$misfiled $id(in $home, its prefix names $expected)"
	fi
done

# WARN, deliberately, and NOT a failure a later session should "tighten". There may be a
# genuine reason to append outside the live volume that nobody has enumerated yet (owner,
# 2026-08-09), and a rail that fails closed on an unenumerated legitimate case is one an
# adopter switches off rather than reads. The append-only rules above stay hard failures:
# this one is about WHERE a new row was filed, not whether history was rewritten.
if [ -n "$misfiled" ]; then
	warn_exit "ledger append-only: new row(s) filed where a reader following the ledger's own rules will not look —${misfiled}. New rows belong at the end of the live volume, and a D<prefix>-NNN id resolves in the volume its prefix names. Move the row, or say in the commit why this one belongs where it is. Adding [cited] or a supersession/correction pointer to an existing row anywhere in the chain is unaffected. Checked $checked committed and $new_checked new row(s) against HEAD."
fi

printf 'checked %d committed ledger row(s) and %d new ledger row(s) against HEAD' "$checked" "$new_checked"
