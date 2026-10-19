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
Adopted harness version: **AMH 15.2.0** — see `harness/VERSION`, the copy that counts.

## Current state

This tree declares **15.2.0**: every Claude adapter hook is anchored at the project root, both
`PreToolUse` hooks refuse the call when the hook itself fails, and on Windows that makes Git for
Windows a hard requirement, said in the refusal itself (**DD-040**), and the command guard judges
`\rm` and `/usr/bin/env` as `rm` and `env` (**DD-041**), and a command after a reserved word
(`then`, `do`, `!`) or spelled with `.exe` as the command it runs (**DD-042**), and it denies a
glob matching every hidden entry of a listed directory while judging a brace expansion word by
word (**DD-044**), and the shipped ladder checks the Claude adapter's shell pin wherever
`.claude/settings.json` exists (**DD-045**). Under it is 15.1.0: the
command guard's permanent denial covers a Windows drive's
root, `Users` and `Users\<name>` in every spelling it folds, a `cmd /c` recursive `rd`/`del` is
judged, one spelled with `\"` nested quotes is denied whatever its path, the constitution
forbids retrying a refused deletion in another spelling (**DD-038**), and the Claude adapter's
command guard matches `Bash|PowerShell`, with PowerShell read by its own reader (**DD-039**).
Under it is 15.0.1, whose
author-identity rung sets aside the forge's test merge a pull-request CI checks out and judges
`origin/<default>..HEAD^2` instead (**DD-036**), over 15.0.0 — a deletion aimed at the filesystem root or a home directory is permanently denied, an
inline interpreter deletion buys one advisory, and both adapters wire output redaction
(**DD-015**–**DD-035**) — over 14.1.0's shell pin (**DD-007**–**DD-014**). Whether this draft
is tagged or released is not recorded here — `scripts/session-start.sh` probes it every session
and reports present, absent or could-not-ask, which is the only answer that can be right twice.

`docs/LEDGER_D.md` is the live ledger volume. No active multi-unit work.

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

**OPEN — tag the drafted 15.2.0 release after its PR merges.** Tagging is an owner action, and
the README Quick Start names the draft tag before it exists. Check: `git ls-remote --exit-code
--tags origin refs/tags/amh-v15.2.0` — a matching ref resolves this item; no output means the
documented install command is not live yet.

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

- 2026-10-19 — **15.2.0 (drafted): adopters' ladders check the Claude shell pin**, gated on
  `.claude/settings.json` existing; that closed the pin-check Owner-queue item (**DD-045**).

- 2026-10-19 — **15.2.0 (drafted): the permanent denial covers `~/.?*`, `~/.[!.]*` and
  `/[!.]*`, and a brace inside a word no longer splits the command**, so `rm -rf
  ~/{.cache,.npm}` gets the advisory; that closed the DD-035 Owner-queue item (**DD-044**).

- 2026-10-19 — **Owner queue triaged to actionable items only.** On the owner's call, five
  observation gaps that no owner action can settle left the queue; what each still lacks and what
  would reopen it is in **DD-043**.

- 2026-10-15 — **15.2.0 (drafted): the command guard judges a command after a reserved word or
  spelled with `.exe`**, which closed that Owner-queue item (**DD-042**).

- 2026-10-14 — **15.2.0 (drafted): a failing or missing Claude hook refuses the call, and the
  guard reads `\rm` and `/usr/bin/env` as `rm` and `env`.** Found by checking this tree against a
  public report on silent hook guards (**DD-040**, **DD-041**). `amh-v15.1.0` was seen on origin,
  so that tag item left the queue.

- 2026-10-04 — **The Claude `PostToolUse` redaction hook was observed firing** on Bash, Read and
  Grep results (**DD-037**). Both Claude adapter comments now say so; the Codex half stays queued.

- 2026-10-07 — **15.1.0 (drafted): Windows drive roots and `cmd /c` deletions reach the command
  guard.** A Claude Code session on Windows PowerShell 5.1 deleted its account's files on `C:`
  through `cmd /c "rmdir /s /q \"...\""`, retrying a cleanup a safety check had blocked; the
  bash half of the Windows arm and the no-respelling rule landed (**DD-038**); then the PowerShell
  reader and the `Bash|PowerShell` matcher, which retired **DD-012**'s decided non-item (**DD-039**).

- 2026-10-04 — **15.0.1: the author-identity rung no longer judges the forge's test merge.** A
  downstream contributor re-authored every commit and force-pushed, and the rung kept failing on
  the detached merge the forge composes for the PR, which no amend reaches (**DD-036**). The
  queued 15.0.0 tag was found on origin this session, so that item left the queue.

- 2026-09-09 through 2026-09-29 — **14.1.0, the untagged 14.2.0 draft and 15.0.0, folded;
  `amh-v14.1.0` and `amh-v15.0.0` were seen on origin on 2026-10-04.** The Claude adapter pinned
  its hooks' shell, both adapters wired output redaction, a deletion aimed at the filesystem root
  or a home directory became the command guard's one permanent denial with an inline-interpreter
  advisory beside it, and two external reviews' findings were validated and fixed; the whole
  draft became MAJOR on the owner's call of 2026-09-18 (**DD-007**–**DD-035**).

- 2026-09-01/02 — **14.0.0 and the 11.0.0 counter work, folded.** Working memory became
  tree-relative and stopped caching world-controlled status; a ledger row was pinned to its text
  rather than to the file it names; counter checks were separated from authoring judgement, with
  compression keyed to content lifecycle and row limits restated as rejection boundaries
  (**DD-001**–**DD-006**, **DC-044**).

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
