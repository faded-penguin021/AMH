# DEVIATIONS & DISCOVERIES LEDGER — volume D (DD-001…)

> **Append-only registry — NEVER archived, compressed or truncated.** This is volume D,
> opened when `docs/LEDGER_C.md` reached its line cap at row DC-044. Rows in the previous
> volumes are never moved or renumbered, and a citation's prefix names its file: `D-NNN`
> resolves in `docs/LEDGER.md`, `DA-NNN` in `docs/LEDGER_A.md`, `DB-NNN` in
> `docs/LEDGER_B.md`, `DC-NNN` in `docs/LEDGER_C.md`, and `DD-NNN` here. Code and docs
> cite entries as bare IDs and those citations must always resolve; no entry is ever deleted
> or summarised away. Note the asymmetry: citations from **code and workflows** are
> machine-checked (`CITATION_SCAN_PATHS`), citations from **prose are not checked at all** —
> docs are deliberately out of scan scope, because prose mentions IDs without citing them. A
> dangling ID in a doc will not fail the build; that one is on the reviewer. Append new
> entries at the bottom, one continuous sequence.
> Code and fixtures are ground truth: where an entry conflicts with the current code, the code
> wins and the entry stays exactly as written. **Rows are immutable — never edit one in
> place**, with one exception named below: the ` [cited]` marker is metadata rather than
> content, and syncing it — adding it or dropping it — is the one in-place edit this rule
> does not cover. A correction is a NEW row plus one appended pointer line on the old
> one, and there are two verbs: `Superseded by D-NNN.` when the whole row is replaced, `Corrected by D-NNN.`
> when one detail went stale under a principle that still stands. Both are append-only and
> mechanically identical; the guard checks the FORM and cannot check which verb is honest, so
> that half is the reviewer's. **Appending the pointer is required, not optional, whenever a
> change knowingly falsifies part of a committed row** — nothing can detect an omitted one,
> which is exactly why it is written here. A row carries at most one pointer, ever, and the
> first is FINAL: the guard refuses a second pointer and refuses to rewrite the first, so a
> wrong verb is unrepairable.
>
> **This file is RETRIEVAL storage: grep it and cite it, never read it whole.** A `DD-NNN`
> citation resolves to one row, and one row is what you read. A volume at its cap is tens of
> kilobytes of prose whose overwhelming majority is irrelevant to any given session, so
> reading it end to end spends a context budget better spent on the code you came to change —
> and the ladder's cap rung prints this volume's size in KB beside its line count for exactly
> that reason (**DA-022**), because it is the live one. Closed volumes are never measured.
> Nothing in the harness has ever asked for a whole-volume read; this sentence exists because
> nothing forbade one either.
>
> **Search before appending.** Grep ALL volumes for the topic first; extend or cite an
> existing row rather than append a near-duplicate. A row that supersedes an older one says
> so ("supersedes DB-NNN") and the old row gets a `Superseded by` pointer, never deletion.
> **Mechanical acceptance and authoring quality are separate.** The two row caps are rejection
> boundaries for unusually long rows, never desired sizes. Passing both counters establishes only
> that a row is not obviously oversized; it does not establish concision, correct scope, or
> information quality. Write the smallest self-contained durable lesson first; one or two
> sentences are preferable when sufficient. Do not merge sentences, replace punctuation, remove
> useful qualifiers, or otherwise rewrite solely to change a counter. If a draft approaches a
> limit, reconsider whether it contains multiple ledger lessons, debugging chronology, completed
> state, or material that belongs in history; split the lessons, keep the durable conclusion, or
> route the narrative to `docs/history/` with a concise pointer from the `docs/STATE.md` changelog.
>
> **A version inside a row is what the session DRAFTED.** Write the number as drafted — `Drafted
> as MINOR X.Y.Z` — and assert no release: the number is settled at PR time against the latest
> tag, so one written mid-train is routinely never published, and "shipped", "published" and
> "released" are the same claim (**DC-023**, **DC-026**, owner 2026-08-27). Rows committed before
> this rule say `Shipped as` for numbers no tag carries; they are immutable, and they were
> deliberately left without a `Corrected by` pointer, so read the number in one as the draft it
> was — **DC-026** carries that trade and its cost. What a train actually published is in the
> `docs/STATE.md` changelog's train lines, which is the index to read when a row's number matters.
>
> **File cap & rollover.** This file holds at most `LEDGER_LINE_CAP` lines from `amh.conf` (the
> cap bounds LINES, not rows — it is read cost that is being bounded). New rows are capped by
> `LEDGER_ROW_SENTENCE_CAP` and `LEDGER_ROW_CHAR_CAP`; the guard counts bytes
> under `LC_ALL=C` for a locale-stable result, so ASCII text is one byte per character and
> non-ASCII UTF-8 is charged by encoded bytes. Neither
> value is restated here as a number, and neither should be: nothing checks preamble prose
> against `amh.conf`, and the 5.0.0 cap change left three volume preambles contradicting the
> guard (**DB-022**). The ladder quotes a value in the verdict that TURNS ON it — a rejection must say what it rejected against — and a green run deliberately quotes neither, because the number a clean run shows you is the number the next row is drafted toward (**DB-040**). Read both from `amh.conf`. Rows already committed when checked are historical and exempt. The final row may
> finish past the file cap, but no row may
> ever *start* past it: when this file stands over the cap, create LEDGER_E.md (this file's
> name with an _E suffix) with the same header discipline, numbering from **DE-001**. It is
> named without backticks on purpose — a name in backticks is a citation, and the path-refs
> guard resolves citations against the real tree. **You do not have to work that name out:
> the ladder's rollover failure prints the next volume's file name AND its row prefix,
> computed rather than looked up.** The exact spelling still matters: the ladder reaches this
> file by walking the chain of names the scheme generates, so a volume named any other way is
> not part of it — the cap rung warns and names such a file, and nothing reads its rows.
>
> **The scheme does not stop at Z, and the volumes are a CHAIN** (U5, shipped 2026-08-04;
> **DB-007** is the record, and the two defects the blocking pass found inside the fix are
> worth reading before touching any of this). The row pattern both the cap rung and the
> citation guard use is `D[A-Z]*-[0-9]+`, matched as a whole word, so a `DAA-001` row is seen —
> under the one-letter pattern it matched nothing, which made it invisible to the cap check AND
> unresolvable as a citation in both directions, with every rung green. The next suffix is an
> odometer over A–Z with carry (Z→AA, AZ→BA, ZZ→AAA), so there is no last entry to fall off.
> The live volume is found by WALKING that same carry rule from LEDGER.md and stopping at the
> first missing link: a volume is a file the scheme can reach, never a file whose name looks
> right. Rows are read from the chain too, so this rung and the citation guard cannot disagree
> about what a volume is. A volume-shaped file the walk does not reach is named in a warning
> and its rows are read by nothing; a missing LEDGER.md with continuations present is a
> failure, because `skip` reads like a pass.
>
> **`[cited]` marker (machine-CHECKED — you write it, the ladder verifies it).** A row cited
> from the ladder's scan scope carries ` [cited]` after its number. The ladder checks it in
> BOTH directions — cited-but-unmarked and marked-but-uncited each fail the build — but it
> never edits this file: nothing syncs the marker for you. The marker warns you that code
> resolves here before you lean on or reword a row. Known Goodhart path, unguarded: the
> cheapest way to strip a protected row's marker is to delete the code comment citing it,
> which the guard then *requires*. If you find yourself doing that, you are removing the
> warning rather than heeding it. Here `scripts/guards/ledger-append-only.sh` refuses the
> removal as a rewrite — but only while it is uncommitted, because it baselines on HEAD, so
> a commit walks past it and nothing looks again (**DC-020**). **One carve-out, and only
> one:** a citation inside a
> SHIPPED script is not a citation at all in the tree that receives it — those rows are ours
> and can never exist in an adopter's ledger — so removing one is correcting a false promise,
> not evading a warning. The reasoning prose stays and the row is named in a form the guard
> does not read (`AMH ledger row DDNNN`). That carve-out is no longer prose you have to
> remember:
> `scripts/guards/shipped-citations.sh` fails on a real id in anything this repository installs
> into an adopter's citation-scan paths — the shipped scripts, the seed scripts and the CI
> workflow, whatever the file extension. The one exception is the shipped fixture suite, whose
> ids are fixture material; the `CITATION_EXCLUDE` default in `harness/templates/amh.conf.example`
> keeps that file out of the scan of any adopter whose own `amh.conf` carries the key, and an
> adopter whose config predates it does not get the exclusion. Anywhere else, the sentence above binds.


- DD-001: **Passing paired size counters proves only the absence of obvious oversizing, not
  writing quality.** Mechanical acceptance must report the measured property without calling a
  ledger row concise or working memory well-compressed. Authors must not merge sentences,
  repunctuate, remove useful qualifiers, or otherwise rewrite solely to move a counter; nearing a
  limit is a prompt to separate durable lessons from chronology, completed state, and history.
