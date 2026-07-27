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
# Counted in the loop, never re-derived afterwards. The closing number used to come from a
# recursive `find`, which stops being the set the loop compared the moment anyone adds a
# subdirectory here — a guard whose final line describes a different set from the one it
# checked is the same prose/code lockstep defect this repo keeps finding elsewhere.
compared=0

# EVERY file under harness/templates/scripts/, not only the *.sh ones. The manifest that
# ships beside them (MANIFEST.sha256) is a shipped artifact exactly as they are, and one
# glob's worth of narrowness would have left this repo's copy of it free to drift from the
# copy adopters receive — while the guard's own line claimed the shipped set was identical.
for t in "$SRC"/*; do
	[ -f "$t" ] || continue
	compared=$((compared + 1))
	name=$(basename "$t")
	if [ ! -e "$DST/$name" ]; then
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
printf '%s shipped file(s) identical to their templates\n' "$compared"
