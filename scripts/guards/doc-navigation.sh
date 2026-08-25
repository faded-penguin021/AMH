#!/usr/bin/env bash
# Repo-local guard: binding runbook section pointers keep bounded retrieval navigable (DA-017).
# The expected set is declared here rather than inferred from surviving prose, so a section
# and its pointer cannot disappear together while the check shrinks with the real omission
# that earned this guard (DA-018).

set -uo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." || exit 1

fails=0
checked=0

while IFS='|' read -r pointer heading pointer_file; do
	[ -n "$pointer" ] || continue
	# A row may name the file that must carry the pointer; the constitution is the default,
	# because that is where every route into the runbook used to start. docs/STATE.md joined
	# the list when its rule preambles moved into the runbook and left pointers behind. That
	# is not a widening for its own sake: DB-029 recorded the FIRST such relocation with "the
	# pointer left behind is prose only", and an unguarded pointer is how a relocation
	# quietly finishes becoming the repeal the rule-review protocol exists to catch. A
	# section reachable only through a pointer nothing checks is a section that can be
	# orphaned by an edit no guard sees.
	[ -n "$pointer_file" ] || pointer_file=AGENTS.md
	checked=$((checked + 1))
	pointer_count=$(grep -cF -- "$pointer" "$pointer_file" 2>/dev/null || true)
	heading_count=$(grep -cFx -- "$heading" docs/RUNBOOK.md 2>/dev/null || true)
	case $pointer_count in
	1) ;;
	0)
		printf 'missing navigation pointer in %s: %s\n' "$pointer_file" "$pointer"
		fails=$((fails + 1))
		;;
	*)
		printf 'duplicate navigation pointer in %s: %s\n' "$pointer_file" "$pointer"
		fails=$((fails + 1))
		;;
	esac
	case $heading_count in
	1) ;;
	0)
		printf 'missing navigation heading in docs/RUNBOOK.md: %s\n' "$heading"
		fails=$((fails + 1))
		;;
	*)
		printf 'duplicate navigation heading in docs/RUNBOOK.md: %s\n' "$heading"
		fails=$((fails + 1))
		;;
	esac
done <<'NAVIGATION'
- Change procedures: `docs/RUNBOOK.md` → **Change-type playbooks**.|## Change-type playbooks
`docs/RUNBOOK.md` → **Efficient document retrieval**.|## Efficient document retrieval
- Binding-rule changes: `docs/RUNBOOK.md` → **Rule-review protocol**.|## Rule-review protocol (MANDATORY for binding-rule and guard diffs)
- Secret handling and incidents: `docs/RUNBOOK.md` → **Incident: leaked credential**.|## Incident: leaked credential
- Session execution, checkpoints, recovery, and owner forks: `docs/RUNBOOK.md` → **Session discipline**.|## Session discipline (BINDING for every session)
- Verification and locally unverifiable coverage: `docs/RUNBOOK.md` → **Acceptance ladder**.|## Acceptance ladder
- Compressing working memory: `docs/RUNBOOK.md` → **Working-memory compression**.|## Working-memory compression
`docs/RUNBOOK.md` → **Working-memory compression**, and they bind whether or not you follow|## Working-memory compression|docs/STATE.md
`docs/RUNBOOK.md` → **Session discipline** 7.|## Session discipline (BINDING for every session)|docs/STATE.md
NAVIGATION

[ "$fails" -eq 0 ] || exit 1
printf '%d binding documentation pointer/heading pair(s) resolve exactly once\n' "$checked"
