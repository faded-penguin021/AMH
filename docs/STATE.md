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
`docs/` + `scripts/` + `amh.conf`. Adopted harness version: **AMH 2.1.0** — see `harness/VERSION`,
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

**A queue item outlives its own truth, and a session that restates it ships nonsense** — the
2.0.0 release item was restated as pending in a session that began after both the merge and the
tag (**DA-011**). 2.1.0 is the fix: the rule is now in `AGENTS.md`, the runbook, P9 and the
seeds, and the session banner reports the release window it could not see. What a check can
honestly claim, and where the first draft over-claimed, is **DA-012**.

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

**Pending owner actions — none.** Three closed on 2026-07-27: the 2.0.0 release (merged and
tagged, verified against `git ls-remote`), `main`'s branch protection repointed at `ladder`,
and the 2.1.0 release (PR #4 merged, tag `amh-v2.1.0` verified via `git ls-remote`).

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

- 2026-07-27 — **Guard fail messages now coach toward deep-folding, and the Quick Start prompt
  primes the agent for the profile question** (**DA-013**). Two failures observed in a real
  deployment: (1) a compression pass that landed short triggered micro-trim iterations because
  the guard said "go to the floor" without saying how; (2) the agent skipped the profile
  question because the owner's prompt didn't mention it, so nothing primed the expectation
  before AMH-ADOPT.md. The seed template preamble now addresses the short-first-pass pattern
  explicitly.
- 2026-07-27 — **AMH 2.1.0: the release window became visible, and the queue learned to test itself.**
  `session-start.sh` now looks for the tag the version file implies — clone first, then `origin`
  — and reports present / absent / could-not-ask as three outcomes; `VERSION_FILE` and
  `RELEASE_TAG_PREFIX` are new `amh.conf` keys, empty by default so no existing adopter changes.
  Queue items carry a **Check:** command where one exists, optional by design. Its pass found the
  fix's own defects: the first draft read local refs while the constitution claimed it answered
  whether the tag *exists*, which in this clone (tags never fetched) would have cried wolf every
  session forever — with a fixture pinning the false alarm as correct (**DA-012**).
  Owner, same day: branch protection repointed at `ladder`, closing the phantom `build` context.
- 2026-07-27 — **`docs/UPGRADING.md` gained the upgrade counterpart to the Quick Start block**
  (owner: the instantiation path had one, the upgrade path did not). It resolves the newest tag
  with `ls-remote | sort -V | tail -1` instead of naming a version, so it is not a sixth
  hand-written copy for `version-lockstep.sh` to miss — verified against the real remote, which
  returns `amh-v2.0.0` until 2.1.0 is tagged.
- 2026-07-27 — **README Quick Start is a paste-into-your-agent block** (owner request), by-hand
  path under it. The pinned tag stays a SINGLE occurrence: `version-lockstep.sh` checks the first
  match only, so the manual block reuses the clone rather than repeating the tag.
- 2026-07-27 — **The instantiation plan, U1–U4, shipped as AMH 2.0.0**, plan file deleted (P16):
  the adoption brief, install profiles, the shipped-script integrity manifest and its rung, and
  the quickstart rewritten against the tag it pins — **DA-002**, **DA-006**…**DA-010**.
- 2026-07-25/27 — **Everything before the release, folded**: founding day, the self-hosting core
  and its legislation, the adopter templates and harness bundle, the server-side rails, first
  green CI, the founding train's merge and the ledger's rollover to volume A, the external RFC
  evaluated as data, and the archive-intake correction that made this release a MAJOR. The detail
  is permanent in **D-001**…**D-035** and **DA-001**…**DA-005**; those rows, not this line, are
  the record.
