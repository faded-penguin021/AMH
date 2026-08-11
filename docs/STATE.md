# STATE — project state & session memory

> **Length guard (hysteresis).** The three thresholds are `STATE_WARN_KB`,
> `STATE_COMPRESS_TO_KB` and `STATE_HARD_KB` in `amh.conf`, and they are deliberately **not**
> restated here as numbers: nothing checks this prose against the config, so a restated number
> is a drift class no guard here covers (**DB-022**). Read them from `amh.conf` when you need
> them. The ladder's size rung prints whichever of them a verdict needs — the floor on its warn
> and fail lines, and again on the `ok` confirming a completed landing, so a green run can name
> all three. Those are derived from `amh.conf`, not copied from it (the landing line is in bytes,
> the key in KB), so a printed number is the guard's arithmetic, not a fourth copy (**DB-025**).
> Grow freely to the soft cap; over it, ONE deep pass landing at or below the compression
> floor — a ceiling, not a target; anywhere below is fine, a comfortable margin under it is
> fine, and you do not keep shaving once under (owner, 2026-07-27). Fail above the hard cap.
> **Compress by folding whole completed stages into Changelog pointer lines and moving durable
> lessons to the ledger** —
> never by shaving clauses until the guard goes quiet, and never by cutting text into another
> file. If the first pass lands short, fold MORE stages: micro-trimming toward the floor is the
> same reflex the band exists to break, one threshold lower. A typo fix above the cap is allowed
> and still owes the pass (**D-027**). The ladder checks sizes, structure and repeated headings
> (**D-034**) and nothing else — it will not judge whether what survived is any good, and it will
> not stop you dropping an open owner-queue item. Never drop one.

## Project

The AMH meta-repository: both the **source of truth** for the Agentic Maintenance Harness — a
reusable operating prompt plus scaffolds for repos maintained by agentic AI sessions — and its
**reference instance**, running byte-identical copies of the scripts it ships. The product is
`harness/` (prose source, templates, generated bundle); this repo's instance is `AGENTS.md` +
`docs/` + `scripts/` + `amh.conf`. Adopted harness version: **AMH 6.0.0** — see `harness/VERSION`,
the copy that counts.

## Current state

AMH 5.2.1 is tagged and published on origin at `48e0946` (confirmed by `git ls-remote --tags`,
which closed both of its queue items rather than restating them — the DA-011 shape, three times
running). This branch's work is classified **6.0.0** (MAJOR, agent) and all five hand-maintained
copies say so; the tag is queued. The owner confirmed MAJOR (2026-08-11) and refused
content-aware secret detection in the same breath: a guard never opens a file, so extension
tiering is the whole answer for `.pem`/`.key` (**DB-027**).

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

**OPEN — tag and publish AMH 6.0.0.** `harness/VERSION`, the changelog's top entry, `AGENTS.md`,
this file, `amh.conf` and the README Quick Start all say 6.0.0; the bundle and the manifest are
rebuilt (`command-guard.sh`'s hash moved, and the manifest's version header with it). Create and
push `amh-v6.0.0` after merge. No check: only the owner may tag or publish.
Check the copies with: `grep -rn '6\.0\.0' harness/VERSION AGENTS.md docs/STATE.md amh.conf README.md`

Everything else currently asked has been answered in the rows the Changelog cites; tags through
5.0.0 are cut and published, and `main`'s protection is repointed at `ladder`.

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

One line per shipped change or completed unit (newest first). Details live in the cited ledger
rows — this section is a pointer index, not a narrative.

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
