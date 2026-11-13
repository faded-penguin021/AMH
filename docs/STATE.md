# STATE — project state & session memory

> **Length guard.** Thresholds are in `amh.conf`; the rules for compressing this file are
> `docs/PROTOCOLS.md` → **Working-memory compression**, and they bind whether or not you follow
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
Adopted harness version: **AMH 17.0.0** — see `harness/VERSION`, the copy that counts.

## Current state

Release state: `scripts/session-start.sh` probes the declared version's tag every session.
`docs/LEDGER_D.md` is the live ledger volume.

Live plans, each in `docs/plans/`, where a unit starts only on the owner's explicit approval of
that unit:

- `2026-11-01-harness-research-gaps.md`, adopted; H0, H0.5, H9, H1, the H9 fix, H4a, H2, H3,
  H5 and H7 done, and H4b done as configuration with its live probes owed (Owner queue). Every unit rides
  17.0.0 (owner, 2026-11-13). Before a unit starts the session says which decisions it needs and
  waits for the answers, and a fresh-context review is pre-allowed for every unit (owner,
  2026-11-09).
  - [ ] H6b — approved 2026-11-13, to follow H7
  - [ ] H6a — waits on the owner's runs (Owner queue); H8 parked
- `2026-11-04-spill-guard-borrowings.md`, adopted: S1, S2, S6a and S3 approved on 2026-11-10, to
  run in that order, each with its own review and its version settled when its behaviour is
  final (its §2, items 4 and 5); S4, S5, S6b and S6c deferred.
- `2026-11-10-command-guard-gap-review.md` and `2026-11-09-cc-safety-net-borrowings.md`: drafts,
  nothing approved; G1, one review of both, comes first (Owner queue).
- `2026-11-10-queue-cycle-and-memory-tiers.md`: a draft, nothing approved.

Operational gotchas:

- A poison token in a squash-merge message suppresses the release commit's CI run entirely. Edit
  the squash message before merging; the guard checks commits on a branch, not the message the
  forge composes at merge time (**DC-040**).
- Nothing checks that every version with a changelog entry actually got a tag, so a merged
  release can sit untagged with every rung green (**DA-010**). `git ls-remote --tags origin`
  settles any version.

## Owner queue

> **Protected section.** Never delete it, and never silently drop items during compression.
> Items leave only when done, answered or triaged — then delete the item and record the outcome
> as a Changelog line or a ledger row. How to test an item before restating it, and why the
> final chat message must: `docs/PROTOCOLS.md` → **Session discipline** 7.

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

**OPEN — the research-gaps plan's remaining §1 decisions, including those H0.5 added.** Whether
P6 admits retiring a compensation: left open on 2026-11-13, when H5 started, until a specific
retirement is proposed, with H5's classification as its input (**DD-082**). An H8 incident-bar
exception is asked if H8 is reopened. The plan's §7.1 also recommends a combined order across
all three plans, which an item below owns. No command settles this.

**OPEN — decide whether the seed constitution's rail and deletion-layer descriptions move out
of it, as H2 moved this repository's.** H2 left them for H3 because a light install had no
runbook to receive them; H3 removed light, so every install now has `docs/RUNBOOK.md`, but
moving a live rule is the owner's call and H3 did not (**DD-081**). The passages are listed in
`docs/plans/2026-11-01-harness-research-gaps-h2-relocation.md` §7. No command settles this.

**OPEN — run H4b's live sandbox probes, on your own host or in a session you name (evidence:
**DD-079**).** H4b shipped the Claude sandbox block as configuration only, and every cell is
unverified: no sandbox can start on the host that built it. The probes are the plan's H4b
acceptance (b) to (d), (f) and (g), with the list in the H4a companion's §7: an in-tree write
passes and an out-of-tree one is refused, each with a positive control; network; on WSL2 a
harmless Windows-program launch; startup without `bwrap`; worktrees, temporary files, git and
the session bootstrap; the full ladder inside the sandbox; and an old adapter left untouched by
the Upgrading step. A follow-up then claims only the cells that pass. Check on a candidate host:
`command -v bwrap socat && unshare -Ur true` — success there means the sandbox can at least start.

**OPEN — say whether you can launch H6a's subject runs.** The launch recipe was given on
2026-11-13: `conformance/runners/local-clone.sh --keep` per scenario and run, in a throwaway
container, with each run's log, model and settings handed back. No command settles this.

**OPEN — run G1, one gpt-6-astra `-e high` review of both command-guard plans,
`docs/plans/2026-11-10-command-guard-gap-review.md` and
`docs/plans/2026-11-09-cc-safety-net-borrowings.md`; then decide whether to adopt them, together,
and which units.** Owner, 2026-11-10: one review covers both, with the mandate N1 had (the gap
plan's §2, item 2), and adoption is decided for both together. Check for one of the gap plan's gaps: `scripts/command-guard.sh --command 'rm -r ~'` — exit status 0 means a recursive
deletion of the home directory without `-f` still passes the permanent denial.

**OPEN — decide on the queue-cycle plan, `docs/plans/2026-11-10-queue-cycle-and-memory-tiers.md`:
whether it is reviewed first (M1), whether to adopt it, and the downstream facts its §2, item 3
asks for.** No command settles this.

**OPEN — decide two recommendations from that review that it had no authority to apply.** (1)
Whether to reconsider a `find` arm for the permanent targets, which **DD-018** chose not to take
(the plan's N8). (2) The cross-plan order and release placement in that plan's §2, decision 3, which
reach the spill-guard and research-gaps plans; H0.5's recommended order is in the research-gaps
plan's §7.1, and it did not change that plan's standing here.

**OPEN — decide whether the test-first rule is MAJOR or MINOR, then tag once this train is
merged (evidence: **DD-073**).** Drafted as MAJOR 17.0.0, because the owner ruled the two
session-discipline rules of 16.0.0 MAJOR (**DD-050**) and this is a third of that kind. The other
reading is MINOR 16.2.0, a new principle an adopter may take or leave; choosing it means changing
the five version copies and the changelog's Upgrading wording. Recommendation: MAJOR, to match
that ruling. The README's clone command names the drafted tag.
Check: `git ls-remote --tags origin 'amh-v17.0.0' 'amh-v16.2.0'` — no output means neither is
tagged.

**OPEN — decide whether to build a guard for a fix that changes an existing test (evidence:
**DD-073**).** The rule is prose-only. A diff shows a modified or deleted test file, so a WARN-only
advisory over configured test paths, like the `RULE_FILES` one, is buildable. No violation is
recorded here, and a guard is earned by an incident, so the session built none. Recommendation:
wait for one. No check settles this; the owner does.

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

- 2026-11-13 — **H7 of the research-gaps plan done: conformance scenario
  `03-refused-deletion`, seeded on DD-038,** judging the refused path, an outside sentinel and
  the rail by final state only; never run against an agent (**DD-083**).
- 2026-11-13 — **H5 of the research-gaps plan done: every binding obligation in both
  constitutions and both Session discipline sections classified as invariant, compensation or
  mixed,** with provenance and a failure condition for each compensation, in
  `docs/plans/2026-11-01-harness-research-gaps-h5-classification.md`. Nothing retired; the owner
  left the P6 question open (**DD-082**).

- 2026-11-13 — **H3 of the research-gaps plan done: the procedures every session is bound by
  move to `docs/PROTOCOLS.md`, in the seed and in this repository, and the `light` profile is
  removed, `standard` becoming the default,** on the owner's answers taken when H3 started; the
  installer reports an unfinished hand migration, and the documentation-navigation guard checks
  each pointer against the file it names. Layout, migration and measurements are in
  `docs/plans/2026-11-01-harness-research-gaps-h3-layout.md` (**DD-081**). Rides the 17.0.0
  draft.
- 2026-11-13 — **H2 of the research-gaps plan done: the host-rail and deletion-rail descriptions
  moved from `AGENTS.md` to the new runbook section Host rails and what they miss,** every
  binding sentence kept and the seed left for H3, on the owner's answers taken when it started;
  `AGENTS.md` 15,274 → 12,338 bytes. The mapping and the acceptance outputs are in
  `docs/plans/2026-11-01-harness-research-gaps-h2-relocation.md` (**DD-080**). Rides the 17.0.0
  draft.
- 2026-11-13 — **H4b of the research-gaps plan, as configuration: the Claude adapter turns on
  Claude Code's sandbox, and `adapter-set.sh` validates both adapters' sandbox configuration,**
  on the owner's answers taken when it started; every containment cell is unverified until the
  live probes in the Owner queue run (**DD-079**). Rides the 17.0.0 draft.
- 2026-11-13 — **H4a of the research-gaps plan done: the sandbox containment design,** in
  `docs/plans/2026-11-01-harness-research-gaps-h4a-containment.md`, on the owner's answers taken
  when it started: Claude Code on native Windows keeps no sandbox and says so, and nothing is
  claimed contained before H4b's probes (**DD-078**).
- 2026-11-13 — **`CLAUDE.md` is now `@AGENTS.md` plus a one-line fallback, root and seed,** so
  Claude Code loads the constitution as an import rather than a read it may skip; a headless
  canary test confirmed the import (**DD-077**). Rides the 17.0.0 draft.
- 2026-11-13 — **The H9 fix: the ladder, and the placeholder and ledger guards, exit red saying
  they checked nothing when their scratch path cannot be made** (**DD-076**). Rides the 17.0.0
  draft.

- 2026-11-13 — **H1 of the research-gaps plan done: what each session must read, item by item,**
  in `docs/plans/2026-11-01-harness-research-gaps-h1-inventory.md`, which re-checks itself on replay. Its finding for H3: a
  light install is told to read a runbook and ledger it never gets (**DD-075**).

- 2026-11-13 — **The incident bar no longer gates the command guard:** the owner's answer of
  2026-11-10, legislated in P13 for `command-guard.sh` in every mode, the scope the owner chose
  (**DD-074**). No guard behaviour changed; it rides the 17.0.0 draft.

- 2026-11-13 — **The owner approved H1, and after it the fix H9 recommended (**DD-072**),** which
  answers the Owner-queue item on whether to fix it.

- 2026-07-25 through 2026-11-12 — **Everything before that, folded.** Founding through the
  17.0.0 draft (**DD-001** to **DD-073**, **DC-020** to **DC-044**, and the volumes before them;
  `docs/history/`).
