#!/usr/bin/env bash
# Fixture suite for this repo's OWN guards (scripts/guards/*.sh).
#
# The shipped fixture suite (scripts/test-ladder-guards.sh) is byte-compared against
# its template, so repo-local fixtures cannot live there — putting them there would
# contaminate the repo-agnostic artifact, which is the thing copy-drift.sh exists to
# prevent. They live here instead, run from scripts/verify.sh, which is the ladder's
# repo-owned extension point.
#
# Until this file existed, every repo-local guard shipped untested while the
# constitution demanded a fixture for each — the rule was unsatisfiable as written.
#
# Method: snapshot the working tree into a throwaway git repo, break exactly one
# thing, and assert the guard's verdict. Never mutate the real tree — a suite that
# leaves the repo dirty when interrupted is worse than no suite.

set -uo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

export GIT_AUTHOR_NAME=amh-test GIT_AUTHOR_EMAIL=amh@test.invalid
export GIT_COMMITTER_NAME=amh-test GIT_COMMITTER_EMAIL=amh@test.invalid

PASSED=0
FAILED=0

snapshot() { # snapshot <name> -> prints the path
	local d="$WORK/$1"
	mkdir -p "$d"
	(cd "$ROOT" && git ls-files -co --exclude-standard -z | tar -cf - --null -T -) |
		(cd "$d" && tar -xf -)
	(
		cd "$d" || exit 1
		git init -q .
		git add -A
		git commit -qm snapshot
	)
	printf '%s' "$d"
}

expect() { # expect <pass|fail> <name> <dir> <guard> [message-substring]
	local want=$1 name=$2 dir=$3 guard=$4 want_msg=${5:-}
	local out rc
	# shellcheck disable=SC2086  # $guard may carry arguments, e.g. "x.sh --tag v1"
	out=$(cd "$dir" && bash scripts/guards/$guard 2>&1)
	rc=$?
	if [ "$want" = pass ] && [ "$rc" -ne 0 ]; then
		FAILED=$((FAILED + 1))
		printf '  FAIL %s — expected pass, got %d\n%s\n' "$name" "$rc" "$out" >&2
	elif [ "$want" = fail ] && [ "$rc" -eq 0 ]; then
		FAILED=$((FAILED + 1))
		printf '  FAIL %s — expected failure, guard passed\n%s\n' "$name" "$out" >&2
	elif [ -n "$want_msg" ] && ! printf '%s' "$out" | grep -qF "$want_msg"; then
		FAILED=$((FAILED + 1))
		printf '  FAIL %s — verdict right but message never mentioned %s\n%s\n' "$name" "$want_msg" "$out" >&2
	else
		PASSED=$((PASSED + 1))
	fi
}

printf 'repo-local guard fixtures\n'

base=$(snapshot base)
expect pass "copy-drift: clean tree" "$base" copy-drift.sh
expect pass "dist-drift: clean tree" "$base" dist-drift.sh
expect pass "placeholder-integrity: clean tree" "$base" placeholder-integrity.sh
expect pass "version-lockstep: clean tree" "$base" version-lockstep.sh
expect pass "path-refs: clean tree" "$base" path-refs.sh
expect pass "manifest-drift: clean tree" "$base" manifest-drift.sh
expect pass "adapter-set: clean tree" "$base" adapter-set.sh
expect pass "doc-navigation: clean tree" "$base" doc-navigation.sh

d=$(snapshot doc_navigation_missing)
sed -i 's/^## Acceptance ladder$/## Verification ladder/' "$d/docs/RUNBOOK.md"
expect fail "doc-navigation: a binding heading was renamed" "$d" doc-navigation.sh "missing navigation heading"

d=$(snapshot doc_navigation_duplicate)
printf '\n## Acceptance ladder\n' >>"$d/docs/RUNBOOK.md"
expect fail "doc-navigation: a binding heading was duplicated" "$d" doc-navigation.sh "duplicate navigation heading"

d=$(snapshot doc_navigation_pointer_missing)
sed -i 's/^- Verification and locally unverifiable coverage:/- Local verification:/' "$d/AGENTS.md"
expect fail "doc-navigation: a binding constitution pointer was renamed" "$d" doc-navigation.sh "missing navigation pointer"

d=$(snapshot drift_script)
printf '# local edit\n' >>"$d/scripts/redact.sh"
expect fail "copy-drift: an edited shipped script" "$d" copy-drift.sh "drift:"

d=$(snapshot drift_missing)
rm "$d/scripts/session-start.sh"
expect fail "copy-drift: a shipped script not installed" "$d" copy-drift.sh "not installed here"

# The manifest is a shipped artifact that is not a *.sh file, and the copy-drift glob used to
# stop at the extension. That gap is not cosmetic: this repo's copy of the manifest could
# drift from the one adopters receive while the guard's own line said the shipped set was
# identical.
d=$(snapshot drift_manifest_copy)
printf '# a local edit\n' >>"$d/scripts/MANIFEST.sha256"
expect fail "copy-drift: an edited shipped file that is not a script" "$d" copy-drift.sh "drift:"

# The failure that reaches an adopter rather than us: a shipped script edited without
# regenerating the manifest publishes hashes for bytes nobody has. Their next upgrade then
# reports every script the harness sent them as locally edited.
d=$(snapshot drift_manifest_stale)
printf '\n# an upstream change\n' >>"$d/harness/templates/scripts/session-start.sh"
expect fail "manifest-drift: a shipped script changed without a rebuild" "$d" manifest-drift.sh "stale or hand-edited"

d=$(snapshot drift_manifest_edited)
sed -i 's/^[0-9a-f]\{64\}/0000000000000000000000000000000000000000000000000000000000000000/' \
	"$d/harness/templates/scripts/MANIFEST.sha256"
expect fail "manifest-drift: a hand-edited manifest" "$d" manifest-drift.sh "stale or hand-edited"

d=$(snapshot drift_manifest_gone)
rm "$d/harness/templates/scripts/MANIFEST.sha256"
expect fail "manifest-drift: no manifest at all" "$d" manifest-drift.sh "has not been built"

# The adapter set is declared in the guard rather than inferred from whichever files happen
# to remain. These Codex mutations prove that each independent delivery layer is live:
# reference path, installer action, and both legislation values. Removing a whole adapter
# cannot make the expected set shrink along with it.
d=$(snapshot adapter_codex_path_gone)
rm "$d/.codex/config.toml"
expect fail "adapter-set: a Codex reference path was removed" "$d" adapter-set.sh ".codex/config.toml"

d=$(snapshot adapter_codex_install_gone)
sed -i '\|codex-config.toml.*\.codex/config.toml|d' "$d/scripts/amh-init.sh"
expect fail "adapter-set: a Codex install action was removed" "$d" adapter-set.sh "install action missing"

d=$(snapshot adapter_codex_legislation_gone)
sed -i 's/ \.codex\/config\.toml//' "$d/harness/templates/amh.conf.example"
expect fail "adapter-set: a Codex legislation entry was removed" "$d" adapter-set.sh "adopter RULE_FILES"

d=$(snapshot adapter_codex_reference_legislation_gone)
sed -i 's/ \.codex\/config\.toml//' "$d/amh.conf"
expect fail "adapter-set: a Codex reference legislation entry was removed" "$d" adapter-set.sh "reference RULE_FILES"

d=$(snapshot drift_dist)
printf 'hand edit\n' >>"$d/harness/dist/AMH.md"
expect fail "dist-drift: a hand-edited bundle" "$d" dist-drift.sh "stale or hand-edited"

d=$(snapshot drift_src)
printf '\nnew prose\n' >>"$d/harness/src/40-adaptation.md"
expect fail "dist-drift: sources changed without a rebuild" "$d" dist-drift.sh "stale or hand-edited"

d=$(snapshot ph_undocumented)
# Assembled at runtime: a stored placeholder literal would make this file fail the
# guard it is testing (the D-004 class — fixtures must never be stored literals).
printf '{{%s}}\n' TOTALLY_NEW_KNOB >>"$d/harness/templates/seed/CLAUDE.md"
expect fail "placeholders: undocumented" "$d" placeholder-integrity.sh "not documented"

d=$(snapshot ph_unfilled)
printf '{{%s}}\n' PROJECT_NAME >>"$d/docs/STATE.md"
expect fail "placeholders: left unfilled in a live file" "$d" placeholder-integrity.sh "unfilled placeholder"

d=$(snapshot ver_bump)
printf '1.9.0\n' >"$d/harness/VERSION"
expect fail "version-lockstep: VERSION bumped alone" "$d" version-lockstep.sh "harness/VERSION says 1.9.0"

d=$(snapshot ver_conf)
sed -i 's/^AMH_VERSION=.*/AMH_VERSION=1.7.0/' "$d/amh.conf"
expect fail "version-lockstep: amh.conf drifted" "$d" version-lockstep.sh "amh.conf"

d=$(snapshot ver_tag)
expect fail "version-lockstep: a tag that does not match" "$d" "version-lockstep.sh --tag amh-v9.9.9" "does not match"

# The README's quickstart pins a release tag, so it is a fifth hand-written copy. Two arms,
# because they fail for different reasons and one message would leave the other untested: a
# tag naming the WRONG version, and a quickstart with no pin at all — which is the state the
# README was in before this check existed, and the one a careless edit returns it to.
# The expected substring is the DRIFT verdict, not the label. `README quickstart tag` prefixes
# every message check() can emit, so asserting it would be satisfied by an implementation that
# cannot tell a drifted pin from a missing one — a review pass built exactly that and both arms
# still passed.
d=$(snapshot ver_readme)
sed -i 's/--branch amh-v[0-9][0-9.]*/--branch amh-v0.1.0/' "$d/README.md"
expect fail "version-lockstep: README pins the wrong release tag" "$d" version-lockstep.sh "README.md says 0.1.0"

d=$(snapshot ver_readme_gone)
sed -i 's/--branch amh-v[0-9][0-9.]*//' "$d/README.md"
expect fail "version-lockstep: README quickstart lost its pin" "$d" version-lockstep.sh "no version found"

d=$(snapshot refs_broken)
printf '\nSee [the plan](docs/NOTHING_HERE.md).\n' >>"$d/docs/RUNBOOK.md"
expect fail "path-refs: a broken relative link" "$d" path-refs.sh "broken link"

d=$(snapshot refs_backtick)
# shellcheck disable=SC2016 # the backticks are the fixture: path-refs.sh only sees a
# citation inside a markdown code span, so expanding them would delete what is on trial.
printf '\nRun `scripts/does-not-exist.sh` first.\n' >>"$d/docs/RUNBOOK.md"
expect fail "path-refs: a cited path that does not exist" "$d" path-refs.sh "nonexistent path"

# A file name with a space: `for f in $files` word-splits it away, and the guard then
# prints a resolved count and a green line for a file it never opened.
d=$(snapshot refs_spacey)
# shellcheck disable=SC2016 # literal backticks: same fixture form as above.
printf 'See `docs/NOTHING_HERE.md` for the details.\n' >"$d/notes with space.md"
expect fail "path-refs: a bad ref in a file name with a space" "$d" path-refs.sh "nonexistent path"

# The docs/plans exclusion is a hole by design (a plan may name what it has not built).
# It is bounded to that directory and asserted here so the boundary is a tested one.
d=$(snapshot refs_plans_excluded)
mkdir -p "$d/docs/plans"
# shellcheck disable=SC2016 # literal backticks: same fixture form as above.
printf 'Build `scripts/does-not-exist.sh` next.\n' >"$d/docs/plans/future.md"
expect pass "path-refs: a plan may name a path it has not built yet" "$d" path-refs.sh

# A bare filename with no slash. The backtick pattern required an embedded slash, so a
# repo-ROOT file could not match it and a citation to one could never fail — which is how
# CONTRIBUTING.md stayed cited five times while absent, inside the guard admitted to close
# that incident.
d=$(snapshot refs_bare_missing)
# shellcheck disable=SC2016 # literal backticks: same fixture form as above.
printf '\nRead `NOTHING_HERE.md` first.\n' >>"$d/docs/RUNBOOK.md"
expect fail "path-refs: a cited bare filename that exists nowhere" "$d" path-refs.sh "no file by that name"

# The other half, and the reason bare names resolve by BASENAME rather than from the repo
# root: the prose says `STATE.md`, never `docs/STATE.md`. A root-relative test would call
# that broken, and a guard that cries wolf on the house style gets ignored — which is why
# the root-relative widening was rejected at 24 hits for 2 true positives.
d=$(snapshot refs_bare_subdir)
# shellcheck disable=SC2016 # literal backticks: same fixture form as above.
printf '\nRead `STATE.md` first.\n' >>"$d/docs/RUNBOOK.md"
expect pass "path-refs: a bare filename resolves from a subdirectory" "$d" path-refs.sh

# The match must be WHOLE-LINE. Dropping `-x` left every fixture above green while
# `TATE.md` and `adder.sh` resolved as substrings of real basenames — a citation to a
# file that does not exist, reported as resolving, which is the entire failure this
# section was added to stop.
d=$(snapshot refs_bare_substring)
# shellcheck disable=SC2016 # literal backticks: same fixture form as above.
printf '\nRead `TATE.md` first.\n' >>"$d/docs/RUNBOOK.md"
expect fail "path-refs: a bare name that is only a substring of a real file" "$d" path-refs.sh "no file by that name"

# `git ls-files` answers from the index, so a file removed with plain `rm` is still listed.
# Resolving against that made a citation to a deleted file read as resolving.
# `amh.conf` rather than a `.md` file: deleting one of the scanned documents would also
# trip sections (a) and (b), so the fixture could pass without section (c) working.
d=$(snapshot refs_bare_deleted)
rm "$d/amh.conf"
expect fail "path-refs: a bare name whose file was deleted but is still in the index" "$d" path-refs.sh "no file by that name"

# --- scripts/bootstrap.sh ----------------------------------------------------
# Not a guard, so it gets its own runner rather than `expect`. It is repo-local for the
# same reason the guards above are: session-start.sh is the shipped, agent-neutral boot
# sequence, and this is the hook it leaves for whatever toolchain the repo happens to
# need. That makes this file its only possible fixture home.
#
# Every case here runs OFFLINE, by construction. The download goes through a `file://`
# URL at a tarball this suite builds, and the binary inside it is a five-line shell
# script — not a copy of the real shellcheck, which would make the fixtures depend on
# the very tool bootstrap.sh exists to install (D-024: a fixture must satisfy its
# predicate by construction, never usually).

# A PATH with no shellcheck on it. Without one, CI — which apt-installs shellcheck to
# /usr/bin — would take bootstrap's already-present fast path in every case below and the
# download half would be tested by nothing, green.
#
# It is CONSTRUCTED, one directory of symlinks to the tools bootstrap.sh actually uses,
# and never `shellcheck`. The obvious form is to subtract instead — walk $PATH and drop
# any directory holding a shellcheck — and it is wrong for a reason worth recording: on
# CI that deletes /usr/bin, and /bin with it (a symlink to usr/bin), so the surviving
# PATH has no bash, curl, tar, git or grep and every case here dies at exit 127. It
# passes on a machine where shellcheck happens to live somewhere uninteresting, which is
# not a property of the fixture at all — it is a property of the box.
bs_shim() { # bs_shim <dir> <tool>... — a directory holding exactly these tools
	local dir=$1 t p
	shift
	mkdir -p "$dir"
	for t in "$@"; do
		p=$(command -v "$t" 2>/dev/null) || continue
		[ -n "$p" ] && ln -sf "$p" "$dir/$t"
	done
}
BS_PATH="$WORK/bs_shim"
bs_shim "$BS_PATH" bash sh env curl tar xz mktemp find grep sed chmod cp mv rm mkdir dirname cat git
# The same set minus curl. `curl` is NOT in the harness's baseline toolchain (AGENTS.md
# names bash, git and coreutils), so bootstrap.sh treats its absence as a supported,
# non-fatal outcome — and that branch deserves a fixture more than it deserves an
# assumption.
BS_PATH_NOCURL="$WORK/bs_shim_nocurl"
bs_shim "$BS_PATH_NOCURL" bash sh env tar xz mktemp find grep sed chmod cp mv rm mkdir dirname cat git

bs_tarball() { # bs_tarball <absolute-out.tar.xz> <script-body>
	local out=$1 body=$2 t
	t=$(mktemp -d) || return 1
	mkdir -p "$t/shellcheck-stable"
	printf '%s' "$body" >"$t/shellcheck-stable/shellcheck"
	chmod +x "$t/shellcheck-stable/shellcheck"
	(cd "$t" && tar -cJf "$out" shellcheck-stable)
	rm -rf "$t"
}

BS_OUT=''
BS_RC=0
bs_env_run() { # bs_env_run <repo-dir> <home> <url> <path> [VAR=VAL...]
	local d=$1 home=$2 url=$3 path=$4
	shift 4
	BS_OUT=$(env HOME="$home" PATH="$path" AMH_SHELLCHECK_URL="$url" "$@" bash "$d/scripts/bootstrap.sh" 2>&1)
	BS_RC=$?
}
bs_run() { bs_env_run "$1" "$2" "$3" "$BS_PATH"; }

bs_expect() { # bs_expect <pass|fail> <name> <message-substring>
	local want=$1 name=$2 want_msg=$3
	if [ "$want" = pass ] && [ "$BS_RC" -ne 0 ]; then
		FAILED=$((FAILED + 1))
		printf '  FAIL %s — expected exit 0, got %d\n%s\n' "$name" "$BS_RC" "$BS_OUT" >&2
	elif [ "$want" = fail ] && [ "$BS_RC" -eq 0 ]; then
		FAILED=$((FAILED + 1))
		printf '  FAIL %s — expected a non-zero exit, got 0\n%s\n' "$name" "$BS_OUT" >&2
	elif ! printf '%s' "$BS_OUT" | grep -qF "$want_msg"; then
		FAILED=$((FAILED + 1))
		printf '  FAIL %s — verdict right but the output never mentioned %s\n%s\n' "$name" "$want_msg" "$BS_OUT" >&2
	else
		PASSED=$((PASSED + 1))
	fi
}

bs_check() { # bs_check <name> <description> <test-expression...>
	local name=$1
	shift
	if "$@"; then
		PASSED=$((PASSED + 1))
	else
		FAILED=$((FAILED + 1))
		printf '  FAIL %s\n' "$name" >&2
	fi
}

d=$(snapshot bootstrap)
# shellcheck disable=SC2016 # scoped to this one call: the body is a script this suite
# WRITES, so `$1` must survive into the file and be expanded by the fixture binary when
# bootstrap.sh runs it — expanding it here would delete what is on trial.
bs_tarball "$d/good.tar.xz" '#!/bin/sh
[ "$1" = --version ] && printf "version: 0.0.0-fixture\n"
exit 0
'
# The silent-skip class in its purest form: a "binary" that installs, runs and exits 0
# while being nothing at all. `command -v` is satisfied, an exit-status check is
# satisfied, and the ladder's lint rung would print skip forever.
bs_tarball "$d/mute.tar.xz" '#!/bin/sh
exit 0
'

# The install cases need curl, and curl is outside the baseline toolchain. Gated rather
# than assumed — and gated LOUDLY, with the count of what was skipped, because a suite
# that quietly runs four fewer cases on some machines is the same defect as a guard that
# quietly checks nothing. The curl-free branch below runs either way.
if [ -e "$BS_PATH/curl" ]; then
	h="$WORK/bs_home_ok"
	mkdir -p "$h"
	bs_run "$d" "$h" "file://$d/good.tar.xz"
	bs_expect pass "bootstrap: a good download installs shellcheck" "installed at"
	bs_check "bootstrap: the installed binary is the one later runs resolve" \
		test -x "$h/.local/bin/shellcheck"
	bs_check "bootstrap: the PATH block reaches the shells the session opens" \
		grep -qF 'AMH toolchain bootstrap' "$h/.bashrc"

	# Second run against a URL that cannot resolve: passing PROVES no download was
	# attempted, which is what "idempotent and fast when shellcheck is already present"
	# means operationally. The marker count proves the ~/.bashrc block is written once,
	# not once per session — a container that boots twenty sessions must not end with
	# twenty blocks.
	bs_run "$d" "$h" "file://$d/does-not-exist.tar.xz"
	bs_expect pass "bootstrap: a second run downloads nothing" "already installed"
	bs_check "bootstrap: the PATH block is appended exactly once" \
		test "$(grep -c 'AMH toolchain bootstrap' "$h/.bashrc")" = 1

	h="$WORK/bs_home_mute"
	mkdir -p "$h"
	bs_run "$d" "$h" "file://$d/mute.tar.xz"
	bs_expect fail "bootstrap: a binary that exits 0 without being shellcheck is rejected" "install FAILED"
	bs_check "bootstrap: a rejected binary is not left behind for the next run to trust" \
		test ! -e "$h/.local/bin/shellcheck"

	h="$WORK/bs_home_nonet"
	mkdir -p "$h"
	bs_run "$d" "$h" "file://$d/no-such-file.tar.xz"
	bs_expect fail "bootstrap: an unfetchable URL is loud" "install FAILED"
else
	printf '  SKIP 6 bootstrap install case(s): curl is not on this machine, and the install path cannot run without it\n' >&2
fi

# manifest-drift with no hashing tool on PATH. The shim above holds a fixed tool list and
# never a hasher, so this is the one condition under which the guard's rebuild cannot happen —
# and it must say THAT rather than reporting a stale manifest, which is what a diff against a
# generator that produced nothing looks like. Placed here because BS_PATH is built above.
out=$(cd "$base" && env PATH="$BS_PATH" bash scripts/guards/manifest-drift.sh 2>&1)
rc=$?
if [ "$rc" -ne 0 ] && printf '%s' "$out" | grep -qF 'this guard checked NOTHING'; then
	PASSED=$((PASSED + 1))
else
	FAILED=$((FAILED + 1))
	printf '  FAIL manifest-drift: a missing hasher is named, not reported as drift — rc=%s\n%s\n' "$rc" "$out" >&2
fi

h="$WORK/bs_home_nocurl"
mkdir -p "$h"
bs_env_run "$d" "$h" "file://$d/good.tar.xz" "$BS_PATH_NOCURL"
bs_expect fail "bootstrap: no curl is a loud, non-fatal outcome" "curl is not available"

# --- the P14 warm-up ---------------------------------------------------------
# Uncovered entirely until these: `snapshot` creates no remote, so every case above takes
# warm_up's early return and replacing the whole function with `:` left the suite green.
# Each case here installs a working fixture shellcheck into $HOME first, so bootstrap
# takes the fast path and the warm-up is the only thing under test.
bs_ready_home() { # bs_ready_home <home>
	mkdir -p "$1/.local/bin"
	# shellcheck disable=SC2016 # scoped to this printf: `$1` belongs to the script being
	# written, not to this function.
	printf '%s\n' '#!/bin/sh' '[ "$1" = --version ] && printf "version: 0.0.0-fixture\n"' 'exit 0' \
		>"$1/.local/bin/shellcheck"
	chmod +x "$1/.local/bin/shellcheck"
}

h="$WORK/bs_home_warm_noremote"
bs_ready_home "$h"
bs_run "$d" "$h" "file://$d/good.tar.xz"
bs_expect pass "warm-up: a repo with no origin says so instead of going quiet" "no 'origin' remote"

# A bare remote on the local filesystem, so the fetch is real but never touches a network.
bs_remote="$WORK/bs_remote.git"
git init -q --bare "$bs_remote"
dw=$(snapshot bootstrap_warm)
bs_branch=$(sed -n 's/^DEFAULT_BRANCH=//p' "$dw/amh.conf")
(
	cd "$dw" || exit 1
	git remote add origin "$bs_remote"
	git push -q origin "HEAD:refs/heads/$bs_branch"
	# The push creates the tracking ref; delete it, so its REAPPEARANCE is the evidence
	# that the warm-up ran rather than something the fixture set up itself.
	git update-ref -d "refs/remotes/origin/$bs_branch" 2>/dev/null
)

bs_no_ref() { # bs_no_ref <dir> <ref>
	! (cd "$1" && git rev-parse --verify --quiet "$2" >/dev/null 2>&1)
}

# A bounded WAIT, not a probabilistic predicate — the distinction D-024 turns on. The
# remote is a bare repository on this filesystem holding one commit, so the only thing
# being waited for is a `git fetch` process starting and exiting; there is no draw, no
# distribution and no tail. The ceiling exists so a hung fetch fails LOUDLY instead of
# hanging the suite, and it is three orders of magnitude past what a local fetch costs.
bs_await_ref() { # bs_await_ref <dir> <ref>
	local i=0
	while [ "$i" -lt 600 ]; do
		(cd "$1" && git rev-parse --verify --quiet "$2" >/dev/null 2>&1) && return 0
		sleep 0.1
		i=$((i + 1))
	done
	return 1
}

# An unwritable log directory. The first draft opened the log inside the background job's
# redirection, so this case printed a line announcing a fetch that had never started.
h="$WORK/bs_home_warm_nolog"
bs_ready_home "$h"
bs_env_run "$dw" "$h" "file://$d/good.tar.xz" "$BS_PATH" TMPDIR="$WORK/no/such/dir"
bs_expect pass "warm-up: an unwritable log is reported, not papered over" "was NOT started"
bs_check "warm-up: and no fetch is claimed when none was started" \
	bs_no_ref "$dw" "refs/remotes/origin/$bs_branch"

h="$WORK/bs_home_warm_ok"
bs_ready_home "$h"
bs_env_run "$dw" "$h" "file://$d/good.tar.xz" "$BS_PATH"
bs_expect pass "warm-up: an origin remote is fetched in the background" "in the background"
bs_check "warm-up: and the ref the poison-token guard needs actually lands" \
	bs_await_ref "$dw" "refs/remotes/origin/$bs_branch"

printf '\n%d passed, %d failed\n' "$PASSED" "$FAILED"
[ "$FAILED" -eq 0 ]
