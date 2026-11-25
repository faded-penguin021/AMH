# PLAN — ladder throughput: use the cores the ladder leaves idle

> **Status: adopted by the owner on 2026-11-25.** Units T0 to T3, run in order in one cloud
> session that orchestrates: each unit's implementation runs in one subagent, its review in one
> fresh-context reviewer subagent, one at a time (`docs/PROTOCOLS.md` → **Session discipline**
> 1). The session that merges the train archives or deletes this file.

The plan is provisional while it is live. Its durable outcomes go to Changelog lines and ledger
rows. Code cites the ledger rows and never this file, and no ledger row may cite this file's path.

## 1. Why, and the owner's decisions

The owner reported the ladder getting slower on every host they use: this cloud runner, their
Docker environment, and Windows most of all.

**Measured on 2026-11-25** on this runner (4 cores, `ffdb33f`, worktree clean), commands named:

| What | Time | Command |
|---|---|---|
| full ladder | 24 m 02 s, green | `time scripts/ladder.sh` |
| `--guards-only` | 42 s, of which 36 s is the command guard's self-test | each output line timestamped |
| command guard self-test alone | 34–35 s | `bash scripts/command-guard.sh --self-test` |
| shipped fixture suite | 352 s, 286 fixtures | its own `timing:` line |
| load average during the full run | about 1.0 | `uptime` |

**Reported by the forge** for CI run 429 on the same commit: the Linux `ladder` job's ladder
step took 16 m 57 s; the `--guards-only` portability smoke took 5 m 28 s on `windows-latest`
and 40 s on `macos-latest`.

Two causes follow from those numbers. **The ladder is serial**: one core works and the rest sit
idle. **The command guard's self-test repeats**: it runs in the rail rung, in three shipped
fixtures, and in each adopter ladder `scripts/tests/test-init-e2e.sh` builds (estimated by
reading: about 15), so about 19 runs per full ladder. On Windows each of its roughly 7,000
process starts (measured with `strace -f` on Linux) pays Git Bash's emulated `fork()`.

**A prototype was measured, not shipped.** A scratch copy of the guard gave each top-level
`st_*` helper called from `self_test` a shard test (case index modulo N) and logged every
`check_command` verdict. Serial: 35 s, 1,870 verdicts. Four workers: 13 s wall, with one core
busy elsewhere. Both the N=4 and the N=3 merged verdict logs were byte-identical to the serial
log. A worker that judges no case costs about 1 s. The scratch copy was not kept: T1 rebuilds it
in the tree and keeps the comparison as a fixture.

**Owner decisions (2026-11-25):** the plan is approved in full. The owner is away, and **the
session decides every fork itself**, recording each choice and its reason in the unit's ledger
row. The hard boundaries in `AGENTS.md` still bind: nothing is pushed except the session branch,
and nothing is tagged, released or opened as a pull request.

Decisions taken when the plan was drafted:

1. **Unit prefix `T`.** No live plan or Owner-queue item uses it.
2. **Parallelism inside the scripts, never by splitting CI jobs.** CI runs exactly
   `scripts/ladder.sh` (P4); a job per suite would bring back the lockstep that rule removed.
3. **Serial stays available and stays exact.** `AMH_JOBS=1` runs today's serial code path, and
   any unusable worker count or scratch directory falls back to serial with a note, never to a
   failure and never to fewer cases. Concurrency changes when work runs, never what runs.
4. **Coverage is counted, not assumed.** A split run must show that every case ran exactly once,
   from counts the workers compute, and must fail loudly when they disagree. A count a program
   computes is not a self-reported attestation; it is the same kind of evidence as a fixture's
   exit code.
5. **One environment variable, `AMH_JOBS`**, a positive integer, read by every parallel part.
   The default is the online core count (`getconf _NPROCESSORS_ONLN`, then `nproc`, then 1). It
   is not an `amh.conf` key: it describes the host, not the repository.
6. **Portability floor.** bash 3.2 (stock macOS), Git Bash on Windows, GNU and BSD userlands. No
   `wait -n`, no `mapfile`, no new dependency. macOS and Windows are judged by CI on the next
   pull request; this runner cannot see them, and every unit's commit body says so.
7. **Version: no bump.** `amh-v17.1.0` is not tagged (checked with `git ls-remote --tags origin`
   on 2026-11-25), and the shipped number is one bump above the latest tag, settled at PR time
   (`docs/RUNBOOK.md` → **Cut a harness release**). Shipped changes add a bullet to the 17.1.0
   entry of `harness/CHANGELOG.md`.

## 2. The units: T0 to T3

Every unit:
- rereads `AGENTS.md`, `docs/STATE.md` and the `docs/RUNBOOK.md` playbooks named in its steps
  before editing;
- leaves its diff uncommitted, with the full `scripts/ladder.sh` green on its final tree, for one
  fresh-context rule-review pass (`docs/PROTOCOLS.md` → **Rule-review protocol**); the
  orchestrating session triages the findings, applies them, reruns the ladder, commits, runs
  `scripts/ladder.sh --guards-only` again and pushes;
- marks its own heading here `: done <date>` (or `: dropped <date>` with the reason) in the same
  commit, and writes one ledger row in the live volume and one `docs/STATE.md` Changelog line;
- states its timings as measured, with the command, or as estimated (**Session discipline** 11).

### T0 — commit this plan: done 2026-11-25

- **Done:** committed with the owner's decisions; `docs/STATE.md` lists it under Live plans.

### T1 — split the command guard's self-test across cores

- **Touch:** `harness/templates/scripts/command-guard.sh`, copied down to `scripts/`, the
  manifest rebuilt (`docs/RUNBOOK.md` → **Change a shipped script**), fixtures in
  `scripts/test-ladder-guards.sh`.
- **Behaviour:** `--self-test` with a worker count above 1 runs the matrix in that many workers.
  Each top-level case is judged by exactly one worker, by case index. A case called from inside
  another helper belongs to its caller's worker. Each worker's output is held and replayed in
  worker order. The verdict line stays `command-guard.sh self-test: ok` or the failure count,
  and a `SKIP` line keeps the meaning the ladder's rail rung gives it. With a count of 1 the
  path is today's.
- **Coverage check:** every worker reports how many cases it saw in total and how many it
  judged. The run fails, naming the shortfall, unless every worker saw the same total and the
  judged counts add up to it.
- **Fixtures, each seen failing with its behaviour removed:** a worker that judges fewer cases
  than it should fails the run; a failing case in any worker fails the run and is named; the
  verdicts of a serial run and of a run with a fixed worker count of 3 are identical case by
  case, through a verdict log the self-test writes only when a test-only variable asks for one;
  an unusable `AMH_JOBS` value runs serially and says so.
- **Acceptance:** the full ladder is green; on this runner the self-test's wall time at the
  default worker count is at most half of its `AMH_JOBS=1` time, both measured; the fixtures
  above pass and were each seen failing.

### T2 — run `scripts/verify.sh`'s independent stages concurrently

- **Touch:** `scripts/verify.sh` (this repository's, not shipped), a fixture in
  `scripts/tests/local-guards.sh`.
- **Behaviour:** the parse check runs first. Then shellcheck, the shipped fixture suite, the
  repo-local suite, the conformance self-test and the end-to-end test run concurrently, at most
  `AMH_JOBS` at a time. Each stage's output is held and printed in today's order under its
  header, with the stage's elapsed seconds. A failing stage fails the set and is named, and so
  is a stage that never reported. If no scratch directory can be made (**DD-093**), the stages
  run serially. The unit measures whether nested workers (T1's inside each stage) need a smaller
  share, and records what it chose and why.
- **Fixtures, seen failing first:** a stub tree in which one stage fails while the others pass
  fails `verify.sh` and names that stage; its output prints in the fixed order whatever order
  the stages finish in; with `AMH_JOBS=1` the stages run one after another.
- **Acceptance:** the full ladder is green, and its wall time on this runner, measured, is
  below T1's measured wall time.

### T3 — measure, then split the longest remaining stage or drop the unit

- **Rule:** after T2, measure each stage. If the longest stage is more than half of the
  verification set's wall time, and splitting it is estimated to cut the full ladder by at least
  25%, split it into concurrent parts. Otherwise drop the unit with the numbers.
- **Acceptance if it runs:** the full ladder is green; the split stage runs every one of its
  fixtures exactly once, shown by comparing its pass count with T2's; the wall time cut is
  measured.
- **Owed either way:** an Owner-queue item to read the Windows and macOS timings on the next
  pull request's CI run, since this runner can measure neither.
