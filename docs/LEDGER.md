# DEVIATIONS & DISCOVERIES LEDGER — permanent registry (D-001…)

> **Append-only registry — NEVER archived, compressed or truncated.** This is the canonical,
> permanent home for every numbered deviation and discovery. Code and docs cite entries as
> bare `D-NNN` and those citations must always resolve here; no entry is ever deleted or
> summarised away. Append new entries at the bottom, one continuous sequence. Code and
> fixtures are ground truth: if an entry conflicts with the current code, trust the code and
> **correct** the entry — never delete it.
>
> **Search before appending.** Grep the ledger for the topic first; extend or cite an
> existing row rather than append a near-duplicate. A row that supersedes an older one says
> so ("supersedes D-NNN") and the old row gets a correction pointer, never deletion.
>
> **File cap & rollover.** This file holds at most **800 lines** (the cap bounds LINES, not
> rows — it is read cost that is being bounded, and the number stays in lockstep with
> `LEDGER_LINE_CAP` in `amh.conf`). The final row may finish past the cap, but no row may
> ever *start* past it: when the file stands over the cap, create `LEDGER_A.md` with this
> same header discipline, numbering from **DA-001** (then `_B.md`/`DB-001`, …). Existing
> rows are never moved or renumbered. A citation's prefix names its file.
>
> **`[cited]` marker (machine-managed).** A row cited from the ladder's scan scope carries
> ` [cited]` after its number. The ladder syncs it BOTH directions — cited-but-unmarked and
> marked-but-uncited each fail the build — so it is verified derived state, never
> hand-tracked. The marker warns you that code resolves here before you lean on or reword
> a row.

- D-001: **This repository is both the harness's source of truth and its reference
  instance.** The distributed product lives under `harness/`; the repo's own instance is
  `AGENTS.md` + `docs/` + `scripts/` + `amh.conf`. The two are deliberately not the same
  files: prose scaffolds are *seeds* (copied once, then owned by the adopting repo), while
  scripts are shipped artifacts (copied verbatim, upgradeable). Rationale: a harness whose
  own repo does not run it has no evidence its artifacts work, and an artifact no repo
  executes rots silently.
- D-002: **Shipped scripts are parameter-free and read `amh.conf` at runtime** — they are
  not rendered from `{{PLACEHOLDER}}` templates. A render step would create a permanent
  rendered-vs-template drift class needing its own guard; runtime configuration deletes the
  class instead of policing it. Consequence: `scripts/*.sh` here are byte-identical to
  `harness/templates/scripts/*.sh` and a guard enforces that with `cmp`, which is what makes
  the dogfooding claim checkable rather than aspirational. Supersedes nothing; see the
  Decided non-items entry in `docs/STATE.md`.
- D-003: **The ladder has exactly two extension points**, and they exist so the shipped
  script never needs local edits (which is the precondition for D-002's `cmp` guard):
  `scripts/guards/*.sh` for repo-specific guards, and `scripts/verify.sh` for the full
  test/build/lint rung. A repo that finds itself editing `scripts/ladder.sh` has found a
  missing extension point — fix it upstream in the template, not locally.
- D-004: **The redaction filter is also the secret-shape scan.** The ladder does not carry a
  second copy of the token patterns; it pipes each text file through `scripts/redact.sh` and
  fails if the output differs. The scan is therefore drift-free by construction. Two
  consequences that have already bitten: any fixture token must be generated at runtime
  (a stored literal makes a file permanently fail its own scan — `redact.sh`'s self-test
  caught exactly this on the day it was written), and the diagnostic reports the file and
  byte position only, never the match.
- D-005: **The founding units installed this repo's legislation with no fresh-context rule
  review.** AMH P12 requires a fresh-context, strongest-tier review for every binding-rule
  diff and allows no self-review fallback. For U1–U2 there was no prior constitution to
  review against and no reviewer was spawned; the owner's review at merge stands in. From
  that merge onward the rule-review protocol binds normally. Recorded rather than skipped
  silently, because an undocumented exception becomes precedent.
