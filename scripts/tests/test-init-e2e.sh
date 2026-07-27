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
#   4. the init placeholder list and harness/PLACEHOLDERS.md cannot diverge in silence.
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
printf '\n%d passed, %d failed\n' "$PASSED" "$FAILED"
[ "$FAILED" -eq 0 ]
