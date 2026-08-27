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
#   scripts/guards/version-lockstep.sh                      check the tree
#   scripts/guards/version-lockstep.sh --tag TAG            also require TAG == amh-v<VERSION>
#   scripts/guards/version-lockstep.sh --against-latest-tag also require VERSION to be exactly
#                                                           one bump above the newest amh-v tag
#
# The --against-latest-tag mode exists because the version used to be assigned per unit,
# mid-train, by whichever session happened to write it: a train carried four numbers and only
# the head one was ever tagged (DC-023). The owner's rule is that the number is decided at PR
# time against the latest tag. Sessions still WRITE a version as they work — that half is
# unchanged, deliberately, because a repo that carries no version between releases would need
# every lockstep copy to learn a placeholder — and this mode validates it once, where the
# decision is actually made. The owner named the shape as the easy fix rather than the clean
# one, and the seam is worth stating: a merged release nobody tagged leaves the next PR
# computing from a stale tag and reading a legitimate version as two bumps. That failure is
# loud rather than silent, and its message says to go tag the predecessor.
#
# It is NOT part of the default run, and the reason is NOT that it touches the network — it does
# not: `git tag -l` reads .git/refs/tags and nothing else, offline, in milliseconds. The reason
# is that a clone's local tag list is not the repository's: a session clone routinely arrives
# with no tags at all (this repo's own session banner says so when it happens), and as a rung
# that state would fail every such session over something its change cannot affect. So CI, which
# checks out with tags, invokes it explicitly at the one event where the release decision is
# real. That is one verification command CI runs and `scripts/ladder.sh` does not, which is a
# deliberate and narrow exception to the single-entrypoint rule (AMH P4) rather than an
# oversight — stated here because an unexplained one is indistinguishable from drift.

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

# The first changelog entry is part of the release lockstep, not merely the first heading that
# happens to contain digits. Skipping an `Unreleased` heading let a seed change advertise PATCH
# adopter impact while every version-bearing file still named the already-published release.
# That is a green check over the exact omission this guard exists to catch.
first_changelog_entry=$(sed -n 's/^## //p' harness/CHANGELOG.md 2>/dev/null | head -1)
case $first_changelog_entry in
"$VERSION "*) ;;
*) note "changelog top entry is '${first_changelog_entry:-missing}', expected version $VERSION — replace an Unreleased top entry and align every lockstep copy" ;;
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

check "constitution" AGENTS.md 's/.*Adopted harness version: \*\*AMH \([0-9][0-9.]*\)\*\*.*/\1/p'
check "state file" docs/STATE.md 's/.*Adopted harness version: \*\*AMH \([0-9][0-9.]*\)\*\*.*/\1/p'
check "amh.conf" amh.conf 's/^AMH_VERSION=\([0-9][0-9.]*\).*/\1/p'
# The README's Quick Start pins a release tag, which makes it a FIFTH hand-written copy of the
# version — and an unchecked one drifts the moment a release lands, handing every new adopter
# the previous version while the repo claims the current one. Checked here rather than trusted
# to the release checklist, because a checklist is a thing a human remembers.
check "README Quick Start tag" README.md 's/.*--branch amh-v\([0-9][0-9.]*\).*/\1/p'

if [ "${1:-}" = "--tag" ]; then
	tag=${2:-}
	if [ "$tag" != "amh-v$VERSION" ]; then
		note "tag '$tag' does not match harness/VERSION ($VERSION) — expected amh-v$VERSION"
	fi
fi

# The newest amh-v tag by NUMERIC precedence, never by tag-list order: `git tag -l` sorts
# lexically, where amh-v9.1.0 comes after amh-v10.2.0 and the guard would validate every PR
# against a tag two majors stale while looking green. Three fields compared as numbers, and an
# empty list is a hard failure rather than a pass, because "no tags found" and "the version is
# fine" must not print the same thing.
#
# ANCESTRY IS NOT CHECKED, deliberately, and the consequence is worth knowing rather than
# discovering: this lists every tag in the clone, so a tag pushed on any branch becomes the
# comparison basis for every open PR at once. That matches how releases are actually cut here —
# the tag lands on main and every open PR should then be measured from it — but it does mean a
# stray amh-v tag anywhere reddens unrelated PRs until it is deleted.
latest_release_tag() {
	git tag -l 'amh-v[0-9]*' | sed -n 's/^amh-v\([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\)$/\1/p' | awk -F. '
		BEGIN { M = -1; N = -1; P = -1 }
		{ if ($1 > M || ($1 == M && ($2 > N || ($2 == N && $3 > P)))) { M = $1; N = $2; P = $3 } }
		END { if (M < 0) exit 1; printf "%d.%d.%d", M, N, P }
	'
}

if [ "${1:-}" = "--against-latest-tag" ]; then
	if ! latest=$(latest_release_tag) || [ -z "$latest" ]; then
		note "no amh-v<MAJOR>.<MINOR>.<PATCH> tag is listed in this clone, so this mode compared NOTHING — run git fetch --tags before trusting a green line here"
	else
		IFS=. read -r lm ln lp <<<"$latest"
		major="$((lm + 1)).0.0"
		minor="$lm.$((ln + 1)).0"
		patch="$lm.$ln.$((lp + 1))"
		case $VERSION in
		"$major" | "$minor" | "$patch") ;;
		"$latest")
			note "harness/VERSION is $VERSION, which is the latest tag itself — this PR ships changes under a number that is already released. Pick one of $major (MAJOR), $minor (MINOR) or $patch (PATCH)."
			;;
		*)
			note "harness/VERSION is $VERSION, which is not one bump above the latest tag amh-v$latest — expected $major (MAJOR), $minor (MINOR) or $patch (PATCH). If the previous release merged but was never tagged, the stale tag is what this is comparing against: tag it and re-run. Versions are decided at PR time against the latest tag (DC-023)."
			;;
		esac
	fi
fi

[ "$fails" -eq 0 ] || exit 1
if [ "${1:-}" = "--against-latest-tag" ]; then
	printf 'version %s consistent across 5 hand-maintained copies, and one bump above the latest tag amh-v%s\n' "$VERSION" "$latest"
else
	printf 'version %s consistent across 5 hand-maintained copies\n' "$VERSION"
fi
