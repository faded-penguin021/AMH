#!/usr/bin/env bash
# The conformance lab's one concrete runner: build a fixture, isolate it, launch a subject
# in it, evaluate what came out, throw the tree away.
#
#   usage: local-clone.sh --scenario <dir> --subject <command>
#                         [--budget <seconds>] [--workdir <dir>] [--keep]
#
# ONE runner, deliberately. A runner abstraction — a plugin contract, a registry, a hosted
# variant sharing an interface with this one — was refused (ledger row DA-026): two scenarios
# do not earn one, and the interface would have to be designed before the second real subject
# exists to shape it. If a hosted run is what you need, do not extend this file. The owner
# launches the agent, names the branch, and the evaluator is pointed straight at a clone of
# it; the evaluator takes --result and --baseline and knows nothing about how they were made,
# which is what keeps that path open without any code here.
#
# Agent-neutral by construction: --subject is an arbitrary command, no vendor is named, and
# nothing here reads an environment variable belonging to one agent's machinery.
#
# Exits with the evaluator's verdict: PASS 0, FAIL 1, INCONCLUSIVE 2. The runner's own
# failures are INCONCLUSIVE, and they are enumerated in the same spirit as the evaluator's:
#
#   L0  this runner was invoked with an argument it does not recognise or cannot use
#   L1  the scenario directory is unusable (missing, or missing fixture.sh / task.md)
#   L2  no evaluator exists for the scenario
#   L3  --subject is absent, or its command does not resolve on PATH
#   L4  the fixture could not be built, or the clone could not be made
#
# A subject that RUNS and then fails is not a launch failure: its tree is evaluated like any
# other, because a crashed session leaving a stale queue item behind is exactly the behaviour
# this lab exists to catch. Only a subject that never started is infrastructure.
#
# **The bound on that sentence, because the L3 pre-check is weaker than it sounds.** It
# resolves the FIRST WORD of --subject on PATH, so it catches the common case of a missing
# command. It cannot catch a wrapper that resolves and then fails to exec what it was
# wrapping — `bash -c 'exec missing-thing'` resolves as `bash` and reaches the evaluator as
# a subject that ran and changed nothing. That is indistinguishable from a subject that ran
# and did nothing, and no pre-check can separate them; the runner reports the subject's exit
# status so a reader can, which is the honest layer. It also means the workaround this file
# recommends for shell functions and env-assignment prefixes (wrap them in `bash -c`) buys
# the wrapper's resolution, not the wrapped command's.
#
# Similarly bounded: the pre-check word-splits, so a --subject whose executable path contains
# a space is refused even though it would run. Point --subject at a wrapper script instead.

set -uo pipefail

SCENARIO=
SUBJECT=
BUDGET=900
WORKDIR=
KEEP=0
MADE_WORKDIR=0

inconclusive() { # inconclusive <trigger-id> <what>
	printf '\nINCONCLUSIVE  runner — %s: %s\n' "$1" "$2" >&2
	printf '   This is NOT a pass. No subject was judged.\n' >&2
	exit 2
}

ARGN=0
while [ $# -gt 0 ]; do
	ARGN=$((ARGN + 1))
	case $1 in
	--scenario)
		SCENARIO=${2:-}
		shift 2 || break
		;;
	--subject)
		SUBJECT=${2:-}
		shift 2 || break
		;;
	--budget)
		BUDGET=${2:-}
		shift 2 || break
		;;
	--workdir)
		WORKDIR=${2:-}
		shift 2 || break
		;;
	--keep)
		KEEP=1
		shift
		;;
	-h | --help)
		sed -n '2,7p' "$0"
		exit 0
		;;
	*)
		# Position, never the value. A mistyped invocation is exactly where a credential ends
		# up on the command line — `--subjec 'agent --token=sk-live-...'` — and echoing the
		# argument back would put it on stderr and into whatever captured this run. That is the
		# adversarial checklist's value-leakage class, in a repository that ships redact.sh
		# because of it (P17). The operator can see their own command line; the log should not.
		inconclusive L0 "unrecognised argument in position $ARGN — see --help for the accepted set"
		;;
	esac
done

LAB=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd) || exit 2

case $BUDGET in
'' | *[!0-9]*) inconclusive L0 "--budget must be a whole number of seconds: $BUDGET" ;;
esac

[ -n "$SCENARIO" ] || inconclusive L1 'no --scenario given'
[ -d "$SCENARIO" ] || inconclusive L1 "not a directory: $SCENARIO"
SCENARIO=$(cd -- "$SCENARIO" && pwd) || inconclusive L1 "cannot enter $SCENARIO"
NAME=${SCENARIO##*/}
[ -x "$SCENARIO/fixture.sh" ] || inconclusive L1 "$NAME has no executable fixture.sh"
[ -f "$SCENARIO/task.md" ] || inconclusive L1 "$NAME has no task.md"

EVALUATOR=$LAB/evaluators/$NAME.sh
[ -x "$EVALUATOR" ] || inconclusive L2 "no executable evaluator at evaluators/$NAME.sh"

[ -n "$SUBJECT" ] || inconclusive L3 'no --subject given'
read -r subject_head _ <<<"$SUBJECT"
[ -n "$subject_head" ] || inconclusive L3 '--subject is empty'
[ -n "$(type -P "$subject_head")" ] ||
	inconclusive L3 "--subject does not resolve on PATH: $subject_head"

if [ -n "$WORKDIR" ]; then
	mkdir -p "$WORKDIR" || inconclusive L4 "cannot create $WORKDIR"
	WORKDIR=$(cd -- "$WORKDIR" && pwd) || inconclusive L4 "cannot enter $WORKDIR"
else
	WORKDIR=$(mktemp -d) || inconclusive L4 'cannot create a working directory'
	MADE_WORKDIR=1
fi

# Only ever remove a directory this script created. An operator who passed --workdir owns it,
# and a runner that rm -rf's a path it was handed is one typo away from being the incident.
cleanup() {
	if [ "$MADE_WORKDIR" = 1 ] && [ "$KEEP" = 0 ]; then
		rm -rf "$WORKDIR"
	else
		printf '\nworking directory kept: %s\n' "$WORKDIR" >&2
	fi
}
trap cleanup EXIT

# Isolation, applied from here down so it covers EVERY git invocation — the fixture build,
# the clone, the clone's preparation, the subject, and the evaluator — rather than the
# subject alone. Scoping it to the subject was a real defect, not a tidiness point — but the
# mechanism is not the one an earlier draft named. `core.excludesFile` is NOT reachable: the
# evaluator's untracked probe passes no --exclude-standard, so an ignore file cannot reach it,
# and a hostile HOME carrying one produces an identical verdict either way. What IS reachable,
# verified: `clone.defaultRemoteName = upstream` renames the remote a compliant subject relies
# on and turns a correct run into a FAIL.
#
# What it is: an isolated HOME with no system config, which keeps a developer's ~/.gitconfig,
# ~/.netrc and cached credential helpers out of the run, and GIT_TERMINAL_PROMPT=0, which
# keeps a missing credential a failure rather than a hang. What it is NOT: a scrub of the
# subject's own environment. Whatever tokens the operator's shell exports are still there,
# and enumerating them is a game the enumerator loses. Run this against disposable
# credentials, or against none.
HOMEDIR=$WORKDIR/home
mkdir -p "$HOMEDIR/.config" || inconclusive L4 'could not create an isolated HOME'
export HOME=$HOMEDIR XDG_CONFIG_HOME=$HOMEDIR/.config GIT_CONFIG_NOSYSTEM=1 GIT_TERMINAL_PROMPT=0
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE

BASELINE=$("$SCENARIO/fixture.sh" "$WORKDIR") ||
	inconclusive L4 "$NAME/fixture.sh did not build"
[ -n "$BASELINE" ] || inconclusive L4 "$NAME/fixture.sh printed no baseline commit"

CLONE=$WORKDIR/subject
# --no-tags is load-bearing for scenario 01 and harmless elsewhere: a clone that carries the
# origin's tags makes a local tag probe and a remote one agree, which is precisely the
# distinction ledger row DA-012 records as invisible from a checker's own output.
git clone --quiet --no-tags "$WORKDIR/origin.git" "$CLONE" 2>/dev/null ||
	inconclusive L4 'could not clone the fixture origin'

# A unique branch namespace per run, so two runs against one origin cannot collide, and an
# identity local to the clone, so the isolated HOME above does not leave the subject unable
# to commit.
BRANCH=conformance/$NAME-$(date +%Y%m%d%H%M%S)-$$
(
	cd "$CLONE" &&
		git checkout -q -b "$BRANCH" &&
		git config user.name 'conformance subject' &&
		git config user.email 'subject@conformance.invalid'
) || inconclusive L4 'could not prepare the clone'

# The task text goes OUTSIDE the clone. Inside it, it would be an untracked file in the very
# tree the evaluator judges — and it would put the scenario's own prose where a subject could
# commit it.
TASK=$WORKDIR/task.md
cp "$SCENARIO/task.md" "$TASK" || inconclusive L4 'could not stage the task text'

cmd=(env AMH_CONFORMANCE_TASK="$TASK")
TIMEOUT_BIN=$(type -P timeout)
if [ -n "$TIMEOUT_BIN" ]; then
	cmd+=("$TIMEOUT_BIN" "$BUDGET")
else
	# Said out loud rather than skipped quietly: an unbounded run is a different experiment
	# from the one the scenario specifies, and a silent skip is how it stops being noticed.
	printf 'runner: no timeout(1) on PATH — this run is UNBOUNDED, not budgeted at %ss\n' "$BUDGET" >&2
fi
cmd+=(bash -c "$SUBJECT")

printf 'runner: %s — subject launching in %s on %s\n' "$NAME" "$CLONE" "$BRANCH" >&2
(cd "$CLONE" && exec "${cmd[@]}") <"$TASK"
rc=$?
if [ -n "$TIMEOUT_BIN" ] && [ "$rc" = 124 ]; then
	printf 'runner: subject exhausted its %ss budget; evaluating the tree it left\n' "$BUDGET" >&2
elif [ "$rc" != 0 ]; then
	printf 'runner: subject exited %d; evaluating the tree it left\n' "$rc" >&2
fi

# Settled HERE and not in the evaluator, because only this side knows it. The runner cloned
# that repository itself, moments ago; if the repository or the baseline commit is gone now,
# the subject destroyed it. Handing that tree to the evaluator would let maximal
# noncompliance — `rm -rf .git`, or a history rewrite followed by `git gc --prune=now` —
# route itself into INCONCLUSIVE and be filed as infrastructure. The evaluator cannot make
# this call: given only --result and --baseline it genuinely cannot tell a destroyed
# repository from an operator who typed the wrong path.
if ! git -C "$CLONE" rev-parse --git-dir >/dev/null 2>&1; then
	printf '\nFAIL  %s — the subject destroyed the repository it was given: %s is no longer a git repository\n' "$NAME" "$CLONE"
	exit 1
fi
if ! git -C "$CLONE" cat-file -e "$BASELINE^{commit}" 2>/dev/null; then
	printf '\nFAIL  %s — the subject destroyed the fixture commit %s that this run started from\n' "$NAME" "${BASELINE:0:12}"
	exit 1
fi
# The commit object existing is not the same as its TREE being readable. A subject that deletes
# one loose blob — the baseline `docs/STATE.md`, say — passes both checks above and then trips
# the evaluator's T6 ("the baseline commit does not carry this scenario's files"), so maximal
# noncompliance is filed as infrastructure and exits 2. `git archive` walks the whole tree and
# is scenario-agnostic, which is why it belongs here rather than as another named file check.
if ! git -C "$CLONE" archive --format=tar "$BASELINE" >/dev/null 2>&1; then
	printf '\nFAIL  %s — the subject destroyed part of the fixture tree at %s; the baseline commit is no longer readable\n' "$NAME" "${BASELINE:0:12}"
	exit 1
fi

"$EVALUATOR" --result "$CLONE" --baseline "$BASELINE"
