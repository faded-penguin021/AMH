# conformance — behavioural scenarios for this repository's prose rules

## What this demonstrates, and what it does not

Until an owner funds a model-backed run on a disposable remote, this lab demonstrates that
its evaluators are deterministic and mutation-sensitive. **It demonstrates nothing whatever
about how any agent behaves.** That sentence belongs in any release claim that mentions the
lab, and it is the first thing in this file because it is the thing most likely to be
dropped when someone summarises it.

Nothing here is installed into an adopting repository. This directory is repo-local; the
installer sources every path it copies from `harness/templates/`, so the lab cannot reach an
adopter tree.

## Why it exists at all

Most rules in this repository are enforced by a guard, and a guard is checkable. A few are
not, and cannot be. The recorded case is an Owner-queue item that a session restates to the
owner as pending after it has already been resolved — a failure the owner reports as
recurring across sessions (ledger row DA-011), compounded by a check that answered a
narrower question than the one it was asked (DA-012). DA-011(c) proves no guard can ever
reach it: anything checking whether a session "verified the queue" consumes the session's own
say-so, which is the banned attestation shape. The fix that shipped was prose — session
discipline item 7 in `docs/RUNBOOK.md` — and nothing in this repository tests whether that
prose works.

The runbook concedes the blind spot in its own words: bash fixtures exercising bash guards in
one interpreter cannot see a defect in an assumption they share. A behavioural scenario is
the only instrument in this constitution's toolbox that can watch a prose rule fail.

That argument earns two scenarios. It does not earn seven, a runner abstraction, a metadata
contract or a report transport — all four were refused (ledger row DA-026). One concrete
runner is not a runner abstraction, and the difference is the thing to preserve if this
directory ever grows.

## The rule that shapes every evaluator here

> An evaluator computes its evidence in its own process, and never reads an artifact the
> subject could have written *about itself*.

The evaluator reads the subject's **work product** — files, sections, commits, refs, worktree
state — because that is the observable consequence the lab exists to measure. It never reads
a subject's account of its own behaviour: not a report it wrote, not a receipt, not a
checklist, not a commit message asserting that a step happened. Run receipts and hook markers
were both refused upstream of this file (DA-025, DA-024) for exactly that reason.

The honest bound this leaves: an evaluator can observe that a resolved queue item is gone and
its outcome recorded. It can never observe that the session *ran the check* before deciding.
The act stays unreachable; only its consequence is measurable. Say that plainly rather than
letting a green verdict imply more.

## Layout

| Path | What it is |
|---|---|
| `conformance/scenarios/<name>/fixture.sh` | builds the disposable repository at runtime; prints the baseline commit |
| `conformance/scenarios/<name>/task.md` | the exact task text handed to the subject |
| `conformance/evaluators/<name>.sh` | the verdict, computed first-hand from a result tree |
| `conformance/runners/local-clone.sh` | the one concrete runner: isolate, launch, evaluate, clean up |
| `conformance/selftest.sh` | the deterministic both-directions test; runs in ordinary CI |

The three layers are separate files on purpose. A scenario states the world, a runner puts a
subject in it, and an evaluator judges what came out; collapsing any two of them lets the
thing being measured choose how it is measured.

There is no `reports/` directory and no oracle directory, both refused. Reports are not this
repository's permanent memory, and a directory of PASS lines invites exactly the inference the
release-claims bound forbids in sentences. **A FAIL is cheap and highly informative — a prose
rule does not work, go fix it. A PASS is one model, one fixture, one run, and means almost
nothing.** Build a FAIL-detector; aggregate nothing.

## Verdicts

| Verdict | Exit | Meaning |
|---|---|---|
| PASS | 0 | every assertion held |
| FAIL | 1 | at least one assertion broke — the default outcome for anything not enumerated below |
| INCONCLUSIVE | 2 | one of the **enumerated** triggers fired (evaluator `T0`–`T7`, runner `L0`–`L4`): the lab could not establish it was judging the right tree |

INCONCLUSIVE is never a judgement call. Each evaluator lists its triggers in its own header
and names the one that fired; anything else that goes wrong is a FAIL. It is rendered louder
than PASS, exits non-zero, and says in words that it is not a pass — infrastructure failure
must never be reported as agent noncompliance, and it must never be mistaken for compliance
either.

## Running it

```sh
conformance/selftest.sh                       # deterministic, no model, no network
conformance/runners/local-clone.sh \
  --scenario conformance/scenarios/01-stale-queue-item \
  --subject 'your-agent-command --prompt-from-stdin'
```

The runner clones a fixture into a disposable working directory, gives the subject the task
text on stdin and at `$AMH_CONFORMANCE_TASK`, bounds it with a wall-clock budget **where
`timeout(1)` exists** — it runs unbounded without it, and says so — evaluates the result and
deletes the working directory. `--keep` leaves it behind.

Isolation, scoped honestly: an isolated `HOME` with no system config covers every git
invocation the runner makes — the fixture build, the clone, the subject and the evaluator — so
a developer's `~/.gitconfig` cannot change a verdict. The mechanism that makes this
load-bearing, verified rather than supposed: `clone.defaultRemoteName = upstream` renames the
remote a compliant subject relies on and turns a correct run into a FAIL. (An earlier draft
justified it with `core.excludesFile` flipping FAIL to PASS. That is not reachable here — the
untracked probe passes `--exclude-standard` — and the sentence was removed rather than left
standing as a defence nobody could check.) `conformance/selftest.sh` isolates itself the same
way, for the same reason and not merely for symmetry: it is the rung that blocks CI.

What isolation is not is a scrub of the subject's environment; whatever the operator's shell
exports is still there. Run against disposable credentials, or none.

For an owner-launched hosted run, skip the runner: point the evaluator at a clone of the
branch the agent produced, with the baseline commit the launch recorded.

```sh
conformance/evaluators/01-stale-queue-item.sh --result <clone> --baseline <sha>
```

## Fixtures are generated, never stored

Every fixture tree is built at runtime by its `fixture.sh`. A stored fixture is content this
repository's own guards would scan as if it were production: a credential-shaped literal
reddens the secret-shape scan that stores it (ledger row D-004), and a stored markdown file
naming paths that exist only inside the fixture reddens the path-reference guard, whose
exclusion list does not cover this directory.

Not a reason, though it reads like one: the state-size and structure rungs do **not** scan a
stored `docs/STATE.md` under here. They read the single path `STATE_FILE` names in
`amh.conf`, never a glob — verified by planting a 30 KB AMH-shaped state file in a scenario
directory and watching both rungs stay green. Keeping the false half of that sentence would
have been prose claiming enforcement nothing performs, which is the thing `docs/RUNBOOK.md`
says is worse than claiming nothing.

## Citations here are prose

The ladder's citation guard scans code and workflows only — `CITATION_SCAN_PATHS` in
`amh.conf` does not include this directory. Ledger identifiers named in these files therefore
resolve by a reader's attention and nothing else, exactly as in `docs/`. A dangling one will
not fail the build.
