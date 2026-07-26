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
> ever *start* past it: when the file stands over the cap, create LEDGER_A.md (this file's
> name with an _A suffix) with this same header discipline, numbering from **DA-001** (then
> LEDGER_B.md/`DB-001`, …). The exact spelling matters: the ladder globs for it, so a volume
> named any other way is invisible to the line-cap and citation guards. Existing
> rows are never moved or renumbered. A citation's prefix names its file.
>
> **`[cited]` marker (machine-CHECKED — you write it, the ladder verifies it).** A row cited
> from the ladder's scan scope carries ` [cited]` after its number. The ladder checks it in
> BOTH directions — cited-but-unmarked and marked-but-uncited each fail the build — but it
> never edits this file: nothing syncs the marker for you. The marker warns you that code
> resolves here before you lean on or reword a row. Known Goodhart path, unguarded: the
> cheapest way to strip a protected row's marker is to delete the code comment citing it,
> which the guard then *requires*. If you find yourself doing that, you are removing the
> warning rather than heeding it. **One carve-out, and only one:** a citation inside a
> SHIPPED script is not a citation at all in the tree that receives it — those rows are
> ours and can never exist in an adopter's ledger — so removing one is correcting a false
> promise, not evading a warning. The reasoning prose stays and the row is named in a form
> the guard does not read (`AMH ledger row DNNN`). Anywhere else, the sentence above binds.

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
  *(No `[cited]` marker, deliberately: the shipped `ladder.sh` and `redact.sh` lean on this
  row in prose and name it as `AMH ledger row D004`, which the citation guard does not read
  as a citation and cannot mark. Reword this row with those two files open; **D-030**.)*
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
  *(No `[cited]` marker, deliberately: `command-guard.sh` leans on this row in four places
  and names it as `AMH ledger row D007`, invisible to the citation guard by design. Reword
  this row with that file open; **D-030**.)*
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
  *(Final sentence superseded by **D-027**, 2026-07-26 — it was true when written and describes
  a rule the guard no longer has: an ordinary edit above the cap, under a configured delta, is
  now allowed. Left standing rather than reworded, per this file's supersede-and-point rule.
  The hole THIS row is about is not reopened: a shrink crossing back under the cap must still
  reach the floor, unconditionally, so nibbling cannot disarm the warning.)*
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
- D-015: **A review protocol needs three bounds, not one; this repo shipped only two
  and the third leaked immediately.** Concurrency was bounded (one reviewer at a time, D-009)
  and depth was bounded (nobody reviews the reviewer), but *iteration* was not: nothing stopped
  a session from reviewing, fixing, and reviewing the corrected diff again — each pass
  sequential and single, each one compliant. That is a loop that launders a diff into looking
  approved, and the session did exactly it on the command-guard unit before the owner named the
  gap. Now: ONE pass per unit; fixes too large to ship unreviewed mean the unit was too big.
  Two adjacent clauses landed with it, both from live friction rather than review: spawning the
  reviewer is what the protocol requires and is not a permission to request each time (asking
  trains the owner to rubber-stamp), and a green-but-unreviewed legislation diff is HELD against
  a harness commit prompt — said once, not re-explained every turn. Generalisation: when a rule
  bounds a process, enumerate the axes it can run away along. Concurrency, depth and iteration
  are three different runaways, and closing two of them reads as closing all three.
- D-016: **Open defect register at the 2026-07-25 session handoff.** Recorded here rather than in working memory because STATE hit its hard cap; these are the next unit's scope, all confirmed and none fixed at the time of writing. Correct the entry as they are fixed; never delete it.
  1. **[SEVERE, shipped] `<<<` here-strings void every rail in `command-guard.sh`.**
     `strip_heredocs` opens heredoc-body mode on any `*'<<'*`, which matches `<<<` and `$((1<<8))`
     too; the delimiter resolves to `<`, no line ever matches it, and every later line is
     discarded unjudged. `grep -q x <<< "$v"` followed by `git push --force origin main` is
     ALLOWED — it voids the force-push and push-to-`main` rails, the two oldest. Server-side
     branch protection is the only remaining layer. Introduced in `a98b462` while fixing a
     heredoc false positive. Fix: open body mode only on a real heredoc operator (`<<` or `<<-`
     followed by a delimiter word), never on `<<<`.
  2. **[shipped] The `<` redirection scan matches `<` inside quoted text — D-007 verbatim.**
     `git commit -m "never read < .env directly"` is BLOCKED. The scan runs over the split words
     before leading-command resolution, so any `<` is treated as a redirection. Fix: judge
     position, not presence.
  3. **[shipped] `is_secret_name` blocks ordinary variables.** `$key`, `$sort_key`, `$page_token`,
     `$csrf_token`, `$public_key`, `$LICENSE_KEY` are all blocked — the last-component rule fixed
     substring matching in one direction and overshot in the other.
  4. **[shipped] Write destinations reported as reads.** `cp .env.example .env`, `tee .env`,
     `sed -i … .env` are blocked with the reason "Reading `.env` exposes credential values" —
     the false-reason class that was just fixed for `export NAME`, back via `cp`/`tee`/`sort`.
  5. **[shipped] `${VAR:+set}` is blocked**, though it never emits a value — it is the presence
     check the block reason itself recommends. And `${#VAR}` (the length, which the prose
     forbids) is NOT caught; nor is `0</proc/self/environ`; nor `readonly -p`.
  6. **[shipped] `AGENTS.md` over-claims reader coverage.** The "which layer holds which half"
     bullet says the guard blocks reads through a reader command; the list is 22 names, and
     `wc -c .env`, `md5sum .env`, `python3 -c "open('.env')"` all pass — `md5sum` and `wc -c`
     produce exactly the hash and length that same paragraph forbids. (D-010 pattern, written
     while fixing D-010 instances.) `harness/src/10-principles.md` hedges correctly; only the
     constitution bullet over-claims.
  7. **[shipped] Guard is quadratic and now 2× slower.** 32 KB of command text takes ~21s;
     64 KB projects past a typical hook timeout. Agents write multi-KB heredocs routinely.
  8. **[FIXED 2026-07-26] The ladder has failed on every run in the repo's history — all 8.**
     The failing rung is always `shellcheck`, which `verify.sh` treats as failed on ANY output,
     including info-level notices: SC2094 (false positive at `ladder.sh:271`, `redact.sh:118` —
     both `cmp` a file against a filtered copy of itself), SC2034 (`test-ladder-guards.sh:27`
     `local name=$1` genuinely unused; a `BRANCH_PREFIX` report), SC2016 (`local-guards.sh:114`,
     intentional), SC2128/SC2178. Shellcheck is CI-only, so no local run can see it. Fix the
     scripts — do NOT narrow `verify.sh` to get green. Also: `tr: write error: Broken pipe`
     appears twice in the fixture-suite output; check it is not a silent skip.
  9. **[FIXED 2026-07-26] Node 20 deprecation.** `actions/checkout@v4` targets Node 20 and is
     being force-run on Node 24. Bump to `@v5` in `.github/workflows/ci.yml` **and** in
     `harness/templates/configs/ci.yml` — adopters inherit the pin.
  11. **[repo-local guard] The STATE landing check cannot tell an edit from a compression pass.**
      Above the 14 KB soft cap, *any* shrink that does not reach the 9 KB floor fails the ladder
      — including a 3-byte typo fix. Hit live this session: correcting a wrong path in this very
      file (a reference to ladder.yml, corrected to `ci.yml`) turned the ladder red, and the only compliant moves were to
      compress the whole file or revert the correction. Both are worse than the typo. The guard
      is right about the Goodhart hole it was built for (D-011); it is wrong that every byte lost
      above the cap is a compression attempt. Fix direction: only judge a shrink as compression
      when it is large enough to *be* one (e.g. below some delta, or when the file crosses no
      band), and say plainly which it is. Do NOT fix by widening the band — that reopens D-011.
  12. **Fixture gaps behind all of the above.** Every "name merely contains a secret word"
      allowed-fixture puts the benign word last, so they pass by construction; none tests a
      benign name *ending* in `_KEY`/`_TOKEN`. No fixture covers `<` in quoted text, `<<<`,
      `${VAR:+…}`, or `cp x .env`. The blocked side is honest (all 20 fail against the old
      script). A duplicate `st_allowed 'grep -rn "force-push" docs/RUNBOOK.md'` appears twice.
- D-017: **First hostile read of the shipped scripts and templates (the D-005 sweep), 2026-07-25.**
  All CONFIRMED unless marked. None fixed. This closes the *investigation* half of D-005 — do
  not re-run the sweep; fix from this list.
  - **B1 [BLOCKER] The secret scan vanishes silently if `redact.sh` loses its exec bit.**
    `ladder.sh:255-258` and `:309-310`. Reproduced: with an `AKIA`-shaped token in the tree,
    executable → FAIL; `chmod -x scripts/redact.sh` → `skip  scripts/redact.sh not present`,
    **ladder green with the credential present**. `guard_rail_selftests` prints its header and
    nothing at all. `copy-drift.sh` does not catch it (`cmp` compares content, not mode). Hits
    any adopter arriving by archive extraction or `core.fileMode=false`. D-004 designates this
    guard as the repo's ENTIRE secret scan.
  - **B2 The citation guard word-splits its file list** — `ladder.sh:234`,
    `grep ... $(tr '\n' ' ' <"$scan_files")`. a scanned script containing `# see D-099` → FAIL; the same
    content in a filename with a space → **green**. `2>/dev/null` swallows the error.
    The same file forbids exactly this at `:265` ("a scan with a silent hole is worse than no
    scan"); `harness/src/30-scaffolds.md:63` calls it "a blocker-class hole". Fixture
    `secret_spacey` exists; no `cite_spacey`.
  - **B3 Same defect in `scripts/guards/path-refs.sh:25`** (`for f in $files`).
  - **B4 Three guards have ZERO fixture coverage** (mutation-tested: stubbing them leaves the
    suite 20/20 green) — `guard_poison_tokens`, `guard_rail_selftests` (the one that catches
    B1), and `advisories` (which holds the rule-review tripwire). Causes: `mk()` never creates
    an `origin/<default>` ref; `run()` sets `CI=1` and `advisories` starts `in_ci && return`;
    `mk()` hardcodes `RULE_FILES=''`. **`guard_poison_tokens` is also inert in this repo right
    now** — `git rev-parse --verify origin/main` fails locally, so it prints `skip` every run.
    The other eight mutations were caught; the suite is otherwise honest.
  - **B5 `redact.sh` misses live credential shapes**, verified by piping runtime-generated
    tokens: `sk-proj-…` (the *existing* `openai_key` class no longer matches OpenAI's format —
    `redact.sh:34` is `sk-[A-Za-z0-9]{32,}` and the `-` breaks the class), `ASIA…` (AWS STS),
    `glpat-…`, a `postgres://` or `https://` URL carrying `user:secret@` userinfo, `hf_…`,
    `Authorization: Bearer …`. The URL-with-userinfo shape already appears in this repo's own
    `git remote -v` output. Negative cases are clean — no false positives found.
    (Correction, 2026-07-26 — the two URL examples were written out whole here and became
    live matches the moment the `url_credentials` class existed, failing the tree scan on
    this very row. Rewritten as a description of the shape; the finding is unchanged. D-022.)
  - **B6 Exact-length classes leak the token tail.** `AKIA[0-9A-Z]{16}`, `AIza…{35}`,
    `npm_…{36}` are fixed-count; a longer token prints its remainder:
    `[REDACTED:google_api_key]AXThQ`. `AGENTS.md` forbids printing a suffix. The self-test
    **structurally cannot see this** — `redact.sh:74` asserts only that the whole token is
    absent, which a partial redaction satisfies.
  - **B7 `session-start.sh:33` silently skips the toolchain bootstrap** when `REMOTE_FLAG` is
    not a valid shell identifier (e.g. `AMH-REMOTE`): `${!REMOTE_FLAG}` errors to stderr, exit
    0, bootstrap never runs. `amh.conf` presents the flag as free-form with no stated
    constraint.
  - **B8 `rm -rf scripts/guards` → ladder green with no output at all** (`ladder.sh:320-333`),
    against the script's own convention of printing `skip` for anything absent.
  - **B11 `CONTRIBUTING.md` does not exist**, is cited 5× (`docs/RUNBOOK.md:32,42,104,207`,
    `docs/UPGRADING.md:4`) and is in `RULE_FILES`; playbook 5 is unfollowable because of it.
    the init script `amh-init.sh` likewise absent, cited 3×, pre-allowed in `.claude/settings.json:13`.
    `path-refs.sh` reports 63 refs resolving because its pattern requires an embedded slash, so
    a repo-root file can never match — the guard was admitted to close this exact incident and
    is blind to half of it.
  - **B12 `command-guard.sh` mistake-class misses**: `git push origin +main` (force-push AND
    default-branch push) ALLOWED, `git push --mirror origin` ALLOWED, `source .env` / `. ./.env`
    ALLOWED. The static deny rails miss `+main` too — both layers fail together.
  - **B9/B10 [PLAUSIBLE, unreproduced]** `ladder.sh:271` discards `cmp`'s stderr, so a
    truncated `redact.sh` stream would pass silently; `ladder.sh:207` `CITATION_EXCLUDE` keeps
    the unfiltered list if the exclusion empties it, and interpolates `$ex` unescaped.
  - **B13/B14 minor**: `harness/templates/seed/scripts/verify.sh` is mode 100644 while
    `ladder.sh:425` requires `-x`, so an adopter's first full run is red; `.claude/settings.json`
    pre-allows a script that ships nowhere.
  - Clean categories, do not re-check: D-004 runtime-generated fixtures honoured everywhere;
    D-006 `local` expansion clean; redaction false positives none; `guard_secret_shapes` NUL
    handling correct; `dist-drift` faithful.
- D-018: **The rule-review codification (D-015) shipped a contradiction and a false citation,
  caught by its own pass.** P12 named the three bounds *Depth, Iteration, Standing* while the
  runbook and seed named *Concurrency, Iteration, Depth* — the generated bundle carried both
  enumerations 627 lines apart under the same heading, and the P12 copy dropped the concurrency
  bound that carries D-009's no-fan-out rule. Fixed by aligning on Concurrency/Iteration/Depth
  and demoting "standing" to a following clause (it is a permission rule, not a runaway axis).
  Also fixed: the claim that "the playbooks say the pass happens BEFORE the commit" — they do
  not, only the ladder's warning does — and a collapsed paragraph break that made the STATE
  exemption read as an exemption from the hold rule. **Open, escalated to the Owner queue:** the
  iteration bound is Goodhart-open. "Fixes too large mean the unit was too big: split it" lets a
  session relabel the corrected diff as a new unit and claim a fresh pass, and no definition of
  a unit is mechanical (`docs/RUNBOOK.md:128`, "about one focused hour", self-assessed). Per
  D-011 a hole survives one band above the fix; this one is prose-only, and `RULE_FILES` does
  not even cover `harness/src`, so the P12 edit in that very diff tripped no tripwire.
- D-019 [cited]: **A guard that tests `-x` before running has an off switch, and the switch
  looks like a pass.** The ladder's secret scan — `redact.sh`, designated the repo's ENTIRE secret defence
  by D-004 — printed `skip  scripts/redact.sh not present` when the file lost its execute bit,
  and the rail self-test section printed its header and nothing at all. Ladder green, live
  credential in the tree, no line saying anything was missing. Reached by an archive download,
  `core.fileMode=false`, or one stray `chmod`, and `copy-drift.sh` cannot see it because `cmp`
  compares content, not mode. Fixed by asking the question that actually matters: the file's
  PRESENCE decides, absence FAILS for the scan (a skip for the thing that is the whole scan is
  a contradiction) and prints `skip` for the self-tests, and both invoke through `bash` so the
  mode has no vote at all. Generalisation: when a guard can be disabled by a property that is
  not its subject — a file mode, an unset variable, a missing ref — the disabled state must be
  louder than the passing state, not quieter. Prefer deleting the dependency (run through
  `bash`) over policing it.
- D-020: **Three guards had no fixture at all, and the cause was the fixture BUILDER, not
  neglect.** Mutation-testing found `guard_poison_tokens`, `guard_rail_selftests` and
  `advisories` all stubbable with the suite still 20/20 green. Each was unreachable by
  construction: `mk()` created no `origin/<default>` ref, so the poison scan resolved nothing
  and printed `skip` on every run (it was inert in the reference repo too, for its entire
  life); `run()` sets `CI=1` and `advisories` opens with `in_ci && return`; `mk()` hardcoded
  `RULE_FILES=''`, so the rule-review tripwire had nothing to trip on. A fixture harness is
  itself a guard and needs the same hostility: **the question is not "did I write a test" but
  "can the guard be stubbed with the suite still green".** Two mutations that prove nothing
  are worth recording as well — a rail self-test overridden by a function appended AFTER the
  file's dispatcher never runs, and a single-line here-document fixture cannot exercise body
  mode, which only ever discards SUBSEQUENT lines.
- D-021 [cited]: **A lint waiver scoped to a compound command is not a waiver, it is a blind spot —
  and the first draft of the fix put two of them inside the guards.** D-016 items 8 and 9 are
  closed: CI is green for the first time (run 14, `8326627`), fixed in the SCRIPTS with
  `verify.sh` untouched — `BRANCH_PREFIX` deleted from `ladder.sh` (it never read it), and an
  inline `# shellcheck disable=` carrying its reason at each SC2094 and SC2016 site. What the
  review caught is the interesting half. `# shellcheck disable=` before a compound command —
  a `while ... done`, an `if ... fi` — covers the ENTIRE body, so the first draft silenced
  SC2016 for all of `path-refs.sh`'s backtick loop and SC2094 for the whole self-test `if`
  inside `redact.sh`, which is the repo's entire secret scan (D-004). Proven by injection: a
  planted `$target`-in-single-quotes and a planted `cat "$f" > "$f"` both linted silent, and
  both fire once the waiver is narrowed. SC1123 forbids a directive on `done < <(...)`; it
  does NOT force widening to the compound — hoist the offending command into its own
  assignment, or factor it into a one-line function, and the waiver covers exactly it.
  **Generalisation: a suppression must be narrower than the thing it protects.** When the
  narrow form is syntactically awkward, the awkwardness is the price of the guard keeping its
  teeth; widening the scope to make the directive fit is how a gate gets weakened by a door
  nobody was watching. Corrections to the rows above, which are append-only and so are
  recorded here instead: (a) item 8's "all 8" was true when written and stale by the time it
  was actioned — runs 1–13 all failed, run 14 is the first success; the CI log, not a ledger
  row, is the authority on what shellcheck reports; (b) item 8's SC2128/SC2178 and
  `test-ladder-guards.sh:27` symptoms were already gone by then and needed no fix. Also
  checked and clean: the `tr: write error: Broken pipe` was **not** a silent skip —
  `tr -dc … </dev/urandom | head -c N` leaves tr writing into a pipe `head` closed after
  taking its N bytes, so the token was always complete. Removed regardless (bounded read,
  then slice) because noise in a guard's output is how a real diagnostic gets skimmed past.
- D-022: **A redaction pattern is judged by what it eats, not by what it catches — and the
  first draft of the widened filter ate one-line JSON.** D-017 B5 and B6 are closed:
  `redact.sh` now matches `sk-proj-`/`sk-svcacct-`/`sk-admin-`, `ASIA`, `glpat-`, `hf_`,
  `Authorization: Bearer` headers and URL userinfo, every length is open-ended (`{n,}`, never
  `{n}`) so an over-long token can no longer print its own tail, and `st_redacted` asserts
  the filtered line EXACTLY rather than merely that the whole token is absent. That last one
  is the load-bearing change: the old assertion was satisfied by a partial redaction, so no
  fixture could ever have found B6 — proven by injection, restoring `AIza…{35}` now turns the
  self-test red where it used to pass. What the review pass caught is again the interesting
  half. The new `url_credentials` class excluded only `/ ? # @` and whitespace from the
  userinfo, so on a compact JSON or logfmt line `scheme://host:port` plus any later `@`
  matched across the gap: `{"url":"http://svc:8080","user":"a@b.com"}` was rewritten to
  `{"url":"[REDACTED:url_credentials]b.com"}` — host, port and structure deleted, no
  credential anywhere in the line. `bearer_header` with a bare `{8,}` value ate any long word
  after the header name, so the sentence "Authorization: Bearer authentication" redacted, in
  a repository whose prose is *about* credential handling. Both would have turned the tree
  scan red on innocent content, which is how a filter gets switched off. Fixed by excluding
  quoting and structural punctuation from userinfo, and by requiring a bearer value to carry
  a digit or punctuation and run to 13 characters. **Generalisation: for a filter that is
  also a gate, a false positive is not the mild failure — the miss leaks one secret, the
  false positive gets the whole filter disabled.** Three further corrections from the same
  pass: the widened `sk-[A-Za-z0-9_-]{32,}` redacted ordinary long kebab-case identifiers
  (`sk-build-linux-x86-64-…`), so the OpenAI families are now four explicit rows and the
  generic class went back to alphanumerics — an alternation would have been the obvious fix
  and is impossible here, because `|` is the generated `s|…|…|g` delimiter; `slack_webhook`
  now tolerates optional userinfo, without which `url_credentials` rewrote the prefix first
  and left the webhook token in the clear; and every negative fixture now places its
  candidate MID-LINE, because one whose benign text runs to end-of-line passes by
  construction — the same defect D-016 item 12 recorded, re-shipped in new fixtures written
  by someone who had read that row. **The assertion itself is now fixture-covered** (D-020):
  a probe feeds `st_redacted` a deliberately partial redaction and requires it to object, so
  the check that closes B6 cannot silently revert. Note the subshell trap it caught in
  passing — the probe called through `$(...)` runs in a subshell where the counter increment
  is discarded, so it reads as "detected nothing" however the assertion behaves.
  Corrections to append-only rows above, recorded here per the D-021 precedent: (a) D-017 B5
  spelled its two example URLs out in full, which became live matches the moment the
  `url_credentials` class existed and failed the tree scan on the ledger itself. The row was
  defanged IN PLACE — the only correction of a row's own text so far, and unavoidable,
  because quoting the old text here would reproduce the match; the finding is unchanged and
  the edit is annotated at the row. (b) Two gaps are known and deliberately NOT closed in
  this unit, since each adds false-positive surface that would ship unreviewed: userinfo with
  no colon (`https://<PAT>@dev.azure.com/…`, the documented Azure DevOps clone URL) is still
  missed, and `ASIA` + 16 uppercase characters redacts an ordinary run-together identifier.
  Both are in the Owner queue. *(Correction pointer, 2026-07-26: neither is, now. The `ASIA`
  half was resolved to knowingly ACCEPTED and the reasoning sits at the class itself in
  `scripts/redact.sh`, which is the authority; the colon-less-userinfo half is an open finding
  in `docs/STATE.md` with a settled direction, not an owner decision. Read this clause for what
  was deferred and why, never for where either gap currently sits.)* (c) A `D-006` citation
  belongs in `redact.sh`'s note about
  `local a=$1 b=${2:-"X$a"}` failing under `set -u`, and is deliberately absent: `redact.sh`
  is a SHIPPED script, and a `D-NNN` citation inside one resolves against the ADOPTER's
  ledger, where no such row exists. The shipped `ladder.sh` already cites D-004 this way; the
  class is real, is not this unit's to fix, and is queued.
  *(Correction pointer, 2026-07-26: the second sentence is now false and the class is closed —
  no shipped script cites anything. Every `D-NNN` in the shipped scripts was rewritten as a
  provenance token the citation regex does not match. Read this clause for why the absent
  `D-006` citation was the right call, never for what the shipped scripts currently contain;
  **D-030**.)*
- D-023 [cited]: **A dangling citation is a symptom; the disease is that nobody ever walked the path.**
  D-017 B11 is closed — `CONTRIBUTING.md` and `scripts/amh-init.sh` exist, so RUNBOOK playbook
  5 is followable and the `.claude/settings.json` pre-allow points at a real script — and with
  them the guard that was supposed to have caught their absence. `path-refs.sh` resolved 64
  references while five citations to a missing root file sat in front of it, because its
  backtick pattern required an embedded slash and a repo-ROOT file therefore could not match:
  the guard admitted to close that exact incident was blind to half of it. Bare names now
  resolve by BASENAME anywhere in the tree, which is the narrow form that works — resolving
  them from the repo root was tried and rejected at 24 hits for 2 true positives, because
  `STATE.md` and `ci.yml` are simply how the prose names `docs/STATE.md` and
  `.github/workflows/ci.yml`. Coverage roughly doubled. (No count is recorded here on purpose: it moves with every doc
  edit, and D-008 is the row about a permanent entry embedding a live number.) The accepted residue:
  four names that were deliberately hypothetical (a future ledger volume) or historical (a
  path quoted BECAUSE it was wrong) read as citations, and no rule can tell those from real
  ones, so the prose stopped code-spanning them — **a name in backticks is a citation, and a
  name that is not a citation should not be in backticks.**
  **The finding worth more than the fix**: writing `amh-init.sh` meant an adopter's first run
  could finally be executed, and it was RED — `cited from code but no such ledger row: D-004
  D-007 D-019`. The SHIPPED scripts cite this repo's ledger in their comments, those rows can
  never exist in an adopter's ledger, and so the citation guard failed on a repo its owner had
  not yet touched, for rows they could not have written. Nothing detected this for the harness's
  entire life, because nobody had instantiated it; B11's dangling references were the *reason*
  nobody could. Fixed in the shipped `amh.conf.example` by excluding the shipped scripts from
  the adopter's citation scan — their `D-NNN` comments resolve against the HARNESS's ledger,
  not the adopter's — while everything the adopter writes stays in scope. **Generalisation:
  an artifact nobody can execute accumulates defects at full speed and reports none; the first
  run of a path is worth more than any amount of reading it.** Also folded in, same family
  (the adopter's first run is red for a reason that is not theirs): the seed `verify.sh`
  shipped mode 100644 while the ladder requires `-x` (**B13** — mode fixed in git, and
  `amh-init.sh` installs seed scripts 755 regardless, so a hand-copy cannot reintroduce it).
  Two notes on how the init script is shaped by rules already in this ledger: it validates
  `REMOTE_FLAG` as a shell identifier so it cannot write the value that makes the bootstrap
  skip silently (B7 narrowed at the source, NOT fixed — the silent skip is still open), and
  it builds its `{{…}}` patterns at runtime from a data list rather than spelling them out,
  so the placeholder guard needs no exemption for it. The exemption was the obvious move and
  was wrong: it would also have hidden a placeholder the script forgot to substitute.
- D-024: **A predicate a fixture satisfies only USUALLY is a flake, however sound the
  predicate looks — and this one shipped into the repo's entire secret scan.** Unit 4's
  `bearer_header` class required the value to contain a digit or punctuation with twelve
  characters after it; the fixture drew its token from `rand_alnum`, which guarantees no such
  character. About one token in 140 had no digit early enough, the self-test failed, and the
  ladder went red — at random. The ladder runs `redact.sh --self-test` once per fixture repo,
  so ~30 draws per run compounded to roughly a **one-in-five chance of a red CI run per
  push**. It passed locally several times before the push, which is exactly what a 0.7%
  failure rate looks like from the inside: the local green was luck, and reporting it as
  verification was wrong. Found by CI (run 16) and by the owner reading the log, not by any
  guard here. Two separate lessons, and the second is the bigger one:
  (a) **a fixture must satisfy its predicate BY CONSTRUCTION, never on average** — the token
  is now built as uppercase/digits followed by alphanumerics, so it cannot miss; and
  (b) **the predicate itself was wrong**, which the owner caught while it was being fixed.
  The first repair was a length floor, on the reasoning that no English word is that long:
  false (`antidisestablishmentarianism` is 28, `pneumonoultramicroscopicsilicovolcanoconiosis`
  is 45, and a repo holding sequence data or long identifiers has no ceiling at all). The
  second was "must contain one non-lowercase character": also false, because a word starting
  a sentence is capitalised. What actually holds is **two** non-lowercase characters — an
  English word carries exactly one capital wherever it sits, an opaque credential carries a
  dozen — with the ANCHOR (`Authorization:` `Bearer`) doing the real discrimination and the
  character rule only separating a token from the handful of words that appear in that exact
  position. Generalisation beyond regexes: when a heuristic separates two populations, state
  the property that actually distinguishes them and test the property, rather than reaching
  for a threshold on a proxy — a threshold invites "is 24 enough?", which has no answer, while
  "words are lowercase, tokens are not" can be checked against a counter-example and was,
  twice, before it held.
- D-025 [cited]: **Unit 5's review pass, and the shape of what it caught.** D-017 B11 and B13 are
  closed (D-023); this row carries the corrections its fresh-context pass returned, none of
  which were in the artifacts the unit set out to build — they were all in the *guard* and the
  *tool* written to close it. `path-refs.sh` resolved bare names against `git ls-files`, which
  answers from the INDEX, so a file removed with plain `rm` still resolved and the guard's own
  headline incident passed green with only a stray `grep` complaint on stderr (D-019's shape:
  the disabled state quieter than the passing one). The new fixtures did not pin `grep -x`, so
  dropping it left the suite green while TATE.md and adder.sh resolved as substrings. In
  `amh-init.sh`, the value check rejected `|` (the sed delimiter) and nothing else, so `&`
  silently wrote the placeholder back into a live config and a newline **injected a line into
  `amh.conf`, a file every shipped script sources at runtime** — arbitrary shell on every
  future ladder run of the adopter's repo, exit 0, no warning; the write also truncated its
  destination before `sed` ran, so a failure emptied the file and then reported that it had
  not written it. And the `keep` policy returned before `chmod`, so re-running init — the
  documented recovery — could not repair a `verify.sh` that had lost its execute bit, which is
  B13 recurring inside B13's own fix. **Generalisation: the dangerous half of a repair is the
  new machinery it introduces, not the gap it closes.** Every unit this session had its blocker
  inside the fix. Also corrected here: `CONTRIBUTING.md` first described `RULE_FILES` as the
  rule-review protocol's scope, which the runbook names in as many words as "how a rule quietly
  stops binding" (`STATE.md` and `LEDGER.md` preambles are legislation and are deliberately not
  in that list); it restated the no-self-review rule with the "cannot means capability, not a
  standing instruction" qualifier deleted, which would have parked every legislation change
  forever; and it cited the link checker as a still-declined non-item when `path-refs.sh` IS
  that checker, admitted the same day it was declined. Two deliberate non-fixes: nothing binds
  `INIT_PLACEHOLDERS` in `amh-init.sh` to the rows marked `init` in `harness/PLACEHOLDERS.md`
  (they agree today; adding a template placeholder and forgetting the list is silent, and the
  guard for it needs its own fixture, so it is queued not bolted on), and the merge-mode placeholder in
  the seed constitution stays a human's sentence even though the script knows the answer.
  *(Correction pointer, 2026-07-26: the first of those two non-fixes did not stay queued — the
  binding shipped later the same day. It is `scripts/amh-init.sh`, which derives the `init` rows
  from `harness/PLACEHOLDERS.md` and dies on a mismatch, an empty derived set included; the
  fixture the row asked for is in `scripts/tests/test-init-e2e.sh`, covering both directions.
  Read this row for why it was deferred, not for the current state. The second non-fix, the
  merge-mode placeholder in the seed constitution, stands.)*
- D-026 [cited]: **`shellcheck` is CI-only by constitutional carve-out, and the cost of that is a
  verification rung the agent cannot see.** Recorded because it is repeatedly mistaken for a
  deviation from "no new dependencies" and is not one: `AGENTS.md` states the exception in the
  same breath as the rule ("a bare container with `bash`, `git` and coreutils; `shellcheck` is
  CI-only"), and `verify.sh` implements exactly that — run it when present, **fail** if it is
  missing under `CI`, print `skip (not installed locally — CI runs it)` otherwise. The rule is
  intact; this row is about the price. That price is not small: the shellcheck rung is the one
  that has been red most often in this repo's history (runs 1–13, every failure), and it is
  structurally invisible to a local ladder run, so a session that edits a script without
  installing shellcheck first is editing blind and will discover it from CI after the push.
  **Install it before touching any script** and run the ladder with it on `PATH`; local 0.11.0
  and CI's apt 0.9.0 have agreed exactly every time they have been compared, but when they
  disagree the CI log is the authority, never a ledger row (D-021). Generalisation: a
  dependency carve-out that keeps the toolchain thin does not make the tool optional — it
  moves the moment of discovery from the edit to the push, and the fix is a habit, not a rule
  change. Reopening the carve-out is not the answer; installing the tool takes one command.
- D-027: **The guard that could not tell a typo fix from an unfinished compression pass, and
  the assertion that never asserted its own name.** D-016 item 11 is closed; **supersedes the
  closing sentence of D-011** ("fires on any shrink from above the cap that misses the floor"),
  which that row now points here for. The STATE landing
  check read every byte lost above the soft cap as a compression pass in progress, so a 15-byte
  deletion had to either compress the whole file or be reverted; it hit that twice, and the
  second time the compliant move was to **pad the file back**, which is the guard paying to be
  obeyed. It now branches on the shrink's SIZE and whether it CROSSES the cap: a crossing must
  land on the floor (D-011 verbatim, untouched), a sub-delta shrink above the cap is an ordinary
  edit, and a shrink at or over the delta above the cap is an unfinished pass. `STATE_EDIT_DELTA_BYTES`
  defaults in the script, so no adopter has to edit the config file they were told they own. The
  band is not widened anywhere — it is the SHRINK that gained a threshold, never the cap.
  What the review pass caught is again the more interesting half, and both blockers were inside
  the fix. **(a)** `expect_warn` had never checked that a warning was printed — it asserted exit
  0 and a substring, and a substring can be an `ok` line. Turning the soft-cap `warn` into an
  `ok` left the whole suite green. That is not a general nicety: the new edit branch is safe
  ONLY because the size warning stays armed and the compression stays owed, so the single
  property justifying the branch was the one property nothing verified. **Generalisation: an
  assertion named for a condition must assert that condition, or the name is the only place it
  exists.** **(b)** The fixture greps shared a phrase both failing branches emit, so rewriting
  one branch in the other's words kept the suite green — a fixture that cannot tell which
  branch fired is not testing the branch split at all. Also fixed from the same pass: the
  delta's plumbing was exercised by nothing (every fixture conf set the key, so deleting the
  script's default left the suite green while an adopter on an existing `amh.conf` would have
  hit an unbound variable under `set -u` and aborted the ladder mid-run); a malformed delta
  fell through to the failing branch while printing numbers that contradicted its own verdict,
  and now warns and falls back; the fixture size helper appended a FIXED 18 KB of filler before
  truncating, so any future request past that would have silently asserted against a size it
  never got — `head -c` short of its request exits 0 (D-024's shape, in the helper written to
  satisfy D-024); and every landing verdict now prints BYTES, because integer KB rounding made
  the honest outcomes read as contradictions ("landed at 8 KB (floor 9 KB)" for a passing
  9215-byte landing, which an agent could answer by padding the file back — the very move this
  row exists to stop). Branch 1 deliberately consults no size and its wording no longer claims
  a classification the guard did not make.
- D-028: **The toolchain bootstrap, and a fixture whose "offline by construction" PATH was
  neither.** `scripts/bootstrap.sh` now exists and closes D-026's local-invisibility cost for
  every remote session: it installs `shellcheck` to `~/.local/bin`, persists that directory to
  `~/.bashrc` behind a marker so a container booting twenty sessions ends with one block, and
  starts the `origin/<default>` fetch that `guard_poison_tokens` needs in the background (P14).
  It is repo-local and deliberately NOT shipped — `session-start.sh` is the agent-neutral boot
  sequence and this is the hook it leaves for a toolchain, so shipping ours would ship an
  opinion about an adopter's stack. Non-fatal throughout: every failure exits non-zero, which
  `session-start.sh` renders as a warning, because a boot hook that kills the session is worse
  than one that skips a tool — and a hook that skips SILENTLY is worse than both (D-019).
  **The blocker was in the fixture, for the fifteenth unit running.** The new suite built its
  shellcheck-free PATH by SUBTRACTING every `$PATH` directory holding a `shellcheck`. On CI,
  which apt-installs it to `/usr/bin`, that deletes `/usr/bin` — and `/bin` with it, being a
  symlink to the same directory — leaving a PATH with no `bash`, `curl`, `tar`, `git` or
  `grep`; all seven new cases died at exit 127 and the push would have been red on arrival. It
  was green here only because this box keeps `shellcheck` in a directory holding nothing else
  the script needs, which is a property of the box and not of the fixture. Now CONSTRUCTED: one
  directory of symlinks to the tools the script uses and, by construction, nothing named
  `shellcheck`. **Generalisation: a fixture that subtracts from the ambient environment inherits
  it; only one that builds its environment can claim "by construction" (D-024).**
  Four more from the same pass, three of them about a step that reported work it had not done.
  `warm_up` announced the background fetch unconditionally, after redirections that could fail —
  with an unwritable log directory the fetch never started and the line still said it was in
  flight; the log is now opened where the failure can be reported, and every branch says which
  one it took. The warm-up had ZERO coverage (`snapshot` creates no remote, so every case took
  the early return and replacing the whole function with `:` left the suite green); it is now
  exercised against a bare repository on the local filesystem. The install path needs `curl`,
  which is outside the baseline toolchain `AGENTS.md` names, so those cases are gated on it,
  LOUDLY and with a count — while the curl-free branch, which was pure assumption, gained a
  fixture of its own. And the staging file was a fixed name under `$BIN_DIR`, so two bootstraps
  racing on one `$HOME` had the loser report a failure for an install that had succeeded; the
  warm-up log had the same shape in a world-writable directory, where a fixed name is also a
  symlink someone else can pre-create. Both are PID-qualified now.
  One finding accepted rather than fixed, recorded because it will look like a gap: the
  pre-install and post-install `--version` checks cannot be separated by any fixture — deleting
  either alone leaves the suite green, and only deleting both turns it red. That is not
  laziness in the fixtures. Whenever a runnable `shellcheck` is already installed the install
  function is never called, so "a bad download must not replace a good binary" is not a state
  this script can reach. The two checks do different things — one refuses to write, the other
  verifies what was written — both are cheap, and the comment at the site now says so instead
  of claiming a rationale that does not hold.
- D-029: **The loudness rule applied to the two rungs that broke it, and an assertion helper
  that repeated D-027(a) verbatim.** D-017 B7 and B8 are closed. `session-start.sh` validated
  nothing about `REMOTE_FLAG`, so a value like `AMH-REMOTE` — plausible, matching the project's
  own naming, and permitted because `amh.conf` presents the flag as free-form — made
  `${!REMOTE_FLAG}` a bad substitution: stderr, exit 0, bootstrap never runs, output identical
  to a machine that is not remote. It now prints the whole banner and carries on; a boot hook
  that refuses to start the session over a malformed config value is worse than the skip it
  replaces. The same file gated the bootstrap on `-x`, D-019's shape exactly, and the gate is
  now PRESENCE with the script invoked through `bash` — the dependency deleted rather than
  policed, as D-019 prefers. `guard_repo_local` printed its section header only on finding a
  guard, so `rm -rf scripts/guards` produced no header, no line and no count, and the ladder
  stayed green: a rung that had vanished was indistinguishable from five guards that passed.
  Header unconditional now, count always stated, absence a `skip` — an adopter with no
  repo-local guards is not in error, the silence was.
  **The blocker was in the new fixture helper, and it was D-027(a) word for word.**
  `expect_pass_saying` asserted exit 0 plus a bare substring and nothing about the line's
  verdict word — so demoting both new `skip` calls to `ok` left the suite 42/42 green while the
  rung rendered an empty extension point exactly like one that had done work. That is the
  entire property the unit exists to establish, verified by nothing, in a helper written after
  the row recording that `expect_warn` had the same hole. The fix is at the call sites rather
  than in the helper, because its three callers legitimately want different verdicts: the
  pattern must now include `   skip  ` or `   ok    `, and the discipline is the caller's.
  **Generalisation, one turn past D-027: a helper that cannot express the property is not an
  excuse for asserting less — push the property to the caller and make it mandatory there.**
  Also from the pass: the invalid-flag fixture built a bootstrap that announces itself and then
  never checked it had stayed quiet, so the banner printing AND the bootstrap running anyway
  was green; the unconditional section header had no fixture of its own; and `[ -f "$g" ]`
  alone dropped a broken symlink or a directory whose name ends in .sh, after which the count line
  claimed the directory held no `*.sh` — not silence this time but an affirmative false, the
  same defect one level inside its own fix. Entries the glob matches are counted and named now,
  and `scripts/guards` existing as a regular file no longer reports itself as absent.
  Checked and clean, do not re-check: the `case $REMOTE_FLAG in` validation across 16 probed
  values (hyphen, empty, leading digit, space, `*`, `?`, `[abc]`, `A]B`, `a$b`, UTF-8, `!`,
  `PATH`, valid-but-unset, `_`) — no quoting or bracket-expression hazard.
- D-030: **A citation is a promise that the ID resolves, so a shipped script must not make
  one.** D-023 is closed, and closed by RETRACTING the previous fix rather than extending it.
  The shipped scripts carried `D-NNN` comments naming this repository's ledger rows — D-007 ×5
  in `command-guard.sh`, D-004 ×2 and D-019 ×2 in `ladder.sh`, D-004 ×1 in `redact.sh` — and
  those rows are ours and can never exist in an adopter's ledger, so an adopter's very first
  ladder run failed on rows they could not have written. The earlier repair excluded the
  shipped scripts in the shipped `amh.conf.example`, and that was the wrong half: `amh.conf` is
  the adopter's forever and this harness cannot upgrade it, so shipping the longer exclusion
  list would have turned every EXISTING adopter's ladder red until they hand-edited a file they
  were told they own. A fix that requires the person you broke to repair it by hand is not a
  fix. The tokens are gone instead; the reasoning prose stays, and each row is named as
  `AMH ledger row DNNN`, which the citation regex (`D[A-Z]?-[0-9]+`) does not match, so a
  harness maintainer can still find it. Each shipped script says in its header why the
  references are written that way, so the next editor does not helpfully "fix" them back.
  **Accepted cost, owner-approved and paid in this unit:** D-004 and D-007 lose their `[cited]`
  markers and the both-directions check that came with them, dropped here because a stale
  marker fails the ladder. D-019 keeps its — `path-refs.sh`, a repo-local guard, still cites
  it, and the guard is the authority, not the prose. Both demarked rows now carry a note saying
  which shipped files lean on them, because the marker existed to warn a future editor and
  nothing else does that job.
  The review pass found no blocker, which is the first time in seventeen units, and it is worth
  saying why: it did the thing D-023 exists to record. It instantiated a fresh adopter with
  `amh-init.sh` and ran that repo's FULL ladder — `0 citation(s) resolve; markers in sync`, no
  hand-editing — then proved the property is guarded by planting a `D-004` in `redact.sh` and
  watching `test-init-e2e.sh` go red with the adopter's original error. **The first run of a
  path is still worth more than any amount of reading it.** What it did catch was prose:
  D-022's clause (c) asserted "the shipped `ladder.sh` already cites D-004 this way", true when
  written and false now, so it gained a correction pointer; the `[cited]` preamble warns that
  deleting a code comment to strip a marker is evading the warning, which is exactly what this
  unit does and is right to do, so the preamble gained its one carve-out; and both the config
  comment and the CHANGELOG entry had grown nine lines narrating a rejected fix no adopter ever
  received, permanently, in files the harness cannot upgrade. **Generalisation: an
  un-upgradeable artifact is the wrong place to explain yourself — say what is true now.**
