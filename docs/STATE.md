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

> **Session handoff (2026-08-03).** Adopted version is **AMH 3.0.0** and the tag is confirmed on
> origin, so that queue item is closed. A new multi-session plan is ACTIVE:
> `2026-08-03-rfc-integration.md`. The external-review plan is COMPLETE and archived at
> `docs/history/2026-07-28-external-review-validation.md`.

**ACTIVE PLAN — integrate three owner-supplied RFCs** (`docs/plans/2026-08-03-rfc-integration.md`;
the RFCs themselves are `rfc-1-runtime-capability-contract.md`, `rfc-2-mechanical-run-receipts.md`
and `rfc-3-conformance-lab.md`, landed verbatim and revised in place by review outcome). They are
external material worked as DATA under P18, the DA-001 precedent. **The owner overrode the
incident bar for this work only** (**DA-023**, the DA-008 shape) and authorised fresh-context
reviewers, full acceptance criteria, and no new dependency — JSON is hand-rolled, `jq` is not
adopted. Segments: S0 land ✅ · S1–S3 adjudicate each RFC · S4–S6 runtime capability contract ·
S7–S10 mechanical run receipts · S11–S14 conformance lab · S15 close out. The plan's collision
table (C1–C14) is reconnaissance — **re-verify each row inside the segment that acts on it**.
Two known head-on collisions: RFC1 wants hook-invocation detection, which **DA-022** refused and
Decided non-items still bars; and nothing may ever *consume* a manifest or receipt (P3, DA-001).

**Closed stages, folded — the rows are the record**: the Qwen external review, worked as DATA
throughout and adjudicated finding by finding (**DA-022**); the rule that a queue item outlives
its own truth, with what a check can honestly claim (**DA-011**, **DA-012**); and the
agent-neutral branch namespace with its identity-allowlist decision (**DA-014**).

Legislation (a binding-rule or guard-semantics diff) means ONE blocking fresh-context reviewer,
strongest tier, one pass, no self-review fallback (D-015, bounded by **D-035**); `RULE_FILES`
is its file-granular tripwire, not its complete scope. **Twenty-six of
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

**OPEN — two independent passes collapsed the scope you approved.** RFC1 was refused at its core
(**DA-024**) and RFC2's format was too (**DA-025**), so S4–S10 no longer have the subjects they
were written for. What survives both is small and worth building: a required-tools and
adapter-presence line in the existing banner, and the ladder naming its subject commit and
worktree state in its verdict lines — together roughly one unit, no new shipped script, no new
artifact. That collides with your "full acceptance criteria" decision, so the call is yours.
Options: **(a)** build the surviving residue and let the criteria counts fall where the
adjudications left them; **(b)** overturn specific refusals on a stated argument, as you did the
incident bar — name which, and the reasoning goes in the ledger; **(c)** stop after S3 with the
adjudications as the deliverable and build nothing. **Recommend (a).** No check: this is a
judgement about what you want built, and only you can settle it.

*Owed with it:* the refusals belong in Decided non-items below, which is rule-bearing, so that
edit waits for a unit carrying its own rule-review pass. **DA-024** holds them meanwhile.

Five closed: the 2.0.0 release (merged and tagged, verified against
`git ls-remote`), `main`'s branch protection repointed at `ladder`, and the 2.1.0 release
(PR #4 merged, tag `amh-v2.1.0` verified via `git ls-remote`) on 2026-07-27; the
`amh-v2.1.1` tag, confirmed by the owner on 2026-07-29 and re-verified via
`git ls-remote --tags origin amh-v2.1.1` on 2026-08-02; the 3.0.0 release, whose check
output named `refs/tags/amh-v3.0.0` on 2026-08-03.

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
- A *failing* byte cap on the ledger, hook-invocation detection in the boot banner, and a
  *shipped* config-schema guard — the intents were adopted in other forms; the mechanisms were
  refused — **DA-022**.
- A guard that checks the session branch matches `BRANCH_PREFIX` — the harness assigns the name;
  such a guard fails every legitimately-assigned branch — **DA-022**.

## Changelog

One line per shipped change or completed unit (newest first). Details live in the cited ledger
rows and in git history — this section is a pointer index, not a narrative.

- 2026-08-03 — **S2: RFC2's receipt format refused, but it found a real gap** (**DA-025**). The
  ladder prints "green" and never says green OF WHAT — no commit, no worktree state, anywhere in
  a session's output. Closed by two facts in the ladder's own verdict lines, the DA-022(d) shape:
  no format, no transport, no sixth shipped script. A flat six-state enum cannot express a
  verdict space where WARN deliberately outranks skip (**D-019**). Replay found a defect inside
  the review itself — the finding held, its supporting claim did not.

- 2026-08-03 — **S1: RFC1 adjudicated, and refused at its core** (**DA-024**). The absence of a
  capability manifest is a decision here, not a gap — DA-001(d) made assurance emergent from
  repository topology precisely so no code could branch on a machine-readable record. The nonce
  marker is not new evidence against **DA-022**: the probe is circular and the mandated manual
  fallback writes a byte-identical marker. The vocabulary survives as a naming convention.

- 2026-08-03 — **Three owner-supplied RFCs landed verbatim and a multi-session plan opened**
  (**DA-023**). The runtime capability contract, mechanical run receipts and the agent
  conformance lab enter as data under P18, to be adjudicated claim by claim before any of them
  is built. The row records the owner's override of the incident bar, with the argument, so no
  future session cites this as precedent for skipping the bar. The 3.0.0 release queue item
  closed the same session: its check output named `refs/tags/amh-v3.0.0`.

- 2026-08-02 — **AMH 3.0.0.** A MAJOR because one binding rule changed: a completed plan may
  retire into the archive instead of being deleted (**DA-020**). The release also carries the
  work that had accumulated unreleased — the Codex adapter and its cross-layer guard, the
  agent-neutral branch namespace (**DA-014**), the compact constitution and its navigation
  guard (**DA-017**, **DA-018**), the P11 citation scope (**DA-019**), the PR handoff
  checkpoint and the adoption-acceptance corrections — plus this plan's four hardening
  segments, S1–S4. The completed plan is archived at
  `docs/history/2026-07-28-external-review-validation.md`.

- 2026-08-02 — **The external review's four hardening segments landed** (**DA-022**). The ledger
  is stated to be retrieval storage and its cap rung now reports size beside lines; the command
  guard's header carries a consolidated list of what it does NOT catch, and the hookless
  posture is prose; `config-schema.sh` keeps this instance's `amh.conf` complete against the
  shipped example, one-directionally and repo-locally. Both blocking review passes found real
  defects INSIDE the fixes — a wrapper claim that was false, an `awk` claim that contradicted
  the reader list two lines above it, and a guard that reported green with `comm` absent.

- 2026-08-01 — **The harness-wide consistency audit closed three stale plan-lifecycle phrases**
  (**DA-021**). The shipped advisory, scaffold description and active plan now agree with
  P2/P16; no new principle, consolidation or unplanned component earned its cost, while the
  approved S1–S5 roadmap remains the bounded source of prospective hardening work.

- 2026-08-01 — **Completed plans may now retire whole into `docs/history/`** (**DA-020**).
  Plans worth retaining become frozen archive context while durable outcomes and implementation
  citations remain in the ledger; repositories without the archive tier still delete them.

- 2026-08-01 — **Adoption and initializer prose now describe only what the executable checks.**
  The README calls the ladder the mechanical gate without treating it as proof that manual
  adoption obligations were completed; installer E2E comments name their guards-only scope;
  the initializer points at the existing downstream malformed-flag defence rather than an open
  finding.

- 2026-07-25/31 — **Everything through the compact constitution, folded**: founding and
  self-hosting, AMH 2.0.0 and 2.1.x, installation profiles and integrity manifests, release and
  queue visibility, agent-neutral branches, Claude/Codex adapter delivery and its cross-layer
  guard, PR-template guidance, context-compression coaching; then the ~90-line entry constitution
  itself, query-first bounded document reading with its navigation guard, and the structural
  review that found one prose/guard scope mismatch rather than missing principles. Durable detail
  is in **D-001**…**D-035** and **DA-001**…**DA-019**; those rows, not this line, are the record.
