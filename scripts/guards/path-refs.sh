#!/usr/bin/env bash
# Repo-local guard: repo-relative paths named in prose actually exist.
#
# Admitted under AMH P20's incident bar, which requires a claim to have DRIFTED before
# it earns a guard. It has, three times, in one review: docs cited scripts/amh-init.sh,
# CONTRIBUTING.md and a version-lockstep guard that did not exist, and playbook 5 was
# unfollowable because of it. That also overturns the "no markdown link checker"
# decided non-item, which rested on "no broken link has cost anything yet".
#
# Deliberately narrow. It checks CODE — whether a path exists — never prose meaning,
# and it never touches the network. It is a tripwire for the drift class that already
# bit us, not a documentation test framework.

set -uo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." || exit 1

fails=0
checked=0

# harness/dist is generated (dist-drift owns it); harness/templates and harness/src
# describe an ADOPTER's tree, where the paths are meant to resolve there, not here.
#
# NUL-separated: `for f in $files` word-splits the list, so a file whose name contains
# a space is skipped in silence and the guard still prints a count and a green line.
# scripts/ladder.sh forbids exactly this in the secret scan ("a scan with a silent hole
# is worse than no scan"), and the harness prose calls it a blocker-class hole.
while IFS= read -r -d '' f; do
	# docs/plans/ describes an INTENDED tree the same way harness/templates describes an
	# adopter's: a plan that may not name a file it has not built yet is the normal case,
	# not drift. What a plan actually delivered is settled by the ladder against the real
	# tree, never by this guard.
	case $f in
	harness/dist/* | harness/templates/* | harness/src/* | docs/plans/*) continue ;;
	esac
	dir=$(dirname "$f")

	# (a) Markdown links with a relative target: [text](path). Skip URLs, anchors and
	#     mailto. Strip any #fragment. Resolved relative to the linking file.
	while IFS= read -r target; do
		[ -n "$target" ] || continue
		case $target in
		http*://* | '#'* | mailto:* | /*) continue ;;
		*'{{'* | *'<'* | *'*'*) continue ;;
		esac
		target=${target%%#*}
		[ -n "$target" ] || continue
		checked=$((checked + 1))
		if [ ! -e "$dir/$target" ]; then
			printf 'broken link in %s: [..](%s)\n' "$f" "$target"
			fails=$((fails + 1))
		fi
	done < <(grep -oE '\]\([^)]+\)' "$f" | sed 's/^](//; s/)$//')

	# (b) Backticked paths that look like real repo paths: contain a slash, end in a
	#     known extension, and carry no glob, placeholder or shell expansion. Resolved
	#     from the repo root, which is how prose here names files.
	#
	# The extraction is hoisted out of the loop so its SC2016 waiver covers ONE command.
	# A directive cannot sit before `done < <(...)` (SC1123), and putting it on the whole
	# `while` silenced SC2016 for the entire body — a waiver that wide stops being a
	# waiver and becomes a blind spot.
	# shellcheck disable=SC2016 # backticks are the pattern's own syntax: this matches
	# markdown code spans literally, so single quotes are required, not a slip.
	backticked=$(grep -oE '`[A-Za-z0-9_./-]+/[A-Za-z0-9_./-]+\.(md|sh|json|yml|yaml|conf)`' "$f" | tr -d '`' | sort -u)
	while IFS= read -r target; do
		[ -n "$target" ] || continue
		case $target in
		*'*'* | *'{{'* | *'$'* | *'<'* | /* | http*) continue ;;
		esac
		checked=$((checked + 1))
		if [ ! -e "$target" ]; then
			# shellcheck disable=SC2016 # literal backticks: the message quotes the citation
			# back in the same markdown form the prose used. No expansion wanted.
			printf 'nonexistent path cited in %s: `%s`\n' "$f" "$target"
			fails=$((fails + 1))
		fi
	done <<<"$backticked"
done < <(git ls-files -co --exclude-standard -z '*.md')

[ "$fails" -eq 0 ] || exit 1
printf '%s path reference(s) resolve\n' "$checked"
