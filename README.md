# AMH — the Agentic Maintenance Harness

An operating harness for a repository maintained by AI agent sessions. It is a constitution
file, three memory tiers, a verification ladder and a handful of shell scripts that together
answer the question every agentic session runs into: *what does this repo already know that I
don't?*

It is agent-agnostic on purpose. Nothing here is a plugin for one vendor's tool — the
behaviour lives in files any agent reads, plus a thin adapter that wires them up. This
repository ships the harness and is itself maintained under it, running byte-identical copies
of the scripts it distributes.

The version this tree distributes is in `harness/VERSION`. (Stated as a pointer, not a number:
a hand-copied version here would be a fifth copy that `scripts/guards/version-lockstep.sh` does
not check, free to go stale at the next bump.)

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

## Quickstart

Instantiate into a repo you already have:

```sh
git clone https://github.com/faded-penguin021/AMH.git
cd AMH
./scripts/amh-init.sh --dry-run /path/to/your-repo   # see what it would write
./scripts/amh-init.sh /path/to/your-repo
```

The target must be a git repository. The script writes two kinds of file and tells you which
is which as it goes:

- **Shipped scripts** are overwritten on every run. They are parameter-free — they read
  `amh.conf` at runtime — and that is exactly what makes a later upgrade a copy instead of a
  merge. Never edit them in your repo; the change you want belongs in `amh.conf`, in a
  `scripts/guards` script, or in `scripts/verify.sh`.
- **Everything else is yours**, written only when absent: the seed prose, `amh.conf`, the CI
  workflow, the agent adapter config. Re-running never clobbers a word you wrote.

Then finish what no tool can guess. The seeds arrive with `{{PLACEHOLDER}}` slots for your
repo's invariants, test commands and module map; the init run lists every file that still has
one, and `harness/PLACEHOLDERS.md` says what each means. A tool that filled these in would
hand you a constitution that reads as finished and asserts nothing.

Finally:

```sh
cd /path/to/your-repo
scripts/ladder.sh
```

Expect it to be red at first, and to tell you why. Fill in the placeholders, put your real
build and test commands in `scripts/verify.sh`, and get it green before your first agent
session — an agent's first instruction is to trust the ladder.

## Start smaller than this

Adopting all of it on day one is the common mistake. For a repo with light AI maintenance the
**smallest useful subset** is three things:

1. the constitution,
2. a state file with an Owner queue,
3. a single verification command.

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
    scripts/         the five shipped scripts
    configs/         CI workflow and agent settings; substituted at init
    seed/            prose scaffolds: copied once, then yours forever
    amh.conf.example
scripts/             THE INSTANCE — this repo living under what it ships
  ladder.sh redact.sh command-guard.sh session-start.sh test-ladder-guards.sh
                     byte-identical copies of the shipped scripts, held by a cmp guard
  verify.sh          this repo's verification set — the ladder's extension point
  amh-init.sh        instantiate the harness into a target repo
  build-dist.sh      regenerate the bundle
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
