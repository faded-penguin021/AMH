#!/usr/bin/env bash
# Rung 3 of the ladder: this repository's full verification set.
#
# SEED TEMPLATE (AMH). Yours from the moment it is copied — this is one of the ladder's two
# extension points, and the reason the shipped ladder never needs a local edit.
#
# Invoked by scripts/ladder.sh, never directly by CI: CI runs the ladder, so the agent and CI
# execute the same entrypoint by construction and "green locally, red in CI" can only mean
# environment.
#
# Start with nothing but your existing test/build/lint commands. Guards accrete later, one at
# a time, each earning its place after a real violation.

set -uo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT" || exit 1

FAILS=0
step() { printf '\n   · %s\n' "$1"; }
bad() {
	printf '     FAIL %s\n' "$1"
	FAILS=$((FAILS + 1))
}

# {{INDIVIDUAL_TEST_BUILD_LINT_COMMANDS}} — one step per command, e.g.:
#
# step "unit tests"
# ./gradlew test --quiet || bad "unit tests"
#
# step "lint"
# ./gradlew lint --quiet || bad "lint"
#
# step "build"
# ./gradlew assembleDebug --quiet || bad "build"

step "verification set is not configured yet"
bad "fill in scripts/verify.sh with this repo's test, build and lint commands"

if [ "$FAILS" -gt 0 ]; then
	printf '\n   verification set: %d failure(s)\n' "$FAILS"
	exit 1
fi
printf '\n   verification set: clean\n'
