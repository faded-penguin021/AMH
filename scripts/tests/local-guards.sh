#!/usr/bin/env bash
# Fixture suite for this repo's OWN guards (scripts/guards/*.sh).
#
# The shipped fixture suite (scripts/test-ladder-guards.sh) is byte-compared against
# its template, so repo-local fixtures cannot live there — putting them there would
# contaminate the repo-agnostic artifact, which is the thing copy-drift.sh exists to
# prevent. They live here instead, run from scripts/verify.sh, which is the ladder's
# repo-owned extension point.
#
# Until this file existed, every repo-local guard shipped untested while the
# constitution demanded a fixture for each — the rule was unsatisfiable as written.
#
# Method: snapshot the working tree into a throwaway git repo, break exactly one
# thing, and assert the guard's verdict. Never mutate the real tree — a suite that
# leaves the repo dirty when interrupted is worse than no suite.

set -uo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

export GIT_AUTHOR_NAME=amh-test GIT_AUTHOR_EMAIL=amh@test.invalid
export GIT_COMMITTER_NAME=amh-test GIT_COMMITTER_EMAIL=amh@test.invalid

PASSED=0
FAILED=0

snapshot() { # snapshot <name> -> prints the path
	local d="$WORK/$1"
	mkdir -p "$d"
	(cd "$ROOT" && git ls-files -co --exclude-standard -z | tar -cf - --null -T -) |
		(cd "$d" && tar -xf -)
	(
		cd "$d" || exit 1
		git init -q .
		git add -A
		git commit -qm snapshot
	)
	printf '%s' "$d"
}

expect() { # expect <pass|fail> <name> <dir> <guard> [message-substring]
	local want=$1 name=$2 dir=$3 guard=$4 want_msg=${5:-}
	local out rc
	# shellcheck disable=SC2086  # $guard may carry arguments, e.g. "x.sh --tag v1"
	out=$(cd "$dir" && bash scripts/guards/$guard 2>&1)
	rc=$?
	if [ "$want" = pass ] && [ "$rc" -ne 0 ]; then
		FAILED=$((FAILED + 1))
		printf '  FAIL %s — expected pass, got %d\n%s\n' "$name" "$rc" "$out" >&2
	elif [ "$want" = fail ] && [ "$rc" -eq 0 ]; then
		FAILED=$((FAILED + 1))
		printf '  FAIL %s — expected failure, guard passed\n%s\n' "$name" "$out" >&2
	elif [ -n "$want_msg" ] && ! printf '%s' "$out" | grep -qF "$want_msg"; then
		FAILED=$((FAILED + 1))
		printf '  FAIL %s — verdict right but message never mentioned %s\n%s\n' "$name" "$want_msg" "$out" >&2
	else
		PASSED=$((PASSED + 1))
	fi
}

printf 'repo-local guard fixtures\n'

base=$(snapshot base)
expect pass "copy-drift: clean tree" "$base" copy-drift.sh
expect pass "dist-drift: clean tree" "$base" dist-drift.sh
expect pass "placeholder-integrity: clean tree" "$base" placeholder-integrity.sh
expect pass "version-lockstep: clean tree" "$base" version-lockstep.sh
expect pass "path-refs: clean tree" "$base" path-refs.sh

d=$(snapshot drift_script)
printf '# local edit\n' >>"$d/scripts/redact.sh"
expect fail "copy-drift: an edited shipped script" "$d" copy-drift.sh "drift:"

d=$(snapshot drift_missing)
rm "$d/scripts/session-start.sh"
expect fail "copy-drift: a shipped script not installed" "$d" copy-drift.sh "not installed here"

d=$(snapshot drift_dist)
printf 'hand edit\n' >>"$d/harness/dist/AMH.md"
expect fail "dist-drift: a hand-edited bundle" "$d" dist-drift.sh "stale or hand-edited"

d=$(snapshot drift_src)
printf '\nnew prose\n' >>"$d/harness/src/40-adaptation.md"
expect fail "dist-drift: sources changed without a rebuild" "$d" dist-drift.sh "stale or hand-edited"

d=$(snapshot ph_undocumented)
# Assembled at runtime: a stored placeholder literal would make this file fail the
# guard it is testing (the D-004 class — fixtures must never be stored literals).
printf '{{%s}}\n' TOTALLY_NEW_KNOB >>"$d/harness/templates/seed/CLAUDE.md"
expect fail "placeholders: undocumented" "$d" placeholder-integrity.sh "not documented"

d=$(snapshot ph_unfilled)
printf '{{%s}}\n' PROJECT_NAME >>"$d/docs/STATE.md"
expect fail "placeholders: left unfilled in a live file" "$d" placeholder-integrity.sh "unfilled placeholder"

d=$(snapshot ver_bump)
printf '1.9.0\n' >"$d/harness/VERSION"
expect fail "version-lockstep: VERSION bumped alone" "$d" version-lockstep.sh "harness/VERSION says 1.9.0"

d=$(snapshot ver_conf)
sed -i 's/^AMH_VERSION=.*/AMH_VERSION=1.7.0/' "$d/amh.conf"
expect fail "version-lockstep: amh.conf drifted" "$d" version-lockstep.sh "amh.conf"

d=$(snapshot ver_tag)
expect fail "version-lockstep: a tag that does not match" "$d" "version-lockstep.sh --tag amh-v9.9.9" "does not match"

d=$(snapshot refs_broken)
printf '\nSee [the plan](docs/NOTHING_HERE.md).\n' >>"$d/docs/RUNBOOK.md"
expect fail "path-refs: a broken relative link" "$d" path-refs.sh "broken link"

d=$(snapshot refs_backtick)
# shellcheck disable=SC2016 # the backticks are the fixture: path-refs.sh only sees a
# citation inside a markdown code span, so expanding them would delete what is on trial.
printf '\nRun `scripts/does-not-exist.sh` first.\n' >>"$d/docs/RUNBOOK.md"
expect fail "path-refs: a cited path that does not exist" "$d" path-refs.sh "nonexistent path"

# A file name with a space: `for f in $files` word-splits it away, and the guard then
# prints a resolved count and a green line for a file it never opened.
d=$(snapshot refs_spacey)
# shellcheck disable=SC2016 # literal backticks: same fixture form as above.
printf 'See `docs/NOTHING_HERE.md` for the details.\n' >"$d/notes with space.md"
expect fail "path-refs: a bad ref in a file name with a space" "$d" path-refs.sh "nonexistent path"

# The docs/plans exclusion is a hole by design (a plan may name what it has not built).
# It is bounded to that directory and asserted here so the boundary is a tested one.
d=$(snapshot refs_plans_excluded)
mkdir -p "$d/docs/plans"
# shellcheck disable=SC2016 # literal backticks: same fixture form as above.
printf 'Build `scripts/does-not-exist.sh` next.\n' >"$d/docs/plans/future.md"
expect pass "path-refs: a plan may name a path it has not built yet" "$d" path-refs.sh

# A bare filename with no slash. The backtick pattern required an embedded slash, so a
# repo-ROOT file could not match it and a citation to one could never fail — which is how
# CONTRIBUTING.md stayed cited five times while absent, inside the guard admitted to close
# that incident.
d=$(snapshot refs_bare_missing)
# shellcheck disable=SC2016 # literal backticks: same fixture form as above.
printf '\nRead `NOTHING_HERE.md` first.\n' >>"$d/docs/RUNBOOK.md"
expect fail "path-refs: a cited bare filename that exists nowhere" "$d" path-refs.sh "no file by that name"

# The other half, and the reason bare names resolve by BASENAME rather than from the repo
# root: the prose says `STATE.md`, never `docs/STATE.md`. A root-relative test would call
# that broken, and a guard that cries wolf on the house style gets ignored — which is why
# the root-relative widening was rejected at 24 hits for 2 true positives.
d=$(snapshot refs_bare_subdir)
# shellcheck disable=SC2016 # literal backticks: same fixture form as above.
printf '\nRead `STATE.md` first.\n' >>"$d/docs/RUNBOOK.md"
expect pass "path-refs: a bare filename resolves from a subdirectory" "$d" path-refs.sh

# The match must be WHOLE-LINE. Dropping `-x` left every fixture above green while
# `TATE.md` and `adder.sh` resolved as substrings of real basenames — a citation to a
# file that does not exist, reported as resolving, which is the entire failure this
# section was added to stop.
d=$(snapshot refs_bare_substring)
# shellcheck disable=SC2016 # literal backticks: same fixture form as above.
printf '\nRead `TATE.md` first.\n' >>"$d/docs/RUNBOOK.md"
expect fail "path-refs: a bare name that is only a substring of a real file" "$d" path-refs.sh "no file by that name"

# `git ls-files` answers from the index, so a file removed with plain `rm` is still listed.
# Resolving against that made a citation to a deleted file read as resolving.
# `amh.conf` rather than a `.md` file: deleting one of the scanned documents would also
# trip sections (a) and (b), so the fixture could pass without section (c) working.
d=$(snapshot refs_bare_deleted)
rm "$d/amh.conf"
expect fail "path-refs: a bare name whose file was deleted but is still in the index" "$d" path-refs.sh "no file by that name"

printf '\n%d passed, %d failed\n' "$PASSED" "$FAILED"
[ "$FAILED" -eq 0 ]
