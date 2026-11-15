#!/usr/bin/env bash
# Conformance scenario 04, arm pre-h2 — the H2 relocation-regression experiment (research-gaps
# plan, H6b). Everything but the arm's name is in conformance/arms/h2-relocation.sh; the other
# arm is the sibling directory, and selftest holds both task.md files byte-identical to
# scenario 03's.
#
#   usage: fixture.sh <workdir>
exec "$(dirname -- "${BASH_SOURCE[0]}")/../../arms/h2-relocation.sh" pre-h2 "$@"
