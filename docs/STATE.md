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

- `2026-11-01-harness-research-gaps.md`, adopted: every unit done, H4b's follow-up last
  (**DD-103** to **DD-105**), except H8, parked. Before a unit starts the session names the
  decisions it needs and waits for the answers; a fresh-context review is pre-allowed for every
  unit (owner, 2026-11-09).
- `2026-11-04-spill-guard-borrowings.md`, adopted: S1, S2, S6a and S3 approved on 2026-11-10, to
  run in that order, each with its own review and its version settled when its behaviour is
  final (its §2, items 4 and 5); S4, S5, S6b and S6c deferred.
- `2026-11-10-command-guard-gap-review.md` and `2026-11-09-cc-safety-net-borrowings.md`: drafts,
  nothing approved; G1, one review of both, comes first (Owner queue).
- `2026-11-10-queue-cycle-and-memory-tiers.md`: a draft, nothing approved.
- `2026-11-19-pipefail-grep-race.md`, adopted, its one unit R1 done (**DD-110**); the session
  that merges the train archives it.

Operational gotchas:

- A poison token in a squash-merge message suppresses the release commit's CI run entirely. Edit
  the squash message before merging; the guard checks branch commits, not the forge's message
  (**DC-040**).
- Nothing checks that every version with a changelog entry got a tag, so a merged release can
  sit untagged with every rung green (**DA-010**); `git ls-remote --tags origin` settles one.

## Owner queue

> **Protected section.** Never delete it, and never silently drop items during compression.
> Items leave only when done, answered or triaged — then delete the item and record the outcome
> as a Changelog line or a ledger row. How to test an item before restating it, and why the
> final chat message must: `docs/PROTOCOLS.md` → **Session discipline** 7.

**OPEN — decide whether to plan a fix for a quote inside backticks.** Bash ends a backtick
substitution at the first unescaped backtick, quotes or not, while every walker in the command
guard reads a `'` inside one as opening a string that hides the rest; no plan covers it, the
guard's header names it, and it reaches heredoc bodies too (**DD-059**).
Check: `scripts/command-guard.sh --command "echo \`echo 'x\`; printenv"` — exit 0 means open.

**OPEN — the research-gaps plan's remaining §1 decisions.** Whether P6 admits retiring a
compensation stays open until one is proposed, with H5's classification as input (**DD-082**);
an H8 incident-bar exception is asked if H8 reopens; the combined order is the item below. No
check settles it.

**OPEN — run G1, one gpt-6-astra `-e high` review of both command-guard plans,
`docs/plans/2026-11-10-command-guard-gap-review.md` and
`docs/plans/2026-11-09-cc-safety-net-borrowings.md`, then decide adoption of both together and
which units** (owner, 2026-11-10, with N1's mandate, the gap plan's §2, item 2).
Check: `scripts/command-guard.sh --command 'rm -r ~'` — exit 0 means that gap is still open.

**OPEN — decide on the queue-cycle plan, `docs/plans/2026-11-10-queue-cycle-and-memory-tiers.md`:
review first (M1), adoption, and the facts its §2, item 3 asks for.** No check settles it.

**OPEN — decide the N1 review's last recommendation it could not apply:** the cross-plan order
and release placement in that plan's §2, decision 3; H0.5's recommended order is in the
research-gaps plan's §7.1. No check settles it.

**OPEN — tag `amh-v17.0.0` once this train is merged.** MAJOR (owner, 2026-11-17, **DD-094**),
no longer blocked by H4b (owner, 2026-11-19, **DD-103**). Tagging is an owner step, and the README's clone command names the
tag. Check: `git ls-remote --tags origin amh-v17.0.0` — no output means open.


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
- **2026-11-19:** a payload-parser fix for a non-UTF-8 code page until a host can test it
  (**DD-069**); a guard for a fix that changes an existing test until an incident earns one
  (**DD-073**); a `find` arm for the permanent targets, N8 (**DD-018**); all three **DD-106**.

## Changelog

One line per shipped change or completed unit (newest first). Details live in the cited ledger
rows — this section is a pointer index, not a narrative.

- 2026-11-19 — **Pipefail race, R1: every pipe into an early-exit reader under `pipefail` whose
  status decides something audited, 109 fixed, the rest recorded with why they cannot race**
  (**DD-110**).
- 2026-11-19 — **PR #75 review fixes, F3, the last unit: the command guard's advisory state —
  an override read alone, the reports' union across both directories, one directory read once,
  and only a regular file a spent marker; the plan is archived to
  `docs/history/2026-11-19-pr75-review-fixes.md`** (**DD-109**).
- 2026-11-19 — **PR #75 review fixes, F2: the bootstrap warns of an advisory marker it cannot
  clear, the fixture suite counts skips apart, and the installer reads `RULE_FILES` as the ladder
  does** (**DD-108**).
- 2026-11-19 — **PR #75 review fixes, F1: the 17.0.0 Upgrading text, the README and the seed
  ledger corrected; every finding reproduced and fixed** (**DD-107**).
- 2026-11-19 — **Owner: three queue items closed on the session's recommendation** — no
  non-UTF-8 parser fix until testable, no test-change guard until an incident, no `find` arm
  (**DD-106**).
- 2026-11-19 — **H4b follow-up, the last: the machine-mode fragment drops its `//proc` rules
  under `adapter-set.sh`, the README claims only the passed sandbox cells, and acceptance (f)
  passed in both arms** (**DD-104**, **DD-105**).
- 2026-11-19 — **The owner cleared DD-088's tag block and chose to drop the machine-mode
  `//proc` rules,** each on the session's recommendation (**DD-103**).

- 2026-11-18 — **H4b follow-up: the last owner-box run, two runs at `7d44ff5`, recorded**
  (**DD-099** to **DD-102**, `2026-11-01-harness-research-gaps-h4b-results.md` §5).
- 2026-11-18 — **H4b follow-up: `2026-11-01-harness-research-gaps-h4b-probe.sh` repaired for the
  last box run** (**DD-098**).
- 2026-11-18 — **Owner: an advisory whose marker cannot be written fires** (**DD-097**).
- 2026-11-13 through 2026-11-17 — **The research-gaps plan's units and H4b follow-ups, folded**
  (**DD-072** to **DD-096**, the plan's §1 and §5, companions
  `2026-11-01-harness-research-gaps-h1-inventory.md`,
  `2026-11-01-harness-research-gaps-h2-relocation.md`,
  `2026-11-01-harness-research-gaps-h3-layout.md`,
  `2026-11-01-harness-research-gaps-h4a-containment.md`,
  `2026-11-01-harness-research-gaps-h5-classification.md` and
  `2026-11-01-harness-research-gaps-h6-runs.md`).
- 2026-07-25 through 2026-11-12 — **Everything before that, folded.** Founding through the
  17.0.0 draft (**DD-001** to **DD-073**, **DC-020** to **DC-044**, and the volumes before them;
  `docs/history/`).
