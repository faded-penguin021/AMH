#!/usr/bin/env bash
# D-024: the bearer fixture must satisfy the production token predicate by construction.

set -uo pipefail

SOURCE=harness/templates/scripts/redact.sh
needle='st_redacted bearer_header'
# shellcheck disable=SC2016  # command substitutions are the literal source shape.
construction='$(rand_upper 8)$(rand_alnum 32)'
# shellcheck disable=SC2016  # command substitution is the literal canonical source line.
expected=$(printf '\tst_redacted bearer_header "$(printf '\''%%s: %%s %%s'\'' Authorization Bearer "%s")"' \
	"$construction")

if [ ! -f "$SOURCE" ]; then
	printf 'bearer-fixture-construction: checked NOTHING: %s is missing; D-024\047s fixture satisfied the production predicate only probabilistically\n' "$SOURCE" >&2
	exit 1
fi

matches=$(grep -cF "$needle" "$SOURCE")
if [ "$matches" -eq 0 ]; then
	printf 'bearer-fixture-construction: checked NOTHING: no %s fixture exists; D-024\047s fixture satisfied the production predicate only probabilistically\n' "$needle" >&2
	exit 1
fi
if [ "$matches" -ne 1 ]; then
	printf 'bearer-fixture-construction: expected exactly one %s fixture, found %s; D-024\047s fixture satisfied the production predicate only probabilistically\n' "$needle" "$matches" >&2
	exit 1
fi

line=$(grep -F "$needle" "$SOURCE")
if [ "$line" != "$expected" ]; then
	printf 'bearer-fixture-construction: bearer token must preserve the required prefix-before-tail construction %s; D-024\047s fixture satisfied the production predicate only probabilistically\n' \
		"$construction" >&2
	exit 1
fi
