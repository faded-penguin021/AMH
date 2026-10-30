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
Adopted harness version: **AMH 16.0.0** — see `harness/VERSION`, the copy that counts.

## Current state

This tree declares **16.0.0**, MAJOR on the owner's call: a unit owes the review of what it
was set to change, never only that of the diff it ends with, and a decision says whether its
evidence was measured, estimated or reported (**DD-050**). It carries the 15.2.0 draft whole: every Claude
adapter hook is anchored at the project root, both
`PreToolUse` hooks refuse the call when the hook itself fails, and on Windows that makes Git for
Windows a hard requirement, said in the refusal itself (**DD-040**), and the command guard judges
`\rm` and `/usr/bin/env` as `rm` and `env` (**DD-041**), and a command after a reserved word
(`then`, `do`, `!`) or spelled with `.exe` as the command it runs (**DD-042**), and it denies a
glob matching every hidden entry of a listed directory while judging a brace expansion word by
word (**DD-044**), and the shipped ladder checks the Claude adapter's shell pin wherever
`.claude/settings.json` exists (**DD-045**), and it removes a backslash-newline before reading a
command, as bash does (**DD-046**), and reads a short-flag cluster on `git push` as git does
(**DD-047**), and denies the pre-push rail's off switches (**DD-048**), and the session banner
says when newer working memory builds on this checkout (**DD-049**), and the pre-push hook file
gets a one-time advisory and an adapter deny rail (**DD-051**), and it denies reading a tool's
stored credentials or printing one with `gh auth token` or `git credential fill` (**DD-052**),
and the constitution names Claude Code's `--safe-mode`, `--bare` and `--restricted` as modes that
leave the adapter's hooks out (**DD-053**). What each older version
added is in `harness/CHANGELOG.md` and the Changelog below. Whether this draft
is tagged or released is not recorded here — `scripts/session-start.sh` probes it every session
and reports present, absent or could-not-ask, which is the only answer that can be right twice.

`docs/LEDGER_D.md` is the live ledger volume.

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

**OPEN — tag the drafted 16.0.0 release after its PR merges.** Tagging is an owner action, and
the README Quick Start names the draft tag before it exists. Check: `git ls-remote --exit-code
--tags origin refs/tags/amh-v16.0.0` — a matching ref resolves this item; no output means the
documented install command is not live yet.

**OPEN — decide whether to plan a fix for two command-guard parse gaps found during
cc-safe-setup Unit 1, both older than it and outside it.** (a) Only the continuation pass knows
`#` comments, so the `'` in `echo a # don't` opens a string for every other walker, and a
`printenv` or `rm -rf /` on the next line gets no verdict. (b) Continuations are joined after
heredoc bodies are cut, so `cat <<EOF \⏎&& git push --force origin main` opens the body a line
early and hides the push. Both are in the guard header's misses; each would be a unit of its
own. Check: pass `echo a # don't`, a newline, then `printenv` to `scripts/command-guard.sh
--command` — exit 0 means (a) is still open.

**OPEN — decide whether to plan a fix for abbreviated long options on `git push`, found during
cc-safe-setup Unit 2 and outside it.** Git accepts a long option shortened to a unique prefix, so
`git push --del origin <branch>` deletes and `--force-w` force-pushes, and the command rail reads
neither; only the `--pre-push` rail, where installed, stops them by outcome. Since Unit 3 the
same gap covers `--no-veri`, and there nothing backstops it, because that flag is what skips the
pre-push rail (**DD-048**). It is in the guard header and would be a unit of its own. Check: pass `git push --del origin
session/x` to `scripts/command-guard.sh --command` — exit 0 means it is still open.

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

- 2026-10-30 — **16.0.0 (drafted), cc-safe-setup Unit 6, which completes that plan: Claude
  Code's `--safe-mode`, `--bare` and `--restricted` are named as modes that leave the adapter's
  hooks out**, and Unit 4's `--restricted` claim is corrected, both on the owner's call; the
  plan is archived in `docs/history/` (**DD-053**).

- 2026-10-27 — **16.0.0 (drafted), cc-safe-setup Unit 5: reading a tool's credential store, and
  `gh auth token` and `git credential fill`, are denied at the block tier**, with the cargo store
  added on the owner's call of 2026-10-27 (**DD-052**).

- 2026-10-26 — **16.0.0 (drafted), cc-safe-setup Unit 4: `rm`, `mv` and `chmod` on the pre-push
  hook file get a one-time advisory, and the Claude adapter denies the editing tools it**; the
  incident bar was met by class, on the owner's call (**DD-051**).

- 2026-10-26 — **16.0.0 (drafted, MAJOR, owner): a unit owes the review of what it was set to
  change, and a decision says whether its evidence was measured, estimated or reported**
  (Session discipline 10–11). The 15.2.0 draft rides it whole (**DD-050**).

- 2026-10-26 — **15.2.0 (drafted): the session banner says when a branch or worktree that builds
  on HEAD has a newer `docs/STATE.md`**, by ancestry and that file, never this branch's name; a
  freshly cut HEAD is judged against the default branch only. Owner-directed, between
  cc-safe-setup Units 3 and 4 (**DD-049**).

- 2026-10-23 — **15.2.0 (drafted), cc-safe-setup Unit 3: the command guard denies the pre-push
  rail's off switches**: `git push --no-verify`, a `core.hooksPath` override on a push, and
  `git config` setting `core.hooksPath`. A `--config-env` that hid a force push from every rail
  is closed too (**DD-048**).

- 2026-10-23 — **15.2.0 (drafted), cc-safe-setup Unit 2: the push rail reads a short-flag
  cluster as git does**, so `git push -uf` and `-qd` are denied and the legal `git push -uo f
  origin <branch>` is no longer denied as naming two refs (**DD-047**).

- 2026-10-23 — **15.2.0 (drafted), cc-safe-setup Unit 1: the command guard removes a
  backslash-newline before it reads a command**, so `rm \⏎-rf /` is denied for good and
  `git push \⏎-u origin session/x` is no longer denied as naming two refs (**DD-046**).

- 2026-10-22/23 — **cc-safe-setup plan drafted, then approved whole by the owner**: six
  command-guard units from measuring that collection's bypass shapes against this guard, Unit 5
  at the block tier, one fresh-context review pass per unit.

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
