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
files=$(git ls-files -co --exclude-standard '*.md' |
	grep -v -e '^harness/dist/' -e '^harness/templates/' -e '^harness/src/' || true)

for f in $files; do
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
	while IFS= read -r target; do
		[ -n "$target" ] || continue
		case $target in
		*'*'* | *'{{'* | *'$'* | *'<'* | /* | http*) continue ;;
		esac
		checked=$((checked + 1))
		if [ ! -e "$target" ]; then
			printf 'nonexistent path cited in %s: `%s`\n' "$f" "$target"
			fails=$((fails + 1))
		fi
	done < <(grep -oE '`[A-Za-z0-9_./-]+/[A-Za-z0-9_./-]+\.(md|sh|json|yml|yaml|conf)`' "$f" |
		tr -d '`' | sort -u)
done

[ "$fails" -eq 0 ] || exit 1
printf '%s path reference(s) resolve\n' "$checked"
