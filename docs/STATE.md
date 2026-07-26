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

> **Session handoff (2026-07-26).** Work is on `claude/owner-queue-attestation-fixes-guh973`,
> stacked on `claude/owner-queue-attestation-der6bl` and through it on the founding branch.
> The topology is a **branch train** and `amh.conf` now says so (owner decision, 2026-07-26).
> **The defect list is D-016 and D-017 — read them, and do NOT re-investigate: both authorised
> hostile passes have run and only the fixing is left.** Two of five planned units shipped
> this session; **units 3, 4 and 5 below are the next session's scope, in order.** The build
> plan is committed at `docs/plans/amh-meta-repository.md` with a status preamble recording
> where the built tree departs from it.

Founding build (`claude/amh-meta-repository-tb2myi`): **U1–U4 done** — self-hosting core,
legislation, adopter templates, harness prose + generated bundle.

- [~] **U5 — Version, changelog, upgrade path.** `VERSION`, `CHANGELOG`, `UPGRADING`,
      `version-lockstep.sh`, MIT `LICENSE` in. Open: the release workflow, and
      mirroring the review's prose corrections into `harness/templates/seed/**` and
      `harness/src/**` (they landed in this repo's instance first).
- [ ] **U6 — README, CONTRIBUTING, `amh-init.sh`, end-to-end test.**

**Repair units — 2 of 5 shipped.** Each takes ONE fresh-context reviewer, blocking, one pass
(D-015): triage, apply, ship, no re-review. Spawning it is required, not a thing to ask about.

- [x] **Unit 1 — the shipped command guard.** D-016 items 1–7 + D-017 B12. Shipped `d95dd1d`.
- [x] **Unit 2 — the ladder blocker and the fixture gaps.** D-017 B1–B3, and B9/B10 which its
      review pass reproduced (a truncated or pass-through `redact.sh` reported every file
      clean). **D-019**, **D-020**. B4 is closed for the fixture suite; its second half —
      `guard_poison_tokens` being inert in THIS repo because `origin/main` did not resolve
      locally — is now a **WARN** rather than a silent skip. A fresh clone will warn again;
      `git fetch origin main` is the fix and makes the guard real (done here, now `ok clean`).
- [ ] **Unit 3 — make CI green for the first time** (D-016 item 8). It has failed all 8 runs
      on shellcheck info-level notices in this repo's own scripts. Fix the SCRIPTS; do NOT
      narrow `verify.sh` — the runbook forbids weakening a gate to get green. Then bump
      `actions/checkout@v4` → `@v5` in `.github/workflows/ci.yml` AND
      `harness/templates/configs/ci.yml` (Node 20 deprecation, D-016 item 9).
- [ ] **Unit 4 — `redact.sh` misses live credential shapes** (D-017 B5/B6): `sk-proj-` (the
      existing `openai_key` class no longer matches OpenAI's format), `ASIA`, `glpat-`,
      credentials in URLs; and the exact-length classes leak the token tail. The self-test
      **structurally cannot see partial redaction** — fix the assertion at `redact.sh:74` too.
- [ ] **Unit 5 — `CONTRIBUTING.md` and `amh-init.sh` are cited but do not exist** (D-017 B11),
      which makes RUNBOOK playbook 5 unfollowable. `path-refs.sh` cannot see repo-root files
      by construction: its pattern requires an embedded slash.

## Owner queue

> **Protected section.** Never delete it, and never silently drop items during compression.
> Items leave only when done, answered or triaged — then delete the item and record the
> outcome as a Changelog line or a ledger row. Every session's final chat message restates
> this queue.

**Pending owner actions:**

1. Tag `amh-v1.8.0` once the founding branch is merged — an owner step. The release workflow
   does not exist yet, so the tag triggers nothing today.
2. **Merge the train as ONE squash PR** whose body describes the net `origin/main..HEAD` diff,
   not the last branch's. No PR template exists yet — `.github/` holds only `workflows/`.

**Open questions:**

1. [2026-07-25] **D-005** — founding legislation installed with no fresh-context reviewer.
   Both authorised passes have now run: prose (applied) and scripts/templates (**D-017**).
   Close D-005 on your read at merge.
2. [2026-07-25] The P3 reword (**D-014**) landed **self-reviewed**, at your direction to work
   without a subagent. Your read at merge is its only outside look.
3. [2026-07-25] **The one-pass rule is Goodhart-open** (D-018): "split the unit" lets a session
   relabel a corrected diff as a new unit and claim a fresh pass. No mechanical definition of a
   unit exists. Your call whether to bound it or accept it as prose-only.

**Open findings.** **D-016** and **D-017** hold them; **read those rows before any new unit,
and do not re-investigate — both authorised hostile passes have run and only the fixing is
left.** Units 1 and 2 above closed D-016 items 1–7, D-017 B1–B3, B9/B10 and B12; those rows
carry the corrections. **Still open**, mapped to the units above: `redact.sh` misses
`sk-proj-`, `ASIA`, `glpat-` and credentials in URLs and leaks over-long tokens' tails, and
its self-test structurally cannot see partial redaction (**B5/B6** → Unit 4); CI has failed on
all 8 runs on shellcheck info notices, and `checkout@v4` is Node-20 deprecated in the workflow
AND the shipped template (**D-016 items 8–9** → Unit 3); `CONTRIBUTING.md` and `amh-init.sh`
are cited but do not exist, and `path-refs.sh` cannot see repo-root files by construction
(**B11** → Unit 5). **Unscoped, no unit yet:** `session-start.sh` skips the toolchain
bootstrap when `REMOTE_FLAG` is not a shell identifier (**B7**); `rm -rf scripts/guards` leaves
the ladder green with no output at all (**B8**); the seed `verify.sh` ships mode 100644 while
the ladder requires `-x`, so an adopter's first full run is red (**B13**); the STATE landing
check cannot tell a typo fix from a compression pass above the soft cap (**D-016 item 11**).


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

- 2026-07-26 — **The ladder's off switch closed, and the fixture builder's blind spots.**
  `redact.sh` losing its exec bit no longer makes the secret scan and the rail self-tests
  vanish silently; the citation guard and `path-refs.sh` no longer word-split their file
  lists; the three guards that had zero coverage now fail when stubbed. `MERGE_MODE` set to
  `branch-train` by owner decision; build plan committed at
  `docs/plans/amh-meta-repository.md`. **D-019**, **D-020**.
- 2026-07-26 — **Shipped command guard repaired**: the `<<<` here-string regression that
  voided every rail, the `<`-in-quoted-text false positive (D-007 verbatim), three
  over-blocking classes, the false "reading" reason on write destinations, `+main`/`--mirror`/
  `source .env`, and a 14s → 0.87s fix at 32 KB. D-016 items 1–7, D-017 B12.
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
