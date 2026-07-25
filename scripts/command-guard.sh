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

# Remove here-document BODIES before segmenting. A heredoc body is data — a
# commit message, a doc block, a file being written — and it routinely quotes
# the very commands this guard blocks. Backticks split segments (command
# substitution), so prose like "the guard blocks `env`" becomes a segment whose
# leading word is `env`, and the rail fires on a commit message describing
# itself. Found in live use, writing the commit that shipped this guard.
#
# Accepted miss, deliberately: `cmd <<EOF` hides everything until the
# terminator, so a real dump command placed inside a heredoc body is not
# judged. That is the fail-open direction, and heredoc-as-evasion is not the
# agent mistake this guard targets.
strip_heredocs() {
	local s=$1
	local out='' line trimmed delim='' body=1
	while IFS= read -r line; do
		if [ "$body" -eq 0 ]; then
			trimmed=${line#"${line%%[![:space:]]*}"} # <<- strips leading tabs
			[ "$trimmed" = "$delim" ] && body=1
			continue
		fi
		out+=$line$'\n'
		case $line in
		*'<<'*)
			delim=${line#*<<}
			delim=${delim#-}
			delim=${delim%%[[:space:];|&)]*}
			delim=${delim#[\'\"]}
			delim=${delim%[\'\"]}
			[ -n "$delim" ] && body=0
			;;
		esac
	done <<<"$s"
	printf '%s' "$out"
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
	# The kernel's copy of a live process's environment — the same dump `env` makes,
	# reachable with a file reader instead of a command.
	/proc/*/environ) return 0 ;;
	*) return 1 ;;
	esac
}

# True if a variable NAME is credential-shaped. Matched on the LAST underscore-
# delimited component, never as a substring: `$AWS_SECRET_ACCESS_KEY` is a secret,
# `$SSH_KEY_PATH` is a path, `$AWS_ACCESS_KEY_ID` is an identifier and `$MONKEY` is
# a monkey. Substring matching blocks all four, and a rail that blocks
# `echo "$SSH_KEY_PATH"` gets disabled, not fixed. Accepted miss: `$TOKEN_B64`.
is_secret_name() {
	case ${1##*_} in
	[Kk][Ee][Yy] | [Tt][Oo][Kk][Ee][Nn] | [Ss][Ee][Cc][Rr][Ee][Tt]) return 0 ;;
	[Pp][Aa][Ss][Ss][Ww][Oo][Rr][Dd] | [Pp][Aa][Ss][Ss][Ww][Dd]) return 0 ;;
	[Cc][Rr][Ee][Dd][Ee][Nn][Tt][Ii][Aa][Ll][Ss] | [Cc][Rr][Ee][Dd][Ee][Nn][Tt][Ii][Aa][Ll]) return 0 ;;
	esac
	return 1
}

# True if a raw argument would EXPAND a credential-shaped variable into output.
# Quoting decides: `echo "$GITHUB_TOKEN"` leaks, `echo 'set $GITHUB_TOKEN first'`
# and `echo "run with \$GITHUB_TOKEN"` expand nothing and are ADVICE — the shape an
# agent writes when a credential is missing. Quoted text is DATA, never a command;
# the remediation instead of the leak is the false positive that kills a rail.
expands_secret_var() {
	local s=$1 # split: `local s=$1 n=${#s}` expands ${#s} BEFORE s exists (set -u)
	local i=0 n=${#s} c q='' rest name
	while [ "$i" -lt "$n" ]; do
		c=${s:i:1}
		case $c in
		'\')
			# Outside single quotes a backslash escapes the next character.
			if [ "$q" != "'" ]; then
				i=$((i + 2))
				continue
			fi
			;;
		"'") [ "$q" = "'" ] && q='' || { [ -z "$q" ] && q="'"; } ;;
		'"') [ "$q" = '"' ] && q='' || { [ -z "$q" ] && q='"'; } ;;
		'$')
			if [ "$q" != "'" ]; then
				rest=${s:i+1}
				rest=${rest#\{}
				name=${rest%%[!A-Za-z0-9_]*}
				[ -n "$name" ] && is_secret_name "$name" && return 0
			fi
			;;
		esac
		i=$((i + 1))
	done
	return 1
}

# True if a shell builtin is being used in its DUMP-EVERYTHING form. `set -euo
# pipefail`, `export FOO=1` and `declare -a xs` are ordinary usage and must pass;
# bare `set`, `export -p` and `declare -x` print every variable's value.
is_env_dump_builtin() {
	local cmd=$1
	shift
	local a
	case $cmd in
	set)
		[ "$#" -eq 0 ] && return 0
		return 1
		;;
	export | typeset | declare)
		[ "$#" -eq 0 ] && return 0
		local dump_flag=1 operand=1
		for a in "$@"; do
			case $a in
			*=*) return 1 ;;         # an assignment, not a dump
			-*p* | -*x*) dump_flag=0 ;;
			-*) ;;
			*) operand=0 ;; # names a variable: prints that one, not the environment
			esac
		done
		[ "$dump_flag" -eq 0 ] && [ "$operand" -ne 0 ] && return 0
		return 1
		;;
	esac
	return 1
}

check_segment() {
	local raw=$1
	# shellcheck disable=SC2206  # deliberate word-splitting: we inspect argv shape
	local words=($1)
	local i=0 w

	# A redirection reaches the same file a reader command would, from ANY command:
	# `tr "\0" "\n" < /proc/self/environ` names no reader at all.
	local k=0 target
	while [ "$k" -lt "${#words[@]}" ]; do
		case ${words[$k]} in
		'<') target=${words[$((k + 1))]:-} ;;
		'<'*) target=${words[$k]#<} ;;
		*)
			k=$((k + 1))
			continue
			;;
		esac
		k=$((k + 1))
		target=${target%\"}
		target=${target#\"}
		target=${target%\'}
		target=${target#\'}
		if [ -n "$target" ] && names_env_file "$target"; then
			BLOCK_REASON="Redirecting from \`$target\` feeds credential values into the command (AMH P17). Check key presence instead, or ask the owner for a narrower evidence contract via the Owner queue."
			return 1
		fi
	done

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
	set | export | declare | typeset)
		# A shell builtin can dump the whole environment without going near `env`.
		if is_env_dump_builtin "$cmd" ${args[@]+"${args[@]}"}; then
			BLOCK_REASON="\`$cmd\` in this form prints every variable's VALUE, which dumps the session's credentials (AMH P17). Report key PRESENCE only, e.g. \`[ -n \"\${MY_KEY:-}\" ] && echo set\`."
			return 1
		fi
		# `declare -p NAME` PRINTS that variable's value. `export NAME` does not —
		# it sets an attribute and prints nothing, so blocking it would be both a
		# false positive and a block reason asserting behaviour the command lacks.
		case $cmd in declare | typeset) ;; *) return 0 ;; esac
		local a prints=1
		for a in ${args[@]+"${args[@]}"}; do
			case $a in -*p*) prints=0 ;; esac
		done
		[ "$prints" -eq 0 ] || return 0
		for a in ${args[@]+"${args[@]}"}; do
			case $a in -* | *=*) continue ;; esac
			if is_secret_name "$a"; then
				BLOCK_REASON="\`$cmd $a\` prints that credential's value (AMH P17). Never a value, prefix, suffix, length or hash — report presence only."
				return 1
			fi
		done
		;;
	echo | printf | print)
		# The commonest leak shape by far: an agent echoing a credential to see it.
		# Scan the RAW argument text, not the split words: word-splitting destroys the
		# quoting context, and quoting is the entire difference between printing a
		# credential and printing advice about one.
		if expands_secret_var "${raw#*"$cmd"}"; then
			BLOCK_REASON="That command expands a credential-shaped variable into output (AMH P17) — never print a value, prefix, suffix, length or hash. Report presence only: \`[ -n \"\${MY_KEY:-}\" ] && echo set\`. If a diagnostic seems to need the value, that is an Owner-queue question, not raw output."
			return 1
		fi
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
	cat | less | more | head | tail | bat | xxd | od | strings | nl | \
		grep | egrep | fgrep | rg | awk | sed | cut | tr | cp | dd | base64 | tee | sort | uniq)
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
	local cmd=$1
	local seg
	BLOCK_REASON=''
	cmd=$(strip_heredocs "$cmd")
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
	# Whole-environment dumps that never mention `env`.
	st_blocked 'set'
	st_blocked 'export -p'
	st_blocked 'declare -x'
	st_blocked 'typeset -x'
	st_blocked 'declare -p'
	st_blocked 'cat /proc/self/environ'
	st_blocked 'strings /proc/1/environ'
	# Printing one credential's value.
	st_blocked 'echo $GITHUB_TOKEN'
	st_blocked 'echo "$AWS_SECRET_ACCESS_KEY"'
	st_blocked 'echo "${OPENAI_API_KEY}"'
	st_blocked 'printf "%s\n" "$MY_PASSWORD"'
	st_blocked 'echo "token is $npm_token"'
	st_blocked 'echo "${DEPLOY_PRIVATE_KEY:0:4}"'
	st_blocked 'declare -p GITHUB_TOKEN'
	# The same file through readers other than `cat`, and through a redirection.
	st_blocked 'grep -a . /proc/self/environ'
	st_blocked 'awk 1 /proc/self/environ'
	st_blocked 'cp /proc/self/environ /tmp/e'
	st_blocked 'tr "\0" "\n" < /proc/self/environ'
	st_blocked 'grep DATABASE_URL .env'
	st_blocked 'while read -r l; do echo "$l"; done < .env'

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
	# Ordinary shell usage the dump rail must not swallow.
	st_allowed 'set -euo pipefail'
	st_allowed 'set -x'
	st_allowed 'export PATH=/usr/local/bin:$PATH'
	st_allowed 'export AMH_REMOTE=1'
	st_allowed 'declare -a items'
	st_allowed 'declare -x MY_FLAG=1'
	st_allowed 'export -f my_function'
	# The presence check the guard itself recommends, and non-secret expansions.
	st_allowed '[ -n "${MY_KEY:-}" ] && echo set'
	st_allowed 'echo "$HOME"'
	st_allowed 'echo "$AUTHOR wrote it"'
	st_allowed 'echo "$API_URL"'
	st_allowed 'printf "%s\n" "$BRANCH"'
	# A heredoc body is DATA. This is the shape that blocked the very commit
	# shipping this rail: backticks split segments, so `env` in prose became a
	# leading command. Both the quoted and unquoted delimiter forms.
	st_allowed "$(printf '%s\n' "git commit -F - <<'EOF'" 'The guard blocks `env`, `printenv` and `.env` reads.' 'EOF')"
	st_allowed "$(printf '%s\n' 'cat <<EOF >notes.md' 'Run `printenv` to see why this is denied.' 'EOF')"
	st_allowed "$(printf '%s\n' "cat <<-'EOF'" $'\tset' $'\tenv' $'\tEOF')"
	# ...but a real command AFTER the terminator is still judged.
	st_blocked "$(printf '%s\n' "git commit -F - <<'EOF'" 'prose about `env`' 'EOF' 'printenv')"
	# Prose naming the shapes, and the guard's own fixtures.
	st_allowed 'grep -rn "GITHUB_TOKEN" docs/'
	st_allowed 'git commit -m "block echo $GITHUB_TOKEN at the rail"'
	# Load-bearing against the false-positive classes this rail can produce.
	# Unexpanded text: advice about a credential is not a credential.
	st_allowed "echo 'Set \$GITHUB_TOKEN in your environment before running gh'"
	st_allowed "printf 'export \$NPM_TOKEN first\n'"
	st_allowed 'echo "remember to set \$GITHUB_TOKEN"'
	# Names that merely CONTAIN a secret word: a path, an identifier, a monkey.
	st_allowed 'echo "$SSH_KEY_PATH"'
	st_allowed 'echo "$AWS_ACCESS_KEY_ID"'
	st_allowed 'echo "$GPG_KEY_ID"'
	st_allowed 'echo "$KEYCLOAK_URL"'
	st_allowed 'echo "$PRIVATE_REPO_URL"'
	st_allowed 'printf "using keyring %s\n" "$KEYRING_BACKEND"'
	st_allowed 'echo "$MONKEY"'
	# Builtins that set an attribute and print nothing.
	st_allowed 'export GITHUB_TOKEN'
	st_allowed 'export NPM_TOKEN OPENAI_API_KEY'
	st_allowed 'declare -p my_array'
	# Readers pointed at ordinary files, and a redirection from one.
	st_allowed 'grep -rn "force-push" docs/RUNBOOK.md'
	st_allowed 'awk 1 README.md'
	st_allowed 'tr "a" "b" < README.md'
	st_allowed 'sort docs/LEDGER.md'
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
