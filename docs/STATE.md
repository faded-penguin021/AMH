# STATE — project state & session memory

> **Length guard.** Thresholds are in `amh.conf`; the rules for compressing this file are
> `docs/RUNBOOK.md` → **Working-memory compression**, and they bind whether or not you follow
> this pointer. Read them before any edit that takes this file over the soft cap.

## Project

The AMH meta-repository — source of truth for the harness and its reference instance, which runs
byte-identical copies of the scripts it ships; `AGENTS.md` describes both and is read in full
every session.
Adopted harness version: **AMH 10.5.0** — see `harness/VERSION`, the copy that counts.

## Current state

AMH **10.5.0** is prepared on this branch and untagged; it adds the structural forge/API
mutation rail (**DC-043**) atop the shipped-integrity CRLF diagnostic fix (**DC-042**). **10.4.1** is RELEASED: `b261502` is tagged `amh-v10.4.1` on
2026-09-01. The preceding 10.4.0 release commit has **no CI run** — its squash folded the
whole branch's bodies into its message, poison token included, so Actions skipped the push and
the newest run on `main` is still 10.3.0's; the next PR is the first chance to verify this
content (**DC-040**). **9.2.0 has a changelog entry and no tag**, and nothing checks that every
changelog version got one. The live ledger
volume is `docs/LEDGER_C.md`, at 801 lines and now at its rollover boundary; opening the next
ledger volume is the next unit with a deadline;
`docs/LEDGER_B.md` is closed at **DB-040**. Row immutability, the correction verbs and the
` [cited]` exception are in that volume's preamble; the append-only guard's exceptions and
draft-row rule are **DB-008** and **DB-013** (**DC-020** for its HEAD baseline). `main`'s
protection is repointed at `ladder`.

## Owner queue

> **Protected section.** Never delete it, and never silently drop items during compression.
> Items leave only when done, answered or triaged — then delete the item and record the outcome
> as a Changelog line or a ledger row. How to test an item before restating it, and why the
> final chat message must: `docs/RUNBOOK.md` → **Session discipline** 7.

**OPEN — tag and publish AMH 10.5.0 after merge.** Owner-only. When merging, **edit the squash
message**: GitHub's default concatenates every commit body on the branch, which is how 10.4.0's
release commit lost its CI run (**DC-040**). Check: `git tag -l amh-v10.5.0` — resolved when it
prints the tag.

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

- 2026-09-01 — **10.5.0: structural forge/API mutation classification closes the observable local escape.** Parsed `gh api` and direct-forge `curl` reads stay allowed; high-consequence mutation methods, implicit POST bodies/uploads and GraphQL mutation documents block with payload-free diagnostics, while the documented application/script/interface boundary remains covered only by least privilege and server approvals (**DC-043**).
- 2026-09-01 — **10.4.2: shipped-integrity failures distinguish CRLF conversion from ordinary
  edits.** A mismatch asks Git for the affected tracked file's authoritative worktree EOL; only
  `w/crlf` selects the targeted `.gitattributes`, re-normalize and re-checkout remediation, while
  every other mismatch retains the existing edited-file explanation (**DC-042**).
- 2026-09-01 — **The CRLF portability question is answered on both platforms.** Run 33494690202
  is green on both legs and prints what each does: an unseeded CRLF tree on Windows fails on the
  integrity rung and ONLY there — five `does not match the hash` lines, secret scan and rails
  green — while macOS bash refuses the script outright. The inference from the manifest's design
  is now an observation, which also made the rung's remediation text readable and wrong for this
  cause (**DC-041**, and a new queue item).
- 2026-09-01 — **The Windows bug report is closed on Windows.** A CRLF-configured adopter tree
  with the `.gitattributes` seed runs every rung green on `windows-latest` — secret scan and
  shipped-script integrity included — and even WITHOUT the seed the secret scan comes back clean
  there, which is the 529 false findings the report opened with, gone on the platform that filed
  it. The step could only say so once its own assertion stopped grepping for a CR that MSYS2
  grep reads past (**DC-041**).
- 2026-09-01 — **A CRLF worktree does not run at all on macOS or Linux, and the CI step that
  should have said so could not.** The first portability run since the merge proved the seed
  holds on a CRLF adopter tree and that an unseeded one dies before the first rung, because bash
  refuses a script whose every line ends in CR — Git Bash tolerating it is why the original
  report saw 533 findings instead of a dead shell. The Windows leg could not answer either way:
  its vacuity assertion grepped for a CR byte that MSYS2 grep reads past, the same tool-family
  assumption one layer up from the defect it guards (**DC-041**).
- 2026-09-01 — **10.4.1: 10.4.0 shipped, and the squash folded a poison token onto `main`.** PR #58
  merged as `f1f25be` and was tagged, resolving the release item and dissolving the rewrite
  BLOCKER by taking the route that needed no rewrite. The cost landed where the rung said it
  would: the default squash message concatenated 24 commit bodies, so Actions skipped the push
  and the tagged commit has no CI run — the message was editable at merge time, which is the
  cheap fix nobody reached for (**DC-040**).
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
