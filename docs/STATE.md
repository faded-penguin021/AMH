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
`docs/` + `scripts/` + `amh.conf`. Adopted harness version: **AMH 2.1.1** — see `harness/VERSION`,
the copy that counts.

## Current state

> **Session handoff (2026-07-27).** **2.0.0 is released and tagged** (`afd990e`, verified with
> `git ls-remote --tags` rather than inherited from the previous handoff, which had it pending).
> **2.1.0 is written and pushed** on `claude/readme-quick-start-4g4ala`, cut from `main`
> (`git merge-base origin/main HEAD` = `afd990e`), and awaiting merge and tag. **PR #4 is open**
> on head `19ba842` — verified with `list_pull_requests`, after the first draft of this handoff
> asserted a PR that did not exist (**DA-011**, inside the release that fixes it). `amh-v1.8.0`
> still points at `7d322d7`. **No plan is active** (P16). Next work comes from the Owner queue,
> or from the owner.

**An external review by a peer LLM (Qwen, relayed by the owner) is being worked as DATA** (P18,
the DA-001 precedent). Plan: `docs/plans/2026-07-28-external-review-validation.md`, owner-approved
2026-07-28, with the standing constraint that **each finding is verified during its own segment,
never at drafting time** — a claim that fails re-verification is recorded as refused, not built.
Segments: **S0 land the plan ✓** · S1 verdicts to the ledger + non-items · S2 the ledger is
retrieval storage (prose + a byte figure in the rollover rung) · S3 what the rails do NOT catch,
plus the hookless posture · S4 repo-local config-schema guard · S5 low findings + release 2.2.0
and plan deletion. Owner decisions on the record: the rule-review reviewer is **authorized** (a
no-subagents instruction is policy, not capability — the runbook says ask), the hookless gap is
**prose only**, `amh-init.sh`'s `BRANCH_PREFIX` default flips to `session`, and the release is a
**MINOR, 2.2.0**.

**A queue item outlives its own truth, and a session that restates it ships nonsense** — the
2.0.0 release item was restated as pending in a session that began after both the merge and the
tag (**DA-011**). 2.1.0 is the fix: the rule is now in `AGENTS.md`, the runbook, P9 and the
seeds, and the session banner reports the release window it could not see. What a check can
honestly claim, and where the first draft over-claimed, is **DA-012**.

**The session-branch namespace is agent-neutral.** `BRANCH_PREFIX=session` is now the
reference-instance value and the initializer default; an adopter may still choose any value
with `--branch-prefix`. The identity allowlist was reviewed as a separate decision: all three
existing no-reply address forms are used in repository history, so all remain; no
Codex/OpenAI identity was added without owner approval (**DA-014**).

Legislation (a diff touching `RULE_FILES`) means ONE blocking fresh-context reviewer, strongest
tier, one pass, no self-review fallback (D-015, bounded by **D-035**); **twenty-six of
twenty-seven passes found a real defect inside the FIX**. A session forbidden subagents ASKS
rather than parking the work (runbook).

Standing gotchas: `shellcheck` is CI-only and its rung load-bearing (**D-026**), installed each
remote session by `scripts/bootstrap.sh` under `AMH_REMOTE=1` (**D-028**); run the ladder
DIRECTLY, never piped — a red tree has been pushed that way; **`git log` cannot answer a question
about this repo's past**, the memory tiers ARE the history (**DA-003**); `path-refs.sh` skips
`harness/templates/*`, so template findings are carried here by hand. **No open findings.**

**The ledger has rolled over**: `docs/LEDGER.md` is closed at 826 lines (last row D-035);
`docs/LEDGER_A.md` is live from `DA-001`. Append there; a citation's prefix names its file.

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

Four closed: the 2.0.0 release (merged and tagged, verified against
`git ls-remote`), `main`'s branch protection repointed at `ladder`, and the 2.1.0 release
(PR #4 merged, tag `amh-v2.1.0` verified via `git ls-remote`) on 2026-07-27; and the
`amh-v2.1.1` tag, confirmed by the owner on 2026-07-29.

**Open questions:** none. Everything asked before it has been answered and recorded —
the 2.0.0 severity call and the rule-scope additions in **DA-005**, the delegated closures of
D-005, D-014 and D-018 in **D-035**.

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

## Changelog

One line per shipped change or completed unit (newest first). Details live in the cited ledger
rows and in git history — this section is a pointer index, not a narrative.

- 2026-07-30 — **Large-document reading is now query-first and section-bounded** (**DA-017**).
  The constitution states the widening conditions; the runbook gives portable retrieval
  examples; a repo-local guard and mutations keep its five binding section pointers unique and
  resolvable without pretending to prove what an agent read.

- 2026-07-30 — **The reference-instance constitution now provides a compact 90-line entry
  context.** `AGENTS.md` retains irreversible safety boundaries, source/generated ownership,
  universal session entry, and binding pointers while moving operational detail behind the
  existing RUNBOOK, configuration, scripts, STATE, and ledger layers; this reorganizes existing
  governance rather than establishing a new rule.

- 2026-07-25/29 — **Everything before the compact constitution, folded**: founding and
  self-hosting, AMH 2.0.0 and 2.1.x, installation profiles and integrity manifests, release and
  queue visibility, agent-neutral branches, Claude/Codex adapter delivery and its cross-layer
  guard, PR-template guidance, and context-compression coaching. Durable detail is in
  **D-001**…**D-035** and **DA-001**…**DA-016**; those rows, not this line, are the record.
