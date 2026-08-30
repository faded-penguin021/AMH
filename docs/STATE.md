# STATE — project state & session memory

> **Length guard.** Thresholds are in `amh.conf`; the rules for compressing this file are
> `docs/RUNBOOK.md` → **Working-memory compression**, and they bind whether or not you follow
> this pointer. Read them before any edit that takes this file over the soft cap.

## Project

The AMH meta-repository — source of truth for the Agentic Maintenance Harness and its
reference instance, which runs byte-identical copies of the scripts it ships. `AGENTS.md`
describes both and is read in full every session.
Adopted harness version: **AMH 10.4.0** — see `harness/VERSION`, the copy that counts.

## Current state

AMH **10.4.0** is prepared on this branch and untagged. The destructive rail now has a
**data-plane tier**: `supabase db reset` and its siblings in five other tools get the one-time
advisory `rm -rf` gets, reached through a package runner as well as bare, with an advisory that
asks for the RESOLVED database to be printed because the target is never in the command, and with
no operand value ever recorded into a signature that gets persisted and printed (**DC-024**). Its
verb list then grew by what reported incidents earn: `npm run db:push` — the most-reported command
in this category and, until now, in the tier's own knowingly-absent list — plus `drizzle-kit push`
and `prisma migrate --shadow-database-url`, with `npm` joining the runner strip and the advisory
disclosing that a script NAME is all it read (**DC-027**). All six character walkers now agree
that a `\"` inside double quotes is not the closing quote; none of them did, which let a real
`git push --force` through behind an escaped quote (**DC-028**). The tier
cannot tell production from local; a cleared advisory means deliberate, not safe, and the guard
header says so. 10.3.1 before it made the README lead with the failures
AMH relieves, translate the mechanisms into familiar agent-workflow terms, and put adoption
before architectural detail. The ` [cited]` marker change prepared in 10.3.0 remains the current
harness behavior: it is now named as the
one in-place edit the ledger's immutability rule does not cover — in the shipped seed preamble
and in this repository's own five rule-bearing places — so the seed and
`harness/templates/amh.conf.example` stop handing adopters opposite instructions about the same
edit (**DC-020**, **DC-021**), and CI validates the release number against the latest tag
(**DC-023**). Drafted as PATCH 10.2.1 and raised to MINOR by the owner (**DC-022**). Everything
from 10.0.1 through 10.2.0 shipped inside the published `amh-v10.2.0` tag; **9.2.0 has a
changelog entry and no tag**, and nothing checks that every changelog version got one.

Ledger rows are immutable and are never edited in place, except the ` [cited]` marker, which is
metadata and is synced in place in both directions. A correction is a new row plus one appended
pointer — `Superseded by D-NNN.` when the row is replaced, `Corrected by D-NNN.` when one detail
went stale under a principle that stands; which verb is honest is the reviewer's half. The
append-only guard's sanctioned exceptions and draft-row rule are **DB-008** and **DB-013**, and
its HEAD baseline means it polices uncommitted work only (**DC-020**). The live volume is
`docs/LEDGER_C.md`, opened at the 8.0.0 rollover; `docs/LEDGER_B.md` is closed at **DB-040**.
`main`'s protection is repointed at `ladder`.

## Owner queue

> **Protected section.** Never delete it, and never silently drop items during compression.
> Items leave only when done, answered or triaged — then delete the item and record the outcome
> as a Changelog line or a ledger row. How to test an item before restating it, and why the
> final chat message must: `docs/RUNBOOK.md` → **Session discipline** 7.

**OPEN — tag and publish AMH 10.4.0 after merge.** The release commit is prepared on the PR
branch; tagging and publication are owner-only actions. Check: `git tag -l amh-v10.4.0` —
resolved when it prints `amh-v10.4.0`.

**OPEN — the destructive rail sees no Windows shell, and two reported incidents live there.**
The owner supplied one (2026-08-29): another agent ran `cmd /c "rd /s /q \"D:\Coding\Mobile
App\surprise\""` twice, and a backslash-quote mismatch between the shell that built the line and
the one that parsed it left `\` as the deletion target, which resolved to the root of `D:` and
wiped unrelated folders. Which layer mis-parsed — the outer shell, `cmd.exe`, or the C-runtime argv
split — is not settled here and matters to whoever builds the arm. It pairs with the Antigravity incident the **DC-027** search turned up,
`rmdir /s /q d:\` truncated at the drive root by an unquoted space. Neither is reachable here:
the verbs are Windows and `cmd /c "..."` hides its command exactly as `bash -c` does. Deliberately
NOT folded into the units that found them — this is a verb-list expansion with its own provenance
and its own scope question, since the harness targets bash and a Windows arm is the owner's call.
No check until a session decides to build it.

**OPEN — investigate the forge/API mutation surface as an escape around the local rails.** The
pre-push rail (DC-009) guards git-CLI pushes only, so an owner-reserved side effect through a
forge or API surface — `gh pr merge`, `gh release create`, `gh api -X POST`, `curl`/`wget`
mutations — bypasses every local rail. Not machinery yet: an adversarial test vector per P3/P10,
earning a narrow rail only if a real session crosses that boundary. It is no longer only
adversarial: the search behind **DC-027** turned up PocketOS, where an agent found a token in an
unrelated file and deleted a production volume AND its backups with one `curl` GraphQL mutation —
a reported incident on this exact surface, in someone else's harness. No check — nobody but a
session actually crossing it settles this.

**OPEN — `path-refs.sh` may still report a false failure if a listing comes back short.** One
full ladder run failed it on `` `session-start.sh` `` — a file that exists — and it did not
reproduce on two clean runs. The guard now refuses a listing that failed or came back empty
instead of reporting either as a verdict, which covers a `git ls-files` that died part way and
left partial output — the shape that fits this symptom, since a total failure would have printed
a green count instead (**DC-029**). Not covered and not seeable from here: a listing git
completed, reported success for, and cut short anyway. No check; only a recurrence settles which
it was.

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

- 2026-08-30 — **A guard that could not list the tree stopped reporting that as a verdict.**
  `path-refs.sh` checked neither of its `git ls-files` listings, so a failed one printed a green
  count over a scan of nothing while an empty basename set called real citations broken. Status,
  emptiness and a post-exclusion count are now checked separately on both listings and each of
  the six behaviours has a fixture its own mutation reddens — the last covering an `if [ -e ]`
  the suite could not see. The queue finding is narrowed, not closed (**DC-029**).
- 2026-08-27 — **The four `Shipped as` rows keep their wording and get no pointer** (owner,
  2026-08-27, agreeing with the session's refusal). A row's one pointer slot is FINAL, the four
  carry live principles that may still need it, and this change did not falsify them — they were
  never true. **DC-026** holds the argument and the cost it accepts.
- 2026-08-29 — **An escaped quote stopped voiding the rails behind it.** The false positive filed
  on 2026-08-27 was the fail-CLOSED half of a defect whose other half let `git push --force`,
  `rm -rf`, `cat .env` and `printenv` through whenever a `\"` appeared earlier on the line: all six
  character walkers read it as the closing quote. Each now applies bash's rule and each has a
  fixture that fails without it; that the filed report was this defect is inferred (**DC-028**).
- 2026-08-27 — **The data-plane tier's list grew by what reported incidents earn.** The owner
  answered its provenance question: `npm run db:push` (the Replit incident's own command, whose
  script NAME is in the command text the tier said it could not read) and `drizzle-kit push` under
  it are advised, `npm` joins the runner strip, and the advisory discloses that it matched a name
  and not a script. Six tools a search found no report for stay out, and the incident no verb list
  can hold — a `curl` GraphQL mutation that deleted a production volume and its backups — went to
  the forge/API queue item instead (**DC-027**).
- 2026-08-27 — **A ledger row records the version it DRAFTED, never one it claims shipped.** The
  owner closed the prose half of **DC-023**: rows saying "Shipped as" name numbers the remote's tag
  list does not carry, so new rows assert no release, old ones are read as drafts, and the rule sits
  in the live volume's preamble and release playbook 5 (**DC-026**).
- 2026-08-27 — **10.4.0: the destructive rail learned the data plane.** Six database-destroying
  verb shapes across five tools now take the same one-time advisory as `rm -rf`, through a package
  runner as well as bare; the advisory asks for the resolved target because the command names
  none, records no operand value into a signature that is persisted and printed, and the guard
  header states the limit it cannot pass — this tier cannot tell production from local
  (**DC-024**). The rule-review pass found the credential-omission fixture covering one of three
  redaction arms and four more assertions that could not fail; all six findings are applied, and
  the N-arms-means-N-mutations lesson is **DC-025**.
- 2026-08-27 — **10.3.1: the README now leads with the failure AMH relieves and the shortest path to
  adoption.** Its opening translates the core mechanisms into familiar agent-workflow terms,
  keeps the rails' limits explicit, and moves Quick Start ahead of architecture and fit details.
- 2026-08-27 — **The release number is validated at PR time against the latest tag.** Sessions
  still write one as they work; CI's `pull_request` event fails unless `harness/VERSION` is
  exactly one bump above the newest `amh-v` tag, over six fixtures whose three accept arms exist
  because the review pass mutated the accept clause to MINOR-only and the first suite stayed
  green (**DC-023**).
- 2026-08-27 — **10.3.0: the seed ledger preamble stops contradicting `amh.conf.example`.** The
  seed forbade in-place row edits while the shipped config told adopters to drop a stale
  `[cited]` marker; the marker is now named as the one edit that rule does not cover, in the seed
  and in this repo's own five rule-bearing places (**DC-021**), at a number the owner raised from
  the drafted PATCH (**DC-022**).
- 2026-08-27 — **The append-only guard's HEAD baseline makes committing a bypass.** The citation
  rung orders a stale `[cited]` marker dropped and the guard refuses the removal, but only while
  it is uncommitted, so ledger immutability is a working-tree property and CI checks it not at
  all — recorded, not repaired (**DC-020**).
- 2026-08-26 — **The 10.1.0–10.2.0 train, published as `amh-v10.2.0`.** CI stopped running the
  whole matrix twice per commit; the command rail learned to read `env` as POSIX defines it,
  closing a false positive and the `env FOO=1` hole together; the push rail stopped policing
  branch names and started policing the push; the bootstrap stopped leaving the guard's
  `.resumed` ledger behind; and the adopter-facing citation-collision note shipped
  (**DC-016**–**DC-019**, **DB-030**).
- 2026-08-25 — **The 9.2.0–10.0.0 train, published as `amh-v10.0.0`.** Working memory stopped
  paying for its own rules; ledger rows became immutable with correction by pointer; a
  citation-guard collision was reproduced and found to have no clean fix, and the owner
  confirmed the MAJOR (**DB-022**–**DB-029**, **DC-011**, **DC-015**).
- 2026-07-25 through 2026-08-20 — **Everything through 9.1.0, folded:** founding through portable
  rails, the constitution rewrite, the 8.0.0–9.0.0 train, and git-native pre-push enforcement.
  The ledger volumes carry the detail; this line carries the dates.
