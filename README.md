# AMH — the Agentic Maintenance Harness

An operating harness for a repository maintained by AI agent sessions. It is a constitution
file, three memory tiers, a verification ladder and a handful of shell scripts that together
answer the question every agentic session runs into: *what does this repo already know that I
don't?*

It is agent-agnostic on purpose. Nothing here is a plugin for one vendor's tool — the
behaviour lives in files any agent reads, plus a thin adapter that wires them up. This
repository ships the harness and is itself maintained under it, running byte-identical copies
of the scripts it distributes.

The version this tree distributes is in `harness/VERSION`. It is stated as a pointer rather than
a number everywhere except the Quick Start below, which must name a real tag to clone — and that
one copy is checked against `harness/VERSION` by `scripts/guards/version-lockstep.sh`, because
an unchecked hand-copied version goes stale at the next bump and hands every new adopter the
wrong release.

## The problem it addresses

An agent session starts with no memory of the last one. Left alone, that produces a
recognisable set of failures: the same bug reintroduced two sessions after it was fixed; a
rule that quietly stops binding because nobody noticed the file it lived in changed; a
"verified" claim that was never run; a credential pasted into a log; a force-push over work
nobody can recover.

The harness is the accumulated answer to those, and every mechanism in it is narrow:

| Mechanism | What it is | What it prevents |
|---|---|---|
| **Constitution** (`AGENTS.md`) | The always-loaded operating prompt: principles, protocol, invariants. | A session inventing its own process. |
| **Working memory** (`docs/STATE.md`) | Current state, Owner queue, changelog. Size-banded with hysteresis. | Handoff by guesswork; an unbounded file nobody reads. |
| **Permanent memory** (`docs/LEDGER.md`) | Append-only rows: what broke, why, and the generalisation. | Session N's shipped bug being rediscovered by session N+9. |
| **Runbook** (`docs/RUNBOOK.md`) | Playbooks for the recurring jobs. | Re-deriving a procedure badly, under time pressure. |
| **The ladder** (`scripts/ladder.sh`) | One verification entrypoint, run identically by the agent and by CI. | "It passes locally" — and green-by-omission. |
| **Rails** (`scripts/command-guard.sh`, `scripts/redact.sh`) | A pre-execution command guard, and a redaction filter that doubles as the repo's secret scan. | Force-pushes, `.env` reads, credentials in output. |
| **Review protocols** | Fresh-context adversarial passes, with a no-self-review rule. | A session grading its own homework. |

Nothing in the harness consumes a self-report. A checklist an agent ticks is not evidence;
the ladder is.

## Who it is for

**It fits** a repository with a single human owner, maintained by agent sessions that run one
at a time, with that human in the loop for merges and for the decisions an agent is not
entitled to make. Any agent, any model vendor. It works on a solo side project as well as on
a production codebase — the smaller the repo, the smaller the subset you should adopt.

**It does not fit** — and will not be stretched to fit — multi-owner arbitration, concurrent
agent sessions on the same repo, or external-contributor PR flows. Each of those needs
machinery the harness deliberately does not define: task claims, ledger-ID allocation,
state-file merge rules. Used there without building that first, it fails in ways it gives you
no diagnostics for.

Two honest costs, before you adopt:

- **The owner has recurring work.** Exactly three touchpoints: merge the squash PRs, action
  the Owner queue, and drop manual-test findings where the next session will read them. If a
  mechanism ever increases that per-change workload, the mechanism is wrong.
- **The value is cumulative.** The ledger and the guards pay for themselves once two or more
  distinct sessions have touched the repo. On day one they are overhead.

## Quick Start

Open your coding agent in the repository you want to adopt AMH in, and paste this:

```text
Install the latest stable release of the Agentic Maintenance Harness (AMH) into this repository.

Run:

    git clone --depth 1 --branch amh-v2.0.0 https://github.com/faded-penguin021/AMH.git /tmp/amh
    /tmp/amh/scripts/amh-init.sh .

Once the harness has been instantiated, read `AMH-ADOPT.md` and follow it completely.

Drive `scripts/ladder.sh` to green, explain any manual actions that require my attention, and
delete `AMH-ADOPT.md` once adoption is complete.

Do not invent repository information. Derive it from the repository wherever possible.
```

That is the whole adoption path. The agent's first instruction in `AMH-ADOPT.md` is to ask you
how much of the harness you want, so nothing large lands without your say-so.

Prefer to drive it yourself? Run the same clone, then the installer against a path — it takes a
`--dry-run` that writes nothing:

```sh
/tmp/amh/scripts/amh-init.sh --dry-run /path/to/your-repo   # see what it would write
/tmp/amh/scripts/amh-init.sh /path/to/your-repo
```

then point your agent at `AMH-ADOPT.md` in the repo you just instantiated into.

The rest of this section is what those steps do, and you can skip it until something
surprises you.

The clone is pinned to a release tag on purpose: instantiating from a moving branch is how a
fleet ends up on versions nobody chose. The target must be a git repository, and keep the
checkout until your agent has finished — `harness/PLACEHOLDERS.md` lives there.

**What lands in your tree**, and the split is worth knowing because it is what makes upgrades
cheap:

- **Shipped scripts** are overwritten on every run. They are parameter-free — they read
  `amh.conf` at runtime — and that is exactly what makes a later upgrade a copy instead of a
  merge. Never edit them in your repo; the change you want belongs in `amh.conf`, in a
  `scripts/guards` script, or in `scripts/verify.sh`.
- **Everything else is yours**, written only when absent: the seed prose, `amh.conf`, the CI
  workflow, the agent adapter config. Re-running never clobbers a word you wrote.

**What is left over is agent work, which is why the second step is a sentence rather than an
afternoon.** The seeds arrive with `{{PLACEHOLDER}}` slots for your repo's invariants, test
commands and module map; `scripts/verify.sh` arrives without your build commands in it; the
first `scripts/ladder.sh` run is red, and says why. A tool that filled those in from nothing
would hand you a constitution that reads as finished and asserts nothing — but an agent sitting
*in your repository* can read it and fill them honestly.

So the init run installs `AMH-ADOPT.md`, a brief addressed to that agent rather than to you. It
tells the agent to ask you how much of the harness you want, fill the slots from your
repository, put your real commands in `scripts/verify.sh`, drive the ladder green, and then
delete the brief. It carries no checkboxes and nothing downstream reads a word of it:
**acceptance is the ladder**, run in your repo, green.

```sh
cd /path/to/your-repo
scripts/ladder.sh
```

That is the check worth watching, whether your agent ran it or you did. Get it green before
your first real session — an agent's first instruction is to trust the ladder, and one that
arrives red teaches it not to.

**How much lands is your call, and the default is small.** `--profile light` (the default)
installs the constitution, the state file and one verification command; `--profile standard`
adds the runbook and the ledger; `--profile full` adds the archive tier. The brief's first
instruction is to ask you which you want rather than to assume the default. Escalating later is
the same command with a larger profile — it adds the missing files and touches nothing you have
written, so starting small costs nothing.

## Start smaller than this

Adopting all of it on day one is the common mistake. For a repo with light AI maintenance the
**smallest useful subset** is three things:

1. the constitution,
2. a state file with an Owner queue,
3. a single verification command.

`--profile light`, the default, installs those three plus a pointer stub for your agent — so
you already start here; what follows is how to grow out of it.

Fold the runbook into the constitution while there are only a couple of playbooks; split it
when they multiply. Add the ledger the first time you catch yourself re-explaining a past
mistake to a fresh session. Add a guard the first time a rule is actually violated — a
botched guard that passes when it should fail is worse than no guard, so each one lands with
a fixture test proving it can fail.

Start `ladder.sh` as nothing but your verification commands. Treat the first few sessions as a
shakedown: when a rule proves ambiguous, the fix is clearer prose in the same change, not
another rule.

## Reading the harness itself

If you would rather read the whole thing before deciding, `harness/dist/AMH.md` is the entire
harness as one document — design principles, the constitution, the scaffolds. It is generated
from the same template files `amh-init.sh` copies, so the document and the artifacts cannot
disagree. Read the principles first: most pieces earn their keep only in combination, and
knowing why a mechanism exists is what lets you adapt it instead of cargo-culting it.

## Repo map

```
README.md            you are here
AGENTS.md            this repo's own constitution — and a worked example of one
CLAUDE.md            pointer stub for Claude Code; adapters stay thin
CONTRIBUTING.md      how to change the harness: release flow, semver policy, review bar
LICENSE              MIT
amh.conf             this repo's harness settings; the shipped scripts read it at runtime
.gitignore
.claude/settings.json   the agent adapter: permission rails, and the two hooks
docs/
  STATE.md           working memory: current state, Owner queue, changelog
  RUNBOOK.md         playbooks
  LEDGER.md          permanent memory: append-only D-NNN rows
  UPGRADING.md       for an adopting repo moving to a newer harness version
  history/           frozen archive: documents retired whole, never compressed residue
  plans/             multi-session build plans; disposable by design
harness/             THE PRODUCT — what an adopter copies
  VERSION            the version this tree distributes
  CHANGELOG.md       per-release notes, each with an Upgrading section
  PLACEHOLDERS.md    every slot in the templates and what it means
  src/               the harness prose, in five parts
  dist/AMH.md        GENERATED single-file bundle — never hand-edited
  templates/
    AMH-ADOPT.md     the adoption brief, written into an adopter's tree for their agent
    scripts/         the five shipped scripts, plus their generated integrity manifest
    configs/         CI workflow and agent settings; substituted at init
    seed/            prose scaffolds: copied once, then yours forever
    amh.conf.example
scripts/             THE INSTANCE — this repo living under what it ships
  ladder.sh redact.sh command-guard.sh session-start.sh test-ladder-guards.sh
                     byte-identical copies of the shipped scripts, held by a cmp guard
  MANIFEST.sha256    their hashes, as shipped — the copy an adopter's ladder checks
  verify.sh          this repo's verification set — the ladder's extension point
  amh-init.sh        instantiate the harness into a target repo
  build-dist.sh      regenerate the bundle
  build-manifest.sh  regenerate the integrity manifest
  guards/            repo-local guards; the ladder runs every one it finds here
  tests/             fixtures for the repo-local guards, and the end-to-end init test
.github/workflows/   CI, which runs the same ladder and nothing else
```

The two halves are the point. A template no repository executes is a liability, so the
reference instance runs the exact files it ships, and a guard fails the build if they ever
differ by a byte.

## Versioning and upgrades

Semver, where the number is a promise about *your* workload as an adopter rather than about
how much prose moved: **MAJOR** means a binding rule changed and you must act, **MINOR** is
additive, **PATCH** is clarification. Each release entry in `harness/CHANGELOG.md` carries an
Upgrading section that is the complete list of what to do; the procedure lives in
`docs/UPGRADING.md`.

Upgrading is not automatic, deliberately. Process that changes under you without your having
read it is worse than process one version behind.

## Contributing

Changes to the harness are governed by this repo's own `AGENTS.md`, at a bar stricter than
most: every legislation diff needs a fresh-context review pass, and the ledger row lands with
the fix. `CONTRIBUTING.md` has the details — including the list of ideas already proposed,
decided against, and not to be re-proposed without new evidence.

## License

MIT — see `LICENSE`.
