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
Adopted harness version: **AMH 14.1.0** — see `harness/VERSION`, the copy that counts.

## Current state

This tree declares **14.1.0**: the Claude adapter pins the shell its hooks run under, so that
layer is not replaced by PowerShell per host — and states where the pin does not reach and what
it costs (**DD-007**–**DD-012**). Whether that version is tagged or
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

**OPEN — nobody has run a pinned hook on a host where Git bash cannot be found at all.** Two
hosts have now run the pinned arm where discovery SUCCEEDS — the second, reported 2026-09-10, saw
a pinned guard pass its self-test and actually fire mid-session, so pinned hooks demonstrably deny
on Windows (**DD-014**); bash being off `PATH` is not the failing case, which is why the WSL hazard
was withdrawn (**DD-010**). Still unobserved is discovery finding NOTHING: that path is read from
the shipped code, and how it fails differs between the bundles read (**DD-011** for the method).
Low stakes — both readings are loud — and no check settles it short of that host.

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

- 2026-09-10 — **A rung now reports an absent Claude `shell` pin, which until now was a hand step nothing checked.** `scripts/guards/adapter-set.sh` requires the exact `"shell": "bash"` line under every `"type": "command"` entry in both the shipped template and the reference copy, and reconciles a layout-independent entry count against what its line matcher actually read, so an entry in a layout it cannot parse reports UNVERIFIED instead of passing. Earned by a downstream 14.1.0 field report whose positive control also showed a pinned guard denying on Windows, and whose headline exposure claim its own bounds withdraw (**DD-013**, **DD-014**). Observed 2026-09-10 while closing the release item: `amh-v14.1.0` is cut and sits on
  `main`'s history, at the same commit `origin/main` points to.

- 2026-09-09/10 — **14.1.0: the Claude adapter pins the shell its hooks run under, and says
  what the pin does not reach, what it costs, and what nobody has run.** All three hooks set the
  `shell` field to bash, so a host whose Git bash is undiscoverable should fail visibly instead
  of handing a bare `.sh` to a file association that runs it detached, feeds it a tty instead of
  the hook payload, and is not waited on. The rule-review pass established that the command
  guard's `Bash` matcher never fires on that host at all — queued as an owner fork rather than
  fixed under cover of a shell pin — and a second pass established that the pinned arm itself
  was never run, that an invalid VALUE drops a whole hook entry, and that `bash` may resolve to
  WSL's in another namespace. That last hazard was then withdrawn on measurement — the pinned
  shell is not resolved through `PATH`, so no host is misrouted to WSL — and the unknown-key
  question was settled at the shipped schema rather than by proxy: the entry survives, so the
  pin is inert on a build predating the field (**DD-007**–**DD-011**). The owner declined the
  `Bash|PowerShell` widening; the guard stays honestly absent there (**DD-012**). Observed
  2026-09-09 while closing the previous release item: 14.0.0 is merged and `amh-v14.0.0` sits
  on `main`'s history.

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
