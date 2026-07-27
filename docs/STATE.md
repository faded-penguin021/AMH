# STATE — project state & session memory

> **Length guard (hysteresis).** Grow freely to **14 KB**; over it, ONE deep pass to **≤ 9 KB**
> — never to just under the cap, or the warning re-arms next session; the band IS the debounce.
> Fail above **16 KB**. That floor is a **ceiling, not a target**: aim comfortably below it.
> Trimming word by word until the guard goes quiet is the same micro-trim reflex the band exists
> to break, one band lower, and it leaves no headroom for the next session's growth. Above the
> cap the ladder tells an ordinary edit from a compression pass by how far the file shrank
> (`STATE_EDIT_DELTA_BYTES`), so fixing a typo up here is allowed and still owes the compression
> (**D-027**). Compress by folding completed stages into Changelog lines and moving durable
> gotchas to the ledger, not by cutting text into a new file. The ladder checks the caps, the
> landing, that the required sections exist and are non-empty, and that NO `## ` heading in this
> file appears twice (**D-034**); it only *warns* if the owner-queue heading vanishes. Nothing judges whether what survived is any good. Never
> drop an open owner-queue item.

## Project

The AMH meta-repository: both the **source of truth** for the Agentic Maintenance Harness — a
reusable operating prompt plus scaffolds for repos maintained by agentic AI sessions — and its
**reference instance**, maintained under the harness and running byte-identical copies of the
scripts it ships. The distributed product lives in `harness/` (prose source, templates, generated
bundle); this repo's own instance is `AGENTS.md` + `docs/` + `scripts/` + `amh.conf`.
Adopted harness version: **AMH 1.8.0** — see `harness/VERSION`, which is the copy that counts.

## Current state

> **Session handoff (2026-07-27).** **The founding train has MERGED** (PR #1, squashed to
> `7d322d7`); every branch of it is superseded. Work is now on
> `claude/harness-instantiation-materializer-7xhxbr`, cut fresh from `origin/main` — a new
> train starts here. `branch-train` remains the mode by owner decision.

**Active plan: `docs/plans/harness-instantiation.md`** (owner-approved 2026-07-27) — making
the harness cheap to instantiate, plus the architectural verdicts on an external instantiation
RFC (**DA-001**). Units, sequential, each shippable: **U0 plan + ledger rollover ✅** · U1 the
adoption brief (AMH-ADOPT.md, not yet built) and the README quickstart · U2 `--profile light|standard|full`,
defaulting to light · U3 the shipped-script integrity manifest and its rung · U4 prose, the
1.9.0 bump, and deleting the plan. U1–U3 are legislation diffs: each takes ONE blocking
fresh-context reviewer, strongest tier, no self-review fallback.

**Every unit has had its blocker inside the FIX, not the original defect** — nineteen of twenty
passes now. Budget for it. Each unit takes ONE fresh-context reviewer, blocking, ONE pass:
triage, apply, ship, no re-review (D-015, bounded against relabelling by **D-035**).

`shellcheck` is CI-only and its rung load-bearing, so editing a script without it is editing
blind (**D-026**); `AMH_REMOTE=1` is now set, so `scripts/bootstrap.sh` installs it every remote
session (**D-028**). Run the ladder DIRECTLY, never piped — a pipe reports the pipe's status,
and a red tree has been pushed that way.

**Open findings.** None. **The ledger has rolled over**: `docs/LEDGER.md` is closed at 826
lines (last row D-035) and `docs/LEDGER_A.md` is the live volume, numbering from `DA-001`.
Append there; rows in the closed volume are never moved or renumbered, and a citation's prefix
names its file.

**Two lessons about verification itself, both paid for and both in the ledger.** A pass that
dies and one that finds nothing both end as "no findings", and a completion sentinel cannot fix
that — it is a self-report. **Ask a pass for falsifiable claims and replay them before believing
any** (**D-033**, **D-035**). And a scripted edit spliced this file in half and shipped green,
because the structure guard asked whether sections EXIST rather than how many (**D-034**).

## Owner queue

> **Protected section.** Never delete it, and never silently drop items during compression.
> Items leave only when done, answered or triaged — then delete the item and record the
> outcome as a Changelog line or a ledger row. Every session's final chat message restates
> this queue.

**Pending owner actions:**

None right now. **AMH 1.8.0 is released** — `amh-v1.8.0` is tagged on the merged founding
commit `7d322d7`, so the README's quickstart has a real tag to pin. The next owner action
arrives at the end of the current plan: tag **amh-v1.9.0** after the merge, in that order
(**DA-002**).

**Open questions:** none. D-005, D-014 and D-018 were closed 2026-07-27 on the owner's
delegation — see the Changelog and **D-035**. D-014's outside look was commissioned as the
second target of that unit's review pass, and its verdict is recorded in D-035 after the fact.

## Decided non-items (don't re-litigate without new evidence)

Each is settled and its reasoning is in the ledger row named — read the row, not this line, before
reopening. Rendering scripts from placeholder templates (**D-002**); doc-fact guards (P20) and a
markdown link checker, both overturned the same day, with `version-lockstep.sh` and `path-refs.sh`
the narrow forms admitted and the incident bar standing — no guard for a claim that has not yet
rotted (**D-010**, **D-023**); section-granular `RULE_FILES`, the tripwire being file-granular
(`docs/RUNBOOK.md` carries this one — no ledger row does); self-reported checklists in commits or
YAML, permanently, the ban being on machinery consuming a self-report rather than on a sentence a
human may disbelieve (P3, **D-014**) — the operative test is **does anything downstream consume
it?**, and it is the test rather than the artifact that decides.

## Changelog

One line per shipped change or completed unit (newest first). Details live in the cited ledger
rows and in git history — this section is a pointer index, not a narrative.

- 2026-07-27 — **The founding train merged**, and the ledger rolled to `docs/LEDGER_A.md` at
  `DA-001`. An external RFC proposing a sync-CLI "materializer" and configurable assurance
  levels was evaluated as data (P18): the materializer is **already built and already one-way**
  (`amh-init.sh`), a packaged CLI was refused as a dependency and an opacity, and assurance
  levels were refused **as configuration** in both presented forms — including the independent
  review's `amh.conf` feature flags, since a guard-gating key in the very file `RULE_FILES`
  protects makes "turn the red rung off" a supported one-line move. The synthesis instead:
  assurance is already **emergent from artifact presence** in the ladder, so a profile is an
  init-time choice of what to install and nothing machine-readable records it (**DA-001**).
  Plan: `docs/plans/harness-instantiation.md`.
- 2026-07-27 — **Owner queue closed out.** Owner **confirmed `AUTHOR_EMAIL_ALLOW`** and asked it
  be explained to outside contributors: `CONTRIBUTING.md` now gives the three-step order the
  guard applies and what to do when it rejects a real address. **`AMH_REMOTE=1` is set** (owner;
  verified at this session's boot), closing D-028's last gap. `30-scaffolds.md`'s citation bullet
  drops the mechanism D-030 retracted; `.github/pull_request_template.md` exists, prose prompts
  not checkboxes. **D-005 closed** (both passes ran); **D-014 closed** — the P3 reword's outside
  look also found P3's consumer list omitted a session's own control flow; **D-018 closed by
  bounding the rule** (**D-035**), parking included, since the bound's only exit had no
  executable form.
  **D-005 closed** — both authorised passes ran and the founding legislation has since been
  reviewed piecemeal by every pass that touched it. **D-014 closed** — the P3 reword got its
  outside look at last. **D-018 closed by bounding the rule** (**D-035**): a unit is what one
  reviewer saw, a corrected diff is never a new unit, and a pass that dies is not a pass.
- 2026-07-27 — **This file was spliced in half and shipped green**: a scripted edit anchored on
  a string the preamble also quotes. The structure guard checked existence, not cardinality, and
  CI agreed; the first fix then covered only the configured sections, which the review pass
  showed was the wrong scope. Any repeated `## ` heading now fails. **D-034**.
- 2026-07-27 — **The git author identity guard** (D-032 built): a shipped rung over `%ae` and
  `%ce`; git's invented identities fail with no config; `AUTHOR_EMAIL_ALLOW` opt-in, defaulted
  empty in the script. Its passes found the allowlist ordering — a named address could not
  override an invented-shape rejection, leaving "edit a shipped script" as the only remedy —
  plus four globs and two arms asserted by nothing. **D-033**.
- 2026-07-26 — **Colon-less URL userinfo is redacted** (D-022's first half), the class turned
  POSITIVE rather than negated, which ends that family (**D-031**); and **the shipped scripts
  stopped citing a ledger they do not ship with** (D-023) by RETRACTING the previous fix, which
  would have reddened every adopter's ladder until they hand-edited a config they own forever
  (**D-030**).
- 2026-07-26 — **The loudness rule applied** (D-019) and **`scripts/bootstrap.sh`**, the
  toolchain bootstrap nothing had provided; both passes found the blocker inside the fix.
  **The STATE landing check** learned to tell an ordinary edit from a compression pass that
  stopped short, after twice making *padding the file back* the compliant move (**D-027**,
  superseding D-011's closing sentence). **Founding build closed out** (U1–U6) and **five repair
  units**: the command guard's `<<<` regression that voided every rail, the ladder's off switch,
  zero-coverage guards given fixtures, first green CI, the adopter path walked end to end.
  **D-016**…**D-025**, **D-027**…**D-029**.
- 2026-07-25/26 — **Founding day and the server-side rails.** U1–U4 (self-hosting core,
  legislation, adopter templates, harness prose + bundle); rule review applied (14 findings, 13
  fixed); env-dump rails closed in `command-guard.sh`, **which shipped with a regression**; then
  branch protection and secret-scanning push protection (owner). **D-001**…**D-014**, **D-016**.
