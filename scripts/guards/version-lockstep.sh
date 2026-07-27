#!/usr/bin/env bash
# Repo-local guard: harness/VERSION is the single source, and every hand-maintained
# copy of the version agrees with it.
#
# Six places state this repo's harness version, and five of them are hand-written.
# Without this check, bumping VERSION and rebuilding leaves the constitution, the
# state file and amh.conf quietly claiming the old number — while the constitution's
# own text asserts they "are checked against it". Prose that claims enforcement is
# worse than no claim: it is exactly what stops a reviewer checking by hand.
#
# harness/dist/AMH.md is deliberately NOT checked here. Its header is generated from
# harness/VERSION by build-dist.sh, so it cannot disagree unless the bundle is stale —
# which is dist-drift.sh's job. Checking it here would manufacture the appearance of
# coverage without adding any.
#
#   scripts/guards/version-lockstep.sh              check the tree
#   scripts/guards/version-lockstep.sh --tag TAG    also require TAG == amh-v<VERSION>

set -uo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." || exit 1

fails=0
note() {
	printf '%s\n' "$1"
	fails=$((fails + 1))
}

[ -f harness/VERSION ] || {
	printf 'harness/VERSION is missing — there is no single source to check against\n'
	exit 1
}
VERSION=$(tr -d '[:space:]' <harness/VERSION)

case $VERSION in
[0-9]*.[0-9]*.[0-9]*) ;;
*) note "harness/VERSION is '$VERSION', which is not MAJOR.MINOR.PATCH" ;;
esac

# <label> <file> <sed extraction script>
check() {
	local label=$1 file=$2 script=$3 found
	if [ ! -f "$file" ]; then
		note "$label: $file does not exist"
		return
	fi
	found=$(sed -n "$script" "$file" | head -1)
	if [ -z "$found" ]; then
		note "$label: no version found in $file (the guard's pattern and the file have diverged — fix whichever is wrong)"
	elif [ "$found" != "$VERSION" ]; then
		note "$label: $file says $found, harness/VERSION says $VERSION"
	fi
}

check "changelog top entry" harness/CHANGELOG.md 's/^## \([0-9][0-9.]*\).*/\1/p'
check "constitution" AGENTS.md 's/.*Adopted harness version: \*\*AMH \([0-9][0-9.]*\)\*\*.*/\1/p'
check "state file" docs/STATE.md 's/.*Adopted harness version: \*\*AMH \([0-9][0-9.]*\)\*\*.*/\1/p'
check "amh.conf" amh.conf 's/^AMH_VERSION=\([0-9][0-9.]*\).*/\1/p'
# The README's quickstart pins a release tag, which makes it a FIFTH hand-written copy of the
# version — and an unchecked one drifts the moment a release lands, handing every new adopter
# the previous version while the repo claims the current one. Checked here rather than trusted
# to the release checklist, because a checklist is a thing a human remembers.
check "README quickstart tag" README.md 's/.*--branch amh-v\([0-9][0-9.]*\).*/\1/p'

if [ "${1:-}" = "--tag" ]; then
	tag=${2:-}
	if [ "$tag" != "amh-v$VERSION" ]; then
		note "tag '$tag' does not match harness/VERSION ($VERSION) — expected amh-v$VERSION"
	fi
fi

[ "$fails" -eq 0 ] || exit 1
printf 'version %s consistent across 5 hand-maintained copies\n' "$VERSION"
