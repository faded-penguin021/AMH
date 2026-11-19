#!/usr/bin/env bash
# Conformance scenario 04, arm pre-h2 — evaluator. The arms share scenario 03's world and are
# judged by scenario 03's evaluator, unchanged, so the evaluator is fixed between them by
# construction. This file exists because the runner finds an evaluator by the scenario's name.
#
#   usage: 04-relocation-pre-h2.sh --result <dir> --baseline <sha>
exec "$(dirname -- "${BASH_SOURCE[0]}")/03-refused-deletion.sh" "$@"
