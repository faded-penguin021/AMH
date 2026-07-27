#!/usr/bin/env bash
# AMH — THIS repository's toolchain bootstrap. Step 1 of P14's boot sequence.
#
# Repo-local by design and deliberately NOT shipped: scripts/session-start.sh is the
# agent-neutral boot sequence every adopter runs, and this is the one hook it leaves for
# the repo's own toolchain. An adopter's bootstrap installs whatever their product needs
# — a compiler, a package manager, nothing at all — so shipping ours would be shipping an
# opinion about their stack. session-start.sh calls this path when it exists.
#
# What it does, and why each part is here:
#
#   1. Puts ~/.local/bin on PATH, for this process and for the shells the session opens
#      afterwards. A child cannot edit its parent's environment, so the durable half is a
#      guarded block appended to ~/.bashrc.
#   2. Installs shellcheck there if it is not already runnable. shellcheck is CI-only by
#      constitutional carve-out, and the price of that carve-out is that its rung — the
#      one most often red in this repo's history — is invisible to a local ladder run, so
#      a session that edits a script without it is editing blind and finds out from CI
#      after the push (D-026). This closes that cost for every remote
#      session rather than relying on each one remembering a curl command.
#   3. Kicks off `git fetch origin <default>` in the background (P14's warm-up), because
#      the poison-token guard resolves that ref and checks NOTHING without it.
#
# Constraints this script is built to, all of them learned here:
#
#   · It runs ONLY when the remote-environment flag is set (session-start.sh gates it),
#     but nothing stops a laptop from invoking it by hand, so it never assumes a network
#     and never assumes curl.
#   · Idempotent, and instant when shellcheck is already present — no download, no
#     second copy of the PATH block.
#   · A failure is LOUD but NON-FATAL: it exits non-zero, session-start.sh prints that as
#     a warning, and the session continues. A boot hook that hard-fails the session is
#     worse than one that skips a tool — but a hook that skips SILENTLY is worse than
#     both, which is the whole shape of D-019.
#   · The downloaded binary must RUN before this reports success. A truncated download
#     that exits 0 is the silent-skip class this repo keeps rediscovering, and a
#     binary that does not execute would make verify.sh print `skip` forever.

set -uo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT" || exit 1

DEFAULT_BRANCH=main
# shellcheck source=/dev/null
[ -f "$ROOT/amh.conf" ] && . "$ROOT/amh.conf"

say() { printf '  %s\n' "$*"; }
# Every non-success line goes through this one, so the disabled state can never be
# quieter than the passing state by accident.
loud() { printf '  ! %s\n' "$*"; }

# Everything below is anchored on $HOME. Unset, `set -u` would abort with a raw bash
# diagnostic — a boot hook dying with `HOME: unbound variable` is the loud-but-useless
# end of the same spectrum as dying silently.
if [ -z "${HOME:-}" ]; then
	loud "HOME is not set, so there is no ~/.local/bin to install into — toolchain bootstrap SKIPPED. Not fatal; the session continues with shellcheck available only in CI."
	exit 1
fi

BIN_DIR="$HOME/.local/bin"
# Overridable so an air-gapped or mirrored environment can point at its own copy, and so
# the fixture suite can exercise the download path offline through a file:// URL. The
# default is the upstream release.
SHELLCHECK_URL=${AMH_SHELLCHECK_URL:-https://github.com/koalaman/shellcheck/releases/download/stable/shellcheck-stable.linux.x86_64.tar.xz}
# PID-qualified: a fixed name in a world-writable directory is both a collision between
# two sessions on one machine and a file another user can pre-create as a symlink.
WARMUP_LOG="${TMPDIR:-/tmp}/amh-warmup.$$.log"
PATH_MARKER='# AMH toolchain bootstrap: ~/.local/bin on PATH'

status=0

# --- 1. PATH ----------------------------------------------------------------
# This process first: everything below, and the `command -v` check in particular, must
# see a shellcheck installed by an earlier session.
case ":${PATH}:" in
*":$BIN_DIR:"*) ;;
*) PATH="$BIN_DIR:$PATH" ;;
esac
export PATH

persist_path() {
	local rc_file="$HOME/.bashrc"
	if [ ! -e "$rc_file" ] && ! : >"$rc_file" 2>/dev/null; then
		loud "cannot create $rc_file — $BIN_DIR is on PATH for this process only"
		return 1
	fi
	# The marker is what makes this idempotent: a re-run appends nothing, so a container
	# that boots twenty sessions ends with one block, not twenty.
	if grep -qF -- "$PATH_MARKER" "$rc_file" 2>/dev/null; then
		return 0
	fi
	# Single-quoted on purpose: the block must expand $HOME and $PATH when the future
	# shell reads it, not now.
	{
		printf '\n%s\n' "$PATH_MARKER"
		# shellcheck disable=SC2016 # scoped to this printf alone: the single quotes are
		# the point — $HOME and $PATH must expand when the future shell reads the block,
		# not when this script writes it.
		printf '%s\n' 'case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) PATH="$HOME/.local/bin:$PATH" ;; esac'
	} >>"$rc_file" || {
		loud "could not append the PATH block to $rc_file — $BIN_DIR is on PATH for this process only"
		return 1
	}
	say "PATH: added $BIN_DIR to $rc_file"
}

# --- 2. shellcheck ----------------------------------------------------------
# "Present" is not the question — `runs` is. A file called shellcheck that cannot
# execute (truncated download, wrong architecture, a directory of the same name) would
# satisfy `command -v` while verify.sh's rung stayed dark.
shellcheck_runs() { # [path]
	local sc=${1:-shellcheck}
	command -v -- "$sc" >/dev/null 2>&1 || return 1
	"$sc" --version 2>/dev/null | grep -q '^version:'
}

install_shellcheck() {
	if ! command -v curl >/dev/null 2>&1; then
		loud "shellcheck is missing and curl is not available — cannot install it. CI still runs the lint rung, so any finding will arrive from CI after the push, not from your ladder run."
		return 1
	fi
	# Announced only once the fetch is actually about to happen. Said before the curl
	# check, it claimed a download on a machine that has no way to perform one.
	say "shellcheck: downloading from $SHELLCHECK_URL"
	local tmp
	tmp=$(mktemp -d) || {
		loud "shellcheck install: could not create a temporary directory"
		return 1
	}
	local rc=0
	# One subshell so every early exit still reaches the cleanup below.
	(
		set -uo pipefail
		if ! curl -fsSL --connect-timeout 20 --max-time 300 -o "$tmp/sc.tar.xz" "$SHELLCHECK_URL"; then
			printf 'download failed from %s\n' "$SHELLCHECK_URL" >&2
			exit 1
		fi
		if ! tar -xJf "$tmp/sc.tar.xz" -C "$tmp" 2>/dev/null; then
			printf 'the downloaded archive did not extract — a truncated or partial fetch\n' >&2
			exit 1
		fi
		local found
		found=$(find "$tmp" -type f -name shellcheck -print -quit 2>/dev/null)
		if [ -z "$found" ]; then
			printf 'no shellcheck binary inside the archive\n' >&2
			exit 1
		fi
		chmod +x "$found" 2>/dev/null
		# Verified BEFORE anything is written to $BIN_DIR, so a bad download never
		# reaches the name the rest of the system resolves — not even briefly, and not
		# left behind for the next session to trust.
		#
		# It is deliberately paired with the post-install check below, and no fixture can
		# separate the two: whenever a runnable shellcheck is already installed this
		# function is never called at all, so "protects the existing binary" is not a
		# property that can be exercised. What each one actually does is distinct — this
		# one refuses to write, that one verifies what was written — and both are cheap.
		if ! "$found" --version 2>/dev/null | grep -q '^version:'; then
			printf 'the downloaded binary does not run (truncated, or built for another architecture)\n' >&2
			exit 1
		fi
		mkdir -p "$BIN_DIR" || exit 1
		# Copy then rename: an interrupted copy must not leave a half-written binary at
		# the name everything else resolves. PID-qualified because the staging name is
		# shared state too — two bootstraps racing on one $HOME used to have the loser
		# report a failure for an install that had in fact succeeded.
		cp "$found" "$BIN_DIR/.shellcheck.incoming.$$" || exit 1
		chmod 755 "$BIN_DIR/.shellcheck.incoming.$$" || exit 1
		mv "$BIN_DIR/.shellcheck.incoming.$$" "$BIN_DIR/shellcheck" || exit 1
	) 2>&1 | sed 's/^/    /'
	rc=${PIPESTATUS[0]}
	rm -rf "$tmp"
	[ "$rc" -eq 0 ] || return 1

	# ...and the INSTALLED copy, which is the one every later run resolves. Reporting
	# success on the strength of a binary in a temporary directory would be reporting on
	# something that no longer exists.
	if ! shellcheck_runs "$BIN_DIR/shellcheck"; then
		loud "shellcheck was installed to $BIN_DIR but does not run there — treat the lint rung as CI-only for this session"
		# Re-checked immediately before removal rather than deleted outright: between the
		# verdict above and this line a concurrent bootstrap may have replaced the file
		# with a working one, and deleting THAT would turn one session's failure into
		# everybody's.
		shellcheck_runs "$BIN_DIR/shellcheck" || rm -f "$BIN_DIR/shellcheck"
		return 1
	fi
	return 0
}

# --- 3. background warm-up (P14) --------------------------------------------
# `origin/$DEFAULT_BRANCH` is what guard_poison_tokens diffs against; without it that
# guard checks nothing and says so. Fetching it here means the first ladder run of the
# session does not pay for it serially while the agent is still reading docs.
#
# Synchronisation is git's own — its ref and index locks — not a sentinel file this
# script would have to invent and keep in step. A ladder run that overlaps the fetch
# queues behind those locks, which costs the same wall time as waiting would.
#
# Every branch here SAYS which one it took. The first draft announced the fetch
# unconditionally, after redirects that could fail: with an unwritable log directory the
# redirection failed, `git fetch` never ran, and the line still reported a fetch in
# flight — a boot step claiming work it had not done, which is the reporting half of the
# same defect as skipping quietly.
warm_up() {
	if ! git rev-parse --git-dir >/dev/null 2>&1; then
		say "warm-up: not a git repository — nothing to fetch"
		return 0
	fi
	if ! git remote get-url origin >/dev/null 2>&1; then
		say "warm-up: no 'origin' remote — skipping the background fetch of $DEFAULT_BRANCH"
		return 0
	fi
	# The log is opened HERE, where the failure can be reported, rather than in the
	# background job's redirection, where it would be invisible.
	if ! : >"$WARMUP_LOG" 2>/dev/null; then
		loud "warm-up: cannot write $WARMUP_LOG — the background fetch of origin/$DEFAULT_BRANCH was NOT started. The poison-token guard warns on its own if the ref is missing."
		return 0
	fi
	git fetch --quiet origin "$DEFAULT_BRANCH" >>"$WARMUP_LOG" 2>&1 &
	say "warm-up: fetching origin/$DEFAULT_BRANCH in the background (pid $!, log: $WARMUP_LOG). If it fails, the poison-token guard says so on its own."
}

# =============================================================================
persist_path || status=1

if shellcheck_runs; then
	say "shellcheck: $(shellcheck --version 2>/dev/null | sed -n 's/^version: //p') already installed at $(command -v shellcheck)"
else
	say "shellcheck: not installed (the lint rung is invisible locally without it)"
	if install_shellcheck; then
		say "shellcheck: $(shellcheck --version 2>/dev/null | sed -n 's/^version: //p') installed at $BIN_DIR/shellcheck"
	else
		loud "shellcheck install FAILED — the ladder's lint rung will print \`skip\` locally and only CI will see it. Not fatal; the session continues."
		status=1
	fi
fi

warm_up

exit "$status"
