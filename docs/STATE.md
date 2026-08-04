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
`docs/` + `scripts/` + `amh.conf`. Adopted harness version: **AMH 3.0.0** — see `harness/VERSION`,
the copy that counts.

## Current state

**U5, the ledger rollover, is the only open unit, and it is NOT BUILT.** The volume scheme dies
at Z, and `DAA-` fails silently in BOTH the row pattern and the volume ordering at once. The
mechanism, the approved fix (unbounded shortlex) and what it owes the shipped seed are
**specified in `docs/LEDGER_B.md`'s preamble** and are not repeated here. It is a
guard-semantics change: legislation, owing its own pass. Twenty-four volumes of headroom remain,
so do not invent `DAA-` before it lands.

Legislation (a binding-rule or guard-semantics diff) means ONE blocking fresh-context reviewer,
strongest tier, one pass, no self-review fallback (D-015, bounded by **D-035**); `RULE_FILES` is
its file-granular tripwire, not its complete scope. **Nearly every pass has found a real defect
inside the FIX.** A session forbidden subagents ASKS rather than parking the work (runbook).
Standing bar: nothing may ever *consume* a record (P3, DA-001, DA-025(c)).

Standing gotchas: `shellcheck` is CI-only and its rung load-bearing (**D-026**), installed each
remote session by `scripts/bootstrap.sh` under `AMH_REMOTE=1` (**D-028**); run the ladder
DIRECTLY, never piped — a red tree has been pushed that way; **`git log` cannot answer a question
about this repo's past**, the memory tiers ARE the history (**DA-003**); `path-refs.sh` skips
`harness/templates/*` and the plans directory but NOT `docs/history/*`, so template findings are
carried here by hand and a document retired into the archive must resolve every path it backticks
(**DB-004**(d)). **No open findings.** Ledger volumes: `docs/LEDGER.md` closed at D-035,
`docs/LEDGER_A.md` at DA-026, `docs/LEDGER_B.md` live from `DB-001`. A citation's prefix names
its file.

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

**OPEN — U5, the ledger rollover, is BLOCKED WORK, not a finished stage.** It is the only unit
of the approved five that is not built. The scheme dies at Z and `DAA-` fails silently in both
the row pattern and the volume ordering; the mechanism and the approved fix (unbounded shortlex)
are specified in `docs/LEDGER_B.md`'s preamble. It is a guard-semantics change, so it is
legislation and owes its own blocking pass.
*This item exists because the narrative above is not durable.* U5 was tracked only in **Current
state**, which a compression pass is supposed to fold — and the plan file that would normally
hold the checklist was archived at close-out (P16), taking the checklist with it. An item here
cannot be silently dropped; a paragraph up there can. **DB-005.** Nothing enforces that, and
nothing may: a guard reading "is the remaining work still tracked?" would be consuming a
self-report. Delete this item only when U5 has landed or the owner drops it.

**OPEN — the version bump for this work.** `harness/CHANGELOG.md` now carries an **Unreleased**
section with its Upgrading notes and deliberately no number, because a heading is a claim; read
it for what shipped. U1–U4 are additive, which reads MINOR; U5 changes guard semantics, which
reads MAJOR, and the runbook makes an ambiguous call yours. **Recommend MINOR** if U5 lands as a
pure superset — every existing `D-`/`DA-`/`DB-` citation still resolves and no adopter must act —
and MAJOR on any adopter-visible break. Settle it once U5 is built; the bump then touches five
lockstep copies plus the manifest and the bundle. No check: a semantics judgement.

**OPEN — RFC3 criterion 2: one conformance scenario run through a hosted agent.** Needs a hosted
task launch on a disposable remote, which an agent session may not assume (**DA-026**). You
launch it and name the branch; I point the same deterministic evaluator at that clone —
`conformance/evaluators/02-incomplete-negative-search.sh --result <clone> --baseline <sha>`, or
scenario 1 the same way. **Both** scenarios are built, so either will do. Until then the lab says
nothing whatever about how any agent behaves, in the words `conformance/README.md` opens with and
every release claim carries. No check: only you can settle it.

**Open questions:** none. Everything asked has been answered and recorded in the rows the
Changelog cites; the release tags through 3.0.0 are cut and each was verified by `git ls-remote`
naming it, and `main`'s protection is repointed at `ladder`.

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
