# STATE — project state & session memory

> **Length guard (hysteresis).** Grow freely to **14 KB**; over it, ONE deep pass landing at
> **≤ 9 KB** — a ceiling, not a target; anywhere below it is fine and 7–8 KB is comfortable, but
> do not keep shaving once you are under (owner, 2026-07-27). Fail above **16 KB**.
> **Compress by folding whole completed stages into Changelog pointer lines and moving durable
> lessons to the ledger** — never by shaving clauses until the guard goes quiet. If the first
> pass lands short, fold MORE stages; do not micro-trim toward the floor — that is the same
> reflex the band exists to break, reappearing one threshold lower. Never cut text into a new
> file.
> A typo fix above the cap is allowed and still owes the pass (**D-027**). The ladder checks
> sizes, structure and repeated headings (**D-034**); nothing judges whether what survived is any
> good, and it will not stop you dropping an open owner-queue item. Never drop one.

## Project

The AMH meta-repository: both the **source of truth** for the Agentic Maintenance Harness — a
reusable operating prompt plus scaffolds for repos maintained by agentic AI sessions — and its
**reference instance**, running byte-identical copies of the scripts it ships. The product is
`harness/` (prose source, templates, generated bundle); this repo's instance is `AGENTS.md` +
`docs/` + `scripts/` + `amh.conf`. Adopted harness version: **AMH 3.0.0** — see `harness/VERSION`,
the copy that counts.

## Current state

**ACTIVE PLAN — integrate three owner-supplied RFCs** (`docs/plans/2026-08-03-rfc-integration.md`;
the RFCs are `rfc-1-runtime-capability-contract.md`, `rfc-2-mechanical-run-receipts.md` and
`rfc-3-conformance-lab.md`, landed verbatim and revised in place by review outcome). External
material worked as DATA under P18, the DA-001 precedent. **The owner overrode the incident bar
for this work only** (**DA-023**) and authorised fresh-context reviewers and no new dependency.
The plan's collision table (C1–C14) is reconnaissance — **re-verify each row in the unit that
acts on it**, and S4–S15 are SUPERSEDED prose, drafted against designs the adjudications refused.

**Five units replace twelve segments** (owner chose option (a), 2026-08-04): **U1** the ladder's
subject line ✅ (**DB-001**) · **U2** the session banner's required-tools and adapter-presence
inventory ✅ (**DB-002**) · **U3** `conformance/` plus scenario 1 (stale queue item, DA-011/DA-012) · **U4**
scenario 2 (incomplete negative search, DA-002/DA-003), the adopter-tree absence assertion, and
close-out · **U5** the ledger rollover — the scheme dies at Z and `DAA-` fails silently in BOTH
the row pattern and the volume ordering; the approved fix is unbounded shortlex, **specified in
`docs/LEDGER_B.md`'s preamble**, which also names what it owes the shipped seed. No new shipped
script, artifact or dependency. Standing bar: nothing may ever *consume* a record (P3, DA-001,
DA-025(c)).

Legislation (a binding-rule or guard-semantics diff) means ONE blocking fresh-context reviewer,
strongest tier, one pass, no self-review fallback (D-015, bounded by **D-035**); `RULE_FILES` is
its file-granular tripwire, not its complete scope. **Nearly every pass has found a real defect
inside the FIX** — U1's found six. A session forbidden subagents ASKS rather than parking the
work (runbook).

Standing gotchas: `shellcheck` is CI-only and its rung load-bearing (**D-026**), installed each
remote session by `scripts/bootstrap.sh` under `AMH_REMOTE=1` (**D-028**); run the ladder
DIRECTLY, never piped — a red tree has been pushed that way; **`git log` cannot answer a question
about this repo's past**, the memory tiers ARE the history (**DA-003**); `path-refs.sh` skips
`harness/templates/*`, so template findings are carried here by hand. **No open findings.**
Ledger volumes: `docs/LEDGER.md` closed at D-035, `docs/LEDGER_A.md` at DA-026, `docs/LEDGER_B.md`
live from `DB-001`. A citation's prefix names its file.

## Owner queue

> **Protected section.** Never delete it, and never silently drop items during compression.
> Items leave only when done, answered or triaged — then delete the item and record the
> outcome as a Changelog line or a ledger row. Every session's final chat message restates
> this queue.
>
> **Test each item before you restate it.** Where an item's truth is observable from a session,
> it carries a **Check:** line with the command — run it at the point you would repeat the item,
> and read its OUTPUT against the resolution the item states, never its exit status (a check
> written to detect the unresolved condition exits 0 exactly when the item is still open). An
> item the output shows resolved is DONE: delete it and write the changelog line in the same
> session, never restate it with a caveat. Where it is not observable, the item says so and names
> who can settle it; restate that as *unverified*, never as pending.
>
> **`Check:` is deliberately NOT a required field.** An item that must carry one will get one —
> "the owner says so" is a check the way a checkbox is evidence, and a queue full of those reads
> as verified while asserting nothing (**D-014**). Its absence is information: it means no
> command settles this, which is itself worth knowing before you repeat the item to a human.

**OPEN — the version bump for this work, at close-out.** Additive shipped-script behaviour reads
MINOR; U5 changes guard semantics (the ledger row pattern and volume ordering), which reads
MAJOR. The runbook makes an ambiguous call yours. **Recommend MINOR** if U5 lands as a pure
superset — every existing `D-`/`DA-`/`DB-` citation still resolves, no adopter must act — and
MAJOR on any adopter-visible break. Raise again once U5 is built. No check: a semantics
judgement.

**OPEN — RFC3 criterion 2: one conformance scenario run through a hosted agent.** Needs a hosted
task launch on a disposable remote, which an agent session may not assume (C14, **DA-026**). You
launch it and name the branch; I point the same deterministic oracle at it. Until then the lab
demonstrates its evaluators are deterministic and mutation-sensitive, and **nothing whatever**
about how any agent behaves — that sentence belongs in the lab's README and in any release claim.
No check: only you can settle it.

**Open questions:** none. Answered and recorded: the 2.0.0 severity call and rule-scope additions
(**DA-005**); the D-005/D-014/D-018 closures (**D-035**); the RFC scope fork (option (a)); the
U5 scheme (unbounded shortlex). Closed earlier: the 2.0.0, 2.1.0, 2.1.1 and 3.0.0 releases, each
verified by `git ls-remote` naming its tag, and `main`'s protection repointed at `ladder`.

## Decided non-items (don't re-litigate without new evidence)

A pointer index, not an argument: **read the cited row before reopening any of these**, because
the row is where the reasoning that settled it lives and this line is deliberately too short to
re-litigate from.

- Rendered/templated shipped scripts, in any form, per-assurance-level included — **D-002**,
  **DA-001**.
- Doc-fact guards and a markdown link checker; `version-lockstep.sh` and `path-refs.sh` are the
  narrow forms admitted, and the incident bar stands — **D-010**, **D-023**.
- Section-granular `RULE_FILES` — path-granular is the tripwire (`docs/RUNBOOK.md`).
- Self-reported checklists in commits or YAML, permanently; the operative test is **does anything
  downstream consume it?** — P3, **D-014**.
- A pre-execution rail on `git log` under branch-train; the banner line is the accepted form —
  **DA-003**.
- Assurance levels as configuration, and a packaged CLI for distribution — **DA-001**.
- A *failing* byte cap on the ledger, hook-invocation detection in the boot banner, and a
  *shipped* config-schema guard — the intents were adopted in other forms; the mechanisms were
  refused — **DA-022**.
- A guard that checks the session branch matches `BRANCH_PREFIX` — the harness assigns the name;
  such a guard fails every legitimately-assigned branch — **DA-022**.
- A runtime capability manifest and a runtime-doctor script to write it; the lifecycle probe
  layer; runtime profiles; a second setup extension point; and "gates consume observed facts
  where justified", a wider hole than the one DA-001(c) closed — **DA-024**. The nonce-marker
  probe is **not** new evidence against DA-022: a marker cannot name its caller, and the mandated
  manual path writes a byte-identical one.
- RFC2's run-receipt FORMAT, its ignored local transport, the CI receipt artifact and a status
  tool to render one — forgeable, and a flat enum cannot express a verdict space where WARN
  deliberately outranks `skip` (**D-019**) — **DA-025**. Scope precisely: a record a human reads
  stays permitted while DA-025(c)'s three conditions hold. The refusal is that format and those
  mechanisms, never the idea of a record; the gap it correctly found was closed in the ladder's
  own verdict lines (**DB-001**).
- A seven-scenario conformance lab with per-scenario YAML metadata, an oracle directory and an
  in-tree reports transport — **DA-026**. Two scenarios seeded on recorded rows survive; the
  other five failed provenance three DIFFERENT ways, which this line must not flatten — three had
  zero ledger hits, one is *inverse* to its recorded instance (D-020 records the agent narrowing
  the checker, not altering production code), and one lost its subject when DA-024 landed.

## Changelog

One line per shipped change or completed unit (newest first). Details live in the cited ledger
rows and in git history — this section is a pointer index, not a narrative.

- 2026-08-04 — **U2: the session banner reports a runtime inventory** (**DB-002**). RFC1's
  surviving residue: two `amh.conf` lists, probed and printed, no file written and no shipped
  script added. Tools are observed/unavailable, adapter files configured/unknown — never
  observed, never unavailable. Eleven fixtures, ten failing against the pre-change tree. The
  blocking pass found six defects, the sharpest being that `command -v` resolves builtins and
  functions, so the probe reported the script's OWN helper as an installed tool; `type -P` now.
  Two new adopter-facing keys, so the release changelog owes them an Upgrading note.

- 2026-08-04 — **U1: the ladder says green OF WHAT, and the owner chose option (a)** — build the
  RFC residue, plus a fifth unit for the ledger rollover. All five verdict lines now name their
  subject commit and worktree state; eleven fixtures; no artifact, flag, vocabulary or shipped
  script added. The blocking pass found six defects and changed the design. `docs/LEDGER_B.md`
  opened at the rollover, and the Decided non-items entries **DA-024**(d) had left owed are
  written. No refusal was reopened. **DB-001** is the record.

- 2026-08-03 — **The three owner-supplied RFCs, landed and fully adjudicated** (**DA-023**
  through **DA-026**): entered as DATA under P18 and judged claim by claim, not obeyed. RFC1
  refused at its core, RFC2's format refused but its diagnosis right, RFC3 accepted at two
  scenarios of seven. Those four rows are the record.

- 2026-07-25/2026-08-02 — **Everything through AMH 3.0.0, folded**: founding and self-hosting;
  2.0.0, 2.1.x and the 3.0.0 MAJOR that let a completed plan retire into the archive;
  installation profiles and integrity manifests; release and queue visibility; agent-neutral
  branches; Claude and Codex adapter delivery with its cross-layer guard; the ~90-line entry
  constitution with query-first bounded reading and its navigation guard; the ledger as stated
  retrieval storage; the command guard's does-NOT-catch block; `config-schema.sh`. The completed
  external-review plan is archived at `docs/history/2026-07-28-external-review-validation.md`.
  Durable detail is in **D-001**…**D-035** and **DA-001**…**DA-022**; those rows are the record.
