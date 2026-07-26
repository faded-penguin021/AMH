#!/usr/bin/env bash
# AMH — fixture regression suite for the ladder's guards.
#
# Guards are code. A guard that false-passes is worse than no guard, because the
# repo now believes it is protected. Every guard therefore gets a synthesized tiny
# repo and an assertion on its pass / warn / fail behaviour.
#
# Each test builds a throwaway repo containing the shipped scripts, breaks exactly
# one thing, and asserts the ladder's verdict.
#
# Shipped by the Agentic Maintenance Harness. Repo-agnostic: do not edit locally.

set -uo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

export GIT_AUTHOR_NAME=amh-test GIT_AUTHOR_EMAIL=amh@test.invalid
export GIT_COMMITTER_NAME=amh-test GIT_COMMITTER_EMAIL=amh@test.invalid

PASSED=0
FAILED=0

# --- fixture construction ---------------------------------------------------
mk() { # mk <name> -> prints the fixture path
	local d="$WORK/$1"
	mkdir -p "$d/scripts/guards" "$d/docs"
	cp "$ROOT/scripts/ladder.sh" "$ROOT/scripts/redact.sh" \
		"$ROOT/scripts/command-guard.sh" "$d/scripts/"
	chmod +x "$d/scripts"/*.sh
	cat >"$d/amh.conf" <<-'CONF'
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
		CITATION_SCAN_PATHS='scripts'
		CITATION_EXCLUDE=''
		POISON_TOKENS='[skip ci]'
		PLAN_DIR=docs/plans
		RULE_FILES=''
	CONF
	cat >"$d/docs/STATE.md" <<-'ST'
		# STATE

		## Project
		A fixture.

		## Current state
		No active work.

		## Owner queue
		**Pending owner actions:** (none)

		## Changelog
		- 2026-01-01 — nothing yet.
	ST
	# D-001 and D-002 are the citation fixtures' own material and must stay UNMARKED.
	# Any row a shipped script cites in its comments has to exist here too, marked —
	# otherwise the citation guard fails every fixture for a reason none of them is
	# testing. Derived from the scripts just copied, never hardcoded: a hardcoded list
	# rots the first time a shipped comment cites a new row (it did).
	{
		printf '# LEDGER\n\n- D-001: a durable fact.\n- D-002: another durable fact.\n'
		grep -ohE 'D[A-Z]?-[0-9]+' "$d/scripts"/*.sh | sort -u | grep -vxE 'D-00[12]' |
			while IFS= read -r id; do
				printf -- '- %s [cited]: a durable fact a shipped script cites.\n' "$id"
			done
	} >"$d/docs/LEDGER.md"
	(
		cd "$d" || exit 1
		git init -q .
		git add -A
		git commit -qm "fixture"
	)
	printf '%s' "$d"
}

run() { (cd "$1" && CI=1 scripts/ladder.sh --guards-only 2>&1); }

# --- assertions -------------------------------------------------------------
report() { # <ok|no> <name> <detail...>
	if [ "$1" = ok ]; then
		PASSED=$((PASSED + 1))
	else
		FAILED=$((FAILED + 1))
		shift
		printf '  FAIL %s\n' "$1" >&2
		shift
		[ $# -gt 0 ] && printf '%s\n' "$*" | sed 's/^/       /' >&2
	fi
}

expect_pass() { # <name> <dir>
	local out rc
	out=$(run "$2")
	rc=$?
	if [ "$rc" -eq 0 ]; then report ok; else report no "$1" "expected exit 0, got $rc" "$out"; fi
}

expect_fail() { # <name> <dir> <grep-pattern>
	local out rc
	out=$(run "$2")
	rc=$?
	if [ "$rc" -eq 0 ]; then
		report no "$1" "expected a failure, ladder passed" "$out"
	elif ! printf '%s' "$out" | grep -qF "$3"; then
		report no "$1" "failed as expected but the message never mentioned '$3'" "$out"
	else
		report ok
	fi
}

expect_warn() { # <name> <dir> <grep-pattern>
	local out rc
	out=$(run "$2")
	rc=$?
	if [ "$rc" -ne 0 ]; then
		report no "$1" "expected exit 0 with a warning, got $rc" "$out"
	elif ! printf '%s' "$out" | grep -qF "$3"; then
		report no "$1" "no warning mentioning '$3'" "$out"
	else
		report ok
	fi
}

filler() { head -c "$1" /dev/zero | tr '\0' 'x'; }

# =============================================================================
printf 'ladder guard fixtures\n'

# --- baseline
d=$(mk baseline)
expect_pass "clean fixture passes" "$d"

# --- STATE size band
d=$(mk state_hard)
{
	echo
	filler $((17 * 1024))
} >>"$d/docs/STATE.md"
expect_fail "STATE over the hard cap fails" "$d" "hard cap"

d=$(mk state_warn)
{
	echo
	filler $((15 * 1024))
} >>"$d/docs/STATE.md"
expect_warn "STATE over the soft cap warns only" "$d" "soft cap"

# Landing check: a trim out of warn territory must reach the floor, not stop in
# the debounce band. This is the Goodhart hole the size thresholds alone leave.
d=$(mk state_landing_bad)
{
	echo
	filler $((15 * 1024))
} >>"$d/docs/STATE.md"
(cd "$d" && git commit -qam "grow past the soft cap")
head -c $((11 * 1024)) "$d/docs/STATE.md" >"$d/docs/STATE.tmp" && mv "$d/docs/STATE.tmp" "$d/docs/STATE.md"
expect_fail "micro-trim that crosses below the cap but misses the floor fails" "$d" "stops short"

# The same hole one band higher: a trim that never crosses below the soft cap. If the
# landing check only fires on a crossing, grow-to-15.5 / trim-to-14.2 repeats forever
# under a mere warning, which is exactly what the debounce claims to prevent.
d=$(mk state_landing_above_warn)
{
	echo
	filler $((16 * 1024))
} >>"$d/docs/STATE.md"
(cd "$d" && git commit -qam "grow well past the soft cap")
head -c $((15 * 1024)) "$d/docs/STATE.md" >"$d/docs/STATE.tmp" && mv "$d/docs/STATE.tmp" "$d/docs/STATE.md"
expect_fail "a trim that stops short while still over the cap fails" "$d" "stops short"

d=$(mk state_landing_good)
{
	echo
	filler $((15 * 1024))
} >>"$d/docs/STATE.md"
(cd "$d" && git commit -qam "grow past the soft cap")
head -c $((5 * 1024)) "$d/docs/STATE.md" >"$d/docs/STATE.tmp" && mv "$d/docs/STATE.tmp" "$d/docs/STATE.md"
expect_pass "compression landing on the floor passes" "$d"

# --- STATE structure
d=$(mk state_section)
grep -v '^## Changelog' "$d/docs/STATE.md" >"$d/t" && mv "$d/t" "$d/docs/STATE.md"
expect_fail "a deleted required section fails" "$d" "is missing"

# Cheapest possible "compliance": keep the headers, delete everything under them.
d=$(mk state_empty_section)
awk '/^## Current state/{print; skip=1; next} skip && /^## /{skip=0} !skip' \
	"$d/docs/STATE.md" >"$d/t" && mv "$d/t" "$d/docs/STATE.md"
expect_fail "a required section emptied of content fails" "$d" "is empty"

d=$(mk state_ownerq)
grep -v '^## Owner queue' "$d/docs/STATE.md" >"$d/t" && mv "$d/t" "$d/docs/STATE.md"
expect_warn "a deleted Owner queue warns" "$d" "Owner queue"

# --- ledger rollover
d=$(mk ledger_cap)
sed -i 's/^LEDGER_LINE_CAP=800/LEDGER_LINE_CAP=4/' "$d/amh.conf"
printf -- '- D-003: past the cap.\n' >>"$d/docs/LEDGER.md"
expect_fail "a row starting past the line cap fails" "$d" "past the"

# --- citations
d=$(mk cite_missing)
printf '# see D-099\n' >"$d/scripts/thing.sh"
expect_fail "a citation with no ledger row fails" "$d" "no such ledger row"

d=$(mk cite_unmarked)
printf '# see D-001\n' >"$d/scripts/thing.sh"
expect_fail "a cited row without its [cited] marker fails" "$d" "not marked"

d=$(mk cite_stale)
sed -i 's/^- D-002:/- D-002 [cited]:/' "$d/docs/LEDGER.md"
expect_fail "a [cited] marker with no citation fails" "$d" "no longer cited"

d=$(mk cite_ok)
printf '# see D-001\n' >"$d/scripts/thing.sh"
sed -i 's/^- D-001:/- D-001 [cited]:/' "$d/docs/LEDGER.md"
expect_pass "a citation with its marker passes" "$d"

d=$(mk cite_dupe)
printf -- '- D-001: a second row with the same number.\n' >>"$d/docs/LEDGER.md"
expect_fail "duplicate row numbers fail" "$d" "duplicate ledger row numbers"

# --- secret shapes
d=$(mk secret_plain)
tok="AKIA$(LC_ALL=C tr -dc 'A-Z0-9' </dev/urandom | head -c 16)"
printf 'key = %s\n' "$tok" >"$d/scripts/deploy.sh"
out=$(run "$d")
if printf '%s' "$out" | grep -q 'credential-shaped'; then
	# The diagnostic must name the file and the position and NOTHING else. A
	# regression to printing the matching line would defeat the whole guard.
	if printf '%s' "$out" | grep -qF "$tok"; then
		report no "secret scan is value-free" "the diagnostic printed the token itself" "$out"
	else
		report ok
	fi
	report ok
else
	report no "secret-shaped string is caught" "not flagged" "$out"
	report no "secret scan is value-free" "(not reached)"
fi

# A file name with a space: the file list must be NUL-separated, or the scan
# silently skips it — a hole that looks exactly like a pass.
d=$(mk secret_spacey)
tok="AKIA$(LC_ALL=C tr -dc 'A-Z0-9' </dev/urandom | head -c 16)"
printf 'key = %s\n' "$tok" >"$d/scripts/deploy notes.sh"
expect_fail "a secret in a file name with a space is still caught" "$d" "credential-shaped"

# --- repo-local guard extension point
d=$(mk guard_ok)
printf '#!/usr/bin/env bash\nexit 0\n' >"$d/scripts/guards/fine.sh"
expect_pass "a passing repo-local guard passes" "$d"

d=$(mk guard_bad)
printf '#!/usr/bin/env bash\necho "domain rule violated"\nexit 1\n' >"$d/scripts/guards/bad.sh"
expect_fail "a failing repo-local guard fails the ladder" "$d" "domain rule violated"

# =============================================================================
printf '\n%d passed, %d failed\n' "$PASSED" "$FAILED"
[ "$FAILED" -eq 0 ]
