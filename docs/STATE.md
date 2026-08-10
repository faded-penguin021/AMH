# STATE — project state & session memory

> **Length guard (hysteresis).** The three thresholds are `STATE_WARN_KB`,
> `STATE_COMPRESS_TO_KB` and `STATE_HARD_KB` in `amh.conf`, and they are deliberately **not**
> restated here as numbers: nothing checks this prose against the config, so a restated number
> is a drift class no guard here covers (**DB-022**). Read them from `amh.conf` when you need
> them. The ladder's size rung prints whichever of them a verdict needs — the floor on its warn
> and fail lines, and again on the `ok` confirming a completed landing, so a green run can name
> all three. Those are derived from `amh.conf`, not copied from it (the landing line is in bytes,
> the key in KB), so a printed number is the guard's arithmetic, not a fourth copy (**DB-025**).
> Grow freely to the soft cap; over it, ONE deep pass landing at or below the compression
> floor — a ceiling, not a target; anywhere below is fine, a comfortable margin under it is
> fine, and you do not keep shaving once under (owner, 2026-07-27). Fail above the hard cap.
> **Compress by folding whole completed stages into Changelog pointer lines and moving durable
> lessons to the ledger** —
> never by shaving clauses until the guard goes quiet, and never by cutting text into another
> file. If the first pass lands short, fold MORE stages: micro-trimming toward the floor is the
> same reflex the band exists to break, one threshold lower. A typo fix above the cap is allowed
> and still owes the pass (**D-027**). The ladder checks sizes, structure and repeated headings
> (**D-034**) and nothing else — it will not judge whether what survived is any good, and it will
> not stop you dropping an open owner-queue item. Never drop one.

## Project

The AMH meta-repository: both the **source of truth** for the Agentic Maintenance Harness — a
reusable operating prompt plus scaffolds for repos maintained by agentic AI sessions — and its
**reference instance**, running byte-identical copies of the scripts it ships. The product is
`harness/` (prose source, templates, generated bundle); this repo's instance is `AGENTS.md` +
`docs/` + `scripts/` + `amh.conf`. Adopted harness version: **AMH 5.2.1** — see `harness/VERSION`,
the copy that counts.

## Current state

AMH 5.2.0 is tagged and published on origin at `7a7c81e` (confirmed by `git ls-remote --tags`,
which closed the queue item asking for it rather than restating it — the DA-011 shape, twice
running). This branch's work is classified **5.2.1** (PATCH, agent) and all five hand-maintained
copies say so; the tag is queued. The classification is queued for the owner too, because the
5.2.0 precedent cuts the other way: the owner called that one MINOR since its Upgrading section
asked adopters to copy new seed wording. This one asks them to correct wording they already
have, and nothing they do today becomes wrong — the PATCH row of the table.

Committed ledger rows are append-only, enforced against `HEAD` by a repo-local guard: two
metadata additions are sanctioned, everything else must stay byte-identical, and rows absent
from `HEAD` are draft material until commit. **DB-008** and **DB-013** are the record.

## Owner queue

> **Protected section.** Never delete it, and never silently drop items during compression.
> Items leave only when done, answered or triaged — then delete the item and record the outcome
> as a Changelog line or a ledger row.
>
> **How to test an item before restating it, and why the final chat message must:**
> `docs/RUNBOOK.md` → Session discipline 7, which is binding and is not repeated here. The one
> thing that lives here: **`Check:` is deliberately NOT a required field**, so its absence is
> information — it means no command settles this, which is worth knowing before you repeat the
> item to a human (**D-014**).

**OPEN — tag and publish AMH 5.2.1.** `harness/VERSION`, the changelog's top entry, `AGENTS.md`,
this file, `amh.conf` and the README Quick Start all say 5.2.1; the bundle and the manifest are
rebuilt (the manifest's version header moved, no script hash did). Create and push `amh-v5.2.1`
after merge. No check: only the owner may tag or publish.
Check the copies with: `grep -rn '5\.2\.1' harness/VERSION AGENTS.md docs/STATE.md amh.conf README.md`

**OPEN — confirm the 5.2.1 classification (PATCH).** A correction to false seed prose: the
Upgrading note asks adopters to fix a sentence they copied, not to adopt anything new, and no
rule, guard or threshold moved. The tension is with 5.2.0, which the owner called MINOR on the
reasoning that an Upgrading section asking for new seed wording is additive whatever the prose
does; read literally that reasoning makes this MINOR too. Agent shipped PATCH and says so here
rather than guessing quietly. No check: the number is a promise to adopters, and only the owner
makes it.

Everything else currently asked has been answered in the rows the Changelog cites; tags through
5.0.0 are cut and published, and `main`'s protection is repointed at `ladder`.

## Decided non-items (don't re-litigate without new evidence)

A pointer index, not an argument: **read the cited row before reopening any of these**, because
the row is where the reasoning that settled it lives and this line is deliberately too short to
re-litigate from.

- **Settled before the 3.0.0 release, each with its row.** Rendered or templated shipped
  scripts in any form, assurance levels as configuration, and a packaged CLI (**D-002**,
  **DA-001**). Doc-fact guards and a markdown link checker beyond the narrow
  `version-lockstep.sh` and `path-refs.sh`, with the incident bar standing (**D-010**,
  **D-023**). Section-granular `RULE_FILES` — path-granular is the tripwire
  (`docs/RUNBOOK.md`). Self-reported checklists in commits or YAML, permanently; the operative
  test is **does anything downstream consume it?** (P3, **D-014**). A pre-execution rail on
  `git log` under branch-train, where the banner line is the accepted form (**DA-003**). A
  *failing* byte cap on the ledger, hook-invocation detection in the boot banner and a *shipped*
  config-schema guard, whose intents were adopted in other forms (**DA-022**). A guard checking
  the session branch against `BRANCH_PREFIX`, which would fail every legitimately-assigned
  branch (**DA-022**).
- **The RFC-era refusals, three rows.** A runtime capability manifest, the script to write it,
  the lifecycle probe layer, runtime profiles, a second setup extension point, and "gates consume
  observed facts where justified" — **DA-024**. RFC2's run-receipt FORMAT, its local transport,
  the CI artifact and a status tool — **DA-025**, which also scopes what a record may still be.
  Five of RFC3's seven scenarios, per-scenario YAML, an oracle directory and in-tree reports —
  **DA-026**, and the five failed provenance three DIFFERENT ways that the row must be read to
  see. Each of the three carries an argument this line deliberately does not reproduce.
- **The 2026-08-10 review's two refusals** — **DB-024**.

## Changelog

One line per shipped change or completed unit (newest first). Details live in the cited ledger
rows — this section is a pointer index, not a narrative.

- 2026-08-10 — **The seed STATE preamble said a passing ladder never prints the compression
  floor; it does.** 5.1.0's "read the thresholds from `amh.conf`" paragraph closed on an
  inference about the ladder's output, and the inference was false: `guard_state_size`'s landing
  branch names the floor on the `ok` line confirming a completed landing, and the shipped
  `state_landing_good` fixture makes a fully green run print it. Reproduced before repairing,
  not argued from the source. The claim had spread to all three prose copies — the seed adopters
  copy, this file's preamble, and **DB-023**, whose parenthetical carried it into the ledger; the
  row keeps its text and its still-valid rule, gains a supersession pointer, and **DB-025**
  carries both forward corrected. Prose about a guard's OUTPUT turns out to be the same drift
  class DB-022/DB-023 recorded about its THRESHOLDS, which neither row saw. Shipped as 5.2.1
  (PATCH, queued for owner confirmation); no guard, threshold, fixture or exit code changed.
  `amh-v5.2.0` was found already published by testing the queue item rather than restating it.

- 2026-08-10 — **The seed STATE preamble now states the end of what is machine-checked.** It
  listed the ladder's checks and never said the list was complete, so the prose after it — grow
  to the soft cap, no trimming below that line — read as enforced. An adopting instance deep-
  compressed a STATE file already under the cap, got a plain `ok`, and reported the landing
  check as holed; it is not, and the report was answered rather than acted on as a bug. The
  landing check's sub-cap silence is the absence of a check, and the preamble now says so and
  says why reaching for a threshold to cover it is the wrong repair — that shape fails a session
  for deleting one closed queue item. Same class as the coverage-before-absence entry below: a
  lesson this repo held and adopters never received. The review pass caught the first draft
  shipping the *inverse* defect — "below the soft cap it checks nothing at all", false because
  `guard_state_structure` runs at every size, in an entry whose whole subject is prose
  overstating enforcement; the closure is now scoped to two named functions rather than timeless.
  No guard, threshold, fixture or exit code changed; 5.2.0 (MINOR). `amh-v5.1.0` was confirmed
  already published by testing the queue item, the DA-011 shape again.

- 2026-08-10 — **The 5.1.0 line: prose stops restating configured numbers, and the seeds gain
  the coverage-before-absence rule.** The STATE band, three volume preambles and four seed
  placeholders each copied a number only `amh.conf` is authoritative for — the drift class 5.0.0
  demonstrated, and the one no guard here can police. Prose now names the key. Separately, the
  DA-003 lesson had reached adopters nowhere and is now in both seeds. From an external review
  entered as DATA; two of its four proposals were taken, two refused. The owner classified the
  result MINOR and all five lockstep copies moved to 5.1.0; the tag is queued. `amh-v5.0.0` was
  found already published at `1427669` by testing the queue item rather than restating it — the
  DA-011 shape, committed in the unit shipping a rule against it. **DB-023** and **DB-024** are
  the record.

- 2026-08-04/2026-08-09 — **The 4.1.0 → 5.0.0 line, folded.** The command guard gained one-time
  advisories on a shared, category-scoped mechanism, then a rearm that clears every category
  rather than one. Repo-local guards gained a third verdict — exit 2 behind a `WARN ` marker
  warns without turning the ladder red, an unmarked exit 2 still fails — and the append-only
  guard uses it. The ledger became a chain of volumes with no Z ceiling, then gained append-only
  enforcement over committed rows, a byte-counted per-row cap, and a misfiled row repaired by
  supersession rather than relocation. `shipped-citations.sh` landed: nothing installed into an
  adopter's scan paths may carry a real row id, scoped by destination. `LEDGER_ROW_CHAR_CAP`
  dropped 2000 → 800 and cut as MAJOR, since an adopter omitting the key inherits a stricter
  guard; three preambles spelled the old value `2,000` and escaped a `2000` grep. Two external
  reviews found no critical or major defect. 4.1.0, 4.2.0 and 5.0.0 are tagged and published.
  **DB-007**…**DB-022** are the record.

- 2026-07-25/2026-08-04 — **Everything through AMH 3.0.0 and the RFC integration, folded.**
  Founding and self-hosting; the 2.0.0, 2.1.x and 3.0.0 releases; installation profiles,
  integrity manifests, agent-neutral branches, the Claude and Codex adapters with their
  cross-layer guard, and the ~90-line entry constitution. Then three owner-supplied RFCs,
  entered as DATA under P18 and judged claim by claim rather than obeyed — RFC1 refused at its
  core, RFC2's format refused but its diagnosis right, RFC3 accepted at two scenarios of seven.
  Their residue: the ladder's verdict lines name their subject commit and worktree state, the
  banner reports a runtime inventory, and `conformance/` carries two behavioural scenarios
  behind a self-test that **demonstrates its evaluators are deterministic and nothing whatever
  about how any agent behaves**. No shipped script, flag or dependency was added and no exit
  code moved. Both plans are archived under `docs/history/`. Durable detail is in
  **D-001**…**D-035**, **DA-001**…**DA-026** and **DB-001**…**DB-004**.
