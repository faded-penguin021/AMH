#!/usr/bin/env bash
# Repo-local guard: harness/dist/AMH.md is generated, and matches its sources.
#
# The bundle exists so the harness survives as one pasteable document while the
# templates stay real, copyable files. That only holds if the two cannot disagree —
# so rebuild and diff rather than trusting anyone to remember. Editing the bundle
# by hand is the mistake this catches; the fix is always to edit harness/src/ or
# harness/templates/ and run scripts/build-dist.sh.

set -uo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." || exit 1

OUT=harness/dist/AMH.md

if [ ! -f "$OUT" ]; then
	printf '%s has not been built — run scripts/build-dist.sh\n' "$OUT"
	exit 1
fi

if ! scripts/build-dist.sh --stdout 2>/dev/null | diff -q - "$OUT" >/dev/null; then
	printf '%s is stale or hand-edited. Edit harness/src/ or harness/templates/, then run scripts/build-dist.sh.\n' "$OUT"
	printf 'first differing lines:\n'
	scripts/build-dist.sh --stdout 2>/dev/null | diff - "$OUT" | head -12 | sed 's/^/  /'
	exit 1
fi

printf '%s matches its sources (%s lines)\n' "$OUT" "$(wc -l <"$OUT" | tr -d ' ')"
