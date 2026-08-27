# DEVIATIONS & DISCOVERIES LEDGER — permanent registry (D-001…)

<!--
SEED TEMPLATE (AMH). Permanent memory: append-only, never rewritten. Add the ledger the
first time you catch yourself re-explaining a past mistake; it earns its cost once two
distinct sessions touch the repo, because it is the only channel through which session N's
shipped bug teaches session N+9's review pass.
-->

> **Append-only registry — NEVER archived, compressed or truncated.** This is the canonical,
> permanent home for every numbered deviation and discovery. Code and docs cite entries as
> bare `D-NNN` and those citations must always resolve here; no entry is ever deleted or
> summarised away. Append new entries at the bottom, one continuous sequence.
> Code and fixtures are ground truth: where an entry conflicts with the current code, the code
> wins and the entry stays exactly as written. **Rows are immutable — never edit one in
> place**, with one exception named below: the ` [cited]` marker is metadata rather than
> content, and syncing it — adding it or dropping it — is the one in-place edit this rule does
> not cover. A correction is a NEW row plus one appended pointer line on the old one, and there
> are two verbs: `Superseded by D-NNN.` when the whole row is replaced, `Corrected by D-NNN.`
> when one detail went stale under a principle that still stands. Both are append-only and
> mechanically identical. **Appending the pointer is required, not optional, whenever a change
> knowingly falsifies part of a committed row** — nothing can detect an omitted one, which is
> why it is written here. If your ladder carries an append-only guard, it can check the FORM
> and never which verb is honest, so that half is the reviewer's; if you have no such guard,
> all of this is prose only for you and worth saying so out loud. A row should carry at most
> one pointer, and treat the first as final.
>
> **This file is RETRIEVAL storage: grep it and cite it, never read it whole.** A `D-NNN`
> citation resolves to one row, and one row is what you read. A volume at its cap is tens of
> kilobytes of prose whose overwhelming majority is irrelevant to any given session, so
> reading it end to end spends a context budget better spent on the code you came to change.
> The ladder's cap rung prints a size in KB beside the line count so the read cost the cap
> stands in for stays visible. It measures the **live** volume only: once this file rolls over,
> its own size stops being reported, which is one more reason to grep it rather than open it.
>
> **Search before appending.** Grep the ledger for the topic first; extend or cite an
> existing row rather than append a near-duplicate. A row that supersedes an older one says
> so ("supersedes D-NNN") and the old row gets a `Superseded by` pointer, never deletion.
> **Keep new rows concise and at or below `LEDGER_ROW_SENTENCE_CAP`.** The working limit counts
> SENTENCES, which is what stops "a maximum, not a target" depending on restraint: a draft over
> it cannot be reworded into compliance, only shortened by a whole sentence. It is not a claim
> that the count cannot be gamed — repunctuating would move it — which is why the byte backstop
> below stays underneath and a new row satisfies both. Write only the durable lesson, even when
> that takes far less space; do not draft a narrative and shave it toward the cap, because
> shaving buys nothing here. Put larger narratives in `docs/history/` and link them from the
> `docs/STATE.md` changelog.
>
> **File cap & rollover.** This file holds at most `LEDGER_LINE_CAP` lines from `amh.conf` (the
> cap bounds LINES, not rows — rows vary in length, and it is read and context cost that is
> being bounded). Neither this cap nor the row cap below is restated here as a number, and
> neither should be: nothing checks preamble prose against `amh.conf`, so a copied number goes
> stale the first time a cap moves. Read a live value from `amh.conf`, or from the verdict that
> **turns on** it — a rejection has to say what it rejected against. A green run quotes neither
> cap, deliberately: the number a clean run puts in front of you is the number the next row gets
> drafted toward, which is how a cap written as a maximum is read as a length.
> New rows must also stay at or below `LEDGER_ROW_CHAR_CAP`, counted as bytes under `LC_ALL=C`;
> ASCII text is one byte per character and non-ASCII UTF-8 is charged by encoded bytes. That one
> is a backstop against sentences that run away, not the limit you write toward. Set it with
> real headroom over your longest compliant row, but do not expect to get FAR above it — a
> backstop that high has stopped bounding read cost. If it fires, the row is a narrative and
> belongs in an archive tier with a pointer from the changelog. Rows
> already committed when checked are historical and exempt. The final row may finish past the
> file cap, but no row may ever *start* past it: when the file stands over the
> cap, create the next volume with this same header discipline and number its rows from the
> matching prefix — `LEDGER.md`/`D-` rolls to `LEDGER_A.md`/`DA-`, then `_B.md`/`DB-`. The
> suffix advances as an odometer over A–Z, not a list with a last entry: `_Z` rolls to `_AA`,
> `_AZ` to `_BA`, `_ZZ` to `_AAA`, without limit. The ladder computes that name and prints it
> in the failure telling you to roll over, so you never have to spell it yourself.
>
> **The volumes form a CHAIN, and the ladder walks it from `LEDGER.md`, stopping at the first
> missing link.** A volume is a file the scheme can reach, not a file whose name looks right:
> a `LEDGER_X.md` with no `LEDGER_A.md`…`LEDGER_W.md` before it is unreachable, and its rows
> are read by nothing. The rung says so rather than ignoring it quietly — one warning naming
> the unreachable file, and a failure if `LEDGER.md` itself is the one missing. Existing rows
> are never moved or renumbered — the cap bounds file size, not history. A citation's prefix
> names its file.
>
> **`[cited]` marker (machine-CHECKED — you write it, the ladder verifies it).** A row cited
> from the ladder's scan scope carries ` [cited]` after its number. The ladder checks it BOTH
> directions — cited-but-unmarked and marked-but-uncited each fail the build — but it never
> edits this file: nothing syncs the marker for you. The marker warns you that code resolves
> here before you lean on or reword a row. Syncing it by hand means editing a committed row in
> place, which is why the immutability rule above carves it out: an append-only guard of your
> own must permit the marker in BOTH directions, or it will refuse the very edit this rung
> demands. Dropping a marker is not optional housekeeping — a marked row nothing cites any
> more fails the build until you drop it, and the row itself is never what goes.

- D-001: {{terse entry: what was discovered, decided or broken; what to do about it; what it
  affects. One entry per durable fact. Solved mistakes AND standing invariants both live
  here.}}
