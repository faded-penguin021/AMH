# STATE — project state & session memory

<!--
SEED TEMPLATE (AMH). Yours from the moment it is copied. Working memory: rewritten freely,
but capacity-bounded — the cap is what forces compaction, and compaction is what keeps every
session's first read cheap.

Keep this file's permanent content to the pointers below. The rules that govern it live in
docs/RUNBOOK.md → Working-memory compression, because rules that change only under the
rule-review protocol would otherwise spend the budget the cap exists to protect — and cannot
be compressed to make room, since folding a live rule is repeal.
-->

> **Length guard.** Thresholds are in `amh.conf`; the rules for compressing this file are
> `docs/RUNBOOK.md` → **Working-memory compression**, and they bind whether or not you follow
> this pointer. Fold completed narrative when its stage completes; retain only current state,
> unresolved owner items, immediate operational gotchas and concise changelog pointers.
>
> **Tree-relative.** That same section also says what may be in `Current state` at all — the
> Changelog and ledger pointers are historical storage and are exempt: it records what stays true
> of the checked-out tree, never world-controlled status (merged, tagged, released, PR
> and CI state, deployments, remote branches, forge settings) as current truth. Point at a live
> probe instead of storing its last answer, route an unresolved external action to the Owner
> queue, and scope a retained past observation to when it was observed. Prose-only — no guard
> judges it.

## Project

{{FIVE_LINE_SUMMARY}}

## Current state

{{WHAT_IS_SHIPPED, as the tree declares it / what is code-complete awaiting owner action / active
multi-unit work with its checklist / "no active work".}}

<!--
Write what a fresh clone of THIS COMMIT would still find true. Test each sentence: would it hold
tomorrow, under another branch name, after forge state had moved? If not, it belongs at a live
probe, in the Owner queue, or scoped as a dated observation — not here as fact. Do not write
"released", "tagged", "merged", "CI is green" or "protection is configured" as current state.
-->


## Owner queue

> **Protected section.** Never delete it, and never silently drop items during compression (a
> ladder guard warns if the header vanishes). Items leave only when done, answered or triaged
> — then delete the item and record the outcome as a Changelog line or a ledger row.
>
> How to test an item before restating it, and why every session's final chat message must:
> `docs/RUNBOOK.md` → **Session discipline** 7.
>
> The form, with the resolution spelled out so the next session is not guessing at it:
>
> ```
> 1. Publish the 1.4.0 release once the changelog PR is merged.
>    Check: `git ls-remote --tags origin 'refs/tags/v1.4.0'` — a line back means it is cut; done.
> 2. Rotate the staging API key (owner-only; no session can see the secret store).
> ```

**Pending owner actions:** (none)

**Open questions:** (none) — date-stamp each item `[YYYY-MM-DD]` with the fork, the options
and the session's recommendation. Age is the owner's triage cue.

**Incoming findings:** (none) — the owner's manual-test results land here. Reading this file
is protocol step 1 of the next session, so anything dropped here is guaranteed to be seen.

## Decided non-items (don't re-litigate without new evidence)

- {{DATE — what was declined, one-line reason.}}

## Changelog

One line per shipped change or completed unit (newest first). Keep terse; details live in the
cited ledger rows and in git history.

- {{DATE}} — **D-NNN** {{one-line summary}}. Detail in the D-NNN row.
