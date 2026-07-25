#!/usr/bin/env bash
# AMH — output redaction filter (P17).
#
# stdin -> stdout. Replaces PREFIX-ANCHORED credential shapes with [REDACTED:<class>].
# Deliberately NOT generic entropy matching: entropy heuristics mangle ordinary build
# output, and output an agent cannot read gets the filter disabled rather than fixed.
#
# This is one of three layers. The prose rule ("never print a credential's value,
# prefix, suffix, length or hash") and the permission deny rails are the other two.
# The regex layer catches KNOWN shapes only — it narrows the window, it never
# replaces the rule.
#
# Usage:
#   cmd 2>&1 | redact.sh          filter
#   redact.sh --classes           list the token classes recognised
#   redact.sh --self-test         fixture matrix (tokens are generated at runtime,
#                                 never stored — a stored literal would itself be a
#                                 secret-shaped string in the tree)
#
# Shipped by the Agentic Maintenance Harness. Repo-agnostic: do not edit locally.

set -euo pipefail

# class<TAB>extended-regex. Order matters: more specific prefixes first, because the
# substitutions are applied in sequence (sk-ant- before the generic sk- shape).
PATTERNS=$(
	cat <<-'PATS'
		aws_access_key_id	AKIA[0-9A-Z]{16}
		github_pat	github_pat_[A-Za-z0-9_]{20,}
		github_token	gh[pousr]_[A-Za-z0-9]{20,}
		slack_token	xox[abprs]-[A-Za-z0-9-]{10,}
		slack_webhook	https://hooks\.slack\.com/services/[A-Za-z0-9/_-]{20,}
		anthropic_key	sk-ant-[A-Za-z0-9_-]{20,}
		openai_key	sk-[A-Za-z0-9]{32,}
		google_api_key	AIza[0-9A-Za-z_-]{35}
		npm_token	npm_[A-Za-z0-9]{36}
		pypi_token	pypi-[A-Za-z0-9_-]{16,}
		stripe_key	[sr]k_live_[A-Za-z0-9]{16,}
		jwt	eyJ[A-Za-z0-9_-]{8,}\.[A-Za-z0-9_-]{8,}\.[A-Za-z0-9_-]{8,}
		private_key_block	-----BEGIN [A-Z ]*PRIVATE KEY-----
	PATS
)

build_sed_script() {
	local class regex
	while IFS=$'\t' read -r class regex; do
		[ -n "$class" ] || continue
		printf 's|%s|[REDACTED:%s]|g\n' "$regex" "$class"
	done <<<"$PATTERNS"
}

filter() { sed -E -f <(build_sed_script); }

list_classes() {
	local class regex
	while IFS=$'\t' read -r class regex; do
		[ -n "$class" ] || continue
		printf '%s\n' "$class"
	done <<<"$PATTERNS"
}

# --- self-test --------------------------------------------------------------

rand_alnum() { LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c "$1"; }
rand_upper() { LC_ALL=C tr -dc 'A-Z0-9' </dev/urandom | head -c "$1"; }

ST_FAILS=0
st_redacted() { # <class> <token>  — token must be replaced, and must not survive
	local class=$1 token=$2 out
	out=$(printf 'log line: %s trailing\n' "$token" | filter)
	if [[ "$out" != *"[REDACTED:$class]"* ]]; then
		printf 'SELF-TEST FAIL: %s was not redacted\n' "$class" >&2
		ST_FAILS=$((ST_FAILS + 1))
	elif [[ "$out" == *"$token"* ]]; then
		printf 'SELF-TEST FAIL: %s survived redaction\n' "$class" >&2
		ST_FAILS=$((ST_FAILS + 1))
	fi
}

st_untouched() { # <label> <text> — ordinary output must pass through byte-identical
	local label=$1 text=$2 out
	out=$(printf '%s\n' "$text" | filter)
	if [ "$out" != "$text" ]; then
		printf 'SELF-TEST FAIL: %s was mangled by the filter\n' "$label" >&2
		ST_FAILS=$((ST_FAILS + 1))
	fi
}

self_test() {
	# Positive cases. Every token is generated here and never written to disk.
	st_redacted aws_access_key_id "AKIA$(rand_upper 16)"
	st_redacted github_pat "github_pat_$(rand_alnum 30)"
	st_redacted github_token "ghp_$(rand_alnum 36)"
	st_redacted slack_token "xoxb-$(rand_alnum 24)"
	st_redacted slack_webhook "https://hooks.slack.com/services/$(rand_alnum 30)"
	st_redacted anthropic_key "sk-ant-$(rand_alnum 40)"
	st_redacted openai_key "sk-$(rand_alnum 40)"
	st_redacted google_api_key "AIza$(rand_alnum 35)"
	st_redacted npm_token "npm_$(rand_alnum 36)"
	st_redacted pypi_token "pypi-$(rand_alnum 30)"
	st_redacted stripe_key "sk_live_$(rand_alnum 24)"
	st_redacted jwt "eyJ$(rand_alnum 20).$(rand_alnum 20).$(rand_alnum 20)"
	# Assembled at runtime: a stored literal would make this file match its own filter.
	st_redacted private_key_block "$(printf -- '-----%s RSA PRIVATE KEY-----' BEGIN)"

	# Negative cases: shapes that occur constantly in real build output and MUST
	# survive untouched. A filter that eats these gets turned off.
	st_untouched git_sha "commit 8f14e45fceea167a5a36dedd4bea2543dfd9e1b2 ok"
	st_untouched uuid "id=123e4567-e89b-12d3-a456-426614174000"
	st_untouched base64_blob "hash=YWJjZGVmZ2hpamtsbW5vcHFyc3R1dnd4eXo="
	st_untouched semver "resolved react@18.3.1 in 412ms"
	st_untouched path "writing /var/lib/build/AKIA-report.txt"
	st_untouched env_presence "DATABASE_URL is set"

	# The filter must be clean under itself: its own patterns must not look like
	# tokens, or the ladder's tree scan would flag this very file forever.
	if [ -f "${BASH_SOURCE[0]}" ]; then
		if ! filter <"${BASH_SOURCE[0]}" | cmp -s - "${BASH_SOURCE[0]}"; then
			printf 'SELF-TEST FAIL: redact.sh is not clean under its own filter\n' >&2
			ST_FAILS=$((ST_FAILS + 1))
		fi
	fi

	if [ "$ST_FAILS" -ne 0 ]; then
		printf 'redact.sh self-test: %d failure(s)\n' "$ST_FAILS" >&2
		return 1
	fi
	printf 'redact.sh self-test: ok\n'
}

case "${1:-}" in
"") filter ;;
--classes) list_classes ;;
--self-test) self_test ;;
*)
	printf 'usage: %s [--classes|--self-test]\n' "$0" >&2
	exit 2
	;;
esac
