#!/usr/bin/env bash
# Repo-local guard: binding runbook section pointers from AGENTS.md remain navigable.
# The expected set is declared here rather than inferred from surviving prose, so a section
# and its pointer cannot disappear together while the check shrinks with the defect (DA-017).

set -uo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." || exit 1

fails=0
checked=0

while IFS='|' read -r pointer heading; do
	[ -n "$pointer" ] || continue
	checked=$((checked + 1))
	pointer_count=$(grep -cF -- "$pointer" AGENTS.md 2>/dev/null || true)
	heading_count=$(grep -cFx -- "$heading" docs/RUNBOOK.md 2>/dev/null || true)
	case $pointer_count in
	1) ;;
	0)
		printf 'missing navigation pointer in AGENTS.md: %s\n' "$pointer"
		fails=$((fails + 1))
		;;
	*)
		printf 'duplicate navigation pointer in AGENTS.md: %s\n' "$pointer"
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
- Verification and locally unverifiable coverage: `docs/RUNBOOK.md` → **Acceptance ladder**.|## Acceptance ladder
NAVIGATION

[ "$fails" -eq 0 ] || exit 1
printf '%d binding documentation pointer/heading pair(s) resolve exactly once\n' "$checked"
