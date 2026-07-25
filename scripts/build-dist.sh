#!/usr/bin/env bash
# Assemble harness/dist/AMH.md — the single-file, pasteable form of the harness — from
# the ordered parts in harness/src/ plus the real template files.
#
# Why generate rather than hand-maintain: the templates must exist as real, copyable
# files (an adopter should not have to extract a scaffold from prose), AND the harness
# must survive as one document you can hand to any agent. Keeping both by hand
# guarantees they drift; generating one from the other makes drift impossible and
# checkable — scripts/guards/dist-drift.sh rebuilds and diffs on every ladder run.
#
#   scripts/build-dist.sh            write harness/dist/AMH.md
#   scripts/build-dist.sh --stdout   write to stdout (used by the drift guard)
#
# Directives understood inside harness/src/*.md:
#   <!-- amh:include <path> -->   inline that file inside a fenced block
#   @AMH_VERSION@                 replaced with the contents of harness/VERSION

set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." || exit 1

SRC=harness/src
OUT=harness/dist/AMH.md
VERSION=$(cat harness/VERSION)

emit() {
	printf '<!-- GENERATED FILE — DO NOT EDIT.\n'
	printf '     Built by scripts/build-dist.sh from harness/src/ and harness/templates/.\n'
	printf '     Edit those, then rebuild. A ladder guard rebuilds and diffs this file. -->\n\n'

	local part line path
	for part in "$SRC"/*.md; do
		while IFS= read -r line; do
			case $line in
			'<!-- amh:include '*' -->')
				path=${line#'<!-- amh:include '}
				path=${path%' -->'}
				if [ ! -f "$path" ]; then
					printf 'build-dist: missing include %s\n' "$path" >&2
					exit 1
				fi
				# Six backticks so the included file's own fences nest cleanly.
				printf '``````\n'
				cat "$path"
				printf '``````\n'
				;;
			*) printf '%s\n' "${line//@AMH_VERSION@/$VERSION}" ;;
			esac
		done <"$part"
		printf '\n'
	done
}

if [ "${1:-}" = "--stdout" ]; then
	emit
else
	mkdir -p "$(dirname "$OUT")"
	emit >"$OUT"
	printf 'wrote %s (%s lines)\n' "$OUT" "$(wc -l <"$OUT" | tr -d ' ')"
fi
