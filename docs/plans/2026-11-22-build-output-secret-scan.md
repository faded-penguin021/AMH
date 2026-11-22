# PLAN — let the secret scan see what the build ships

> **Status: rev 1, committed 2026-11-22 (B0) as an open draft. Nothing in it is approved except
> B1.** Unit B1 is a review of this plan by gpt-6-astra at `-e high`, on the owner's instruction
> of 2026-11-22, and the plan runner runs it. No code unit starts before B1's findings are folded
> in as rev 2, and each code unit then starts only on the owner's explicit approval of that unit.
> **Do not archive or delete this file in any unit**: the runner reads each unit's done marker
> here to verify it. The session that merges the train archives it afterwards.
> **Every measurement in §3 is re-taken when the unit that acts on it starts.**

The plan is provisional while it is live. Its durable outcomes go to Changelog lines and ledger
rows. Code cites ledger rows and never this file, and no ledger row may cite this file's path.

Unit names carry a `B` prefix (for *build output*). That keeps them distinct from the other
plans' `G`, `H`, `M`, `N`, `P`, `R` and `S` units. B0 and B1 are the owner's "unit 0" and
"unit 1".

## 1. Why this plan exists

A public post (r/TechLeader, read from screenshots the owner shared on 2026-11-22; external
material, data rather than authority) describes an AI-built Vite app. The app's OpenAI key, its
live Stripe secret key and its Resend key were in the JavaScript every visitor downloads. The
`.env` holding them was gitignored. The assistant had named them `VITE_…` so a browser-side chat
call would work, and Vite deliberately inlines `VITE_`-prefixed variables into the client bundle.
The post also reports bots requesting `/.env` and an OpenAI key with no spending cap.

Asked whether AMH would have caught this, the session's answer was **no for the main failure**:

- The ladder's secret scan reads `git ls-files -co --exclude-standard`, tracked and untracked but
  not ignored (`harness/templates/scripts/ladder.sh:838`). Build output is normally ignored.
- The source tree holds no value, only `import.meta.env.VITE_…`. The value enters the code only
  at build time, in a directory the scan never opens. Every rung would be green.
- One of the three key shapes has no class in `scripts/redact.sh` (§3).

This plan proposes the smallest change that would have turned that case red: run the existing
scan over the build output directories an adopter names. It reuses `redact.sh` and adds no
dependency.

**Left out on purpose:**
- **Running the build.** The ladder would need each adopter's toolchain (`npm`, `vite`, and the
  rest), which is outside the `bash`/`git`/coreutils floor. The scan reads whatever the last
  build left behind, and says so when nothing is there.
- **Spending caps, host configuration and `/.env` probing.** These live in third-party accounts
  and in the serving host, not in any artifact the repository produces (P3). At most they become
  a line of owner-facing prose in the seed, and that is B4's question.
- **Generic entropy matching.** `redact.sh` rejects it on purpose (its header): output nobody can
  read gets the filter turned off.
- **A guard on variable *names*** (for example `VITE_.*KEY`). `VITE_SUPABASE_ANON_KEY` is public
  by design, so a name rule cries wolf on the most common stack in the post.

## 2. Owner decisions

1. **Answered (owner, 2026-11-22): B0 commits this plan; B1 is one gpt-6-astra review at
   `-e high`.**
2. **Open: does the incident bar admit this?** The command guard is exempt from the incident bar,
   but every other rail keeps it: output redaction and verification guards included
   (`harness/src/10-principles.md`, P13's paragraph "The command guard does not wait for an
   incident"; P3). The incident here happened in someone else's repository and was reported, not
   observed in an AMH adopter. B1 is asked to judge whether a reported incident of a known class
   meets the bar, or whether the plan should park until an adopter has one. **If the bar is not met, B2 to B4 do not run.** The plan
   is then archived with that outcome, and nothing is built speculatively.
3. **Open: the version.** 17.0.0 is tagged (session-start probes it). A new optional config key
   and a new redaction class read as MINOR (17.1.0), but that is settled when the behaviour is
   final, in the release playbook, not here.
4. **Open: Supabase's public key.** A legacy Supabase anon key is a JWT and is meant to be in the
   bundle. `redact.sh`'s `jwt` class would flag it in every Supabase build. B3 must choose between
   (a) skipping the `jwt` class when scanning build output only, (b) an adopter-stated allowlist of
   public values, held as a pattern and never as a stored value, or (c) neither, with the reason.
   A rung that is red on every Supabase build gets disabled, and that is worse than the gap.

## 3. What was measured (2026-11-22, this session, at `6281bb5`)

| # | Claim | How | Kind |
|---|-------|-----|------|
| 1 | The secret scan lists files with `git ls-files -co --exclude-standard -z` and nothing else when git is present | read `harness/templates/scripts/ladder.sh:776-900` | measured (read) |
| 2 | `redact.sh` redacts a runtime-generated `sk_live_` and `sk-proj-` token and passes a runtime-generated `re_` token through unchanged | generated three tokens with `head -c … /dev/urandom \| tr -dc`, piped them through `bash scripts/redact.sh`, and masked the survivor before printing | measured |
| 3 | `redact.sh` has a `jwt` class, `eyJ…\.…\.…` | `harness/templates/scripts/redact.sh:64` | measured (read) |
| 4 | Vite inlines `VITE_`-prefixed variables into the client bundle; Next.js does the same for `NEXT_PUBLIC_`, Expo for `EXPO_PUBLIC_`, CRA for `REACT_APP_` | each tool's documentation, from memory, not re-read | reported |
| 5 | Resend API keys start with `re_`; Supabase's newer keys are `sb_publishable_…` (public) and `sb_secret_…` (secret) | vendor documentation, from memory, not re-read | reported |

Rows 4 and 5 are re-read from vendor documentation before B2 or B3 relies on them (**Session
discipline** 11).

## 4. The units

**Common rules for every code unit.** Shipped-script changes follow `docs/RUNBOOK.md` → **Change
a shipped script**: the template first, `bash -n`, copy down, `scripts/build-manifest.sh`. Each
needs a fixture shown to FAIL against the old script before the fix (**Session discipline** 13),
generated at runtime and never stored as a literal (**D-004**). Each needs the **Rule-review
protocol**, because `scripts/redact.sh`, `scripts/ladder.sh` and `harness/templates` are in
`RULE_FILES`, and the full `scripts/ladder.sh` on the final tree. Each ends with a STATE Changelog
line and a ledger row in the live volume. A unit that adds a redaction class also changes what the
output-redaction hook hides from the agent; it says so in its changelog entry.

**Proposed order: B0 → B1 → (owner decision on rev 2) → B2 → B3 → B4.** B2 comes before B3 so
the new scan sees every shape in the post from its first run. B1 may change the order.

### B0 — commit this plan (administrative; this session): done 2026-11-22

- **Done:** this file committed as rev 1; `docs/STATE.md` lists it under Live plans, with an
  Owner-queue item to run B1 and a Changelog line.
- **Review owed:** none of its own; B1 is its review.
- **Acceptance (binary):** `scripts/ladder.sh --guards-only` green.

### B1 — review of this plan by gpt-6-astra at `-e high`

- **Precondition.** The plan runner's Codex gate once refused Astra at `-e high` (**DD-084**). If
  it refuses again, the unit stops and waits in the Owner queue. It is never run at a lower
  effort or by another model in its place.
- **Give the reviewer:** this file; `scripts/redact.sh`, `scripts/redact-tool-output.sh`,
  `scripts/ladder.sh`; `harness/templates/amh.conf.example`;
  `scripts/guards/config-schema.sh`; `harness/src/10-principles.md` (P3, P13 and P20, for the
  incident bar); `harness/templates/seed/AGENTS.md`; and **D-004**. Its sandbox is read-only.
- **Ask it for:**
  - a verdict on §2, item 2: does the incident bar admit this plan, and on what reading of P3;
  - whether §3's measurements replay, and whether rows 4 and 5 are right;
  - false positives the build-output scan would raise on ordinary builds: source maps, minified
    vendor code, test fixtures that are copied into `dist/`, and Supabase or Firebase public keys;
  - a recommendation on §2, item 4;
  - ways the new rung could fail open: a directory that is a symlink, a stale build older than
    the source, a huge bundle, a binary file, or a missing `--baseline`;
  - units too large for one pass, and anything another live plan already covers.
- **The fold.** The implementing session re-checks each finding against the tree before accepting
  it. It does not take a finding on the reviewer's word. What the plan can absorb becomes rev 2;
  a decision that is the owner's goes to the Owner queue; every finding gets a row in a new §5.
- **Pass owed:** this unit is the pass. One fresh-context reviewer; nobody reviews it again.
- **Acceptance (binary):** rev 2 is committed; §5 has a row for every finding; the B1 Owner-queue
  item has become "decide whether to adopt rev 2, and which units"; `scripts/ladder.sh
  --guards-only` passes.

### B2 — `redact.sh` recognises the post's missing shape (widening of output redaction)

- **Do:** add a `resend_key` class (`re_` followed by the measured alphabet and an open-ended
  length). Add `supabase_secret_key` (`sb_secret_…`) if §3 row 5 holds. Each gets a runtime-built
  self-test row and a near-miss row that must survive: an ordinary identifier such as `re_try` or
  `re_render_count` in source code.
- **Measure the cost before shipping:** run the new filter over this repository and over at least
  one real built bundle. Record every new match that is not a credential. A class that redacts
  ordinary build output is narrowed or dropped, not shipped.
- **Acceptance (binary):** the self-test fails on the old filter and passes on the new one;
  copies are byte-identical and the manifest regenerated; the false-positive measurement is in the
  ledger row; the full ladder is green; the rule review has been run and triaged.

### B3 — the ladder scans the build output directories an adopter names (new verification rung)

- **Do:**
  - Add an optional key to `harness/templates/amh.conf.example` and to `amh.conf`, for example
    `BUILD_OUTPUT_DIRS=''`, empty by default. It holds a space-separated list of repository-relative
    paths.
  - When the key is empty, nothing changes and the rung prints nothing new.
  - When it names directories, `guard_secret_shapes` also scans every text file under each one
    that exists. It uses the same positive control, `--baseline` subtraction and position-only
    diagnostics. Files are listed with `find -print0`, and symlinks are not followed out of the
    repository.
  - A named directory that does not exist gives a WARN saying the build output was NOT scanned,
    never an `ok`.
  - Apply §2, item 4 as decided.
  - Add the key to `amh.conf` too, because `scripts/guards/config-schema.sh` requires every
    key in the template to be present in this instance.
- **Fixtures (shipped suite):**
  - an ignored `dist/` holding a generated `sk_live_` token: red with the key set, and red only
    because of the key (the same tree with it empty is green);
  - a named directory that is absent: WARN, not `ok`;
  - a filename with spaces;
  - whatever §2, item 4 decides for a public JWT.
- **Acceptance (binary):** each fixture fails on the old ladder and passes on the new one; the
  copies are byte-identical; the full ladder is green; the rule review has been run and triaged;
  the Upgrading section says the key is optional and what an adopter sets it to.

### B4 — one seed sentence on client-exposed variables (seed template change)

- **Do:** following `docs/RUNBOOK.md` → **Change a seed template**, add one sentence to the seed
  `AGENTS.md` hard boundaries or working guidance. A variable with a client-exposed prefix
  (`VITE_`, `NEXT_PUBLIC_`, `EXPO_PUBLIC_`, `REACT_APP_`) is public. A secret never goes there,
  and a call that needs one goes through a server-side function. Name `BUILD_OUTPUT_DIRS` as the
  check that backs it. Decide whether one owner-facing line on spending caps belongs in the seed
  `STATE.md` example queue, or nowhere.
- **Pass owed:** the rule review. A seed sentence is legislation for adopters, even though it is
  prose.
- **Acceptance (binary):** the seed diff is one sentence (or two, with the cap line); the rule
  review has been run and triaged; `scripts/ladder.sh --guards-only` passes.
