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
Adopted harness version: **AMH 2.0.0** — see `harness/VERSION`, which is the copy that counts.

## Current state

> **Session handoff (2026-07-27).** The founding train MERGED (PR #1, squashed to `a659da6`;
> `7d322d7` is PR #2, a revert, and it is what `amh-v1.8.0` points at).
> `claude/state-review-planning-ol544l` carries the whole instantiation plan, U0–U4, and is
> **green and pushed**; it contains `…-jandv0`, which contains `…-ushoux`. `branch-train` is
> the mode, so cut the next branch **from `…-ol544l`, not from main**. **No plan is active** —
> the instantiation plan is complete and its file is deleted (P16). The next session takes new
> work from the Owner queue, or from the owner.

**AMH 2.0.0 is written but not yet released**: the version bump is on the branch, the tag is
the owner's step after the merge, and `README.md`'s quickstart already pins `amh-v2.0.0`. Every
release from now on has that window — the pin and its lockstep arm are new in this plan.
**Nothing mechanical closes it**: `version-lockstep.sh` checks the pinned string against
`harness/VERSION`, never against the tags that exist, so merged-but-untagged is green in every
guard while the documented clone command 404s. The Owner-queue item below is the only thing
bounding it (**DA-010**).

Every unit of that plan that touched `RULE_FILES` was a legislation diff — U1 through U4; U0
moved only STATE, the ledger and the plan file and needed no pass. Legislation means ONE
blocking fresh-context reviewer, strongest tier, one pass, triage and ship, no self-review
fallback (D-015, bounded by **D-035**). Budget for it: **twenty-six of twenty-seven passes have
found a real defect inside the FIX**, including four in ledger rows about the very lesson they
were recording — U4's HIGH was a false enforcement claim sitting in the subsection that cites
D-010 for exactly that shape (**DA-010**), and U3's was an enforcement claim one line stronger
than the code (**DA-008**). This session's standing instruction forbade subagents; the runbook's
answer is to ASK rather than park, and the owner granted the spawn.

`shellcheck` is CI-only and its rung load-bearing, so editing a script without it is editing
blind (**D-026**); `AMH_REMOTE=1` is set, so `scripts/bootstrap.sh` installs it every remote
session (**D-028**). Run the ladder DIRECTLY, never piped — a pipe reports the pipe's status,
and a red tree has been pushed that way. **`git log` cannot answer a question about this repo's
past**: squash-merge destroys it, and the memory tiers ARE the history (**DA-003**).

**No open findings.** Both U2 ones are closed: the `docs/history/` seed ships, and
`amh.conf.example` lists `amh.conf` in its own `RULE_FILES`. Neither was visible to
`path-refs.sh`, which skips `harness/templates/*` by design — that blind spot is unchanged and
is why template findings have to be carried here by hand.

**The ledger has rolled over**: `docs/LEDGER.md` is closed at 826 lines (last row D-035);
`docs/LEDGER_A.md` is live from `DA-001`. Append there; a citation's prefix names its file.

## Owner queue

> **Protected section.** Never delete it, and never silently drop items during compression.
> Items leave only when done, answered or triaged — then delete the item and record the
> outcome as a Changelog line or a ledger row. Every session's final chat message restates
> this queue.

**Pending owner actions — two.**

1. **The release.** Merge `claude/state-review-planning-ol544l` (draft PR open), then **tag
   `amh-v2.0.0`**, in that order: the release workflow checks the tag against `harness/VERSION`,
   so the tag follows the merged bump rather than leading it. Until the tag exists the README's
   quickstart names a clone target that 404s, and no guard reports it (**DA-010**) — this queue
   entry is what closes the window. `amh-v1.8.0` remains tagged on `7d322d7`.
2. **`main`'s branch protection requires a check named `build`, which nothing here emits.**
   `ci.yml`'s job is `ladder` and is the only check that reports on a PR (`release.yml` fires on
   tag push only), so the required context stays "Expected" forever and blocks the merge above.
   Repoint the requirement at `ladder`. Agent-unfixable: branch protection is owner-only, and
   renaming the job to `build` would fix the symptom by making the ladder answer to a name that
   describes nothing.

**Open questions:** none. Answered 2026-07-27 (**DA-005**): this release is a **MAJOR, 2.0.0**,
because the archive correction deleted a clause adopters could have relied on; and `harness/src`
joined `RULE_FILES` and `CONTRIBUTING.md`'s scope list. Earlier the same day, D-005, D-014 and
D-018 were closed on the owner's delegation (**D-035**).

## Decided non-items (don't re-litigate without new evidence)

Each is settled and its reasoning is in the ledger row named — read the row, not this line,
before reopening. Rendering scripts from placeholder templates (**D-002**); doc-fact guards
(P20) and a markdown link checker, both overturned the same day, with `version-lockstep.sh` and
`path-refs.sh` the narrow forms admitted and the incident bar standing (**D-010**, **D-023**);
section-granular `RULE_FILES`, the tripwire being path-granular (`docs/RUNBOOK.md` carries this
one); self-reported checklists in commits or YAML, permanently — the ban is on machinery
consuming a self-report, not on a sentence a human may disbelieve, and the operative test is
**does anything downstream consume it?** (P3, **D-014**). A pre-execution warning on `git log`
under branch-train (**DA-003**): right incident, wrong layer — the rail is binary, the command is
correct nearly every time, and the shape is not enumerable; a session-start banner line is the
accepted form (U3b). Assurance levels as configuration, in every presented form including
`amh.conf` feature flags (**DA-001**), and a packaged CLI for distribution (**DA-001**).
Per-level rendered scripts — generating structurally different shipped scripts per assurance
level, which would re-create the rendered-vs-template drift class **D-002** deleted and break
the `cmp` guard that makes the dogfooding claim checkable (**DA-001**); the accepted shape is
that only *seed prose* is profile-selected, and that nothing a script reads records the choice.

## Changelog

One line per shipped change or completed unit (newest first). Details live in the cited ledger
rows and in git history — this section is a pointer index, not a narrative.

- 2026-07-27 — **U4: AMH 2.0.0 written, and the instantiation plan closed.** The MAJOR bump
  across five lockstep copies, the changelog entry whose Upgrading section is the complete
  1.8.0 → 2.0.0 list (the archive-intake correction is the only breaking item, and it is
  prose-only — nothing reads the archive), `harness/src/40-adaptation.md`'s profile table and
  the "nothing records the level" sentence, `docs/UPGRADING.md`'s statement of the ADR-1
  invariant (nothing `amh-init.sh` does may be needed again after it exits), and the README
  quickstart rewritten to two commands plus one sentence, pinning `amh-v2.0.0` — the rewrite
  **DA-006** deferred to here precisely so the pinned tag would contain what the text promises.
  The plan file is deleted (P16): its durable content is in these lines and in `DA-001`…`DA-010`.
- 2026-07-27 — **U3: the shipped-script integrity manifest, and U3b's squash-history line.**
  `MANIFEST.sha256` is generated from `harness/templates/scripts/*.sh` and installed beside
  them; a shipped rung hashes each one against it. Absence warns, an empty manifest fails, and
  a manifest not covering the ladder itself fails — the guard can refuse the self-serving
  omission and count the rest, which is a weaker claim than the first draft's prose made and is
  now what the prose says (**DA-008**). Admitted ahead of the incident bar by owner decision —
  with no adopters the incident is only discoverable at an adopter's expense. Two consequences
  worth carrying: the documented hand-upgrade had to become `cp .../scripts/*` (scripts without
  their manifest read as five edited files), and `copy-drift.sh`'s `*.sh` glob would have let
  this repo's copy drift from the shipped one. `session-start.sh` now says under
  `branch-train` that the default branch's log is not this repo's past (**DA-009**).
- 2026-07-27 — **U2: install profiles.** `amh-init.sh --profile light|standard|full`, default
  light, selecting seed prose only — nothing records the level, so nothing can branch on it
  (**DA-001**). The archive tier finally ships as a seed. Its pass (**DA-007**) returned six
  findings, one HIGH: the profile gate ran *before* the presence test, so the documented plain
  re-run told existing adopters their runbook and ledger were "not in the light profile" while
  both sat in their tree — and silently dropped them from the unfilled-placeholder report.
  Presence outranks configuration; a switch governs absence only. Also: an untested default
  survived being flipped, a fixture stopped one word short of the advice it checked, and a
  shipped script named a file the default profile declines.
- 2026-07-27 — **U1: the adoption brief.** `amh-init.sh` writes `AMH-ADOPT.md` into an adopter's
  tree on fresh installs only, addressed to their agent: ask the owner how much harness they
  want, fill the slots from the repo, write `verify.sh`, drive the ladder green, delete the
  brief. README's tag becomes a fifth lockstep copy. Its pass returned a REJECT worth the cost
  (**DA-006**): prose described a future release as shipped, an unreachable `keep` branch was
  "proved" by a tautological fixture, a fixture matched a label every failure emits, playbook 5
  could not satisfy the guard it now trips, and the installer claimed a guard adopters lack.
- 2026-07-27 — **The archive's stated intake was wrong and is corrected** (**DA-004**): folding
  is the compression method; the archive takes documents retired whole, never another tier's
  live file — a Goodhart hole the pass found in the first fix, where retiring this file
  wholesale satisfied every word. Consequences (**DA-005**): MAJOR 2.0.0, and `harness/src`
  joins the rule scope.
- 2026-07-27 — **The founding train merged**; ledger rolled to volume A. An external RFC
  proposing a sync-CLI "materializer" and assurance levels was evaluated as data (P18): the
  materializer is already built and already one-way, a packaged CLI was refused, and levels were
  refused *as configuration* — assurance is already emergent from artifact presence in the
  ladder, so a profile is an init-time choice of what to install (**DA-001**).
- 2026-07-27 — **Owner queue closed out**: `AUTHOR_EMAIL_ALLOW` confirmed and explained to
  outside contributors, `AMH_REMOTE=1` set (closing D-028), the PR template landed, and D-005,
  D-014 and D-018 closed — the last by bounding the one-pass rule (**D-035**).
- 2026-07-27 — **This file was spliced in half and shipped green** by a scripted edit anchored on
  a string its own preamble quotes; any repeated `## ` heading now fails (**D-034**). And **the
  git author identity guard** shipped, its passes finding the allowlist ordering plus six arms
  asserted by nothing (**D-032**, **D-033**).
- 2026-07-26 — **Colon-less URL userinfo redacted**, the class turned positive (**D-031**); the
  shipped scripts **stopped citing a ledger they do not ship with**, by retracting the previous
  fix rather than extending it (**D-030**). **The loudness rule** applied (D-019),
  `scripts/bootstrap.sh` written, and the STATE landing check taught to tell a typo from an
  unfinished compression pass (**D-027**). Founding build closed out (U1–U6) plus five repair
  units: the command guard's `<<<` regression, the ladder's off switch, zero-coverage guards
  given fixtures, first green CI, the adopter path walked end to end. **D-016**…**D-029**.
- 2026-07-25/26 — **Founding day and the server-side rails.** Self-hosting core, legislation,
  adopter templates, harness prose and bundle; rule review applied (14 findings, 13 fixed);
  env-dump rails closed in `command-guard.sh`, which shipped with a regression; branch
  protection and secret-scanning push protection (owner). **D-001**…**D-014**, **D-016**.
