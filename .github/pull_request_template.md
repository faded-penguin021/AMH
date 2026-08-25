<!--
  This template is a LAYOUT TO FILL IN, not a form to tick. There are deliberately no
  checkboxes: this repository has a standing decision against self-reported checklists in
  commits or YAML (P3, D-014). The ban is on machinery CONSUMING a
  self-report — a box an agent can tick without doing the work, that something downstream
  then trusts. Prose a reader can weigh and disbelieve is fine, which is what this asks for.
  If a guard, a CI step or a merge rule ever starts requiring text from this file, that is
  the violation: delete the requirement, not the section.

  Delete any heading that does not apply. Delete this comment.
-->

## What this changes

<!-- The net diff against the default branch, in prose. Under MERGE_MODE=branch-train a
     session branch contains every branch before it, so describe the whole superset, not
     the last branch's work. Lead with what a reader would not guess from the file list. -->

## Why

<!-- The problem, not the solution restated. If a ledger row carries the reasoning, name it
     (D-NNN) rather than repeating it. -->

## What the review pass found

<!-- Every legislation and guard diff gets a fresh-context pass before commit
     (CONTRIBUTING.md). Its findings are the most useful thing in this description: in this
     repository's history the blocking defect has been inside the FIX rather than the
     original problem in nearly every pass this repository has run. Say what it found and
     what you did about each. "Clean" is a legitimate answer and worth stating as plainly as any other —
     and it is prose, evidence of nothing, which is exactly why nothing consumes it.
     If the diff needed no pass, say which rule exempts it. -->

## Verification

<!-- What you ran and what it said. `scripts/ladder.sh` is the single entrypoint and CI runs
     the same command, so name its exit status, not your impression of it — run it DIRECTLY,
     never through a pipe, or you are reporting the pipe's status. Where a claim rests on a
     test, prefer the falsifiable form: "mutation M, suite went red" beats "covered". -->

## Adopter impact

<!-- Anything an adopter of the harness must DO, and the version semantics that follow from
     it (MAJOR = a binding rule changed; MINOR = additive; PATCH = no action). `amh.conf` and
     the seed documents are the adopter's forever and this harness cannot upgrade them, so a
     change that requires hand-editing either one belongs here in full — or belongs redesigned.
     "None" is a complete answer. -->

## Ledger rows

<!-- New D-NNN rows, and any pointer appended to an existing row, one line each. Rows are append-only and never renumbered;
     corrections go in a later row that points back. -->

## Owner actions after merge

<!-- Tagging, releasing, environment settings — anything an agent may not do itself. Mirror
     these into the Owner queue in docs/STATE.md so they survive this PR. -->
