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
`docs/` + `scripts/` + `amh.conf`. Adopted harness version: **AMH 4.0.0** — see `harness/VERSION`,
the copy that counts.

## Current state

**U6 has landed: committed ledger rows are protected by a repo-local append-only guard.** The
guard compares the working tree to `HEAD`, so rows that predate the active unit must remain
present and byte-identical; the sole allowed edit is appending one strict standalone
`Superseded by D[A-Z]*-NNN.` sentence. Rows first created in the uncommitted unit remain draft
material until commit. **DB-008** records the rule and its tradeoff. The owner has classified
U1–U6 as AMH 4.0.0; publishing the tag remains queued below.

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

**OPEN — publish AMH 4.0.0.** Version files and changelog now name 4.0.0, but tagging
and publishing are owner steps. Create and push `amh-v4.0.0` after merge. No check: only the
owner may tag/publish.

**Open questions — ONE.** What may the lab now claim? The owner has accepted six agent-backed
runs as satisfying RFC3 criterion 2 (**DB-009**), so `conformance/README.md`'s opening — "until
an owner funds a model-backed run on a disposable remote, this lab demonstrates that its
evaluators are deterministic and mutation-sensitive… it demonstrates nothing whatever about how
any agent behaves" — is now stale in its premise, and that sentence is the one every release
claim carries. The honest replacement is narrower than "the lab works": A5 held 6/6, so six
subjects of one model on one fixture did not reproduce the DA-003 class, and A6's 5/6 break says
more about the evaluator than about them. Recommendation: keep the release-claims bound and
restate it as one model, one fixture, six runs, with the DB-009(d) residues named — never as a
conformance claim. Owner's call because it is a release claim, not a description. Everything else
asked has been answered in the rows the Changelog cites; tags through 3.0.0 are cut, each
verified by `git ls-remote` naming it, and `main`'s protection is repointed at `ladder`.

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

- 2026-08-05 — **RFC3 criterion 2 closed by owner decision.** The owner accepted the six
  agent-backed scenario-02 runs as satisfying it, over the two residues **DB-009**(d) names —
  a container rather than a disposable remote, and verdicts relayed by the launching process.
  The queue item is retired; what the lab may now claim replaces it as the open question.

- 2026-08-05 — **Scenario 02 run through six agent-backed subjects; the finding is the
  evaluator's own, and no behaviour shipped.** A5 held 6/6 — the DA-003 class the scenario exists
  to catch was not reproduced once — while A6 broke 5/6 on the control row, every time inside a
  sentence excluding it. A task-text fix was tried, failed its first verification run by making
  the answer worse, and was reverted unshipped. The cause is polarity-blindness in
  `ids_named_in`, which over-fires A6 and under-fires A5 alike; it is now DECLARED in the
  evaluator rather than patched, because separating an asserted citation from a disclaimed one is
  the manufactured oracle P19 refuses. **DB-009** is the record.

- 2026-08-04 — **Release classification set to AMH 4.0.0.** Owner answered the version fork as
  MAJOR; the changelog's Unreleased section became 4.0.0, lockstep version copies moved, and
  the Quick Start now pins `amh-v4.0.0`. Tagging/publishing remain owner work.

- 2026-08-04 — **U6: committed ledger rows are append-only under a local guard.** Added
  `scripts/guards/ledger-append-only.sh` plus fixtures covering deletion, arbitrary rewrite,
  strict supersession and new-row draft freedom. The guard compares against `HEAD`, fails if a
  pre-existing row id disappears or changes, and permits only a standalone final `Superseded by
  D[A-Z]*-NNN.` sentence on an existing row; rows absent from `HEAD` stay editable until commit.
  **DB-008** is the record.

- 2026-08-04 — **U5: the ledger volume scheme no longer ends at Z, and volumes became a
  chain.** Unbounded whole-word row pattern; the live volume walked from the base file by the
  same carry rule that names the next one, so a file the walk cannot reach is not a volume;
  rows read from that chain, so the cap rung and the citation guard cannot disagree about what
  a volume is; unreachable volume-shaped files warned, a missing base volume failed. Fifteen
  new fixtures, thirteen of which fail against the pre-change script. The blocking pass found two defects inside the fix and its own comment reintroduced
  a third; **DB-007** is the record.

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
