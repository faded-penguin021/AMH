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
`docs/` + `scripts/` + `amh.conf`. Adopted harness version: **AMH 6.1.0** — see `harness/VERSION`,
the copy that counts.

## Current state

AMH 6.0.0 is tagged and published on origin (confirmed by `git ls-remote --tags` on 2026-08-13).
This branch is **6.1.0** (MINOR): it adds a project-scoped Codex rule reviewer without
changing the agent-neutral fresh-context review standard. All five hand-maintained copies say
6.1.0; the tag is queued.

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

**OPEN — tag and publish AMH 6.1.0.** `harness/VERSION`, the changelog's top entry, `AGENTS.md`,
this file, `amh.conf` and the README Quick Start all say 6.1.0; the bundle and manifest are
rebuilt. Create and push `amh-v6.1.0` after merge. No check: only the owner may tag or publish.
Check the copies with: `grep -rn '6\.1\.0' harness/VERSION AGENTS.md docs/STATE.md amh.conf README.md`

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
- **The 2026-08-10 review's two refusals** — **DB-024**.
- **A guard that opens files to classify them** (owner, 2026-08-11). Reading a `.pem`'s first
  line would separate a private key from a certificate, and it is refused: no rail here opens a
  file, and the advisory tier is the answer instead — **DB-027**.

## Changelog

- 2026-08-13 — **A project-scoped Codex rule reviewer now ships.** Its read-only profile reuses
  the runbook review classes, inspects the live diff and supporting artifacts, and stays
  human-readable rather than becoming machine-consumed evidence. Installer and adapter-set
  fixtures keep the repository-local copy synchronized (**DB-032**).

One line per shipped change or completed unit (newest first). Details live in the cited ledger
rows — this section is a pointer index, not a narrative.

- 2026-08-13 — **The ledger row cap is a maximum, not a drafting target.** Seed and local
  preambles now tell agents to write the durable lesson at its natural size, even far below the
  cap, rather than micro-trimming a narrative until it passes. The config template and scaffold
  explanation carry the same distinction; no value or guard changed. **DB-031** is the record.

- 2026-08-12 — **The destructive-command advisory rearms per operand set, names the failure mode it
  is shaped for, and stops suggesting its own sidestep.** From a downstream session that was
  blocked on `rm -rf "$S/base"`, renamed the target so no `rm` was needed, and reported it as
  routing around the trigger to save a turn. One marker per category meant the first harmless
  `rm -rf` in a session spent the rail for every later one; the state file now holds one line per
  operand set AS WRITTEN — command text, not resolved path, and the advisory names that limit
  rather than implying the guard resolves anything. The reason text asks for the non-empty check
  on a leading `$VAR/` path, excluding substitutions and always-set variables so the strongest
  paragraph stays rare, and says renaming the target is not compliance. Every new behaviour is
  fixtured against a mutant that removes it. No other category's rearm changed. **DB-030** is
  the record.

- 2026-08-11 — **The ladder's output description moved out of working memory into the runbook.**
  Owner call on the fork the unit below raised: the preamble's account of which thresholds the
  size rung prints, and why a printed number is not a copy, is a description of a guard rather
  than working memory, so it is charged to no byte cap now — it sits under `docs/RUNBOOK.md` →
  Acceptance ladder in both this instance and the seed, with a prose-only pointer where it stood.
  A relocation is not a compression, so the preamble carries the exception in writing. Measured
  across both units, and only part of it earned by compressing: this preamble is 16% smaller than
  at 5.2.1 (1699 → 1420 bytes) and the seed's 20% (4084 → 3271). **DB-029** is the record.

- 2026-08-11 — **The length-guard preamble is compressed, here and in the seed.** From an owner
  observation: a preamble inside a capacity-bounded file spends the budget it rations, and at the
  floor this one was a fifth of it. The seed's copy is ~15% shorter and this one ~10%, all of it
  restatement; no threshold, guard, fixture or exit code moved. The rule-review pass earned the
  difference between those two numbers — the first cut of this copy dropped the two clauses
  5.2.1 was cut to ADD, and they are restored. Folded into the unreleased 6.0.0. **DB-028** is
  the record.

- 2026-08-11 — **The redactor became a real second layer for key material.** Owner call on the
  finding the unit below surfaced: `private_key_block` matched the header line, so the filter
  printed a marker and then the whole key. A `private_key_body` range stage now redacts the body,
  anchored between the markers and matching wholly-base64 lines — without the anchor a manifest
  hash redacts, without the shape bound an unterminated header eats the log, and both are
  fixtured. The review caught the first floor: 32 characters, above the 20-28 real RSA tails, in
  a fixture whose oracle reused that same 32. Folded into the unreleased 6.0.0 rather than bumped again. The owner also confirmed
  MAJOR and refused content-aware detection outright. **DB-027** is the record.

- 2026-08-11 — **Branch review closed the Codex adapter's `_sk` asymmetry.** The command guard,
  Claude adapter and release prose named all six OpenSSH private-key stems, but the Codex rule
  stopped at four even though its prefix syntax can express `id_ecdsa_sk` and `id_ed25519_sk`
  exactly as well. The two bare and two `./` spellings now complete that adapter's promised set.
  CI then caught the generated bundle still carrying the four-stem template; rebuilt it from
  source rather than hand-editing it, restoring `dist-drift.sh` coverage.

- 2026-08-11 — **The secret-file rails reach private keys; `.pem`/`.key` get an advisory, not a
  block.** From an owner question about `.pem`, `.key` and `id_rsa`. `id_rsa` and its siblings
  block across readers, `<` redirection and copy sources; `.pub` clears by construction. The two
  container extensions join the one-time advisory `.env` already had. Found on the way:
  `redact.sh` redacts a key's BEGIN line only, so the read rail is the only mechanical layer for
  key material. Adapters
  moved with the guard. Shipped as 6.0.0 (MAJOR, queued). Both 5.2.1 queue items closed by testing
  them — `amh-v5.2.1` is published at `48e0946`. **DB-026** is the record.

- 2026-07-25 through 2026-08-10 — **Everything up to 5.2.1, folded.** Founding and self-hosting; the
  2.0.0, 2.1.x and 3.0.0 releases; installation profiles, integrity manifests, agent-neutral
  branches, and the Claude and Codex adapters with their cross-layer guard. Three owner-supplied
  RFCs entered as DATA under P18 and judged claim by claim — RFC1 refused at its core, RFC2's
  format refused but its diagnosis right, RFC3 accepted at two scenarios of seven; both plans are
  archived under `docs/history/`. Then the command guard's one-time advisories and their rearm,
  a third WARN verdict for repo-local guards, the ledger as a chain of volumes with append-only
  enforcement and a per-row byte cap, `shipped-citations.sh`, and `LEDGER_ROW_CHAR_CAP` cut from
  2000 to 800 as MAJOR. Then three units of prose repair through 5.2.1, all one class: prose
  restating a configured number, an unclosed enumeration read as complete, and a false claim about
  a guard's OUTPUT — the fix each time was subtraction rather than machinery, and no guard,
  threshold, fixture or exit code moved. Two external reviews found no critical or major defect.
  All tagged and published. **D-001**...**D-035**, **DA-001**...**DA-026** and
  **DB-001**...**DB-025** are the record.
