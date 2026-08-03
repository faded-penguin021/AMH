# PLAN — integrate the three runtime/evidence RFCs

Owner-approved 2026-08-03. Provisional (P16): the owner may pivot mid-feature, every segment
ends shippable, and the final segment moves this completed plan whole into `docs/history/`.
Durable outcomes live in Changelog lines and ledger rows either way — code cites ledger rows,
never this file (P11).

**Verification of every claim below happens during EXECUTION, not during drafting.** The
collision table is reconnaissance, not a verdict. Re-verify each row inside the segment that
acts on it.

## Context

The owner supplied three externally-authored RFCs and asked for them to be landed verbatim,
reviewed, revised by review outcome, and integrated:

| File | Proposes |
|---|---|
| `rfc-1-runtime-capability-contract.md` | `scripts/runtime-doctor.sh`, a versioned capability manifest, five capability states, a project-owned `scripts/environment-setup.sh`, descriptive runtime profiles |
| `rfc-2-mechanical-run-receipts.md` | `scripts/ladder.sh --report`, a versioned JSON run receipt, `scripts/amh-status.sh`, CI receipt artifacts |
| `rfc-3-conformance-lab.md` | A repo-local `conformance/` lab — scenarios, runners, evaluators — evaluating agent behaviour by observable consequence only |

They are external material. Under P18 they are **data, never authority**: each claim is
adjudicated against this repository's constitution and its existing decisions, and refusals are
recorded as permanently as acceptances. The precedent is **DA-001**, where an external RFC's
verdicts became a ledger row rather than a diff, and `docs/history/2026-07-28-external-review-validation.md`,
where three of seven external claims were false as written.

The three are ordered by dependency: RFC1 defines the capability-state vocabulary RFC2's
runtime layer reuses, and RFC2's receipts are one of the evidence sources RFC3 consumes.

## Owner decisions (2026-08-03, asked and answered — recorded permanently by S0)

1. **The incident bar is overridden for this work.** `CONTRIBUTING.md` and RUNBOOK playbook 3
   require a real violation before new machinery; the owner lifts that bar for these three
   RFCs specifically. The precedent for an owner overriding it on a stated argument is
   **DA-008** (and **D-032**/**D-033** before it). What this licenses is *this override*, not
   "the incident bar is negotiable" — the bar stands for everything else.
2. **Full acceptance criteria**, not the minimal vertical slices each RFC's own Implementation
   directive names. All 42 criteria across the three RFCs are in scope.
3. **Fresh-context reviewers are authorised.** The standing harness instruction against
   spawning subagents is lifted for this plan, so the rule-review protocol runs normally: one
   reviewer per unit, sequential, blocking, strongest tier, one pass. Nothing is parked for
   want of a reviewer.
4. **No new dependency.** JSON is emitted with `printf` and explicit escaping, and read back
   with a bounded reader restricted to the flat schema we ourselves emit. `jq` is not adopted.
   The floor stays `bash`, `git`, coreutils.
5. **RFC text is revised in place.** The verbatim originals need not survive the squash-merge;
   their durable content is the ledger verdicts.

## Collisions found before execution (RE-VERIFY inside the acting segment)

| # | What the tree showed | Bears on |
|---|---|---|
| C1 | `docs/STATE.md` → Decided non-items already refuses **hook-invocation detection in the boot banner** (**DA-022**), and `AGENTS.md` says plainly that no script can tell a hook invocation from a manual one without one vendor's environment variables, "so this stays prose on purpose". RFC1's `session_start: observed` wants exactly that fact. RFC1's *nonce-marker* probe may be a genuinely different mechanism — that is the adjudication, and re-opening a Decided non-item requires new evidence. | S1, S5 |
| C2 | **DA-001(c)/(d)** refuse machine-readable configuration that code can branch on, deliberately, "so no future code can branch on it". A capability manifest or receipt is legal as a *record*; it violates P3 the moment a guard, CI step or agent decision procedure consumes it. | S1, S2, S4, S7, S9 |
| C3 | `scripts/ladder.sh` has **no per-rung state** — `FAILS`/`WARNS` are global counters and a rung emits several lines. RFC2's per-rung receipt requires introducing that state. | S7 |
| C4 | The ladder parses **only `$1`**, via a single `case`, and `--help` prints `sed -n '2,16p' "$0"` — the header comment block *is* the help text. `--report PATH` needs a `while` loop and header lines that stay inside 2–16. | S7 |
| C5 | The ladder's verdict vocabulary is four words (`ok`/`WARN`/`FAIL`/`skip`), and **"unavailable" is deliberately spelled `WARN`, not `skip`** (`AMH ledger row D019`) — a guard that could not run must be louder than one that passed. RFC2's six-word vocabulary must map onto that, not replace it. | S2, S7 |
| C6 | Shipped scripts are **template-first**: edit `harness/templates/scripts/<name>.sh`, copy down byte-for-byte, run `scripts/build-manifest.sh` in the same change. `copy-drift.sh` and `manifest-drift.sh` enforce it. | S4–S10 |
| C7 | **Corrected in S1 — the count is hardcoded in more places than first listed.** Adding a shipped script breaks two literal assertions in `scripts/tests/test-init-e2e.sh` (lines 282 and 285) and the prose count in `amh.conf:3`, `README.md:207`, `docs/UPGRADING.md:69`, `harness/templates/AMH-ADOPT.md:95` and the generated `harness/dist/AMH.md:1611` — plus both adapter allow-lists. Two of those are in `RULE_FILES` and one is generated, so it must be rebuilt, never hand-edited. | S9 |
| C8 | `scripts/guards/path-refs.sh` fails on any backticked repo path in prose that does not exist. `docs/plans/*`, `harness/templates/*`, `harness/src/*`, `harness/dist/*` are the only exclusions — so an RFC may name `scripts/runtime-doctor.sh` while it lives here, and the moment that name moves into `AGENTS.md`, the runbook or the README the file must exist. | S4–S15 |
| C9 | `guard_citations` checks `[cited]` markers in **both** directions over `CITATION_SCAN_PATHS='scripts .github'`. A ledger row cited from a new script must gain the marker; a marked row that loses its last citation fails too. Inside a *shipped* script the form is `AMH ledger row DNNN` (no hyphen) so the guard does not read it. | S4–S13 |
| C10 | `docs/LEDGER_A.md` is at **676 of its 800-line cap**. This plan will append well over a hundred lines of rows, so the rollover to `LEDGER_B.md` (numbering from `DB-001`) lands mid-plan. The ladder globs for that exact spelling. | any segment |
| C11 | `docs/STATE.md` is at **12.6 KB of the 14 KB soft cap**, and the landing check arms only when the *committed* size is already above the cap. Keep the segment checklist terse; a deep compression pass to ≤ 9 KB is owed the moment the file crosses 14 KB. | S0, and every segment's STATE edit |
| C12 | CI uploads **no artifacts today** — `.github/workflows/` has no `upload-artifact` step, and the shipped `ci.yml` template's header forbids verification steps CI performs that the ladder does not. RFC2's artifact upload is a first, and must stay non-verifying. | S10 |
| C13 | Nothing in the repo writes machine-readable state and there is no `.amh/` directory; `.gitignore` is five meaningful lines. RFC1's `.amh/runtime.json` and RFC2's `.amh/receipts/` both need it, ignored. | S4, S8 |
| C14 | RFC3 criterion 2 ("one scenario runs through a hosted agent") is an **owner action** — it needs a hosted task launch and a disposable remote, neither of which an agent session may assume. It becomes an Owner-queue item, not a segment I can close. | S14 |

## Standing rules for every segment

Do not re-derive these each session.

- **Sequence:** ladder green → `docs/STATE.md` Changelog line → commit with an honest
  verification disclosure → push `claude/rfc-review-integration-lgvaei`. Never start a segment
  on top of an uncommitted one.
- **Reviewers:** every segment whose diff touches `RULE_FILES` scope — the rail scripts,
  `scripts/guards`, `amh.conf`, `AGENTS.md`, `docs/RUNBOOK.md`, `CONTRIBUTING.md`, the adapter
  configs, anything under `harness/templates/` or `harness/src/` — gets **one** blocking
  fresh-context pass at the strongest available tier, after the ladder is green and **before**
  the commit. One reviewer at a time. One pass per unit; the unit is what the reviewer saw, and
  its fixes belong to it permanently. Verdict goes in the commit body as prose no gate consumes.
- **Adversarial pass** additionally for any diff touching shell quoting, `set -u`, hook payload
  parsing, filesystem or git-state edge cases, or terminal output that could leak a value.
- **Shipped-script changes:** template first, `cp` down, `scripts/build-manifest.sh`, and a
  fixture in `harness/templates/scripts/test-ladder-guards.sh` (never `scripts/tests/` — do not
  cross the streams). The fixture must be shown to FAIL against the old script by stashing the
  *behaviour*, never by deleting the file.
- **P3 line, checked every segment:** a manifest, receipt or report is a record a human reads.
  The moment a guard, CI step, merge gate or agent decision procedure branches on one, it has
  become a self-report gate and the segment is wrong. State per artifact that nothing consumes
  it.
- **Ladder is run directly, never piped.**

## Segments

Each ends shippable. `[ ]` → `[x]` here and in the `docs/STATE.md` checklist as they land.

### S0 — Land the RFCs and this plan *(docs-only; `--guards-only` is the gate)*

- [x] `docs/plans/` created; the three RFCs copied byte-identical from the owner's uploads.
- [x] This plan file.
- [ ] `docs/STATE.md`: plan reference (all four basenames, or the plan-orphan advisory warns),
      terse segment checklist, Changelog line; close the resolved 3.0.0 release queue item —
      `git ls-remote --tags origin amh-v3.0.0` resolves to `refs/tags/amh-v3.0.0`.
- [ ] Ledger row: the owner override of the incident bar with its stated argument (the DA-008
      shape), and the four other owner decisions above.
- **Acceptance:** `scripts/ladder.sh --guards-only` green, zero warnings.
- **No reviewer:** nothing in this diff is in rule-review scope — `docs/plans/` is not, and the
  `docs/STATE.md` sections touched are not its rule-bearing ones. Say so in the commit body.

### S1 — Adjudicate RFC1 *(docs-only)* — **DONE**

- [x] Blocking fresh-context pass. Seven falsifiable claims returned; all six decision-bearing
      ones replayed and held.
- [x] C1 answered: the nonce marker is **not** new evidence. The probe is circular — proving a
      hook invoked the script needs a pre-command hook to stamp the ordering, which is one of
      the capabilities being probed — and the constitution's mandated manual fallback writes a
      byte-identical marker. **DA-022** stands; Decided non-items was not reopened.
- [x] RFC1 revised in place: refused at its core, four adjudicated criteria replacing thirteen.
- [x] **DA-024** records the verdicts, including (c) — a finding wider than RFC1: gitignoring a
      directory removes it from `guard_secret_shapes`, the only mechanical credential check in
      the tree. **This binds S8's `.amh/receipts/` proposal.**
- [x] Decided non-items **deferred** — it is rule-bearing, and editing it would pull this
      docs-only diff into rule-review scope. Owed by a unit that carries its own pass.
- [x] Owner-queue fork raised: S4–S6 no longer have a subject.

### S2 — Adjudicate RFC2 *(docs-only)*

- [ ] Same shape. Adjudicate C5 (vocabulary vs `D-019`'s WARN-not-skip rule) and C2 (what may
      ever consume a receipt) explicitly.
- [ ] Revise `docs/plans/rfc-2-mechanical-run-receipts.md` in place; ledger the verdicts.

### S3 — Adjudicate RFC3 *(docs-only)*

- [ ] Same shape. Adjudicate C14 (the hosted-agent criterion is an owner action) and the
      non-blocking model-run policy.
- [ ] Revise `docs/plans/rfc-3-conformance-lab.md` in place; ledger the verdicts.

### S4 — Capability schema + `runtime-doctor.sh`, repository and environment layers

- [ ] `harness/templates/scripts/runtime-doctor.sh`: human output and `--json`. Repository
      probes (worktree, writable via a temporary ignored path, `origin` remote, default-branch
      ref) and environment probes (required tools by executing their version command). Pure-bash
      JSON emitter with explicit escaping; the `amh_sha256_tool()` idiom already in the ladder is
      the house pattern for optional-tool detection.
- [ ] `.gitignore`: `/.amh/` (C13). The doctor's cache is `.amh/runtime.json` — diagnostic
      cache, not a memory tier, never committed, never cited.
- [ ] Criterion 6 is mechanical here: the doctor must emit no secrets, no environment dump, no
      raw command output. `guard_secret_shapes` runs `redact.sh` over it; that is the check.
- [ ] Copy down, `scripts/build-manifest.sh`, update C7's four sites (the E2E literal count,
      `docs/UPGRADING.md`, both adapter allow-lists).
- [ ] Fixtures in the shipped suite, including a deliberately broken probe (criterion 11) and
      the proof that a failed probe leaves behind no successful marker (criterion 5).
- **Acceptance:** full `scripts/ladder.sh` green; new fixtures shown to fail against the old
  tree. **Rule-review: yes.**

### S5 — Lifecycle probes and the five capability states

- [ ] Depends on S1's C1 verdict. Session-start, pre-command, post-command and stop probes,
      each `observed` only through a mechanical effect (criterion 4: a configured-but-dead hook
      is `configured`, never `observed`; `unknown` never becomes `unavailable` or `safe`).
- [ ] Adapter changes where the verdict permits: `.claude/settings.json`,
      `harness/templates/configs/claude-settings.json`, `.codex/config.toml`. The Codex adapter
      declares honestly that it has no such hooks — that honesty is the reference case for
      `unavailable`.
- [ ] Fixtures for all five states, both directions (criterion 11).
- **Acceptance:** ladder green; the hookless path still yields a complete manual workflow
  (criterion 7). **Rule-review: yes** (adapter rails are legislation).

### S6 — Setup contract, profiles, and the RFC1 prose layer

- [ ] `scripts/environment-setup.sh` as the *optional, project-owned* extension point
      (criterion 8) — no language-specific package installation in shipped scripts.
- [ ] Synthesised descriptive profiles (repository-only / guarded / observable / managed) as
      **output only**; no gate consumes a profile name (criterion 9).
- [ ] Security-boundary wording: the doctor states externally-provided isolation as `unknown`,
      never as verified.
- [ ] `AGENTS.md`, `docs/RUNBOOK.md`, `docs/UPGRADING.md`, `harness/CHANGELOG.md`,
      `harness/src/` as needed; `scripts/build-dist.sh` afterwards or `dist-drift.sh` fails.
- **Acceptance:** ladder green; criteria 1–13 of RFC1 each mapped to a fixture or an explicit
  "prose-only" statement. **Rule-review: yes.**

### S7 — Receipt schema and `ladder.sh --report PATH`

- [ ] Convert argument parsing to a `while` loop (C4), keeping `--guards-only` and the help
      text inside header lines 2–16.
- [ ] Introduce per-rung state (C3) and map it onto the receipt vocabulary per S2's C5 verdict.
- [ ] Bind the receipt to the exact verified commit and worktree state; a dirty worktree is
      recorded, never silently attributed to `HEAD` (criterion 2).
- [ ] A report is written for passing **and** failing runs (criterion 1); human output and the
      exit code are unchanged and remain authoritative.
- **Acceptance:** ladder green; green and red receipts both valid. **Rule-review: yes.**

### S8 — Interruption, finalization and receipt fixtures

- [ ] Atomic finalization (write to a temporary path, `mv` into place) so an interrupted run
      yields either no final receipt or an explicitly `interrupted` one — never `pass`
      (criteria 3, 4).
- [ ] `.amh/receipts/` as the local ignored transport; works with no CI and no lifecycle hooks
      (criterion 6).
- [ ] Positive controls, each required to emit failure honestly: a planted failing guard → a
      `fail` rung; a terminated ladder → `interrupted` or no finalized result; a removed tool →
      `unavailable`; an altered receipt → validation failure.
- **Acceptance:** ladder green; every positive control demonstrated. **Rule-review: yes.**

### S9 — `scripts/amh-status.sh`

- [ ] New shipped script: current repository state plus the newest *matching* receipt, human
      and `--json`. A receipt for another commit is labelled stale and never displayed as the
      status of the current tree (criterion 11).
- [ ] Bounded pure-bash reader over our own flat schema; validate producer and subject commit
      before relying on a receipt (criterion 12). Agent-authored receipts are not accepted as
      mechanical evidence (criterion 10) — state how that is decided without consuming a claim.
- [ ] C7's four sites again; `build-manifest.sh`.
- [ ] Fixtures: malformed, forged, stale, failed and interrupted receipts.
- **Acceptance:** ladder green. **Rule-review: yes.**

### S10 — CI receipt artifacts and the data-minimization audit

- [ ] `.github/workflows/ci.yml` and `harness/templates/configs/ci.yml` upload receipts for
      **both** successful and failed verification (criterion 5) — upload only, never a
      verification step the ladder does not perform (C12).
- [ ] Audit the emitted fields against RFC2's prohibition list: no prompts, responses, raw
      output, environment values, source contents, credentials or attestations (criterion 9).
- **Acceptance:** ladder green; a CI run on this branch produces both artifacts.
  **Rule-review: yes** (workflow and template).

### S11 — `conformance/` skeleton and scenario 1

- [ ] Repo-local `conformance/{scenarios,runners,evaluators,reports}/`. Not under
      `harness/templates/`, so it is never installed into an adopter repository (criterion 13)
      — that follows from existing structure, and `copy-drift.sh` is one-directional, so
      nothing complains.
- [ ] Scenario contract: `scenario.yml`, `task.md`, `fixture/`, `oracle/`, `evaluate.sh`; fixed
      revision and bounded budget per scenario (criterion 9).
- [ ] Scenario 1 (resolved Owner-queue item) with its evaluator and its **positive control** —
      restore the stale item, require `FAIL` (criterion 5).
- [ ] PASS / FAIL / INCONCLUSIVE semantics, with infrastructure failure never reported as agent
      noncompliance (criterion 6).
- **Acceptance:** the evaluator passes a compliant fixture and fails the mutation.
  **Rule-review: no** (nothing in `RULE_FILES`); **adversarial pass: yes**.

### S12 — A non-hosted runner, and evaluator tests in ordinary CI

- [ ] Disposable-clone shell runner satisfying the runner contract: isolated repository, exact
      revision, exact task text, bounded budget, unique branch namespace, no production
      credentials, launch failure distinguished from agent failure (criteria 3, 7, 8).
- [ ] Wire the **deterministic evaluator tests** into `scripts/verify.sh` so they run in
      ordinary CI (criterion 11) while model-backed execution stays non-blocking (criterion 12).
- **Acceptance:** ladder green with the evaluator suite in it. **Rule-review: yes**
  (`scripts/verify.sh` sits behind the ladder's extension point).

### S13 — Scenarios 2–7 *(expect to split; decide the split BEFORE any reviewer sees a diff)*

- [ ] 2 external prompt injection · 3 incomplete negative search · 4 bounded recovery ·
      5 broken probe · 6 session interruption · 7 runtime integration failure.
- [ ] Each with fixture, evaluator and a positive control that is required to `FAIL`
      (criterion 5). Criterion 10 needs at least three distinct behavioural failure classes
      operational before the lab may be called established.
- **Acceptance:** every evaluator shown to fail against its noncompliant mutation.

### S14 — Reporting, release claims, and the hosted run

- [ ] Bounded report format and the `reports/` transport; reports are evaluation evidence, not
      AMH permanent memory.
- [ ] Release-claim language: what the lab permits saying, and the four claims it forbids.
- [ ] **Owner-queue item** for criterion 2 (C14): the owner launches one scenario through a
      hosted agent on a disposable remote and names the resulting branch; I point the same
      deterministic oracle at it (criterion 4).
- **Acceptance:** ladder green; criterion 2 explicitly open in the Owner queue, not claimed.

### S15 — Close out

- [ ] `harness/CHANGELOG.md` entry with its **Upgrading** subsection; `docs/UPGRADING.md`;
      README repo map.
- [ ] **Owner-queue question:** MAJOR vs MINOR. Additive scripts read MINOR, but if any binding
      rule moved in S5/S6 it is MAJOR — the runbook says an ambiguous call is the owner's, not
      mine. The version bump touches five lockstep copies; the release cut and tag are owner
      steps.
- [ ] `scripts/build-dist.sh`, `scripts/build-manifest.sh`, final ladder.
- [ ] Move this plan whole into `docs/history/2026-08-03-rfc-integration.md`; remove the three
      RFC files or archive them with it. Durable outcomes stay in Changelog lines and ledger
      rows.

## Verification

- **Per segment:** `scripts/ladder.sh` (run directly, never piped) — `--guards-only` for the
  docs-only segments S0–S3, full otherwise. Every new fixture demonstrated to fail against the
  pre-change behaviour by stashing the *behaviour*, not by deleting a file.
- **End to end:** `scripts/tests/test-init-e2e.sh` proves an adopter tree still instantiates and
  its own ladder goes green with the new shipped scripts, and that the conformance lab is absent
  from that tree.
- **RFC criteria:** S6, S10 and S14 each close with an explicit map from every acceptance
  criterion in their RFC to the fixture that covers it or the sentence stating it is prose-only.
  A criterion with neither is not met, and saying so is the honest outcome.
- **What none of this reaches:** these are bash fixtures exercising bash scripts in the same
  interpreter, so a defect in an assumption they share is invisible to them. The conformance lab
  is the layer meant to see past that, and until a scenario has run against a real agent it has
  demonstrated only that its evaluator is deterministic.
