# RUNBOOK — maintenance playbook

<!--
SEED TEMPLATE (AMH). Yours from the moment it is copied. Process docs are code: if a playbook
is wrong, stale or missing the case you just handled, fixing it is part of that change, not a
follow-up. For a small repo, folding this file into the constitution is a legitimate
simplification — split it out when the playbooks multiply.
-->

Entry point for changing the system. Pick the playbook matching your task, read the reference
docs it names, then do the work. **Code + {{IMMUTABLE_FIXTURES}} are ground truth**; where any
doc disagrees with the code, trust the code (and fix the doc) — except the append-only ledger,
whose rows are never edited in place: a correction is a new row plus one appended pointer on
the old one.

## Where logic lives

{{MODULE_MAP — the same shape as the constitution's, one level more detail.}}

## Reference-doc index

| Question | Doc |
|---|---|
| {{QUESTION}} | {{DOC_PATH}} |
| How do I compress `docs/STATE.md`? | this runbook → **Working-memory compression** |

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
   check is restated as *unverified*, naming who settles it — **`Check:` is deliberately not a
   required field**: an item that must carry one will get one, "the owner says so" is a check
   the way a checkbox is evidence, and its absence is information rather than an omission.
   Nothing enforces this and nothing
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
edits are exempt, EXCEPT the state file's rule-bearing sections (its Owner-queue preamble, its
length-guard pointer, its decided non-items). The compression rules themselves live in
**Working-memory compression** below, which is in this runbook and therefore in scope already.

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

**What the working-memory size rung prints — and what it deliberately does not.** It reads
`STATE_WARN_KB`, both compression-floor keys and `STATE_HARD_KB` from `amh.conf`, falling back to its
own defaults for a key you leave out, and **names a threshold only in a verdict that turns on
one**: the hard cap and the floor when it fails over the hard cap, the soft cap and the floor
when it warns above the soft cap, and the floor in the landing failures. A verdict that rejects
nothing names nothing — the plain size line reports your file's size and stops, and the `ok`
confirming a completed landing reports how far **clear of the floor** you landed, in both of
its units, rather than the floor itself. That is not brevity, it is the point: the number a clean run puts
in front of you is the number the next compression aims at, and an instance that had copied "the
cap is a maximum, not a target" into its own prose still shaved a dozen edits to land seven bytes
under the floor. Headroom removes that pull; it is **not a score to maximise** in the other
direction, because a file gutted to stubs prints a large number and passes.

Note the units, because they are what the removal above could not achieve on its own: the
landing verdict is a byte floor AND a sentence floor, and neither is satisfied alone. A pass
that shaved words to cross the soft cap arrives carrying every sentence it started with and
fails on one; a pass that repunctuated to collapse the sentence count freed no space and fails
on the other. The size lines stay byte-only — they say *when* to compress, and nobody drafts
toward them. What still cannot be checked is whether the sentences
that went were the right ones: the length-guard rule governs that — fold whole completed stages,
never shave — and no guard can tell a folded stage from a gutted one.

So **read a threshold from `amh.conf`, not from a green run**: it is the source, a failing verdict
will quote it back at you when one matters, and a number you copy into prose becomes a further
copy that nothing checks against the config. If you left a key out of `amh.conf` entirely, the
value in force is the shipped default at the top of `scripts/ladder.sh` — that is the one case
where the config cannot answer you. Where a verdict does print a configured value it prints it
**verbatim**; only the landing lines do arithmetic, working in bytes where the key is in KB.

Two honest exceptions, so the discipline is not read as wider than it is. The boot banner still
prints your state file's size **against the soft cap**, deliberately: it is read before a session
writes, where knowing you are near the cap is the whole point, and it names the cap rather than
the floor that compression aims at. And the `ok` for a small edit above the cap names
`STATE_EDIT_DELTA_BYTES`, which is the threshold that verdict turns on. This paragraph lives here
rather than in `docs/STATE.md`: a description of a guard's output is not working memory and
should not be charged to that file's byte cap. The rules that governed that file have since
followed it here — see **Working-memory compression** below. It
describes the three size verdicts and the landing `ok`, not the rung's other lines; read
`guard_state_size` when it and this disagree.

## Working-memory compression

The rules for compressing `docs/STATE.md`. They live here rather than in the file they govern,
and that placement is the point: these rules change only under the rule-review protocol, while
the byte cap on `docs/STATE.md` exists to force *volatile* content out. A block of permanent
rules sitting inside that cap spends the budget every compression pass is fighting for, and it
cannot itself be compressed — folding a live rule is repeal. Measure it in your own repository
rather than trusting a proportion: in the harness's own, the two preambles were 2,499 bytes of
a 9,216-byte compression floor, and in this scaffold they were 4,859 bytes of 6,045 before the
adopter had written a line.

**Relocating a live rule is legislation, not tidying — and the destination decides whether it
is repeal.** This runbook is read on demand and every playbook routes into it, so a rule here
still reaches the session that needs it. The ledger and `docs/history/` do not: they are
retrieval storage nobody reads whole, and a live rule there binds nothing. If your ladder
carries a documentation-navigation guard, give this section's heading AND the pointer left
behind in `docs/STATE.md` a row in it — a guard that checks only the heading leaves the pointer
deletable in silence, which is how a relocation quietly finishes becoming a repeal. Without
such a guard the pointer is prose only; say so rather than implying a check you do not have.
Moving any further passage out of working memory stays the owner's call, one grant at a time.

**Thresholds.** `STATE_WARN_KB`, both compression-floor keys and `STATE_HARD_KB` live in
`amh.conf` and are deliberately **not** restated here as numbers: nothing checks this prose
against the config, so a copied number drifts silently the first time a threshold moves. Which
of them the size rung prints, and why a number it printed is never a value to copy back into
prose, are in **Acceptance ladder** above.

**When to compress.** Grow freely to the soft cap; no trimming below that line. Over it, ONE
deep pass landing at or below the compression floor — a ceiling, not a target: anywhere below
is fine, and you do not keep shaving once under. Never trim to just under the soft cap, because
micro-trims re-arm the warning a session later and the wide band IS the debounce, statelessly.
Fail above the hard cap, which is byte-only like the soft cap: those two say WHEN to compress,
and read cost is bytes. A typo fix above the cap is allowed and still owes the pass.

**How far.** The floor is a byte size **AND** a sentence count, and a landing satisfies both.
That is what keeps "a ceiling, not a target" from depending on your restraint: shaving words
cannot move the sentence count, repunctuating cannot move the bytes, and folding whole
completed stages is the only move that clears both. Land short and you fold MORE stages.

**How.** Collapse each completed work stage into one Changelog line, fold changelog clusters,
move durable gotchas into the append-only ledger, and delete narrative prose. Never shave
clauses until the guard goes quiet, and never cut text into another file — that is not
compression, it is the relocation the second paragraph above makes the owner's call.
**Project**, **Current state** and **Owner queue** must always survive it: compress an
Owner-queue item's prose, never drop an open one — closing them is the owner's call.

**What the ladder checks, and what it does not.** `scripts/ladder.sh` machine-checks the band,
the required sections and their non-empty bodies, that no level-2 heading appears twice, that
the Owner-queue heading is still there (a warning, not a failure — the section is the owner's),
and that a compression pass lands on the floor rather than just clearing the warning; above the
cap it tells a pass from an ordinary edit by how much the file shrank
(`STATE_EDIT_DELTA_BYTES`), so the ladder will not fail you for fixing a typo up there — which
is a statement about the guard, not a release: the size warning stays armed and the pass is
still owed. **And that list is the whole of it** — a claim about `guard_state_size` and
`guard_state_structure` in `scripts/ladder.sh`, a file that upgrades independently of this one,
so those two functions are the authority and this sentence is what goes stale when a version
adds a rung, with nothing checking it against the script. Everything else here — what to fold,
what to move to the ledger, whether what survived is any good, and whether you dropped an open
Owner-queue item — is prose no guard will catch you breaking. Never drop one.

**One consequence, since silence reads as approval: the landing check never runs below the soft
cap.** Only a file that started above it reaches that check, though the structure checks run at
every size. So a deep pass on a file already under the cap draws a plain size line and nothing
more: the absence of a check, not a verdict that the edit was right, and exactly the pass the
paragraphs above forbid. Do not reach for a threshold to cover it. It is the SHRINK that is
measured, never the band, and a check treating any large shrink as a compression pass fails a
session for deleting one resolved Owner-queue item from a healthy file — leaving padding the
file back as the only way to pass.

## When CI fails (workflow vs code)

The local ladder and CI run the same script, but the commit, index and worktree are inputs too.
A guard built on `git ls-files` may omit an untracked file; staging it after the local run
changes the input CI receives and can turn local-green into CI-red without any environment
difference. Triage: (1) read the failing log; (2) reproduce from the exact tree state CI
checked, staging new files before the local ladder when a guard's file discovery is
index-dependent; then classify a real failure (fix the code), a toolchain mismatch (fix the
workflow, in the same PR), or a flake (re-run once; never "fix" code for a flake). (3) Never
weaken a gate to get green. (4) Real but out of scope: say so, with the log excerpt.

## Self-adaptation — keep this runbook useful

If this runbook lacks what you need: consult the ledger — and `docs/history/` if this repo has
an archive; not every profile installs one — record durable facts as ledger rows, and if a
playbook is wrong, stale or missing the case you just handled, **fix this runbook in the same
change.** Treat it as code.

Self-adaptation covers *operational* content — playbooks, the doc index, module maps,
commands. *Binding* rules (session discipline, the review protocols, guard semantics, git and
permission policy) are never self-adaptation: they go through the rule-review protocol, and
process-reshaping changes go through the Owner queue (discipline 7).
