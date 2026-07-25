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
> summarised away. Append new entries at the bottom, one continuous sequence. Code and
> fixtures are ground truth: if an entry conflicts with the current code, trust the code and
> **correct** the entry — never delete it.
>
> **Search before appending.** Grep the ledger for the topic first; extend or cite an
> existing row rather than append a near-duplicate. A row that supersedes an older one says
> so ("supersedes D-NNN") and the old row gets a correction pointer, never deletion.
>
> **File cap & rollover.** This file holds at most **{{LINE_CAP}}** lines (the cap bounds
> LINES, not rows — rows vary in length, and it is read and context cost that is being
> bounded; keep the number in lockstep with `LEDGER_LINE_CAP` in `amh.conf`). The final row
> may finish past the cap, but no row may ever *start* past it: when the file stands over the
> cap, create `LEDGER_A.md` with this same header discipline, numbering from **DA-001** (then
> `_B.md`/`DB-001`, …). Existing rows are never moved or renumbered — the cap bounds file
> size, not history. A citation's prefix names its file.
>
> **`[cited]` marker (machine-managed).** A row cited from the ladder's scan scope carries
> ` [cited]` after its number. The ladder checks it BOTH directions — cited-but-unmarked and
> marked-but-uncited each fail the build — so it is verified derived state, never
> hand-tracked. The marker warns you that code resolves here before you lean on or reword
> a row.

- D-001: {{terse entry: what was discovered, decided or broken; what to do about it; what it
  affects. One entry per durable fact. Solved mistakes AND standing invariants both live
  here.}}
