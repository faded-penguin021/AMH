# DEVIATIONS & DISCOVERIES LEDGER — volume D (DD-001…)

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

- DD-001: **Passing paired size counters proves only the absence of obvious oversizing, not
  writing quality.** Mechanical acceptance must report the measured property without calling a
  ledger row concise or working memory well-compressed. Authors must not merge sentences,
  repunctuate, remove useful qualifiers, or otherwise rewrite solely to move a counter; nearing a
  limit is a prompt to separate durable lessons from chronology, completed state, and history.
- DD-002: **Opening a new live ledger volume changes the baseline of fixtures that append rows.**
  Any fixture that means “live volume” must follow the chain rather than retain the formerly live
  file and prefix; expected diagnostics must also change when a verdict is deliberately narrowed.
- DD-003: **Threshold names must describe behavior, while immutable path prose needs an author-time check and a historical-drift exemption.** State warning and edit-delta values are triggers, state hard and ledger row limits are rejection boundaries, compression results satisfy post-action ceilings, ledger lines define a rollover boundary, and live-volume bytes are measurement only. A ledger path must resolve when authored, but after a committed target moves the row stays immutable and the path guard exempts only a reference and target both demonstrably present at HEAD; editable prose follows the rename and a correction row records changed meaning.
