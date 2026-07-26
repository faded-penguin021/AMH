#!/usr/bin/env bash
# Repo-local guard: placeholders are documented, and none survive in live files.
#
# Two failure modes, both real for a repo that ships templates:
#   1. A template gains a {{PLACEHOLDER}} nobody documents, so an adopter ships it
#      unfilled — the template's own instructions are the only place they would have
#      learned it existed.
#   2. This repo copies a template into its own live tree and leaves a placeholder in
#      it, which means the reference instance is not actually instantiated.
#
# Checks CODE against a documented set — it never parses prose to decide what is true.

set -uo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." || exit 1

DOC=harness/PLACEHOLDERS.md
TEMPLATES=harness/templates
fails=0

if [ ! -f "$DOC" ]; then
	printf '%s is missing — placeholders would be undocumented by construction\n' "$DOC"
	exit 1
fi

documented=$(mktemp)
used=$(mktemp)
trap 'rm -f "$documented" "$used"' EXIT

# Documented names: the leading `| \`NAME\` |` cell of each table row. Slash-separated
# cells (`QUESTION` / `DOC_PATH`) count as several names.
sed -n 's/^| *`\([^`]*\)`\( *\/ *`\([^`]*\)`\)* *|.*/\1 \3/p' "$DOC" | tr ' ' '\n' | grep -v '^$' | sort -u >"$documented"

grep -rhoE '\{\{[A-Z_][A-Z0-9_]*\}\}' "$TEMPLATES" 2>/dev/null |
	sed 's/[{}]//g' | sort -u >"$used"

undocumented=$(comm -23 "$used" "$documented")
if [ -n "$undocumented" ]; then
	printf 'used in %s but not documented in %s: %s\n' \
		"$TEMPLATES" "$DOC" "$(printf '%s' "$undocumented" | tr '\n' ' ')"
	fails=$((fails + 1))
fi

# Live files: this repo's OWN instance — the files that had to be instantiated. Everything
# under harness/ is the distributed product: templates carry placeholders by definition, the
# prose explains the convention, and the generated bundle inlines the templates verbatim.
# `PLACEHOLDER` and `X` are the generic words prose uses for a slot in general ("these
# carry {{PLACEHOLDER}}s", "every {{X}} is documented"), never an unfilled slot. Exempting
# the two metasyntactic names keeps this guard pointed at whole DIRECTORIES it cannot see
# into; excluding a directory to let one document through would be a standing hole for
# every file later put there.
live=$(git ls-files -co --exclude-standard |
	grep -v -e '^harness/' -e '^scripts/guards/placeholder-integrity.sh$' || true)
if [ -n "$live" ]; then
	leftover=$(printf '%s\n' "$live" | tr '\n' '\0' |
		xargs -0 grep -lE '\{\{[A-Z_][A-Z0-9_]*\}\}' 2>/dev/null |
		while IFS= read -r f; do
			if grep -ohE '\{\{[A-Z_][A-Z0-9_]*\}\}' "$f" | grep -qvE '^\{\{(PLACEHOLDER|X)\}\}$'; then
				printf '%s\n' "$f"
			fi
		done)
	if [ -n "$leftover" ]; then
		printf 'unfilled placeholder(s) in live files: %s\n' "$(printf '%s' "$leftover" | tr '\n' ' ')"
		fails=$((fails + 1))
	fi
fi

[ "$fails" -eq 0 ] || exit 1
printf '%s placeholder(s) documented, none left unfilled\n' "$(wc -l <"$used" | tr -d ' ')"
