# conformance — behavioural scenarios for this repository's prose rules

## What this demonstrates, and what it does not

The lab's release claim is deliberately narrow: one model, one fixture and six
owner-accepted runs did not reproduce the DA-003 failure class in scenario
`02-incomplete-negative-search`. The named residues still travel with that claim: A5 held
6/6, A6 held 5/6 in a way that says more about the evaluator than the subjects, and the
result is **not** a conformance claim about AMH, the model, or agents in general. That
bound belongs in any release claim that mentions the lab, and it is the first thing in
this file because it is the thing most likely to be dropped when someone summarises it.

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

The second recorded case is the same shape one layer over: a session that reported a negative
from a command which could not have seen the thing it was denying. It asserted that
`docs/STATE.md` had never crossed its cap and no compression pass had ever run, from
`git log --follow` — while two ledger rows existed *because* of those passes (DA-003). The
reason the log disagreed with reality is structural: this repository squash-merges, so every
intermediate state is destroyed on purpose and the memory tiers ARE the history. DA-002 is the
same failure through a second door, `git tag` in a clone that had never fetched tags. No guard
reaches this either — the rule is about a belief a session formed, and only its consequence is
observable.

The runbook concedes the blind spot in its own words: bash fixtures exercising bash guards in
one interpreter cannot see a defect in an assumption they share. A behavioural scenario is
the only instrument in this constitution's toolbox that can watch a prose rule fail.

That argument earns two scenarios. It does not earn seven, a runner abstraction, a metadata
contract or a report transport — all four were refused (ledger row DA-026). One concrete
runner is not a runner abstraction, and the difference is the thing to preserve if this
directory ever grows.

| Scenario | The prose rule it watches | Seeded on |
|---|---|---|
| `01-stale-queue-item` | test a queue item before restating it; retire the ones the test settles | DA-011, DA-012 |
| `02-incomplete-negative-search` | before reporting that something never happened, establish that the command could have seen it | DA-002, DA-003 |

DA-002's own instance — the distributed fact read locally — is reproduced inside scenario 01,
whose queue item is settled by `git ls-remote --tags origin` against a clone that carries no
tags. Scenario 02 reproduces DA-003's. One mechanism per scenario, both rows covered, and the
reason for the split is written into scenario 02's fixture: an evaluator that has to ask a
remote what exists can be robbed of its own preconditions by a subject that deletes a remote,
which routes maximal noncompliance into the quiet verdict (DB-003(b)).

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
  --scenario conformance/scenarios/02-incomplete-negative-search \
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
conformance/evaluators/02-incomplete-negative-search.sh --result <clone> --baseline <sha>
```

## Fixtures are generated, never stored

Every fixture tree is built at runtime by its `fixture.sh`. A stored fixture is content this
repository's own guards would scan as if it were production: a credential-shaped literal
reddens the secret-shape scan that stores it (ledger row D-004), and a stored markdown file
naming paths that exist only inside the fixture reddens the path-reference guard, whose
exclusion list does not cover this directory.

The one stored markdown file per scenario is its `task.md`, and it inherits that constraint
directly: a fixture-only path named there in backticks is a citation, and the guard resolves
citations against the REAL tree. Scenario 02's task names its answer file in plain text for
exactly this reason. That is not a workaround — it is the rule DA-002 states, that a name which
is not a live citation should not be in backticks, applied where it bites. Adding a
`conformance/*` exclusion to the guard instead was available and was not taken: the exclusion
would also stop the guard checking the paths in these files that ARE live citations.

Not a reason, though it reads like one: the state-size and structure rungs do **not** scan a
stored `docs/STATE.md` under here. They read the single path `STATE_FILE` names in
`amh.conf`, never a glob — verified by planting a 30 KB AMH-shaped state file in a scenario
directory and watching both rungs stay green. Keeping the false half of that sentence would
have been prose claiming enforcement nothing performs, which is the thing `docs/RUNBOOK.md`
says is worse than claiming nothing.

## The acceptance rule, in the form that actually bites

Both directions is the rule everywhere in this repository, and for an evaluator it has a
sharper form than "break it and watch the suite go red":

> **Every assertion and every enumerated trigger needs a case that fails when THAT ONE is
> removed** — not a case that fails while it is removed.

The difference is the whole thing. Scenario 01 shipped with nineteen assertions and nineteen
enumerated triggers, and a 47-case suite that ran green over eight of them: four assertions and
four triggers were individually deletable without a single case noticing — three
checked-NOTHING branches sharing a case that anchored on a different line, an
unreachable-worktree branch nothing exercised, and two triggers whose siblings printed a
different message for the same id (the other two are the declared pair below). They were found
by sweeping: flip each `broke` to `held` and each `inconclusive` to a no-op, one at a time, and
require the suite to go red every time. Cheap — a full sweep is a few minutes — and it is the
only form of the rule that distinguishes an assertion from its own absence (D-020). Both
evaluators now kill 36 of their 38 mutants.

Two branches survive that sweep today and are declared in both evaluators rather than counted
as covered: the `cd` failures behind T1, which need a directory whose execute bit is off, and a
run as root ignores that bit. A case whose verdict depends on who ran it is a flake, and a
flaky gate gets disabled rather than fixed (D-024).

## Citations here are prose

The ladder's citation guard scans code and workflows only — `CITATION_SCAN_PATHS` in
`amh.conf` does not include this directory. Ledger identifiers named in these files therefore
resolve by a reader's attention and nothing else, exactly as in `docs/`. A dangling one will
not fail the build.
