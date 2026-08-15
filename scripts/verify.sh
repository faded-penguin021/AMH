#!/usr/bin/env bash
# Rung 3 of the ladder: this repository's full verification set.
#
# The repo's product is shell + markdown, so verification is: every script parses,
# every script lints (where shellcheck is available), and the guards' own fixture
# suite passes. Invoked by scripts/ladder.sh — never run standalone in CI, so that
# CI and the agent execute the same entrypoint.

set -uo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT" || exit 1

FAILS=0
step() { printf '\n   · %s\n' "$1"; }
bad() {
	printf '     FAIL %s\n' "$1"
	FAILS=$((FAILS + 1))
}

SCRIPTS=()
while IFS= read -r script; do
	SCRIPTS+=("$script")
done < <(git ls-files -co --exclude-standard '*.sh' | sort)

step "parse check (bash -n) on ${#SCRIPTS[@]} script(s)"
for s in "${SCRIPTS[@]}"; do
	bash -n "$s" 2>/tmp/amh-parse.$$ || {
		bad "$s"
		sed 's/^/       /' /tmp/amh-parse.$$
	}
done
rm -f /tmp/amh-parse.$$

step "shellcheck"
if command -v shellcheck >/dev/null 2>&1; then
	shellcheck -x "${SCRIPTS[@]}" || bad "shellcheck reported findings"
elif [ -n "${CI:-}" ]; then
	# CI installs it; a silent skip there would let lint rot land on the default branch.
	bad "shellcheck is not installed in CI"
else
	printf '     skip (not installed locally — CI runs it)\n'
fi

step "shipped guard fixture suite"
scripts/test-ladder-guards.sh || bad "scripts/test-ladder-guards.sh"

step "repo-local guard fixture suite"
scripts/tests/local-guards.sh || bad "scripts/tests/local-guards.sh"

# The behavioural conformance lab's own tests. Deterministic by construction — no model, no
# network, no cost — which is the whole reason they may block here while model-backed runs
# stay permanently non-blocking. Read conformance/README.md before treating a green line
# from this rung as information about an agent: it says the evaluators are deterministic and
# mutation-sensitive, and nothing at all about how any agent behaves.
step "conformance evaluator self-test"
conformance/selftest.sh || bad "conformance/selftest.sh"

# Last, because it is the slowest rung and the only one that builds a whole second repo.
# It is also the only one that executes the adopter's path at all: everything above tests
# this repo against itself, and the defects that path has produced were invisible to all
# of it (D-023).
step "instantiation end-to-end"
scripts/tests/test-init-e2e.sh || bad "scripts/tests/test-init-e2e.sh"

if [ "$FAILS" -gt 0 ]; then
	printf '\n   verification set: %d failure(s)\n' "$FAILS"
	exit 1
fi
printf '\n   verification set: clean\n'
