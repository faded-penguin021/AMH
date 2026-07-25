#!/usr/bin/env bash
# Repo-local guard: this repo runs the scripts it ships, byte for byte.
#
# The meta-repo's claim is that it is the harness's reference instance. That claim is
# worth exactly as much as its enforcement: without this check, scripts/ and
# harness/templates/scripts/ drift, and the repo ships artifacts it does not actually
# execute — the failure mode the whole repo exists to rule out (D-001, D-002).
#
# It works only because the shipped scripts are repo-agnostic: values come from
# amh.conf, extra guards from scripts/guards/, the verification set from
# scripts/verify.sh (D-003). Needing to edit a shipped script locally means an
# extension point is missing — add it upstream in the template, not here.

set -uo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." || exit 1

SRC=harness/templates/scripts
DST=scripts
fails=0

for t in "$SRC"/*.sh; do
	name=$(basename "$t")
	if [ ! -f "$DST/$name" ]; then
		printf 'shipped but not installed here: %s (this repo must run what it ships)\n' "$name"
		fails=$((fails + 1))
		continue
	fi
	if ! cmp -s "$t" "$DST/$name"; then
		printf 'drift: %s differs from %s — edit the template, then copy it into %s/\n' \
			"$DST/$name" "$t" "$DST"
		fails=$((fails + 1))
	fi
done

# The reverse direction is deliberately NOT an error: scripts/verify.sh,
# scripts/guards/* and the repo's own tooling are local by design.

[ "$fails" -eq 0 ] || exit 1
printf '%s shipped script(s) identical to their templates\n' "$(find "$SRC" -name '*.sh' | wc -l | tr -d ' ')"
