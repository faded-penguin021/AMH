# PLAN — make CI able to SEE the Windows failures, not just run on Windows

Owner-approved 2026-08-31, drafted at the end of the session that shipped **DC-031**/**DC-032**
(branch `session/readme-adoption`, PR #58). Provisional: the owner may pivot, every unit ends
shippable, and the final unit archives this file to `docs/history/` or deletes it. Durable
outcomes live in Changelog lines and ledger rows either way — code cites ledger rows, never this
file.

**Verification of every claim below happens during EXECUTION, not during drafting.** The scope
facts in Unit 1 were read from `amh.conf` and `scripts/guards/shipped-citations.sh` on
2026-08-31; re-check each one inside the unit that acts on it.

## Why this exists

Two Windows defects reached this repository from an adopter rather than from CI, and neither was
a CI outage — the matrix was green throughout, because the Windows job cannot encounter either
input:

- **The CRLF class (DC-030).** `.github/workflows/ci.yml`, first step of the `portability` job,
  sets `core.autocrlf false` and `core.eol lf` *before* checkout. Deliberate, and its comment
  says why. The effect is that the Windows job tests Git Bash on an LF tree, which is the one
  configuration no adopter has: Git for Windows sets `core.autocrlf=true` in its SYSTEM config at
  install time.
- **The grep class (DC-031).** The citation rung needs a binary file inside
  `CITATION_SCAN_PATHS` to misfire. This repository has none, so the rung ran on Windows every PR
  and never met the input that breaks it. Adding `-I` changed no CI verdict in either direction.

The gap is between *the rung runs on that platform* and *the rung runs on that platform against
the input that breaks it*. A green matrix cell means the code executed, not that the platform's
differences were exercised.

## Owner authorizations (recorded here so a cleared session can act on them)

1. **The fresh-context rule-review pass mandated by `docs/RUNBOOK.md` → Rule-review protocol is
   PRE-APPROVED for both units below.** The session's standing "no subagents unless asked"
   policy is lifted for exactly these passes. It stays ONE blocking reviewer per unit, at the
   strongest tier, and the ONE-pass-per-unit bound is unchanged — this is authorization to spawn
   the first pass without stopping to ask, never a licence for a second.
2. The pre-execution command guard advises **every** subagent spawn and does not stand down after
   the first. Re-issuing the identical spawn once is the sanctioned way through, and that is
   expected here rather than a surprise to escalate.
3. Record the authorization in the ledger row the unit that consumes it writes — the owner's
   grant is a durable decision, not a session detail.

## Pacing — the owner is ASLEEP; do not burn the usage window

Budget as drafted: **2026-08-31 19:20 UTC, 5-hour window at 46%, ~3h10m remaining**, so the
window resets at roughly **22:30 UTC**. The rule for this plan is that waiting is free and
retrying is not.

- **Never poll with `sleep`, and never idle in a running turn.** Waiting is done by
  `mcp__Claude_Code_Remote__send_later` (schedules a message back into this session) and then
  ENDING THE TURN.
- **One full `scripts/ladder.sh` run per unit**, immediately before its commit. Iterate with
  `scripts/ladder.sh --guards-only`; a full run is ~15 minutes and the fixture suites dominate
  it. Never re-run the full ladder "to be sure".
- **Unit 1 runs immediately** on execution. It is the cheap one: one review pass, one full
  ladder.
- **Then stop.** After Unit 1 is pushed, call `send_later` with `delay_minutes: 195` (lands
  ≈22:35 UTC, after the window resets) carrying the instruction to start Unit 2, and end the
  turn. Do not start Unit 2 in the same window, even if it feels close to free.
- **Waiting on CI is also `send_later`,** `delay_minutes: 20`, then read the check runs with the
  GitHub MCP tools (`pull_request_read` with `method: get_check_runs`, `actions_get`,
  `get_job_logs`). Never watch a job by re-running a command.
- **At most three CI fix-and-push rounds per unit.** If the Windows job is still red after the
  third, stop, leave the branch green locally, write the blocker into the `docs/STATE.md` Owner
  queue with the failing job's name and log excerpt, push, and end. Recovery is bounded
  (`docs/RUNBOOK.md` → Session discipline 6).
- If a usage limit is hit anyway: do not retry into it. `send_later` past the reset and end the
  turn. Nothing here is urgent enough to spend the owner's morning on a rate-limit message.

## Unit 1 — give the citation rung a binary file to meet, and make CI say what it ran

**Binary acceptance:** the ladder is green with a committed binary file inside
`CITATION_SCAN_PATHS`, and the Windows CI job prints the versions of the two tools whose
behaviour these fixes depend on.

- **Touch:** a new committed binary fixture reachable by the citation scan, and
  `.github/workflows/ci.yml`.
- **Where the file goes, and why it is not obvious.** `amh.conf` has
  `CITATION_SCAN_PATHS='scripts .github'` and
  `CITATION_EXCLUDE='scripts/test-ladder-guards.sh scripts/tests'`, so `scripts/tests/` is OUT of
  scope and cannot host it. `scripts/guards/shipped-citations.sh` globs
  `harness/templates/*` only, so a file under `scripts/` is not in the shipped set — which
  matters, because that guard now REFUSES a binary shipped file by design (DC-032). Suggested:
  `scripts/fixtures/binary-citation.bin`, containing an id-shaped token beside a NUL byte.
  **Verify all three scopes before committing** — citation scan sees it, shipped-citations does
  not, and the manifest (which covers `scripts/*.sh`) is unaffected. The secret scan skips it via
  its own `grep -qI`, and `placeholder-integrity.sh`'s live pass now skips it via `-I`; both are
  real coverage rather than accidents, and both should be confirmed by reading the run's output,
  not assumed.
- **State honestly what this buys, in the file's own comment and in the changelog.** On a host
  whose grep is >= 3.5 the notice goes to stderr and this file changes nothing — it is not a
  regression check for `-I` on a modern grep. What it does is put the input permanently in front
  of every platform, so a runner that ever ships an older grep reports the defect instead of
  passing over it. The regression check for `-I` itself remains the shim fixture in
  `test-ladder-guards.sh`, which already runs on Windows CI. Do not oversell it.
- **Print the tool versions in the portability job.** One step running `grep --version`,
  `sed --version`, `bash --version` (first line each) on both matrix legs. This repository's whole
  Windows story is "a third-party tool behaves differently there", and the version that decides
  the behaviour is currently unrecorded on every run. This is what turns the Owner-queue item's
  open question — is CI's grep even one of the affected versions? — into something a reader can
  answer from a log.
- **Then update the Owner-queue item** in `docs/STATE.md` with what the job now shows, and close
  it if the printed version and the passing rung together settle it.
- **Record:** STATE changelog line; a ledger row only if something durable is learned (the
  authorization in the "Owner authorizations" section above goes in this row).

## Unit 2 — a Windows job that checks out the way an adopter does

**Binary acceptance:** a CI job fails against `HEAD~` of the DC-030 fix and passes against the
fix. Demonstrate that direction explicitly; a new job that is green on both is a job that checks
nothing.

- **The obvious version does not work, and knowing why is half the unit.** You cannot simply drop
  the `core.autocrlf false` step: this repository now has its own root `.gitattributes` pinning
  `* text=auto eol=lf`, so the checkout is LF regardless. That file is the DC-030 fix working as
  intended, and fighting it would test a configuration this repo has deliberately made
  impossible.
- **Test the ADOPTER's tree instead, which the job already builds.** The portability job
  instantiates a fresh repo with `scripts/amh-init.sh --profile light "$target"`. Give that
  scratch repo the adopter's real condition — `core.autocrlf=true`, no seed `.gitattributes`
  (or the seed removed to model an adopter who skipped the hand-applied note), renormalised —
  and run ITS `scripts/ladder.sh --guards-only`. That is a genuine CRLF worktree running the
  shipped rungs, without touching this repository's own line endings.
- **Expect it to be RED in one configuration and say so.** The 10.4.0 changelog states plainly
  that a CRLF worktree without the seed cannot be green: a CRLF shipped script does not match its
  published LF hash, and `amh.conf` sources with a CR in every value. So the job asserts the
  scan and parse rungs specifically (no false credential findings, no phantom deleted scripts),
  not a blanket exit 0 — or it instantiates WITH the seed and asserts full green. Pick one,
  state which in the job's name, and make the assertion narrow enough to be true.
- **Never make this job green by weakening a rung.** If it is red for a real reason, that is a
  finding, not an obstacle: record it and stop rather than loosening what the rung measures.
- **Rule-review protocol applies** (CI is not a rail, but the job encodes what "verified on
  Windows" means, and the seed/attributes interaction is legislation-adjacent). Use the
  pre-approved pass.
- **Record:** STATE changelog line; ledger row for the durable lesson — a matrix cell is not
  coverage, and a platform job that normalises away the platform's defaults tests the wrong
  machine.

## Chore, do it inside whichever unit lands first

PR #58's body still lists four scripts under **Adopter impact** and does not mention
`session-start.sh`. The `harness/CHANGELOG.md` Upgrading section was corrected on 2026-08-31;
the PR body was not. Update it to match — the PR body is what a reviewer reads, and it currently
carries the exact instruction the adopter proved incomplete. Describe the whole diff against
`main`, per `AGENTS.md` (`MERGE_MODE=branch-train`).

## Explicitly out of scope

- Widening `harness/templates/seed/.gitattributes`. The adopter asked for it not to be widened
  and the narrowness is a stated choice.
- The `--baseline` performance rework (compare CR-stripped streams first). It is a design change
  to a rung whose current shape was just reviewed; it needs its own unit and its own evidence,
  and the changelog now states the cost rather than hiding it.
- A skipped-file counter on the citation rung's ok line. Considered and declined by this
  session's reviewer as a nice-to-have.
