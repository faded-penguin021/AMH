# DEVIATIONS & DISCOVERIES LEDGER — volume C (DC-001…)

> **Append-only registry — NEVER archived, compressed or truncated.** This is volume C,
> opened when `docs/LEDGER_B.md` reached its line cap (800 at the time) at row DB-040. Rows
> in the previous volumes are never moved or renumbered, and a citation's prefix names its
> file: `D-NNN` resolves in `docs/LEDGER.md`, `DA-NNN` in `docs/LEDGER_A.md`, `DB-NNN` in
> `docs/LEDGER_B.md`, `DC-NNN` here. Code and docs
> cite entries as bare IDs and those citations must always resolve; no entry is ever deleted
> or summarised away. Note the asymmetry: citations from **code and workflows** are
> machine-checked (`CITATION_SCAN_PATHS`), citations from **prose are not checked at all** —
> docs are deliberately out of scan scope, because prose mentions IDs without citing them. A
> dangling ID in a doc will not fail the build; that one is on the reviewer. Append new
> entries at the bottom, one continuous sequence. Code and fixtures are ground truth: if an
> entry conflicts with the current code, trust the code and **correct** the entry — never
> delete it.
>
> **This file is RETRIEVAL storage: grep it and cite it, never read it whole.** A `DC-NNN`
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
> so ("supersedes DB-NNN") and the old row gets a correction pointer, never deletion.
> **Keep new rows concise and at or below `LEDGER_ROW_SENTENCE_CAP`.** The working limit counts
> SENTENCES (**DC-003**), which is what stops "a maximum, not a target" depending on restraint:
> a draft over it cannot be reworded into compliance, only shortened by a whole sentence. It is
> not a claim that the count cannot be gamed — repunctuating would move it — which is why the
> `LEDGER_ROW_CHAR_CAP` backstop stays underneath and a row satisfies both. Write only the
> durable lesson, even when that takes far less space; do not draft a narrative and shave it
> toward the cap, because shaving buys nothing here. Put larger narratives in `docs/history/`
> and link them from the `docs/STATE.md` changelog.
>
> **File cap & rollover.** This file holds at most `LEDGER_LINE_CAP` lines from `amh.conf` (the
> cap bounds LINES, not rows — it is read cost that is being bounded). New rows are capped by
> `LEDGER_ROW_SENTENCE_CAP`, and beneath that by `LEDGER_ROW_CHAR_CAP`; the guard counts bytes
> under `LC_ALL=C` for a locale-stable result, so ASCII text is one byte per character and
> non-ASCII UTF-8 is charged by encoded bytes. The byte cap is a backstop against sentences that
> run away and sits far above where a compliant row lands — if it fires, the row is a narrative
> and belongs in `docs/history/`, not in tighter wording. Neither
> value is restated here as a number, and neither should be: nothing checks preamble prose
> against `amh.conf`, and the 5.0.0 cap change left three volume preambles contradicting the
> guard (**DB-022**). The ladder quotes a value in the verdict that TURNS ON it — a rejection must say what it rejected against — and a green run deliberately quotes neither, because the number a clean run shows you is the number the next row is drafted toward (**DB-040**). Read both from `amh.conf`. Rows already committed when checked are historical and exempt. The final row may
> finish past the file cap, but no row may
> ever *start* past it: when this file stands over the cap, create LEDGER_D.md (this file's
> name with a _D suffix) with the same header discipline, numbering from **DD-001**. It is
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
> warning rather than heeding it. **One carve-out, and only one:** a citation inside a
> SHIPPED script is not a citation at all in the tree that receives it — those rows are ours
> and can never exist in an adopter's ledger — so removing one is correcting a false promise,
> not evading a warning. The reasoning prose stays and the row is named in a form the guard
> does not read (`AMH ledger row DCNNN`). That carve-out is no longer prose you have to
> remember:
> `scripts/guards/shipped-citations.sh` fails on a real id in anything this repository installs
> into an adopter's citation-scan paths — the shipped scripts, the seed scripts and the CI
> workflow, whatever the file extension. The one exception is the shipped fixture suite, whose
> ids are fixture material; the `CITATION_EXCLUDE` default in `harness/templates/amh.conf.example`
> keeps that file out of the scan of any adopter whose own `amh.conf` carries the key, and an
> adopter whose config predates it does not get the exclusion. Anywhere else, the sentence above binds.

- DC-001: **Redirections are syntax — strip them before any word is judged.** The push rail
  counted `2>` and `>/dev/null` as refspecs, denying `git push -u origin session/x 2>&1` for
  "naming another branch" — false of the command it read. Filtering the refspec loop alone was
  both too narrow and too broad: a redirection between `git` and `push` had always hidden
  `--force` and `--mirror`; one before the command word hid the command itself; and filtering
  already-unquoted words read a literal `'2>'` argument as syntax and swallowed the `--force`
  behind it, D-007 one layer down. One quote-aware strip now runs first, in every position.
  Sessions route around rails (**DB-030**); a rail provably wrong about what it just read
  supplies the argument.

- DC-002: **"Not judged" and "nothing to object to" must never share an exit path** — a rail's
  form of the failure DA-008 records for generators. A scanner read its word list through a
  process substitution; an empty read took the "no words" branch and ALLOWED the command, so
  the rail could report a clean read of text it never parsed. Observed as 18 fixtures red on
  stock macOS Bash 3.2 and green on a re-run at the same commit; the mechanism is inferred, not
  proven, and the contiguity of the failing block fits sustained pressure over a window rather
  than a per-call coin flip. Removing the subshells is the repair. The fail-closed arms are a
  tripwire for the next transport, unreachable against these parsers by construction, which is
  the honest claim for them.

- DC-003 [cited]: **A limit an agent writes toward needs a second unit, because one unit is
  always cheap to satisfy.** The state floor and the new-row cap were byte thresholds, and both
  produced the same reflex: a draft over the line got trimmed word by word until it fit, landing
  7 bytes under the floor in one instance and going 874 to 797 against an 800-byte cap in
  another. Removing the number from green output (**DB-040**) could not reach it, because a
  session measures its own draft against a cap it read from `amh.conf` — the anchor is the cap,
  not the report of it. Counting sentences kills the shave, since the smallest edit that moves
  that count deletes a whole sentence; the review pass then showed a sentence floor alone is
  just as cheap to satisfy in the other direction, rewriting `. T` to `; t` across this state
  file from 85 sentences to 41 while freeing no byte at all. So an aim-point is bounded in both
  units and a landing satisfies both, each blocking the move that fools the other, while bytes
  still stand alone where nobody drafts: the soft and hard caps, and the edit delta.
