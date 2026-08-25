# STATE — project state & session memory

> **Length guard.** Thresholds are in `amh.conf`; the rules for compressing this file are
> `docs/RUNBOOK.md` → **Working-memory compression**, and they bind whether or not you follow
> this pointer. Read them before any edit that takes this file over the soft cap.

## Project

The AMH meta-repository — source of truth for the Agentic Maintenance Harness and its
reference instance, which runs byte-identical copies of the scripts it ships. `AGENTS.md`
describes both and is read in full every session.
Adopted harness version: **AMH 9.2.0** — see `harness/VERSION`, the copy that counts.

## Current state

AMH **9.2.0** is prepared on this branch but not yet tagged or published. It moves this file's
two rule preambles into `docs/RUNBOOK.md` → **Working-memory compression** and **Session
discipline** 7, leaving pointers that `doc-navigation.sh` now checks. The rules are unchanged;
what changes is that 2,499 bytes of them no longer spend a 9,216-byte budget that exists to
evict volatile content. The seed scaffold gets the same shape, where the two preambles were
4,859 bytes of 6,045 before an adopter had written a line.

9.1.0 is tagged and published as `amh-v9.1.0`, and its `portability (macos-latest)` job passed
on the merge commit with the stock-Bash assertion green — which closed the parser watch.

Committed ledger rows are append-only, enforced against `HEAD` by a repo-local guard whose
sanctioned exceptions and draft-row rule are in **DB-008** and **DB-013**. The live volume is
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

**OPEN — tag and publish AMH 9.2.0 after this branch merges.** Check:
`git ls-remote --tags origin refs/tags/amh-v9.2.0` — resolved when it prints the tag.

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
