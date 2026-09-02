# STATE — project state & session memory

> **Length guard.** Thresholds are in `amh.conf`; the rules for compressing this file are
> `docs/RUNBOOK.md` → **Working-memory compression**, and they bind whether or not you follow
> this pointer. Read them before any edit that takes this file over the soft cap.

## Project

The AMH meta-repository — source of truth for the harness and its reference instance, which runs
byte-identical copies of the scripts it ships; `AGENTS.md` describes both and is read in full
every session.
Adopted harness version: **AMH 13.0.0** — see `harness/VERSION`, the copy that counts.

## Current state

AMH **13.0.0** is prepared on this branch and untagged; it separates counter acceptance from
authoring quality (**DD-001**, **DD-002**). **11.0.0** is released and tagged `amh-v11.0.0`. The 10.4.0 release commit has no CI run because its squash
message carried the poison token; edit future squash messages before merge (**DC-040**).
**9.2.0 has a changelog entry and no tag**, and nothing checks that every changelog version got
one. `docs/LEDGER_D.md` is live at **DD-002**. `main` protection targets `ladder`.

**ACTIVE — RFC "Correct mutability boundaries in State and ledger references", unit 2 of 2.**
Unit 1 shipped (**DD-004**). Unit 2 makes `docs/STATE.md` tree-relative and carries the combined
MAJOR release for both units; the version is deliberately still 13.0.0 until it runs. What it
owes, and what unit 1 already delivered, are in `docs/plans/2026-09-02-state-ledger-mutability.md`
— read that file, not this line, before starting. Delete or archive it when unit 2 completes.

## Owner queue

> **Protected section.** Never delete it, and never silently drop items during compression.
> Items leave only when done, answered or triaged — then delete the item and record the outcome
> as a Changelog line or a ledger row. How to test an item before restating it, and why the
> final chat message must: `docs/RUNBOOK.md` → **Session discipline** 7.

**OPEN — the `printf | grep -q` class survives at 39 further sites, and 10 are NOT fixture
harnesses.** Unit 3 fixed the two with reachable unbounded input; the residue is safe on BOUNDED,
mostly single-line input rather than on a loud direction, and at least three are the same
fail-OPEN shape — `ladder.sh:1358` is the one to watch (**DC-038**). Not queued as work; reopen
if any starts matching something unbounded. Check: `grep -rn "printf.*| *grep -q" --include=*.sh
scripts/ harness/templates/` prints 45 lines, 6 of them comments — resolved only if that stops
matching the description, which it deliberately does not.

**OPEN — the 2026-08-29 `path-refs.sh` false failure on `` `session-start.sh` `` still has no
reproducer.** Closed in `b2a9ae3` as the EPIPE defect, then restored when the pass falsified that
(**DC-035**, **DC-029** for the residue): a listing git completed, reported success for, and cut
short anyway. No check; only a recurrence settles it.

**OPEN — the destructive rail sees no Windows shell, and two reported incidents live there.** The
owner's (2026-08-29) `cmd /c "rd /s /q ..."` resolved to the root of `D:` through a
backslash-quote mismatch, pairing with the Antigravity `rmdir /s /q d:\` (**DC-027**). Which
layer mis-parsed is unsettled and matters to whoever builds the arm; a Windows arm is the owner's
call since the harness targets bash. No check until a session builds it.

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
  ledger-id prefix (**DC-015**); ledger immutability across commits (**DC-020**).

## Changelog

- 2026-09-02 — **A ledger row pins its text, not the file it names.** The path guard now classifies
  a missing ledger target against the commit that introduced the citing row — exempting historical
  drift past the commit that removes the target, failing a citation already broken when authored,
  and warning where no history or default-branch baseline can say which — so the completed Windows
  CI plan retired to `docs/history/` while DC-033 keeps its wording (**DD-004**). The frozen
  archive left the scan in the same change, on the plan tier's own reasoning (owner, **DD-005**).

- 2026-09-02 — **Thresholds name their behavior and historical ledger paths stay immutable.** Classified every configured content boundary at its action point, removed target-like wording and the ledger warning band, shortened ledger preambles, and made path validation strict at authoring while exempting a committed target that had moved only in the working tree (**DD-003**, corrected by **DD-004**).

One line per shipped change or completed unit (newest first). Details live in the cited ledger
rows — this section is a pointer index, not a narrative.

- 2026-09-02 — **Counter-check fixture baselines follow the live ledger.** Updated shipped and
  local fixture expectations after the objective-verdict rewrite and volume-D rollover (**DD-002**).

- 2026-09-02 — **Counter checks report size, not writing quality.** Runbook, configuration and
  ledger preambles separate binary byte-and-sentence acceptance from authoring judgement, ban
  counter-only rewrites, and keep successful verdicts factual (**DD-001**).

- 2026-09-01 — **11.0.0: working-memory compression follows content lifecycle.** Completed
  narrative is folded when its stage completes; configured byte and sentence values remain
  unchanged and serve only as post-compression acceptance ceilings (**DC-044**).
- 2026-09-01 — **10.5.1: ledger row limits are rejection boundaries, never desired sizes.**
  Config comments, scaffold guidance and the ledger seed now lead with the smallest
  self-contained durable lesson, prefer one or two sentences when sufficient, distinguish the
  sentence anti-shaving control from the dense-sentence byte backstop, and route near-boundary
  material to splitting, durable conclusions or history instead of boundary optimization.
- 2026-09-01 — **10.4.0–10.5.0, folded.** The train shipped the Windows/CRLF portability
  proof and remediation, fixed reachable fail-open `printf | grep -q` pipelines, prohibited
  ledger citations to plan paths, and added structural forge/API mutation classification
  (**DC-036**–**DC-043**).
- 2026-07-25 through 2026-08-31 — **Everything before this session, folded.** Founding through
  portable rails, the constitution rewrite, the 8.0.0–9.0.0 train, git-native pre-push
  enforcement, the 9.2.0–10.2.0 trains tagged `amh-v10.0.0` and `amh-v10.2.0`, and the unreleased
  10.3.0–10.4.0 train: a data-plane tier grown by reported incidents, an escaped quote that had
  been voiding the rails behind it, a PR-time release-number check, an adoption-first README, and
  a Windows tail in four parts (**DC-020**–**DC-035**, and the volumes for everything older).
