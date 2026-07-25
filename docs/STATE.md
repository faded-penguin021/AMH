# STATE — project state & session memory

> **Length guard (read before editing — hysteresis).** Grow freely to **14 KB**; no trimming
> below that line. When the guard warns, run ONE deep compression pass to **≤ 9 KB** — never
> trim to just under the threshold (micro-trims re-arm the warning a session later; the wide
> band IS the debounce). Fail above **16 KB**. Compression means: collapse each completed work
> stage into one Changelog line, fold changelog clusters, move any durable gotcha into the
> append-only ledger, delete narrative prose.
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

The AMH meta-repository: both the **source of truth** for the Agentic Maintenance Harness — a
reusable operating prompt plus scaffolds for repos maintained by agentic AI sessions — and its
**reference instance**, maintained under the harness and running byte-identical copies of the
scripts it ships.

- The distributed product lives in `harness/` (prose source, templates, generated bundle).
- This repo's own instance is `AGENTS.md` + `docs/` + `scripts/` + `amh.conf`.
- Adopted harness version: **AMH 1.8.0** (see `harness/VERSION`).

## Current state

> **Session handoff (2026-07-25).** Work continues on `claude/owner-queue-attestation-der6bl`,
> stacked on the founding branch — the topology is a **branch train**, not the
> `branch-per-change` `amh.conf` declares (Owner queue #3). **Two things are known-broken and
> unfixed: the shipped command guard has a rail-voiding regression, and CI has never passed.**
> Both are in **D-016** — read it first; it is the next unit's scope. A codification diff was
> uncommitted and under review at handoff; if `D-015` is missing from the ledger it died with
> the session. Its content is **D-015**; what its own review corrected is **D-018**.

Founding build (`claude/amh-meta-repository-tb2myi`): **U1–U4 done** — self-hosting core,
legislation, adopter templates, harness prose + generated bundle.

- [~] **U5 — Version, changelog, upgrade path.** `VERSION`, `CHANGELOG`, `UPGRADING`,
      `version-lockstep.sh`, MIT `LICENSE` in. Open: the release workflow, and
      mirroring the review's prose corrections into `harness/templates/seed/**` and
      `harness/src/**` (they landed in this repo's instance first).
- [ ] **U6 — README, CONTRIBUTING, `amh-init.sh`, end-to-end test.**
- [ ] **Next unit — fix what is broken.** D-016 in the ledger, in its stated severity order.

## Owner queue

> **Protected section.** Never delete it, and never silently drop items during compression.
> Items leave only when done, answered or triaged — then delete the item and record the
> outcome as a Changelog line or a ledger row. Every session's final chat message restates
> this queue.

**Pending owner actions:**

1. Tag `amh-v1.8.0` once the founding branch is merged — an owner step. The release workflow
   does not exist yet, so the tag triggers nothing today.
2. **Merge mode is misdeclared.** `amh.conf` says `MERGE_MODE=branch-per-change`, but this
   branch was cut from the founding branch and contains it whole — P13 mode (b),
   **branch-train**. Under a train only the final superset branch merges, in ONE squash PR
   whose body describes the net `origin/main..HEAD` diff (all 9+ commits), which is what you
   asked for. So the config is what is wrong. Decide: set `MERGE_MODE=branch-train` (a value in
   `RULE_FILES`, so a rule change), or merge the founding branch first. No PR template exists
   yet — `.github/` holds only `workflows/`.

**Open questions:**

1. [2026-07-25] **D-005** — founding legislation installed with no fresh-context reviewer.
   Both authorised passes have now run: prose (applied) and scripts/templates (**D-017**).
   Close D-005 on your read at merge.
2. [2026-07-25] The P3 reword (**D-014**) landed **self-reviewed**, at your direction to work
   without a subagent. Your read at merge is its only outside look.
3. [2026-07-25] **The one-pass rule is Goodhart-open** (D-018): "split the unit" lets a session
   relabel a corrected diff as a new unit and claim a fresh pass. No mechanical definition of a
   unit exists. Your call whether to bound it or accept it as prose-only.

**Incoming findings:** two ledger rows hold every open defect; **read them before any new
unit, and do not re-investigate — the work is done, only the fixing is left.** **D-016**: the
command-guard regressions and the CI red. **D-017**: the first hostile read of the shipped
scripts and templates (this closes D-005's investigation). Worst first across both: (0) **D-017
B1** — the ladder's secret scan silently disappears if `redact.sh` loses its exec bit, ladder
green with a live credential in the tree; (1) `<<<` here-strings void EVERY rail in the shipped
`command-guard.sh`, including force-push and push-to-`main`; (2) the `<` scan blocks `<` inside
quoted text — D-007 verbatim; (3) two guards word-split their file lists and skip
spacey filenames silently; (4) three guards have zero fixture coverage and one is inert here;
(5) `redact.sh` misses `sk-proj-`, `ASIA`, `glpat-` and credentials in URLs, and leaks the tail
of over-long tokens; (6) **CI has failed on all 8 runs in this repo's history**, on shellcheck
info notices — fix the scripts, never narrow `verify.sh`; (7) `CONTRIBUTING.md` and
`amh-init.sh` are cited but do not exist, and `path-refs.sh` structurally cannot see it;
(8) `git push origin +main` and `source .env` pass both rail layers; (9) `checkout@v4` is
Node-20 deprecated in the workflow and the shipped template.


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
  P3): an agent can emit an attestation without doing the work. Guards check artifacts. Scope
  clarified the same day (D-014): the ban is on *machinery* — no guard, gate, CI step or
  required field may consume a self-report — not on a commit-body sentence a human reads and
  may disbelieve. A disclosure that graduates into a gate is the thing being banned.

## Changelog

One line per shipped change or completed unit (newest first). Details live in the cited ledger
rows and in git history.

- 2026-07-25 — **Env-dump rails closed** in `command-guard.sh` (builtins, `/proc`, `<`
  redirections, echoed values); 24+36 fixtures; one pass, 9 findings applied. **Shipped with a
  regression — D-016.**
- 2026-07-25 — **P3/P12 attestation contradiction resolved** (owner: option (c)). P3 bans
  attestation-based *machinery*; commit-body verdicts stay as prose for a human. **D-014.**
- 2026-07-25 — **MIT `LICENSE`**, (c) faded-penguin021.
- 2026-07-25 — **Rule review, constitution + runbook, applied.** 14 confirmed findings; 13
  fixed, 1 escalated, 2 accepted as limits. New: `version-lockstep.sh`, `path-refs.sh`,
  repo-local fixtures. **D-008**…**D-013.**
- 2026-07-25 — **U1–U4**: self-hosting core, legislation, adopter templates, harness prose +
  bundle. Founding decisions **D-001**…**D-007**.
