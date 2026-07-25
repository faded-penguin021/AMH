# STATE — project state & session memory

> **Length guard (read before editing — hysteresis).** Grow freely to **14 KB**; no trimming
> below that line. When the guard warns, run ONE deep compression pass to **≤ 9 KB** — never
> trim to just under the threshold (micro-trims re-arm the warning a session later; the wide
> band IS the debounce). Fail above **16 KB**. Compression means: collapse each completed
> work stage into one Changelog line, fold changelog clusters, move any durable gotcha into
> the append-only ledger, delete narrative prose.
>
> **What the ladder actually enforces**, so nobody mistakes prose for a gate: it fails over
> 16 KB; it fails a trim that starts above 14 KB and stops above the 9 KB floor (in either
> direction — crossing the cap or not); it fails if **`## Project`**, **`## Current state`**
> or **`## Changelog`** is missing *or emptied of content*; and it **warns only** if
> `## Owner queue` disappears, because closing the owner's items is the owner's call, not a
> build failure. Everything else here is prose: nothing detects a 13 KB → 5 KB trim, nothing
> can tell real compression from cutting 6 KB out into a new file, and no guard judges
> whether what survived is any good. Owner-queue items are the owner's to close — compress
> their prose, never drop an open item.

## Project

The AMH meta-repository. It is both the **source of truth** for the Agentic Maintenance
Harness — a reusable operating prompt plus scaffolds for repos maintained by agentic AI
sessions — and its **reference instance**: this repo is itself maintained under the harness,
running byte-identical copies of the scripts it ships.

- The distributed product lives in `harness/` (prose source, templates, generated bundle).
- This repo's own instance is `AGENTS.md` + `docs/` + `scripts/` + `amh.conf`.
- Adopted harness version: **AMH 1.8.0** (see `harness/VERSION`).

## Current state

> **Session handoff (2026-07-25).** Work continues on `claude/owner-queue-attestation-der6bl`,
> which is stacked on the founding branch — the topology is a **branch train**, not the
> `branch-per-change` that `amh.conf` still declares (see Owner queue). Pushed and green
> through commit `a98b462`. **Two things are known-broken and neither is fixed:** the shipped
> command guard has a rail-voiding regression, and CI has never passed. Both are itemised
> under **Incoming findings** — read them before starting any new unit; they are the next
> unit's scope. One codification diff was uncommitted and awaiting a fresh-context pass at
> handoff; if `D-015` is absent from `docs/LEDGER.md`, that diff died with the session and must
> be rewritten. Its whole content, so it is recoverable from here: the rule-review protocol
> gains **three bounds** — *concurrency* (one reviewer at a time, blocking: already had it),
> *iteration* (**ONE pass per unit** — triage findings, apply, ship; never re-review the
> corrected diff, because that turns a gate into a loop that launders a diff into looking
> approved; fixes too large to ship unreviewed mean the unit was too big), and *depth* (nobody
> reviews the reviewer: already had it). Plus two clauses from live friction: spawning the
> reviewer is what the protocol requires and is **not** a permission to ask for each time, and
> a green-but-unreviewed legislation diff is **held** against a harness commit prompt — said
> once, not re-explained every turn. Goes in `docs/RUNBOOK.md`, `harness/src/10-principles.md`
> (P12), and `harness/templates/seed/docs/RUNBOOK.md`, then rebuild the bundle.

Founding build (`claude/amh-meta-repository-tb2myi`): **U1–U4 done** — self-hosting core,
legislation, adopter templates, harness prose + generated bundle.

- [~] **U5 — Version, changelog, upgrade path.** `VERSION`, `CHANGELOG`, `UPGRADING`,
      `version-lockstep.sh`, MIT `LICENSE` in. Open: the tag-triggered release workflow, and
      mirroring the review's prose corrections into `harness/templates/seed/**` and
      `harness/src/**` (they landed in this repo's instance first).
- [ ] **U6 — README, CONTRIBUTING, `amh-init.sh`, end-to-end test.**
- [ ] **Next unit — fix what is broken.** Incoming findings 1–10 below, in that order.

## Owner queue

> **Protected section.** Never delete it, and never silently drop items during compression.
> Items leave only when done, answered or triaged — then delete the item and record the
> outcome as a Changelog line or a ledger row. Every session's final chat message restates
> this queue.

**Pending owner actions:**

1. Enable **secret-scanning push protection** on the repo (Settings → Code security). Branch
   protection on `main` is done. Push protection is worth enabling even though this codebase
   ships no keys: it binds every actor and every tool, and the risk it covers is a session
   *environment* credential pasted into a file or a log excerpt, not a checked-in key. No
   custom patterns are needed — the default provider-token set is the whole ask, and it costs
   nothing to leave on. (AMH P13: agent-side rails bind only agents that load them.)
2. Tag `amh-v1.8.0` once the founding branch is merged — tagging stays an owner step. The
   release workflow is not built yet, so today the tag triggers nothing; once it exists,
   pushing the tag is the whole step and it refuses a tag that disagrees with
   `harness/VERSION`.
3. **Merge mode is misdeclared.** `amh.conf` says `MERGE_MODE=branch-per-change`, but
   `claude/owner-queue-attestation-der6bl` was cut from the founding branch and contains it
   whole — that is P13 mode (b), **branch-train**. Under a train only the final superset
   branch merges, in ONE squash PR whose body must describe the net `origin/main..HEAD` diff
   (all 9+ commits), not just the last session's. You asked for the PR to cover the whole
   train; that is consistent with the train, so the config is what is wrong. Decide: switch
   `MERGE_MODE` to `branch-train` (changing a value in `RULE_FILES`, so it is a rule change),
   or merge the founding branch first and keep per-change. No PR template exists yet either —
   `.github/` holds only `workflows/`.

**Open questions:**

1. [2026-07-25] Founding units U1–U2 installed this repo's legislation with no fresh-context
   reviewer, since there was no prior constitution to review against (D-005). The rule-review
   pass you authorised covered **the constitution and this runbook only** — not the
   ladder/rails scripts and not the templates or the generated bundle, which have had no
   hostile read. **Recommendation:** close D-005 on your read at merge for the prose that was
   reviewed, and treat a scripts/templates pass as a separate unit to authorise (or decline)
   when you choose.
2. [2026-07-25] The P3 reword below (D-014) is a binding-rule diff, and the rule-review
   protocol has no self-review fallback: it goes to a fresh context, or it parks for you. You
   directed this session to do it without a subagent, so it landed **self-reviewed** — the
   protocol's own exit, since a standing instruction is a policy you can set, not a capability
   limit. Flagging it because the diff changes a principle and I authored it: your read at
   merge is the only outside look it gets. No answer needed unless you want it re-reviewed.

**Incoming findings:** (the next unit's scope — all confirmed, none fixed)

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
   on Node 24. Bump to `@v5` in `.github/workflows/ladder.yml` **and** in
   `harness/templates/configs/ci.yml` — adopters inherit the pin.
10. **Fixture gaps behind all of the above.** Every "name merely contains a secret word"
    allowed-fixture puts the benign word last, so they pass by construction; none tests a
    benign name *ending* in `_KEY`/`_TOKEN`. No fixture covers `<` in quoted text, `<<<`,
    `${VAR:+…}`, or `cp x .env`. The blocked side is honest (all 20 fail against the old
    script). A duplicate `st_allowed 'grep -rn "force-push" docs/RUNBOOK.md'` appears twice.

## Decided non-items (don't re-litigate without new evidence)

- **2026-07-25 — Rendering scripts from placeholder templates.** Declined. The shipped
  scripts read `amh.conf` at runtime instead, which deletes the rendered-vs-template drift
  class entirely rather than policing it. See D-002.
- **2026-07-25 — Doc-fact guards (AMH P20) for this repo's prose. OVERTURNED same day.**
  Declined on the grounds that no claim had drifted; the rule review then found five that
  had (D-010). P20's incident bar is met, so `version-lockstep.sh` and `path-refs.sh` are
  admitted. The bar itself stands: still no guard for a claim that has not yet rotted.
- **2026-07-25 — A markdown link checker in the ladder. OVERTURNED same day.** Declined on
  "no broken link has cost anything yet"; three dangling references were shipped within the
  day, one of which made a playbook unfollowable. `path-refs.sh` is the narrow form: repo-
  relative paths only, no network, no flake surface. Widening it to bare filenames was tried
  and rejected — 24 hits for 2 true positives would train everyone to ignore it.
- **2026-07-25 — Section-granular `RULE_FILES`.** Declined: the tripwire is file-granular, so
  `docs/STATE.md` and `docs/LEDGER.md` stay out (they change nearly every unit; warn fatigue
  kills tripwires) and `docs/RUNBOOK.md` stays in wholesale, accepting that operational
  playbook fixes trip it. Building section-granularity is machinery in service of a warning.
- **2026-07-25 — Self-reported checklists in commits or YAML.** Declined permanently (AMH
  P3): an agent can emit an attestation without doing the work. Guards check artifacts. Scope
  clarified the same day (D-014): the ban is on *machinery* — no guard, gate, CI step or
  required field may consume a self-report — not on a commit-body sentence a human reads and
  may disbelieve. A disclosure that graduates into a gate is the thing being banned.

## Changelog

One line per shipped change or completed unit (newest first). Keep terse; details live in the
cited ledger rows and in git history.

- 2026-07-25 — **P3/P12 attestation contradiction resolved (owner: option (c)).** P3 now bans
  attestation-based *machinery* — nothing downstream may consume a self-report — and permits
  the commit-body verdict and verification disclosure as prose for a human. Mirrored into
  `AGENTS.md`, both runbooks, the seed scaffold and the rebuilt bundle. **D-014.**
- 2026-07-25 — **MIT `LICENSE`** at the repo root, © faded-penguin021 (owner's call; the
  harness is meant to be copied, and it shipped without permission to do so).
- 2026-07-25 — **Rule review, U1–U4, applied.** One fresh-context pass over the constitution
  and runbook returned 17 findings (14 confirmed); 13 fixed here, 1 escalated to the Owner
  queue, 2 accepted as documented limits. Guards: the STATE landing check now catches trims
  that never cross the cap, required sections must be non-empty, `version-lockstep.sh` and
  `path-refs.sh` are new, and repo-local guards finally have fixtures
  (`scripts/tests/local-guards.sh`). Prose: five false enforcement claims corrected.
  **D-008**…**D-013**.
- 2026-07-25 — **U4** Harness prose in `harness/src/` (overview, P0–P20, constitution,
  scaffolds, adaptation notes) and the generated single-file bundle `harness/dist/AMH.md`,
  built by `scripts/build-dist.sh` and kept honest by `dist-drift.sh`. The placeholder guard's
  live-file scope was corrected: everything under `harness/` is the product, not this repo's
  instance.
- 2026-07-25 — **U3** Adopter templates: seed scaffolds (constitution, pointer, STATE,
  RUNBOOK, LEDGER, `verify.sh`), configs carrying `{{PLACEHOLDER}}`s (Claude Code settings,
  CI workflow), `amh.conf.example`, and `harness/PLACEHOLDERS.md` with a guard that fails on
  an undocumented placeholder or one left unfilled in this repo's live tree.
- 2026-07-25 — **U2** Legislation: `AGENTS.md` (canonical constitution), `CLAUDE.md` pointer,
  `docs/RUNBOOK.md` (playbooks, session discipline, both review protocols, incident playbook),
  and `scripts/guards/copy-drift.sh` — which makes "this repo runs what it ships" checkable
  rather than aspirational. Shipped-bug classes seeding the review checklist: **D-006**,
  **D-007**, **D-008**.
- 2026-07-25 — **U1** Self-hosting core: `amh.conf`, ladder + guard fixture suite, redaction
  and command-guard rails with self-tests, session bootstrap, permission rails, CI. This repo
  now runs the harness it ships. Founding decisions in **D-001**…**D-005**.
