# Plan — easier instantiation, and verdicts on the instantiation RFC

> **Provisional, and disposable (AMH P16).** Owner-approved 2026-07-27. The unit checklist is
> mirrored in `docs/STATE.md`; the owner may pivot mid-feature, and each unit ends shippable so
> dropping a later one costs nothing. **This file is deleted by its final unit** — by then its
> durable content lives in `docs/STATE.md` changelog lines and `DA-NNN` ledger rows. Nothing
> ever cites it: plans die, the ledger does not (P11).

## Context

Two things arrived together, and they turn out to be one change.

**The owner's ask.** Adopting AMH today costs the repo owner real work: clone the meta-repo,
run `scripts/amh-init.sh`, then hand-fill ~24 `{{PLACEHOLDER}}` slots across the seed prose
(`harness/PLACEHOLDERS.md` lists them), write `scripts/verify.sh`, and drive
`scripts/ladder.sh` from red to green. Every one of those is work an agent sitting *in the
adopting repo* could do better than the owner — it can read the repo. The owner should have
to paste a command block and a sentence, and nothing else. That is P0 applied to adoption
itself: the harness's own onboarding is currently its worst owner-attention cost.

**The RFC.** A peer LLM proposes (1) a "Repository Materializer" — a sync CLI that
materializes transparent repo artifacts — and (2) a "Configurable Assurance Model" — light /
medium / heavy strictness. An independent DeepSeek review accepts (1) one-way and recommends
composable feature flags in `amh.conf` for (2). This plan records architectural decisions on
both, and implements only the part that is both earned and owner-approved.

The verdicts below are the substance of this plan; the implementation is deliberately small
because most of what the RFC asks for **already exists** and one part of it is **not yet
earned** under this repo's own bar (`CONTRIBUTING.md`: new machinery needs an incident, not a
hypothesis).

---

## Part 1 — Architectural Decision Records

### ADR-1: Repository Materializer — **ACCEPT the boundary, REJECT the new machinery**

The materializer is already built and already one-way. `scripts/amh-init.sh` writes into a
target tree, overwrites exactly the shipped scripts, never clobbers a word the adopter owns,
and is idempotent (`scripts/tests/test-init-e2e.sh` asserts all three). Nothing it writes is
needed again after it exits: the shipped scripts are parameter-free and read `amh.conf` at
runtime (**D-002**), so the adopter's tree is independently executable with `bash`, `git` and
coreutils. The Reproducibility Invariant is intact and was never at risk.

- **P0:** satisfied — it removes owner decisions rather than adding a dependency.
- **P3:** satisfied — no artifact it writes is a self-report.
- **`scripts/guards/copy-drift.sh`: zero impact.** That guard compares `scripts/*.sh` against
  `harness/templates/scripts/*.sh` *inside the meta-repo*. The materializer sits downstream of
  that boundary and does not cross it.
- **Direction: strictly one-way (pull).** Agreed with the independent review, for a reason it
  did not state: bidirectional sync would import merge semantics into a path deliberately
  designed as a copy, and a local edit flowing upstream would break the repo-agnosticism that
  makes `cmp` a valid dogfooding proof (**D-002**, **D-003**). Contributions go back as PRs to
  the meta-repo — a different mechanism, not a sync direction.
- **REJECT: a packaged CLI** (npm / brew / a binary). It adds a dependency the harness
  forbids itself, and it puts a tool between the agent and the raw source, which is the exact
  opacity the RFC's own rationale argues against.
- **REVISE the boundary statement.** "The CLI owns transport; the repository owns execution"
  is imprecise — init also substitutes init-time placeholders, which is materialization, not
  transport. The accurate invariant, and the one to write into the prose:
  > **Nothing `amh-init.sh` does may be needed again after it exits.** The tree it leaves
  > behind is self-describing and independently executable; the harness is never on the
  > runtime path.

**Flawed assumption, called out.** "Manual file copying guarantees version drift across an
adopter's fleet" conflates two things. Drift *from upstream* is a supported, documented state
(`docs/UPGRADING.md` — no telemetry, no auto-update, no deprecation clock; staying behind is
often correct). The harmful drift is *local edits to shipped scripts*, which turns every
future upgrade into a merge. That one is detectable offline, with a checksum manifest written
at release and a shipped guard comparing `scripts/*.sh` against it.

**Owner decision (2026-07-27): adopt it now, ahead of the incident bar.** My recommendation was
to defer — zero adopters means zero incidents, and this repo declines guards built for
hypotheticals (`CONTRIBUTING.md`; **D-010**). The owner overrode it, and the reasoning is
recorded rather than buried: with no adopters, the incident can only be discovered *at an
adopter's expense*, and they are the one party who cannot pay it. The deviation from the
incident bar is itself ledgered — this is the second guard in this repo's history admitted
before its violation, and the first admitted by owner decision rather than by the drift
occurring. See U2 for the shape.

### ADR-2: Configurable Assurance — **REVISE (reject both presented topologies)**

- **REJECT materialized topology (A).** Generating structurally different scripts per level
  re-creates the rendered-vs-template drift class that **D-002** deleted, and breaks the `cmp`
  guard that makes the dogfooding claim checkable. It is a decided non-item; the RFC brings no
  new evidence.
- **REJECT feature flags in `amh.conf` (B / the independent review's recommendation).** This
  is my one substantive disagreement with DeepSeek. `amh.conf` is in `RULE_FILES` *precisely
  because* editing it is a rule change — the comment in the file says a missing entry would
  let an agent raise `STATE_HARD_KB` or blank `POISON_TOKENS` unreviewed. A guard-disabling
  flag makes "turn the red rung off" a supported one-line move: it hands a stuck session a
  green button, which is the Goodhart shape P3 exists to refuse and **D-019** ("a guard that
  can be disabled by something that is not its subject") already paid for once.
- **ACCEPT, as a synthesis neither the RFC nor the review proposes: assurance is already
  emergent from repository topology, and the missing piece is discoverability, not
  configurability.** Read `scripts/ladder.sh`: no ledger → `skip "no ledger yet"`; no
  `scripts/guards/` → `skip … 0 repo-local guard(s) ran`; `AUTHOR_EMAIL_ALLOW` unset → the
  zero-config half only, and the `ok` line says which. The rungs activate on **artifact
  presence**, never on a declared level. That is strictly better than a flag on P3 grounds: a
  flag is a claim about intent, presence is an artifact the work produces anyway.

  So the profile is an **init-time choice of what to install**, not a runtime switch:

  | Layer | Topology | Why |
  |---|---|---|
  | Shipped scripts | **parametric**, byte-identical for everyone | keeps `cmp`, keeps upgrades a copy (D-002/D-003) |
  | Seed prose | **materialized** — file-granular selection at init | copied once, owned thereafter, never drift-checked |
  | Runtime activation | **presence-derived** | no flag, no level, nothing to flip |

  After init there is no "level" anywhere in the tree to edit. Moving light → full is *adding
  files*, which is a visible diff and a real act.

- **Not levels, not flags, not policy bundles: an install manifest.** `light` / `standard` /
  `full` are names for which seed files land, consumed once and then gone. Nothing machine-
  readable records the choice — deliberately, so no future code can branch on it.

### ADR-3: Adoption is agent-work, not owner-work — **ACCEPT (this is the owner's ask)**

`amh-init.sh` writes `AMH-ADOPT.md` into the target repo (keep-policy, never clobbered). The
owner pastes two commands and one sentence at their agent; the agent fills the placeholders
from the repo it can read, writes `verify.sh`, prunes for the profile, drives the ladder
green, and deletes the file. **Acceptance is the ladder, not the brief** — `AMH-ADOPT.md`
carries no checkbox, and nothing downstream consumes anything it says (P3, **D-014**).

---

## Part 2 — Implementation

Sequential units, each ending green, committed and pushed (P5). Branch:
`claude/harness-instantiation-materializer-7xhxbr`, cut from `origin/main` — **the founding
train has merged** (`7d322d7`), so `docs/STATE.md`'s "ready for the squash merge" handoff is
stale and gets corrected in U1.

**Standing cost, stated up front:** `RULE_FILES` covers `AGENTS.md`, `amh.conf`,
`harness/templates` and `scripts/guards`, so *every unit below is a legislation diff*. P12
binds: one fresh-context reviewer per unit, strongest tier, blocking, one pass, **no
self-review fallback**. That means spawning a review subagent per unit — approving this plan
approves those spawns.

### U0 — Land the plan, then roll the ledger (first acts)

**Commit this plan into the repo** as `docs/plans/harness-instantiation.md` — `PLAN_DIR` in
`amh.conf` is `docs/plans`, which is exactly P16's home for a multi-session plan, and the
plan file is what makes the ADRs above readable by a future session before they reach the
ledger. Two obligations come with it, both mechanical:

- **`docs/STATE.md` must reference it by filename.** The ladder's local advisory warns on any
  file in `PLAN_DIR` that `docs/STATE.md` does not name (`scripts/ladder.sh:718`), and a
  mirrored checklist in the state file is P16's other half.
- **It dies at the last unit.** P16: at the final segment the plan file is deleted, because by
  then its durable content lives in changelog lines and `DA-NNN` rows — code and docs cite the
  ledger, never a plan, since the plan dies and the ledger does not (**D-030**'s reasoning
  applied to citations, P11's rule directly). U3 deletes it and drops the STATE reference in
  the same commit.

Then, the ledger rollover, per `docs/STATE.md`:

`docs/LEDGER.md` is at 826 lines against an 800-line cap. Create `docs/LEDGER_A.md` with the
same header discipline, numbering from **DA-001**. Every row this plan produces lands there.
Existing rows are never moved or renumbered. Verify: `scripts/ladder.sh --guards-only` — the
rollover rung must go from warn to ok, and the citation guard must still resolve `D-NNN`
across both volumes (`live_ledger()` globs `LEDGER_*.md`).

### U1 — The adoption brief

- **New:** `harness/templates/ADOPT.md` → installed as `AMH-ADOPT.md` at the target root,
  policy `keep`, mode 644, via the existing `install_file` in `scripts/amh-init.sh:269`.
  Content: what init just wrote and the shipped/yours split; fill the `{{…}}` slots, with
  `harness/PLACEHOLDERS.md` quoted for what each means; put real commands in
  `scripts/verify.sh`; the profile's pruning instructions; get `scripts/ladder.sh` green;
  **then delete this file.** No checkboxes, no "confirm you did X".
- **`harness/PLACEHOLDERS.md`:** any slot ADOPT.md carries needs a row, and if it is an `init`
  slot it needs an `INIT_PLACEHOLDERS` entry too — `amh-init.sh:220-232` dies on divergence,
  and `test-init-e2e.sh` case 4 asserts both directions. Prefer reusing existing `init` slots
  (`AMH_VERSION`, `DEFAULT_BRANCH`) over inventing new ones.
- **`README.md`:** Quickstart becomes the two commands plus one sentence. No prompt text
  duplicated into the README — the brief has exactly one home, so there is no drift class and
  no guard is needed for one.
- **`scripts/tests/test-init-e2e.sh`:** assert `AMH-ADOPT.md` lands, and that a re-run does not
  clobber an edited one (mirrors the existing `amh.conf` assertion at `:146`).

### U2 — `--profile light|standard|full`, defaulting to **light**

- `scripts/amh-init.sh`: new option, validated in the `--merge-mode` style (`:177`) — an
  invalid value dies at init rather than inside a guard in someone else's repo. It selects
  which `harness/templates/seed/**` files are installed, file-granular only:
  - **`light` — the default** (owner decision): `AGENTS.md`, `CLAUDE.md`, `docs/STATE.md`,
    `scripts/verify.sh`. This is the README's "smallest useful subset" made executable:
    constitution + state file with an Owner queue + one verification command.
  - `standard` — `+ docs/RUNBOOK.md`, `docs/LEDGER.md`
  - `full` — everything, today's behaviour
- **The default is light, but nothing assumes it.** `AMH-ADOPT.md`'s **first instruction** is
  that the agent asks the owner which profile they want, presenting the three with their
  costs, before touching a placeholder — P8 applied to the one decision the tool must not
  make for them. Escalating is a re-run: `amh-init.sh --profile standard .` adds the missing
  seeds and, because everything already present is keep-policy, changes nothing the adopter
  has written. That is the whole upgrade path, and it is why light-by-default is safe.
- Changing the default does **not** regress an existing adopter's re-run: under keep policy a
  ledger or runbook they already have is untouched: light only declines to *add* files.
- The profile is **not** written to `amh.conf` and **not** read by any script. It reaches the
  agent only through `AMH-ADOPT.md`, and under `light` the brief tells it to reconcile the
  seed prose it kept — fold the runbook into the constitution, drop the ledger sentences —
  which is advice `harness/src/40-adaptation.md` already gives (owner-confirmed: agent-side
  reconciliation, not a second forked seed set).
- **Fix the missing fourth tier while the file lists are open.** P2 describes four memory
  tiers; `harness/templates/seed/` ships three — there is no `docs/history/`, so no adopter
  has ever received the archive tier, while the seed runbook instructs their agent to "consult
  the ledger and the archive". `path-refs.sh` is structurally blind to this: it skips
  `harness/templates/*` because those paths are meant to resolve in the adopter's tree. Ship a
  seeded `docs/history/README.md` (`standard` and `full`; under `light` the brief tells the
  agent to drop the archive sentence from the runbook it folded in).
- **And settle where compressed narrative actually goes**, because two shipped documents
  disagree: the archive README says "spent narrative from compressed STATE passes lands here",
  while the STATE preamble says to compress "by folding completed stages into Changelog lines
  … **not by cutting text into a new file**". Both ship. This is normative, not descriptive —
  the ground-truth rule cannot settle it — so it is an owner question, carried below.
- `test-init-e2e.sh`: one case per profile — instantiate, run **that repo's** ladder, require
  green. `light` is the load-bearing one: it proves presence-derived degradation actually
  works end to end (ledger rung prints `skip`, ladder still green, planted-credential positive
  control still red).

### U3 — Shipped-script integrity manifest (owner-adopted ahead of the incident bar)

The one piece of genuinely new machinery, and the only unit that touches a shipped script.

- **Generation.** A checksum manifest over `harness/templates/scripts/*.sh`, generated —
  never hand-written — the way `harness/dist/AMH.md` is, with a repo-local drift guard
  mirroring `scripts/guards/dist-drift.sh` so a stale manifest cannot ship.
- **Installation.** `amh-init.sh` writes it into the target beside the scripts it describes,
  policy `overwrite` — it is a shipped artifact, not the adopter's, and an upgrade replaces it
  with the new version's hashes in the same pass that replaces the scripts.
- **The rung.** A new `guard_shipped_integrity` in `harness/templates/scripts/ladder.sh`
  (then copied into `scripts/` — `copy-drift.sh` enforces byte-identity). Each shipped script
  is hashed against the manifest; a mismatch **fails**, naming the file and the remedy
  `docs/UPGRADING.md` already states: the edit belongs in `amh.conf`, `scripts/guards/*.sh` or
  `scripts/verify.sh`, and re-running init restores the original.
- **Absence is a `skip`, not a fail — deliberately.** An adopter who upgraded by the documented
  `cp harness/templates/scripts/*.sh scripts/` has no manifest, and a rung that failed on
  absence would turn their ladder red until they hand-repaired it: the **D-030** shape, a fix
  that requires the person you broke to fix it. The skip line names what went unchecked, per
  **D-019**'s rule that a disabled guard must be louder than a passing one.
- **Fixtures, in the shipped suite** (`harness/templates/scripts/test-ladder-guards.sh`, then
  copied down): a tampered script fails, an intact tree passes, an absent manifest skips. Each
  must be shown to fail without the guard (**D-008**).
- This is the meta-repo's second integrity check over the same files, and that is correct
  rather than redundant: `copy-drift.sh` proves *this repo runs what it ships*, the manifest
  proves *an adopter still runs what we shipped them*. Different claims, different trees.

### U3b — One banner line for the squash-history blind spot

Small, and it ships in the same unit as U3 because both touch shipped scripts and both owe
`copy-drift.sh` a matching copy into `scripts/`.

`scripts/session-start.sh` already sources `amh.conf` and prints the branch, the state file's
headroom and the protocol pointer (P14 step 4). Add one line, emitted **only** when
`MERGE_MODE` is `branch-train`: history on the default branch is squashed, so `git log` there
is not this repo's past — the ledger and the STATE changelog are. Needs a `MERGE_MODE=` default
alongside the others at the top of the script, since the script does not read the key today.

Rejected alternative, with reasoning, in **DA-003**: a pre-execution warning on `git log`. It
clears the incident bar and is still the wrong layer — the rail is binary, the command is
correct nearly every time (two shipped rungs use it), the defect was the generalisation rather
than the command, and the shape is not enumerable.

### U4 — Prose, version, release

- `harness/src/40-adaptation.md` gains the profile table and the "nothing records the level"
  sentence; `harness/src/` is the only home — run `scripts/build-dist.sh`, `dist-drift.sh`
  confirms.
- `docs/UPGRADING.md`: the upgradeable/yours table gains `AMH-ADOPT.md` (yours, delete when
  done) and states the ADR-1 invariant.
- **MINOR bump → 1.9.0.** Additive by the letter of the semver policy — a new option, a new
  template, a new rung that skips where its artifact is absent — and no binding rule changes
  for an existing adopter, whose obligation is nothing. `harness/VERSION` is the single
  source; `scripts/guards/version-lockstep.sh` checks four hand-written copies:
  `harness/CHANGELOG.md`'s top entry, `AGENTS.md`'s recorded version, `docs/STATE.md`'s, and
  `AMH_VERSION` in `amh.conf`. The changelog entry carries its Upgrading section.
- `docs/STATE.md`: correct the stale train handoff, add the changelog line, add the three
  rejected shapes to **Decided non-items** (packaged CLI, assurance feature flags, per-level
  rendered scripts) — each pointing at its `DA-NNN` row, not restating the argument.
- `docs/LEDGER_A.md`: rows for the ADRs, for the manifest guard **and for its admission ahead
  of the incident bar** — an owner decision that deviates from a standing rule is exactly what
  the ledger is for, and a future session must find the reasoning rather than the precedent.
- **Delete `docs/plans/harness-instantiation.md`** and its `docs/STATE.md` reference (P16).

### Owner queue (settled 2026-07-27)

1. **AMH 1.8.0 is released** — `amh-v1.8.0` is tagged on the merged founding commit `7d322d7`.
   The README quickstart therefore pins a tag that exists today. The remaining owner action is
   to tag **amh-v1.9.0** after this plan's merge, in that order.
2. **The spent squash-PR body is deleted**, together with the `docs/STATE.md` citation that
   made the first attempt fail the ladder — the ordering rule is now **DA-002**.

### U1 addendum — pin the tag with a guard, not with discipline

The README naming a release tag is a fifth hand-written copy of the version, and this repo
already knows what happens to those: `scripts/guards/version-lockstep.sh` exists because four
of them drift. Add the README's pinned tag as a **fifth checked copy** in the same guard, so
the quickstart cannot go stale against `harness/VERSION`. The merge-to-tag window (the README
names the new tag before the owner creates it) is the same window every release already has,
and it closes the moment the tag lands.

## Verification

- `scripts/ladder.sh` green after every unit, run **directly, never piped** (a pipe reports the
  pipe's status; a red tree has been pushed that way).
- `scripts/tests/test-init-e2e.sh` — the real acceptance for U1/U2: instantiate into a scratch
  repo per profile and run *that* repo's ladder, including the planted-credential positive
  control that proves the green is not vacuous.
- `scripts/verify.sh` (parse check, shellcheck, guard fixtures) — `shellcheck` is CI-only and
  installed by `scripts/bootstrap.sh` at session start under `AMH_REMOTE=1`; editing a script
  without it is editing blind (**D-026**).
- `scripts/build-dist.sh` after any `harness/src/` edit. `copy-drift.sh` after U3's
  `harness/templates/scripts/` edits — U3 changes two shipped scripts (`ladder.sh`,
  `test-ladder-guards.sh`), and each must be copied into `scripts/` in the same commit.
- U3's fixtures must be shown to **fail without the guard** before the guard lands (D-008); a
  fixture that passes either way is the false-pass this repo treats as worse than no guard.
- **What cannot be verified here:** that a real adopting agent follows `AMH-ADOPT.md` well.
  The e2e test covers the harness's half only; the brief's quality is owner-judged. Every
  commit body says so.

## Settled by the owner, 2026-07-27

1. **`light` and the constitution** — agent-side reconciliation at adoption time, not a second
   forked seed set.
2. **Default profile is `light`**, and `AMH-ADOPT.md` must have the agent *ask* rather than
   assume it.
3. **The manifest guard ships now**, ahead of the incident bar, with the deviation ledgered.
