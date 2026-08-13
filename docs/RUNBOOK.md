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
| `harness/templates/scripts/MANIFEST.sha256` | hashes of the shipped scripts, installed beside them | **generated** — rebuilt and diffed by a guard |
| `harness/dist/AMH.md` | the single-file bundle | **generated** — rebuilt and diffed by a guard |
| `harness/VERSION` | the harness version | single source; lockstep-checked |
| `scripts/*.sh` (five) + `scripts/MANIFEST.sha256` | this repo's instance of the shipped files | byte-identical copies (D-002) |
| `scripts/verify.sh`, `scripts/guards/*`, `scripts/tests/*` | this repo's local verification | the ladder's only two extension points; `tests/` hangs off `verify.sh` |
| `scripts/amh-init.sh`, `scripts/build-dist.sh`, `scripts/build-manifest.sh` | repo-local tooling: instantiate an adopter, generate the bundle, generate the integrity manifest | not shipped — they run FROM here, never inside an adopting repo |
| `conformance/` | behavioural scenarios for the prose rules no guard can reach | repo-local, never installed; evaluators compute their own evidence |
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

## Efficient document retrieval

Keep context relevant by locating before loading. For a large structured document, list its
headings or search for the exact identifier, then print only the matching section; widen the
read when that section names prerequisites, rules may interact across sections, or the excerpt
is ambiguous. This is an outcome rule, not a command ritual: native range-reading tools are
equally valid. The entry constitution and `docs/STATE.md` are read in full at session start,
and any playbook instruction to read a file in full overrides this optimization.

Portable examples (headings and ledger identifiers are stable navigation keys; stored line
numbers are not):

```bash
grep -nE '^#{1,3} ' docs/RUNBOOK.md
awk '/^## Rule-review protocol/{p=1} p && /^## / && !/^## Rule-review protocol/{exit} p' docs/RUNBOOK.md
grep -nF 'DA-016:' docs/LEDGER_A.md
```

The documentation-navigation guard checks that every runbook section named by the entry
constitution exists exactly once. It cannot prove what an agent read, and no attestation or
shell history may be used as evidence that this procedure was followed (DA-017).

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
- **Record:** STATE changelog line; a concise ledger row if the change encodes a durable
  lesson. Record that lesson, not the whole debugging narrative; archive a larger narrative
  under `docs/history/` and point to it from the `docs/STATE.md` changelog.

### 2. Change a shipped script

- **When:** a guard, rail or the bootstrap needs different behaviour.
- **Read first:** the script itself, and its fixtures in `scripts/test-ladder-guards.sh` or
  its `--self-test` matrix.
- **Touch:** `harness/templates/scripts/<name>.sh` — **the template is the original**. Then
  copy it into `scripts/`. Never edit `scripts/<name>.sh` directly; `copy-drift.sh` will
  fail, and the fix is always in the same direction (D-002).
- **Obligations:** the script must stay repo-agnostic. Needing a repo-specific branch means
  an extension point is missing — add the extension point instead (D-003). **Never cite a
  ledger row by its real id in anything shipped** — not the rails, not the seed scripts, not
  the CI workflow — because our rows cannot exist in an adopter's ledger; name it `AMH ledger
  row DBNNN` without the hyphen. `shipped-citations.sh` fails on the hyphenated form, scoped by
  where a file is installed rather than by its extension. New behaviour
  lands with its fixture in the same change. **Run `scripts/build-manifest.sh` in the same
  change**: the shipped scripts' hashes ship with them, and `manifest-drift.sh` fails on a
  manifest that describes bytes nobody has. **Rule-review protocol applies** (guard
  semantics are legislation).
- **Acceptance:** `scripts/ladder.sh` green, including the fixture suite and both rail
  self-tests; the new fixture must FAIL against the old script — check by stashing the
  behaviour change, or the fixture proves nothing.
- **Record:** STATE changelog line; a concise ledger row for any durable bug class the change
  fixes, not its whole debugging narrative. Archive a larger narrative under `docs/history/`
  and point to it from the `docs/STATE.md` changelog.

### 3. Add a guard

- **When:** a rule has actually been violated. Not before — guards accrete one at a time,
  each earning its place after a real incident. Speculative guards are how a harness turns
  into ceremony (P3, P20).
- **Read first:** `scripts/ladder.sh`'s guard section for the house style.
- **Touch:** a repo-specific guard goes in `scripts/guards/<name>.sh`. Three verdicts: exit 0
  passes, exit 2 whose MERGED output (stdout and stderr together, which is what the ladder
  captures) begins `WARN ` warns without turning the run red, any other non-zero fails. The
  warn line is the guard's first line; later lines are indented under it. That contract is the
  ladder's — a workflow invoking a guard directly, as the release job does, sees any non-zero
  as a failure. Its fixture goes in `scripts/tests/local-guards.sh`. A guard
  every adopter needs goes in the shipped `harness/templates/scripts/ladder.sh` with its
  fixture in `harness/templates/scripts/test-ladder-guards.sh`, both then copied into
  `scripts/`. Do not cross the streams: a repo-local fixture in the shipped suite breaks
  `copy-drift.sh`, and it should — that file is a repo-agnostic artifact.
- **Obligations:** the guard must check an artifact the work produces anyway — a file size, a
  diff, a commit message, a citation. If a rule cannot be derived from a real artifact it
  stays prose plus reviewer attention; never make a gate out of something the agent
  self-reports (D-014).
- **Acceptance:** ladder green; the new fixture demonstrably fails without the guard.
  Demonstrate it by removing the *behaviour* — stash the diff, or delete the added lines —
  and re-running the suite. Deleting the guard FILE proves only that the file must exist:
  every fixture then dies at exit 127, including one that never checked anything.
  Know what this acceptance does not reach: these are bash fixtures exercising bash guards
  in the same interpreter, so a defect in an assumption they share is invisible to them —
  quoting, locale, `set -u` behaviour, a stubbed tool that silently returns success. Making
  the fixture fail against the old script is the mitigation, not a proof of correctness, and
  it is why guards that can go hollow (a missing tool, an extraction that yields nothing)
  carry an explicit checked-NOTHING branch instead of trusting the comparison to be loud.
- **Record:** STATE changelog line; a concise ledger row naming the incident and durable
  lesson that earned the guard, not the whole debugging narrative. Archive a larger narrative
  under `docs/history/` and point to it from the `docs/STATE.md` changelog.

### 4. Change a seed template

- **When:** the scaffold an adopting repo starts from should change.
- **Read first:** `harness/templates/seed/` and `harness/PLACEHOLDERS.md`.
- **Touch:** the seed file; `harness/PLACEHOLDERS.md` if placeholders changed; the changelog.
- **Obligations:** seeds are *starting points*, not upgradeable artifacts — an adopter owns
  their copy and will never re-sync it. So a seed change reaches existing adopters only as a
  hand-applied note: write it in the **Upgrading** subsection of this version's
  `harness/CHANGELOG.md` entry, naming the seed file to copy the wording from.
  `docs/UPGRADING.md` is the version-agnostic procedure and routes adopters to those entries —
  it does not carry per-version notes, so it usually needs no edit. Every `{{PLACEHOLDER}}`
  must be documented, or the placeholder-integrity guard fails.
- **Acceptance:** ladder green.
- **Record:** STATE changelog line; CHANGELOG entry under the next version.

### 5. Cut a harness release

- **When:** the owner asks. Version semantics are in `CONTRIBUTING.md`; an ambiguous
  major-vs-minor call is an Owner-queue question, not an agent's judgement call.
- **Steps:** update `harness/VERSION` → add the `harness/CHANGELOG.md` entry, including its
  **Upgrading** subsection (what an adopter must actually do) → update the version recorded
  in `AGENTS.md`, `docs/STATE.md` and `amh.conf` → **update the release tag in the `README.md`
  Quick Start's clone command** → `scripts/build-dist.sh` → **`scripts/build-manifest.sh`** →
  ladder.
- **Obligations:** `scripts/guards/version-lockstep.sh` binds `harness/VERSION` to five
  hand-written copies — the changelog's top entry, `AGENTS.md`, `docs/STATE.md`,
  `AMH_VERSION` in `amh.conf`, and the `README.md` Quick Start's tag. Never edit one alone.
  The README copy is the one this list forgot once: the guard went red at the end of a
  release with nothing in these steps telling the releaser which file to touch. **The manifest
  is the second**, found the same way in 2.1.0 — `MANIFEST.sha256`'s header carries the version,
  so a bump makes it stale even though no shipped script changed, and `manifest-drift.sh`
  reports it as a script edited without its manifest. Neither copy is lockstep-checked: they are
  generated, so the rebuild steps above are what keep them true. The bundle header is generated from
  `harness/VERSION`, so `dist-drift.sh` covers it and the lockstep guard deliberately does
  not. **Tagging and publishing are owner steps** — queue them, do not attempt them.
- **Acceptance:** ladder green.
- **Record:** STATE changelog line; Owner-queue item for the tag.

### 6. Docs-only change

- `scripts/ladder.sh --guards-only` is the acceptance gate (seconds). If the change touches
  `harness/src/`, rebuild the bundle first — otherwise the dist-drift guard fails, correctly.

### 7. Add or change a conformance scenario

- **When:** a *prose* rule needs testing — one no guard can reach, because reaching it would
  mean consuming the session's own account of what it did. Not for anything a guard can
  check: a scenario costs a model run, a guard costs milliseconds.
- **Read first:** `conformance/README.md` in full, and the ledger rows the scenario claims as
  its provenance.
- **Touch:** `conformance/scenarios/<name>/` (a `fixture.sh` that builds the disposable repo
  at runtime and prints its baseline commit, plus the `task.md` handed to the subject),
  `conformance/evaluators/<name>.sh`, and `conformance/selftest.sh`, which the acceptance
  rule below requires cases in. The runner is shared and should not need changing; if it
  does, keep it one concrete runner rather than growing the abstraction that was refused.
- **Obligations:** the scenario is seeded on a named ledger row recording a real failure
  here — a hypothetical one is what the incident bar exists to stop, and three of RFC3's
  seven died on exactly that, with two more failing provenance in their own ways: one runs
  inverse to the instance it cites, and one lost its subject entirely (**DA-026**(b)). The
  three are not one class, and flattening them is how a checklist starts overstating its
  own provenance. The evaluator computes every fact in its own
  process and never reads the subject's account of its own behaviour. Every absence
  assertion is paired with the presence check that keeps it from passing over nothing.
  INCONCLUSIVE comes only from a trigger enumerated in the evaluator's header; everything
  else is FAIL. Fixtures are generated, never stored.
- **Acceptance:** `conformance/selftest.sh` green, with the new evaluator exercised in BOTH
  directions — a compliant tree passes, and each mutation it claims to detect fails *naming
  the reason*. Then demonstrate the other direction the same way guards are demonstrated:
  break the evaluator, watch the suite go red, restore it. Those two rules are orthogonal —
  one mutates the subject, one mutates the checker — and neither implies the other.
- **Record:** STATE changelog line; a concise ledger row for the durable lesson the scenario
  taught, not the whole debugging narrative. Archive a larger narrative under `docs/history/`
  and point to it from the `docs/STATE.md` changelog.
- **What a green run does NOT say:** anything about how an agent behaves. Until a scenario
  has been run against a real agent it has demonstrated only that its evaluator is
  deterministic. Any release claim that mentions the lab carries that sentence.

## Session discipline (BINDING for every session)

1. **Strictly sequential.** No parallel subagents; one unit of work at a time. This includes
   review passes: the protocols below permit exactly ONE reviewer at a time, and it BLOCKS —
   you do not keep editing while it runs. Fanning out several reviewers because the tooling
   makes it easy is the exact failure this rule names (D-009).
2. **Small, shippable units.** About one focused hour, independently shippable, each with a
   hard **binary** acceptance check — never "looks right".
3. **Checkpoint invariant.** Every unit ends: acceptance green → STATE changelog line →
   commit → push. Never start a second unit on top of an uncommitted first. Assume the
   session dies at any moment; an interrupted session must lose at most the unit in flight.
4. **You are the last reviewer.** The review protocols below are mandatory. There is no
   stronger pass behind you.
5. **Multi-unit work** persists an owner-approved plan file plus a STATE checklist; segments
   run sequentially and each ends shippable. At the end, move a completed plan worth retaining
   whole to `docs/history/`; otherwise delete it. Its durable outcomes live in changelog lines
   and ledger rows either way. Code cites ledger rows, never plans: an archived plan is a
   historical record, not permanent memory.
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
   Owner queue — **each item tested first, never copied forward.** Run the `Check:` command an
   item carries and read its OUTPUT against the resolution the item states — not its exit
   status, which is a property of the command and says nothing about the item (a check written
   to detect the unresolved condition exits 0 precisely when the item is still open). Resolved
   means done in this session: delete it and record the outcome, rather than restating it with a
   caveat. An item with no check is restated as *unverified*, naming who settles it. Nothing
   enforces this and nothing may: a gate consuming "I checked" is the D-014 shape (DA-011).
8. **Verification disclosure.** Every commit body states which ladder rungs actually ran and
   names what could NOT be verified locally. Disclosure of real actions, addressed to a human
   — never something a gate consumes (D-014).
9. **Establish coverage before reporting an absence.** Before you report that something does
   not exist or never happened, establish that the command you ran could have seen it, and say
   which artifact you searched. The tell is available before the claim: a local artifact was
   read and its answer reported as a property of the repository. `MERGE_MODE=branch-train` plus
   squash-merge means a whole train arrives as ONE commit and the branches are pruned, so
   `git log`, `git show`, `blame` and `tag` cannot answer a question about this repository's
   past — the ledger and the STATE changelog are the only surviving record (**DA-002**,
   **DA-003**). A pre-execution rail on `git log` was considered and declined: the defect is
   the generalisation drawn from the output, which no such rail can see. What was accepted
   instead is a line in the session banner — but that line reaches you only if your harness
   ran `scripts/session-start.sh`, and one of the two first-class adapters has no
   session-start hook to run it. So this is prose-only and binds you whether or not anything
   printed it.

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

Hunt these classes concretely. The first five are real bugs already shipped in this repo,
with their ledger rows; the last two are carried from the harness's own history and have not
(yet) bitten here — marked as such, because a checklist that overstates its provenance invites
the reader to discount all of it:

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
- **Fail-closed rails** *(inherited, not yet seen here)* — a guard that blocks on malformed
  input gets disabled, not fixed. Rails fail open; the layers beneath them catch what leaks
  through.
- **Guard/prose lockstep** *(inherited, not yet seen here)* — a constant in a script and the
  number stated in prose must move together. When they disagree the code says what the system
  DOES; it does not settle what the value SHOULD be (see the constitution's ground-truth
  note).

Verdict goes in the commit body ("adversarial pass: clean"). Understand exactly what that
string is: prose for a human reader, checked by nothing, and **not** evidence the pass
happened — an agent that skipped the review can type it just as easily. Write it anyway, and
write it honestly: the attestation ban forbids *machinery* built on a self-report, not a
disclosure nothing consumes (D-014). If a guard, a CI step or a merge checklist ever starts
requiring the string, that is the violation — delete the requirement, not the sentence.
Findings get fixed before the commit and ledgered if durable; when a class becomes
mechanically testable, encode it as a fixture and retire it from this list — the pass holds
only what the fixtures cannot see.

## Rule-review protocol (MANDATORY for binding-rule and guard diffs)

Diffs changing this harness's legislation — `AGENTS.md`, this runbook's protocols,
`CONTRIBUTING.md`, guard semantics **and** their fixture suite, the rail scripts, the session
bootstrap, ledger preambles, adapter permission rails, and anything under
`harness/templates/` — get the same fresh-context pass at the **strongest available tier
regardless of diff size**; a three-line rule edit can carry a semantic bomb. **No self-review
fallback:** a session that cannot spawn a fresh context parks the rule change for the human.
"Cannot" means *capability* — no subagent mechanism, no clean invocation available. It does
NOT mean a standing instruction told you not to spawn one: that is a policy the owner can
lift, so ASK before parking, and record the answer. Treating a policy as a capability limit
would park every legislation change forever while the playbooks above still expect the unit to
finish. **Three bounds on the pass** — they are what keep it a gate instead of a process that eats the
unit (D-015):

- **Concurrency: one reviewer at a time, blocking.** A review is a gate, not a background job;
  fanning out several is the parallel-subagent failure the session discipline forbids (D-009).
  You do not keep editing while it runs.
- **Iteration: ONE pass per unit.** Triage the findings, apply them, ship. Do NOT review the
  corrected diff again — re-running until a pass comes back clean turns the gate into a loop
  that launders a diff into looking approved, and each lap costs a whole context for shrinking
  returns. Fixes too large to ship unreviewed mean the unit was too big.

  **Three bounds on what "a unit" may mean, because the sentence above was Goodhart-open for as
  long as it stood alone (D-018, closed by D-035).** "Split it" is an instruction about what to
  do NEXT TIME, and read as permission it lets a session relabel a corrected diff as a fresh
  unit and claim a second pass — the exact laundering the paragraph forbids.

  - **A unit is what one reviewer saw.** Not what you meant to build, and not what the commit
    message calls it: the unit is the diff you handed to the pass. Everything descended from
    that diff — the fixes for its findings, the fixes for those fixes — belongs to the same
    unit permanently, however large it grows or however different it ends up looking.
  - **Splitting is a decision made BEFORE the pass, never after seeing its findings.** You may
    divide work into two units and give each its own pass, decided while both are unreviewed.
    Once findings exist, that route is closed: if the corrections are too big to ship
    unreviewed, they are too big to ship. "The fixes turned out large" is evidence the unit
    was misjudged, not a licence.

    **Parking is the exit, and it has to be executable or this bound is a trap** — with (a)
    forbidding a second pass and this clause forbidding the ship, a session that could not
    park would have no legal move at all. So parking overrides the hold: **commit the work
    and push it**, with the commit body saying plainly that the unit is unreviewed and why,
    and put it in the Owner queue naming the branch. Uncommitted work cannot be parked, and
    losing it is worse than a branch that says what it is. The owner may then authorise a
    fresh pass on the parked unit — that is the ONE way a unit gets a second reviewer, it is
    the owner's to grant and never the session's to assume, and the grant goes in the ledger.
  - **A pass that did not report is not a pass.** If the reviewer died, was killed, or returned
    nothing because it never ran, the unit is unreviewed and its replacement is that unit's
    FIRST pass, not a second one. Judge this from the artifact and never from the reviewer's
    own say-so: a completion marker is a self-report, and P3 bans machinery that consumes one.
    Before treating a reviewer as dead, confirm it has actually stopped — a live pass mid-run
    looks identical to a stalled one from the outside, and replacing it while it works gives
    you two reviewers editing under each other, which the concurrency bound above forbids.

  **Ask each pass for falsifiable claims, and replay them.** "I checked the coverage" is
  unfalsifiable and worth nothing; "I deleted this branch and the suite stayed green" is a
  claim you can re-run in the time it takes to read it. Ask for findings in that form, replay
  the ones a decision rests on, and treat what survives replay as the finding — a mutation that
  silently failed to change the file reports exactly as green as a fixture that cannot fail.
- **Depth: one level of meta.** The reviewer reports, the session triages, the human
  arbitrates. Nobody reviews the reviewer.

**Spawning the reviewer is not a question for the owner.** It is what this protocol already
requires, so do not ask permission each time — spawn it, and escalate the *diff's substance*
if something genuinely needs a human. (The "ask before parking" clause above is narrower: it
applies only when a standing instruction appears to forbid subagents outright.)

**Codex invocation.** In a Codex repository that installs the project-scoped custom agent,
select `amh-rule-reviewer` for this pass and give it the actual uncommitted diff; it will inspect
the applicable rule sources and fixtures in the tree. This is a convenience, not a new review
standard: any genuinely fresh context at the strongest available tier remains valid, including
for agents that do not support Codex profiles. A live parent permission override can propagate
to subagents and broaden the runtime sandbox; the reviewer's own instructions still forbid
edits even in that case. The result remains human-readable prose, and no guard, script, or
decision procedure may consume a “review complete” statement as evidence.

**While the pass is in flight the diff stays green, uncommitted and unpushed.** A harness that
prompts for a commit on every idle turn does not override the gate: hold, say so once, and do
not re-explain every turn. Green-but-reviewed-pending is a normal state, not a stall — the
checkpoint invariant budgets for losing exactly the unit in flight, and the ladder's own
warning says the pass happens BEFORE the commit. The hold lifts the moment the pass reports:
triage, apply, commit.

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
  citation guard scans configured implementation paths, not doc prose, so the "actually supports" half is checked only
  here;
- **agent-agnosticism regression** — the rule silently assumes one agent's machinery,
  filenames or environment variables.

**Scope of the tripwire vs scope of the protocol.** `RULE_FILES` in `amh.conf` is
file-granular, so the two do not coincide — and pretending they do is how a rule quietly stops
binding:

- `docs/STATE.md` and `docs/LEDGER.md` are **not** in `RULE_FILES` even though their preambles
  are legislation. They change in nearly every unit and the tripwire cannot fire on a section;
  warn fatigue would kill it. Their rule-bearing sections are **prose-only** — you are on your
  own there.
- `docs/RUNBOOK.md` **is** listed wholesale, so fixing a stale playbook — which the
  self-adaptation rule below *requires* in the same change — trips the warning. Accepted false
  positive: the alternative is section-granularity this tooling does not have. Say in the
  commit that the diff was operational, and move on.
- `amh.conf` is listed because it defines the thresholds, the poison tokens and `RULE_FILES`
  itself. A scope list that excludes the file defining the scope list is not a scope list.

The tripwire only *surfaces* that this protocol applies; reviewer attention is the
enforcement. One level of meta only: the reviewer reports, the session triages, the human
arbitrates. Nobody reviews the reviewer.

## Incident: leaked credential

Before an incident, know the rail's shape: `scripts/command-guard.sh` carries a consolidated
**what this guard does NOT catch** block in its header — interpreters outside its enumerated
reader list, wrappers it does not strip, `eval`-constructed and encoded commands, heredocs and
window limits. Read it there rather than reconstructing it from the scanners, and treat a green
check as "no mistake this scanner recognises", never as proof a command was safe. An agent whose
harness provides no pre-execution hook has no command rail at all.

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
5. **Afterward:** a concise ledger row capturing the durable lesson, not the whole incident
   narrative; archive a larger narrative under `docs/history/` and point to it from the
   `docs/STATE.md` changelog. If a guard or deny rail could have caught it, add one with a
   fixture.

## Acceptance ladder

**One command: `scripts/ladder.sh`** — fast pre-flight guards, then the full verification set.
CI invokes this exact script, so there is no hand-maintained lockstep between what the agent
runs and what CI runs. `--guards-only` covers docs-only changes in seconds.

**What the working-memory size rung prints.** It names whichever of `STATE_WARN_KB`,
`STATE_COMPRESS_TO_KB` and `STATE_HARD_KB` a verdict needs: the soft and hard caps on its
plain `ok`, the floor on its over-cap warn and on its fail lines, and the floor again on the `ok`
confirming a completed compression landing. So a fully green run can name all three, and seeing
the floor in one is not a reason to doubt it — that inference is what release 5.2.1 was cut to
delete. Every one of those prints the configured value **verbatim**; only the landing lines add
arithmetic, reporting the floor in bytes where the key is in KB. Which is precisely why a printed
number is never a value to copy into prose: quoting one back makes a fourth copy of a config key,
the drift class **DB-022** names and no guard here catches (**DB-025**). This paragraph lives here
rather than in `docs/STATE.md`'s length-guard preamble, which carries the RULES, because a
description of a guard's output is not working memory and should not be charged to a byte cap
(owner, 2026-08-11). It describes four branches of `guard_state_size` — the three size verdicts
and the landing `ok` — and not the rung's other lines; read the function when it and this
disagree.

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
