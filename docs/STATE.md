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
Adopted harness version: **AMH 16.1.0** — see `harness/VERSION`, the copy that counts.

## Current state

This tree declares **16.1.0**; `harness/CHANGELOG.md` names what each version carries. Whether
it is tagged or released is not recorded here — `scripts/session-start.sh` probes that every
session.

`docs/LEDGER_D.md` is the live ledger volume.

`docs/plans/2026-10-31-owner-queue-closure.md` has every unit done. A5, retiring it together with
`docs/plans/2026-11-02-unit2-attempt-1.patch`, is what remains.

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

**OPEN — decide whether to fix the interpreter and hook-file advisories going silent with no
digest tool.** Found by the `xargs` unit's review: their comment in `scripts/command-guard.sh`
says such an advisory re-fires, but `interpreter_signature` failing returns before it fires, and
the same comment cites DC-004 for the one-shot rule DB-030 states. Reported by that reviewer,
measured with a `PATH` holding no `sha256sum`, `shasum` or `cksum`; no one-line check here.

**OPEN — decide whether to plan a fix for a quote inside backticks.** Found while building Unit 2:
bash ends a backtick substitution at the first unescaped backtick, quotes or not, and every walker
in the command guard reads a `'` inside one as opening a string that hides the rest, so
`` echo `echo 'x`; printenv `` passes. No plan covers it; the guard's header names it.
Check: `scripts/command-guard.sh --command "echo \`echo 'x\`; printenv"` — exit status 0 means
it is still open. Unit 4 now reads heredoc bodies as bash does, so this gap also reaches a
command whose body the guard used to misread and refuse (**DD-059**).

**OPEN — decide whether to fix three gaps the machine-mode review found outside its unit
(evidence: **DD-068**).** (1) `scripts/redact-tool-output.sh` starts Python with `-c` and no `-I`,
so a `json.py` in the session's folder stands redaction down. (2) `scripts/guards/adapter-set.sh`'s
pins on the project adapter do not read each hook's event key. (3) The adapter's one-slash
`Read(/proc/*/environ)` rails may never reach `/proc`. Check for (1):
`grep -c '"$PY" -c ' scripts/redact-tool-output.sh` — a count above 0 means it is still open.

**OPEN — decide whether to fix the command guard's payload parser on a non-UTF-8 code page
(evidence: **DD-069**).** Its text stdio swallows an encode or decode error, so the command passes
unjudged; measured only as the mechanism, on Linux. No Windows host here can test the proposed fix,
and no one-line check here settles it.

**OPEN — decide whether to adopt the harness-research-gaps plan,
`docs/plans/2026-11-01-harness-research-gaps.md`, and each decision in its §1.** It is committed
as a draft, and nothing in it is approved. No unit starts without the owner's approval of that
unit.

**OPEN — run N1 of the cc-safety-net plan, `docs/plans/2026-11-09-cc-safety-net-borrowings.md`:
its gpt-6-astra (`-e high`) review.** The owner granted that pass authority to overturn the plan's
own decisions and to add or rewrite its units (its §2). Nothing in the plan is adopted or
approved, and each later unit starts only on the owner's approval of that unit.

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
