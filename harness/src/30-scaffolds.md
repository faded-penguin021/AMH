---

## Part 3 — Scaffolds

Seven files and one config directory. The prose scaffolds are **seeds**: copied once, then owned
by the adopting repo. The scripts are **artifacts**: copied verbatim, parameter-free, and
upgradeable — they read `amh.conf` at runtime, take repo-specific guards from
`scripts/guards/*.sh`, and take the verification set from `scripts/verify.sh`. That split is
what makes upgrading to a later harness version a mechanical copy for the scripts and a short
hand-applied list for the prose.

### 3.1 `amh.conf` — all repo-specific values in one place

<!-- amh:include harness/templates/amh.conf.example -->

### 3.2 `docs/STATE.md` — working memory (bounded, compressible)

Note the hysteresis band and the *landing* check. Size thresholds alone are Goodhart-able: a
micro-trim to just under the soft cap passes the guard and re-arms the warning a session later.
The guard therefore also fails a change that trims the file out of warn territory but stops
inside the debounce band instead of reaching the compression floor. Pick numbers so
warn − compress-to spans many sessions of growth and hard − warn leaves one long session of
margin — 9 / 14 / 16 KB is a working example.

Say in the file itself that the compression floor is a **ceiling, not a target**. Every phrasing
of the rule is naturally read as "land at the floor", and an agent that reads it that way will
shave words one at a time until the guard goes quiet — the micro-trim reflex the band exists to
break, reappearing one band lower and leaving no headroom for the next session. Do not add a
second threshold to enforce the aim point: it would warn on a perfectly good compression pass,
and "is 8 enough?" is a question with no answer.

The landing check judges the shrink's *size* as well as where it lands, which is why
`STATE_EDIT_DELTA_BYTES` exists. Its first form treated every byte lost above the soft cap as a
compression pass in progress, and that reading fails a three-byte typo fix: go to the floor or
revert the correction, both worse than the typo. So a shrink smaller than the delta and still
above the cap is an ordinary edit and is allowed, with the size warning left armed; one that
reaches the delta is a compression pass and must land on the floor. Set the delta in the empty
gap between the two populations — no ordinary edit runs to a kilobyte, no real compression pass
comes in under several. Widen the *delta* if your file is unusual; never widen the *band*, which
is the hole the landing check was built for.

<!-- amh:include harness/templates/seed/docs/STATE.md -->

### 3.3 `docs/RUNBOOK.md` — change-type playbooks

<!-- amh:include harness/templates/seed/docs/RUNBOOK.md -->

### 3.4 `docs/LEDGER.md` — permanent memory (append-only, rolling files)

<!-- amh:include harness/templates/seed/docs/LEDGER.md -->

### 3.5 `scripts/ladder.sh` — the one verification entrypoint

One bash script, run by both the agent and CI. Structure: fast guards (seconds, no build), then
`--guards-only` exits, then the full verification set via `scripts/verify.sh`.

The guards it ships with:

- **State length (hysteresis)** — quiet below the warn line; over it, warn with the deep
  compress-to target in the message; fail over the hard cap. Never make the warn line the
  compression target: the gap between them is the debounce. Plus the landing check described
  above, which supplies the state the size thresholds lack by comparing against the committed
  size (working tree vs HEAD, falling back to HEAD~1 for a just-committed trim). It fires only
  on a shrink from above the warn line, so growth and sub-warn edits never trip it, and it names
  the branch it took in every outcome — an unfinished pass and an ordinary edit above the cap
  look identical in the size alone, so saying which one it decided is half the guard.
- **State structure** — fail if a required section header is missing (an over-compression
  tripwire) or if it survives with no body under it; warn if the Owner-queue header vanished
  (data loss for the human). And fail on ANY repeated `## ` heading, required or not: a botched
  scripted edit duplicates the document rather than deleting from it, and every other check here
  passes a duplicate — bytes grew, which is allowed, and existence was satisfied twice over.
  Ask the question of the document, not of the configured list, or you close the one heading
  that broke and leave the class open.
- **Ledger rollover** — warn approaching the line cap; fail when the live file's LAST row
  *starts* past the cap. The final row may overflow; the next belongs in the next file.
- **Citation integrity** — grep the source trees (code and workflows, NOT docs, and not the
  guard's own fixture suite, which carries synthetic and harness-internal IDs by design and is
  what the shipped `amh.conf` excludes) for `D[A-Z]?-\d+`. The other shipped scripts stay in
  scope and need no exemption: they name the harness's own rows as `AMH ledger row DNNN`,
  deliberately not a citation, because those rows are ours and can never resolve in your ledger
  — written as citations they failed an adopter's first ladder run. The rail scripts and the
  ladder say so in their headers; do not "fix" them back, and do not narrow the fixture-suite
  exclusion to match this paragraph, or you inherit its synthetic IDs. Then:
  every citation must resolve to a row in the file its prefix names; no duplicate row
  numbers; `[cited]` markers must match the citation set in both directions.
- **Poison-token scan** — fixed strings that must never reach a commit message (CI-skip tokens
  a squash merge would fold onto the default branch), scanned over `origin/<default>..HEAD`
  before push. Because force-push is forbidden, a pushed mistake is permanent until merge.
- **Git author identity** — `%ae` and `%ce` over the same `origin/<default>..HEAD` window, in
  two unequal halves. Zero-config: fail on the identities git invents when nothing was
  configured (`root@host`, `…@localhost`, `…@host.local`, `(none)`, no `@` at all). These are
  machine names rather than addresses, which is why that half needs no list of who may commit
  — but its false-positive surface is small, not empty, and claiming empty would be the
  false-coverage move this document warns about elsewhere: `.local` is a real Active Directory
  and mDNS suffix, and a build account can legitimately be `root@` a real domain. Opt-in:
  `AUTHOR_EMAIL_ALLOW`, an extended regex matched against the whole address and **empty by
  default in the script** — a rung that needed a new `amh.conf` key would turn every existing
  adopter's ladder red until they hand-edited a file they were told they own. **Consult the
  allowlist FIRST**, so a named address is admitted whatever shape it has: that is what keeps
  the zero-config half from being a dead end an adopter can only escape by editing a shipped
  script, and its price is that a permissive pattern switches that half off. Do not use the
  repo's own history as the allowlist: a first-time contributor and a misconfigured one are
  indistinguishable, so it fails every commit of a new branch. Both fields, because a rebase
  rewrites the committer while the author survives. One arm and one message per shape, or a
  single fixture covers the lot and the other patterns can be deleted green. And say in the
  guard what it cannot do — it cannot tell a personal address from a work one, and prose that
  implies otherwise is what stops the next reader checking by hand.
- **Secret-shape tree scan** — fail if redacting any tracked or untracked text file with the
  `redact.sh` filter would change it. The scan IS the filter, so it is drift-free by
  construction. Report value-free (file and position, never the match — and test that
  property: a diagnostic that regresses to printing the line defeats the point). Pass the file
  list NUL-separated; a word-split list silently skips names with spaces or non-ASCII
  characters, which is a blocker-class hole. Text files only — binaries ride on the server-side
  push-protection layer, which fires at push; this guard is the earlier, commit-time net. One
  consequence: any fixture token in the tree must be runtime-generated, never a stored literal.
  **`redact.sh` is a hard dependency of this guard, not an optional one**: it IS the scan, so
  its absence FAILS the ladder rather than skipping, and the smallest-useful-subset path may
  not drop it while keeping this rung. Neither may its file mode decide anything — run it
  through `bash`, and prove it still works on a generated token before trusting its silence. A
  filter that is missing, empty, truncating or pass-through otherwise reports every file clean,
  which is the same hole as having no scan while looking greener than one.
- **Rail self-tests** — every mechanical rail script carries its own fixture self-test and the
  ladder runs it, so a silently regressed pattern fails the build instead of passing quietly.
  The command guard's matrix asserts both directions: forbidden commands block, and the known
  false-positive classes (quoted text naming a forbidden command; prose naming a forbidden
  path) stay allowed.
- **Repo-local guards** — `scripts/guards/*.sh`, the extension point that keeps this script
  repo-agnostic. Domain rules live there: a store changelog length cap (mind the unit — a
  "500 character" limit is codepoints, and `wc -c` overcounts multibyte text), a
  version-monotonicity check, a falsifiable doc-fact tripwire (P20).
- **Local-only advisories (WARN, skipped in CI)** — a checkpoint tripwire (code changed versus
  the default branch but the state file is not in the diff, so the changelog line is probably
  missing); a stale-branch tripwire classified mechanically with the P13 test-merge; a
  plan-orphan tripwire (a file under `docs/plans/` not referenced from the state file's active
  work, meaning a finished or pivoted plan missed its deletion step); and a rule-review
  tripwire on the uncommitted diff. The state file and the ledgers are deliberately excluded
  from that last one: they change in nearly every unit, and warn fatigue kills tripwires.

Plus `scripts/test-ladder-guards.sh`: a fixture-based regression suite for the guards
themselves, synthesising tiny repos and asserting each guard's pass, warn and fail behaviour.
Run it in CI and whenever a guard changes — and before believing a new fixture, break the guard
deliberately and confirm the fixture goes red. A fixture that passes against the broken code is
a false sense of protection, which is worse than none.

**Bootstrap the ladder as nothing but the verification commands.** Guards accrete one at a
time, each earning its place after a real violation, and each landing with a fixture test in
the same change.

### 3.6 `scripts/verify.sh` — the verification set (yours)

<!-- amh:include harness/templates/seed/scripts/verify.sh -->

### 3.7 `scripts/session-start.sh` — session bootstrap

Agent-neutral and idempotent (P14). It self-locates the repo root from its own path and keys
remote-only steps off an explicit neutral flag, never one agent's environment variables. Each
agent's adapter lives in its own dot-dir and stays THIN — wiring only, no logic. A new agent's
adapter must invoke the bootstrap at session start (or the instructions file tells hook-less
agents to run it manually), mirror the deny rails below if the agent supports permission rules,
honour the one-session-one-branch rule, and add its permission-config file to the rule-review
tripwire list. Everything behavioural stays in the shared constitution and scripts, so
switching agents rewrites nothing.

### 3.8 Permission rails — the adapter layer

- **Allow:** the ladder, the setup, warm-up and bootstrap scripts, the build tool.
  Verification must never stall on a permission prompt.
- **Deny (hard rails):** `git push --force` in all spellings; any push targeting the default
  branch directly; environment and secret dumps in the spellings a deny rule can express —
  `env`, `printenv`, the builtin dump forms (`set`, `export -p`, `declare -x`), reads of
  `.env`-style files and of `/proc/<pid>/environ`. Deny rules match command *strings*
  (exactly or by prefix, depending on the agent), so they reach what you can enumerate and
  nothing else: a variable expansion inside `echo`, or a `<` redirection, is invisible to
  them. That residue is the pre-execution guard's job, below. Two cautions from live use:
  write each rule so it cannot swallow ordinary usage the guard itself permits (`declare -x`
  as an exact match denies the dump; as a prefix it also denies `declare -x MY_FLAG=1`), and
  never let this list imply coverage the layers do not have. Prose forbids it; the permission
  layer *enforces* what it can spell. An agent without
  permission-rule support still inherits the prose rule — the rails are defence in depth, not
  the only copy of the policy.
- **Instructive pre-execution guard** (where the agent supports pre-tool-use hooks): wire the
  agent-neutral `scripts/command-guard.sh` so every shell command is checked against the hard
  rails before it runs, and a violation is blocked with a reason naming the rule and the
  correct alternative (Claude Code: a Bash PreToolUse hook; exit 2 plus stderr becomes the
  reason shown to the model). This is the layer that makes rails *self-correcting*; the static
  deny list stays beneath it as the second net. Follow the P13 pattern rules: leading-command
  matching, mistake-not-evasion threat model, fail open on malformed input, self-test run by
  the ladder.
- **Output redaction** (where supported): if the agent exposes an output-filter hook, pipe tool
  and terminal output through `scripts/redact.sh` so known token shapes are scrubbed before
  they reach the context window. State explicitly in the adapter which layers it actually
  provides — rails, redaction, or prose-only.
- **Server-side:** the owner mirrors the hardest rails at the host — branch protection on the
  default branch (PRs required; force-push and deletion blocked) and secret-scanning push
  protection. The adapter's deny rules bind only agents that load them; the server binds every
  actor.

A worked adapter, for Claude Code:

<!-- amh:include harness/templates/configs/claude-settings.json -->

### 3.9 CI — invoking the same entrypoint

<!-- amh:include harness/templates/configs/ci.yml -->

### 3.10 The adoption brief — the instantiation work, addressed to the agent

Instantiating is mostly work a tool cannot do: the seeds carry slots only this repository can
fill, the verification set is a stub, and how much of the harness a repo should adopt is the
owner's call. That work is nobody's idea of a good use of the owner's evening, and it is
exactly what an agent sitting in the codebase is good at.

So the installer writes one more file into the adopting tree — `AMH-ADOPT.md`, addressed to
the agent rather than to the human. It asks the owner how much of the harness they want,
fills the slots from the repository itself, writes the real build and test commands into
`scripts/verify.sh`, drives the ladder green, and ends by telling the agent to delete it.
Adoption then costs the owner two commands and one sentence: *read the brief and follow it*.

Three properties keep it honest, and each is a rule the harness states elsewhere applied to
its own front door. It is written **only on a fresh install**, because a document that tells
you to adopt a harness you have run for a year is noise — an upgrade never re-issues it. It
carries **no checklist**: the brief says outright that reporting a completed step is worth
nothing, since no gate consumes such a claim (P3). And it is explicit about the limit of its
own acceptance test — a fresh tree has no repo-local guards, so a green ladder does **not**
prove the placeholders were filled, and the brief says to grep for them by hand rather than
implying a check that does not exist.

<!-- amh:include harness/templates/AMH-ADOPT.md -->
