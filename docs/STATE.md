# STATE — project state & session memory

> **Length guard (hysteresis).** The thresholds `STATE_WARN_KB`, both compression-floor keys
> and `STATE_HARD_KB` live in `amh.conf`, deliberately **not** restated here as numbers: nothing
> checks this prose against the config, so a restated number is a drift class no guard here
> covers (**DB-022**). Which of them the size rung prints, and why a number it printed is never a
> copy to quote back, are in `docs/RUNBOOK.md` → **Acceptance ladder** — a description of the
> guard's output, kept out of the file the guard measures (**DB-025**).
> Grow freely to the soft cap; over it, ONE deep pass landing at or below the
> compression floor — a ceiling, not a target: anywhere below is fine, and you do not keep
> shaving once under (owner, 2026-07-27). **The floor is a byte size AND a sentence count, and a
> landing satisfies both** (**DC-003**), which is what stops that rule depending on your
> restraint: trimming words cannot move the sentence count, repunctuating cannot move the bytes,
> and folding whole stages is the only move that clears both. Fail above the hard cap, which is
> byte-only like the soft cap — those two say WHEN to compress. **Compress by folding whole
> completed stages into Changelog pointer lines and moving durable lessons to the ledger** —
> never by shaving clauses until the guard goes quiet, and never by cutting text into another
> file: moving a passage OUT is not compression and is the owner's call — granted once, for the
> guard-output description now in the runbook (owner, 2026-08-11).
> Land short and you fold MORE stages. A typo fix above the cap is allowed and still owes
> the pass (**D-027**). The ladder checks sizes, structure and repeated headings (**D-034**) and
> nothing else — not whether what survived is any good, and not whether you dropped an open
> owner-queue item. Never drop one.

## Project

The AMH meta-repository: both the **source of truth** for the Agentic Maintenance Harness — a
reusable operating prompt plus scaffolds for repos maintained by agentic AI sessions — and its
**reference instance**, running byte-identical copies of the scripts it ships. The product is
`harness/` (prose source, templates, generated bundle); this repo's instance is `AGENTS.md` +
`docs/` + `scripts/` + `amh.conf`. Adopted harness version: **AMH 9.0.0** — see `harness/VERSION`,
the copy that counts.

## Current state

AMH **8.0.0** is tagged and published on origin (`amh-v8.0.0` at 6d447b6, confirmed by
`git ls-remote --tags` on 2026-08-17). This branch prepares **9.0.0**, correcting CI triage and
closing the version-lockstep hole that let an `Unreleased` entry sit above the published version.

Committed ledger rows are append-only, enforced against `HEAD` by a repo-local guard whose
sanctioned exceptions and draft-row rule are in **DB-008** and **DB-013**. The live volume is
`docs/LEDGER_C.md`, opened at the 8.0.0 rollover; `docs/LEDGER_B.md` is closed at **DB-040**.

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

**OPEN — tag and publish AMH 9.0.0.** Create and push `amh-v9.0.0` after this branch merges. No
check: only the owner may tag or publish.

**OPEN — `split_segments` cuts braces that blur a destructive target.** Unquoted
`rm -rf ${d}/build` becomes `rm -rf $`, so every unquoted-brace deletion records the same target
`$` and clears the advisory for every other one — the cross-target silence the per-target rearm
exists to stop. Quoting records the real target and the advisory recommends the quoted spelling,
so this is a hole rather than a live wound and remains in the guard header's "does NOT catch"
block. Closing it means teaching the splitter about `${...}`. It is the function every scanner
in the script is built on, so it is its own unit with its own review pass. Check:
`scripts/command-guard.sh --command 'rm -rf ${a}/x'` then
`… --command 'rm -rf ${b}/y'` — the second exits 0.

**WATCH — the macOS rail self-test failure has a repair, but not a proven cause.** The
subshell transport the failure rode is gone: the parsers fill arrays in-process (**DC-002**).
That is the whole of the repair. The fail-closed arm added beside it cannot fire against these
parsers — every non-blank string yields a word and a segment — so it is a tripwire for a future
transport and not a second line of defence here; do not read a green macOS run as proof it
works. If the same eighteen fixtures go red again, the diagnosis was wrong and the mechanism is
still open. **Close after 9 consecutive green `portability (macos-latest)` runs on merged
commits**, replacing a "several" nobody counts — a stand-in for evidence and never evidence,
since no number of green runs disproves an intermittent fault; the 9 is the README's own N+9
rediscovery horizon, and a recurrence inside the count resets it and marks the diagnosis wrong.
Check: the `portability (macos-latest)` job on this branch.

Everything else currently asked has been answered in the rows the Changelog cites; tags through
8.0.0 are cut and published, and `main`'s protection is repointed at `ladder`.

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
- **The RFC-era refusals, three rows, each carrying an argument this line does not reproduce.**
  A runtime capability manifest, the script to write it, the lifecycle probe layer, runtime
  profiles, a second setup extension point and "gates consume observed facts" — **DA-024**.
  RFC2's run-receipt format, its transport, the CI artifact and a status tool — **DA-025**,
  which also scopes what a record may still be. Five of RFC3's seven scenarios, per-scenario YAML, an oracle directory and in-tree
  reports — **DA-026**, whose five failed provenance three DIFFERENT ways.
- **A warning when a ledger row or a compression pass lands in the top decile below its cap**
  (the inverted-gradient guard), declined with the anchor removal that shipped instead: it
  invents a second threshold to hug, and a guard accretes after an incident, not ahead of one
  (**DB-040**). Cap-hugging then survived the removal, and the owner settled the reopening the
  other way: the aim-points gained a second UNIT instead (**DC-003**), which is not a second
  threshold in the same unit and so does not answer to this objection. The objection stands
  unchanged for any future proposal of the top-decile shape.
- **A byte cap on the constitution (`CONSTITUTION_WARN_KB`)**, refused while adding the
  current-state rule that would have motivated it — the defect is kind, not size, and a cap over
  all-live legislation makes shaving a rule the cheapest compliance (**DB-038**).
- **A block-once rail for Python file writes**, declined after a downstream agent used a
  Python heredoc for an opaque text replacement. The reviewability problem is real, but the
  proposed rail is not agent-neutral or artifact-triggered: AMH cannot assume a host provides
  structured edit tools, and recognizing arbitrary interpreter writes means treating heredoc
  program text as commands while missing equivalent writes in other languages (**DC-007**).
- **The 2026-08-10 review's two refusals** — **DB-024**.
- **A guard that opens files to classify them** (owner, 2026-08-11). Reading a `.pem`'s first
  line would separate a private key from a certificate, and it is refused: no rail here opens a
  file, and the advisory tier is the answer instead — **DB-027**.

## Changelog

One line per shipped change or completed unit (newest first). Details live in the cited ledger
rows — this section is a pointer index, not a narrative.

- 2026-08-17 — Prepared 9.0.0: corrected the local-green/CI-red playbook to account for
  index-dependent guard inputs; declined an agent-specific Python-write rail; and made the
  version lockstep reject an unversioned top changelog entry (**DC-007**, **DC-008**).

- 2026-08-15 through 2026-08-17 — **The 8.0.0 train, folded, tagged and published**
  (`amh-v8.0.0` at 6d447b6). The constitution bounded by kind rather than bytes; green verdicts
  stopped printing thresholds; the guard's parsers left subshells; redirections stripped before
  any word is judged; the caps an agent writes toward gained a second unit; an adversarial pass
  closed three enforcement defects; and the context-window question closed as a non-item with
  nothing shipped. **DB-038**…**DB-040** and **DC-001**…**DC-006** are the record; the
  unquoted-brace splitter hole and the macOS WATCH stay queued above.

- 2026-08-11 through 2026-08-15 — **The 6.0.0 through 7.0.2 train, folded.** Private-key read
  rails and block-body redaction; portable working-memory prose; per-operand destructive
  advisories; maximum-not-target ledger guidance; Codex lifecycle hooks and project rule
  reviewer; deterministic bearer-fixture construction; session-namespace push enforcement;
  required PR template use; full base-to-head branch-train descriptions; and cross-platform
  support for the macOS, GNU/Linux and Windows Git Bash toolchains closing with the macOS
  release-tag repair. **DB-026**…**DB-037** are the record.

- 2026-07-25 through 2026-08-10 — **Everything up to 5.2.1, folded.** Founding, self-hosting,
  releases through 5.2.1, the rejected and reduced RFCs, conformance scenarios, lifecycle and
  command rails, ledger chaining and limits, shipped citations, and the prose repairs leading
  into 6.0.0. **D-001**…**D-035**, **DA-001**…**DA-026**, and **DB-001**…**DB-025** are the
  record.
