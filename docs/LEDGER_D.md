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
> **Paths in rows.** A row's immutability covers its text, not the lifetime or location of a file
> it names. A new path reference must resolve in the tree where the row is authored; a committed
> row's target may later move or disappear, and that drift leaves the historical text alone.
> Append a correction pointer only when meaning changed, and update editable documentation —
> including this preamble — to follow the target. New nonexistent paths are still rejected.
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
- DD-003 [cited]: **Threshold names must describe behavior, while immutable path prose needs an author-time check and a historical-drift exemption.** State warning and edit-delta values are triggers, state hard and ledger row limits are rejection boundaries, compression results satisfy post-action ceilings, ledger lines define a rollover boundary, and live-volume bytes are measurement only. A ledger path must resolve when authored, but after a committed target moves the row stays immutable and the path guard exempts only a reference and target both demonstrably present at HEAD; editable prose follows the rename and a correction row records changed meaning.
  Corrected by DD-004.
- DD-004 [cited]: **A ledger row's immutability covers its text, not the lifetime or location of a file it names.** Reading a committed citation as a retention rule for another tier's file kept a completed plan out of the archive for two releases, and 13.0.0's exemption tested the reference and the target at HEAD, so it survived only until the removal was itself committed. A path reference must resolve in the tree where its row is authored; a later move or deletion is historical drift, so `scripts/guards/path-refs.sh` now classifies a missing target against the commit that introduced the citing row. A parentless introducing commit — a shallow boundary or a squash import — settles nothing, so the guard falls back to the default-branch baseline and then to an explicit WARN rather than reporting an unread history as author-time proof or as a newly broken path. Editable prose follows a target that moves, ledger preambles included, and new rows still may not cite a plan's path, because a plan is provisional context whose citation dies when it retires.
- DD-005 [cited]: **A frozen tier must be excluded from path scanning, or it inherits the trap immutability just escaped.** `scripts/guards/path-refs.sh` scanned docs/history/ while the archive's own README and AMH P2 forbid editing what is in it, so a path named in an archived document that later moved could only be repaired by an edit the rules prohibit. The exclusion mirrors the plan tier's, which exists because a plan describes a tree that does not exist yet: an archive describes one that no longer does. Owner, 2026-09-02, choosing this over dropping the frozen rule so history could follow renames — the archive's whole value is that it does not change.
- DD-006: **Working memory must be tree-relative, because a cached world fact is a cache with no invalidation.** The state file asserted that the current version was untagged while its tag existed on origin, named a ledger volume's latest row three appends out of date, and claimed a forge protection setting no session can inspect — each true when written and read as current by every session after. `Current state` now records only what stays true of the checked-out tree; world-controlled status points at the live probe that recomputes it, an unresolved external action becomes an Owner-queue item with its command, and a retained past fact is scoped in the sentence to when it was observed rather than to a metadata field. The test is whether a sentence would survive this same commit being cloned tomorrow under another branch name. Prose-only and deliberately unguarded: the discriminator is meaning, so a rung grepping this file for forbidden phrases would be the attestation shape P3 refuses.
