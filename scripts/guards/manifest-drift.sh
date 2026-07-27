#!/usr/bin/env bash
# Repo-local guard: the shipped-script integrity manifest is generated, and current.
#
# The manifest is the only thing telling an adopter's ladder which bytes the harness actually
# shipped. A stale one is worse than none: it reports every legitimately upgraded script as
# locally edited, in someone else's repo, with the harness maintainer nowhere near it. So it
# is generated rather than written, and rebuilt-and-diffed here rather than remembered — the
# same treatment, for the same reason, as harness/dist/AMH.md.
#
# Only the TEMPLATE copy is checked here. The instance copy under scripts/ is held identical
# by copy-drift.sh, which compares every file in harness/templates/scripts/ — so a second
# comparison in this guard would manufacture the appearance of coverage without adding any.

set -uo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." || exit 1

OUT=harness/templates/scripts/MANIFEST.sha256

if [ ! -f "$OUT" ]; then
	printf '%s has not been built — run scripts/build-manifest.sh\n' "$OUT"
	exit 1
fi

# Asked BEFORE the rebuild, not discovered from its wreckage. Without this the diff below runs
# against a generator that refused to produce anything, and the verdict reads "stale or
# hand-edited" — the machine's missing toolchain reported as tampering. The shipped rung goes
# to some trouble to keep those two apart; a repo-local guard collapsing them would be the same
# defect with a smaller blast radius.
#
# It FAILS rather than warning, which is the opposite of the shipped rung's answer to the same
# condition, and deliberately: this guard runs only in the harness's own repository, where the
# manifest is a release artifact we are about to publish. Being unable to verify it is not a
# state to carry on from.
if ! command -v sha256sum >/dev/null 2>&1 && ! command -v shasum >/dev/null 2>&1; then
	printf 'no sha256sum or shasum on PATH, so %s could not be rebuilt — this guard checked NOTHING.\n' "$OUT"
	exit 1
fi

# stderr is NOT discarded here, unlike the sibling drift guard's first form. The generator's
# one refusal — no sha256sum and no shasum — would otherwise be swallowed, and this guard would
# report "stale or hand-edited" over a diff of empty hashes: the machine's missing toolchain
# reported as tampering, with the line that says otherwise thrown away. A guard that suppresses
# the evidence for its own verdict is worse than one that has no verdict.
if ! scripts/build-manifest.sh --stdout | diff -q - "$OUT" >/dev/null; then
	printf '%s is stale or hand-edited — a shipped script changed without the manifest.\n' "$OUT"
	printf 'Run scripts/build-manifest.sh, then copy the result into scripts/ as usual.\n'
	printf 'first differing lines:\n'
	scripts/build-manifest.sh --stdout | diff - "$OUT" | head -12 | sed 's/^/  /'
	exit 1
fi

printf '%s matches the scripts it describes (%s entries)\n' \
	"$OUT" "$(grep -cv '^#' "$OUT" | tr -d ' ')"
