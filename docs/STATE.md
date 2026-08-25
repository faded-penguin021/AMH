# STATE — project state & session memory

> **Length guard.** Thresholds are in `amh.conf`; the rules for compressing this file are
> `docs/RUNBOOK.md` → **Working-memory compression**, and they bind whether or not you follow
> this pointer. Read them before any edit that takes this file over the soft cap.

## Project

The AMH meta-repository — source of truth for the Agentic Maintenance Harness and its
reference instance, which runs byte-identical copies of the scripts it ships. `AGENTS.md`
describes both and is read in full every session.
Adopted harness version: **AMH 10.0.0** — see `harness/VERSION`, the copy that counts.

## Current state

AMH **10.0.0** is prepared on this branch but not yet tagged or published. The train carries
two changelog entries: 9.2.0, the working-memory relocation (**DC-013**), and 10.0.0, the
ledger correction rules below.

Ledger rows are immutable and are never edited in place. A correction is a new row plus one
appended pointer on the old one — `Superseded by D-NNN.` when the whole row is replaced,
`Corrected by D-NNN.` when one detail went stale under a principle that still stands. Both are
the same append; which verb is honest is a judgement the guard cannot check, and that half is
the reviewer's. The preamble promise to "correct the entry" is gone from all five preambles
(owner, 2026-08-25). DB-014 now carries `Corrected by DC-011.`

9.1.0 is tagged and published as `amh-v9.1.0`, and its `portability (macos-latest)` job passed
on the merge commit with the stock-Bash assertion green — which closed the parser watch.

The append-only guard's sanctioned exceptions and draft-row rule are in **DB-008** and
**DB-013**. The live volume is
`docs/LEDGER_C.md`, opened at the 8.0.0 rollover; `docs/LEDGER_B.md` is closed at **DB-040**.

## Owner queue

> **Protected section.** Never delete it, and never silently drop items during compression.
> Items leave only when done, answered or triaged — then delete the item and record the outcome
> as a Changelog line or a ledger row. How to test an item before restating it, and why the
> final chat message must: `docs/RUNBOOK.md` → **Session discipline** 7.

**OPEN — investigate the forge/API mutation surface as an escape around the local rails.** The
pre-push rail (DC-009) guards git-CLI pushes only; an owner-reserved shared-side effect through a
forge/API surface — `gh pr merge`, `gh release create`, `gh api -X POST`, `curl`/`wget`
mutations — bypasses every local rail. Not machinery yet: an adversarial test vector per P3/P10,
earning a narrow rail only if a real session crosses that boundary. No check — nobody but a
session actually crossing it settles this.

**OPEN — tag and publish AMH 10.0.0 after this branch merges.** Check:
`git ls-remote --tags origin refs/tags/amh-v10.0.0` — resolved when it prints the tag.

**DECIDE — confirm 10.0.0 is MAJOR before the tag is cut.** This train deletes the ledger
preamble's in-place-correction clause. The append-only guard is repo-local and NOT shipped, so
an adopter has no mechanism forbidding the practice their seed preamble told them to use —
which makes it CONTRIBUTING.md's MAJOR test ("deleting one clause that adopters relied on"),
and that is how it is written. Read as "nothing an adopter successfully does today breaks" it
is MINOR instead. One read; overrule it and the five lockstep copies move together (the README tag is one
of them). No check — version semantics are a judgement, not an observable.

Everything else currently asked has been answered in the rows the Changelog cites; tags through
9.1.0 are cut and published, and `main`'s protection is repointed at `ladder`.

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

- 2026-08-25 — **Ledger rows are immutable; a correction is a new row plus a pointer.** The
  preamble promise the guard never honoured is deleted from all five preambles, and a second
  pointer verb `Corrected by` joins `Superseded by` for the case where a principle stands and
  one detail died — DB-014's, which now carries one. Owner decision; MAJOR, queued for
  confirmation (**DC-014**).
- 2026-08-25 — **Prepared AMH 9.2.0: working memory stops paying for its own rules.** This
  file's length-guard and Owner-queue preambles moved to the runbook behind guard-checked
  pointers, the Project section shrank to the lockstep sentence, and the seed scaffold got the
  same shape (**DC-013**, on the **DB-029** grant).
- 2026-08-25 — **Two Owner-queue items closed on their own checks.** `amh-v9.1.0` is cut and
  published at `172c868`, and the macOS parser watch closed: `portability (macos-latest)`
  succeeded on that merge commit with "Assert stock macOS Bash" green rather than skipped, so
  the DC-011/DC-012 parser has now run on bash 3.2.
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
