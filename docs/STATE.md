# STATE — project state & session memory

> **Length guard.** Thresholds are in `amh.conf`; the rules for compressing this file are
> `docs/RUNBOOK.md` → **Working-memory compression**, and they bind whether or not you follow
> this pointer. Read them before any edit that takes this file over the compression trigger.
>
> **Tree-relative.** That same section says what may be in `Current state` at all — the Changelog
> and ledger pointers below are historical storage and are exempt: what stays true of the
> checked-out tree, never world-controlled status (merged, tagged, released, PR and CI state,
> deployments, remote branches, forge settings) as current truth. Point at a live probe instead
> of storing its last answer, route an unresolved external action to the Owner queue, and scope a
> retained past observation to when it was observed. Prose-only — no guard judges it.

## Project

The AMH meta-repository — source of truth for the harness and its reference instance, which runs
byte-identical copies of the scripts it ships; `AGENTS.md` describes both and is read in full
every session.
Adopted harness version: **AMH 16.1.1** — see `harness/VERSION`, the copy that counts.

## Current state

This tree declares **16.1.1**; `harness/CHANGELOG.md` names what each version carries. Whether
it is tagged or released is not recorded here — `scripts/session-start.sh` probes that every
session.

`docs/LEDGER_D.md` is the live ledger volume.

Multi-unit work, planned: `docs/plans/2026-11-01-harness-research-gaps.md` closes the gaps a
harness-engineering survey found. The owner adopted it on 2026-11-09. **Each unit starts only on
the owner's explicit approval of that unit, and when the owner says to start one, the session
first says which decisions it needs and does not start until they are answered.** A fresh-context
review is pre-allowed for every unit.

- [x] H0 — the plan committed (rev 2)
- [ ] H0.5 — review by gpt-6-astra at `-e high`, mandate as N1's (started by the owner)
- [ ] H1, H4a, H4b, H2, H3, H5, H6a, H6b (optional), H7, H8 — none approved yet

Multi-unit work, planned: `docs/plans/2026-11-04-spill-guard-borrowings.md` closes the
credential-handling gaps found by comparing AMH with spill-guard. The owner adopted its four
selected units on 2026-11-04; S4, S5, S6b and S6c stay deferred.
 **Each unit starts only on the owner's explicit approval of that unit**; none is
approved yet.

- [x] S0 — the plan committed (rev 2)
- [ ] S1 — refusal text does not repeat a supported credential shape (awaiting approval)
- [ ] S2 — private-key bodies under a line prefix
- [ ] S6a — options on the wrappers the guard already peels
- [ ] S3 — four token shapes

Operational gotchas:

- A poison token in a squash-merge message suppresses the release commit's CI run entirely. Edit
  the squash message before merging; the guard checks commits on a branch, not the message the
  forge composes at merge time (**DC-040**).
- Nothing checks that every version with a changelog entry actually got a tag, so a merged
  release can sit untagged with every rung green (**DA-010**). `scripts/session-start.sh` probes
  the current version's tag every session; `git ls-remote --tags origin` settles any other.

## Owner queue

> **Protected section.** Never delete it, and never silently drop items during compression.
> Items leave only when done, answered or triaged — then delete the item and record the outcome
> as a Changelog line or a ledger row. How to test an item before restating it, and why the
> final chat message must: `docs/RUNBOOK.md` → **Session discipline** 7.

**OPEN — decide whether to plan a fix for a quote inside backticks.** Found while building Unit 2:
bash ends a backtick substitution at the first unescaped backtick, quotes or not, and every walker
in the command guard reads a `'` inside one as opening a string that hides the rest, so
`` echo `echo 'x`; printenv `` passes. No plan covers it; the guard's header names it.
Check: `scripts/command-guard.sh --command "echo \`echo 'x\`; printenv"` — exit status 0 means
it is still open. Unit 4 now reads heredoc bodies as bash does, so this gap also reaches a
command whose body the guard used to misread and refuse (**DD-059**).

**OPEN — decide whether to fix the command guard's payload parser on a non-UTF-8 code page
(evidence: **DD-069**).** Its text stdio swallows an encode or decode error, so the command passes
unjudged; measured only as the mechanism, on Linux. No Windows host here can test the proposed fix,
and no one-line check here settles it.

**OPEN — the research-gaps plan's remaining §1 decisions.** Asked when the unit each one belongs to
is started; none is answered yet except the two §1 marks as answered.

**OPEN — decide whether to adopt rev 2 of the cc-safety-net plan,
`docs/plans/2026-11-09-cc-safety-net-borrowings.md`, and which units.** Its N1 review is folded, and
its §8 has a row for each finding. Nothing in it is adopted or approved, and each later unit starts
only on the owner's approval of that unit.

**OPEN — decide two recommendations from that review that it had no authority to apply.** (1)
Whether to reconsider a `find` arm for the permanent targets, which **DD-018** chose not to take
(the plan's N8). (2) The cross-plan order and release placement in that plan's §2, decision 3, which
reach the spill-guard and research-gaps plans.

**OPEN — approve, or not, starting spill-guard plan Unit S1: refusal text does not repeat a
supported credential shape.** The plan is adopted for the release after 16.0.0 (its §2), and S1
is its first unit.
Each unit starts only on the owner's explicit approval of that unit, and approving one approves
only that one. When a unit lands, this item moves to the next. Check for S6a's gap, which the
plan raised: `scripts/command-guard.sh --command 'nice -n 5 rm -rf ~'` — exit status 0 means a
wrapper option still takes a deletion of the home directory past the permanent denial.

## Decided non-items (don't re-litigate without new evidence)

A pointer index, not an argument: **read the cited row before reopening any of these**, because
the row is where the reasoning lives and these lines are deliberately too short to re-litigate
from.

- **Pre-3.0.0:** templated shipped scripts, assurance levels, a packaged CLI, broad
  doc-fact/link guards, section-granular `RULE_FILES`, machine-consumed self-attestations, a
  `git log` rail under branch-train, failing ledger caps, hook-invocation detection, a shipped
  config-schema guard, a `BRANCH_PREFIX` push check (**D-002**, **D-010**, **D-014**, **D-023**,
  **DA-001**, **DA-003**, **DA-022**).
- **RFCs:** capability/profile/probe machinery and a second setup extension (**DA-024**); run
  receipts, transport, CI artifact and status tool (**DA-025**); five provenance-defective
  scenarios and their YAML/oracle/report machinery (**DA-026**).
- **Later:** the top-decile warning (**DB-040**, **DC-003** the adopted alternative); a
  constitution byte cap (**DB-038**); a Python-write advisory (**DC-007**); the 2026-08-10 review
  proposals (**DB-024**); a guard that opens a file to classify it (**DB-027**); a configurable
  ledger-id prefix (**DC-015**); ledger immutability across commits (**DC-020**); a guard that
  judges a State sentence's temporal validity (**DD-006**).

## Changelog

One line per shipped change or completed unit (newest first). Details live in the cited ledger
rows — this section is a pointer index, not a narrative.

- 2026-11-09 — **Research-gaps plan adopted by the owner, with H0.5 added;** fresh-context review
  pre-allowed for every unit. `amh-v16.1.1` found on origin, at the merged 16.1.1, so that queue
  item is done. Owner-queue-closure plan's A5 done: the plan is in `docs/history/`, and its
  attempt-1 patch is deleted (it applied only to a commit `main` does not contain; recoverable from
  that tag).

- 2026-11-09 — **16.1.1 drafted as PATCH, on the owner's choice,** for the fixes below; the version
  queue item is answered and the tag is queued.

- 2026-11-09 — **Two Owner-queue items closed on the owner's ask.** The interpreter and hook-file
  advisories re-fire with no digest tool (**DD-071**), and the machine-mode review's three gaps are
  fixed (**DD-070**). A runbook recipe now covers a branch that outlives its squash merge.

- 2026-11-09 — **N1 of the cc-safety-net plan done: gpt-6-astra's review folded into rev 2.** It
  rewrote most units and approved none; the plan's §8 has a row for each finding.

- 2026-11-09 — **Working memory compressed, and the 16.1.0 queue item left as done:** its check
  found `amh-v16.1.0` on origin that day.

- 2026-11-09 — **The cc-safety-net borrowings plan committed as a draft (N0).** On the owner's
  ask, after comparing that project with the command guard; its N1 review is in the Owner queue.

- 2026-11-08 — **The 16.1.0 train, folded.** The deletion rail reads through `xargs`, an optional
  machine mode that adoption and upgrades ask about, and the guard fixes they and a whole-train
  review surfaced (**DD-062** to **DD-067**).

- 2026-07-25 through 2026-11-06 — **Everything before that, folded.** Founding through the 16.0.0
  train (**DD-001** to **DD-061**, **DC-020** to **DC-044**, and the volumes for everything older;
  `docs/history/2026-11-05-unit4-review-and-fix.md` and the archived cc-safe-setup plan). The
  10.3.0–10.4.0 and 14.2.0 drafts rode later tags untagged, and 16.0.0 carried the 15.2.0 draft
  whole.
