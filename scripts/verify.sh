#!/usr/bin/env bash
# Rung 3 of the ladder: this repository's full verification set.
#
# The repo's product is shell + markdown, so verification is: every script parses,
# every script lints (where shellcheck is available), and the guards' own fixture
# suite passes. Invoked by scripts/ladder.sh — never run standalone in CI, so that
# CI and the agent execute the same entrypoint.
#
# The parse check runs first. The five stages after it are independent of each other and run
# concurrently, at most AMH_JOBS at a time (default: the online core count; AMH_JOBS=1 runs them
# one after another, as does a host where no scratch directory can be made). Each stage's output
# is held and printed in the fixed order below, under its header with its elapsed seconds, so
# concurrency changes when a stage runs, never which stages run or what the log says (DD-127).

set -uo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT" || exit 1

FAILS=0
step() { printf '\n   · %s\n' "$1"; }
bad() {
	printf '     FAIL %s\n' "$1"
	FAILS=$((FAILS + 1))
}

SCRIPTS=()
while IFS= read -r script; do
	SCRIPTS+=("$script")
done < <(git ls-files -co --exclude-standard '*.sh' | sort)

step "parse check (bash -n) on ${#SCRIPTS[@]} script(s)"
# No scratch file: a host sandbox can leave /tmp read-only, and every script then read as broken
# (DD-093). bash -n's diagnostics are captured instead.
for s in "${SCRIPTS[@]}"; do
	if ! parse_err=$(bash -n "$s" 2>&1); then
		bad "$s"
		printf '%s\n' "$parse_err" | sed 's/^/       /'
	fi
done

# The stages, in the order they are printed. STAGE_LABEL is what a FAIL line names.
#
# The conformance stage is the behavioural lab's own tests. Deterministic by construction — no
# model, no network, no cost — which is the whole reason they may block here while model-backed
# runs stay permanently non-blocking. Read conformance/README.md before treating a green line
# from it as information about an agent: it says the evaluators are deterministic and
# mutation-sensitive, and nothing at all about how any agent behaves.
#
# The end-to-end stage is printed last: it is the only one that builds a whole second repo, and
# the only one that executes the adopter's path at all. Everything else tests this repo against
# itself, and the defects that path has produced were invisible to all of it (D-023).
STAGE_TITLE=(
	"shellcheck"
	"shipped guard fixture suite"
	"repo-local guard fixture suite"
	"conformance evaluator self-test"
	"instantiation end-to-end"
)
STAGE_LABEL=(
	"shellcheck"
	"scripts/test-ladder-guards.sh"
	"scripts/tests/local-guards.sh"
	"conformance/selftest.sh"
	"scripts/tests/test-init-e2e.sh"
)
STAGES=${#STAGE_TITLE[@]}
# The order the concurrent path starts them in: the three long suites first, so a small AMH_JOBS
# never leaves one of them waiting for a slot behind the two short stages.
LAUNCH_ORDER=(4 1 2 0 3)

if command -v shellcheck >/dev/null 2>&1; then
	SHELLCHECK=run
elif [ -n "${CI:-}" ]; then
	# CI installs it; a silent skip there would let lint rot land on the default branch.
	SHELLCHECK=missing-in-ci
else
	SHELLCHECK=skip
fi

# Stage <i>'s command. Always called in a process of its own, which it replaces with `exec`, so
# a background stage's process id is the command's own and a signal sent to it reaches it.
stage_exec() { # stage_exec <i>
	case $1 in
	0)
		case $SHELLCHECK in
		run) exec shellcheck -x "${SCRIPTS[@]}" ;;
		missing-in-ci) exit 1 ;;
		*)
			printf '     skip (not installed locally — CI runs it)\n'
			exit 0
			;;
		esac
		;;
	*) exec "${STAGE_LABEL[$1]}" ;;
	esac
}
stage_failed() { # stage_failed <i> <status>
	if [ "$1" -eq 0 ] && [ "$SHELLCHECK" = missing-in-ci ]; then
		bad "shellcheck is not installed in CI"
	elif [ "$1" -eq 0 ]; then
		bad "shellcheck reported findings: it exited with status $2"
	else
		bad "${STAGE_LABEL[$1]} exited with status $2"
	fi
}

# The worker count: AMH_JOBS when set, else the online core count, then `nproc`, then 1. A value
# that is not a positive integer runs the stages serially and says so on stderr. The stages get
# AMH_JOBS unchanged, not a share of it: the command guard's self-test inside them splits by the
# same variable, and a share of one per stage left the end-to-end stage serial for the minutes it
# runs alone at the end, which cost more than the early oversubscription (DD-127).
stage_jobs() {
	local want=${AMH_JOBS:-} n
	if [ -z "$want" ]; then
		n=$(getconf _NPROCESSORS_ONLN 2>/dev/null) || n=
		case $n in '' | *[!0-9]* | 0) n=$(nproc 2>/dev/null) || n= ;; esac
		case $n in '' | *[!0-9]* | 0) n=1 ;; esac
	else
		n=$want
		case $n in *[!0-9]*) n= ;; esac
		while [ -n "$n" ] && [ "${n#0}" != "$n" ]; do n=${n#0}; done
		if [ -z "$n" ]; then
			printf "verify.sh: AMH_JOBS='%s' is not a positive integer; running the stages serially\n" "$want" >&2
			n=1
		fi
	fi
	# More workers than stages run every stage at once; the length test keeps `-gt` in range.
	if [ ${#n} -gt 4 ] || [ "$n" -gt "$STAGES" ]; then
		n=$STAGES
	fi
	JOBS=$n
}

# Today's path: one stage after another, its output streamed as it runs. AMH_JOBS=1 takes it,
# and so does a host where no scratch directory can be made (DD-093).
run_serially() {
	local i=0 rc start
	while [ "$i" -lt "$STAGES" ]; do
		step "${STAGE_TITLE[i]}"
		start=$SECONDS
		(stage_exec "$i")
		rc=$?
		[ "$rc" -eq 0 ] || stage_failed "$i" "$rc"
		printf '     (%s s)\n' $((SECONDS - start))
		i=$((i + 1))
	done
}

VS_DIR=''
VS_PIDS=()
vs_cleanup() {
	[ -n "$VS_DIR" ] || return 0
	rm -f -- "$VS_DIR"/out.* "$VS_DIR"/report.*
	rmdir -- "$VS_DIR" 2>/dev/null || :
	VS_DIR=''
}
# An interrupt stops every stage still running, then removes the held output. Each runner is
# sent TERM, never INT: its TERM trap passes the signal to its stage and waits for it, while INT
# would end a runner and leave its stage running. Whether a background job and the stage it runs
# ignore INT is the shell's to decide (POSIX allows it); on bash 5.2 neither does.
vs_interrupted() { # <exit status>
	kill -TERM ${VS_PIDS[@]+"${VS_PIDS[@]}"} 2>/dev/null
	wait 2>/dev/null
	vs_cleanup
	exit "$1"
}
# One stage's runner, in the background, so in a subshell of its own: it runs the stage with
# its output held and then writes the stage's exit status to its report. A runner that dies
# before that leaves no report, which the parent reads as a stage that never reported.
stage_runner() { # stage_runner <i>
	local pid='' rc
	trap - EXIT HUP INT
	trap '[ -z "$pid" ] || { kill -TERM "$pid" 2>/dev/null; wait "$pid"; }; exit 143' TERM
	# Held in the scratch directory: if TMPDIR fills, this text can be cut short, while the exit
	# status, which alone decides pass or fail, is still the stage's own.
	stage_exec "$1" >"$VS_DIR/out.$1" 2>&1 &
	pid=$!
	wait "$pid"
	rc=$?
	printf '%s\n' "$rc" >"$VS_DIR/report.$1"
}
# Stage <i>, finished: its header with the seconds from its start to the moment its runner was
# seen gone, its held output, and its verdict.
stage_print() { # stage_print <i>
	local i=$1 rc=''
	step "${STAGE_TITLE[i]} ($((STAGE_END[i] - STAGE_START[i])) s)"
	cat -- "$VS_DIR/out.$i" 2>/dev/null
	# The file is tested first, since a failed `<` prints the shell's own error.
	if [ -f "$VS_DIR/report.$i" ]; then
		read -r rc <"$VS_DIR/report.$i" || rc=''
	fi
	case $rc in
	'' | *[!0-9]*) bad "${STAGE_LABEL[i]} never reported (its runner exited with status ${STAGE_WAIT[i]})" ;;
	0) ;;
	*) stage_failed "$i" "$rc" ;;
	esac
}
# At most JOBS runners at once, in LAUNCH_ORDER. No `wait -n` (bash 3.2): the loop polls, and a
# stage is finished once its report exists or its runner is gone. Each stage is printed as soon
# as it and every stage before it in the printed order are finished.
run_concurrently() {
	local next=0 printed=0 running=0 i k progressed
	STAGE_STATE=() STAGE_START=() STAGE_END=() STAGE_WAIT=()
	trap 'vs_interrupted 129' HUP
	trap 'vs_interrupted 130' INT
	trap 'vs_interrupted 143' TERM
	while [ "$printed" -lt "$STAGES" ]; do
		progressed=0
		while [ "$running" -lt "$JOBS" ] && [ "$next" -lt "$STAGES" ]; do
			i=${LAUNCH_ORDER[next]}
			STAGE_START[i]=$SECONDS
			stage_runner "$i" &
			VS_PIDS[i]=$!
			STAGE_STATE[i]=running
			running=$((running + 1))
			next=$((next + 1))
		done
		for k in "${LAUNCH_ORDER[@]}"; do
			[ "${STAGE_STATE[k]:-}" = running ] || continue
			if [ -f "$VS_DIR/report.$k" ] || ! kill -0 "${VS_PIDS[k]}" 2>/dev/null; then
				wait "${VS_PIDS[k]}"
				STAGE_WAIT[k]=$?
				STAGE_END[k]=$SECONDS
				STAGE_STATE[k]=finished
				unset 'VS_PIDS[k]'
				running=$((running - 1))
				progressed=1
			fi
		done
		while [ "$printed" -lt "$STAGES" ] && [ "${STAGE_STATE[printed]:-}" = finished ]; do
			stage_print "$printed"
			printed=$((printed + 1))
		done
		# Once a second: each poll forks `sleep`, which costs tens of milliseconds on Git Bash. If
		# `sleep` fails, `wait` blocks until every runner is gone, which delays launches and prints
		# but never spins: a runner is always running here, or the loop would have launched one.
		if [ "$progressed" -eq 0 ] && [ "$printed" -lt "$STAGES" ]; then
			sleep 1 2>/dev/null || wait
		fi
	done
	trap - HUP INT TERM
}

stage_jobs
if [ "$JOBS" -le 1 ]; then
	run_serially
elif ! VS_DIR=$(mktemp -d "${TMPDIR:-/tmp}/amh-verify-stages.XXXXXX" 2>/dev/null) || [ -z "$VS_DIR" ] || [ ! -d "$VS_DIR" ]; then
	printf 'verify.sh: no scratch directory for the held output could be made; running the stages serially\n' >&2
	VS_DIR=''
	run_serially
else
	run_concurrently
	vs_cleanup
fi

if [ "$FAILS" -gt 0 ]; then
	printf '\n   verification set: %d failure(s)\n' "$FAILS"
	exit 1
fi
printf '\n   verification set: clean\n'
