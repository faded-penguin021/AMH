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
- D-007 [cited]: **Matching a forbidden word anywhere in a command instead of in its argument
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
  8. **[CI, never green] The ladder has failed on every run in the repo's history — all 8.**
     The failing rung is always `shellcheck`, which `verify.sh` treats as failed on ANY output,
     including info-level notices: SC2094 (false positive at `ladder.sh:271`, `redact.sh:118` —
     both `cmp` a file against a filtered copy of itself), SC2034 (`test-ladder-guards.sh:27`
     `local name=$1` genuinely unused; a `BRANCH_PREFIX` report), SC2016 (`local-guards.sh:114`,
     intentional), SC2128/SC2178. Shellcheck is CI-only, so no local run can see it. Fix the
     scripts — do NOT narrow `verify.sh` to get green. Also: `tr: write error: Broken pipe`
     appears twice in the fixture-suite output; check it is not a silent skip.
  9. **[CI] Node 20 deprecation.** `actions/checkout@v4` targets Node 20 and is being force-run
     on Node 24. Bump to `@v5` in `.github/workflows/ci.yml` **and** in
     `harness/templates/configs/ci.yml` — adopters inherit the pin.
  11. **[repo-local guard] The STATE landing check cannot tell an edit from a compression pass.**
      Above the 14 KB soft cap, *any* shrink that does not reach the 9 KB floor fails the ladder
      — including a 3-byte typo fix. Hit live this session: correcting a wrong path in this very
      file (`ladder.yml` → `ci.yml`) turned the ladder red, and the only compliant moves were to
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
    `glpat-…`, `postgres://user:pw@host/db`, `https://user:token@host/repo.git`, `hf_…`,
    `Authorization: Bearer …`. The URL-with-userinfo shape already appears in this repo's own
    `git remote -v` output. Negative cases are clean — no false positives found.
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
