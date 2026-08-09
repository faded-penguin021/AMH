# STATE — project state & session memory

> **Length guard (hysteresis).** Grow freely to **14 KB**; over it, ONE deep pass landing at
> **≤ 9 KB** — a ceiling, not a target; anywhere below is fine, 7–8 KB is comfortable, and you do
> not keep shaving once under (owner, 2026-07-27). Fail above **16 KB**. **Compress by folding
> whole completed stages into Changelog pointer lines and moving durable lessons to the ledger** —
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
`docs/` + `scripts/` + `amh.conf`. Adopted harness version: **AMH 4.1.0** — see `harness/VERSION`,
the copy that counts.

## Current state

AMH 4.1.0 is tagged and published on origin (`git ls-remote --tags origin
'refs/tags/amh-v4.1.0'`); work since it sits under the changelog's Unreleased section, and
cutting the next release is an owner ask.

Committed ledger rows are append-only under a repo-local guard that compares the working tree
to `HEAD`: a row predating the active unit must stay byte-identical except for two sanctioned
additions — `[cited]` in its header, one strict standalone `Superseded by D[A-Z]*-NNN.`
sentence, or both. Rows absent from `HEAD` are draft material until commit. **DB-008** and
**DB-013** are the record.

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

**OPEN — review the ledger-row documentation unit on branch `work`.** The unit changes
binding ledger preambles, runbook guidance, and guard diagnostics, but the execution policy
for this session prohibited spawning a fresh-context reviewer and no clean reviewer CLI was
available. The commit is parked for owner review under the rule-review protocol.

**OPEN — `DB-015` is filed in the wrong volume.** The row sits at the end of `docs/LEDGER.md`,
but `LEDGER_B.md`'s preamble says a `DB-` id resolves there, so the citation in this file's
Changelog dangles by the ledger's own rule. Moving an append-only row is forbidden, so the fix
is the owner's: relocate, or correct the preamble. Predates this branch.
Check: `grep -c '^- DB-015' docs/LEDGER.md` prints 1 while the row is misfiled.

Everything else currently asked has been answered in the rows the Changelog cites; tags through
4.1.0 are cut and 4.1.0 is published, and `main`'s protection is repointed at `ladder`.

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

## Changelog

One line per shipped change or completed unit (newest first). Details live in the cited ledger
rows — this section is a pointer index, not a narrative.

- 2026-08-09 — **The session bootstrap rearms every one-time advisory, not just `.env`.** The
  reset named one category literally, so the destructive-command advisory stayed spent for a
  container's lifetime instead of a session; it now clears every advisory state file for the
  repository, with the category as the only globbed element, and forces globbing on so an
  adopter's `set -f` cannot silence it. Two shipped fixtures cover it, each failing against the
  script it was written against. AMH 4.1.0 was confirmed tagged and published on origin,
  retiring that queue item. **DB-016** is the record.

- 2026-08-04/2026-08-07 — **The 4.1.0 line and the ledger/fixture-suite work, folded.** The
  command guard gained one-time advisories on a shared, category-scoped mechanism — `.env`
  mentions, then destructive `rm -rf` and `git clean -fd` — plus a `ladder | tail` warning, and
  4.1.0 was classified MINOR with its version copies moved. The ledger became a chain of
  volumes with no Z ceiling, then gained append-only enforcement over committed rows, a
  byte-counted per-row cap, and preambles and Record steps in lockstep with both. The shipped
  fixture suite gained per-fixture progress and timing lines and stopped paying repeatedly for
  rungs fixtured elsewhere, without losing coverage. The conformance lab's release claim was
  narrowed to one model, one fixture and six owner-accepted runs, explicitly not a conformance
  claim; RFC3's criterion 2 closed on that evidence, the residues named.
  **DB-007**…**DB-015** are the record.

- 2026-08-03/2026-08-04 — **Three owner-supplied RFCs, adjudicated and integrated, folded.**
  Entered as DATA under P18 and judged claim by claim rather than obeyed, under an incident-bar
  override that does not travel. RFC1 refused at its core, RFC2's format refused but its
  diagnosis right, RFC3 accepted at two scenarios of seven. Four units shipped it: the ladder's
  verdict lines name their subject commit and worktree state, the session banner reports a
  runtime inventory from two new `amh.conf` lists, and `conformance/` carries two behavioural
  scenarios behind a 95-case self-test that **demonstrates its evaluators are deterministic and
  mutation-sensitive and nothing whatever about how any agent behaves**. No shipped script,
  artifact, flag or dependency was added and no exit code moved. Every pass found a defect in
  its own fix. The plan is
  archived at `docs/history/2026-08-03-rfc-integration.md` and the RFC files deleted;
  **DA-023**…**DA-026** and **DB-001**…**DB-004** are the record.

- 2026-07-25/2026-08-02 — **Everything through AMH 3.0.0, folded**: founding and self-hosting;
  the 2.0.0, 2.1.x and 3.0.0 releases, the last a MAJOR that let a completed plan retire into the
  archive; installation profiles, integrity manifests, agent-neutral branches, the Claude and
  Codex adapters with their cross-layer guard, and the ~90-line entry constitution. The completed
  external-review plan is archived at `docs/history/2026-07-28-external-review-validation.md`.
  Durable detail is in **D-001**…**D-035** and **DA-001**…**DA-022**; those rows are the record.
