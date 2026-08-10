# STATE — project state & session memory

> **Length guard (hysteresis).** The three thresholds are `STATE_WARN_KB`,
> `STATE_COMPRESS_TO_KB` and `STATE_HARD_KB` in `amh.conf`, and they are deliberately **not**
> restated here as numbers: nothing checks this prose against the config, so a restated number
> is a drift class no guard here covers (**DB-022**). Read them from `amh.conf` when you need
> them. The ladder's cap rung names the soft and hard caps when it passes and the compression
> floor when it warns or fails — so the floor is the one value a healthy tree never prints.
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
`docs/` + `scripts/` + `amh.conf`. Adopted harness version: **AMH 5.1.0** — see `harness/VERSION`,
the copy that counts.

## Current state

AMH 5.0.0 is tagged and published on origin (`amh-v5.0.0` at `1427669`, confirmed by
`git ls-remote --tags`), which is this branch's merge base. This branch's work is classified
**5.1.0** (MINOR, owner) and all five hand-maintained copies say so; the tag is queued.

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

**OPEN — tag and publish AMH 5.1.0.** `harness/VERSION`, the changelog's top entry, `AGENTS.md`,
this file, `amh.conf` and the README Quick Start all say 5.1.0; the bundle and the manifest are
rebuilt. Create and push `amh-v5.1.0` after merge. No check: only the owner may tag or publish.
Check the copies with: `grep -rn '5\.1\.0' harness/VERSION AGENTS.md docs/STATE.md amh.conf README.md`

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
