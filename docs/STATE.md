# STATE — project state & session memory

> **Length guard (hysteresis).** Grow freely to **14 KB**; over it, ONE deep pass to **≤ 9
> KB** — never to just under the cap, or the warning re-arms next session; the band IS the
> debounce. Fail above **16 KB**. Compress by folding completed stages into Changelog lines
> and moving durable gotchas to the ledger, not by cutting text into a new file. The ladder
> checks the caps, the landing, and that `## Project` / `## Current state` / `## Changelog`
> exist and are non-empty; it only *warns* if `## Owner queue` vanishes. Nothing judges
> whether what survived is any good. Never drop an open owner-queue item.

## Project

The AMH meta-repository: both the **source of truth** for the Agentic Maintenance Harness — a
reusable operating prompt plus scaffolds for repos maintained by agentic AI sessions — and its
**reference instance**, maintained under the harness and running byte-identical copies of the
scripts it ships.

- The distributed product lives in `harness/` (prose source, templates, generated bundle).
- This repo's own instance is `AGENTS.md` + `docs/` + `scripts/` + `amh.conf`.
- Adopted harness version: **AMH 1.8.0** (see `harness/VERSION`).

## Current state

> **Session handoff (2026-07-26).** Work is on
> `claude/owner-queue-attestation-fixes-8yq4br`, the tip of the branch train (main ←
> `...-tb2myi` ← `...-der6bl` ← `...-guh973` ← `...-guzkor` ← here); `amh.conf` says
> `branch-train` by owner decision. **All five repair units are shipped.** What is left is
> the unbuilt half of U5/U6 and the unscoped findings below — not a defect list. The build
> plan is at `docs/plans/amh-meta-repository.md`, stale by design about U6.

Founding build (`claude/amh-meta-repository-tb2myi`): **U1–U4 done**. Still open from the
plan:

- **U5** — the release workflow; and the review's prose corrections need mirroring into
  `harness/templates/seed/` and `harness/src/` (they landed in this repo's instance first).
- **U6** — `README.md` is still the 5-byte stub the plan's own Context describes as the
  *starting* condition, so U6's README was never written; and the planned end-to-end init
  test does not exist, so instantiation is verified only by hand.

**Repair units — all 5 shipped** (D-016, D-017; see the Changelog and **D-019**…**D-025**).
Each took ONE fresh-context reviewer, blocking, one pass (D-015): triage, apply, ship, no
re-review — spawning it is required, not a thing to ask about. **Every one of the five had its
blocker inside the fix, not in the original defect.** Budget for that.

## Owner queue

> **Protected section.** Never delete it, and never silently drop items during compression.
> Items leave only when done, answered or triaged — then delete the item and record the
> outcome as a Changelog line or a ledger row. Every session's final chat message restates
> this queue.

**Pending owner actions:**

1. Tag `amh-v1.8.0` once the founding branch is merged — an owner step. The release workflow
   does not exist yet, so the tag triggers nothing today.
2. **Merge the train as ONE squash PR** whose body describes the net `origin/main..HEAD` diff,
   not the last branch's. No PR template exists yet — `.github/` holds only `workflows/`.

**Open questions:**

1. [2026-07-25] **D-005** — founding legislation installed with no fresh-context reviewer.
   Both authorised passes have now run: prose (applied) and scripts/templates (**D-017**).
   Close D-005 on your read at merge.
2. [2026-07-25] The P3 reword (**D-014**) landed **self-reviewed**, at your direction to work
   without a subagent. Your read at merge is its only outside look.
3. [2026-07-25] **The one-pass rule is Goodhart-open** (D-018): "split the unit" lets a session
   relabel a corrected diff as a new unit and claim a fresh pass. No mechanical definition of a
   unit exists. Your call whether to bound it or accept it as prose-only.

**Open findings.** Every finding that had a unit is fixed; **D-016** and **D-017** carry the
corrections and should not be re-investigated. **Unscoped, still open:**

- **B7** — `session-start.sh` skips the toolchain bootstrap when `REMOTE_FLAG` is not a shell
  identifier. Narrowed at the source (`amh-init.sh` refuses to write such a value), not fixed.
- **B8** — `rm -rf scripts/guards` leaves the ladder green with no output at all.
- **D-016 item 11** — the STATE landing check cannot tell a typo fix from a compression pass
  above the soft cap. Do **not** fix by widening the band; that reopens D-011.
- **D-022** — two deliberately deferred redaction gaps: colon-less URL userinfo (the Azure
  DevOps PAT clone URL) is missed, and `ASIA` + 16 uppercase characters redacts an ordinary
  identifier.
- **D-023, mitigated not resolved** — a `D-NNN` citation inside a SHIPPED script resolves
  against the *adopter's* ledger, where the row cannot exist; it made an adopter's first run
  red. The shipped `amh.conf.example` now excludes those scripts from the citation scan.
  Whether shipped code should cite this ledger at all decides fix vs. plaster.
- **D-025** — nothing binds `INIT_PLACEHOLDERS` in `amh-init.sh` to the `init` rows of
  `harness/PLACEHOLDERS.md`; they agree today, and a new template placeholder would diverge
  silently.

## Decided non-items (don't re-litigate without new evidence)

- **Rendering scripts from placeholder templates.** Declined: the shipped scripts read
  `amh.conf` at runtime, which deletes the rendered-vs-template drift class instead of
  policing it (D-002).
- **Doc-fact guards (P20), and a markdown link checker. Both OVERTURNED the same day** — the
  rule review found five drifted claims (D-010) and three dangling references shipped within
  the day, one making a playbook unfollowable. `version-lockstep.sh` and `path-refs.sh` are
  the narrow forms admitted. Resolving bare filenames *from the repo root* was tried and
  rejected (24 hits, 2 true positives); by **basename anywhere in the tree** is what works
  (D-023). The incident bar stands: no guard for a claim that has not yet rotted.
- **Section-granular `RULE_FILES`.** Declined: the tripwire is file-granular, so `STATE.md`
  and `LEDGER.md` stay out (warn fatigue kills tripwires) and `RUNBOOK.md` stays in
  wholesale. This is the tripwire's scope, never the protocol's.
- **Self-reported checklists in commits or YAML.** Declined permanently (P3); scope clarified
  by D-014 — the ban is on *machinery* consuming a self-report, not on a commit-body sentence
  a human reads and may disbelieve.

## Changelog

One line per shipped change or completed unit (newest first). Details live in the cited ledger
rows and in git history.

- 2026-07-26 — **Repair units 4 and 5: the redaction filter and the adopter path.**
  `redact.sh` matches the shapes actually in circulation (`sk-proj-` and siblings, `ASIA`,
  `glpat-`, `hf_`, Bearer headers, URL userinfo) and no class can print a token's tail; the
  load-bearing fix is a self-test comparing the filtered line **exactly**, which is what makes
  partial redaction visible at all. `CONTRIBUTING.md` and `scripts/amh-init.sh` exist, so
  playbook 5 is followable, and `path-refs.sh` resolves bare filenames by basename anywhere in
  the tree. Instantiating a scratch repo for the first time found the real defect: an
  adopter's first ladder run failed on ledger rows only this repo can have. Seed `verify.sh`
  ships executable. D-017 B5/B6, B11, B13 — **D-022**, **D-023**, **D-025**.
- 2026-07-26 — **A flaky fixture inside the secret scan, caught by CI.** The Bearer class
  required a digit in a randomly-generated token, so ~1 run in 140 failed and the ladder went
  red at random — about one push in five, and the local greens before it were luck, not
  verification. The predicate was then wrong twice more: no length separates a word from a
  token, and neither does one capital. **D-024.**
- 2026-07-26 — **Server-side rails complete** (owner): branch protection on `main` plus
  **secret-scanning push protection**, closing P13's server-side half. Recorded here because
  the queue item was deleted in `38c809a` with no outcome written down — the one thing the
  protected section forbids.
- 2026-07-26 — **CI green for the first time in this repo's history** (run 14; runs 1–13 all
  failed on shellcheck info notices in our own scripts). Fixed in the scripts, with
  `verify.sh` left as strict as it was; `actions/checkout@v5` in the workflow and the shipped
  template. The review pass caught the fix widening two lint waivers to whole compound
  commands. D-016 items 8–9, **D-021**.
- 2026-07-26 — **The ladder's off switch closed, and the fixture builder's blind spots.**
  `redact.sh` losing its exec bit no longer makes the secret scan vanish silently; two guards
  no longer word-split their file lists; three guards with zero coverage now fail when
  stubbed. `MERGE_MODE` set to `branch-train` by owner decision. **D-019**, **D-020**.
- 2026-07-26 — **Shipped command guard repaired**: the `<<<` here-string regression that
  voided every rail, the `<`-in-quoted-text false positive (D-007 verbatim), three
  over-blocking classes, the false "reading" reason on write destinations, `+main`/`--mirror`/
  `source .env`, and a 14s → 0.87s fix at 32 KB. D-016 items 1–7, D-017 B12.
- 2026-07-25 — **Founding day.** U1–U4 (self-hosting core, legislation, adopter templates,
  harness prose + bundle); the rule review applied (14 findings, 13 fixed — new
  `version-lockstep.sh`, `path-refs.sh`, repo-local fixtures); env-dump rails closed in
  `command-guard.sh`, **which shipped with a regression (D-016)**; the P3/P12 attestation
  contradiction resolved by the owner; MIT `LICENSE`, (c) faded-penguin021.
  **D-001**…**D-014.**
