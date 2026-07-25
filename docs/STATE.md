# STATE — project state & session memory

> **Length guard (read before editing — hysteresis).** Grow freely to **14 KB**; no trimming
> below that line. When the guard warns, run ONE deep compression pass to **≤ 9 KB** — never
> trim to just under the threshold (micro-trims re-arm the warning a session later; the wide
> band IS the debounce, statelessly). Fail above **16 KB**. Compression means: collapse each
> completed work stage into one Changelog line, fold changelog clusters, move any durable
> gotcha into the append-only ledger, delete narrative prose. **Project**, **Current state**
> and **Owner queue** must always survive compression (Owner-queue items are the owner's to
> close — compress their prose, never drop an open item). `scripts/ladder.sh` machine-checks
> all of this, including that a compression pass actually lands on the 9 KB floor.

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
- [ ] **U5 — Version, changelog, upgrade path.** `harness/VERSION`, `CHANGELOG`, `UPGRADING`.
- [ ] **U6 — README, CONTRIBUTING, `amh-init.sh`, end-to-end test.**

## Owner queue

> **Protected section.** Never delete it, and never silently drop items during compression.
> Items leave only when done, answered or triaged — then delete the item and record the
> outcome as a Changelog line or a ledger row. Every session's final chat message restates
> this queue.

**Pending owner actions:**

1. Choose a licence for the distributed harness — it currently ships without one, which
   leaves adopters without permission to use it. (Recommendation: a permissive licence;
   the harness is meant to be copied.)
2. Mirror the hard rails server-side (AMH P13): branch protection on `main` (PRs required,
   force-push and deletion blocked) and secret-scanning push protection. The agent-side
   permission rails bind only agents that load them; server-side rails bind every actor.
3. Tag `amh-v1.8.0` once the founding branch is merged — tagging stays an owner step.

**Open questions:**

- [2026-07-25] The founding units (U1–U2) install this repo's legislation, so there is no
  earlier constitution for a fresh-context reviewer to check them against, and no subagent
  was spawned (standing instruction). **Recommendation:** treat the merge review of the
  founding branch as the rule-review pass for U1–U2; from the merge onward the rule-review
  protocol binds normally. Recorded as D-005 rather than silently skipped.

**Incoming findings:** (none)

## Decided non-items (don't re-litigate without new evidence)

- **2026-07-25 — Rendering scripts from placeholder templates.** Declined. The shipped
  scripts read `amh.conf` at runtime instead, which deletes the rendered-vs-template drift
  class entirely rather than policing it. See D-002.
- **2026-07-25 — Doc-fact guards (AMH P20) for this repo's prose.** Declined *for now*: P20
  admits a check only after a claim has actually drifted once. No claim has. Admitting them
  speculatively is how a tripwire metastasises into a doc-testing framework.
- **2026-07-25 — A markdown link checker in the ladder.** Declined: no broken link has cost
  anything yet, and a gate that flakes on network-fetched links gets disabled, not fixed.
- **2026-07-25 — Self-reported checklists in commits or YAML.** Declined permanently (AMH
  P3): an agent can emit an attestation without doing the work. Guards check artifacts.

## Changelog

One line per shipped change or completed unit (newest first). Keep terse; details live in the
cited ledger rows and in git history.

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
