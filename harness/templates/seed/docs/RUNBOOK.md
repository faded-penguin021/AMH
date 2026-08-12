# RUNBOOK — maintenance playbook

<!--
SEED TEMPLATE (AMH). Yours from the moment it is copied. Process docs are code: if a playbook
is wrong, stale or missing the case you just handled, fixing it is part of that change, not a
follow-up. For a small repo, folding this file into the constitution is a legitimate
simplification — split it out when the playbooks multiply.
-->

Entry point for changing the system. Pick the playbook matching your task, read the reference
docs it names, then do the work. **Code + {{IMMUTABLE_FIXTURES}} are ground truth**; where any
doc disagrees with the code, trust the code (and fix the doc).

## Where logic lives

{{MODULE_MAP — the same shape as the constitution's, one level more detail.}}

## Reference-doc index

| Question | Doc |
|---|---|
| {{QUESTION}} | {{DOC_PATH}} |

## Change-type playbooks

Each: *when · read first · code to touch · obligations · acceptance · record it.*

### 1. {{CHANGE_TYPE, e.g. "Bug fix"}}

- **Read first:** {{reference docs + related ledger rows}}
- **Steps / code:** {{where the change goes — e.g. reproduce → failing test first → fix so it
  conforms to the fixtures (never edit a fixture to pass) → ladder → adversarial review if the
  diff touches {{UNTESTED_GLUE_AREAS}}}}
- **Acceptance:** {{the binary gate — which ladder rungs}}
- **Record:** {{STATE changelog line; ledger row if durable; which reference doc to update}}

{{Repeat for each recurring change type: feature, config/schema change, dependency or
platform bump (two reviewable commits: forward-compat first, behaviour flip second), release
cut (version invariants; the owner does the tagging), etc.}}

## Session discipline (BINDING for every session)

1. **Strictly sequential.** No parallel subagents; one unit of work at a time. Parallel agents
   on one repo have burned whole usage windows.
2. **Small, shippable units.** About one focused hour, independently shippable, each with a
   hard **binary** acceptance check — never "looks right".
3. **Checkpoint invariant.** Every unit ends: acceptance green → STATE changelog line →
   commit → push. Never start a second unit on top of an uncommitted first. Assume the session
   dies at any moment; an interrupted session must lose at most the unit in flight.
4. **You are the last reviewer.** The review protocols below are mandatory. There is no
   stronger pass behind you.
5. **Multi-unit work** persists an owner-approved plan file plus a STATE checklist; segments
   run sequentially and each ends shippable. At the end, move a completed plan worth retaining
   whole to `docs/history/` if this repository has the archive tier; otherwise delete it. Its
   durable outcomes live in changelog lines and ledger rows either way. Code cites ledger rows,
   never plans: an archived plan is a historical record, not permanent memory.
6. **Recovery (bounded).** If the unit in flight has gone wrong: reset to the last green
   checkpoint, re-run the ladder to confirm green, re-attempt smaller — recording any durable
   lesson first. Recovery is not infinite: if the SAME blocker survives a second
   reset-and-retry with no real progress, stop. Reset once more to green (never end a unit
   red), record the blocker in the Owner queue, commit and push so the record survives session
   death, and end the unit. A gate that will not go green is either a real fix you are missing
   — diagnose it, do not just re-run it — or an owner fork. Neither is solved by burning the
   usage window re-running a script. The stop is for a genuinely stuck blocker, never cover
   for abandoning a failure you could diagnose. Pushed checkpoints are immutable; recovery
   never rewrites pushed history.
7. **Ask, don't assume.** Forks that are (a) irreversible or expensive to unwind (schema
   migration, deleting a feature, renaming a public surface), (b) user-visible behaviour with
   no spec to appeal to, (c) version-semantics ambiguous (readable as minor or major), or (d)
   process-reshaping (changes how the owner works, not just the code) are the OWNER's: stop at
   the last green checkpoint, record the fork with options and your recommendation under
   STATE → Owner queue → Open questions, then move to independent work. Genuinely unsure
   whether something is a fork? Treat it as one — the queue entry already carries your
   recommendation, so escalation costs the owner one read, while a wrong guess can cost a
   segment. Routine engineering judgement inside a unit's stated scope is NOT a fork. The
   final chat message restates the Owner queue — **each item tested first, never copied
   forward.** Run the `Check:` command an item carries and read its OUTPUT against the
   resolution the item states, not its exit status (a check written to detect the unresolved
   condition exits 0 exactly when the item is still open). Resolved means done in this session:
   delete it and record the outcome, rather than restating it with a caveat. An item with no
   check is restated as *unverified*, naming who settles it. Nothing enforces this and nothing
   may: a gate that consumes "I checked" is a self-report.
8. **Verification disclosure.** Every commit body states what was actually verified (which
   ladder rungs and tests ran) and names what could NOT be verified locally. Disclosure of
   real actions, addressed to a human — never something a gate consumes.
9. **Establish coverage before reporting an absence.** Before you report that something does
   not exist or never happened, establish that the command you ran could have seen it, and say
   which artifact you searched. A local artifact was read and the answer reported as a property
   of the repository is the shape to watch for. The standing trap is git: where branches are
   squash-merged, a whole train of sessions arrives as ONE commit and the intermediate states
   are destroyed by design, so `git log`, `git show`, `blame` and `tag` cannot answer questions
   about this repository's past — the ledger and the STATE changelog are the only surviving
   record. This is prose-only and must stay so: the defect is the generalisation drawn from a
   command's output, and no pre-execution rail can see a belief formed after the command
   returned.

## Adversarial review protocol (MANDATORY for {{UNTESTED_GLUE_AREAS}} diffs)

Test suites cannot see all code. After the ladder is green, hand the FULL diff to a
**fresh-context** reviewer (subagent or clean invocation) — given the diff, this checklist and
tree access, but NOT the authoring context, which is anchored on its own rationale and
predisposed to accept it. Scale the reviewer's model tier to the diff: small mechanical change
→ light tier; large or glue-heavy → the strongest available. Self-review is the fallback only
where no fresh context can be spawned.

Hunt these proven bug classes — each one a real shipped bug from this repo's ledger; append
new classes as the ledger grows:

- {{BUG_CLASS + its ledger citation}}

If the pass finds nothing, say so in the commit body ("adversarial pass: clean"); if it finds
something, fix it before the commit and ledger anything durable. That verdict is disclosure to
a human reader, not evidence the pass happened — legitimate only because nothing consumes it.
Never let a guard, a CI step or a merge checklist start requiring the string; a self-report
that gates anything is passed by typing. When a class turns out to be
mechanically testable, encode it as a regression test and retire it from this list — the pass
holds only what the tests cannot see.

## Rule-review protocol (MANDATORY for binding-rule and guard diffs)

Diffs changing the harness's legislation — the constitution, this runbook's protocols, guard
semantics AND their fixture suite, the mechanical rail scripts (a silently weakened rail is a
weakened rail), the session bootstrap, ledger preambles, adapter permission rails — get the
same fresh-context pass at the **strongest tier regardless of diff size**: a three-line rule
edit can carry a semantic bomb, and a bad rule manufactures defects in every future session
that obeys it. **No self-review fallback:** a harness that cannot spawn a fresh context parks
the rule change for the human rather than reviewing its own legislation. Routine state-file
edits are exempt, EXCEPT the state file's rule-bearing sections (its length-guard preamble,
its decided non-items).

The reviewer hunts these rule bug classes (seed the exemplars from your own ledger as they
occur):

- **rule contradiction** — the new rule against an existing binding rule;
- **prose/guard lockstep drift** — a number or behaviour stated in prose diverging from the
  guard constant or logic that enforces it;
- **Goodhart-ability** — the rule can be satisfied while defeating its intent;
- **enforcement asymmetry** — prose implies a check no guard performs (say "prose-only", or
  add the check);
- **citation validity** — cited ledger entries exist AND actually support the claim (the
  citation guard scans configured implementation paths, not doc prose — this half is checked only here);
- **agent-agnosticism regression** — the rule silently assumes one agent's machinery,
  filenames or environment variables.

Verdict in the commit body. The ladder's rule-file tripwire only *surfaces* that this protocol
applies; reviewer attention is the enforcement.

**Three bounds keep the pass a gate rather than a process that eats the unit:**

- **Concurrency: one reviewer at a time, blocking.** Not a background job; you do not keep
  editing while it runs.
- **Iteration: ONE pass per unit.** Triage the findings, apply them, ship — do NOT review the
  corrected diff again. Re-running until a pass comes back clean turns the gate into a loop
  that launders a diff into looking approved. Fixes too large to ship unreviewed mean the unit
  was too big: split it, or hand the residue to the human.
- **Depth: one level of meta.** The reviewer reports, the session triages, the human
  arbitrates. Nobody reviews the reviewer.

Spawning the reviewer is what this protocol requires, not a permission to request — do not ask
each time; escalate the *diff's substance* instead. While the pass is in flight the diff stays
green, uncommitted and unpushed; a harness commit prompt on an idle turn does not override the
gate. Say so once rather than re-explaining every turn.

## Incident: leaked credential

Containment outranks the checkpoint invariant.

1. **Stop.** Never repeat the value again — not in STATE, the ledger, chat or a diff. Refer to
   it by key name only.
2. **Owner queue immediately:** key name, where it landed (SHA / file / log), exposure window.
   Push nothing new containing it.
3. **The owner rotates the credential FIRST.** Rotation is what ends the exposure; the value
   stays burned even after cleanup.
4. **Then** the owner decides on a history rewrite — the ONE sanctioned exception to
   never-rewriting-pushed-history, scoped to removing the secret, **owner-decided AND
   owner-executed**. An agent never runs the rewrite: the deny rail stays for agents, and the
   owner lifts it for themselves.
5. **Afterward:** a ledger row, and if a guard or deny rail could have caught it, add one with
   a fixture test.

## Acceptance ladder

**One command: `scripts/ladder.sh`** — fast pre-flight guards, then the full task set in one
invocation. CI's verification step invokes THIS script, so there is no hand-maintained
lockstep between what the agent runs and what CI runs. `--guards-only` covers docs-only
changes in seconds.

**What the working-memory size rung prints.** It reads `STATE_WARN_KB`, `STATE_COMPRESS_TO_KB`
and `STATE_HARD_KB` from `amh.conf` — falling back to its own defaults for a key you leave out —
and names whichever a verdict needs: the caps on its size line, the floor when it warns over the
cap, when it fails, and again on the `ok` confirming a completed compression landing. A fully
green run can therefore name all three, and seeing the floor in one is not a sign of trouble.
Every one of those prints your configured value **verbatim**; only the landing lines add
arithmetic, reporting the floor in bytes where the key is in KB. Which is precisely why a printed
number is never a value to copy back into prose: quoting one makes a further copy of a config key,
and nothing checks a copy against the config. This paragraph lives here rather than in
`docs/STATE.md`'s length-guard preamble, which carries the RULES: a description of a guard's
output is not working memory and should not be charged to that file's byte cap. It describes the
three size verdicts and the landing `ok`, not the rung's other lines; read `guard_state_size` when
it and this disagree.

## When CI fails (workflow vs code)

The local ladder and CI run the same script, so CI-red with local-green means environment, not
code. Triage: (1) read the failing log — a real failure (fix the code), a toolchain mismatch
(fix the workflow, in the same PR), or a flake (re-run once; never "fix" code for a flake).
(2) Never weaken a gate to get green. (3) Real but out of scope: say so, with the log excerpt.

## Self-adaptation — keep this runbook useful

If this runbook lacks what you need: consult the ledger — and `docs/history/` if this repo has
an archive; not every profile installs one — record durable facts as ledger rows, and if a
playbook is wrong, stale or missing the case you just handled, **fix this runbook in the same
change.** Treat it as code.

Self-adaptation covers *operational* content — playbooks, the doc index, module maps,
commands. *Binding* rules (session discipline, the review protocols, guard semantics, git and
permission policy) are never self-adaptation: they go through the rule-review protocol, and
process-reshaping changes go through the Owner queue (discipline 7).
