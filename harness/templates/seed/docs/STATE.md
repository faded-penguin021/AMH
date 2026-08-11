# STATE — project state & session memory

<!--
SEED TEMPLATE (AMH). Yours from the moment it is copied. Working memory: rewritten freely,
but capacity-bounded — the cap is what forces compaction, and compaction is what keeps every
session's first read cheap.
-->

> **Length guard (read before editing — hysteresis).** The thresholds `STATE_WARN_KB`,
> `STATE_COMPRESS_TO_KB` and `STATE_HARD_KB` live in `amh.conf`, named here and deliberately
> **not** restated as numbers: nothing checks this prose against the config, so a copied number
> drifts silently the first time a threshold moves. `scripts/ladder.sh` reads them from there too
> — or falls back to its own defaults for a key you leave out — and prints whichever a verdict
> needs: the caps on its size line, the floor when it warns, fails, or confirms a completed
> landing. Those are DERIVED from your config, not copied out of it (the landing line reports
> bytes where the key is in KB), so read one as the guard's arithmetic, never as a value to copy
> back into prose.
>
> Grow freely to the soft cap; no trimming below that line. When the guard warns, run ONE deep
> compression pass landing at or below the compression floor — never trim to just under the soft
> cap, because micro-trims re-arm the warning a session later and the wide band IS the debounce,
> statelessly. The floor is a **ceiling, not a target**: aim comfortably below it, and if the
> pass lands short, fold MORE completed stages rather than micro-trimming toward the floor — the
> same reflex the band exists to break, one threshold lower. Fail above the hard cap. Compressing
> means collapsing each completed work stage into one Changelog line, folding changelog clusters,
> moving durable gotchas into the append-only ledger and deleting narrative prose. **Project**,
> **Current state** and **Owner queue** must always survive it: compress an Owner-queue item's
> prose, never drop an open one — closing them is the owner's call.
>
> `scripts/ladder.sh` machine-checks the band, the required sections and their non-empty bodies,
> that no level-2 heading appears twice, that the Owner-queue heading is still there (a warning,
> not a failure — the section is the owner's), and that a compression pass lands on the floor
> rather than just clearing the warning; above the cap it tells a pass from an ordinary edit by
> how much the file shrank (`STATE_EDIT_DELTA_BYTES`), so fixing a typo up here obliges you
> neither to compress the file nor to revert. **And that list is the whole of it** — a claim
> about `guard_state_size` and `guard_state_structure` in `scripts/ladder.sh`, a file that
> upgrades independently of this one, so those two functions are the authority and this sentence
> is what goes stale when a version adds a rung, with nothing checking it against the script. Everything else here — what to fold, what to move to the ledger, whether
> to compress at all — is prose no guard will catch you breaking.
>
> One consequence, since silence reads as approval: **the landing check never runs below the soft
> cap** — only a file that started above it reaches that check, though the structure checks run
> at every size. So a deep pass on a file already under the cap draws a plain size line and
> nothing more: the absence of a check, not a verdict that the edit was right, and exactly the
> pass the paragraph above forbids. Do not reach for a threshold to cover it. It is the SHRINK
> that is measured, never the band, and a check treating any large shrink as a compression pass
> fails a session for deleting one resolved Owner-queue item from a healthy file — leaving
> padding the file back as the only way to pass.

## Project

{{FIVE_LINE_SUMMARY}}

## Current state

{{WHAT_IS_SHIPPED / what is code-complete awaiting owner action / active multi-unit work with
its checklist / "no active work".}}

## Owner queue

> **Protected section.** Never delete it, and never silently drop items during compression (a
> ladder guard warns if the header vanishes). Items leave only when done, answered or triaged
> — then delete the item and record the outcome as a Changelog line or a ledger row. Every
> session's final chat message restates this queue.
>
> **Test each item before you restate it.** Where an item's truth is observable from a session,
> it carries a **Check:** line with the command — run it, read its OUTPUT against the resolution
> the item states (not its exit status), and if the item is resolved it is done: delete it and
> record the outcome in the same session, never restate it with a caveat. Where it is not
> observable, the item says so and names who settles it; restate that as *unverified*.
> **`Check:` is deliberately not a required field** — an item that must carry one will get one,
> and "the owner says so" is a check the way a checkbox is evidence. Its absence is information.
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
