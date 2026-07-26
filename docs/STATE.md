# STATE — project state & session memory

> **Length guard (hysteresis).** Grow freely to **14 KB**; over it, ONE deep pass to **≤ 9 KB**
> — never to just under the cap, or the warning re-arms next session; the band IS the debounce.
> Fail above **16 KB**. That floor is a **ceiling, not a target**: aim comfortably below it.
> Trimming word by word until the guard goes quiet is the same micro-trim reflex the band exists
> to break, one band lower, and it leaves no headroom for the next session's growth. Above the
> cap the ladder tells an ordinary edit from a compression pass by how far the file shrank
> (`STATE_EDIT_DELTA_BYTES`), so fixing a typo up here is allowed and still owes the compression
> (**D-027**). Compress by folding completed stages into Changelog lines and moving durable
> gotchas to the ledger, not by cutting text into a new file. The ladder checks the caps, the
> landing, and that `## Project` / `## Current state` /
> `## Changelog` exist and are non-empty; it only *warns* if `## Owner queue` vanishes. Nothing
> judges whether what survived is any good. Never drop an open owner-queue item.

## Project

The AMH meta-repository: both the **source of truth** for the Agentic Maintenance Harness — a
reusable operating prompt plus scaffolds for repos maintained by agentic AI sessions — and its
**reference instance**, maintained under the harness and running byte-identical copies of the
scripts it ships. The distributed product lives in `harness/` (prose source, templates, generated
bundle); this repo's own instance is `AGENTS.md` + `docs/` + `scripts/` + `amh.conf`.
Adopted harness version: **AMH 1.8.0** — see `harness/VERSION`, which is the copy that counts.

## Current state

> **Session handoff (2026-07-26).** Work is on `claude/owner-queue-close-findings-60rz4g`, tip of
> the branch train (main ← tb2myi ← der6bl ← guh973 ← guzkor ← 8yq4br ← b7fell ← here);
> `branch-train` by owner decision.

The founding build, the five repair units and the build plan are done. What is left is the
findings below, not a defect list. **Every unit so far has had its blocker inside the FIX, not in
the original defect** — twelve running. Budget for that. Each takes ONE fresh-context reviewer,
blocking, ONE pass (D-015): triage, apply, ship, no re-review. Spawning it is required, not a
thing to ask about; do not relabel a corrected diff as a new unit to claim a fresh pass (D-018).

`shellcheck` is CI-only and its rung is load-bearing, so a session that edits a script without
installing it first is editing blind (**D-026**); scripts/bootstrap.sh does that install on every
remote session. Run the ladder DIRECTLY, never piped — a piped run reports the pipe's exit
status, and a red tree has been pushed that way.

**Open findings.** The owner has given a settled direction on each; build them, do not
re-litigate them. **D-016** and **D-017** carry the corrections — do not re-investigate.

- **B7 + B8 — the disabled state must be louder than the passing state (D-019).** B7:
  `session-start.sh` skips the bootstrap silently when `REMOTE_FLAG` is not a shell identifier
  (narrowed at the source in `amh-init.sh`, not fixed) — validate it, print a loud banner, do NOT
  make it fatal; the same file gates the bootstrap on `-x`, so run it through `bash` and delete
  the dependency. B8: `rm -rf scripts/guards` leaves the ladder green and silent — print
  `skip  scripts/guards (directory absent)` and the count actually run, still a skip. Neither has
  fixture coverage today; both scripts are shipped.
- **D-022** — colon-less URL userinfo (the documented Azure DevOps PAT clone URL) is missed. Add
  a class requiring ≥ 20 characters of userinfo before the `@`, excluding `git@host` at three.
  Every negative fixture MID-LINE: for a filter that is also a gate, a false positive switches
  the whole filter off while a miss leaks one secret. The row's second half — `ASIA` + 16
  uppercase characters redacting an ordinary identifier — is **accepted, not open**.
- **D-023 — de-cite the shipped scripts.** A citation promises the ID resolves, and in an
  adopter's tree `D-004` never can. Strip the guard-visible tokens (D-007 ×5 in
  `command-guard.sh`, D-004 ×2 and D-019 ×1 in `ladder.sh`, D-004 ×1 in `redact.sh`), keep the
  prose, append a provenance token the citation regex does not match. Revert `CITATION_EXCLUDE`
  in the shipped `amh.conf.example` to the fixtures only and drop the CHANGELOG note about it —
  `amh.conf` is the adopter's forever. **Accepted cost:** D-004 and D-007 lose their `[cited]`
  markers, dropped in the same unit or the ladder fails on stale markers; D-019 keeps its.
## Owner queue

> **Protected section.** Never delete it, and never silently drop items during compression.
> Items leave only when done, answered or triaged — then delete the item and record the
> outcome as a Changelog line or a ledger row. Every session's final chat message restates
> this queue.

**Pending owner actions:**

1. Tag `amh-v1.8.0` once the founding branch is merged. The release workflow now exists, so the
   tag verifies the tree, checks itself against `harness/VERSION`, and publishes the bundle.
2. **Merge the train as ONE squash PR** whose body describes the net `origin/main..HEAD` diff,
   not the last branch's. No PR template exists — `.github/` holds only `workflows/`. **The
   drafted body is still not written**; it remains the open half of the wrap-up unit.

**Open questions:**

1. [2026-07-25] **D-005** — founding legislation installed with no fresh-context reviewer. Both
   authorised passes have now run: prose (applied) and scripts/templates (**D-017**). Close on
   your read at merge.
2. [2026-07-25] The P3 reword (**D-014**) landed **self-reviewed**, at your direction. Your read
   at merge is its only outside look.
3. [2026-07-25] **The one-pass rule is Goodhart-open** (D-018): "split the unit" lets a session
   relabel a corrected diff as a new unit and claim a fresh pass, and no definition of a unit is
   mechanical. Your call whether to bound it or accept it as prose-only.

## Decided non-items (don't re-litigate without new evidence)

Each is settled and its reasoning is in the ledger row named — read the row, not this line,
before reopening. Rendering scripts from placeholder templates (**D-002**); doc-fact guards
(P20) and a markdown link checker, both overturned the same day, with `version-lockstep.sh` and
`path-refs.sh` the narrow forms admitted and the incident bar standing — no guard for a claim
that has not yet rotted (**D-010**, **D-023**); section-granular `RULE_FILES`, the tripwire being
file-granular (`docs/RUNBOOK.md`, which carries this one — no ledger row does); self-reported
checklists in commits or YAML, permanently, the ban
being on machinery consuming a self-report rather than on a sentence a human may disbelieve
(P3, **D-014**).

## Changelog

One line per shipped change or completed unit (newest first). Details live in the cited ledger
rows and in git history — this section is a pointer index, not a narrative.

- 2026-07-26 — **`scripts/bootstrap.sh`**: the toolchain bootstrap `session-start.sh` had always
  called and nothing provided. Installs shellcheck, persists PATH, warms the `origin/<default>`
  fetch, loud and non-fatal throughout. Its review pass found the blocker in the FIXTURE again —
  a shellcheck-free PATH built by subtraction deletes `/usr/bin` on CI. **D-028**.
- 2026-07-26 — **The STATE landing check tells an edit from a compression pass** (D-016 item 11).
  It read every byte lost above the soft cap as a pass in progress, so a 15-byte deletion had to
  compress the whole file or be reverted; twice, the compliant move was to *pad the file back*.
  Now branches on the shrink's size and whether it crosses the cap, and names the branch.
  **D-027**, superseding D-011's closing sentence.
- 2026-07-26 — **Founding build closed out** (U1–U6): release workflow, `README.md`, end-to-end
  instantiation test, `INIT_PLACEHOLDERS` bound to its document, build plan deleted. **D-025**.
- 2026-07-26 — **Five repair units**: the command guard's `<<<` regression that voided every rail
  and five more mistake classes; the ladder's off switch closed and three zero-coverage guards
  given fixtures; first-ever green CI at run 14; `redact.sh` widened to the shapes in circulation
  with an exact-match self-test; the adopter path walked end-to-end, which is what found the
  citation defect. **D-016**, **D-017**, **D-019**…**D-024**.
- 2026-07-25/26 — **Founding day and the server-side rails.** U1–U4 (self-hosting core,
  legislation, adopter templates, harness prose + bundle); rule review applied (14 findings, 13
  fixed); env-dump rails closed in `command-guard.sh`, **which shipped with a regression**; then
  branch protection on `main` plus secret-scanning push protection (owner), closing P13's
  server-side half. **D-001**…**D-014**, **D-016**.
