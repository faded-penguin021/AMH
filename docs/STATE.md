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
> landing, and that `## Project` / `## Current state` /
> `## Changelog` exist and are non-empty; it only *warns* if `## Owner queue` vanishes. Nothing
> judges whether what survived is any good. Never drop an open owner-queue item.

## Project

The AMH meta-repository: both the **source of truth** for the Agentic Maintenance Harness — a
reusable operating prompt plus scaffolds for repos maintained by agentic AI sessions — and its
**reference instance**, maintained under the harness and running byte-identical copies of the
scripts it ships. The distributed product lives in `harness/` (prose source, templates, generated
bundle); this repo's own instance is `AGENTS.md` + `docs/` + `scripts/` + `amh.conf`.
Adopted harness version: **AMH 1.8.0** — see `harness/VERSION`, which is the copy that counts.

## Current state

> **Session handoff (2026-07-27).** Work is on `claude/owner-queue-git-author-guard-bzpdxd`, tip
> of the branch train (main ← tb2myi ← der6bl ← guh973 ← guzkor ← 8yq4br ← b7fell ← 60rz4g ←
> ddmycw ← here); `branch-train` by owner decision. **Every carried finding is closed and the
> train is ready for the owner's squash merge**, body drafted in `docs/SQUASH_PR_BODY.md`.
> **This file is over the soft cap and owes ONE deep compression pass to ≤ 9 KB** — it went over
> writing D-033 up, and stopping at 14335 to silence the warning is the move the band exists to
> prevent. The warning is the debounce working; the pass is the next session's first act.

**Every unit has had its blocker inside the FIX, not in the original defect** — eighteen of the
last nineteen passes, this one included. Budget for it. Each unit takes ONE fresh-context
reviewer, blocking, ONE pass (D-015): triage, apply, ship, no re-review. Spawning it is required,
not a thing to ask about; do not relabel a corrected diff as a new unit for a fresh pass (D-018).

`shellcheck` is CI-only and its rung load-bearing, so editing a script without installing it
first is editing blind (**D-026**); `scripts/bootstrap.sh` installs it on every remote session.
Run the ladder DIRECTLY, never piped — a pipe reports the pipe's status, and a red tree has been
pushed that way.

**Open findings.** None — the identity guard is built and shipped (**D-033**).

**The review protocol has D-019's own defect**: a pass that dies and one that finds nothing both
end as "no findings". Do not answer it with a completion sentinel — that is a self-report and P3
bans consuming those. **Ask a pass for falsifiable claims — "mutation M, suite stayed green" —
and replay them before believing any.** Two were replayed here and proved nothing: see **D-033**.

## Owner queue` vanishes. Nothing
> judges whether what survived is any good. Never drop an open owner-queue item.

## Project

The AMH meta-repository: both the **source of truth** for the Agentic Maintenance Harness — a
reusable operating prompt plus scaffolds for repos maintained by agentic AI sessions — and its
**reference instance**, maintained under the harness and running byte-identical copies of the
scripts it ships. The distributed product lives in `harness/` (prose source, templates, generated
bundle); this repo's own instance is `AGENTS.md` + `docs/` + `scripts/` + `amh.conf`.
Adopted harness version: **AMH 1.8.0** — see `harness/VERSION`, which is the copy that counts.

## Current state

> **Session handoff (2026-07-27).** Work is on `claude/owner-queue-git-author-guard-bzpdxd`, tip
> of the branch train (main ← tb2myi ← der6bl ← guh973 ← guzkor ← 8yq4br ← b7fell ← 60rz4g ←
> ddmycw ← here); `branch-train` by owner decision. **Every carried finding is closed and the
> train is ready for the owner's squash merge**, body drafted in `docs/SQUASH_PR_BODY.md`.
> **This file is over the soft cap and owes ONE deep compression pass to ≤ 9 KB** — it went over
> writing D-033 up, and stopping at 14335 to silence the warning is the move the band exists to
> prevent. The warning is the debounce working; the pass is the next session's first act.

**Every unit has had its blocker inside the FIX, not in the original defect** — eighteen of the
last nineteen passes, this one included. Budget for it. Each unit takes ONE fresh-context
reviewer, blocking, ONE pass (D-015): triage, apply, ship, no re-review. Spawning it is required,
not a thing to ask about; do not relabel a corrected diff as a new unit for a fresh pass (D-018).

`shellcheck` is CI-only and its rung load-bearing, so editing a script without installing it
first is editing blind (**D-026**); `scripts/bootstrap.sh` installs it on every remote session.
Run the ladder DIRECTLY, never piped — a pipe reports the pipe's status, and a red tree has been
pushed that way.

**Open findings.** One, owner-requested, with a settled direction. Build it; do not re-litigate.

- **A machine check on git author identity (owner-requested 2026-07-27, NOT yet built).**
  `AGENTS.md:153-159` makes the owner's personal identifiers a secret that leaks through git
  author metadata, and calls itself "prose-only, deliberately: no guard can see an identity you
  have not committed yet". That justifies no PRE-COMMIT guard and nothing more — the rule's own
  next clause ("an unpushed commit is amendable, a pushed one is not") names the window the
  ladder runs in, and this repo forbids the force-push that would fix a pushed one.
  Direction: a new shipped rung `guard_author_identity` over `%ae` and `%ce` across
  `origin/$DEFAULT_BRANCH..HEAD`. **Zero-config half** — FAIL on identities git invented for
  itself (`root@*`, `*@localhost`, `*@*.local`, `*@*.localdomain`, `*(none)*`, empty, anything
  with no `@`): never a real address, so no false-positive surface. **Opt-in half** —
  `AUTHOR_EMAIL_ALLOW`, an extended regex, defaulted to empty IN THE SCRIPT so no adopter is
  ever asked to add a key to make their ladder green (D-027's pattern, and D-030's whole
  lesson). Do NOT use the repo's own history as an allowlist: a first-time contributor is
  indistinguishable from a misconfigured one, and this branch would warn on all 30 of its own
  commits. Say plainly in the guard's comment that it cannot tell a personal address from a work
  one — implying more than it does is D-010's class. Fixtures: committer-field-only (a rebase
  writes it while the author survives), not-an-address, allowlist match/miss, and the key ABSENT
  with an address the allowlist would reject, or hardcoding a permissive default stays green.
  Amend the `AGENTS.md` claim to say pre-commit rather than never. It trips D-010's incident bar
  (nothing has rotted; all 33 commits carry the right alias) — overridden by the owner because
  the harm is a permanent, unfixable-by-policy leak.

## Owner queue

> **Protected section.** Never delete it, and never silently drop items during compression.
> Items leave only when done, answered or triaged — then delete the item and record the
> outcome as a Changelog line or a ledger row. Every session's final chat message restates
> this queue.

**Pending owner actions:**

1. Tag `amh-v1.8.0` once the founding branch is merged. The release workflow now exists, so the
   tag verifies the tree, checks itself against `harness/VERSION`, and publishes the bundle.
2. **Merge the train as ONE squash PR** whose body describes the net `origin/main..HEAD` diff,
   not the last branch's. No PR template exists — `.github/` holds only `workflows/`. The body
   is drafted and waiting in `docs/SQUASH_PR_BODY.md`: copy it into the PR description and
   delete the file, since a merged PR is its own record.

3. **Set `AMH_REMOTE=1` in the remote environment, or `scripts/bootstrap.sh` never runs.**
   Verified by presence check: the flag is unset, so `session-start.sh` skips the bootstrap —
   correctly, since that gate is what stops it surprising someone on a laptop. So the script
   built to install `shellcheck` automatically (**D-028**, closing **D-026**'s cost) fires for
   nobody and every session still installs it by hand. One environment variable fixes it. Noted
   rather than worked around: a bootstrap that silently never runs is this repo's own recurring
   defect class, and it would have gone unnoticed for the same reason as all the others.
4. **The identity guard is built (D-033) — confirm `AUTHOR_EMAIL_ALLOW` in `amh.conf`.** It
   admits `noreply@anthropic.com` and `*@users.noreply.github.com`: every commit on this train,
   plus one made through the GitHub web UI. Commit from a differently configured machine and the
   ladder reddens until that line is widened; deleting the key leaves the zero-config half
   running. An address the key admits is accepted whatever shape it has, so a permissive pattern
   switches that half off.
5. **`harness/src/30-scaffolds.md`'s citation bullet is stale** — out of this unit's scope, so
   left alone. It still says the shipped `amh.conf` excludes the shipped scripts "whose `D-NNN`
   comments cite the harness's ledger"; D-030 retracted that, the tokens are gone, and the
   exclusion now covers only the fixture suite.

**Open questions:**

1. [2026-07-25] **D-005** — founding legislation installed with no fresh-context reviewer. Both
   authorised passes have now run: prose (applied) and scripts/templates (**D-017**). Close on
   your read at merge.
2. [2026-07-25] The P3 reword (**D-014**) landed **self-reviewed**, at your direction. Your read
   at merge is its only outside look.
3. [2026-07-25] **The one-pass rule is Goodhart-open** (D-018): "split the unit" lets a session
   relabel a corrected diff as a new unit and claim a fresh pass, and no definition of a unit is
   mechanical. Your call whether to bound it or accept it as prose-only.

## Decided non-items (don't re-litigate without new evidence)

Each is settled and its reasoning is in the ledger row named — read the row, not this line, before
reopening. Rendering scripts from placeholder templates (**D-002**); doc-fact guards (P20) and a
markdown link checker, both overturned the same day, with `version-lockstep.sh` and `path-refs.sh`
the narrow forms admitted and the incident bar standing — no guard for a claim that has not yet
rotted (**D-010**, **D-023**); section-granular `RULE_FILES`, the tripwire being file-granular
(`docs/RUNBOOK.md` carries this one — no ledger row does); self-reported checklists in commits or
YAML, permanently, the ban being on machinery consuming a self-report rather than on a sentence a
human may disbelieve (P3, **D-014**).

## Changelog

One line per shipped change or completed unit (newest first). Details live in the cited ledger
rows and in git history — this section is a pointer index, not a narrative.

- 2026-07-27 — **The git author identity guard** (D-032 built): a shipped rung over `%ae` and
  `%ce`; git's invented identities fail with no config; `AUTHOR_EMAIL_ALLOW` opt-in, defaulted
  empty in the script. Its passes found the allowlist ordering — a named address could not
  override an invented-shape rejection, leaving "edit a shipped script" as the only remedy —
  plus four globs and two arms asserted by nothing. **D-033**.
- 2026-07-26 — **Colon-less URL userinfo is redacted** (D-022's first half; the second stays
  ACCEPTED). Its pass found the false positive that mattered — an unpadded markdown table row —
  and the userinfo class is now POSITIVE rather than negated, which ends that family. **D-031**.
- 2026-07-26 — **The shipped scripts stopped citing a ledger they do not ship with** (D-023).
  Closed by RETRACTING the previous fix: the `CITATION_EXCLUDE` route would have turned every
  existing adopter's ladder red until they hand-edited a config they own forever. D-004 and
  D-007 lose their `[cited]` markers as the accepted cost; D-019 keeps its. **D-030**.
- 2026-07-26 — **B7 + B8, the loudness rule applied** (D-019): `session-start.sh` validates
  `REMOTE_FLAG` and gates the bootstrap on presence rather than its exec bit; `guard_repo_local`
  always prints its header and the count it ran. Its pass found **D-027(a) repeated verbatim** in
  the new assertion helper. **D-029**.
- 2026-07-26 — **`scripts/bootstrap.sh`**: the toolchain bootstrap `session-start.sh` had always
  called and nothing provided. Installs shellcheck, persists PATH, warms the `origin/<default>`
  fetch, loud and non-fatal throughout. Its review pass found the blocker in the FIXTURE again —
  a shellcheck-free PATH built by subtraction deletes `/usr/bin` on CI. **D-028**.
- 2026-07-26 — **The STATE landing check tells an edit from a compression pass** (D-016 item 11).
  It read every byte lost above the soft cap as a pass in progress, so a 15-byte deletion had to
  compress the whole file or be reverted; twice, the compliant move was to *pad the file back*.
  Now branches on the shrink's size and whether it crosses the cap, and names the branch.
  **D-027**, superseding D-011's closing sentence.
- 2026-07-26 — **Founding build closed out** (U1–U6): release workflow, `README.md`, end-to-end
  instantiation test, `INIT_PLACEHOLDERS` bound to its document, build plan deleted. **D-025**.
- 2026-07-26 — **Five repair units**: the command guard's `<<<` regression that voided every rail
  and five more mistake classes; the ladder's off switch closed and three zero-coverage guards
  given fixtures; first-ever green CI at run 14; `redact.sh` widened to the shapes in circulation
  with an exact-match self-test; the adopter path walked end-to-end, which is what found the
  citation defect. **D-016**, **D-017**, **D-019**…**D-024**.
- 2026-07-25/26 — **Founding day and the server-side rails.** U1–U4 (self-hosting core,
  legislation, adopter templates, harness prose + bundle); rule review applied (14 findings, 13
  fixed); env-dump rails closed in `command-guard.sh`, **which shipped with a regression**; then
  branch protection on `main` plus secret-scanning push protection (owner), closing P13's
  server-side half. **D-001**…**D-014**, **D-016**.
