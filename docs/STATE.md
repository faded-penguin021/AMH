# STATE — project state & session memory

> **Length guard.** Thresholds are in `amh.conf`; the rules for compressing this file are
> `docs/RUNBOOK.md` → **Working-memory compression**, and they bind whether or not you follow
> this pointer. Read them before any edit that takes this file over the soft cap.

## Project

The AMH meta-repository — source of truth for the Agentic Maintenance Harness and its
reference instance, which runs byte-identical copies of the scripts it ships. `AGENTS.md`
describes both and is read in full every session.
Adopted harness version: **AMH 10.1.1** — see `harness/VERSION`, the copy that counts.

## Current state

AMH **10.1.1** is prepared on this branch and untagged: a PATCH making the bootstrap's advisory
reset clear the guard's `.resumed` sibling, which it had been leaving behind — so
`--advisory-report` stops going silent about a deletion abandoned this session and
`--spawn-report` stops counting the container (**DC-018**).

AMH **10.1.0** is prepared on this branch and untagged: a MINOR removing the command rail's
branch-namespace check, which had blocked a correctly assigned `claude/<codename>` branch —
the shape **DA-022** declined to guard, and which P13 states as standing instruction for the
`--pre-push` rail in the same script (**DC-017**). The rail now denies every spelling git
resolves to the default branch, force, deletion, an explicit `refs/tags/` push, the two
unresolvable destinations `HEAD` and `@`, and a second ref. Three misses are enumerated in the
guard header, **DB-035**'s `git push -u origin work` among them. The review pass earned its
keep: the first draft opened `heads/main` as a live path to the default branch while claiming
in prose that the default branch was denied. 10.0.1 rides inside this train: a PATCH carrying
the adopter-facing citation-collision note into `harness/templates/amh.conf.example`, with no
key, rule or behaviour moved (**DC-016**).

Ledger rows are immutable and are never edited in place. A correction is a new row plus one
appended pointer on the old one — `Superseded by D-NNN.` when the whole row is replaced,
`Corrected by D-NNN.` when one detail went stale under a principle that still stands. Both are
the same append; which verb is honest is a judgement the guard cannot check, and that half is
the reviewer's. The preamble promise to "correct the entry" is gone from all five preambles
(owner, 2026-08-25). DB-014 now carries `Corrected by DC-011.`

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

**OPEN — `amh-v10.1.1` is unpublished, and the version call inside 10.1.0 is unconfirmed.**
The rail change, both changelog entries, the ledger rows and all five lockstep copies are on
this branch; tagging and publishing are owner steps and were not attempted. Two things need the
owner, not a command. (a) The tag. Check: `git ls-remote --tags origin refs/tags/amh-v10.1.1` —
resolved when it prints a ref. (b) **MINOR is a call this session made unilaterally**, under
the standing mandate to decide rather than queue, on a change that removes a rail 7.0.0 shipped
as MAJOR. This is not an ordinary judgement call: `CONTRIBUTING.md` singles out an ambiguous
major-vs-minor call as the one place where "guessing is worse than waiting" and routes it here.
The argument for MINOR, and the honest objection to it, are both in the changelog's "Why MINOR
and not MAJOR"; the review pass agreed MINOR is the right number and still recorded the process
override as a finding. Overturn it before tagging if the reasoning does not hold — after the
tag it is a published promise. 10.0.1 and 10.1.0 never got their own tags and now ride inside
this train, the same way 9.2.0 rode inside 10.0.0.

**OPEN — the command rail blocks `env -u VAR cmd`, which dumps nothing.** `env` with an
assignment or a bare command is stripped as a transparent prefix, but the `-u` option is not
recognised, so `env -u AMH_REMOTE bash scripts/session-start.sh` is refused as an environment
dump. This repository's own shipped fixture suite uses that exact spelling — it only escapes
because the suite runs it in a subshell rather than through the hook. Same class as **DC-017**:
a rail rejecting a command it exists to permit. The fix is small (treat `-u NAME`/`-u` the way
an assignment is treated, then judge what follows) but it is a rail change owed its own unit and
review pass, and the direction to avoid is stripping `env` so eagerly that a bare `env` or
`env -i` stops being read as the dump it is. Check:
`scripts/command-guard.sh --command 'env -u FOO bash x.sh'; echo $?` — resolved when it prints
0, with `env` and `env -i` still printing 2. **Next unit, startable cold:** edit
`harness/templates/scripts/command-guard.sh` (never the `scripts/` copy) where `env` is stripped
as a transparent prefix, add a shipped fixture that fails against today's script, copy down,
`build-manifest.sh`, then RUNBOOK playbook 2 plus the rule-review pass. Verified still open
2026-08-26: all four spellings return exactly the values stated above.

**OPEN — `path-refs.sh` may report specific false failures when its file listing comes back
short.** One full ladder run this session failed it on `` `session-start.sh` `` — a file that
exists — and it did not reproduce on two clean runs. The guard builds `basenames` from
`git ls-files` and never checks that the listing succeeded or is non-empty, so section (c) can
name real citations as broken; its siblings refuse that zero-extraction case explicitly
(`config-schema.sh`, `version-lockstep.sh`). Unverified — no reproducer yet, which is why this
is a finding and not a fix.

Everything else currently asked has been answered in the rows the Changelog cites, and `main`'s
protection is repointed at `ladder`. Tags: 7.0.2, 8.0.0, 9.0.0, 9.1.0 and 10.0.0 are cut and
published; **9.2.0 has a changelog entry and no tag** — it shipped inside the 10.0.0 train, and
nothing checks that every changelog version got one.

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
  to classify it (**DB-027**); and a configurable ledger-id prefix to dodge domain-constant
  collisions, which relocates the collision into the adopter's taxonomy rather than removing it
  (**DC-015**).

## Changelog

One line per shipped change or completed unit (newest first). Details live in the cited ledger
rows — this section is a pointer index, not a narrative.

- 2026-08-26 — **10.1.1's review pass landed after a rate-limit interruption; four findings
  applied, no blocker.** Resumed rather than respawned: a pass that never reported is not a pass,
  so this was the unit's FIRST. Two overstated claims corrected in prose and one dead fixture
  line removed (**DC-018**). macOS Bash 3.2 stays unexecuted here.
- 2026-08-25 — **The bootstrap stops leaving the guard's `.resumed` ledger behind; PATCH
  10.1.1.** The advisory reset's pattern ended at the repository slug, so it cleared the state
  file and never its sibling — and `--advisory-report`, whose job is to make an abandoned
  deletion visible, printed NOTHING for one abandoned this session whenever the same command
  text had been resumed in an earlier one. `--spawn-report` counting the container was the
  visible half. Enumerated rather than widened to `<slug>*`, which reaches a neighbouring
  repository; two fixtures, both in hook mode, the only path that writes the file. That closed
  the Owner-queue item on the spawn count (**DC-018**).
- 2026-08-25 — **The push rail stops policing the branch name and polices the push; shipped as
  MINOR 10.1.0.** The namespace check blocked a correctly assigned `claude/<codename>` branch,
  which is what **DA-022** refused before 7.0.0 built it and what P13 tells the `--pre-push`
  rail in the same script to avoid — the two rails had disagreed for four majors with both
  self-tests green. What replaces it is the readable facts, and a differential over 844 push
  spellings is what proved the swap complete: the first draft had opened `heads/main`, which
  the review pass caught. Tag pushes gained a real rail, three misses are enumerated in the
  guard header, and **DB-035**/**DB-036** each carry `Corrected by DC-017.` A fixture that had
  never tested its own comment was found by the removal (**DC-017**).
- 2026-08-25 — **The adopter-facing citation-collision note is written, and ships as PATCH
  10.0.1.** `amh.conf.example` now names the class beside the two citation keys, gives a
  locating command that honours both, and prices all three escapes — including the two second
  steps **DC-015** found undocumented. The shape is named in words and never shown: an example
  id would be read as a citation by the very scan the note describes. The review pass caught
  the one claim the draft inherited from DC-015 instead of deriving it — a multi-capital
  constant IS an 8.0.0 regression, as **DB-007**(d) recorded (**DC-016**).
- 2026-08-25 — **A citation-guard collision was reported, reproduced, and found to have no clean
  escape.** `DB-9`-shaped domain constants fail the citation rung in an adopter tree; the class
  predates the 8.0.0 widening, and two of the three apparent hatches need an undocumented second
  step. `LEDGER_PREFIX` is refused, on relocation and the incident bar rather than immutability.
  The adopter-facing note stays unwritten — the review pass cut its first draft (**DC-015**).
- 2026-08-25 — **10.0.0 is merged and tagged; that queue item closed on its own check.**
  `git ls-remote --tags origin refs/tags/amh-v10.0.0` prints the tag at `793c744`, the squash
  commit this branch is cut from, so the release window the banner reports is shut.
- 2026-08-25 — **10.0.0 confirmed MAJOR by the owner.** The session's reading stands: the
  append-only guard is repo-local and unshipped, so deleting the in-place-correction clause
  makes a practice adopters could legitimately be following wrong. No version change followed;
  the item closed on the answer, not on a command.
- 2026-08-25 — **Ledger rows are immutable; a correction is a new row plus a pointer.** The
  preamble promise the guard never honoured is deleted from all five preambles, and a second
  pointer verb `Corrected by` joins `Superseded by` for the case where a principle stands and
  one detail died — DB-014's, which now carries one. Owner decision; MAJOR (**DC-014**).
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
