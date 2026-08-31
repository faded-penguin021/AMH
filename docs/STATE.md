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
entry and no tag**, and nothing checks that every changelog version got one.

The live ledger volume is `docs/LEDGER_C.md`, opened at the 8.0.0 rollover; `docs/LEDGER_B.md`
is closed at **DB-040**. Row immutability, the correction verbs and the ` [cited]` exception are
in that volume's preamble; the append-only guard's exceptions and draft-row rule are **DB-008**
and **DB-013** (**DC-020** for its HEAD baseline).
`main`'s protection is repointed at `ladder`.

## Owner queue

> **Protected section.** Never delete it, and never silently drop items during compression.
> Items leave only when done, answered or triaged — then delete the item and record the outcome
> as a Changelog line or a ledger row. How to test an item before restating it, and why the
> final chat message must: `docs/RUNBOOK.md` → **Session discipline** 7.

**OPEN — tag and publish AMH 10.4.0 after merge.** The release commit is prepared on the PR
branch; tagging and publication are owner-only actions. Check: `git tag -l amh-v10.4.0` —
resolved when it prints `amh-v10.4.0`.

**OPEN — approved plan, in progress: `docs/plans/2026-08-31-ci-sees-windows.md`.** Three
sequential shippable units: (1) a binary file inside `CITATION_SCAN_PATHS` plus printed tool
versions, (2) a CI job running the shipped rungs on a genuinely CRLF adopter tree, (3) the
`printf | grep -q` fail-open in the command rail. The owner pre-approved the mandated
fresh-context pass for each — one blocking reviewer, strongest tier, one-pass bound unchanged —
and asked that the work be paced around the usage window. Checklist: [x] unit 1 [ ] unit 2
[ ] unit 3 [x] PR #58 body corrected [ ] plan archived or deleted.

**OPEN — the `path-refs.sh` pass is DONE and its findings are RECORDED, NOT FIXED — fix them
first (owner, 2026-08-31).** The fix in `b2a9ae3` is correct; what the pass falsified was the
story around it (**DC-035**). In priority order, each replayable: (a) the guard comment at
`path-refs.sh:185` gives the wrong REASON — a here-string works because its writer is not a
pipeline member and never reaches `PIPESTATUS`, not because bash backs it with a temp file,
which it does only above the pipe-buffer size, so a reader on bash >= 5.1 would wrongly think
the fix void; (b) fixture (viii) in `local-guards.sh` pads with `*.md`, which drags 800 files
through the markdown loop for nothing — `*.txt` still fails against the piped form and takes
0.13s against 10.9s, currently 23% of the repo-local suite; (c) that fixture is a bare `expect
pass` with no message substring, so it goes vacuous silently if the padding ever stops clearing
the pipe buffer — `expect` takes a fifth argument on a pass verdict; (d) the `Check:` one-liner
below and in `b2a9ae3` prints 141, a SIGPIPE death, not the 1 it claims, except where SIGPIPE is
ignored as on the CI runner; (e) the commit body's "(DC-034 cites DC-033)" is false — DC-034
cites no other row. Check: `sed -n '185p' scripts/guards/path-refs.sh` — resolved when the
comment no longer says "temporary file rather than a pipe".

**OPEN — the 2026-08-29 `path-refs.sh` false failure on `` `session-start.sh` `` still has no
reproducer.** It was closed in `b2a9ae3` as the EPIPE defect **DC-034** fixes; the pass
falsified that (**DC-035**) and the item is restored rather than left retired on a coincidence
of symptoms. The mechanism cannot have produced it: the basename list is 1127 bytes over 71
entries, the old pipeline gives 0/200 false failures against the real listing, and
`session-start.sh` is entry 64 of 71, so nothing is pending when grep matches. What DC-029 named
is still uncovered — a listing git completed, reported success for, and cut short anyway. No
check; only a recurrence settles it.

**OPEN — `scripts/command-guard.sh` carries the same `printf | grep -q` shape, and there it
fails OPEN.** `extract_command`'s no-python3 fallback reads a SUCCESSFUL match as a failure
whenever the writer still had bytes pending, so `|| return 0` stands the rail down on a Bash
command it should have inspected. **And it is not the only site:** the pass found
`scripts/ladder.sh:899` and its shipped twin doing the same in the poison-token rung, where a
token early in a long enough set of commit messages is silently not reported — this branch's own
messages already stand at 44065 bytes of the ~65536 needed (**DC-035**). Approved by the owner
(2026-08-31) as **Unit 3** of the plan above on the same terms, pre-approved pass included; the
defect, acceptance and playbook-2 obligations are written there, and the rung now belongs in
that unit's scope. Check: `bash -c 'set -uo pipefail; { printf "a\n"; sleep 0.1;
printf "b\n"; } | grep -qxF a'; echo $?` prints 1 for a match that succeeded.

**OPEN — the grep half is CONFIRMED on Windows CI; the CRLF half and rung 3 are not.** Run
33432523501 prints `grep (GNU grep) 3.0` on `portability (windows-latest)`, inside the <= 3.4
range where the binary-file notice goes to STDOUT, and the citation rung passed there over the
committed `scripts/fixtures/binary-citation.bin` — a real regression check for `-I`, not just the
input being present (**DC-033**). Two gaps remain: a CRLF worktree needs the `.gitattributes`
seed and CI's Windows job sets `core.autocrlf false` before checkout, so it has never seen one
(unit 2); and `verify.sh` (rung 3), home of the shipped fixture suite, has never run on Windows
or macOS at all, both legs being `--guards-only`. Check: read that job on the newest run —
resolved for the grep half while its printed grep stays <= 3.4 and the rung passes, a runner
image moving grep to >= 3.5 retiring that silently.

**OPEN — the destructive rail sees no Windows shell, and two reported incidents live there.**
The owner's (2026-08-29) `cmd /c "rd /s /q ..."` lost its target to a backslash-quote mismatch
and resolved to the root of `D:`; it pairs with the Antigravity `rmdir /s /q d:\` the **DC-027**
search found. Which layer mis-parsed — outer shell, `cmd.exe`, C-runtime argv split — is
unsettled and matters to whoever builds the arm. Neither is reachable here, the verbs being
Windows and `cmd /c` hiding its command as `bash -c` does, and a Windows arm is the owner's call
since the harness targets bash. No check until a session builds it.

**OPEN — investigate the forge/API mutation surface as an escape around the local rails.** The
pre-push rail (DC-009) guards git-CLI pushes only, so an owner-reserved side effect through
`gh pr merge`, `gh api -X POST` or a `curl`/`wget` mutation bypasses every local rail — not
merely adversarial, since the **DC-027** search turned up PocketOS, where an agent used a token
from an unrelated file to delete a production volume AND its backups in one GraphQL mutation.
No check — nobody but a session actually crossing it settles this.

**OPEN — `amh.conf`'s `LEDGER_ROW_CHAR_CAP` comment calibrates against a figure the rows
falsify.** It calls ~1450 bytes the longest sentence-compliant row, leaving 2000 "about a quarter
of headroom"; measured, **DC-030** is 1962, **DC-027** 1866 and **DC-011** 1858, so that headroom
does not exist. Pre-existing, found by a review pass looking at something else; code is ground
truth so the prose is wrong, but it is legislation in a `RULE_FILES` file, so repairing it is a
reviewed unit rather than a typo fix. Check: `awk` the volumes for the longest row under the
sentence cap and compare with the comment.

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
  (**DC-007**); the two 2026-08-10 review proposals (**DB-024**); any guard that opens a file
  to classify it (**DB-027**); a configurable ledger-id prefix, which relocates a domain-constant
  collision into the adopter's taxonomy rather than removing it (**DC-015**); and making ledger
  immutability hold across commits, which needs a history rail no incident has earned
  (**DC-020**).

## Changelog

One line per shipped change or completed unit (newest first). Details live in the cited ledger
rows — this section is a pointer index, not a narrative.

- 2026-08-31 — **The parked `path-refs.sh` unit was reviewed on the owner's authorisation, and
  the pass kept the fix but broke its story.** The EPIPE mechanism explains the macOS CI failure
  and cannot explain the older `session-start.sh` sighting, so that queue item is restored; the
  same shape turned up in `ladder.sh`'s poison-token rung, failing open. Findings recorded
  unfixed by the owner's instruction (**DC-035**).
- 2026-08-25 through 2026-08-31 — **The unreleased 10.3.0–10.4.0 train, folded.** A data-plane
  tier grown by reported incidents; an escaped quote that had been voiding the rails behind it;
  a PR-time release-number check; an adoption-first README; and a Windows tail in four parts —
  CRLF falsifying two rungs, grep's binary-file notice falsifying a third, the committed binary
  fixture that finally puts that input in front of every matrix leg, and a `grep -q` whose early
  exit turned a match into a failure under `pipefail` (**DC-020**–**DC-034**).
- 2026-07-25 through 2026-08-26 — **Everything published, folded:** founding through portable
  rails, the constitution rewrite, the 8.0.0–9.0.0 train, git-native pre-push enforcement, and
  the 9.2.0–10.2.0 trains tagged `amh-v10.0.0` and `amh-v10.2.0` (immutable rows with correction
  by pointer, working memory that stopped paying for its own rules, a citation-guard collision
  with no clean fix, a matrix that stopped running twice, a POSIX-correct `env`, a push rail that
  polices the push). The ledger volumes carry the detail; this line carries the dates.
