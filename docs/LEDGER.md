# DEVIATIONS & DISCOVERIES LEDGER — permanent registry (D-001…)

> **Append-only registry — NEVER archived, compressed or truncated.** This is the canonical,
> permanent home for every numbered deviation and discovery. Code and docs cite entries as
> bare `D-NNN` and those citations must always resolve here; no entry is ever deleted or
> summarised away. Note the asymmetry: citations from **code and workflows** are
> machine-checked (`CITATION_SCAN_PATHS`), citations from **prose are not checked at all** —
> docs are deliberately out of scan scope, because prose mentions IDs without citing them.
> A dangling `D-NNN` in a doc will not fail the build; that one is on the reviewer. Append new entries at the bottom, one continuous sequence. Code and
> fixtures are ground truth: if an entry conflicts with the current code, trust the code and
> **correct** the entry — never delete it.
>
> **Search before appending.** Grep the ledger for the topic first; extend or cite an
> existing row rather than append a near-duplicate. A row that supersedes an older one says
> so ("supersedes D-NNN") and the old row gets a correction pointer, never deletion.
>
> **File cap & rollover.** This file holds at most **800 lines** (the cap bounds LINES, not
> rows — it is read cost that is being bounded, and the number stays in lockstep with
> `LEDGER_LINE_CAP` in `amh.conf`). The final row may finish past the cap, but no row may
> ever *start* past it: when the file stands over the cap, create `LEDGER_A.md` with this
> same header discipline, numbering from **DA-001** (then `_B.md`/`DB-001`, …). Existing
> rows are never moved or renumbered. A citation's prefix names its file.
>
> **`[cited]` marker (machine-CHECKED — you write it, the ladder verifies it).** A row cited
> from the ladder's scan scope carries ` [cited]` after its number. The ladder checks it in
> BOTH directions — cited-but-unmarked and marked-but-uncited each fail the build — but it
> never edits this file: nothing syncs the marker for you. The marker warns you that code
> resolves here before you lean on or reword a row. Known Goodhart path, unguarded: the
> cheapest way to strip a protected row's marker is to delete the code comment citing it,
> which the guard then *requires*. If you find yourself doing that, you are removing the
> warning rather than heeding it.

- D-001 [cited]: **This repository is both the harness's source of truth and its reference
  instance.** The distributed product lives under `harness/`; the repo's own instance is
  `AGENTS.md` + `docs/` + `scripts/` + `amh.conf`. The two are deliberately not the same
  files: prose scaffolds are *seeds* (copied once, then owned by the adopting repo), while
  scripts are shipped artifacts (copied verbatim, upgradeable). Rationale: a harness whose
  own repo does not run it has no evidence its artifacts work, and an artifact no repo
  executes rots silently.
- D-002 [cited]: **Shipped scripts are parameter-free and read `amh.conf` at runtime** — they are
  not rendered from `{{PLACEHOLDER}}` templates. A render step would create a permanent
  rendered-vs-template drift class needing its own guard; runtime configuration deletes the
  class instead of policing it. Consequence: `scripts/*.sh` here are byte-identical to
  `harness/templates/scripts/*.sh` and a guard enforces that with `cmp`, which is what makes
  the dogfooding claim checkable rather than aspirational. Supersedes nothing; see the
  Decided non-items entry in `docs/STATE.md`.
- D-003 [cited]: **The ladder has exactly two extension points**, and they exist so the shipped
  script never needs local edits (which is the precondition for D-002's `cmp` guard):
  `scripts/guards/*.sh` for repo-specific guards, and `scripts/verify.sh` for the full
  test/build/lint rung. A repo that finds itself editing `scripts/ladder.sh` has found a
  missing extension point — fix it upstream in the template, not locally.
- D-004: **The redaction filter is also the secret-shape scan.** The ladder does not carry a
  second copy of the token patterns; it pipes each text file through `scripts/redact.sh` and
  fails if the output differs. The scan is therefore drift-free by construction. Two
  consequences that have already bitten: any fixture token must be generated at runtime
  (a stored literal makes a file permanently fail its own scan — `redact.sh`'s self-test
  caught exactly this on the day it was written), and the diagnostic reports the file and
  byte position only, never the match.
- D-005: **The founding units installed this repo's legislation with no fresh-context rule
  review.** AMH P12 requires a fresh-context, strongest-tier review for every binding-rule
  diff and allows no self-review fallback. For U1–U2 there was no prior constitution to
  review against and no reviewer was spawned; the owner's review at merge stands in. From
  that merge onward the rule-review protocol binds normally. Recorded rather than skipped
  silently, because an undocumented exception becomes precedent.
- D-006: **`local a=$1 b=${#a}` explodes under `set -u`.** Bash expands every word of a
  `local` declaration *before* performing any of its assignments, so a later initialiser
  referring to an earlier name on the same line sees the OLD (unset) variable —
  `unbound variable`, on the first line of a function that reads correctly. Split the
  declaration. Shipped live in `command-guard.sh`'s segment splitter on day one and broke
  every single check; the self-test caught it immediately, which is the argument for rails
  carrying their own matrices.
- D-007: **Matching a forbidden word anywhere in a command instead of in its argument
  position.** The command guard scanned every token after `git` for `push`, so
  `git commit -m "never git push --force"` was blocked by its own commit message. Quoted
  text is DATA. The fix — resolve the git *subcommand* (skipping global flags), then judge
  only a real `push` — is the general rule: match a token's position, not its presence.
  This is the second of the two false-positive classes the harness warns about, and both
  surfaced within an hour of the guard existing.
- D-008: **A guard's fixture must be shown to fail without the guard.** Run the mutation
  before believing a new fixture — delete or neuter the guard and confirm the fixture goes
  red. A fixture that passes against the broken code is a false sense of protection, which is
  worse than none. Every mutation tried so far was caught (the STATE landing check, the
  secret-scan file list, the above-cap trim, the empty-section check).
  *(Correction, 2026-07-25: this row originally cited "the suite's 18 green assertions". That
  number was stale within a day. A permanent row must not embed a live count — the guard/prose
  lockstep class, committed inside the row warning about it.)*
- D-009: **Fanning out review subagents is the parallel-agent failure, not an exception to
  it.** P12 permits ONE fresh-context reviewer, blocking, inside the unit. The first session
  with the capability spawned three at once and kept editing files while they ran — so they
  were neither singular nor blocking. Nothing in the tooling resisted it; spawning three is
  exactly as easy as spawning one, which is the whole problem. The rule now appears at the
  point of temptation (session discipline 1 and the rule-review protocol), not only in the
  discipline list. The owner caught this, not a guard: it is not machine-checkable, because
  the harness cannot see its own agent's tool calls.
- D-010: **Prose that claims enforcement is worse than prose that claims nothing.** A rule
  review found five places asserting a check that did not exist or did not do what was
  claimed: a version-lockstep guard named in three files and never written; `[cited]`
  described as "machine-synced" when the ladder only compares; the ledger preamble claiming
  doc citations resolve when docs are out of scan scope; the STATE preamble naming Owner queue
  as mandatory (it warns) while omitting `## Changelog` (it fails); "machine-checks all of
  this" over rules no byte count can see. The failure mode is specific: a false enforcement
  claim is what stops a reviewer checking by hand. When adding a rule, write down which layer
  holds it — guard, rail, or prose-only — and say "prose-only" out loud.
- D-011: **A Goodhart hole usually survives one band higher than the fix.** The STATE landing
  check closed "trim to just under the soft cap" but only fired when the trim CROSSED below
  the cap, so 15.5 KB → 14.2 KB never triggered it and grow-then-nibble repeated forever under
  a warning. Generalisation: when closing a threshold-gaming hole, ask what the same game looks
  like without crossing the threshold. The check now fires on any shrink from above the cap
  that misses the floor.
- D-012: **A scope list must cover the file that defines the scope list.** `amh.conf` holds
  `STATE_HARD_KB`, `POISON_TOKENS`, `CITATION_SCAN_PATHS` and `RULE_FILES` itself, and was not
  in `RULE_FILES` — so raising a cap or blanking the poison tokens tripped no wire. Related:
  the ground-truth rule ("trust the code, correct the doc") let a one-line config edit
  retroactively amend the constitution, since the config IS code. That rule now resolves
  descriptive conflicts only; changing a binding value is a rule change.
- D-013: **The repo-local guards had no fixtures, and the constitution's rule made that
  unfixable.** It demanded every new guard land with a fixture in
  `scripts/test-ladder-guards.sh` — a file `copy-drift.sh` forbids editing, with no third
  slot for repo-local fixtures. Three guards shipped untested under a rule nobody could obey.
  Fixtures for repo-local guards now live in `scripts/tests/local-guards.sh`, run from
  `verify.sh`. Watch for this shape: a rule whose only compliant action violates a different
  invariant is not strict, it is broken.
- D-014: **The attestation ban is on machinery, not on prose — P3 said "never invent
  self-reported attestations" while P12 mandated writing "adversarial pass: clean" in the
  commit body.** Both inherited from the upstream harness, so the contradiction was a defect
  in the harness itself, not in this instantiation; an interim fix scoped the verdict as
  prose-for-humans and left P3's "never" standing as an overstatement. Resolved by the owner
  in favour of rewording P3: no guard, gate, CI step or required field may accept an agent's
  claim about its own process as evidence, while a sentence addressed to a human reader is
  fine. The operative test is **does anything downstream consume it** — a claim a human may
  disbelieve costs nothing; the moment a script greps for it or a checklist demands it, the
  work it stood for becomes optional. Generalisation: when a ban reads "never write X", check
  whether the harm is in the writing or in something depending on it; banning the artifact
  instead of the dependency outlaws honest disclosure and still permits the gate.
