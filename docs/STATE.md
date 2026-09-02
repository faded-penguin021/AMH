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
Adopted harness version: **AMH 14.0.0** — see `harness/VERSION`, the copy that counts.

## Current state

This tree declares **14.0.0**: ledger rows pin their text rather than the files they name, and
working memory is tree-relative (**DD-004**, **DD-006**). Whether that version is tagged or
released is not recorded here — `scripts/session-start.sh` probes it every session and reports
present, absent or could-not-ask, which is the only answer that can be right twice.

`docs/LEDGER_D.md` is the live ledger volume. No active multi-unit work.

Operational gotchas:

- A poison token in a squash-merge message suppresses the release commit's CI run entirely. Edit
  the squash message before merging; the guard checks commits on a branch, not the message the
  forge composes at merge time (**DC-040**).
- Nothing checks that every version with a changelog entry actually got a tag, so a merged
  release can sit untagged with every rung green (**DA-010**). The release Owner-queue item below
  carries the command that settles it for this version.

## Owner queue

> **Protected section.** Never delete it, and never silently drop items during compression.
> Items leave only when done, answered or triaged — then delete the item and record the outcome
> as a Changelog line or a ledger row. How to test an item before restating it, and why the
> final chat message must: `docs/RUNBOOK.md` → **Session discipline** 7.

**PENDING OWNER ACTION — merge this branch, then tag 14.0.0, in that order.** The tree declares
14.0.0 and the changelog carries its entry; both steps are yours. Merge
`claude/state-ledger-mutability-qvj27g` into `main` first, then tag the merge commit — tagging
before the merge points the release at a commit `main` never gets, and the README's clone command
targets `amh-v14.0.0`, so until the tag exists that documented install 404s (**DA-010**). Edit the
squash message before merging: a poison token in it suppresses the release commit's CI run
(**DC-040**). Expected, not observed — no session here can inspect a forge setting with the tools
this harness assumes — `main` protection requires the `ladder` check; if that is no longer so, the
merge gate is not what this assumes.
Check: `git ls-remote --tags origin 'refs/tags/amh-v14.0.0'` — a line back means the tag is cut;
confirm it sits on `main`'s history before closing, since the check cannot see the ordering this
item exists to enforce.

**OPEN — the `printf | grep -q` class survives at 39 further sites, and 10 are NOT fixture
harnesses.** Unit 3 fixed the two with reachable unbounded input; the residue is safe on BOUNDED,
mostly single-line input rather than on a loud direction, and at least three are the same
fail-OPEN shape — `ladder.sh:1358` is the one to watch (**DC-038**). Not queued as work; reopen
if any starts matching something unbounded. Check: `grep -rn "printf.*| *grep -q" --include=*.sh
scripts/ harness/templates/` prints 45 lines, 6 of them comments — resolved only if that stops
matching the description, which it deliberately does not.

**OPEN — the 2026-08-29 `path-refs.sh` false failure on `` `session-start.sh` `` still has no
reproducer.** Closed once as the EPIPE defect, then restored when the pass falsified that
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
  ledger-id prefix (**DC-015**); ledger immutability across commits (**DC-020**); a guard that
  judges a State sentence's temporal validity (**DD-006**).

## Changelog

- 2026-09-02 — **14.0.0: working memory is tree-relative.** `Current state` records what stays
  true of the checked-out tree and stops caching merge, tag, release, CI and forge-setting status;
  live facts point at the probe that recomputes them, external actions route to the Owner queue,
  and retained past facts are scoped to when they were observed. Prose-only, at P2/P9, both
  runbooks, both constitutions and the seeds (**DD-006**).

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
