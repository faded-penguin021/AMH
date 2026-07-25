# STATE — project state & session memory

> **Length guard (read before editing — hysteresis).** Grow freely to **14 KB**; no trimming
> below that line. When the guard warns, run ONE deep compression pass to **≤ 9 KB** — never
> trim to just under the threshold (micro-trims re-arm the warning a session later; the wide
> band IS the debounce). Fail above **16 KB**. Compression means: collapse each completed
> work stage into one Changelog line, fold changelog clusters, move any durable gotcha into
> the append-only ledger, delete narrative prose.
>
> **What the ladder actually enforces**, so nobody mistakes prose for a gate: it fails over
> 16 KB; it fails a trim that starts above 14 KB and stops above the 9 KB floor (in either
> direction — crossing the cap or not); it fails if **`## Project`**, **`## Current state`**
> or **`## Changelog`** is missing *or emptied of content*; and it **warns only** if
> `## Owner queue` disappears, because closing the owner's items is the owner's call, not a
> build failure. Everything else here is prose: nothing detects a 13 KB → 5 KB trim, nothing
> can tell real compression from cutting 6 KB out into a new file, and no guard judges
> whether what survived is any good. Owner-queue items are the owner's to close — compress
> their prose, never drop an open item.

## Project

The AMH meta-repository. It is both the **source of truth** for the Agentic Maintenance
Harness — a reusable operating prompt plus scaffolds for repos maintained by agentic AI
sessions — and its **reference instance**: this repo is itself maintained under the harness,
running byte-identical copies of the scripts it ships.

- The distributed product lives in `harness/` (prose source, templates, generated bundle).
- This repo's own instance is `AGENTS.md` + `docs/` + `scripts/` + `amh.conf`.
- Adopted harness version: **AMH 1.8.0** (see `harness/VERSION`).

## Current state

Founding build in progress on `claude/amh-meta-repository-tb2myi`, in sequential units:

- [x] **U1 — Self-hosting core.** `amh.conf`, the five shipped scripts + byte-identical
      copies in `scripts/`, guard fixture suite, permission rails, CI, working memory.
- [x] **U2 — Legislation.** `AGENTS.md`, `CLAUDE.md` pointer, `docs/RUNBOOK.md`.
- [x] **U3 — Adopter templates.** `harness/templates/{seed,configs}`, `PLACEHOLDERS.md`.
- [x] **U4 — Harness prose + generated bundle.** `harness/src/`, `harness/dist/AMH.md`.
- [~] **U5 — Version, changelog, upgrade path.** `harness/VERSION`, `CHANGELOG`, `UPGRADING`,
      `version-lockstep.sh` and the MIT `LICENSE` are in. Still open: the tag-triggered release
      workflow (owner asked for it), and mirroring the review's prose corrections into
      `harness/templates/seed/**` and `harness/src/**` — the corrections landed in this repo's
      own instance first, so the shipped copies still carry the wrong claims.
- [ ] **U6 — README, CONTRIBUTING, `amh-init.sh`, end-to-end test.**

## Owner queue

> **Protected section.** Never delete it, and never silently drop items during compression.
> Items leave only when done, answered or triaged — then delete the item and record the
> outcome as a Changelog line or a ledger row. Every session's final chat message restates
> this queue.

**Pending owner actions:**

1. Enable **secret-scanning push protection** on the repo (Settings → Code security). Branch
   protection on `main` is done. Push protection is worth enabling even though this codebase
   ships no keys: it binds every actor and every tool, and the risk it covers is a session
   *environment* credential pasted into a file or a log excerpt, not a checked-in key. No
   custom patterns are needed — the default provider-token set is the whole ask, and it costs
   nothing to leave on. (AMH P13: agent-side rails bind only agents that load them.)
2. Tag `amh-v1.8.0` once the founding branch is merged — tagging stays an owner step. The
   release workflow is not built yet, so today the tag triggers nothing; once it exists,
   pushing the tag is the whole step and it refuses a tag that disagrees with
   `harness/VERSION`.

**Open questions:**

1. [2026-07-25] **The commit-body review verdict is a self-reported attestation, which this
   repo bans permanently.** The runbook mandates writing "adversarial pass: clean"; the
   constitution and Decided non-items ban attestations because an agent can emit one without
   doing the work. Both are inherited from the upstream harness (P12 mandates the verdict, P3
   bans attestations), so this is a defect in the harness itself, not just this instantiation.
   **Options:** (a) keep the verdict, scoped explicitly as prose-for-humans carrying no
   evidentiary weight — done as an interim measure, but it leaves P3's "never" as an
   overstatement; (b) drop the verdict requirement entirely and rely on the reviewer's
   findings appearing in the diff; (c) reword P3 to ban attestation-based *machinery* rather
   than attestation-shaped *prose*. **Recommendation: (c)** — the real rule is that no gate
   may accept a self-report, which (c) says precisely while (a) leaves a contradiction on the
   page. This changes an upstream principle, so it is yours, not mine.
2. [2026-07-25] Founding units U1–U2 installed this repo's legislation with no fresh-context
   reviewer, since there was no prior constitution to review against (D-005). The rule-review
   pass you authorised has now covered U1–U4 and its findings are applied. **Recommendation:**
   close this once you have read the founding branch at merge; nothing further is pending.

**Incoming findings:** (none)

## Decided non-items (don't re-litigate without new evidence)

- **2026-07-25 — Rendering scripts from placeholder templates.** Declined. The shipped
  scripts read `amh.conf` at runtime instead, which deletes the rendered-vs-template drift
  class entirely rather than policing it. See D-002.
- **2026-07-25 — Doc-fact guards (AMH P20) for this repo's prose. OVERTURNED same day.**
  Declined on the grounds that no claim had drifted; the rule review then found five that
  had (D-010). P20's incident bar is met, so `version-lockstep.sh` and `path-refs.sh` are
  admitted. The bar itself stands: still no guard for a claim that has not yet rotted.
- **2026-07-25 — A markdown link checker in the ladder. OVERTURNED same day.** Declined on
  "no broken link has cost anything yet"; three dangling references were shipped within the
  day, one of which made a playbook unfollowable. `path-refs.sh` is the narrow form: repo-
  relative paths only, no network, no flake surface. Widening it to bare filenames was tried
  and rejected — 24 hits for 2 true positives would train everyone to ignore it.
- **2026-07-25 — Section-granular `RULE_FILES`.** Declined: the tripwire is file-granular, so
  `docs/STATE.md` and `docs/LEDGER.md` stay out (they change nearly every unit; warn fatigue
  kills tripwires) and `docs/RUNBOOK.md` stays in wholesale, accepting that operational
  playbook fixes trip it. Building section-granularity is machinery in service of a warning.
- **2026-07-25 — Self-reported checklists in commits or YAML.** Declined permanently (AMH
  P3): an agent can emit an attestation without doing the work. Guards check artifacts.

## Changelog

One line per shipped change or completed unit (newest first). Keep terse; details live in the
cited ledger rows and in git history.

- 2026-07-25 — **MIT `LICENSE`** at the repo root, © faded-penguin021 (owner's call; the
  harness is meant to be copied, and it shipped without permission to do so).
- 2026-07-25 — **Rule review, U1–U4, applied.** One fresh-context pass over the constitution
  and runbook returned 17 findings (14 confirmed); 13 fixed here, 1 escalated to the Owner
  queue, 2 accepted as documented limits. Guards: the STATE landing check now catches trims
  that never cross the cap, required sections must be non-empty, `version-lockstep.sh` and
  `path-refs.sh` are new, and repo-local guards finally have fixtures
  (`scripts/tests/local-guards.sh`). Prose: five false enforcement claims corrected.
  **D-008**…**D-013**.
- 2026-07-25 — **U4** Harness prose in `harness/src/` (overview, P0–P20, constitution,
  scaffolds, adaptation notes) and the generated single-file bundle `harness/dist/AMH.md`,
  built by `scripts/build-dist.sh` and kept honest by `dist-drift.sh`. The placeholder guard's
  live-file scope was corrected: everything under `harness/` is the product, not this repo's
  instance.
- 2026-07-25 — **U3** Adopter templates: seed scaffolds (constitution, pointer, STATE,
  RUNBOOK, LEDGER, `verify.sh`), configs carrying `{{PLACEHOLDER}}`s (Claude Code settings,
  CI workflow), `amh.conf.example`, and `harness/PLACEHOLDERS.md` with a guard that fails on
  an undocumented placeholder or one left unfilled in this repo's live tree.
- 2026-07-25 — **U2** Legislation: `AGENTS.md` (canonical constitution), `CLAUDE.md` pointer,
  `docs/RUNBOOK.md` (playbooks, session discipline, both review protocols, incident playbook),
  and `scripts/guards/copy-drift.sh` — which makes "this repo runs what it ships" checkable
  rather than aspirational. Shipped-bug classes seeding the review checklist: **D-006**,
  **D-007**, **D-008**.
- 2026-07-25 — **U1** Self-hosting core: `amh.conf`, ladder + guard fixture suite, redaction
  and command-guard rails with self-tests, session bootstrap, permission rails, CI. This repo
  now runs the harness it ships. Founding decisions in **D-001**…**D-005**.
