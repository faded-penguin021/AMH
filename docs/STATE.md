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
Adopted harness version: **AMH 14.2.0** — see `harness/VERSION`, the copy that counts.

## Current state

This tree declares **14.2.0**: both first-class adapters wire post-execution output redaction, so
`scripts/redact-tool-output.sh` filters the string leaves of a tool result — one `redact.sh`
invocation per leaf — before the context window reads it. Claude replaces the result in place;
Codex blocks the original and supplies filtered feedback because its PostToolUse contract does
not rewrite arbitrary results (**DD-015**–**DD-017**). 14.1.0's shell pin still stands under it (**DD-007**–**DD-012**).
Whether this draft is tagged or
released is not recorded here — `scripts/session-start.sh` probes it every session and reports
present, absent or could-not-ask, which is the only answer that can be right twice.

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

**OPEN — tag the drafted 14.2.0 release after its PR merges.** Tagging is an owner action, and
the README Quick Start follows the release playbook by naming the draft tag before it exists.
Check: `git ls-remote --exit-code --tags origin refs/tags/amh-v14.2.0` — a matching ref resolves
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

**OPEN — the `printf | grep -q` class survives at 61 non-comment sites.** Unit 3 fixed the two
with reachable unbounded input; the residue was safe on bounded, mostly single-line input rather
than on a loud direction when last classified, but the fixture/non-fixture split has not been
recounted since the output-redaction rail landed. Not queued as work; reopen if any starts
matching something unbounded. Check: `grep -rn "printf.*| *grep -q" --include=*.sh scripts/
harness/templates/` prints 67 lines, 6 of them comments — resolved only if that stops matching
the description, which it deliberately does not (**DC-038**).

**OPEN — the 2026-08-29 `path-refs.sh` false failure on `` `session-start.sh` `` still has no
reproducer.** Closed once as the EPIPE defect, then restored when the pass falsified that
(**DC-035**, **DC-029** for the residue): a listing git completed, reported success for, and cut
short anyway. No check; only a recurrence settles it.

**OPEN — the destructive rail sees no Windows shell, and two reported incidents live there.** The
owner's (2026-08-29) `cmd /c "rd /s /q ..."` resolved to the root of `D:` through a
backslash-quote mismatch, pairing with the Antigravity `rmdir /s /q d:\` (**DC-027**). Which
layer mis-parsed is unsettled and matters to whoever builds the arm; a Windows arm is the owner's
call since the harness targets bash. No check until a session builds it.

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

- 2026-09-13 — **14.2.0: the Codex adapter now redacts successful tool output.** Its new
  all-tool PostToolUse hook runs the shared leaf filter; when a known shape changes, Codex's
  block-and-feedback contract withholds the original from the model and returns filtered text,
  while Claude's existing path still replaces the native result in place (**DD-017**).

- 2026-09-12 — **14.2.0: the Claude adapter redacts tool output after execution, completing the
  half of P17 that had never been wired.** The adapter's "this agent has no output-filter hook"
  was true when written and is now false, so a `PostToolUse` hook runs the new shipped
  `scripts/redact-tool-output.sh`, which walks the string LEAVES of `tool_response`, filters each
  through `redact.sh` in its own invocation and rebuilds the response in place — the RFC's own
  "filter the response" shorthand was measured and prints a marker over a live private key, and
  the mandatory review then measured that batching the leaves lets one leaf's open sed range
  rewrite another's (**DD-016**). Fail-open by the host's design, successful tool calls only,
  known shapes only, `python3` or nothing, and configured rather than observed: all five bounds
  ship in the adapter prose, and `scripts/guards/adapter-set.sh` fails on the wiring's absence
  because that absence is invisible from a green tree (**DD-015**).

- 2026-09-10 — **A rung now reports an absent Claude `shell` pin.** `scripts/guards/adapter-set.sh`
  requires the exact `"shell": "bash"` line under every `"type": "command"` entry in both Claude
  adapter copies, and reports UNVERIFIED for an entry whose layout its line matcher cannot read
  (**DD-013**, **DD-014**). Observed 2026-09-10: `amh-v14.1.0` was cut and sat on `main`'s history
  at the commit `origin/main` then pointed to.

- 2026-09-09/10 — **14.1.0: the Claude adapter pins the shell its hooks run under, and says what
  the pin does not reach.** All hooks set `shell` to bash, so an undiscoverable Git bash fails
  visibly instead of going to the Windows file association, which runs a bare `.sh` detached and
  reports rc=0. The rule-review pass established that the guard's `Bash` matcher never fires on
  that host at all, the WSL hazard was withdrawn on measurement, and the owner declined the
  `Bash|PowerShell` widening (**DD-007**–**DD-012**).

- 2026-09-02 — **14.0.0: working memory is tree-relative.** `Current state` records what stays
  true of the checked-out tree and stops caching merge, tag, release, CI and forge-setting status
  (**DD-006**).

- 2026-09-02 — **A ledger row pins its text, not the file it names**, and the frozen archive left
  the path scan in the same change (**DD-004**, **DD-005**).

- 2026-09-02 — **Thresholds name their behavior and historical ledger paths stay immutable**
  (**DD-003**, corrected by **DD-004**).

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
