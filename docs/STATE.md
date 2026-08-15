# STATE — project state & session memory

> **Length guard (hysteresis).** The thresholds `STATE_WARN_KB`, `STATE_COMPRESS_TO_KB` and
> `STATE_HARD_KB` live in `amh.conf`, deliberately **not** restated here as numbers: nothing
> checks this prose against the config, so a restated number is a drift class no guard here
> covers (**DB-022**). Which of them the size rung prints, and why a number it printed is never a
> copy to quote back, are in `docs/RUNBOOK.md` → **Acceptance ladder** — a description of the
> guard's output, kept out of the file the guard measures (**DB-025**).
> Grow freely to the soft cap; over it, ONE deep pass landing at or below the
> compression floor — a ceiling, not a target: anywhere below is fine, and you do not keep
> shaving once under (owner, 2026-07-27). Fail above the hard cap. **Compress by folding whole
> completed stages into Changelog pointer lines and moving durable lessons to the ledger** —
> never by shaving clauses until the guard goes quiet, and never by cutting text into another
> file: moving a passage OUT is not compression and is the owner's call — granted once, for the
> guard-output description now in the runbook (owner, 2026-08-11).
> Land short and you fold MORE stages: micro-trimming toward the floor is the same reflex the
> band exists to break, one threshold lower. A typo fix above the cap is allowed and still owes
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
sanctioned exceptions and draft-row rule are in **DB-008** and **DB-013**.

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

**OPEN — the push rail blocks a legal push that carries a redirection.** `git push -u origin
session/x 2>&1` and `… >/dev/null` are both denied, with a reason that says the push "names
another branch or leaves the ref implicit" — false of both. Redirection tokens survive into the
segment the ref counter reads, so they count as extra refs; `&&` is handled correctly. This is
the shape that teaches a session to route around a rail (**DB-030**). Check:
`scripts/command-guard.sh --command 'git push -u origin session/x 2>&1'` exits 2 while the same
command without `2>&1` exits 0. Not fixed here — it is a shipped-rail change with its own
fixture and review pass.

**OPEN — the macOS rail self-test is nondeterministic.** Run 31913987929 failed on
`portability (macos-latest)` with 18 `should have been BLOCKED` cases — every private-key case
and the dotenv write-destination/redirect/reader forms — then passed on re-run at the same
commit, with `command-guard.sh` byte-identical to the green `main` run 74 minutes earlier. So it
is neither a regression from this branch nor a static portability bug. The failing set is one
contiguous block of advisory-bearing cases, which points at advisory state or signature
construction rather than parsing — the area 7.0.2 already repaired once for Bash 3.2 collisions.
A rail that intermittently does not block is worse than one that never did, so this needs a real
diagnosis, not a re-run. Check: re-run the macOS job a few times at a fixed commit and count.

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
  (**DB-040**). Reopen it if cap-hugging survives the removal — that is the incident.
- **A byte cap on the constitution (`CONSTITUTION_WARN_KB`)**, refused while adding the
  current-state rule that would have motivated it — the defect is kind, not size, and a cap over
  all-live legislation makes shaving a rule the cheapest compliance (**DB-038**).
- **The 2026-08-10 review's two refusals** — **DB-024**.
- **A guard that opens files to classify them** (owner, 2026-08-11). Reading a `.pem`'s first
  line would separate a private key from a certificate, and it is refused: no rail here opens a
  file, and the advisory tier is the answer instead — **DB-027**.

## Changelog

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
