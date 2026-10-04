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
Adopted harness version: **AMH 15.0.1** — see `harness/VERSION`, the copy that counts.

## Current state

This tree declares **15.0.1**: the author-identity rung sets aside the forge's test merge a
pull-request CI checks out — two parents, the first already in the base, no branch at it — and
judges `origin/<default>..HEAD^2` instead, with a `note` line saying so (**DD-036**). Under it is
15.0.0 — a deletion aimed at the filesystem root or a home directory is permanently denied, an
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

**OPEN — tag the drafted 15.0.1 release after its PR merges.** Tagging is an owner action, and
the README Quick Start follows the release playbook by naming the draft tag before it exists.
Check: `git ls-remote --exit-code --tags origin refs/tags/amh-v15.0.1` — a matching ref resolves
this item; no output means the documented install command is not live yet.

**OPEN — nothing has observed the new `PostToolUse` redaction hook actually firing, and no
session can.** `scripts/redact-tool-output.sh --self-test` settles this repository's half —
payload handling, leaf accounting, result-shape preservation — and settles nothing about whether
Claude honours `updatedToolOutput` or Codex honours block-and-feedback, because a session cannot
reload its own hook set to find out. Both contracts fail open on hook failure, as does a missing
`python3`, so a hook that never fires looks exactly like a tree with no credential in its output
(**DD-015**, **DD-017**). Only a session that starts with either adapter loaded and sees a
redaction marker in a tool result settles that adapter. Check: `scripts/redact-tool-output.sh
--self-test` — all checks passing means the script is sound, and is NOT evidence either hook ran.

**OPEN — nobody has run a pinned hook on a host where Git bash cannot be found at all.** Two
hosts have now run the pinned arm where discovery SUCCEEDS — the second, reported 2026-09-10, saw
a pinned guard pass its self-test and actually fire mid-session, so pinned hooks demonstrably deny
on Windows (**DD-014**); bash being off `PATH` is not the failing case, which is why the WSL hazard
was withdrawn (**DD-010**). Still unobserved is discovery finding NOTHING: that path is read from
the shipped code, and how it fails differs between the bundles read (**DD-011** for the method).
Low stakes — both readings are loud — and no check settles it short of that host.

**OPEN — the `printf | grep -q` class survives at 73 non-comment sites.** Unit 3 fixed the two
with reachable unbounded input; the residue was safe on bounded, mostly single-line input rather
than on a loud direction when last classified, but the fixture/non-fixture split has not been
recounted since the output-redaction rail landed. The 2026-09-29 installer fixtures added seven,
all asserting on short installer output in the loud direction; the redaction self-test's python3
fix then added four on one hook response each (two in the quiet direction, bounded far below a
pipe buffer), and the Claude matcher check one on a JSON group, loud. Not queued as work; reopen
if any starts matching something unbounded. Check: `grep -rn "printf.*| *grep -q" --include=*.sh
scripts/ harness/templates/` prints 79 lines, 6 of them comments — resolved only if that stops
matching the description, which it deliberately does not (**DC-038**).

**OPEN — the 2026-08-29 `path-refs.sh` false failure on `` `session-start.sh` `` still has no
reproducer.** Closed once as the EPIPE defect, then restored when the pass falsified that
(**DC-035**, **DC-029** for the residue): a listing git completed, reported success for, and cut
short anyway. No check; only a recurrence settles it.

**OPEN — the destructive rail sees no Windows shell, and two reported incidents live there.** The
owner's (2026-08-29) `cmd /c "rd /s /q ..."` resolved to the root of `D:` through a
backslash-quote mismatch, pairing with the Antigravity `rmdir /s /q d:\` (**DC-027**). Which
layer mis-parsed is unsettled and matters to whoever builds the arm; a Windows arm is the owner's
call since the harness targets bash. No check until a session builds it.

**OPEN — two permanent-denial edges the fold unit found and left (DD-035).** Misses, and
widening is yours: `~/.?*`, `~/.??*`, `~/.[!.]*`, git's `-- '.?*'` under a home `-C`, and bracket
globs such as `/[!.]*` keep the advisory while `~/.*` is denied. A false positive, a defect: the
segment splitter reads a brace expansion's `{` as a separator, so `rm -rf ~/{.cache,.npm}` is
judged as `rm -rf ~/` and denied for good. Check: each twice through `scripts/command-guard.sh
--command` under one `DESTRUCTIVE_ADVISORY_STATE` — `2 0` on a miss or `2 2` on the brace form
means still open.

**OPEN — the pin check is repo-local, and whether adopters get one is yours.**
`scripts/guards/adapter-set.sh` now fails on a Claude hook missing `"shell": "bash"`, but it is
this repository's own guard: an adopter's ladder still checks nothing, exactly as 14.1.0's
Upgrading note says. Shipping it means a rung in the shipped `ladder.sh` keyed to one vendor's
adapter file — an agent-agnosticism question as much as a version-semantics one (additive, so
MINOR), and adjacent to the shipped config-schema guard already declined pre-3.0.0 (**DA-022**),
which is why it is yours rather than a unit's. Recommendation: ship it gated on the file
existing, so a repo with no Claude adapter is unaffected (**DD-013**).
Check: `grep -c '"shell": "bash"' harness/templates/scripts/ladder.sh` — a non-zero count means
it shipped; `0` means adopters still have only the hand step.

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
  judges a State sentence's temporal validity (**DD-006**); widening the command guard's hook
  matcher to PowerShell before a Windows arm exists (**DD-012**).

## Changelog

One line per shipped change or completed unit (newest first). Details live in the cited ledger
rows — this section is a pointer index, not a narrative.

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
