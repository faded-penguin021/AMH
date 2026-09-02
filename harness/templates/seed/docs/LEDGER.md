# DEVIATIONS & DISCOVERIES LEDGER — permanent registry (D-001…)

<!--
SEED TEMPLATE (AMH). Permanent memory: append-only, never rewritten. Add the ledger the
first time you catch yourself re-explaining a past mistake; it earns its cost once two
distinct sessions touch the repo, because it is the only channel through which session N's
shipped bug teaches session N+9's review pass.
-->

> **Append-only retrieval storage.** Append rows at the bottom in sequence; never move,
> renumber, summarize, or delete them. Search by topic or identifier rather than reading a
> volume whole. Code and fixtures settle current behavior; a stale row remains historical.
>
> **Rows are immutable.** The ` [cited]` marker is metadata and may be synchronized in place.
> Otherwise correct a detail with a new row and append `Corrected by D-NNN.` to the old row, or
> replace its whole conclusion with a new row and append `Superseded by D-NNN.` The first pointer
> is final. The guard checks pointer form, not whether the chosen verb is honest.
>
> **Authoring.** Search the volume chain before appending. Write the smallest self-contained
> durable lesson; route debugging narrative to history and point to it from the STATE changelog.
> `LEDGER_ROW_SENTENCE_CAP` and `LEDGER_ROW_CHAR_CAP` are rejection boundaries for new rows.
> Crossing either rejects the row; passing them proves no more than absence of obvious oversizing.
> Boundaries determine when machinery intervenes, not how much content an author should produce.
>
> **Rollover.** `LEDGER_LINE_CAP` is a rollover boundary: the final row may finish after it, but
> a later row starts the next volume. The suffix advances as an A–Z odometer, and existing rows
> never move. The live volume's byte size is measurement only: it is reported but never judged.
> Boundaries determine when machinery intervenes, not how much content an author should produce.
>
> **Paths in rows.** A new path reference must resolve when authored. If a committed row's path
> later moves or disappears, leave the historical text immutable, append a correction pointer
> when meaning changed, and update editable documentation. The local path guard exempts only a
> reference whose exact token and target both existed at HEAD; it continues to reject new nonexistent paths.
>
> **Citations.** Bare ledger IDs resolve through the volume chain. A row cited from configured
> code or workflow scan paths carries ` [cited]`; the ladder checks that marker in both
> directions. Documentation mentions are intentionally outside that machine check.

- D-001: {{terse entry: what was discovered, decided or broken; what to do about it; what it
  affects. One entry per durable fact. Solved mistakes AND standing invariants both live
  here.}}
