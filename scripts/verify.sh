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

mapfile -t SCRIPTS < <(git ls-files -co --exclude-standard '*.sh' | sort)

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

step "guard fixture suite"
scripts/test-ladder-guards.sh || bad "scripts/test-ladder-guards.sh"

if [ "$FAILS" -gt 0 ]; then
	printf '\n   verification set: %d failure(s)\n' "$FAILS"
	exit 1
fi
printf '\n   verification set: clean\n'
