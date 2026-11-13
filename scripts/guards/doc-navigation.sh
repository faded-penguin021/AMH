#!/usr/bin/env bash
# Repo-local guard: binding section pointers into docs/RUNBOOK.md and docs/PROTOCOLS.md keep
# bounded retrieval navigable (DA-017).
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
	# The heading is looked for in the file the POINTER names, not in a fixed one: the
	# sections split between the runbook and docs/PROTOCOLS.md (DD-081), and a heading that
	# exists only in the other file leaves the pointer a session follows resolving to nothing.
	# A row whose pointer names neither file is a fault in this table, reported as one.
	target=$(printf '%s\n' "$pointer" | grep -oE 'docs/(RUNBOOK|PROTOCOLS)\.md' | head -n 1)
	case $target in
	docs/RUNBOOK.md) other=docs/PROTOCOLS.md ;;
	docs/PROTOCOLS.md) other=docs/RUNBOOK.md ;;
	*)
		printf 'navigation row names no target document: %s\n' "$pointer"
		fails=$((fails + 1))
		continue
		;;
	esac
	pointer_count=$(grep -cF -- "$pointer" "$pointer_file" 2>/dev/null || true)
	heading_count=$(grep -cFx -- "$heading" "$target" 2>/dev/null || true)
	# The same heading in the other document is a second authority for one rule — the state
	# a half-finished split leaves — and it is the shape the split's own migration can produce.
	other_count=$(grep -cFx -- "$heading" "$other" 2>/dev/null || true)
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
		printf 'missing navigation heading in %s: %s\n' "$target" "$heading"
		fails=$((fails + 1))
		;;
	*)
		printf 'duplicate navigation heading in %s: %s\n' "$target" "$heading"
		fails=$((fails + 1))
		;;
	esac
	if [ "${other_count:-0}" -gt 0 ]; then
		printf 'duplicate navigation heading in %s: %s (its pointer names %s)\n' "$other" "$heading" "$target"
		fails=$((fails + 1))
	fi
done <<'NAVIGATION'
- Change procedures: `docs/RUNBOOK.md` → **Change-type playbooks**.|## Change-type playbooks
`docs/RUNBOOK.md` → **Efficient document retrieval**.|## Efficient document retrieval
- Binding-rule changes: `docs/PROTOCOLS.md` → **Rule-review protocol**.|## Rule-review protocol (MANDATORY for binding-rule and guard diffs)
- Secret handling and incidents: `docs/PROTOCOLS.md` → **Incident: leaked credential**.|## Incident: leaked credential
- Session execution, checkpoints, recovery, and owner forks: `docs/PROTOCOLS.md` → **Session discipline**.|## Session discipline (BINDING for every session)
- Verification and locally unverifiable coverage: `docs/PROTOCOLS.md` → **Acceptance ladder**.|## Acceptance ladder
- Compressing working memory: `docs/PROTOCOLS.md` → **Working-memory compression**.|## Working-memory compression
`docs/RUNBOOK.md` → **Host rails and what they miss** before you count on a rail to stop a|## Host rails and what they miss
`docs/RUNBOOK.md` → **Host rails and what they miss**. A deletion the guard denied|## Host rails and what they miss
`docs/PROTOCOLS.md` → **Working-memory compression**, and they bind whether or not you follow|## Working-memory compression|docs/STATE.md
`docs/PROTOCOLS.md` → **Session discipline** 7.|## Session discipline (BINDING for every session)|docs/STATE.md
NAVIGATION

[ "$fails" -eq 0 ] || exit 1
printf '%d binding documentation pointer/heading pair(s) resolve exactly once\n' "$checked"
