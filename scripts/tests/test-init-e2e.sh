#!/usr/bin/env bash
# End-to-end: instantiate the harness into a scratch repo, then run THAT repo's ladder.
#
# The build plan named this as U6's acceptance criterion and it was the one never met.
# Instantiation had only ever been run by hand, and the one time it was, an adopter's very
# first ladder run came back RED for ledger rows only this repo can have — a defect that had
# been shipping for the harness's entire life because nobody had executed the path. An
# artifact nobody can execute accumulates defects at full speed and reports none (D-023).
#
# What this asserts, in order:
#   1. a fresh instantiation produces a repo whose own guards-only ladder is GREEN,
#   2. ...and that green is not vacuous — a planted credential still turns it red,
#   3. re-running init upgrades the machinery and leaves the adopter's judgement and both
#      agent adapters alone,
#   4. the init placeholder list and harness/PLACEHOLDERS.md cannot diverge in silence,
#   5. every --profile installs its own seed set and produces a GREEN guards-only ladder there.
#   6. the post-17.0.0 layout holds on fresh installs, and every pre-17.0.0 shape — standard,
#      full, and light with its folds — reaches it by the documented hand migration, with the
#      installer reporting what is left until it does.
#
# Repo-local: this script runs from the harness's source of truth. It is not shipped, and
# an adopter never runs it.

set -uo pipefail

sed_in_place() { # <sed-expression> <file>
	local expression=$1 file=$2 tmp="${2}.amh-sed.$$"
	sed "$expression" "$file" >"$tmp" || {
		rm -f "$tmp"
		return 1
	}
	cat "$tmp" >"$file" && rm -f "$tmp"
}

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
# Checked: an empty WORK puts every fixture at the filesystem root, and the suite would go on
# to report on trees it never built.
if ! WORK=$(mktemp -d) || [ -z "$WORK" ] || [ ! -d "$WORK" ]; then
	printf '%s: no scratch directory could be created — no fixture ran\n' "${0##*/}" >&2
	exit 1
fi
trap 'rm -rf "$WORK"' EXIT
export HOME="$WORK/home"
mkdir -p "$HOME"

export GIT_AUTHOR_NAME=amh-test GIT_AUTHOR_EMAIL=amh@test.invalid
export GIT_COMMITTER_NAME=amh-test GIT_COMMITTER_EMAIL=amh@test.invalid

PASSED=0
FAILED=0

pass() { PASSED=$((PASSED + 1)); }
fail() { # <name> <detail...>
	FAILED=$((FAILED + 1))
	printf '  FAIL %s\n' "$1" >&2
	shift
	[ $# -gt 0 ] && printf '%s\n' "$*" | sed 's/^/       /' >&2
	return 0
}

# A target repo, empty and freshly initialised — which is the state an adopter is actually
# in. `git init` and nothing else: the ladder must not need a commit to exist before it can
# say anything useful, and the first run happening before the first commit is the normal
# case, not an edge one.
target() { # <name> -> prints the path
	local d="$WORK/$1"
	mkdir -p "$d"
	git -C "$d" init -q
	printf '%s' "$d"
}

# The instantiated repo's OWN ladder, guards only. CI=1 suppresses the local advisories,
# which describe a working session the fixture does not have.
target_ladder() { (cd "$1" && CI=1 scripts/ladder.sh --guards-only 2>&1); }

# A runtime-generated AKIA-shaped token. Never a stored literal: this file is scanned by
# the same secret guard it is testing, and a literal would make it fail its own scan
# (D-004). Bounded read then slice, so `tr` is never left writing into a pipe that `head`
# has already closed.
akia_token() {
	local pool=''
	while [ "${#pool}" -lt 16 ]; do
		pool=$pool$(head -c 512 /dev/urandom | LC_ALL=C tr -dc 'A-Z0-9')
	done
	printf 'AKIA%s' "${pool:0:16}"
}

printf 'init end-to-end\n'

# =============================================================================
# 1. A fresh instantiation is green.
# =============================================================================
d=$(target fresh)
if out=$("$ROOT/scripts/amh-init.sh" "$d" 2>&1); then
	pass
else
	fail "amh-init.sh instantiates into an empty git repo" "$out"
fi

# BSD chmod treats GNU's `--` marker as a filename. Reproduce that contract on every host:
# the installer must never pass the marker, and must still set executable modes correctly.
chmod_bin=$(command -v chmod)
mkdir -p "$WORK/bsd-bin"
cat >"$WORK/bsd-bin/chmod" <<-EOF
	#!/usr/bin/env bash
	for arg in "\$@"; do
		[ "\$arg" != -- ] || { printf 'bsd-chmod fixture: unsupported --\n' >&2; exit 1; }
	done
	exec "$chmod_bin" "\$@"
EOF
"$chmod_bin" +x "$WORK/bsd-bin/chmod"
d_bsd_chmod=$(target bsd_chmod)
if out=$(PATH="$WORK/bsd-bin:$PATH" "$ROOT/scripts/amh-init.sh" "$d_bsd_chmod" 2>&1) &&
	[ -x "$d_bsd_chmod/scripts/ladder.sh" ] &&
	[ ! -e "$d_bsd_chmod/scripts/ladder.sh.amh-init.tmp" ]; then
	pass
else
	fail "amh-init.sh uses the BSD/GNU chmod intersection and leaves no temporary file" "$out"
fi

mkdir -p "$WORK/failing-chmod-bin"
cat >"$WORK/failing-chmod-bin/chmod" <<-EOF
	#!/usr/bin/env bash
	case \${2:-} in
	*.amh-init.tmp) exit 1 ;;
	esac
	exec "$chmod_bin" "\$@"
EOF
"$chmod_bin" +x "$WORK/failing-chmod-bin/chmod"
d_chmod_failure=$(target chmod_failure_cleanup)
if PATH="$WORK/failing-chmod-bin:$PATH" "$ROOT/scripts/amh-init.sh" "$d_chmod_failure" >/dev/null 2>&1; then
	fail "amh-init.sh reports an injected chmod failure"
elif [ ! -e "$d_chmod_failure/scripts/command-guard.sh.amh-init.tmp" ]; then
	pass
else
	fail "amh-init.sh removes its temporary file after chmod failure"
fi

if grep -qxF 'BRANCH_PREFIX=session' "$d/amh.conf"; then
	pass
else
	fail "a fresh instantiation uses the agent-neutral session branch prefix"
fi

# The default is policy, not a hard-coded parser assumption: adopters can still choose any
# namespace through the documented option, and configuration-driven scripts read that value.
d_custom=$(target custom_branch_prefix)
"$ROOT/scripts/amh-init.sh" --branch-prefix maintainer "$d_custom" >/dev/null 2>&1
custom_guard_out=$("$d_custom/scripts/command-guard.sh" --command 'git push origin main' 2>&1)
custom_guard_rc=$?
if grep -qxF 'BRANCH_PREFIX=maintainer' "$d_custom/amh.conf" &&
	[ "$custom_guard_rc" -eq 2 ] &&
	printf '%s' "$custom_guard_out" | grep -qF 'maintainer/<codename>'; then
	pass
else
	fail "--branch-prefix drives installed scripts with an arbitrary prefix" \
		"exit $custom_guard_rc" "$custom_guard_out"
fi

expected_codex_rules="$WORK/expected-codex-amh.rules"
default_branch_slot=$(printf '{%sDEFAULT_BRANCH}%s' '{' '}')
sed "s/$default_branch_slot/main/g" \
	"$ROOT/harness/templates/configs/codex-amh.rules" >"$expected_codex_rules"
if cmp -s "$ROOT/harness/templates/configs/codex-config.toml" "$d/.codex/config.toml" &&
	cmp -s "$expected_codex_rules" "$d/.codex/rules/amh.rules" &&
	[ "$(grep -cFx '[[hooks.SessionStart]]' "$d/.codex/config.toml")" -eq 1 ] &&
	[ "$(grep -cFx '[[hooks.PreToolUse]]' "$d/.codex/config.toml")" -eq 1 ] &&
	sed -n '/^\[\[hooks.SessionStart\]\]$/,/^$/p' "$d/.codex/config.toml" | grep -qF 'scripts/session-start.sh' &&
	sed -n '/^\[\[hooks.PreToolUse\]\]$/,/^$/p' "$d/.codex/config.toml" | grep -qF 'scripts/command-guard.sh' &&
	cmp -s "$ROOT/harness/templates/configs/codex-agents/amh-rule-reviewer.toml" \
		"$d/.codex/agents/amh-rule-reviewer.toml" &&
	[ ! -e "$HOME/.codex/agents/amh-rule-reviewer.toml" ]; then
	pass
else
	fail "a fresh instantiation keeps the complete hook-bearing Codex adapter repository-local"
fi

placeholder_open=$(printf '{%s' '{')
if ! grep -R -qF "$placeholder_open" "$d/.claude" "$d/.codex"; then
	pass
else
	fail "generated agent-adapter installations contain no unresolved placeholders"
fi

out=$(target_ladder "$d")
rc=$?
if [ "$rc" -eq 0 ]; then
	pass
else
	fail "the instantiated repo's own ladder is green" "exit $rc" "$out"
fi

# The seeds arrive carrying {{...}} slots by design, so the run must SAY so rather than
# claiming there is nothing left to do. The alternative — a tool that guesses — hands back
# a constitution that reads as finished and asserts nothing.
report=$("$ROOT/scripts/amh-init.sh" "$d" 2>&1)
if printf '%s' "$report" | grep -qF 'Search for {{'; then
	pass
else
	fail "the run reports the placeholders it deliberately did not fill" "$report"
fi

# =============================================================================
# 2. ...and that green is not vacuous.
#
# Exit 0 from a freshly built tree proves nothing on its own: an instantiation that
# installed a broken ladder, or none, exits 0 just as happily. Plant something the ladder
# is supposed to catch and require it to catch it (the D-020 question — can the thing be
# stubbed with the suite still green).
# =============================================================================
d=$(target positive_control)
"$ROOT/scripts/amh-init.sh" "$d" >/dev/null 2>&1
printf 'key = %s\n' "$(akia_token)" >"$d/deploy.sh"
out=$(target_ladder "$d")
rc=$?
if [ "$rc" -ne 0 ] && printf '%s' "$out" | grep -qF 'credential-shaped'; then
	pass
else
	fail "the instantiated ladder still catches a planted credential" "exit $rc" "$out"
fi

# =============================================================================
# 3. Re-running init upgrades the machinery and leaves the judgement alone.
#
# This is the documented upgrade path and the documented recovery, so each half is
# asserted separately: overwriting a shipped script is the POINT, and overwriting a word
# the adopter wrote would make the tool unusable for the job it exists to do.
# =============================================================================
d=$(target rerun)
"$ROOT/scripts/amh-init.sh" "$d" >/dev/null 2>&1

printf '\n# a local edit that must not survive\n' >>"$d/scripts/ladder.sh"
printf '\n# AN ADOPTER DECISION THAT MUST SURVIVE\n' >>"$d/amh.conf"
adopter_conf=$(cat "$d/amh.conf")
printf '\n# adopter Codex configuration\n' >>"$d/.codex/config.toml"
printf '\n# adopter Codex policy\n' >>"$d/.codex/rules/amh.rules"
printf '\n# adopter reviewer instruction\n' >>"$d/.codex/agents/amh-rule-reviewer.toml"
adopter_codex_config=$(cat "$d/.codex/config.toml")
adopter_codex_rules=$(cat "$d/.codex/rules/amh.rules")
adopter_codex_reviewer=$(cat "$d/.codex/agents/amh-rule-reviewer.toml")
# B13's shape, and the recovery for it: a seed script that has lost its execute bit makes
# the ladder refuse to run its verification rung, and "re-run init" is what the docs tell
# an adopter to do about it.
chmod -x "$d/scripts/verify.sh"

if out=$("$ROOT/scripts/amh-init.sh" "$d" 2>&1); then
	pass
else
	fail "re-running init succeeds" "$out"
fi

if cmp -s "$ROOT/harness/templates/scripts/ladder.sh" "$d/scripts/ladder.sh"; then
	pass
else
	fail "a locally edited shipped script is restored by a re-run"
fi

if [ "$(cat "$d/amh.conf")" = "$adopter_conf" ]; then
	pass
else
	fail "a re-run does not clobber a word the adopter wrote"
fi

if [ "$(cat "$d/.codex/config.toml")" = "$adopter_codex_config" ] &&
	[ "$(cat "$d/.codex/rules/amh.rules")" = "$adopter_codex_rules" ] &&
	[ "$(cat "$d/.codex/agents/amh-rule-reviewer.toml")" = "$adopter_codex_reviewer" ]; then
	pass
else
	fail "a re-run does not clobber adopter changes to any Codex adapter file"
fi

if [ -x "$d/scripts/verify.sh" ]; then
	pass
else
	fail "a re-run restores a seed script's lost execute bit"
fi

# =============================================================================
# 3b. The adoption brief lands once, and STAYS deleted.
#
# The brief ends by telling the agent to delete it. Under plain `keep` that instruction is a
# trap: the next upgrade run resurrects the file, and a repo that has been running the harness
# for a year is handed a document telling it to adopt one. So the write is conditional on a
# FRESH install, and both halves are asserted — a conditional nobody tests is a coin flip.
# =============================================================================
d=$(target adopt_brief)
"$ROOT/scripts/amh-init.sh" "$d" >/dev/null 2>&1
if [ -f "$d/AMH-ADOPT.md" ]; then
	pass
else
	fail "a fresh instantiation writes the adoption brief"
fi

# An annotated brief survives a re-run. This passes through the SKIP path, not the keep path —
# a re-run is never fresh — so it is asserted for what it is: the brief an adopter is part-way
# through is not touched, whichever branch protects it.
printf '\nOWNER CHOSE STANDARD; placeholders half done\n' >>"$d/AMH-ADOPT.md"
brief=$(cat "$d/AMH-ADOPT.md")
out=$("$ROOT/scripts/amh-init.sh" "$d" 2>&1)
if [ "$(cat "$d/AMH-ADOPT.md")" = "$brief" ] && printf '%s' "$out" | grep -qF 'already adopted'; then
	pass
else
	fail "a re-run leaves an annotated brief alone and says why" "$out"
fi

# ...and once deleted, it stays deleted. THIS is the assertion the FRESH gate exists for:
# replacing the condition with `true` must break it, and does.
rm -f "$d/AMH-ADOPT.md"
out=$("$ROOT/scripts/amh-init.sh" "$d" 2>&1)
if [ ! -e "$d/AMH-ADOPT.md" ]; then
	pass
else
	fail "an upgrade re-run does not resurrect a deleted adoption brief" "$out"
fi

# The gate needs BOTH markers, because either alone misfires on a real first-time adopter: a
# repo that happened to have a file called amh.conf would silently never receive the brief,
# and the symptom is a missing file with no diagnostic.
d=$(target adopt_stray_conf)
printf 'UNRELATED=1\n' >"$d/amh.conf"
"$ROOT/scripts/amh-init.sh" "$d" >/dev/null 2>&1
if [ -f "$d/AMH-ADOPT.md" ]; then
	pass
else
	fail "a first-time adopter with an unrelated amh.conf still gets the brief"
fi

# =============================================================================
# 3b'. An upgrade renders what it writes from the amh.conf it keeps.
#
# amh.conf is kept on a re-run, so anything the re-run WRITES — an adapter the adopter deleted,
# a file a later release introduced — must carry that file's values. Rendered from defaults it
# put `main` into the static Codex rules of a repo whose amh.conf said `master`, so the two
# layers protected different branches. Both adapters are deleted here to stand in for files an
# older installation never received, and the re-run names no option at all.
# =============================================================================
d=$(target upgrade_kept_conf)
"$ROOT/scripts/amh-init.sh" --default-branch master "$d" >/dev/null 2>&1
rm -f "$d/.codex/rules/amh.rules" "$d/.claude/settings.json"
out=$("$ROOT/scripts/amh-init.sh" "$d" 2>&1)
rc=$?
if [ "$rc" -eq 0 ] &&
	grep -qF '"HEAD:master"' "$d/.codex/rules/amh.rules" && ! grep -qF '"HEAD:main"' "$d/.codex/rules/amh.rules" &&
	grep -qF 'HEAD:master)' "$d/.claude/settings.json" && ! grep -qF 'HEAD:main)' "$d/.claude/settings.json"; then
	pass
else
	fail "an upgrade renders re-introduced adapters from the kept amh.conf, not from defaults" "exit $rc" "$out"
fi

# ...and an option that AGREES with the kept file is simply accepted: the refusals below are
# about disagreement, and one that fired on every typed option would pass all of them.
rm -f "$d/.codex/rules/amh.rules"
out=$("$ROOT/scripts/amh-init.sh" --default-branch master "$d" 2>&1)
rc=$?
if [ "$rc" -eq 0 ] && grep -qF '"HEAD:master"' "$d/.codex/rules/amh.rules"; then
	pass
else
	fail "an upgrade option that agrees with the kept amh.conf is accepted" "exit $rc" "$out"
fi

# An option that disagrees with the kept file is refused, and refused BEFORE anything is written:
# obeying it would render a value no dynamic guard reads, and dropping it silently would leave
# the adopter believing it had applied.
rm -f "$d/.codex/rules/amh.rules"
out=$("$ROOT/scripts/amh-init.sh" --default-branch develop "$d" 2>&1)
rc=$?
if [ "$rc" -ne 0 ] && printf '%s' "$out" | grep -qF "disagrees with DEFAULT_BRANCH='master'" &&
	[ ! -e "$d/.codex/rules/amh.rules" ]; then
	pass
else
	fail "an upgrade option that disagrees with the kept amh.conf is refused before any write" "exit $rc" "$out"
fi

# A key the kept file does not set means the shipped scripts' default, so an option naming
# anything else is the same disagreement one step removed.
sed_in_place '/^DEFAULT_BRANCH=/d' "$d/amh.conf"
out=$("$ROOT/scripts/amh-init.sh" --default-branch master "$d" 2>&1)
rc=$?
if [ "$rc" -ne 0 ] && printf '%s' "$out" | grep -qF "resolves DEFAULT_BRANCH to the shipped scripts' default 'main'" &&
	[ ! -e "$d/.codex/rules/amh.rules" ]; then
	pass
else
	fail "an upgrade option for a key the kept amh.conf leaves unset is refused" "exit $rc" "$out"
fi

# Branch values reach an unquoted assignment every shipped script sources, and the default branch
# also JSON, Starlark and a YAML comment; both are narrowed to characters all of those read
# literally. Each value here is refused with the tree still empty: `release/"stable"` is a valid
# git branch name that produced adapter JSON which did not parse, `$(...)` would run on every
# ladder run, `a..b` and a prefix of `.a` pass the character set and fail git's own rules (the
# second only once `/<codename>` is appended), and a quote ends the single-quoted citation list.
only_git() { # <dir> — true when nothing but .git is in it
	local f
	for f in "$1"/* "$1"/.[!.]* "$1"/..?*; do
		[ -e "$f" ] || continue
		[ "${f##*/}" = .git ] || return 1
	done
}
n=0
# shellcheck disable=SC2016 # the `$(id)` is the refused VALUE, and must reach the script unexpanded
for spec in '--default-branch:release/"stable"' '--branch-prefix:x$(id)' '--default-branch:a..b' '--branch-prefix:.a' "--citation-paths:scripts it's"; do
	n=$((n + 1))
	flag=${spec%%:*}
	val=${spec#*:}
	t=$(target "unsafe_value_$n")
	out=$("$ROOT/scripts/amh-init.sh" "$flag" "$val" "$t" 2>&1)
	rc=$?
	if [ "$rc" -ne 0 ] && printf '%s' "$out" | grep -qF -- "$flag" &&
		only_git "$t"; then
		pass
	else
		fail "an unsafe $flag value is refused before anything is written: $val" "exit $rc" "$out"
	fi
done

# The same narrowing reaches a value READ from the kept file — but only where this run is about
# to write it, and the pair below pins both sides of that line. With the Codex rules to
# regenerate, the unsafe kept branch would land in them: refused, blamed on the file rather than
# on an option the adopter never typed, and nothing written. With nothing to regenerate that
# carries it, the same value blocks nothing: the shipped scripts are copied whatever amh.conf
# says, and a check with nothing to protect can only stop an upgrade.
d=$(target upgrade_kept_unsafe)
"$ROOT/scripts/amh-init.sh" "$d" >/dev/null 2>&1
printf "DEFAULT_BRANCH='rel\"x'\n" >>"$d/amh.conf"
out=$("$ROOT/scripts/amh-init.sh" "$d" 2>&1)
rc=$?
if [ "$rc" -eq 0 ]; then
	pass
else
	fail "an unsafe value in the kept amh.conf that no written file carries does not block the upgrade" "exit $rc" "$out"
fi
rm -f "$d/.codex/rules/amh.rules"
out=$("$ROOT/scripts/amh-init.sh" "$d" 2>&1)
rc=$?
if [ "$rc" -ne 0 ] && printf '%s' "$out" | grep -qF 'DEFAULT_BRANCH in the kept amh.conf may contain only' &&
	[ ! -e "$d/.codex/rules/amh.rules" ]; then
	pass
else
	fail "an unsafe kept value that a written file WOULD carry is refused and blamed on amh.conf" "exit $rc" "$out"
fi

# The size band reaches only amh.conf, which an upgrade never writes, so a kept value the
# installer would refuse at install time (a sentence ceiling past what the compression trigger
# can hold) must not stop an upgrade whose own ladder runs on it.
d=$(target upgrade_kept_band)
"$ROOT/scripts/amh-init.sh" "$d" >/dev/null 2>&1
sed_in_place 's/^STATE_COMPRESS_TO_SENTENCES=.*/STATE_COMPRESS_TO_SENTENCES=2000/' "$d/amh.conf"
out=$("$ROOT/scripts/amh-init.sh" "$d" 2>&1)
rc=$?
if [ "$rc" -eq 0 ]; then
	pass
else
	fail "a kept size-band value no written file carries does not block the upgrade" "exit $rc" "$out"
fi

# A kept amh.conf is read the way the shipped scripts read it: from the target's root, with ROOT
# naming that root. One that sources a sibling through "$ROOT" is read in full even when the
# installer runs from somewhere else entirely.
d=$(target upgrade_kept_root_relative)
"$ROOT/scripts/amh-init.sh" "$d" >/dev/null 2>&1
sed_in_place '/^DEFAULT_BRANCH=/d' "$d/amh.conf"
printf 'DEFAULT_BRANCH=master\n' >"$d/amh.local.conf"
# shellcheck disable=SC2016 # the line is written into amh.conf; its "$ROOT" belongs to the reader
printf '. "$ROOT/amh.local.conf"\n' >>"$d/amh.conf"
rm -f "$d/.codex/rules/amh.rules"
out=$(cd "$WORK" && "$ROOT/scripts/amh-init.sh" "$d" 2>&1)
rc=$?
if [ "$rc" -eq 0 ] && grep -qF '"HEAD:master"' "$d/.codex/rules/amh.rules"; then
	pass
else
	fail "a kept amh.conf that sources a sibling through \$ROOT is read in full" "exit $rc" "$out"
fi

# A kept amh.conf is read with the shipped scripts' defaults already in place, because every
# shipped script assigns them before it sources the file. A line that reads the key it assigns
# therefore resolves to the default at runtime — the installed guard below protects `main` — and
# reading the file with the keys unset rendered `trunk` into both adapters instead, so the static
# rules and the guard protected different branches with every rung green.
d=$(target upgrade_kept_self_reference)
"$ROOT/scripts/amh-init.sh" "$d" >/dev/null 2>&1
sed_in_place '/^DEFAULT_BRANCH=/d' "$d/amh.conf"
# shellcheck disable=SC2016 # the line is written into amh.conf; its expansion belongs to the reader
printf 'DEFAULT_BRANCH=${DEFAULT_BRANCH:-trunk}\n' >>"$d/amh.conf"
rm -f "$d/.codex/rules/amh.rules" "$d/.claude/settings.json"
out=$("$ROOT/scripts/amh-init.sh" "$d" 2>&1)
rc=$?
guard_out=$("$d/scripts/command-guard.sh" --command 'git push origin HEAD:main' 2>&1)
guard_rc=$?
if [ "$rc" -eq 0 ] && [ "$guard_rc" -eq 2 ] &&
	grep -qF '"HEAD:main"' "$d/.codex/rules/amh.rules" && ! grep -qF 'trunk' "$d/.codex/rules/amh.rules" &&
	grep -qF 'HEAD:main)' "$d/.claude/settings.json" && ! grep -qF 'trunk' "$d/.claude/settings.json"; then
	pass
else
	fail "a kept amh.conf that reads the key it assigns renders what the installed guard enforces" \
		"exit $rc, guard exit $guard_rc" "$out" "$guard_out"
fi

# A kept amh.conf that stops part way hands back nothing, and nothing reads exactly like "every
# key unset" — the defaults this whole block exists to stop rendering. The run must refuse.
d=$(target upgrade_kept_exits)
"$ROOT/scripts/amh-init.sh" --default-branch master "$d" >/dev/null 2>&1
printf 'exit 0\n' >>"$d/amh.conf"
rm -f "$d/.codex/rules/amh.rules"
out=$("$ROOT/scripts/amh-init.sh" "$d" 2>&1)
rc=$?
if [ "$rc" -ne 0 ] && printf '%s' "$out" | grep -qF 'did not load to its end' &&
	[ ! -e "$d/.codex/rules/amh.rules" ]; then
	pass
else
	fail "a kept amh.conf that exits part way is refused rather than read as defaults" "exit $rc" "$out"
fi

# A FIRST install that finds an unrelated amh.conf keeps it too, and the shipped scripts will
# source it, so it is the file every value has to agree with: an option it does not record is
# refused rather than rendered beside a default the scripts would read instead.
d=$(target unrelated_conf_option)
printf 'UNRELATED=1\n' >"$d/amh.conf"
out=$("$ROOT/scripts/amh-init.sh" --default-branch master "$d" 2>&1)
rc=$?
if [ "$rc" -ne 0 ] && printf '%s' "$out" | grep -qF "resolves DEFAULT_BRANCH to the shipped scripts' default 'main'" &&
	[ ! -e "$d/.codex/rules/amh.rules" ]; then
	pass
else
	fail "an option an unrelated kept amh.conf does not record is refused on a first install" "exit $rc" "$out"
fi

# =============================================================================
# 3c. The integrity manifest reaches the adopter, and works THERE.
#
# Everything the shipped suite asserts about this rung it asserts against a synthesised
# fixture repo whose manifest the suite itself wrote. That proves the rung's logic and
# nothing about the delivery: an installer that never wrote the manifest, or wrote it before
# the scripts it hashes, would leave every one of those fixtures green while every real
# adopter got a permanent `skip` — or worse, a red ladder on a tree nobody had touched.
# =============================================================================
d=$(target manifest)
"$ROOT/scripts/amh-init.sh" "$d" >/dev/null 2>&1

if cmp -s "$ROOT/harness/templates/scripts/MANIFEST.sha256" "$d/scripts/MANIFEST.sha256"; then
	pass
else
	fail "a fresh instantiation installs the shipped integrity manifest"
fi

# The rung is live in the new tree, not skipping. The count is part of the assertion: a
# manifest that arrived truncated, or one written before the scripts, would still produce an
# `ok` line — with a smaller number. The expected number is DERIVED from the template
# directory rather than written out: hard-coding it made adding a sixth shipped script fail
# here with a message naming "five", which reads as a defect in the installer instead of a
# stale count in this line.
shipped_count=$(find "$ROOT/harness/templates/scripts" -maxdepth 1 -name '*.sh' | wc -l | tr -d ' ')
out=$(target_ladder "$d")
if [ "$shipped_count" -eq 0 ]; then
	fail "counted NOTHING to expect — no shipped scripts found under harness/templates/scripts" "$out"
elif printf '%s' "$out" | grep -qF "   ok    $shipped_count shipped script(s) match the published hashes"; then
	pass
else
	fail "the instantiated repo verifies all $shipped_count shipped script(s) against the manifest" "$out"
fi

# The conformance lab is repo-local and must never reach an adopter. That is structurally true
# — amh-init.sh copies only from harness/templates/, and nothing about the lab lives there — but
# structurally true and asserted are different things, and the adjudication that admitted the lab
# requires this one MECHANICALLY rather than in prose (DA-026, criterion 7). The README and the
# runbook both state the claim; without this line they would be the only thing stating it, which
# is the shape D-010 names.
if [ ! -e "$d/conformance" ]; then
	pass
else
	fail "the conformance lab is absent from an instantiated adopter tree" "$(ls -a "$d/conformance")"
fi

# The defect the whole unit exists to catch, exercised where it actually happens: a local edit
# to a shipped script in somebody else's repo.
printf '\n# a local edit to a shipped rail\n' >>"$d/scripts/redact.sh"
out=$(target_ladder "$d")
rc=$?
if [ "$rc" -ne 0 ] && printf '%s' "$out" | grep -qF 'scripts/redact.sh does not match the hash'; then
	pass
else
	fail "an edited shipped script turns the adopter's ladder red" "exit $rc" "$out"
fi

# ...and the documented repair puts both halves back. The manifest is `overwrite` policy for
# this reason: an adopter who edited it — to silence the rung, or by accident — must not keep
# that edit through an upgrade, or the guard is disabled by its own subject.
printf '# an edit to the manifest itself\n' >>"$d/scripts/MANIFEST.sha256"
"$ROOT/scripts/amh-init.sh" "$d" >/dev/null 2>&1
if cmp -s "$ROOT/harness/templates/scripts/redact.sh" "$d/scripts/redact.sh" &&
	cmp -s "$ROOT/harness/templates/scripts/MANIFEST.sha256" "$d/scripts/MANIFEST.sha256"; then
	pass
else
	fail "re-running init restores both the edited script and an edited manifest"
fi

out=$(target_ladder "$d")
rc=$?
if [ "$rc" -eq 0 ]; then
	pass
else
	fail "the repaired repo's ladder is green again" "exit $rc" "$out"
fi

# =============================================================================
# 4. The init placeholder list is bound to the document describing it.
#
# Both directions, because the two are separately silent: a name documented as `init` but
# absent from the list ships unfilled into a live config, and a name in the list but not
# in the document is an undocumented slot. The check runs against a COPY of the harness —
# amh-init.sh resolves its root from its own path, so a copy carrying only what it reads
# is enough, and the real tree is never mutated.
# =============================================================================
harness_copy() { # <name> -> prints the path
	local d="$WORK/$1"
	mkdir -p "$d/scripts"
	cp -R "$ROOT/harness" "$d/harness"
	cp "$ROOT/scripts/amh-init.sh" "$d/scripts/amh-init.sh"
	chmod +x "$d/scripts/amh-init.sh"
	printf '%s' "$d"
}

expect_init_dies() { # <name> <harness-dir> <target-dir>
	local out rc
	out=$("$2/scripts/amh-init.sh" "$3" 2>&1)
	rc=$?
	if [ "$rc" -eq 0 ]; then
		fail "$1" "expected a failure, amh-init succeeded" "$out"
	elif ! printf '%s' "$out" | grep -qF 'disagree'; then
		fail "$1" "failed, but not with the divergence message" "$out"
	else
		pass
	fi
}

h=$(harness_copy doc_extra)
# Appended as a table row, with the name supplied at runtime rather than written out: a
# spelled-out placeholder in this file would trip the placeholder guard, which reads live
# files — the D-004 class, and this file demonstrating it while testing it.
# shellcheck disable=SC2016 # the backticks are the table's own markdown syntax — the row
# must look exactly like a real one or the check would pass for the wrong reason. Scoped
# to this single printf, never the block.
printf '| `%s` | init | A slot the init script has never heard of. |\n' \
	TOTALLY_NEW_KNOB >>"$h/harness/PLACEHOLDERS.md"
expect_init_dies "a documented init placeholder missing from the script is fatal" \
	"$h" "$(target doc_extra_target)"

h=$(harness_copy list_extra)
sed_in_place "s/^INIT_PLACEHOLDERS='/INIT_PLACEHOLDERS='TOTALLY_NEW_KNOB /" \
	"$h/scripts/amh-init.sh"
expect_init_dies "an init placeholder missing from the document is fatal" \
	"$h" "$(target list_extra_target)"

# And the binding is not vacuous either: it must still pass on the real, unmutated tree —
# which cases 1–3 above have already exercised, since every one of them ran the check.

# =============================================================================
# 5. Every profile installs its own seed set, and every one of them is green.
#
# Two profiles since AMH 17.0.0: `standard`, the default, and `full`. The claim the removed
# `light` profile used to carry here is still asserted below, on a standard tree whose owner
# removed the ledger: assurance degrades by ARTIFACT PRESENCE rather than by a configured
# level. A repo with no ledger must produce a ladder that skips the ledger rung and stays
# green — if it went red instead, deleting a scaffold would be a way to ship a broken tree,
# and the only honest fix would be the runtime flag this design refuses (DA-001).
#
# Absence is asserted as hard as presence: a profile that quietly installed everything would
# satisfy every green-ladder assertion here while doing nothing it claims to do.
# =============================================================================

# Sets PROFILE_DIR rather than printing it. A command substitution would run this in a
# subshell, and every pass() and fail() it performed would be counted into a copy of the
# tallies that dies with the subshell — a whole section of the suite reporting nothing, which
# is the silent-skip class this repo keeps rediscovering.
PROFILE_DIR=''
profile_case() { # <profile> <present-csv> <absent-csv>
	local profile=$1 present=$2 absent=$3 d out rc f missing='' extra=''
	d=$(target "profile_$profile")
	PROFILE_DIR=$d
	if out=$("$ROOT/scripts/amh-init.sh" --profile "$profile" "$d" 2>&1); then
		pass
	else
		fail "--profile $profile instantiates" "$out"
		return 0
	fi
	# shellcheck disable=SC2086 # the split is the point: both arguments are
	# space-separated path lists. Scoped to these two loops — none of these paths can
	# contain a space, they are fixed seed names written in this file.
	for f in $present; do
		[ -e "$d/$f" ] || missing="$missing $f"
	done
	# shellcheck disable=SC2086
	for f in $absent; do
		[ ! -e "$d/$f" ] || extra="$extra $f"
	done
	if [ -z "$missing" ] && [ -z "$extra" ]; then
		pass
	else
		fail "--profile $profile installs exactly its seed set" \
			"missing:$missing" "installed but should not be:$extra"
	fi
	out=$(target_ladder "$d")
	rc=$?
	if [ "$rc" -eq 0 ]; then
		pass
	else
		fail "the --profile $profile repo's own ladder is green" "exit $rc" "$out"
	fi
}

STANDARD_SET='AGENTS.md CLAUDE.md .gitattributes docs/STATE.md scripts/verify.sh scripts/ladder.sh amh.conf docs/PROTOCOLS.md docs/RUNBOOK.md docs/LEDGER.md'

profile_case standard "$STANDARD_SET" 'docs/history/README.md'
d=$PROFILE_DIR

# The positive control again, under the smallest profile. Everything a smaller profile drops is
# prose; if one of them could also cost a guard, this is where that would surface.
printf 'key = %s\n' "$(akia_token)" >"$d/deploy.sh"
out=$(target_ladder "$d")
rc=$?
if [ "$rc" -ne 0 ] && printf '%s' "$out" | grep -qF 'credential-shaped'; then
	pass
else
	fail "a standard instantiation still catches a planted credential" "exit $rc" "$out"
fi

# Presence-derived assurance (DA-001), on the shape that now reaches it: the owner removed the
# ledger from a standard tree. The green must be the kind that SAYS it skipped. A silent pass
# is indistinguishable from a ladder that lost the rung altogether (D-019).
d=$(target profile_no_ledger)
"$ROOT/scripts/amh-init.sh" "$d" >/dev/null 2>&1
rm -f -- "$d/docs/LEDGER.md"
out=$(target_ladder "$d")
rc=$?
if [ "$rc" -eq 0 ] && printf '%s' "$out" | grep -qF 'no ledger yet'; then
	pass
else
	fail "a tree without a ledger reports the ledger rung as skipped and stays green" "exit $rc" "$out"
fi

# `full` has no seed left to be absent, so its absence list names a file no profile installs.
# Passing an empty list would have made this call's absence half a loop that runs zero times —
# an assertion that cannot fail, dressed as one that can.
profile_case full "$STANDARD_SET docs/history/README.md" 'docs/NOTHING_IS_DECLINED_AT_FULL.md'

# The DEFAULT is `standard`, and it needs its own assertion: every case above passes --profile
# explicitly, and every case elsewhere in this file passes none but asserts nothing about which
# seeds landed. When the default was `light`, changing it to `full` left the suite 30/30 green.
# Both halves, because a default of `full` also installs the binding document and the ledger.
d=$(target profile_default)
"$ROOT/scripts/amh-init.sh" "$d" >/dev/null 2>&1
if [ -f "$d/docs/PROTOCOLS.md" ] && [ -f "$d/docs/LEDGER.md" ] && [ ! -e "$d/docs/history/README.md" ]; then
	pass
else
	fail "with no --profile the install is standard"
fi

# The brief is the only place the profile is written down — the whole design refuses to record
# it anywhere a script could read — so the substitution being right is not cosmetic: it is the
# adopting agent's sole account of what it is looking at. Hardcoding a wrong profile into the
# template left the suite green. Both profiles, because a template that named one of them
# unconditionally would satisfy a single-profile check.
# shellcheck disable=SC2016 # the backticks are the brief's own markdown code span, matched
# literally by grep -F. Expanding them would run the word as a command. Scoped to this one
# condition rather than the file, so a genuine unexpanded expression elsewhere still reports.
if grep -qF 'used the `standard` profile' "$d/AMH-ADOPT.md" &&
	grep -qF 'used the `full` profile' "$WORK/profile_full/AMH-ADOPT.md"; then
	pass
else
	fail "the brief states the profile the install actually used"
fi

# `light` is refused by NAME, before anything is written: a command line copied from an older
# brief must learn that the profile is gone, not receive a standard tree while believing it
# chose a smaller one. Asserting the empty target is what tells "refused" from "warned, then
# installed anyway".
d=$(target profile_light_removed)
out=$("$ROOT/scripts/amh-init.sh" --profile light "$d" 2>&1)
rc=$?
if [ "$rc" -ne 0 ] && printf '%s' "$out" | grep -qF 'light profile was removed in AMH 17.0.0' &&
	printf '%s' "$out" | grep -qF 'use --profile standard' && only_git "$d"; then
	pass
else
	fail "--profile light is refused by name and writes nothing" "exit $rc" "$out"
fi

# Escalation is a re-run, and it is the entire upgrade path between profiles: it must ADD the
# declined seed while leaving what the adopter has already written alone. Both halves, because
# a re-run that clobbered the constitution would be the worse failure and would still satisfy
# an "it added the archive" assertion on its own.
d=$(target profile_escalate)
"$ROOT/scripts/amh-init.sh" --profile standard "$d" >/dev/null 2>&1
printf '\nAN ADOPTER SENTENCE THAT MUST SURVIVE\n' >>"$d/AGENTS.md"
printf '\nAN ADOPTER PROTOCOL SENTENCE THAT MUST SURVIVE\n' >>"$d/docs/PROTOCOLS.md"
adopter_agents=$(cat "$d/AGENTS.md")
adopter_protocols=$(cat "$d/docs/PROTOCOLS.md")
out=$("$ROOT/scripts/amh-init.sh" --profile full "$d" 2>&1)
if [ -f "$d/docs/history/README.md" ]; then
	pass
else
	fail "re-running with a larger profile adds the seed it declined before" "$out"
fi
if [ "$(cat "$d/AGENTS.md")" = "$adopter_agents" ] &&
	[ "$(cat "$d/docs/PROTOCOLS.md")" = "$adopter_protocols" ]; then
	pass
else
	fail "escalating a profile does not clobber a word the adopter wrote"
fi

# The reverse of escalation, and the one that reaches every EXISTING adopter: `docs/UPGRADING.md`
# documents a bare `amh-init.sh <target>` as the upgrade path, and the default is not the
# largest profile. A full adopter who has an archive must not be told it is "not in the
# standard profile" — presence outranks the profile, so it is kept.
#
# The silent half is asserted too, and it is the one that would never have been noticed: a
# declined file never enters the installed list, so gating before the presence test also drops
# it from the unfilled-placeholder report. The archive seed ships with no slot of its own, so
# the adopter's copy is given one here — the report must still reach it.
d=$(target downgrade_rerun)
"$ROOT/scripts/amh-init.sh" --profile full "$d" >/dev/null 2>&1
printf '\n{{%s}}\n' ARCHIVE_OWNER_SLOT >>"$d/docs/history/README.md"
out=$("$ROOT/scripts/amh-init.sh" "$d" 2>&1)
if [ -f "$d/docs/history/README.md" ] &&
	! printf '%s' "$out" | grep -qF '(not in the standard profile' &&
	printf '%s' "$out" | grep -qF '0 not in the standard profile'; then
	pass
else
	fail "a plain re-run keeps seeds the adopter already has instead of declining them" "$out"
fi
if printf '%s' "$out" | grep -qE '^ +docs/history/README\.md$'; then
	pass
else
	fail "a kept-but-out-of-profile seed still reaches the unfilled-placeholder report" "$out"
fi

# A declined file is NAMED, not silently absent. Nothing in the target tree records the
# profile, by design, so this output is the adopter's only account of what they did not get.
# The assertion runs to the END of the line, including which profile would supply the file:
# stopping at the filename leaves the ADVICE untested, and the advice is the part that can be
# wrong while looking right (D-007's shape, in an assertion rather than a guard).
out=$("$ROOT/scripts/amh-init.sh" --profile standard "$(target profile_report)" 2>&1)
if printf '%s' "$out" | grep -qF 'docs/history/README.md (not in the standard profile — add it with --profile full)' &&
	printf '%s' "$out" | grep -qF '1 not in the standard profile'; then
	pass
else
	fail "the run names each declined seed, the profile that supplies it, and the tally" "$out"
fi

# An unknown profile dies at init rather than inside a guard in someone else's repo — the
# --merge-mode rule. Falling through to "install everything" would be the dangerous default.
out=$("$ROOT/scripts/amh-init.sh" --profile heavy "$(target profile_bad)" 2>&1)
rc=$?
if [ "$rc" -ne 0 ] && printf '%s' "$out" | grep -qF 'must be standard or full'; then
	pass
else
	fail "an unknown --profile is fatal at init" "exit $rc" "$out"
fi

# =============================================================================
# 6. The layout after AMH 17.0.0, and how an install from before it gets there.
#
# docs/PROTOCOLS.md holds the six sections every session is bound by; docs/RUNBOOK.md keeps
# the change-type playbooks. A seed is never re-synced, so an existing install migrates by
# hand (harness/CHANGELOG.md, 17.0.0, Upgrading), and the installer's closing report is the
# only thing that can say the migration is unfinished — the files involved are the adopter's.
#
# Every case asserts the end state the same way: the six sections each present exactly once in
# docs/PROTOCOLS.md and identical to a fresh install's, none of them (and no folded playbooks)
# left in the constitution or the runbook, and every `docs/<file>.md` → **<section>** pointer
# in the four documents resolving to a file that exists and a heading it has. Presence of a
# file or a heading alone does not pass.
#
# The historical installs are RECONSTRUCTED from the current seed by the inverse of the split
# — the six sections back into the runbook (or folded into the constitution, as the removed
# light profile's brief told adopters to do), the binding document deleted, its pointers sent
# back to the runbook. They are not checked out from a released tag: this suite runs on a
# checkout that may have no history, and a case that skipped when it had none would be the
# silent-skip class. The reconstruction is close to, not identical with, a real 16.x tree.
# =============================================================================

MOVED='Session discipline|Adversarial review protocol|Rule-review protocol|Incident: leaked credential|Acceptance ladder|Working-memory compression'
REF=$WORK/profile_default # a fresh standard install, from section 5

# sed_in_place with an extended regular expression; the same temp-file-and-cat route.
sed_ere_in_place() { # <sed-ere-expression> <file>
	local tmp="${2}.amh-sed.$$"
	sed -E "$1" "$2" >"$tmp" || {
		rm -f "$tmp"
		return 1
	}
	cat "$tmp" >"$2" && rm -f "$tmp"
}

# Prints the `## ` section whose heading starts with <prefix>, up to the next `## ` heading.
section_of() { # <file> <prefix>
	awk -v h="## $2" 'index($0, h) == 1 { p = 1; print; next } p && /^## / { exit } p' "$1"
}

# Deletes, in place, every `## ` section whose heading matches the extended regex.
drop_sections() { # <file> <ere>
	awk -v re="^## ($2)" '/^## / { skip = ($0 ~ re) } !skip' "$1" >"$1.tmp" && mv -- "$1.tmp" "$1"
}

# Sets LAYOUT_PROBLEMS: empty when the tree has the post-17.0.0 layout.
# The runbook's playbooks are compared WHOLE against what they should be — a fresh install's,
# or for a light install the playbooks its owner folded into the constitution — because a
# heading with nothing under it is the "presence alone" H3's acceptance refuses.
LAYOUT_PROBLEMS=''
layout_check() { # <dir> [file holding the expected Change-type playbooks section]
	local d=$1 expected=${2:-} sec n want IFS_SAVE=$IFS
	LAYOUT_PROBLEMS=''
	IFS='|'
	for sec in $MOVED; do
		IFS=$IFS_SAVE
		n=$(grep -cE "^## $sec( |\$)" "$d/docs/PROTOCOLS.md" 2>/dev/null)
		[ "${n:-0}" = 1 ] || LAYOUT_PROBLEMS="$LAYOUT_PROBLEMS [PROTOCOLS has $sec ${n:-0} times]"
		[ "$(section_of "$d/docs/PROTOCOLS.md" "$sec")" = "$(section_of "$REF/docs/PROTOCOLS.md" "$sec")" ] ||
			LAYOUT_PROBLEMS="$LAYOUT_PROBLEMS [PROTOCOLS: $sec is not the complete section]"
		IFS='|'
	done
	IFS=$IFS_SAVE
	[ "$(grep -c '^## Change-type playbooks' "$d/docs/RUNBOOK.md")" = 1 ] ||
		LAYOUT_PROBLEMS="$LAYOUT_PROBLEMS [RUNBOOK has no single Change-type playbooks section]"
	if [ -n "$expected" ]; then want=$(cat "$expected"); else want=$(section_of "$REF/docs/RUNBOOK.md" 'Change-type playbooks'); fi
	[ "$(section_of "$d/docs/RUNBOOK.md" 'Change-type playbooks')" = "$want" ] ||
		LAYOUT_PROBLEMS="$LAYOUT_PROBLEMS [RUNBOOK: the playbooks are not the expected ones, complete]"
	! grep -qE "^## ($MOVED)( |\$)" "$d/docs/RUNBOOK.md" ||
		LAYOUT_PROBLEMS="$LAYOUT_PROBLEMS [RUNBOOK still carries a moved section]"
	! grep -qE "^## ($MOVED|Change-type playbooks)( |\$)" "$d/AGENTS.md" ||
		LAYOUT_PROBLEMS="$LAYOUT_PROBLEMS [AGENTS.md still carries a moved section]"
	grep -qF 'docs/PROTOCOLS.md' "$d/AGENTS.md" ||
		LAYOUT_PROBLEMS="$LAYOUT_PROBLEMS [AGENTS.md never mentions docs/PROTOCOLS.md]"
}

# Sets POINTER_PROBLEMS: every backticked `docs/<file>.md`, and every `docs/<file>.md` →
# **<section>** pointer, in the constitution, the state file, the runbook and the protocols,
# names a file that exists and, for a pointer, a heading that file has. Line breaks and
# blockquote markers are flattened first, so a pointer wrapped across lines is still read.
POINTER_PROBLEMS=''
pointer_check() { # <dir>
	local d=$1 f ref path head
	POINTER_PROBLEMS=''
	for f in AGENTS.md docs/STATE.md docs/RUNBOOK.md docs/PROTOCOLS.md; do
		[ -f "$d/$f" ] || { POINTER_PROBLEMS="$POINTER_PROBLEMS [$f missing]"; continue; }
		# shellcheck disable=SC2016 # the backticks are Markdown code spans matched or written
		# literally; nothing in them is meant to expand. Scoped to this loop.
		while IFS= read -r ref; do
			path=${ref#\`}
			path=${path%%\`*}
			[ -f "$d/$path" ] || { POINTER_PROBLEMS="$POINTER_PROBLEMS [$f -> $path: no such file]"; continue; }
			case $ref in *'**'*) ;; *) continue ;; esac
			head=${ref#*\*\*}
			head=${head%\*\*}
			grep -qF -- "## $head" "$d/$path" ||
				POINTER_PROBLEMS="$POINTER_PROBLEMS [$f -> $path: no heading '$head']"
		done < <(sed 's/^> \{0,1\}//' "$d/$f" | tr '\n' ' ' | tr -s ' ' |
			grep -oE '`docs/[A-Za-z_]+\.md`( → \*\*[^*]+\*\*)?' || true)
	done
}

# The hand migration as the 17.0.0 Upgrading subsection states it, done by script: steps B to
# E. Carrying a local edit of a moved section into docs/PROTOCOLS.md is step A; these trees
# have none. <fold> names whether the constitution carries folded playbooks to move first;
# <state> and <config> leave the state file, or the two configuration steps, undone.
hand_migrate() { # <dir> <fold:yes|no> <state:yes|no> [config:yes|no, default yes]
	local d=$1 fold=$2 state=$3 config=${4:-yes} f files='AGENTS.md docs/RUNBOOK.md'
	if [ "$fold" = yes ]; then
		{
			awk '/^## Change-type playbooks/ { exit } { print }' "$d/docs/RUNBOOK.md"
			section_of "$d/AGENTS.md" 'Change-type playbooks'
			awk '/^## Change-type playbooks/ { p = 1; next } p && /^## / { q = 1 } q' "$d/docs/RUNBOOK.md"
		} >"$d/docs/RUNBOOK.md.tmp" && mv -- "$d/docs/RUNBOOK.md.tmp" "$d/docs/RUNBOOK.md"
		drop_sections "$d/AGENTS.md" 'Change-type playbooks'
	fi
	drop_sections "$d/docs/RUNBOOK.md" "$MOVED"
	drop_sections "$d/AGENTS.md" "$MOVED"
	[ "$state" = yes ] && files="$files docs/STATE.md"
	# shellcheck disable=SC2016 # the backticks are Markdown code spans matched or written
	# literally; nothing in them is meant to expand. Scoped to this loop.
	for f in $files; do
		sed_ere_in_place 's#`docs/RUNBOOK\.md` → (\*{0,2})(Session|Adversarial|Rule-review|Incident:|Acceptance|Working-memory)#`docs/PROTOCOLS.md` → \1\2#g' "$d/$f"
		sed_ere_in_place 's#docs/RUNBOOK\.md → (Working-memory compression)#docs/PROTOCOLS.md → \1#g' "$d/$f"
		sed_ere_in_place 's#RUNBOOK \*\*Session discipline\*\*#`docs/PROTOCOLS.md` → **Session discipline**#g' "$d/$f"
		sed_ere_in_place 's#the incident playbook in `docs/RUNBOOK\.md`#`docs/PROTOCOLS.md` → **Incident: leaked credential**#g' "$d/$f"
		sed_ere_in_place 's#this runbook → \*\*(Working-memory compression)#`docs/PROTOCOLS.md` → **\1#g' "$d/$f"
	done
	[ "$config" = yes ] || return 0
	sed_in_place "s#^RULE_FILES='AGENTS.md #RULE_FILES='AGENTS.md docs/PROTOCOLS.md #" "$d/amh.conf"
	sed_in_place 's#the review classes already defined by docs/RUNBOOK.md#the review classes the Rule-review protocol already defines#' \
		"$d/.codex/agents/amh-rule-reviewer.toml"
}

# A pre-17.0.0 standard or full install: the six sections inside the runbook, no binding
# document, every pointer to them aimed at the runbook.
make_historical_runbook() { # <dir>
	local d=$1
	{
		awk '/^## When CI fails/ { exit } { print }' "$d/docs/RUNBOOK.md"
		awk '/^## Session discipline/ { p = 1 } p' "$d/docs/PROTOCOLS.md"
		printf '\n'
		awk '/^## When CI fails/ { p = 1 } p' "$d/docs/RUNBOOK.md"
	} >"$d/docs/RUNBOOK.md.tmp" && mv -- "$d/docs/RUNBOOK.md.tmp" "$d/docs/RUNBOOK.md"
	rm -f -- "$d/docs/PROTOCOLS.md"
	unpoint "$d"
}

# A pre-17.0.0 light install whose owner followed its brief: the protocols and the playbooks
# folded into the constitution, no runbook, ledger or binding document.
make_historical_light_folded() { # <dir>
	local d=$1
	{
		printf '\n'
		awk '/^## Session discipline/ { p = 1 } p' "$d/docs/PROTOCOLS.md"
		printf '\n'
		section_of "$d/docs/RUNBOOK.md" 'Change-type playbooks'
		printf '\nFOLDED PLAYBOOK THE ADOPTER WROTE\n'
	} >>"$d/AGENTS.md"
	rm -f -- "$d/docs/PROTOCOLS.md" "$d/docs/RUNBOOK.md" "$d/docs/LEDGER.md"
	unpoint "$d"
}

# Sends every pointer to the binding document back to the runbook, which is where a
# pre-17.0.0 seed aimed them — the incident pointer and the doc-index row in their old words —
# and undoes the two configuration changes a pre-17.0.0 install never had.
unpoint() { # <dir>
	local d=$1 f
	# shellcheck disable=SC2016 # the backticks are Markdown code spans matched or written
	# literally; nothing in them is meant to expand. Scoped to this loop.
	for f in AGENTS.md docs/STATE.md docs/RUNBOOK.md; do
		[ -f "$d/$f" ] || continue
		sed_in_place 's#See `docs/PROTOCOLS.md` → \*\*Incident: leaked credential\*\*#See the incident playbook in `docs/RUNBOOK.md`#' "$d/$f"
		sed_in_place 's#docs/PROTOCOLS\.md#docs/RUNBOOK.md#g' "$d/$f"
	done
	if [ -f "$d/docs/RUNBOOK.md" ]; then
		# shellcheck disable=SC2016 # the backticks are Markdown code spans written literally.
		sed_in_place 's#| `docs/RUNBOOK.md` → \*\*Working-memory compression\*\* |#| this runbook → **Working-memory compression** |#' "$d/docs/RUNBOOK.md"
	fi
	sed_in_place "s# docs/PROTOCOLS.md##" "$d/amh.conf"
	sed_in_place 's#the review classes the Rule-review protocol already defines#the review classes already defined by docs/RUNBOOK.md#' \
		"$d/.codex/agents/amh-rule-reviewer.toml"
}

# The full check of one tree: layout, pointers, an installer re-run that reports nothing to
# migrate, and the tree's own ladder green.
assert_migrated() { # <label> <dir> [expected-playbooks-file]
	local label=$1 d=$2 out rc
	layout_check "$d" "${3:-}"
	if [ -z "$LAYOUT_PROBLEMS" ]; then pass; else fail "$label: the six sections live in docs/PROTOCOLS.md alone, complete" "$LAYOUT_PROBLEMS"; fi
	pointer_check "$d"
	if [ -z "$POINTER_PROBLEMS" ]; then pass; else fail "$label: every pointer destination resolves" "$POINTER_PROBLEMS"; fi
	out=$("$ROOT/scripts/amh-init.sh" "$d" 2>&1)
	if ! printf '%s' "$out" | grep -qF 'Migrate to docs/PROTOCOLS.md'; then pass; else fail "$label: a re-run reports nothing left to migrate" "$out"; fi
	out=$(target_ladder "$d")
	rc=$?
	if [ "$rc" -eq 0 ]; then pass; else fail "$label: the tree's own ladder is green" "exit $rc" "$out"; fi
}

# The checks themselves must be able to fail, or every case below is decoration. A dangling
# section pointer, a pointer to a file that is not there, a duplicated section and a truncated
# one, each planted in a copy of a fresh install.
d=$(target layout_negative)
"$ROOT/scripts/amh-init.sh" "$d" >/dev/null 2>&1
# shellcheck disable=SC2016 # the backticks are Markdown code spans matched or written
# literally; nothing in them is meant to expand.
printf '\nSee `docs/PROTOCOLS.md` → **No such section** and `docs/NOPE.md`.\n' >>"$d/AGENTS.md"
pointer_check "$d"
case $POINTER_PROBLEMS in
*"no heading 'No such section'"*"docs/NOPE.md: no such file"*) pass ;;
*) fail "the pointer check fails on a dangling section pointer and a missing file" "$POINTER_PROBLEMS" ;;
esac
section_of "$d/docs/PROTOCOLS.md" 'Rule-review protocol' >>"$d/docs/RUNBOOK.md"
sed_in_place '/^## Incident: leaked credential/,/^## /{/^1\. /d;}' "$d/docs/PROTOCOLS.md"
layout_check "$d"
case $LAYOUT_PROBLEMS in
*'RUNBOOK still carries a moved section'*'Incident: leaked credential is not the complete section'*) ;;
*'Incident: leaked credential is not the complete section'*'RUNBOOK still carries a moved section'*) ;;
*) LAYOUT_PROBLEMS="UNDETECTED: $LAYOUT_PROBLEMS" ;;
esac
case $LAYOUT_PROBLEMS in
UNDETECTED*) fail "the layout check fails on a duplicated section and a truncated one" "$LAYOUT_PROBLEMS" ;;
*) pass ;;
esac
d=$(target layout_negative_playbooks)
"$ROOT/scripts/amh-init.sh" "$d" >/dev/null 2>&1
awk '/^## Change-type playbooks/ { print; skip = 1; next } skip && /^## / { skip = 0 } !skip' \
	"$d/docs/RUNBOOK.md" >"$d/docs/RUNBOOK.md.tmp" && mv -- "$d/docs/RUNBOOK.md.tmp" "$d/docs/RUNBOOK.md"
layout_check "$d"
case $LAYOUT_PROBLEMS in
*'the playbooks are not the expected ones'*) pass ;;
*) fail "the layout check fails on a playbooks heading with nothing under it" "$LAYOUT_PROBLEMS" ;;
esac

# Fresh installs, both profiles, already have the layout.
assert_migrated "fresh standard" "$REF"
assert_migrated "fresh full" "$WORK/profile_full"

# A repeated install changes nothing and reports nothing.
d=$(target layout_repeat)
"$ROOT/scripts/amh-init.sh" "$d" >/dev/null 2>&1
before=$(cd "$d" && find AGENTS.md CLAUDE.md docs -type f | sort | xargs cat | cksum)
out=$("$ROOT/scripts/amh-init.sh" "$d" 2>&1)
after=$(cd "$d" && find AGENTS.md CLAUDE.md docs -type f | sort | xargs cat | cksum)
if [ "$before" = "$after" ] && ! printf '%s' "$out" | grep -qF 'Migrate to'; then
	pass
else
	fail "a repeated install leaves the prose untouched and reports nothing to migrate" "$out"
fi

# Historical standard and full installs: the re-run adds the binding document and keeps the
# old runbook, so the tree briefly holds two authorities — and the report must say so, naming
# the constitution that never mentions the new document. That is the case H3 names: a
# retained old constitution that never references the binding document must not pass quietly.
for p in standard full; do
	d=$(target "historical_$p")
	"$ROOT/scripts/amh-init.sh" --profile "$p" "$d" >/dev/null 2>&1
	make_historical_runbook "$d"
	out=$("$ROOT/scripts/amh-init.sh" "$d" 2>&1)
	if [ -f "$d/docs/PROTOCOLS.md" ] &&
		printf '%s' "$out" | grep -qF 'AGENTS.md never mentions docs/PROTOCOLS.md' &&
		printf '%s' "$out" | grep -qF 'docs/RUNBOOK.md still has a section that now lives elsewhere: Acceptance ladder, Adversarial review protocol, Incident: leaked credential, Rule-review protocol, Session discipline, Working-memory compression' &&
		printf '%s' "$out" | grep -qE 'docs/STATE\.md sends [0-9]+ pointer' &&
		printf '%s' "$out" | grep -qF 'amh.conf: RULE_FILES does not list docs/PROTOCOLS.md' &&
		printf '%s' "$out" | grep -qF '.codex/agents/amh-rule-reviewer.toml still sends its reviewer to docs/RUNBOOK.md'; then
		pass
	else
		fail "historical $p: the upgrade writes docs/PROTOCOLS.md and reports the unfinished migration" "$out"
	fi
	hand_migrate "$d" no yes
	assert_migrated "historical $p, migrated" "$d"
done
# ...and a migrated historical standard install still escalates cleanly.
d=$WORK/historical_standard
out=$("$ROOT/scripts/amh-init.sh" --profile full "$d" 2>&1)
if [ -f "$d/docs/history/README.md" ] && ! printf '%s' "$out" | grep -qF 'Migrate to'; then
	pass
else
	fail "a migrated historical install escalates to full with nothing to migrate" "$out"
fi

# A historical light install, folded as its brief said: a bare re-run is now an upgrade to
# standard, adding the runbook, the ledger and the binding document, and the report names the
# folded sections — the playbooks among them, which belong in the runbook now.
d=$(target historical_light_folded)
"$ROOT/scripts/amh-init.sh" "$d" >/dev/null 2>&1
make_historical_light_folded "$d"
out=$("$ROOT/scripts/amh-init.sh" "$d" 2>&1)
if [ -f "$d/docs/RUNBOOK.md" ] && [ -f "$d/docs/LEDGER.md" ] && [ -f "$d/docs/PROTOCOLS.md" ] &&
	printf '%s' "$out" | grep -qF '1 not in the standard profile' &&
	printf '%s' "$out" | grep -qF 'AGENTS.md never mentions docs/PROTOCOLS.md' &&
	printf '%s' "$out" | grep -qF 'AGENTS.md still has a section that now lives elsewhere: Acceptance ladder, Adversarial review protocol, Change-type playbooks, Incident: leaked credential'; then
	pass
else
	fail "historical light: a bare re-run upgrades to standard and reports the folded sections" "$out"
fi
# What the runbook must hold afterwards: the scaffold's playbooks as a fresh install has them,
# plus the one the owner wrote — the folded copy itself still points at the runbook until the
# migration's repointing step, so it is not the expectation.
{
	section_of "$REF/docs/RUNBOOK.md" 'Change-type playbooks'
	printf '\nFOLDED PLAYBOOK THE ADOPTER WROTE\n'
} >"$WORK/folded_playbooks.md"
hand_migrate "$d" yes yes
if grep -qF 'FOLDED PLAYBOOK THE ADOPTER WROTE' "$d/docs/RUNBOOK.md" &&
	! grep -qF 'FOLDED PLAYBOOK THE ADOPTER WROTE' "$d/AGENTS.md"; then
	pass
else
	fail "historical light: the adopter's folded playbook ends in the runbook, once"
fi
assert_migrated "historical light, migrated" "$d" "$WORK/folded_playbooks.md"

# A migration left half done — constitution and runbook repointed, state file not — is still
# reported, and the report names only what is left.
d=$(target historical_partial)
"$ROOT/scripts/amh-init.sh" "$d" >/dev/null 2>&1
make_historical_runbook "$d"
"$ROOT/scripts/amh-init.sh" "$d" >/dev/null 2>&1
hand_migrate "$d" no no
out=$("$ROOT/scripts/amh-init.sh" "$d" 2>&1)
if printf '%s' "$out" | grep -qE 'docs/STATE\.md sends [0-9]+ pointer' &&
	! printf '%s' "$out" | grep -qE '^ +(AGENTS\.md|docs/RUNBOOK\.md) '; then
	pass
else
	fail "a half-done migration is reported, naming only the state file" "$out"
fi

# The old pointer forms that are not "RUNBOOK → section" — the incident sentence and the
# runbook's doc-index row — and the two configuration steps: a migration that left only these
# undone must still be reported, each by name, or the report going quiet would call it done.
d=$(target historical_old_forms)
"$ROOT/scripts/amh-init.sh" "$d" >/dev/null 2>&1
make_historical_runbook "$d"
"$ROOT/scripts/amh-init.sh" "$d" >/dev/null 2>&1
hand_migrate "$d" no yes no
# shellcheck disable=SC2016 # the backticks are Markdown code spans written literally.
sed_in_place 's#See `docs/PROTOCOLS.md` → \*\*Incident: leaked credential\*\*#See the incident playbook in `docs/RUNBOOK.md`#' "$d/AGENTS.md"
# shellcheck disable=SC2016 # the backticks are Markdown code spans written literally.
sed_in_place 's#| `docs/PROTOCOLS.md` → \*\*Working-memory compression\*\* |#| this runbook → **Working-memory compression** |#' "$d/docs/RUNBOOK.md"
out=$("$ROOT/scripts/amh-init.sh" "$d" 2>&1)
if printf '%s' "$out" | grep -qF 'AGENTS.md sends 1 pointer(s) to the runbook' &&
	printf '%s' "$out" | grep -qF 'docs/RUNBOOK.md sends 1 pointer(s) to the runbook' &&
	printf '%s' "$out" | grep -qF 'amh.conf: RULE_FILES does not list docs/PROTOCOLS.md' &&
	printf '%s' "$out" | grep -qF '.codex/agents/amh-rule-reviewer.toml still sends its reviewer'; then
	pass
else
	fail "the old incident and doc-index pointer forms and both configuration steps are reported" "$out"
fi

# A binding document the adopter already had is kept, like any file of theirs, so it is its
# COMPLETENESS the report checks, not its presence.
d=$(target protocols_incomplete)
"$ROOT/scripts/amh-init.sh" "$d" >/dev/null 2>&1
section_of "$REF/docs/PROTOCOLS.md" 'Session discipline' >"$d/docs/PROTOCOLS.md"
out=$("$ROOT/scripts/amh-init.sh" "$d" 2>&1)
if printf '%s' "$out" | grep -qF 'docs/PROTOCOLS.md has no section for: Adversarial review protocol, Rule-review protocol, Incident: leaked credential, Acceptance ladder, Working-memory compression'; then
	pass
else
	fail "a kept, incomplete docs/PROTOCOLS.md is reported section by section" "$out"
fi

# Every seed file must be classified. An unclassified one is fatal, and the check is
# exercised here rather than trusted: a table with a catch-all would silently bucket a new
# seed file for every adopter (the D-025 shape).
h=$(harness_copy seed_unclassified)
: >"$h/harness/templates/seed/docs/UNCLASSIFIED.md"
out=$("$h/scripts/amh-init.sh" "$(target seed_unclassified_target)" 2>&1)
rc=$?
if [ "$rc" -ne 0 ] && printf '%s' "$out" | grep -qF 'no profile classification'; then
	pass
else
	fail "a seed file with no profile classification is fatal" "exit $rc" "$out"
fi

# =============================================================================
printf '\n%d passed, %d failed\n' "$PASSED" "$FAILED"
[ "$FAILED" -eq 0 ]
