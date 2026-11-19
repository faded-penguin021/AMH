# PROTOCOLS — what binds every session

<!--
SEED TEMPLATE (AMH). Yours from the moment it is copied. The procedures every session in this
repository works under, whatever its task: the constitution sends every session here, and the
change-type playbooks in docs/RUNBOOK.md route into these sections. Editing this file is a rule
change, so it goes through the Rule-review protocol below; the runbook's self-adaptation does
not reach it.
-->

The task-specific half — the module map, the change-type playbooks, CI triage — is in
`docs/RUNBOOK.md`. This file is the half no task is exempt from.

## Session discipline (BINDING for every session)

1. **Strictly sequential.** No parallel subagents; one unit of work at a time. Parallel agents
   on one repo have burned whole usage windows.
2. **Small, shippable units.** About one focused hour, independently shippable, each with a
   hard **binary** acceptance check — never "looks right".
3. **Checkpoint invariant.** Every unit ends: STATE changelog line → acceptance green →
   commit → commit-metadata check → push. The changelog line comes FIRST so the ladder verifies
   the tree that is committed. The check after the commit is `scripts/ladder.sh --guards-only`:
   its poison-token and author-identity rungs read commits, so the run before the commit cannot
   see the one being made, and the git-native pre-push rail judges refs, never messages or
   identities. A failure there is fixed by amending the unpushed commit and running the check
   again; a WARN that either rung checked NOTHING means the check did not happen — fetch the
   reference it names and re-run, or report that it did not run. Never start a second unit on
   top of an uncommitted first. Assume the session
   dies at any moment; an interrupted session must lose at most the unit in flight.
4. **You are the last reviewer.** The review protocols below are mandatory. There is no
   stronger pass behind you.
5. **Multi-unit work** persists an owner-approved plan file plus a STATE checklist; segments
   run sequentially and each ends shippable. At the end, move a completed plan worth retaining
   whole to `docs/history/` if this repository has the archive tier; otherwise delete it. Its
   durable outcomes live in changelog lines and ledger rows either way. Code cites ledger rows,
   never plans: an archived plan is a historical record, not permanent memory. **And no ledger
   row may cite a plan's PATH** — not in backticks, not as a link, not as a bare filename. A plan
   is provisional context, not permanent evidence, so the citation goes dead the moment the plan
   retires, in a row that can never be repaired. Record what the plan DELIVERED in the row; name
   the plan in prose if you must refer to it, in a form no path guard resolves. **A legacy
   citation does NOT pin its plan.** A row's immutability covers the row's text, not the lifetime
   or location of a file it names: the row keeps its historical wording and the plan completes
   archive-or-delete like any other. A path guard here must let it — a citation resolves in the
   tree where its row is authored, and a target that moves or disappears afterwards is historical
   path drift, reported as unknown rather than guessed at when the history that would settle it
   is missing from the checkout.
6. **Recovery (bounded).** If the unit in flight has gone wrong: reset to the last green
   checkpoint, re-run the ladder to confirm green, re-attempt smaller — recording any durable
   lesson first. Recovery is not infinite: if the SAME blocker survives a second
   reset-and-retry with no real progress, stop. Reset once more to green (never end a unit
   red), record the blocker in the Owner queue, then close it like any unit — ladder, commit,
   commit-metadata check, push (item 3) — so the record survives session death, and end the
   unit. A gate that will not go green is either a real fix you are missing
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
   real actions, addressed to a human — never something a gate consumes. The post-commit
   metadata check cannot be disclosed in the commit it judges; report it where the session
   reports its outcome.
9. **Establish coverage before reporting an absence.** Before you report that something does
   not exist or never happened, establish that the command you ran could have seen it, and say
   which artifact you searched. A local artifact was read and the answer reported as a property
   of the repository is the shape to watch for. The standing trap is git: where branches are
   squash-merged, a whole train of sessions arrives as ONE commit and the intermediate states
   are destroyed by design. `git log`, `git show`, `blame` and `tag` still show each merged
   snapshot and what changed between them, but not what happened inside a train, in what order
   or why, and a search of them cannot establish that something never happened — for those
   questions the ledger and the STATE changelog are the only surviving record. This is
   prose-only and must stay so: the defect is the generalisation drawn from a
   command's output, and no pre-execution rail can see a belief formed after the command
   returned.
10. **A unit owes the review of what it was set to change, never only that of the diff it
   ends with.** Decide which pass the unit owes — the adversarial pass, the rule-review pass,
   or a review its plan names — from the change it was planned or asked to make, before the
   work starts. A unit framed as evaluating whether to make a change owes that change's pass,
   because its outcome is that decision, and an asked unit's change is the ask as the owner
   wrote it, not the session's paraphrase of it. Keep the pass when the unit ends smaller, and
   above all when it concludes the change is not needed: the reviewer then gets what the unit
   was set to change, the conclusion and the evidence it rests on — the attempt, the
   measurement — but, as with a diff, not the author's argument for it; it works at the tier
   the planned change would have earned and replays that evidence first (item 11). "No code
   changed, so no review" is the shape to watch for. "Not needed" is the cheapest outcome a
   unit can reach, and if it also removed the review that would test it, doing less would be a
   route past every gate — the laundering of re-reviewing until a pass comes back clean,
   reached by shrinking instead. Concluding "not needed" is an outcome the pass tests;
   redefining what a unit of an owner-approved plan was set to change is the owner's call
   (item 5). A unit that stops at a blocker (item 6) or a fork (item 7) has concluded nothing:
   it parks, and its pass waits with it. The commit body says what the unit was set to change
   and which pass that owed (item 8) — a disclosure nothing consumes. "A unit is what one
   reviewer saw" counts passes; this item says which pass is owed. The acceptance ladder still
   follows the tree — a docs-only result runs the docs-only gate — because the ladder checks what was
   committed, while the pass checks a judgement. Prose-only: which pass a unit owes is decided
   from intent, which no guard can read.
11. **A decision says whether its evidence was measured, estimated or reported.** A ledger row,
   commit message or report that rests a decision on a number or an outcome — a diff size, a
   line count, "it came out longer", "it does not reproduce" — says how it got it: measured,
   naming the command, with its input kept where the reviewer can reach it until the pass
   reports; estimated by reading; or reported by someone else, naming who. A past tense is a
   measurement claim: "it came out longer" asserts that an attempt was built. A measurement
   nobody can replay reads as an estimate. A ledger row outlives every session branch, so it
   carries the number and the command themselves and names no branch, as item 5 rules for a
   plan's path. Where a pass is owed its reviewer replays what it can (item 10); elsewhere the
   reader is the only check. Prose-only, and it must stay so — nothing in the artifacts tells
   an estimate from a measurement, and a required "measured:" field would be filled either
   way; the sentence stays a disclosure because nothing consumes it.
12. **A fix's test is written before the fix, and existing tests are frozen for the fix.**
   (a) For a defect, write the test that reproduces it and run it against the unfixed tree
   before any fix is written. It must fail for the reason the report names: a failure on a
   typo, a missing import or an unrelated assertion has reproduced nothing. Then write the fix.
   The test committed is the test that was seen failing: one edited after the fix was written
   is run against the unfixed tree again. The failing test is never committed on its own; the
   unit ends green, with the test and the fix in one commit (item 3). Where a defect cannot be
   reproduced in a test, the commit body says so and says what was done instead.
   (b) A test that existed before the fix is not the fix's to change. Changing,
   skipping, loosening or deleting one is a second decision, and "a test" includes what decides
   whether it runs and what it accepts: fixtures and golden data, shared helpers, the runner's
   exclusions and tolerances. A test changed to make way for a fix is covered whichever unit
   changes it. That unit owes a fresh-context pass, run as the adversarial pass below with two
   differences: the strongest available tier whatever the diff's size, and no self-review
   fallback. Where no fresh context can be spawned, the test stays as it was and the question
   goes to the Owner queue. The reviewer gets the old test, the new one, and the defect report
   as it was received (or the reproduction, where the session found the defect itself), and
   judges whether the old test was wrong by the specification, never by the fix. Where no
   specification settles what the behaviour should be, that is the owner's fork (item 7), not
   the reviewer's. Where the unit already owes a pass, it is the same pass. Adding a test is
   not covered. The reason for both: a test written after the fix is written from the fix, and
   showing that it fails without the fix does not tell the two apart, so both demonstrations
   are owed. The same session may write both. Order keeps the test from asserting whatever the
   fix's code happens to do; it does not keep the test from sharing the session's diagnosis.
   Prose-only: nothing records the order, and no guard reads the diff for a changed test. The
   commit body says the test was seen failing first and names any pre-existing test the unit
   changed, a disclosure nothing consumes (item 8).

## Adversarial review protocol (MANDATORY for {{UNTESTED_GLUE_AREAS}} diffs)

Test suites cannot see all code. After the ladder is green, hand the FULL diff to a
**fresh-context** reviewer (subagent or clean invocation) — given the diff, this checklist and
tree access, but NOT the authoring context, which is anchored on its own rationale and
predisposed to accept it. Scale the reviewer's model tier to the diff: small mechanical change
→ light tier; large or glue-heavy → the strongest available. Self-review is the fallback only
where no fresh context can be spawned. A unit set to make such a change owes this pass even
when it ends without one; the reviewer then reviews its conclusion (Session discipline 10).
A fix that changes, skips, loosens or deletes a test that existed before it owes this pass too,
whatever areas its diff touches, at the strongest available tier and with no self-review
fallback (Session discipline 12).

Hunt these proven bug classes — each one a real shipped bug from this repo's ledger; append
new classes as the ledger grows:

- {{BUG_CLASS + its ledger citation}}

If the pass finds nothing, say so in the commit body ("adversarial pass: clean"); if it finds
something, fix it before the commit, ledger anything durable, and re-run the ladder on the
corrected tree before committing (Session discipline 3). That verdict is disclosure to
a human reader, not evidence the pass happened — legitimate only because nothing consumes it.
Never let a guard, a CI step or a merge checklist start requiring the string; a self-report
that gates anything is passed by typing. When a class turns out to be
mechanically testable, encode it as a regression test and retire it from this list — the pass
holds only what the tests cannot see.

## Rule-review protocol (MANDATORY for binding-rule and guard diffs)

Diffs changing the harness's legislation — the constitution, this file, guard
semantics AND their fixture suite, the mechanical rail scripts (a silently weakened rail is a
weakened rail), the session bootstrap, ledger preambles, adapter permission rails — get the
same fresh-context pass at the **strongest tier regardless of diff size**: a three-line rule
edit can carry a semantic bomb, and a bad rule manufactures defects in every future session
that obeys it. A unit set to change legislation owes the pass even when it ends without a
diff (Session discipline 10). **No self-review fallback:** a harness that cannot spawn a fresh context parks
the rule change for the human rather than reviewing its own legislation. Routine state-file
edits are exempt, EXCEPT the state file's rule-bearing sections (its Owner-queue preamble, its
length-guard pointer, its decided non-items). The compression rules themselves live in
**Working-memory compression** below, which is in this file and therefore in scope already.

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
- **Iteration: ONE pass per unit.** Triage the findings, apply them, re-run the LADDER on the
  corrected tree (a check, not a second review), ship — do NOT review the
  corrected diff again. Re-running until a pass comes back clean turns the gate into a loop
  that launders a diff into looking approved. Fixes too large to ship unreviewed mean the unit
  was too big: split it, or hand the residue to the human.
- **Depth: one level of meta.** The reviewer reports, the session triages, the human
  arbitrates. Nobody reviews the reviewer.

Spawning the reviewer is what this protocol requires, not a permission to request — do not ask
each time; escalate the *diff's substance* instead. While the pass is in flight the diff stays
green, uncommitted and unpushed; a harness commit prompt on an idle turn does not override the
gate. Say so once rather than re-explaining every turn. When it reports: triage, apply, re-run
the ladder on the corrected tree, commit.

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

| Configuration key | Behavioral category | Action point |
|---|---|---|
| `STATE_WARN_KB` | trigger | crossing it makes compression mandatory |
| `STATE_HARD_KB` | rejection boundary | crossing it fails the state-size rung |
| `STATE_COMPRESS_TO_KB`, `STATE_COMPRESS_TO_SENTENCES` | post-action ceiling | a compression result must satisfy both |
| `STATE_EDIT_DELTA_BYTES` | trigger | a shrink at or above it is treated as a compression pass |
| `LEDGER_ROW_SENTENCE_CAP`, `LEDGER_ROW_CHAR_CAP` | rejection boundary | crossing either rejects a new row |
| `LEDGER_LINE_CAP` | rollover boundary | a later row starts a new volume |
| live-ledger byte size | measurement only | the rung reports it and never judges it |

At every authoring action point, boundaries determine when machinery intervenes, not how much
content an author should produce.

**What the working-memory size rung prints — and what it deliberately does not.** It reads
`STATE_WARN_KB`, both post-compression ceiling keys and `STATE_HARD_KB` from `amh.conf`, falling back to its
own defaults for a key you leave out, and **names a threshold only in a verdict that turns on
one**: the rejection boundary and the post-action ceilings when it fails over the rejection boundary, the compression trigger and the post-action ceilings
when it warns above the compression trigger, and the post-action ceilings in the landing failures. A verdict that rejects
nothing names nothing — the plain size line reports your file's size and stops, and the `ok`
confirming a completed landing reports how far **below the post-action ceilings** you landed, in both of
its units, rather than the post-action ceilings themselves. That headroom is a measurement, not a score or an
invitation to retain more: a file gutted to stubs also prints a large number and passes.

Note the units, because they are what the removal above could not achieve on its own: the
landing verdict is a byte ceiling AND a sentence ceiling, and neither is satisfied alone. A pass
that shaved words to cross the compression trigger arrives carrying every sentence it started with and
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
prints your state file's size **against the compression trigger**, deliberately: it is read before a session
writes, where knowing you are near the cap is the whole point. The `ok` for a small edit above the cap names
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
a 9,216-byte post-action ceilings, and in this scaffold they were 4,859 bytes of 6,045 before the
adopter had written a line.

**Relocating a live rule is legislation, not tidying — and the destination decides whether it
is repeal.** This file is bound on every session and every playbook routes into it, so a rule
here still reaches the session that needs it. The ledger and `docs/history/` do not: they are
retrieval storage nobody reads whole, and a live rule there binds nothing. If your ladder
carries a documentation-navigation guard, give this section's heading AND the pointer left
behind in `docs/STATE.md` a row in it — a guard that checks only the heading leaves the pointer
deletable in silence, which is how a relocation quietly finishes becoming a repeal. Without
such a guard the pointer is prose only; say so rather than implying a check you do not have.
Moving any further passage out of working memory stays the owner's call, one grant at a time.

**Thresholds.** `STATE_WARN_KB`, both post-compression ceiling keys and `STATE_HARD_KB` live in
`amh.conf` and are deliberately **not** restated here as numbers: nothing checks this prose
against the config, so a copied number drifts silently the first time a threshold moves. Which
of them the size rung prints, and why a number it printed is never a value to copy back into
prose, are in **Acceptance ladder** above.

**When to compress.** Compress by lifecycle, not by file size: once a stage is complete, fold
its narrative and route its durable lessons even below the compression trigger. The compression trigger only makes a
compression pass mandatory before further substantive work; the rejection boundary remains a byte-only
failure boundary. A typo fix above the compression trigger is allowed and still owes the pass.

Here, boundaries determine when machinery intervenes, not how much content an author should
produce.

**How far.** After compression, keep only current state, unresolved Owner-queue items,
immediate operational gotchas, and concise Changelog pointers. The configured byte and sentence
values are post-compression acceptance ceilings, satisfied together, not retention goals. There
is no reward for keeping text because space remains, no preferred landing size, and no need to
add, preserve or reshape content to approach either ceiling. A substantially smaller file is
equally successful — and often better — when it retains everything live.

**How.** Decide each fold by whether the stage is complete, never by proximity to a number.
Collapse completed stages into concise Changelog pointers, fold changelog clusters, move durable
lessons into the append-only ledger before deleting their narrative, and retain only immediate
operational gotchas. Never shave clauses until the guard goes quiet, and never cut text into
another file — that is not compression, it is the relocation the second paragraph above makes
the owner's call.
**Project**, **Current state** and **Owner queue** must always survive it: compress an
Owner-queue item's prose, never drop an open one — closing them is the owner's call.

**What may be in `Current state` at all — the content rule beside the size rule.** Compression
decides how much survives; this decides what is eligible. Three categories, and only the first is
unqualified truth here:

1. **Repository-controlled** — true of the checked-out tree until another repository change alters
   it: the version the tree declares, implemented behaviour, tracked active work, the live ledger
   volume — the VOLUME, never its latest row id, which every append moves and no sentence
   follows. This is what `Current state` is for.
2. **World-controlled** — can change with no change to the tree: whether a branch merged, whether a
   remote tag or release exists, PR and CI status, deployments, remote branches, forge protection
   settings. Never cached here as current truth.
3. **Historical observation** — a past external fact kept because it is still useful, scoped in the
   sentence to when or where it was observed so it cannot read as present status.

Apply the test before writing a sentence: *would it still be accurate if this same commit were
cloned tomorrow, under another branch name, after forge state had moved?* If not, route it. Where
a live probe already computes the fact, point at the probe rather than copying its output — the
session-start banner's release line is one, so name the probe and not its last answer. Where a
session cannot inspect the setting (branch protection, a remote's configuration), state the
expectation or the unresolved owner action without claiming to have observed it. Where the
resolution is an external action, it belongs in the Owner queue with its `Check:`, not here.

Two limits, so this is not read wider than it is. The scope is `Current state`; it does not reach
the Changelog or the ledger pointers, which are historical storage by construction — a dated line
calling a train "unreleased" records when it was written, and no session owes a re-validation of
what a past row said. And it
is **prose-only** — no guard reads a State sentence for temporal validity, and none is proposed:
the discriminator is meaning, which is what this harness refuses to build gates on. Do not add one,
and do not make startup grep this file for forbidden phrases.

**What the ladder checks, and what it does not.** `scripts/ladder.sh` machine-checks the band,
the required sections and their non-empty bodies, that no level-2 heading appears twice, that
the Owner-queue heading is still there (a warning, not a failure — the section is the owner's),
and that a compression pass lands on the post-action ceilings rather than just clearing the warning; above the
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
