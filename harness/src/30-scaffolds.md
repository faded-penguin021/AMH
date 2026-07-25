---

## Part 3 — Scaffolds

Six files and one config directory. The prose scaffolds are **seeds**: copied once, then owned
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
  on a shrink out of warn territory, so growth and sub-warn edits never trip it.
- **State structure** — fail if a required section header is missing (an over-compression
  tripwire); warn if the Owner-queue header vanished (data loss for the human).
- **Ledger rollover** — warn approaching the line cap; fail when the live file's LAST row
  *starts* past the cap. The final row may overflow; the next belongs in the next file.
- **Citation integrity** — grep the source trees (code and workflows, NOT docs and not the
  guard's own fixtures) for `D[A-Z]?-\d+`; every citation must resolve to a row in the file its
  prefix names; no duplicate row numbers; `[cited]` markers must match the citation set in both
  directions.
- **Poison-token scan** — fixed strings that must never reach a commit message (CI-skip tokens
  a squash merge would fold onto the default branch), scanned over `origin/<default>..HEAD`
  before push. Because force-push is forbidden, a pushed mistake is permanent until merge.
- **Secret-shape tree scan** — fail if redacting any tracked or untracked text file with the
  `redact.sh` filter would change it. The scan IS the filter, so it is drift-free by
  construction. Report value-free (file and position, never the match — and test that
  property: a diagnostic that regresses to printing the line defeats the point). Pass the file
  list NUL-separated; a word-split list silently skips names with spaces or non-ASCII
  characters, which is a blocker-class hole. Text files only — binaries ride on the server-side
  push-protection layer, which fires at push; this guard is the earlier, commit-time net. One
  consequence: any fixture token in the tree must be runtime-generated, never a stored literal.
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
  branch directly; environment and secret dumps (`env`, `printenv`, reads of `.env`-style
  files). Prose forbids it; the permission layer *enforces* it. An agent without
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
