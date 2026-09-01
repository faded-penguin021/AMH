# STATE — project state & session memory

> **Length guard.** Thresholds are in `amh.conf`; the rules for compressing this file are
> `docs/RUNBOOK.md` → **Working-memory compression**, and they bind whether or not you follow
> this pointer. Read them before any edit that takes this file over the soft cap.

## Project

The AMH meta-repository — source of truth for the harness and its reference instance, which runs
byte-identical copies of the scripts it ships; `AGENTS.md` describes both and is read in full
every session.
Adopted harness version: **AMH 10.4.0** — see `harness/VERSION`, the copy that counts.

## Current state

AMH **10.4.0** is prepared on this branch and untagged, carrying 10.3.1 with it; the newest tag
is `amh-v10.3.0` and the PR-time check wants exactly one bump above it. **9.2.0 has a changelog
entry and no tag**, and nothing checks that every changelog version got one. The live ledger
volume is `docs/LEDGER_C.md`, at 730 of its 800-line cap, so a rollover is near;
`docs/LEDGER_B.md` is closed at **DB-040**. Row immutability, the correction verbs and the
` [cited]` exception are in that volume's preamble; the append-only guard's exceptions and
draft-row rule are **DB-008** and **DB-013** (**DC-020** for its HEAD baseline). `main`'s
protection is repointed at `ladder`.

## Owner queue

> **Protected section.** Never delete it, and never silently drop items during compression.
> Items leave only when done, answered or triaged — then delete the item and record the outcome
> as a Changelog line or a ledger row. How to test an item before restating it, and why the
> final chat message must: `docs/RUNBOOK.md` → **Session discipline** 7.

**OPEN — BLOCKER: the owner directed a history rewrite for `e364631`'s poison token, and no
session may execute one.** The token is in a pushed commit message, so the rung fails
permanently and Actions SKIPPED that push (PR #58, zero check runs). On 2026-09-01 the owner
chose the rewrite over the recommended squash-merge. A session cannot carry it out: `AGENTS.md`
→ Hard boundaries permits a rewrite of pushed history only in the owner-directed,
**owner-executed** credential-incident process after rotation, and this is not one; the
`--pre-push` rail independently blocks the non-fast-forward by OUTCOME on every branch, so
`--no-verify` would be the only route and that is defeating a rail, not using one. The rung's own
failure text says force-push is forbidden. So this needs the owner AT A LOCAL CLONE:
`git rebase -i e23f86a`, mark `e364631` `reword`, drop the token from that body, then
`git push --force-with-lease`. Verified 2026-09-01: `e364631` is the ONLY commit in the range
whose body holds the literal token — `9815164` describes the incident without quoting it — so
one reword clears the range, and `e364631` and `9815164` both get new shas. Squash-merge remains
available and needs no rewrite. Check: `git log --format=%B origin/main..HEAD | grep -c
'skip'` — resolved when the range no longer holds it.

**OPEN — tag and publish AMH 10.4.0 after merge.** Owner-only actions; the release commit is
prepared on the PR branch. Check: `git tag -l amh-v10.4.0` — resolved when it prints the tag.

**OPEN — the CRLF CI step ran once, half-passed, and its re-run is unverified.** First run
33468064665 (`e23f86a`): macOS green, Windows RED on the step's own vacuity assertion, because
delete-and-checkout does not re-smudge under Git Bash — which voids that run's seeded pass there
too. It did establish that DC-030's `--baseline` survives real CRLF bytes under MSYS2's sed.
Re-smudge, vacuity assertion and `git ls-files --eol` diagnostics are in (**DC-037**); the grep
half stays CONFIRMED on run 33432523501 (**DC-033**); `verify.sh` (rung 3) has still never run on
Windows or macOS. Check: read that job on the newest run — the CRLF half resolves once the step
is green on BOTH legs, run id recorded here; the grep half while its printed grep stays <= 3.4.

**OPEN — the `printf | grep -q` class survives at 39 further sites, and 10 are NOT fixture
harnesses.** Unit 3 fixed the two with reachable unbounded input; the residue is safe on BOUNDED,
mostly single-line input rather than on a loud direction, and at least three are the same
fail-OPEN shape — `ladder.sh:1358` is the one to watch (**DC-038**). Not queued as work; reopen
if any starts matching something unbounded. Check: `grep -rn "printf.*| *grep -q" --include=*.sh
scripts/ harness/templates/` prints 44 lines, 5 of them comments — resolved only if that stops
matching the description, which it deliberately does not.

**OPEN — the 2026-08-29 `path-refs.sh` false failure on `` `session-start.sh` `` still has no
reproducer.** Closed in `b2a9ae3` as the EPIPE defect, then restored when the pass falsified that
(**DC-035**, **DC-029** for the residue): a listing git completed, reported success for, and cut
short anyway. No check; only a recurrence settles it.

**OPEN — the destructive rail sees no Windows shell, and two reported incidents live there.** The
owner's (2026-08-29) `cmd /c "rd /s /q ..."` resolved to the root of `D:` through a
backslash-quote mismatch, pairing with the Antigravity `rmdir /s /q d:\` (**DC-027**). Which
layer mis-parsed is unsettled and matters to whoever builds the arm; a Windows arm is the owner's
call since the harness targets bash. No check until a session builds it.

**OPEN — investigate the forge/API mutation surface as an escape around the local rails.** The
pre-push rail guards git-CLI pushes only, so `gh api -X POST` or a `curl` mutation bypasses every
local rail — not merely adversarial, since PocketOS lost a production volume AND its backups to
one GraphQL mutation carrying a found token (**DC-009**, **DC-027**). No check — nobody but a
session actually crossing it settles this.

**OPEN — `amh.conf`'s `LEDGER_ROW_CHAR_CAP` comment calibrates against a figure the rows
falsify.** It calls ~1450 bytes the longest sentence-compliant row, leaving 2000 "about a quarter
of headroom"; measured, **DC-030** is 1962, **DC-027** 1866, **DC-011** 1858. Legislation in a
`RULE_FILES` file, so a reviewed unit rather than a typo fix. Check: `awk` the volumes for the
longest row under the sentence cap and compare with the comment.

## Decided non-items (don't re-litigate without new evidence)

A pointer index, not an argument: **read the cited row before reopening any of these**, because
the row is where the reasoning lives and these lines are deliberately too short to re-litigate
from.

- **Pre-3.0.0:** templated shipped scripts, assurance levels, a packaged CLI, broad
  doc-fact/link guards, section-granular `RULE_FILES`, machine-consumed self-attestations, a
  `git log` rail under branch-train, failing ledger caps, hook-invocation detection, a shipped
  config-schema guard, a `BRANCH_PREFIX` push check (**D-002**, **D-010**, **D-014**, **D-023**,
  **DA-001**, **DA-003**, **DA-022**).
- **RFCs:** capability/profile/probe machinery and a second setup extension (**DA-024**); run
  receipts, transport, CI artifact and status tool (**DA-025**); five provenance-defective
  scenarios and their YAML/oracle/report machinery (**DA-026**).
- **Later:** the top-decile warning (**DB-040**, **DC-003** the adopted alternative); a
  constitution byte cap (**DB-038**); a Python-write advisory (**DC-007**); the 2026-08-10 review
  proposals (**DB-024**); a guard that opens a file to classify it (**DB-027**); a configurable
  ledger-id prefix (**DC-015**); ledger immutability across commits (**DC-020**).

## Changelog

One line per shipped change or completed unit (newest first). Details live in the cited ledger
rows — this section is a pointer index, not a narrative.

- 2026-09-01 — **A ledger row may no longer cite a plan's path.** DC-033 cited one, and
  immutable-row plus archive-or-delete plus the path guard made that plan undeletable. The rule
  is now in the principles, both runbooks and the seed; `ledger-append-only.sh` enforces it on
  NEW rows in all three forms `path-refs.sh` resolves, committed rows exempt of necessity.
  `2026-08-31-ci-sees-windows.md` is retained in `docs/plans/` permanently — DC-033's citation
  cannot be withdrawn, so do not try to archive it again (**DC-039**).
- 2026-08-31 through 2026-09-01 — **The three-unit "CI sees Windows" plan, all units shipped.**
  The pass's five findings applied; the macOS leg confirmed green on the EPIPE fix; a portability
  step building a CRLF adopter tree and asserting BOTH directions, whose first Windows run failed
  on its own vacuity assertion and was repaired; and the `printf | grep -q` shape fixed where it
  fails OPEN, with shipped fixtures that assert their own input size. The plan file could not be
  deleted — a committed row cites its path (**DC-036**, **DC-037**, **DC-038**).
- 2026-07-25 through 2026-08-31 — **Everything before this session, folded.** Founding through
  portable rails, the constitution rewrite, the 8.0.0–9.0.0 train, git-native pre-push
  enforcement, the 9.2.0–10.2.0 trains tagged `amh-v10.0.0` and `amh-v10.2.0`, and the unreleased
  10.3.0–10.4.0 train: a data-plane tier grown by reported incidents, an escaped quote that had
  been voiding the rails behind it, a PR-time release-number check, an adoption-first README, and
  a Windows tail in four parts (**DC-020**–**DC-035**, and the volumes for everything older).
