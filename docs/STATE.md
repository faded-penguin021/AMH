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
`docs/` + `scripts/` + `amh.conf`. Adopted harness version: **AMH 9.1.0** — see `harness/VERSION`,
the copy that counts.

## Current state

AMH **9.1.0** is prepared on this branch but not yet tagged or published. It adds the
**git-native pre-push rail** (P13): `command-guard.sh
--pre-push`, invoked by git through `.git/hooks/pre-push`, independently rejects default-branch,
force/non-fast-forward and delete pushes — the layer that would have backstopped D-016 item 1,
binding even a hook-less agent. It carries no branch-prefix check (DA-022) and is a guardrail,
not a boundary (`--no-verify` bypasses; git-CLI pushes only).

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

**OPEN — investigate the forge/API mutation surface as an escape around the local rails.** The
pre-push rail (DC-009) guards git-CLI pushes only; an owner-reserved shared-side effect through a
forge/API surface — `gh pr merge`, `gh release create`, `gh api -X POST`, `curl`/`wget`
mutations — bypasses every local rail. Not machinery yet: an adversarial test vector per P3/P10,
earning a narrow rail only if a real session crosses that boundary. No check — nobody but a
session actually crossing it settles this.

**DECIDE — the ledger preamble tells you to correct a stale row; the guard forbids it.** Every
volume preamble says "Code and fixtures are ground truth: if an entry conflicts with the current
code, trust the code and **correct** the entry — never delete it." But
`scripts/guards/ledger-append-only.sh` rejects any edit to a committed row except adding
`[cited]` or a final `Superseded by D-NNN.` line. Hit for real while recording **DC-011**:
DB-014's sentence enumerating the destructive rail's commands became false, the preamble's
remedy is a correction, and the guard refused it. Supersession is the wrong marker — DB-014's
principle stands and only its enumeration went stale, so the row is now knowingly stale in the
tree. **What is needed is one choice, not a discussion:** (a) let the guard accept an appended
line matching a fixed correction form, keeping every existing byte immutable — recommended,
since it preserves append-only while honouring what the preamble already promises; or (b) delete
the correction promise from all four volume preambles and say supersession is the only route.
Either is a rule change and takes the rule-review protocol. Until then prose claims an
affordance the enforcement layer denies, which is the **D-010** class.
Check: append a line to a committed row in `docs/LEDGER_B.md`, run
`scripts/guards/ledger-append-only.sh`, then `git checkout -- docs/LEDGER_B.md` — open while the
guard still exits 1.


**WATCH — the guard's parser changed substantially and has not yet run on stock macOS Bash.**
The macOS eighteen-fixture watch closed on its own terms (see the Changelog line citing
**DC-002**), but it closed on the parser as it stood BEFORE this branch. `DC-011` and `DC-012`
add a git subcommand dispatch, a new operand collector and a third entry point, none of which
has seen bash 3.2 — no 3.2 is available in the session container, so both commits disclose the
gap rather than claim coverage. This is a watch, not a question: it settles itself when the
branch merges. Check: the `portability (macos-latest)` job on the merge commit.

**OPEN — tag and publish AMH 9.1.0 after this branch merges.** Check:
`git ls-remote --tags origin refs/tags/amh-v9.1.0` — resolved when it prints the tag.

Everything else currently asked has been answered in the rows the Changelog cites; tags through
9.0.0 are cut and published, and `main`'s protection is repointed at `ladder`.

## Decided non-items (don't re-litigate without new evidence)

A pointer index, not an argument: **read the cited row before reopening any of these**, because
the row is where the reasoning that settled it lives and this line is deliberately too short to
re-litigate from.

- **Pre-3.0.0 refusals:** rendered or templated shipped scripts, assurance-level configuration,
  a packaged CLI, broad doc-fact/link guards, section-granular `RULE_FILES`, machine-consumed
  self-attestations, a `git log` rail under branch-train, failing ledger caps, hook-invocation
  detection, a shipped config-schema guard, and a `BRANCH_PREFIX` push check (**D-002**,
  **D-010**, **D-014**, **D-023**, **DA-001**, **DA-003**, **DA-022**).
- **RFC refusals:** runtime capability/profile/probe machinery and a second setup extension
  (**DA-024**); run receipts, transport, CI artifact and status tool (**DA-025**); and five
  provenance-defective scenarios plus their YAML/oracle/report machinery (**DA-026**).
- **Later refusals:** the top-decile/inverted-gradient warning (**DB-040**, with **DC-003** the
  adopted two-unit alternative); a constitution byte cap (**DB-038**); a Python-write advisory
  (**DC-007**); the two 2026-08-10 review proposals (**DB-024**); and any guard that opens a file
  to classify it (**DB-027**).

## Changelog

One line per shipped change or completed unit (newest first). Details live in the cited ledger
rows — this section is a pointer index, not a narrative.

- 2026-08-18 through 2026-08-20 — **Prepared AMH 9.1.0.** Git-native pre-push enforcement;
  parameter-expansion-safe segment splitting; broader destructive-git advisories; a Claude
  spawn speed bump with bounded reporting; the SC2015 repair; closure of the original macOS
  watch and opening of the new parser watch; and POSIX-Awk upgrade-tag selection (**DC-009**…
  **DC-012**; **DC-002** is the closed watch record).
- 2026-08-15 through 2026-08-17 — **The 8.0.0–9.0.0 train, folded and published.** Constitution
  boundaries, value-free verdicts, parser/redirection repairs, two-unit compression floors,
  index-aware CI triage and strict top-entry version lockstep are recorded by **DB-038**…
  **DB-040**, **DC-001**…**DC-008**; the Python-write rail stayed declined.
- 2026-07-25 through 2026-08-15 — **Everything through 7.0.2, folded:** founding through portable
  adapters/toolchains (**D-001**…**D-035**, **DA-001**…**DA-026**, **DB-001**…**DB-037**).
