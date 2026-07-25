# RUNBOOK — maintenance playbook

Entry point for changing this repository. Pick the playbook matching your task, read what it
names, then do the work. **Code + the guard fixture suite are ground truth**; where any doc
disagrees with the code, trust the code and fix the doc.

## Where logic lives

| Path | What it is | The invariant that protects it |
|---|---|---|
| `harness/src/*.md` | the harness's prose, in ordered parts | hand-edited; the only source for `dist/` |
| `harness/templates/scripts/*.sh` | the shipped scripts | repo-agnostic; parameter-free (D-002, D-003) |
| `harness/templates/seed/**` | prose scaffolds for adopters | copied once, then owned by the adopter; never drift-checked |
| `harness/templates/configs/**` | JSON/YAML for adopters | carries `{{PLACEHOLDER}}`s; substituted at init |
| `harness/dist/AMH.md` | the single-file bundle | **generated** — rebuilt and diffed by a guard |
| `harness/VERSION` | the harness version | single source; lockstep-checked |
| `scripts/*.sh` (five) | this repo's instance of the shipped scripts | byte-identical copies (D-001) |
| `scripts/verify.sh`, `scripts/guards/*` | this repo's local verification | the ladder's only two extension points |
| `docs/STATE.md` | working memory | capped, compressible, Owner queue protected |
| `docs/LEDGER.md` | permanent memory | append-only; never rewritten |

## Reference-doc index

| Question | Doc |
|---|---|
| What binds me this session? | `AGENTS.md` |
| Why does mechanism X exist? | `harness/src/10-principles.md` |
| What is pending for the owner? | `docs/STATE.md` → Owner queue |
| Why was Y decided/rejected? | `docs/LEDGER.md`; `docs/STATE.md` → Decided non-items |
| How does an adopter move to a new version? | `docs/UPGRADING.md` |
| What changed between versions? | `harness/CHANGELOG.md` |
| How do I contribute a harness change? | `CONTRIBUTING.md` |

## Change-type playbooks

Each: *when · read first · what to touch · obligations · acceptance · record it.*

### 1. Change or add a harness principle

- **When:** the harness's *logic* changes — a new principle, a revised one, a retired one.
- **Read first:** `harness/src/10-principles.md` in full, plus `docs/STATE.md` → Decided
  non-items (the idea may already have been declined) and `CONTRIBUTING.md` → version
  semantics.
- **Touch:** `harness/src/10-principles.md`; the constitution template
  (`harness/templates/seed/AGENTS.md`) if the principle changes what an adopting repo must
  do; `harness/CHANGELOG.md`; `harness/VERSION` if the release warrants a bump.
- **Obligations:** every principle must justify itself against P0 in one sentence — more
  shipped correctness, or less owner attention per change. A principle that satisfies
  neither is ceremony no matter how sophisticated it sounds. Rebuild the bundle
  (`scripts/build-dist.sh`). **Rule-review protocol applies.**
- **Acceptance:** `scripts/ladder.sh` green (dist-drift and version-lockstep guards included).
- **Record:** STATE changelog line; a ledger row if the change encodes a durable lesson.

### 2. Change a shipped script

- **When:** a guard, rail or the bootstrap needs different behaviour.
- **Read first:** the script itself, and its fixtures in `scripts/test-ladder-guards.sh` or
  its `--self-test` matrix.
- **Touch:** `harness/templates/scripts/<name>.sh` — **the template is the original**. Then
  copy it into `scripts/`. Never edit `scripts/<name>.sh` directly; `copy-drift.sh` will
  fail, and the fix is always in the same direction (D-001).
- **Obligations:** the script must stay repo-agnostic. Needing a repo-specific branch means
  an extension point is missing — add the extension point instead (D-003). New behaviour
  lands with its fixture in the same change. **Rule-review protocol applies** (guard
  semantics are legislation).
- **Acceptance:** `scripts/ladder.sh` green, including the fixture suite and both rail
  self-tests; the new fixture must FAIL against the old script — check by stashing the
  behaviour change, or the fixture proves nothing.
- **Record:** STATE changelog line; ledger row for any bug class the change fixes.

### 3. Add a guard

- **When:** a rule has actually been violated. Not before — guards accrete one at a time,
  each earning its place after a real incident. Speculative guards are how a harness turns
  into ceremony (P3, P20).
- **Read first:** `scripts/ladder.sh`'s guard section for the house style.
- **Touch:** a repo-specific guard goes in `scripts/guards/<name>.sh` (exit non-zero to fail
  the ladder; stdout is shown). A guard every adopter needs goes in the shipped
  `harness/templates/scripts/ladder.sh` and gets a fixture in
  `harness/templates/scripts/test-ladder-guards.sh`.
- **Obligations:** the guard must check an artifact the work produces anyway — a file size, a
  diff, a commit message, a citation. If a rule cannot be derived from a real artifact it
  stays prose plus reviewer attention; never invent an attestation the agent self-reports.
- **Acceptance:** ladder green; the new fixture demonstrably fails without the guard.
- **Record:** STATE changelog line; a ledger row naming the incident that earned the guard.

### 4. Change a seed template

- **When:** the scaffold an adopting repo starts from should change.
- **Read first:** `harness/templates/seed/` and `harness/PLACEHOLDERS.md`.
- **Touch:** the seed file; `harness/PLACEHOLDERS.md` if placeholders changed; the changelog.
- **Obligations:** seeds are *starting points*, not upgradeable artifacts — an adopter owns
  their copy and will never re-sync it. So a seed change reaches existing adopters only
  through `docs/UPGRADING.md`; say there what they must apply by hand. Every `{{PLACEHOLDER}}`
  must be documented, or the placeholder-integrity guard fails.
- **Acceptance:** ladder green.
- **Record:** STATE changelog line; CHANGELOG entry under the next version.

### 5. Cut a harness release

- **When:** the owner asks. Version semantics are in `CONTRIBUTING.md`; an ambiguous
  major-vs-minor call is an Owner-queue question, not an agent's judgement call.
- **Steps:** update `harness/VERSION` → add the `harness/CHANGELOG.md` entry, including its
  **Upgrading** subsection (what an adopter must actually do) → update the version recorded
  in `AGENTS.md` and `docs/STATE.md` → `scripts/build-dist.sh` → ladder.
- **Obligations:** the version-lockstep guard binds `VERSION`, the bundle header, the
  changelog's top entry and the constitution's recorded version. Never edit one of the four
  alone. **Tagging and publishing are owner steps** — queue them, do not attempt them.
- **Acceptance:** ladder green.
- **Record:** STATE changelog line; Owner-queue item for the tag.

### 6. Docs-only change

- `scripts/ladder.sh --guards-only` is the acceptance gate (seconds). If the change touches
  `harness/src/`, rebuild the bundle first — otherwise the dist-drift guard fails, correctly.

## Session discipline (BINDING for every session)

1. **Strictly sequential.** No parallel subagents; one unit of work at a time.
2. **Small, shippable units.** About one focused hour, independently shippable, each with a
   hard **binary** acceptance check — never "looks right".
3. **Checkpoint invariant.** Every unit ends: acceptance green → STATE changelog line →
   commit → push. Never start a second unit on top of an uncommitted first. Assume the
   session dies at any moment; an interrupted session must lose at most the unit in flight.
4. **You are the last reviewer.** The review protocols below are mandatory. There is no
   stronger pass behind you.
5. **Multi-unit work** persists an owner-approved plan file plus a STATE checklist; segments
   run sequentially and each ends shippable; delete the plan at the end — by then its durable
   content lives in changelog lines and ledger rows. Code cites ledger rows, never plans.
6. **Recovery (bounded).** If the unit in flight has gone wrong: reset to the last green
   checkpoint, re-run the ladder to confirm green, re-attempt smaller — recording any durable
   lesson first. Recovery is not infinite: if the SAME blocker survives a second
   reset-and-retry with no real progress, stop. Reset once more to green (never end a unit
   red), record the blocker in the Owner queue, commit and push so the record survives session
   death, and end the unit. A gate that will not go green is either a real fix you are missing
   — diagnose it, do not just re-run it — or an owner fork. Neither is solved by burning the
   usage window. The stop is for a genuinely stuck blocker, never cover for abandoning a
   failure you could diagnose. Pushed checkpoints are immutable.
7. **Ask, don't assume.** Forks that are (a) irreversible or expensive to unwind, (b)
   user-visible behaviour with no spec to appeal to, (c) version-semantics ambiguous, or (d)
   process-reshaping are the OWNER's: stop at the last green checkpoint, record the fork with
   options and your recommendation under STATE → Owner queue → Open questions, then move to
   independent work. Genuinely unsure whether something is a fork? Treat it as one —
   escalation costs the owner one read; a wrong guess can cost a segment. Routine engineering
   judgement inside a unit's stated scope is NOT a fork. The final chat message restates the
   Owner queue.
8. **Verification disclosure.** Every commit body states which ladder rungs actually ran and
   names what could NOT be verified locally. Disclosure of real actions — not an attestation.

## Adversarial review protocol (MANDATORY for diffs the fixtures cannot see)

The fixture suite sees guard *verdicts*. It does not see: shell quoting and word-splitting,
`set -u` interactions, hook payload parsing, filesystem edge cases (spaces and non-ASCII in
names, empty files, binaries), git-state edge cases (no remote, shallow clone, detached HEAD,
first commit), or terminal output that could leak a value. A diff touching those areas gets a
second, hostile read of the FULL diff after the ladder is green — in a **fresh context**
(subagent or clean invocation) given the diff, this checklist and tree access, but NOT the
author's reasoning. The context that wrote a diff is anchored on its own rationale. Scale the
reviewer's model tier to the diff. Self-review is the fallback only where no fresh context
can be spawned.

Hunt these classes concretely — each is a real bug already shipped in this repo:

- **`local` list expansion order** — `local s=$1 n=${#s}` expands `${#s}` *before* `s` is
  assigned, so it explodes under `set -u`. Split the declaration (D-006).
- **Matching a word anywhere instead of in position** — scanning every token for `push`
  flagged `git commit -m "never git push --force"`. Match the subcommand, not the word (D-007).
- **A stored literal that makes a file fail its own scan** — secret-shaped fixtures must be
  generated at runtime (D-004).
- **Value leakage in a diagnostic** — a guard that reports *what* it matched instead of
  *where* defeats itself. Report file and position only.
- **Silent skips that look like passes** — a word-split file list drops names with spaces; an
  absent tool "skips" instead of failing in CI; a missing ref makes a guard vacuous.
- **Fail-closed rails** — a guard that blocks on malformed input gets disabled, not fixed.
  Rails fail open; the layers beneath them catch what leaks through.
- **Guard/prose lockstep** — a constant in a script and the number stated in prose must move
  together.

Verdict goes in the commit body ("adversarial pass: clean"). Findings get fixed before the
commit and ledgered if durable; when a class becomes mechanically testable, encode it as a
fixture and retire it from this list — the pass holds only what the fixtures cannot see.

## Rule-review protocol (MANDATORY for binding-rule and guard diffs)

Diffs changing this harness's legislation — `AGENTS.md`, this runbook's protocols,
`CONTRIBUTING.md`, guard semantics **and** their fixture suite, the rail scripts, the session
bootstrap, ledger preambles, adapter permission rails, and anything under
`harness/templates/` — get the same fresh-context pass at the **strongest available tier
regardless of diff size**; a three-line rule edit can carry a semantic bomb. **No self-review
fallback:** a session that cannot spawn a fresh context parks the rule change for the human.
Routine `docs/STATE.md` edits are exempt, EXCEPT its rule-bearing sections (the length-guard
preamble, Decided non-items).

The reviewer hunts these rule bug classes:

- **rule contradiction** — the new rule against an existing binding rule;
- **prose/guard lockstep drift** — a number or behaviour in prose diverging from the constant
  or logic that enforces it;
- **Goodhart-ability** — the rule can be satisfied while defeating its intent (the STATE
  micro-trim hole is the worked example: it is why the landing check exists);
- **enforcement asymmetry** — prose implies a check no guard performs. Say "prose-only", or
  add the check;
- **citation validity** — cited ledger rows exist AND actually support the claim. The
  citation guard scans code, not doc prose, so the "actually supports" half is checked only
  here;
- **agent-agnosticism regression** — the rule silently assumes one agent's machinery,
  filenames or environment variables.

The ladder's rule-review tripwire only *surfaces* that this protocol applies; reviewer
attention is the enforcement. One level of meta only: the reviewer reports, the session
triages, the human arbitrates. Nobody reviews the reviewer.

## Incident: leaked credential

Containment outranks the checkpoint invariant.

1. **Stop.** Never repeat the value again — not in STATE, the ledger, chat or a diff. Refer
   to it by key name only.
2. **Owner queue immediately:** key name, where it landed (SHA / file / log), exposure
   window. Push nothing new containing it.
3. **The owner rotates the credential FIRST.** Rotation is what ends the exposure; the value
   stays burned even after cleanup.
4. **Then** the owner decides on a history rewrite — the one sanctioned exception to
   never-rewriting-pushed-history, scoped to removing the secret, **owner-executed, never by
   an agent**. The force-push rail stays in place for agents; the owner lifts it for
   themselves.
5. **Afterward:** a ledger row, and if a guard or deny rail could have caught it, add one
   with a fixture.

## Acceptance ladder

**One command: `scripts/ladder.sh`** — fast pre-flight guards, then the full verification set.
CI invokes this exact script, so there is no hand-maintained lockstep between what the agent
runs and what CI runs. `--guards-only` covers docs-only changes in seconds.

## When CI fails (workflow vs code)

Local and CI run the same script, so CI-red with local-green means environment, not code.
Triage: (1) read the failing log — a real failure (fix the code), a toolchain mismatch (fix
the workflow, in the same change), or a flake (re-run once; never "fix" code for a flake).
(2) Never weaken a gate to get green. (3) Real but out of scope: say so, with the log excerpt.
The most likely environment difference here is `shellcheck`, which CI installs and this
container does not have — `verify.sh` deliberately FAILS rather than skips when it is missing
under `CI`.

## Self-adaptation — keep this runbook useful

If this runbook lacks what you need: consult the ledger and the archive, record durable facts
as ledger rows, and if a playbook is wrong, stale or missing the case you just handled, **fix
this runbook in the same change.** Treat it as code.

Self-adaptation covers *operational* content — playbooks, the doc index, the module map,
commands. *Binding* rules (session discipline, the review protocols, guard semantics, git and
permission policy) are never self-adaptation: they go through the rule-review protocol, and
process-reshaping changes go through the Owner queue.
