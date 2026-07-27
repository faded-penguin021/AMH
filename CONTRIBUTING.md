# Contributing to the AMH

For people and agents changing **this** repository — the harness's source of truth. If you
maintain a repo that has *adopted* the harness and want to move it to a newer version, you
want `UPGRADING.md` instead; consuming a release is a different job from cutting one.

This repo is governed by its own harness. `AGENTS.md` is the constitution and it binds you,
not just the agent — read it first, and read `RUNBOOK.md` for the playbook matching your
change. Nothing here overrides either document; this file covers the three things a
contributor needs that are specific to *changing the harness itself*: what a new rule has to
earn, what the version number promises, and how a change gets from a branch to a release.

## Before you propose anything

**Check the vaccine list.** `STATE.md` → *Decided non-items* records ideas that were
considered and declined, each with its reasoning. Several are things any competent reviewer
proposes on first contact. Three are still declined: rendering scripts from placeholder
templates, section-granular rule files, and self-reported checklists. Re-proposing one without
new evidence costs a round trip and gets the same answer. If you have new evidence, say what it
is — the list also records two ideas that were declined and then **overturned the same day**,
including the link checker that is now `path-refs.sh`. Evidence moves these; argument does
not.

**Check the ledger.** `LEDGER.md` is append-only and holds every deviation and discovery,
including the ones that read as embarrassing. If your idea has a history, it is there.

**Know the test the checklist ban actually applies.** "Self-reported checklists" does not mean
"never write down what you did" — it means nothing downstream may CONSUME an agent's claim about
its own process. The operative question is **does anything consume it?** A sentence a human
reads and may disbelieve costs nothing, so the review disclosure in a commit body and the prose
sections of the PR template are fine. The moment a script greps for that string, a required
field demands it, or a session branches on a subagent's "done" marker, the claim has become a
gate that is passed by typing, and the work it stood for is optional (P3, D-014).

## The bar a new principle must clear

Every mechanism in this harness answers to P0 (`10-principles.md`):

> Maximize correct, shippable change per unit of owner attention — assuming the executing
> agent is the weakest one, and that it may die mid-task.

A proposed principle must justify itself against that sentence in **one** sentence: it buys
more shipped correctness, or it buys less owner attention per change. A proposal that does
neither is ceremony, however sophisticated it sounds, and sophistication is the usual disguise.

Two failure modes this repo has actually shipped, so they are worth naming:

- **Prose that claims enforcement nothing performs.** A rule describing a guard that does not
  exist is worse than no rule, because it stops people looking. If you write that something is
  checked, point at the check.
- **A guard built for a violation that has never happened.** The bar for new machinery is an
  incident, not a hypothetical. Two guards in this repo were declined on that ground and
  admitted hours later when the drift they described actually occurred — which is the process
  working, not a reason to skip it.

New principles go in `10-principles.md`; the bundle under `dist/` is **generated** from it,
so never edit the bundle by hand. Run `build-dist.sh` and let the drift guard confirm it.

## Every legislation diff gets a fresh-context review

Changing `AGENTS.md`, this file, the runbook's protocols, guard semantics *or their fixtures*,
the rail scripts, the session bootstrap, ledger preambles, permission rails, or anything under
`templates/` requires the rule-review protocol in `RUNBOOK.md`: one fresh-context reviewer, at
the strongest tier available, **regardless of diff size**, blocking, and exactly one pass. A
three-line rule edit can carry a semantic bomb; the size of a legislation diff predicts nothing
about its blast radius.

There is **no self-review fallback**. A contributor who cannot get a fresh-context read parks
the change rather than approving their own rule edit — but "cannot" means *capability*, no
mechanism and no clean invocation available. A standing instruction not to spawn one is a
policy the owner can lift, so ask before parking. Treating a policy as a capability limit
would park every legislation change forever.

`RULE_FILES` in `amh.conf` makes the ladder *warn* when your uncommitted diff touches one of
those files. It is a tripwire, not the scope: the two deliberately do not coincide, and
treating the list as the definition is how a rule quietly stops binding. It is coarse in both
directions — it nags about an operational typo in the runbook, and it does **not** contain
`docs/STATE.md` or `docs/LEDGER.md`, whose preambles are legislation and do get the protocol.
The scope is the list above; the warning is a courtesy. Read the diff, not the warning.

## Version semantics

The number is a promise about **an adopter's workload**, not about how much prose moved:

| | Meaning | What an adopter must do |
|---|---|---|
| **MAJOR** | A binding rule changed. | Something they are doing now becomes wrong. The changelog entry's *Upgrading* section is the complete list. |
| **MINOR** | Additive. | Nothing. New principles, guards or templates they may take or leave. |
| **PATCH** | Clarification or fix. | Nothing. |

The trap is judging by diff size. Rewriting half the prose without changing what any rule
*requires* is a PATCH; deleting one clause that adopters relied on is a MAJOR. Ask what breaks
for someone who has already adopted, and nothing else.

**An ambiguous major-vs-minor call is an Owner-queue question, not a judgement call.** It is
the one place in this process where guessing is worse than waiting: the whole point of the
number is that an adopter can trust it without reading the diff.

## Branches and merging

- Work on one session branch, named `<BRANCH_PREFIX>/<codename>` from `amh.conf`. One session,
  one branch.
- **Never force-push, and never push to the branch named by `DEFAULT_BRANCH`.** Both are denied
  by the permission rails and by the pre-execution command guard. Two layers, because one of
  them has failed: a bug in the command guard voided its force-push and push-to-`main` rails
  outright, and the permission rails did not backstop it — server-side branch protection was
  the only thing left standing (D-016).
- The merge topology is whatever `MERGE_MODE` says. It is currently **branch-train**: each
  branch is cut from the previous one and contains it whole, so only the final superset branch
  merges, as ONE squash PR whose body describes the net diff against the default branch rather
  than the last branch's. Under `branch-per-change` each branch would merge on its own.
- **Merging and tagging are owner steps.** Queue them; do not attempt them.

### The identity your commits carry

The ladder checks the author and committer address on the commits your branch adds — those in
`origin/<default>..HEAD`, and only when it can resolve that reference, so a shallow clone or a
fork without the upstream ref gets a warning saying it checked nothing rather than a pass. It
can reject a first-time contributor's perfectly real address, which is worth knowing before it
happens rather than after. Each address is judged in this order:

1. **`AUTHOR_EMAIL_ALLOW` in `amh.conf` is consulted first**, an extended regex matched against
   the whole address. Match it and you are accepted, whatever shape the address has. That
   ordering is the escape hatch for a project whose real addresses look machine-generated
   (`.local` is a genuine Active Directory suffix); its price is that a permissive pattern
   switches off step 2 entirely, so the pattern is kept exact.
2. **Otherwise it fails outright on the identities git invents when nothing is configured** —
   `root@host`, `you@localhost`, `you@laptop.local`, `you@box.localdomain`, `(none)`, an empty
   field, anything with no `@`. If you have never run `git config user.email` on this machine,
   that is what you are about to commit. Check before the first commit: an unpushed commit is
   amendable and a pushed one is not, because this repo forbids itself the rewrite that would
   fix it.
3. **Otherwise, if the key is set and your address did not match it, it fails there.** This
   repository does set it, so a real address can fail with nothing wrong with it. **If that is
   you, say so in your PR and the owner widens the line** — one line, a deliberate choice rather
   than a judgement about your address. Do not work around it by changing the identity you
   commit under.

**What it cannot do:** tell a personal address from a work one, or a forge no-reply alias from
the address behind it. Choosing the right identity is still yours — see the identifiers rule in
`AGENTS.md`. The guard catches machine-generated addresses and the stated list, nothing more.

## Cutting a release

Playbook 5 in `RUNBOOK.md` is the procedure and is the authority. In outline: bump `VERSION`,
add the changelog entry *including its Upgrading section*, update the three other
hand-maintained copies of the version — `AGENTS.md`, `STATE.md` and `amh.conf` — rebuild the
bundle, run the ladder, then queue the tag for the owner. Those three plus the changelog's top
entry are the four copies the lockstep guard binds; `VERSION` itself is the source they are
checked against.

The Upgrading section is the part people skip and the part that matters. It is not a summary
of what changed — it is the complete list of what an adopter must actually *do*. If it is
empty, say so explicitly; an absent section reads as an oversight.

## Acceptance

`ladder.sh` is the single entrypoint, and CI runs the same command, so "green locally, red in
CI" can only mean the environment differs. Green is the bar for every change. `--guards-only`
is the seconds-long subset for docs-only work.

Two things the ladder cannot tell you, so they are on you:

- Whether what survived a compression pass on `STATE.md` is any good. No guard reads.
- Whether a fixture would fail without the guard it tests. Break the guard, watch the fixture
  go red, put it back. A fixture that passes against broken code is worse than no fixture, and
  this repo has shipped three that were unreachable by construction.
