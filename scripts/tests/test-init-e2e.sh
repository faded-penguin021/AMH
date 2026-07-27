#!/usr/bin/env bash
# End-to-end: instantiate the harness into a scratch repo, then run THAT repo's ladder.
#
# The build plan named this as U6's acceptance criterion and it was the one never met.
# Instantiation had only ever been run by hand, and the one time it was, an adopter's very
# first ladder run came back RED for ledger rows only this repo can have — a defect that had
# been shipping for the harness's entire life because nobody had executed the path. An
# artifact nobody can execute accumulates defects at full speed and reports none (D-023).
#
# What this asserts, in order:
#   1. a fresh instantiation produces a repo whose own ladder is GREEN,
#   2. ...and that green is not vacuous — a planted credential still turns it red,
#   3. re-running init upgrades the machinery and leaves the adopter's judgement alone,
#   4. the init placeholder list and harness/PLACEHOLDERS.md cannot diverge in silence,
#   5. every --profile installs its own seed set and produces a GREEN ladder in that repo.
#
# Repo-local: this script runs from the harness's source of truth. It is not shipped, and
# an adopter never runs it.

set -uo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

export GIT_AUTHOR_NAME=amh-test GIT_AUTHOR_EMAIL=amh@test.invalid
export GIT_COMMITTER_NAME=amh-test GIT_COMMITTER_EMAIL=amh@test.invalid

PASSED=0
FAILED=0

pass() { PASSED=$((PASSED + 1)); }
fail() { # <name> <detail...>
	FAILED=$((FAILED + 1))
	printf '  FAIL %s\n' "$1" >&2
	shift
	[ $# -gt 0 ] && printf '%s\n' "$*" | sed 's/^/       /' >&2
	return 0
}

# A target repo, empty and freshly initialised — which is the state an adopter is actually
# in. `git init` and nothing else: the ladder must not need a commit to exist before it can
# say anything useful, and the first run happening before the first commit is the normal
# case, not an edge one.
target() { # <name> -> prints the path
	local d="$WORK/$1"
	mkdir -p "$d"
	git -C "$d" init -q
	printf '%s' "$d"
}

# The instantiated repo's OWN ladder, guards only. CI=1 suppresses the local advisories,
# which describe a working session the fixture does not have.
target_ladder() { (cd "$1" && CI=1 scripts/ladder.sh --guards-only 2>&1); }

# A runtime-generated AKIA-shaped token. Never a stored literal: this file is scanned by
# the same secret guard it is testing, and a literal would make it fail its own scan
# (D-004). Bounded read then slice, so `tr` is never left writing into a pipe that `head`
# has already closed.
akia_token() {
	local pool=''
	while [ "${#pool}" -lt 16 ]; do
		pool=$pool$(head -c 512 /dev/urandom | LC_ALL=C tr -dc 'A-Z0-9')
	done
	printf 'AKIA%s' "${pool:0:16}"
}

printf 'init end-to-end\n'

# =============================================================================
# 1. A fresh instantiation is green.
# =============================================================================
d=$(target fresh)
if out=$("$ROOT/scripts/amh-init.sh" "$d" 2>&1); then
	pass
else
	fail "amh-init.sh instantiates into an empty git repo" "$out"
fi

out=$(target_ladder "$d")
rc=$?
if [ "$rc" -eq 0 ]; then
	pass
else
	fail "the instantiated repo's own ladder is green" "exit $rc" "$out"
fi

# The seeds arrive carrying {{...}} slots by design, so the run must SAY so rather than
# claiming there is nothing left to do. The alternative — a tool that guesses — hands back
# a constitution that reads as finished and asserts nothing.
report=$("$ROOT/scripts/amh-init.sh" "$d" 2>&1)
if printf '%s' "$report" | grep -qF 'Search for {{'; then
	pass
else
	fail "the run reports the placeholders it deliberately did not fill" "$report"
fi

# =============================================================================
# 2. ...and that green is not vacuous.
#
# Exit 0 from a freshly built tree proves nothing on its own: an instantiation that
# installed a broken ladder, or none, exits 0 just as happily. Plant something the ladder
# is supposed to catch and require it to catch it (the D-020 question — can the thing be
# stubbed with the suite still green).
# =============================================================================
d=$(target positive_control)
"$ROOT/scripts/amh-init.sh" "$d" >/dev/null 2>&1
printf 'key = %s\n' "$(akia_token)" >"$d/deploy.sh"
out=$(target_ladder "$d")
rc=$?
if [ "$rc" -ne 0 ] && printf '%s' "$out" | grep -qF 'credential-shaped'; then
	pass
else
	fail "the instantiated ladder still catches a planted credential" "exit $rc" "$out"
fi

# =============================================================================
# 3. Re-running init upgrades the machinery and leaves the judgement alone.
#
# This is the documented upgrade path and the documented recovery, so each half is
# asserted separately: overwriting a shipped script is the POINT, and overwriting a word
# the adopter wrote would make the tool unusable for the job it exists to do.
# =============================================================================
d=$(target rerun)
"$ROOT/scripts/amh-init.sh" "$d" >/dev/null 2>&1

printf '\n# a local edit that must not survive\n' >>"$d/scripts/ladder.sh"
printf '\n# AN ADOPTER DECISION THAT MUST SURVIVE\n' >>"$d/amh.conf"
adopter_conf=$(cat "$d/amh.conf")
# B13's shape, and the recovery for it: a seed script that has lost its execute bit makes
# the ladder refuse to run its verification rung, and "re-run init" is what the docs tell
# an adopter to do about it.
chmod -x "$d/scripts/verify.sh"

if out=$("$ROOT/scripts/amh-init.sh" "$d" 2>&1); then
	pass
else
	fail "re-running init succeeds" "$out"
fi

if cmp -s "$ROOT/harness/templates/scripts/ladder.sh" "$d/scripts/ladder.sh"; then
	pass
else
	fail "a locally edited shipped script is restored by a re-run"
fi

if [ "$(cat "$d/amh.conf")" = "$adopter_conf" ]; then
	pass
else
	fail "a re-run does not clobber a word the adopter wrote"
fi

if [ -x "$d/scripts/verify.sh" ]; then
	pass
else
	fail "a re-run restores a seed script's lost execute bit"
fi

# =============================================================================
# 3b. The adoption brief lands once, and STAYS deleted.
#
# The brief ends by telling the agent to delete it. Under plain `keep` that instruction is a
# trap: the next upgrade run resurrects the file, and a repo that has been running the harness
# for a year is handed a document telling it to adopt one. So the write is conditional on a
# FRESH install, and both halves are asserted — a conditional nobody tests is a coin flip.
# =============================================================================
d=$(target adopt_brief)
"$ROOT/scripts/amh-init.sh" "$d" >/dev/null 2>&1
if [ -f "$d/AMH-ADOPT.md" ]; then
	pass
else
	fail "a fresh instantiation writes the adoption brief"
fi

# An annotated brief survives a re-run. This passes through the SKIP path, not the keep path —
# a re-run is never fresh — so it is asserted for what it is: the brief an adopter is part-way
# through is not touched, whichever branch protects it.
printf '\nOWNER CHOSE STANDARD; placeholders half done\n' >>"$d/AMH-ADOPT.md"
brief=$(cat "$d/AMH-ADOPT.md")
out=$("$ROOT/scripts/amh-init.sh" "$d" 2>&1)
if [ "$(cat "$d/AMH-ADOPT.md")" = "$brief" ] && printf '%s' "$out" | grep -qF 'already adopted'; then
	pass
else
	fail "a re-run leaves an annotated brief alone and says why" "$out"
fi

# ...and once deleted, it stays deleted. THIS is the assertion the FRESH gate exists for:
# replacing the condition with `true` must break it, and does.
rm -f "$d/AMH-ADOPT.md"
out=$("$ROOT/scripts/amh-init.sh" "$d" 2>&1)
if [ ! -e "$d/AMH-ADOPT.md" ]; then
	pass
else
	fail "an upgrade re-run does not resurrect a deleted adoption brief" "$out"
fi

# The gate needs BOTH markers, because either alone misfires on a real first-time adopter: a
# repo that happened to have a file called amh.conf would silently never receive the brief,
# and the symptom is a missing file with no diagnostic.
d=$(target adopt_stray_conf)
printf 'UNRELATED=1\n' >"$d/amh.conf"
"$ROOT/scripts/amh-init.sh" "$d" >/dev/null 2>&1
if [ -f "$d/AMH-ADOPT.md" ]; then
	pass
else
	fail "a first-time adopter with an unrelated amh.conf still gets the brief"
fi

# =============================================================================
# 3c. The integrity manifest reaches the adopter, and works THERE.
#
# Everything the shipped suite asserts about this rung it asserts against a synthesised
# fixture repo whose manifest the suite itself wrote. That proves the rung's logic and
# nothing about the delivery: an installer that never wrote the manifest, or wrote it before
# the scripts it hashes, would leave every one of those fixtures green while every real
# adopter got a permanent `skip` — or worse, a red ladder on a tree nobody had touched.
# =============================================================================
d=$(target manifest)
"$ROOT/scripts/amh-init.sh" "$d" >/dev/null 2>&1

if cmp -s "$ROOT/harness/templates/scripts/MANIFEST.sha256" "$d/scripts/MANIFEST.sha256"; then
	pass
else
	fail "a fresh instantiation installs the shipped integrity manifest"
fi

# The rung is live in the new tree, not skipping. The count is part of the assertion: a
# manifest that arrived truncated, or one written before the scripts, would still produce an
# `ok` line — with a smaller number.
out=$(target_ladder "$d")
if printf '%s' "$out" | grep -qF '   ok    5 shipped script(s) match the published hashes'; then
	pass
else
	fail "the instantiated repo verifies all five shipped scripts against the manifest" "$out"
fi

# The defect the whole unit exists to catch, exercised where it actually happens: a local edit
# to a shipped script in somebody else's repo.
printf '\n# a local edit to a shipped rail\n' >>"$d/scripts/redact.sh"
out=$(target_ladder "$d")
rc=$?
if [ "$rc" -ne 0 ] && printf '%s' "$out" | grep -qF 'scripts/redact.sh does not match the hash'; then
	pass
else
	fail "an edited shipped script turns the adopter's ladder red" "exit $rc" "$out"
fi

# ...and the documented repair puts both halves back. The manifest is `overwrite` policy for
# this reason: an adopter who edited it — to silence the rung, or by accident — must not keep
# that edit through an upgrade, or the guard is disabled by its own subject.
printf '# an edit to the manifest itself\n' >>"$d/scripts/MANIFEST.sha256"
"$ROOT/scripts/amh-init.sh" "$d" >/dev/null 2>&1
if cmp -s "$ROOT/harness/templates/scripts/redact.sh" "$d/scripts/redact.sh" &&
	cmp -s "$ROOT/harness/templates/scripts/MANIFEST.sha256" "$d/scripts/MANIFEST.sha256"; then
	pass
else
	fail "re-running init restores both the edited script and an edited manifest"
fi

out=$(target_ladder "$d")
rc=$?
if [ "$rc" -eq 0 ]; then
	pass
else
	fail "the repaired repo's ladder is green again" "exit $rc" "$out"
fi

# =============================================================================
# 4. The init placeholder list is bound to the document describing it.
#
# Both directions, because the two are separately silent: a name documented as `init` but
# absent from the list ships unfilled into a live config, and a name in the list but not
# in the document is an undocumented slot. The check runs against a COPY of the harness —
# amh-init.sh resolves its root from its own path, so a copy carrying only what it reads
# is enough, and the real tree is never mutated.
# =============================================================================
harness_copy() { # <name> -> prints the path
	local d="$WORK/$1"
	mkdir -p "$d/scripts"
	cp -R "$ROOT/harness" "$d/harness"
	cp "$ROOT/scripts/amh-init.sh" "$d/scripts/amh-init.sh"
	chmod +x "$d/scripts/amh-init.sh"
	printf '%s' "$d"
}

expect_init_dies() { # <name> <harness-dir> <target-dir>
	local out rc
	out=$("$2/scripts/amh-init.sh" "$3" 2>&1)
	rc=$?
	if [ "$rc" -eq 0 ]; then
		fail "$1" "expected a failure, amh-init succeeded" "$out"
	elif ! printf '%s' "$out" | grep -qF 'disagree'; then
		fail "$1" "failed, but not with the divergence message" "$out"
	else
		pass
	fi
}

h=$(harness_copy doc_extra)
# Appended as a table row, with the name supplied at runtime rather than written out: a
# spelled-out placeholder in this file would trip the placeholder guard, which reads live
# files — the D-004 class, and this file demonstrating it while testing it.
# shellcheck disable=SC2016 # the backticks are the table's own markdown syntax — the row
# must look exactly like a real one or the check would pass for the wrong reason. Scoped
# to this single printf, never the block.
printf '| `%s` | init | A slot the init script has never heard of. |\n' \
	TOTALLY_NEW_KNOB >>"$h/harness/PLACEHOLDERS.md"
expect_init_dies "a documented init placeholder missing from the script is fatal" \
	"$h" "$(target doc_extra_target)"

h=$(harness_copy list_extra)
sed -i "s/^INIT_PLACEHOLDERS='/INIT_PLACEHOLDERS='TOTALLY_NEW_KNOB /" \
	"$h/scripts/amh-init.sh"
expect_init_dies "an init placeholder missing from the document is fatal" \
	"$h" "$(target list_extra_target)"

# And the binding is not vacuous either: it must still pass on the real, unmutated tree —
# which cases 1–3 above have already exercised, since every one of them ran the check.

# =============================================================================
# 5. Every profile installs its own seed set, and every one of them is green.
#
# The load-bearing case is `light`, and it is load-bearing for a claim the other two cannot
# make: that assurance degrades by ARTIFACT PRESENCE rather than by a configured level. A repo
# with no ledger must produce a ladder that skips the ledger rung and stays green — if it went
# red instead, the profile would be a way to ship a broken tree, and the only honest fix would
# be the runtime flag this design refuses (DA-001).
#
# Absence is asserted as hard as presence: a profile that quietly installed everything would
# satisfy every green-ladder assertion here while doing nothing it claims to do.
# =============================================================================

# Sets PROFILE_DIR rather than printing it. A command substitution would run this in a
# subshell, and every pass() and fail() it performed would be counted into a copy of the
# tallies that dies with the subshell — a whole section of the suite reporting nothing, which
# is the silent-skip class this repo keeps rediscovering.
PROFILE_DIR=''
profile_case() { # <profile> <present-csv> <absent-csv>
	local profile=$1 present=$2 absent=$3 d out rc f missing='' extra=''
	d=$(target "profile_$profile")
	PROFILE_DIR=$d
	if out=$("$ROOT/scripts/amh-init.sh" --profile "$profile" "$d" 2>&1); then
		pass
	else
		fail "--profile $profile instantiates" "$out"
		return 0
	fi
	# shellcheck disable=SC2086 # the split is the point: both arguments are
	# space-separated path lists. Scoped to these two loops — none of these paths can
	# contain a space, they are fixed seed names written in this file.
	for f in $present; do
		[ -e "$d/$f" ] || missing="$missing $f"
	done
	# shellcheck disable=SC2086
	for f in $absent; do
		[ ! -e "$d/$f" ] || extra="$extra $f"
	done
	if [ -z "$missing" ] && [ -z "$extra" ]; then
		pass
	else
		fail "--profile $profile installs exactly its seed set" \
			"missing:$missing" "installed but should not be:$extra"
	fi
	out=$(target_ladder "$d")
	rc=$?
	if [ "$rc" -eq 0 ]; then
		pass
	else
		fail "the --profile $profile repo's own ladder is green" "exit $rc" "$out"
	fi
}

profile_case light \
	'AGENTS.md CLAUDE.md docs/STATE.md scripts/verify.sh scripts/ladder.sh amh.conf' \
	'docs/RUNBOOK.md docs/LEDGER.md docs/history/README.md'
d=$PROFILE_DIR

# ...and that green is the presence-derived kind, not the vacuous kind: the rung with nothing
# to check must SAY it skipped. A silent pass is indistinguishable from a ladder that lost the
# rung altogether (D-019).
out=$(target_ladder "$d")
if printf '%s' "$out" | grep -qF 'no ledger yet'; then
	pass
else
	fail "a light repo's ladder reports the ledger rung as skipped rather than passing it" "$out"
fi

# The positive control again, under light. Everything a smaller profile drops is prose; if one
# of them could also cost a guard, this is where that would surface.
printf 'key = %s\n' "$(akia_token)" >"$d/deploy.sh"
out=$(target_ladder "$d")
rc=$?
if [ "$rc" -ne 0 ] && printf '%s' "$out" | grep -qF 'credential-shaped'; then
	pass
else
	fail "a light instantiation still catches a planted credential" "exit $rc" "$out"
fi

profile_case standard \
	'AGENTS.md CLAUDE.md docs/STATE.md scripts/verify.sh scripts/ladder.sh amh.conf docs/RUNBOOK.md docs/LEDGER.md' \
	'docs/history/README.md'

# `full` has no seed left to be absent, so its absence list names the file the OTHER two
# profiles decline. Passing an empty list would have made this call's absence half a loop that
# runs zero times — an assertion that cannot fail, dressed as one that can.
profile_case full \
	'AGENTS.md CLAUDE.md docs/STATE.md scripts/verify.sh scripts/ladder.sh amh.conf docs/RUNBOOK.md docs/LEDGER.md docs/history/README.md' \
	'docs/NOTHING_IS_DECLINED_AT_FULL.md'

# The DEFAULT is `light`, and until this assertion existed nothing said so: every case above
# passes --profile explicitly, and every case elsewhere in this file passes none but asserts
# nothing about which seeds landed. Changing the default to `full` left the suite 30/30 green.
d=$(target profile_default)
"$ROOT/scripts/amh-init.sh" "$d" >/dev/null 2>&1
if [ -f "$d/AGENTS.md" ] && [ ! -e "$d/docs/LEDGER.md" ] && [ ! -e "$d/docs/history/README.md" ]; then
	pass
else
	fail "with no --profile the install is light"
fi

# The brief is the only place the profile is written down — the whole design refuses to record
# it anywhere a script could read — so the substitution being right is not cosmetic: it is the
# adopting agent's sole account of what it is looking at. Hardcoding a wrong profile into the
# template left the suite green. Both profiles, because a template that named one of them
# unconditionally would satisfy a single-profile check.
# shellcheck disable=SC2016 # the backticks are the brief's own markdown code span, matched
# literally by grep -F. Expanding them would run the word as a command. Scoped to this one
# condition rather than the file, so a genuine unexpanded expression elsewhere still reports.
if grep -qF 'used the `light` profile' "$d/AMH-ADOPT.md" &&
	grep -qF 'used the `full` profile' "$WORK/profile_full/AMH-ADOPT.md"; then
	pass
else
	fail "the brief states the profile the install actually used"
fi

# Escalation is a re-run, and it is the entire upgrade path between profiles: it must ADD the
# declined seeds while leaving what the adopter has already written alone. Both halves, because
# a re-run that clobbered the constitution would be the worse failure and would still satisfy
# an "it added the ledger" assertion on its own.
d=$(target profile_escalate)
"$ROOT/scripts/amh-init.sh" --profile light "$d" >/dev/null 2>&1
printf '\nAN ADOPTER SENTENCE THAT MUST SURVIVE\n' >>"$d/AGENTS.md"
adopter_agents=$(cat "$d/AGENTS.md")
out=$("$ROOT/scripts/amh-init.sh" --profile full "$d" 2>&1)
if [ -f "$d/docs/LEDGER.md" ] && [ -f "$d/docs/RUNBOOK.md" ] && [ -f "$d/docs/history/README.md" ]; then
	pass
else
	fail "re-running with a larger profile adds the seeds it declined before" "$out"
fi
if [ "$(cat "$d/AGENTS.md")" = "$adopter_agents" ]; then
	pass
else
	fail "escalating a profile does not clobber a word the adopter wrote"
fi

# The reverse of escalation, and the one that reaches every EXISTING adopter: `docs/UPGRADING.md`
# documents a bare `amh-init.sh <target>` as the upgrade path, and the default is now the
# smallest profile. A 1.8.0 adopter who has a runbook and a ledger must not be told those files
# are "not in the light profile" — presence outranks the profile, so they are kept.
#
# The silent half is asserted too, and it is the one that would never have been noticed: a
# declined file never enters the installed list, so gating before the presence test also drops
# it from the unfilled-placeholder report — the seed runbook ships with real {{...}} slots, and
# the adopter would have been told there was nothing left to fill in there.
d=$(target downgrade_rerun)
"$ROOT/scripts/amh-init.sh" --profile full "$d" >/dev/null 2>&1
out=$("$ROOT/scripts/amh-init.sh" "$d" 2>&1)
if [ -f "$d/docs/LEDGER.md" ] && [ -f "$d/docs/RUNBOOK.md" ] &&
	! printf '%s' "$out" | grep -qF '(not in the light profile' &&
	printf '%s' "$out" | grep -qF '0 not in the light profile'; then
	pass
else
	fail "a plain re-run keeps seeds the adopter already has instead of declining them" "$out"
fi
if printf '%s' "$out" | grep -qF 'docs/RUNBOOK.md'; then
	pass
else
	fail "a kept-but-out-of-profile seed still reaches the unfilled-placeholder report" "$out"
fi

# A declined file is NAMED, not silently absent. Nothing in the target tree records the
# profile, by design, so this output is the adopter's only account of what they did not get.
#
# The assertion runs to the END of the line, including which profile would supply the file.
# Stopping at the filename leaves the ADVICE untested, and the advice is the part that can be
# wrong while looking right: deleting the standard/full distinction made the ledger's line
# read "add it with --profile full" — telling an adopter to install the archive tier to get a
# ledger — with the whole suite green. Matching a token but not its position, D-007's shape,
# in an assertion rather than a guard.
out=$("$ROOT/scripts/amh-init.sh" --profile light "$(target profile_report)" 2>&1)
if printf '%s' "$out" | grep -qF 'docs/LEDGER.md (not in the light profile — add it with --profile standard)' &&
	printf '%s' "$out" | grep -qF 'docs/history/README.md (not in the light profile — add it with --profile full)' &&
	printf '%s' "$out" | grep -qF '3 not in the light profile'; then
	pass
else
	fail "the run names each declined seed, the profile that supplies it, and the tally" "$out"
fi

# An unknown profile dies at init rather than inside a guard in someone else's repo — the
# --merge-mode rule. Falling through to "install everything" would be the dangerous default.
out=$("$ROOT/scripts/amh-init.sh" --profile heavy "$(target profile_bad)" 2>&1)
rc=$?
if [ "$rc" -ne 0 ] && printf '%s' "$out" | grep -qF 'must be light, standard or full'; then
	pass
else
	fail "an unknown --profile is fatal at init" "exit $rc" "$out"
fi

# Every seed file must be classified. An unclassified one is fatal, and the check is
# exercised here rather than trusted: a table with a catch-all would silently bucket a new
# seed file for every adopter (the D-025 shape).
h=$(harness_copy seed_unclassified)
: >"$h/harness/templates/seed/docs/UNCLASSIFIED.md"
out=$("$h/scripts/amh-init.sh" "$(target seed_unclassified_target)" 2>&1)
rc=$?
if [ "$rc" -ne 0 ] && printf '%s' "$out" | grep -qF 'no profile classification'; then
	pass
else
	fail "a seed file with no profile classification is fatal" "exit $rc" "$out"
fi

# =============================================================================
printf '\n%d passed, %d failed\n' "$PASSED" "$FAILED"
[ "$FAILED" -eq 0 ]
