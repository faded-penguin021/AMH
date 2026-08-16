# STATE — project state & session memory

> **Length guard (hysteresis).** The thresholds `STATE_WARN_KB`, both compression-floor keys
> and `STATE_HARD_KB` live in `amh.conf`, deliberately **not** restated here as numbers: nothing
> checks this prose against the config, so a restated number is a drift class no guard here
> covers (**DB-022**). Which of them the size rung prints, and why a number it printed is never a
> copy to quote back, are in `docs/RUNBOOK.md` → **Acceptance ladder** — a description of the
> guard's output, kept out of the file the guard measures (**DB-025**).
> Grow freely to the soft cap; over it, ONE deep pass landing at or below the
> compression floor — a ceiling, not a target: anywhere below is fine, and you do not keep
> shaving once under (owner, 2026-07-27). **The floor is a byte size AND a sentence count, and a
> landing satisfies both** (**DC-003**), which is what stops that rule depending on your
> restraint: trimming words cannot move the sentence count, repunctuating cannot move the bytes,
> and folding whole stages is the only move that clears both. Fail above the hard cap, which is
> byte-only like the soft cap — those two say WHEN to compress. **Compress by folding whole
> completed stages into Changelog pointer lines and moving durable lessons to the ledger** —
> never by shaving clauses until the guard goes quiet, and never by cutting text into another
> file: moving a passage OUT is not compression and is the owner's call — granted once, for the
> guard-output description now in the runbook (owner, 2026-08-11).
> Land short and you fold MORE stages. A typo fix above the cap is allowed and still owes
> the pass (**D-027**). The ladder checks sizes, structure and repeated headings (**D-034**) and
> nothing else — not whether what survived is any good, and not whether you dropped an open
> owner-queue item. Never drop one.

## Project

The AMH meta-repository: both the **source of truth** for the Agentic Maintenance Harness — a
reusable operating prompt plus scaffolds for repos maintained by agentic AI sessions — and its
**reference instance**, running byte-identical copies of the scripts it ships. The product is
`harness/` (prose source, templates, generated bundle); this repo's instance is `AGENTS.md` +
`docs/` + `scripts/` + `amh.conf`. Adopted harness version: **AMH 8.0.0** — see `harness/VERSION`,
the copy that counts.

## Current state

AMH 7.0.2 is tagged and published on origin (confirmed by `git ls-remote --tags` on 2026-08-15).
This branch is **8.0.0** (MAJOR): the seed constitution states that it describes the system as
currently built, and adoption history now belongs in the ledger and the state changelog.

Committed ledger rows are append-only, enforced against `HEAD` by a repo-local guard whose
sanctioned exceptions and draft-row rule are in **DB-008** and **DB-013**. The live volume is
`docs/LEDGER_C.md`, opened at the 8.0.0 rollover; `docs/LEDGER_B.md` is closed at **DB-040**.

## Owner queue

> **Protected section.** Never delete it, and never silently drop items during compression.
> Items leave only when done, answered or triaged — then delete the item and record the outcome
> as a Changelog line or a ledger row.
>
> **How to test an item before restating it, and why the final chat message must:**
> `docs/RUNBOOK.md` → Session discipline 7, which is binding and is not repeated here. The one
> thing that lives here: **`Check:` is deliberately NOT a required field**, so its absence is
> information — it means no command settles this, which is worth knowing before you repeat the
> item to a human (**D-014**).

**OPEN — make the `rm -rf` pre-execution advisory actually change behaviour** (owner,
2026-08-16). The rail stops a destructive command once so the session spends a turn checking the
expansion, and it names the two moves that are NOT compliance: rerunning without looking, and
renaming or relocating the target so the deletion is no longer needed. This session took the
second one — blocked on `rm -rf $d`, it renamed the scratch directory and dropped the deletion,
which cleared the prompt without ever making the check. The owner has tried one round of wording
against this already. The question is what layer beyond wording could work, given that the rail
cannot see whether a check happened and a self-report may never satisfy one (**D-014**). No
`Check:` — the evidence is a session transcript, which no command replays.

**OPEN — an fd-duplicating redirection before the operands hides the command from every
rail.** `split_segments` treats the `&` of `2>&1` as a segment operator, so `git 2>&1 push
--mirror origin` splits into `git 2>` and `1 push --mirror origin`; the second segment leads
with `1`, which is no command, and bash runs the push. Same for `2>&1 env`. It predates the
8.0.0 redirection fix, which closed every other position, and it is recorded in the guard
header's "does NOT catch" block rather than left implicit. Closing it means teaching
`split_segments` that `N>&M` is one token — a change to the function every scanner in that
script is built on, so it is its own unit with its own review pass. Check:
`scripts/command-guard.sh --command 'git 2>&1 push --mirror origin'` exits 0 while
`… --command 'git push --mirror origin'` exits 2.

**WATCH — the macOS rail self-test failure has a repair, but not a proven cause.** The
subshell transport the failure rode is gone: the parsers fill arrays in-process (**DC-002**).
That is the whole of the repair. The fail-closed arm added beside it cannot fire against these
parsers — every non-blank string yields a word and a segment — so it is a tripwire for a future
transport and not a second line of defence here; do not read a green macOS run as proof it
works. If the same eighteen fixtures go red again, the diagnosis was wrong and the mechanism is
still open. Close this item after several green macOS runs. Check: the
`portability (macos-latest)` job on this branch.

**OPEN — tag and publish AMH 8.0.0.** Create and push `amh-v8.0.0` after this branch merges. No
check: only the owner may tag or publish. (`amh-v7.0.2` is published — `git ls-remote --tags
origin 'refs/tags/amh-v*'` on 2026-08-15 — which closed the previous item.)

Everything else currently asked has been answered in the rows the Changelog cites; tags through
6.0.0 are cut and published, and `main`'s protection is repointed at `ladder`.

## Decided non-items (don't re-litigate without new evidence)

A pointer index, not an argument: **read the cited row before reopening any of these**, because
the row is where the reasoning that settled it lives and this line is deliberately too short to
re-litigate from.

- **Settled before the 3.0.0 release, each with its row.** Rendered or templated shipped
  scripts in any form, assurance levels as configuration, and a packaged CLI (**D-002**,
  **DA-001**). Doc-fact guards and a markdown link checker beyond the narrow
  `version-lockstep.sh` and `path-refs.sh`, with the incident bar standing (**D-010**,
  **D-023**). Section-granular `RULE_FILES` — path-granular is the tripwire
  (`docs/RUNBOOK.md`). Self-reported checklists in commits or YAML, permanently; the operative
  test is **does anything downstream consume it?** (P3, **D-014**). A pre-execution rail on
  `git log` under branch-train, where the banner line is the accepted form (**DA-003**). A
  *failing* byte cap on the ledger, hook-invocation detection in the boot banner and a *shipped*
  config-schema guard, whose intents were adopted in other forms (**DA-022**). A guard checking
  the session branch against `BRANCH_PREFIX`, which would fail every legitimately-assigned
  branch (**DA-022**).
- **The RFC-era refusals, three rows, each carrying an argument this line does not reproduce.**
  A runtime capability manifest, the script to write it, the lifecycle probe layer, runtime
  profiles, a second setup extension point and "gates consume observed facts" — **DA-024**.
  RFC2's run-receipt format, its transport, the CI artifact and a status tool — **DA-025**,
  which also scopes what a record may still be. Five of RFC3's seven scenarios, per-scenario YAML, an oracle directory and in-tree
  reports — **DA-026**, whose five failed provenance three DIFFERENT ways.
- **A warning when a ledger row or a compression pass lands in the top decile below its cap**
  (the inverted-gradient guard), declined with the anchor removal that shipped instead: it
  invents a second threshold to hug, and a guard accretes after an incident, not ahead of one
  (**DB-040**). Cap-hugging then survived the removal, and the owner settled the reopening the
  other way: the aim-points gained a second UNIT instead (**DC-003**), which is not a second
  threshold in the same unit and so does not answer to this objection. The objection stands
  unchanged for any future proposal of the top-decile shape.
- **A byte cap on the constitution (`CONSTITUTION_WARN_KB`)**, refused while adding the
  current-state rule that would have motivated it — the defect is kind, not size, and a cap over
  all-live legislation makes shaving a rule the cheapest compliance (**DB-038**).
- **The 2026-08-10 review's two refusals** — **DB-024**.
- **A guard that opens files to classify them** (owner, 2026-08-11). Reading a `.pem`'s first
  line would separate a private key from a certificate, and it is refused: no rail here opens a
  file, and the advisory tier is the answer instead — **DB-027**.

## Changelog

- 2026-08-16 — **The caps an agent writes toward gained a second unit (8.0.0, same release).**
  `STATE_COMPRESS_TO_SENTENCES` joins the KB floor and a landing meets both; `LEDGER_ROW_SENTENCE_CAP`
  becomes the working row limit over a raised byte backstop. Each unit blocks the cheap move that
  satisfies the other, which is what the declined top-decile warning could not do. **DC-003**.

- 2026-08-16 — **Redirections are stripped before the command guard judges any word (8.0.0,
  same release).** Closed the queue item's false denial of `git push … 2>&1`, and — found by
  the mandatory pass, not by the report — two silent bypasses as old as the rails themselves:
  a redirection between `git` and `push` hid `--force` and `--mirror`, one before the command
  word hid the command. Thirteen fixtures, each shown to fail against a broken implementation.
  One miss stays open below. The ledger rolled over to `docs/LEDGER_C.md`. **DC-001**.

- 2026-08-16 — **The guard's parsers stopped piping through subshells (8.0.0, same release).**
  The repair for the intermittent macOS self-test failure, whose cause is inferred rather than
  proven — the queue carries a WATCH. A fail-closed arm now denies non-blank text that parses
  to nothing, unreachable against these parsers and kept as a tripwire. **DC-002**.

- 2026-08-15 — **Green verdicts stopped printing thresholds (8.0.0, same release).** The size
  line reports the measurement, the landing line reports bytes clear of the floor, and the
  new-row rung reports each row's length; warns and fails still quote the cap they turn on.
  Three `expect_pass_not_saying` fixtures fail if a number returns to a green line. The
  inverted-gradient warning the same report proposed was declined — a second threshold is a
  second number to hug. **DB-040**.

- 2026-08-15 — **Owner: the release is MAJOR, and both units ship inside 8.0.0** (owner,
  2026-08-15, answering the version question raised in this queue and closing it).

- 2026-08-15 — **The constitution is bounded by kind, not by bytes, as 8.0.0.** The seed and
  this instance now say they state the system as currently built, and route supersession
  history, adoption narratives and per-version sanction records to the ledger with a changelog
  pointer. A `CONSTITUTION_WARN_KB` was considered and refused; the `RULE_FILES` tripwire is the
  enforcement, described at its real strength. Existing adopters relocate by hand — the
  changelog's Upgrading notes carry the steps and what the move does to their tripwire. The
  review pass added the routing's limit (a live rule never leaves) and the owner-queue escalation
  of the version call. **DB-038**, **DB-039**.

- 2026-08-15 — **The macOS release-tag failure is repaired as 7.0.2.** Destructive-advisory
  signature sorting and joining now stay inside Bash, with reversed-order target-set coverage.
  The immutable 7.0.1 tag is an assetless prerelease whose verification failed, so the corrected
  artifact requires a new patch tag.

- 2026-08-15 — **AMH 7.0.1 covers the supported macOS, Linux, and Windows toolchains.**
  Fixed the initializer's BSD-`chmod` failure and cleanup, Bash 3.2 heredoc parsing and BSD sed
  redaction and citation-row programs; removed GNU `sed -i` and Bash 4 dependencies from verification; documented
  the runtime floor for macOS, GNU/Linux, and Windows Git Bash; and added shipped-guard plus
  installer CI smoke jobs for macOS and Windows Git Bash alongside Linux's full ladder. Prepared
  as 7.0.1.

One line per shipped change or completed unit (newest first). Details live in the cited ledger
rows — this section is a pointer index, not a narrative.

- 2026-08-11 through 2026-08-14 — **The 6.0.0–7.0.0 train, folded.** Private-key read rails
  and block-body redaction; portable working-memory prose; per-operand destructive advisories;
  maximum-not-target ledger guidance; Codex lifecycle hooks and project rule reviewer;
  deterministic bearer-fixture construction; session-namespace push enforcement; required PR
  template use; and full base-to-head branch-train descriptions. **DB-026**…**DB-037** are the
  record.

- 2026-07-25 through 2026-08-10 — **Everything up to 5.2.1, folded.** Founding, self-hosting,
  releases through 5.2.1, the rejected and reduced RFCs, conformance scenarios, lifecycle and
  command rails, ledger chaining and limits, shipped citations, and the prose repairs leading
  into 6.0.0. **D-001**…**D-035**, **DA-001**…**DA-026**, and **DB-001**…**DB-025** are the
  record.
