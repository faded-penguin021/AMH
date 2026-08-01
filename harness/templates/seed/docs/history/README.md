# Archive — frozen (AMH P2, cold storage)

<!--
SEED TEMPLATE (AMH). Yours from the moment it is copied. This directory is the fourth memory
tier and the one a repo is likeliest not to need on day one — it is installed by the `full`
profile. If you took a smaller profile and later retire a document whole, create the directory
then and copy this README's rules in with it.
-->

Consult what is in here; never edit it.

**What lands here: documents retired WHOLE.** A completed plan worth retaining, a frozen
prior-era design doc, a specification superseded outright, a reference for a subsystem that no
longer exists — something that stopped being live all at once and is worth keeping readable.
Adding such a file is the only way this directory grows. A completed plan's durable outcomes
still belong in ledger rows and changelog lines; its archived copy is context, not permanent
memory and not a valid implementation citation.

**What does not land here: the output of a compression pass.** When the working-memory file is
compressed, its durable facts leave as ledger rows and the rest is folded into a changelog line
pointing at them. Narrative whose durable content has already been extracted is cache, not data
— it is not relocated here for safekeeping.

**And never a live file from another tier.** Moving the working-memory file here and starting a
fresh one obeys every sentence above while defeating all of them: it is the same relocation at
file granularity, it evades the cap that forces the fold, and it moves the Owner queue out of
the one document every session is required to read. Working memory is compressed in place,
never rotated.

That rule is **prose-only** by construction. No guard reads this directory and none is proposed:
"has this document genuinely stopped being live?" is a judgement an agent makes about its own
work, which is exactly what the harness refuses to build machinery on.

One consequence worth stating rather than leaving to be discovered: under a squash-merge
topology the intermediate states are destroyed by design, so whatever a fold does not preserve
is gone. Extract to the ledger *before* you compress, not after.
