#!/usr/bin/env bash
# Repo-local guard: this instance's amh.conf carries every key the shipped
# amh.conf.example declares.
#
# The reference instance and the template drift in one direction that matters: a key
# added to harness/templates/amh.conf.example is a key adopters will set, and if this
# repo does not also set it, the repo that PRODUCES the harness is the one running an
# incomplete configuration — while every guard here keeps passing, because each shipped
# script defaults its own keys in-script.
#
# ONE-DIRECTIONAL ON PURPOSE. Extra keys in amh.conf are legal and expected:
# AUTHOR_EMAIL_ALLOW is deliberately absent from the example (it is opt-in, and an
# example value would invite adopters to paste an allowlist they have not thought about),
# yet this repo sets it. A guard that also failed on extras would have to be taught about
# every opt-in key, and would fail the instance for using a feature correctly.
#
# NOT SHIPPED, and that is the finding rather than an omission. An adopter's tree has no
# amh.conf.example to compare against — the installer renders their amh.conf and does not
# leave the template behind — and the shipped scripts default every key they read, so a
# missing key is a SUPPORTED state there, not drift. Shipping this check would fail
# adopters for a condition their harness explicitly permits. The adopter-facing half is
# prose in docs/UPGRADING.md, which diffs their key set against the release they cloned.
# See DA-022. (A real citation, hyphen and all: this guard is repo-local and the row is
# ours, so the ladder can and must check that it resolves. The unhyphenated `DANNN` form
# belongs only in SHIPPED scripts, where the row can never exist in the adopter's ledger.)
#
#   scripts/guards/config-schema.sh

set -uo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." || exit 1

EXAMPLE=harness/templates/amh.conf.example
INSTANCE=amh.conf

for f in "$EXAMPLE" "$INSTANCE"; do
	[ -f "$f" ] || {
		printf '%s is missing — there is nothing to compare\n' "$f"
		exit 1
	}
done

# Assignments at the start of a line only. A key named inside a comment, a heredoc or
# prose is documentation, not configuration, and the example file is mostly prose.
keys() { sed -n 's/^\([A-Za-z_][A-Za-z0-9_]*\)=.*/\1/p' "$1" | sort -u; }

# A guard that cannot run must be LOUDER than one that passes (D-019). Without these two
# checks this script reports a cheerful green in both of the ways it can be hollow: no
# `comm` on PATH leaves `missing` empty and the `if` below skipped, and an EXAMPLE that
# yields no keys at all — emptied, renamed, or restyled so the pattern no longer matches —
# compares nothing against nothing and calls it agreement. version-lockstep.sh, the guard
# this one is modelled on, refuses the same zero-extraction case for the same reason.
command -v comm >/dev/null 2>&1 || {
	printf 'comm is not on PATH — this guard checked NOTHING. Install coreutils or remove the guard; do not read this as a pass.\n'
	exit 1
}

example_keys=$(keys "$EXAMPLE")
[ -n "$example_keys" ] || {
	printf 'no KEY= assignments found in %s (the guard pattern and the file have diverged — fix whichever is wrong)\n' "$EXAMPLE"
	exit 1
}

missing=$(comm -23 <(printf '%s\n' "$example_keys") <(keys "$INSTANCE")) || {
	printf 'comm failed comparing %s against %s — this guard checked NOTHING\n' "$EXAMPLE" "$INSTANCE"
	exit 1
}

if [ -n "$missing" ]; then
	printf 'amh.conf is missing key(s) the shipped example declares:\n'
	# shellcheck disable=SC2086  # split on purpose: one key per line
	printf '  %s\n' $missing
	printf 'Set them in amh.conf, or remove them from %s if they are no longer part of the contract.\n' "$EXAMPLE"
	exit 1
fi

printf 'amh.conf carries all %s key(s) from the shipped example\n' "$(printf '%s\n' "$example_keys" | wc -l | tr -d ' ')"
