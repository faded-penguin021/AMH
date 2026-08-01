Frozen archive (AMH P2, cold storage). Consult it; never edit what is in it.

**What lands here: documents retired WHOLE.** A completed plan worth retaining, a frozen
prior-era design doc, a reference superseded outright — something that stopped being live all
at once and is worth keeping readable. Adding such a file is the only way this directory grows.
A completed plan's durable outcomes still belong in ledger rows and changelog lines; its
archived copy is context, not permanent memory and not a valid implementation citation.

**What does not land here: the output of a compression pass.** When `docs/STATE.md` is
compressed, durable facts leave as ledger rows and the rest is folded into a Changelog line
pointing at them. Narrative whose durable content has already been extracted is cache, not
data — it is not relocated here for safekeeping.

**And never this repository's live working memory.** Moving `docs/STATE.md` here and starting
a fresh one obeys every sentence above while defeating all of them: it is the same relocation
at file granularity, it evades the cap that forces the fold, and it moves the Owner queue out
of the one document every session is required to read. Working memory is compressed in place,
never rotated. That rule is prose-only — no guard reads this directory, and "has it stopped
being live?" is a judgement, not a check.

The consequence, stated plainly rather than left to be discovered: under a squash-merge
topology the intermediate states are destroyed by design, so what a fold does not preserve is
gone. Extract to the ledger *before* compressing, not after.
