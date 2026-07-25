#!/usr/bin/env bash
# AMH — instructive pre-execution command guard (P13).
#
# Checks a shell command against the harness's hard rails BEFORE it runs and blocks
# with a reason that names the rule and the correct alternative, so the agent
# self-corrects in one step instead of fighting a mute prefix-matched denial.
#
# This is the TOP layer of three. Beneath it: the agent's static permission deny
# rules, and (server-side) branch protection + secret-scanning push protection. Those
# layers bind actors that never load this script.
#
# Design rules this guard is bound by — each one paid for in false positives:
#   * Judge only the LEADING command of each simple-command segment, with quoting
#     respected. Text that merely CONTAINS a forbidden command — a commit message, a
#     doc heredoc, this script's own CLI — must never trip it.
#   * Target agent MISTAKES, not evasion. Quoting and prefix tricks are accepted
#     misses; the layers beneath catch those.
#   * Fail OPEN on malformed input. A guard that bricks every command gets disabled,
#     not fixed.
#
# Usage:
#   command-guard.sh                  read a hook payload (JSON) on stdin
#   command-guard.sh --command 'CMD'  check one command directly
#   command-guard.sh --self-test      blocked + allowed fixture matrix
#
# Exit codes: 0 = allowed (or fail-open), 2 = blocked (reason on stderr).
#
# Shipped by the Agentic Maintenance Harness. Repo-agnostic: do not edit locally.

set -uo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

DEFAULT_BRANCH=main
BRANCH_PREFIX=session
# shellcheck source=/dev/null
[ -f "$ROOT/amh.conf" ] && . "$ROOT/amh.conf"

# --- segment splitting ------------------------------------------------------
# Emit one line per simple-command segment, splitting on UNQUOTED shell operators.
# Quoted regions stay inside their segment and are therefore never a leading command.
split_segments() {
	local s=$1
	local i=0 n=${#s} c q='' seg=''
	local out=()
	while [ "$i" -lt "$n" ]; do
		c=${s:i:1}
		if [ -n "$q" ]; then
			seg+=$c
			[ "$c" = "$q" ] && q=''
			i=$((i + 1))
			continue
		fi
		case $c in
		"'" | '"')
			q=$c
			seg+=$c
			;;
		'\')
			seg+=$c
			i=$((i + 1))
			[ "$i" -lt "$n" ] && seg+=${s:i:1}
			;;
		';' | '&' | '|' | $'\n' | '(' | ')' | '{' | '}' | '`')
			out+=("$seg")
			seg=''
			;;
		'$')
			if [ "${s:i+1:1}" = '(' ]; then
				out+=("$seg")
				seg=''
				i=$((i + 1))
			else
				seg+=$c
			fi
			;;
		*) seg+=$c ;;
		esac
		i=$((i + 1))
	done
	out+=("$seg")
	printf '%s\n' "${out[@]}"
}

# --- rails ------------------------------------------------------------------
BLOCK_REASON=''

is_env_template() { # .env.example and friends carry no secrets
	case $1 in
	*.env.example | *.env.sample | *.env.template | *.env.dist) return 0 ;;
	*) return 1 ;;
	esac
}

names_env_file() {
	case $1 in
	.env | .env.* | */.env | */.env.*) is_env_template "$1" && return 1 || return 0 ;;
	*) return 1 ;;
	esac
}

check_segment() {
	# shellcheck disable=SC2206  # deliberate word-splitting: we inspect argv shape
	local words=($1)
	local i=0 w

	# Strip leading variable assignments and transparent prefixes so that
	# `env FOO=1 git push --force` is judged as a git command, not an env dump.
	while [ "$i" -lt "${#words[@]}" ]; do
		w=${words[$i]}
		case $w in
		*=*) i=$((i + 1)) ;;
		sudo | nohup | nice | time | command | builtin | exec) i=$((i + 1)) ;;
		env)
			# `env` with an assignment or a command after it is a prefix, not a dump.
			if [ $((i + 1)) -lt "${#words[@]}" ]; then
				case ${words[$((i + 1))]} in
				-*)
					BLOCK_REASON="\`env\` dumps the session environment, which carries credentials (AMH P17). Report key PRESENCE only, e.g. \`[ -n \"\${MY_KEY:-}\" ] && echo set\`."
					return 1
					;;
				*) i=$((i + 1)) ;;
				esac
			else
				BLOCK_REASON="\`env\` dumps the session environment, which carries credentials (AMH P17). Report key PRESENCE only, e.g. \`[ -n \"\${MY_KEY:-}\" ] && echo set\`."
				return 1
			fi
			;;
		*) break ;;
		esac
	done
	[ "$i" -lt "${#words[@]}" ] || return 0

	local cmd=${words[$i]}
	cmd=${cmd##*/}
	local args=("${words[@]:$((i + 1))}")

	case $cmd in
	printenv)
		BLOCK_REASON="\`printenv\` prints credential values (AMH P17). Report key PRESENCE only — never a value, prefix, suffix, length or hash."
		return 1
		;;
	git)
		# `push` must be the SUBCOMMAND, not any word anywhere in the line — otherwise
		# `git commit -m "never git push --force"` trips the rail on its own message.
		local j=0 a
		while [ "$j" -lt "${#args[@]}" ]; do
			case ${args[$j]} in
			-C | -c | --exec-path) j=$((j + 2)) ;;
			-*) j=$((j + 1)) ;;
			*) break ;;
			esac
		done
		[ "$j" -lt "${#args[@]}" ] && [ "${args[$j]}" = push ] || return 0
		for a in "${args[@]:$((j + 1))}"; do
			case $a in
			--force | -f | --force-with-lease | --force-with-lease=* | --force-if-includes)
				BLOCK_REASON="Force-push is denied (AMH P7): pushed checkpoints are immutable. If the branch diverged, merge the default branch in — never rewrite pushed history. A history rewrite is owner-executed and only for a leaked-credential incident."
				return 1
				;;
			-*) ;;
			"$DEFAULT_BRANCH" | "refs/heads/$DEFAULT_BRANCH" | *:"$DEFAULT_BRANCH" | *:"refs/heads/$DEFAULT_BRANCH")
				BLOCK_REASON="Pushing to \`$DEFAULT_BRANCH\` is denied (AMH P13). Push your session branch instead: \`git push -u origin $BRANCH_PREFIX/<codename>\`. The owner merges via squash PR."
				return 1
				;;
			esac
		done
		;;
	cat | less | more | head | tail | bat | xxd | od | strings | nl)
		local a
		for a in "${args[@]:-}"; do
			case $a in -*) continue ;; esac
			a=${a%\"}
			a=${a#\"}
			a=${a%\'}
			a=${a#\'}
			if names_env_file "$a"; then
				BLOCK_REASON="Reading \`$a\` exposes credential values (AMH P17). Check key presence instead, or ask the owner for a narrower evidence contract via the Owner queue."
				return 1
			fi
		done
		;;
	esac
	return 0
}

check_command() {
	local cmd=$1 seg
	BLOCK_REASON=''
	while IFS= read -r seg; do
		[ -n "${seg// /}" ] || continue
		check_segment "$seg" || return 1
	done < <(split_segments "$cmd")
	return 0
}

# --- hook payload -----------------------------------------------------------
extract_command() { # fail-open: print nothing if the payload is not what we expect
	local payload=$1
	if command -v python3 >/dev/null 2>&1; then
		printf '%s' "$payload" | python3 -c 'import json,sys
try:
    d = json.load(sys.stdin)
    print(d.get("tool_input", {}).get("command", ""))
except Exception:
    pass' 2>/dev/null
	else
		printf '%s' "$payload" | sed -n 's/.*"command"[[:space:]]*:[[:space:]]*"\(.*\)".*/\1/p' | head -1
	fi
}

run_hook() {
	local payload cmd
	payload=$(cat) || exit 0
	cmd=$(extract_command "$payload")
	[ -n "$cmd" ] || exit 0 # malformed or non-Bash tool: fail open
	if ! check_command "$cmd"; then
		printf 'BLOCKED by the AMH command guard.\n\n%s\n' "$BLOCK_REASON" >&2
		exit 2
	fi
	exit 0
}

# --- self-test --------------------------------------------------------------
ST_FAILS=0
st_blocked() {
	if check_command "$1"; then
		printf 'SELF-TEST FAIL: should have been BLOCKED: %s\n' "$1" >&2
		ST_FAILS=$((ST_FAILS + 1))
	fi
}
st_allowed() {
	if ! check_command "$1"; then
		printf 'SELF-TEST FAIL: should have been ALLOWED: %s\n   reason given: %s\n' "$1" "$BLOCK_REASON" >&2
		ST_FAILS=$((ST_FAILS + 1))
	fi
}

self_test() {
	# --- must block: the rails themselves
	st_blocked 'git push --force origin feature'
	st_blocked 'git push -f origin feature'
	st_blocked 'git push --force-with-lease'
	st_blocked "git push origin $DEFAULT_BRANCH"
	st_blocked "git push origin HEAD:$DEFAULT_BRANCH"
	st_blocked "git push origin refs/heads/$DEFAULT_BRANCH"
	st_blocked 'env'
	st_blocked 'env -0'
	st_blocked 'printenv'
	st_blocked 'printenv AWS_SECRET_ACCESS_KEY'
	st_blocked 'cat .env'
	st_blocked 'cat config/.env.production'
	st_blocked 'ls -la && git push --force origin x'
	st_blocked 'make build; printenv'
	st_blocked 'echo hi | cat .env'
	st_blocked 'RESULT=$(git push --force origin x)'
	st_blocked 'git -C /some/repo push --force origin x'
	st_blocked 'cat ".env"'
	st_blocked 'sudo printenv'

	# --- must allow: the known false-positive classes.
	# Quoted text naming a forbidden command is DATA, not a command.
	st_allowed 'git commit -m "never git push --force on this repo"'
	st_allowed "git commit -m 'document why printenv is denied'"
	st_allowed 'echo "cat .env is forbidden by P17"'
	st_allowed 'grep -rn "printenv" docs/'
	st_allowed 'scripts/command-guard.sh --self-test'
	# Prose naming a forbidden path.
	st_allowed 'grep -rn "force-push" docs/RUNBOOK.md'
	# Ordinary correct usage.
	st_allowed "git push -u origin $BRANCH_PREFIX/some-codename"
	st_allowed "git push -u origin $BRANCH_PREFIX/x && echo pushed"
	st_allowed 'env FOO=1 make test'
	st_allowed 'FOO=1 make test'
	st_allowed 'cat .env.example'
	st_allowed 'cat README.md'
	# A branch whose name merely CONTAINS the default branch name.
	st_allowed "git push -u origin ${DEFAULT_BRANCH}tenance"
	st_allowed "git push -u origin $BRANCH_PREFIX/$DEFAULT_BRANCH-cleanup"
	# Fail-open on an empty or odd command.
	st_allowed ''
	st_allowed '   '

	if [ "$ST_FAILS" -ne 0 ]; then
		printf 'command-guard.sh self-test: %d failure(s)\n' "$ST_FAILS" >&2
		return 1
	fi
	printf 'command-guard.sh self-test: ok\n'
}

case "${1:-}" in
"") run_hook ;;
--command)
	if check_command "${2:-}"; then exit 0; fi
	printf 'BLOCKED by the AMH command guard.\n\n%s\n' "$BLOCK_REASON" >&2
	exit 2
	;;
--self-test) self_test ;;
*)
	printf 'usage: %s [--command CMD|--self-test]\n' "$0" >&2
	exit 2
	;;
esac
