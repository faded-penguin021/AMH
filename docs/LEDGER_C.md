# DEVIATIONS & DISCOVERIES LEDGER — volume C (DC-001…)

> **Append-only registry — NEVER archived, compressed or truncated.** This is volume C,
> opened when `docs/LEDGER_B.md` reached its line cap (800 at the time) at row DB-040. Rows
> in the previous volumes are never moved or renumbered, and a citation's prefix names its
> file: `D-NNN` resolves in `docs/LEDGER.md`, `DA-NNN` in `docs/LEDGER_A.md`, `DB-NNN` in
> `docs/LEDGER_B.md`, `DC-NNN` here. Code and docs
> cite entries as bare IDs and those citations must always resolve; no entry is ever deleted
> or summarised away. Note the asymmetry: citations from **code and workflows** are
> machine-checked (`CITATION_SCAN_PATHS`), citations from **prose are not checked at all** —
> docs are deliberately out of scan scope, because prose mentions IDs without citing them. A
> dangling ID in a doc will not fail the build; that one is on the reviewer. Append new
> entries at the bottom, one continuous sequence.
> Code and fixtures are ground truth: where an entry conflicts with the current code, the code
> wins and the entry stays exactly as written. **Rows are immutable — never edit one in
> place.** A correction is a NEW row plus one appended pointer line on the old one, and there
> are two verbs: `Superseded by D-NNN.` when the whole row is replaced, `Corrected by D-NNN.`
> when one detail went stale under a principle that still stands. Both are append-only and
> mechanically identical; the guard checks the FORM and cannot check which verb is honest, so
> that half is the reviewer's. **Appending the pointer is required, not optional, whenever a
> change knowingly falsifies part of a committed row** — nothing can detect an omitted one,
> which is exactly why it is written here. A row carries at most one pointer, ever, and the
> first is FINAL: the guard refuses a second pointer and refuses to rewrite the first, so a
> wrong verb is unrepairable.
>
> **This file is RETRIEVAL storage: grep it and cite it, never read it whole.** A `DC-NNN`
> citation resolves to one row, and one row is what you read. A volume at its cap is tens of
> kilobytes of prose whose overwhelming majority is irrelevant to any given session, so
> reading it end to end spends a context budget better spent on the code you came to change —
> and the ladder's cap rung prints this volume's size in KB beside its line count for exactly
> that reason (**DA-022**), because it is the live one. Closed volumes are never measured.
> Nothing in the harness has ever asked for a whole-volume read; this sentence exists because
> nothing forbade one either.
>
> **Search before appending.** Grep ALL volumes for the topic first; extend or cite an
> existing row rather than append a near-duplicate. A row that supersedes an older one says
> so ("supersedes DB-NNN") and the old row gets a `Superseded by` pointer, never deletion.
> **Keep new rows concise and at or below `LEDGER_ROW_SENTENCE_CAP`.** The working limit counts
> SENTENCES (**DC-003**), which is what stops "a maximum, not a target" depending on restraint:
> a draft over it cannot be reworded into compliance, only shortened by a whole sentence. It is
> not a claim that the count cannot be gamed — repunctuating would move it — which is why the
> `LEDGER_ROW_CHAR_CAP` backstop stays underneath and a row satisfies both. Write only the
> durable lesson, even when that takes far less space; do not draft a narrative and shave it
> toward the cap, because shaving buys nothing here. Put larger narratives in `docs/history/`
> and link them from the `docs/STATE.md` changelog.
>
> **File cap & rollover.** This file holds at most `LEDGER_LINE_CAP` lines from `amh.conf` (the
> cap bounds LINES, not rows — it is read cost that is being bounded). New rows are capped by
> `LEDGER_ROW_SENTENCE_CAP`, and beneath that by `LEDGER_ROW_CHAR_CAP`; the guard counts bytes
> under `LC_ALL=C` for a locale-stable result, so ASCII text is one byte per character and
> non-ASCII UTF-8 is charged by encoded bytes. The byte cap is a backstop against sentences that
> run away and sits far above where a compliant row lands — if it fires, the row is a narrative
> and belongs in `docs/history/`, not in tighter wording. Neither
> value is restated here as a number, and neither should be: nothing checks preamble prose
> against `amh.conf`, and the 5.0.0 cap change left three volume preambles contradicting the
> guard (**DB-022**). The ladder quotes a value in the verdict that TURNS ON it — a rejection must say what it rejected against — and a green run deliberately quotes neither, because the number a clean run shows you is the number the next row is drafted toward (**DB-040**). Read both from `amh.conf`. Rows already committed when checked are historical and exempt. The final row may
> finish past the file cap, but no row may
> ever *start* past it: when this file stands over the cap, create LEDGER_D.md (this file's
> name with a _D suffix) with the same header discipline, numbering from **DD-001**. It is
> named without backticks on purpose — a name in backticks is a citation, and the path-refs
> guard resolves citations against the real tree. **You do not have to work that name out:
> the ladder's rollover failure prints the next volume's file name AND its row prefix,
> computed rather than looked up.** The exact spelling still matters: the ladder reaches this
> file by walking the chain of names the scheme generates, so a volume named any other way is
> not part of it — the cap rung warns and names such a file, and nothing reads its rows.
>
> **The scheme does not stop at Z, and the volumes are a CHAIN** (U5, shipped 2026-08-04;
> **DB-007** is the record, and the two defects the blocking pass found inside the fix are
> worth reading before touching any of this). The row pattern both the cap rung and the
> citation guard use is `D[A-Z]*-[0-9]+`, matched as a whole word, so a `DAA-001` row is seen —
> under the one-letter pattern it matched nothing, which made it invisible to the cap check AND
> unresolvable as a citation in both directions, with every rung green. The next suffix is an
> odometer over A–Z with carry (Z→AA, AZ→BA, ZZ→AAA), so there is no last entry to fall off.
> The live volume is found by WALKING that same carry rule from LEDGER.md and stopping at the
> first missing link: a volume is a file the scheme can reach, never a file whose name looks
> right. Rows are read from the chain too, so this rung and the citation guard cannot disagree
> about what a volume is. A volume-shaped file the walk does not reach is named in a warning
> and its rows are read by nothing; a missing LEDGER.md with continuations present is a
> failure, because `skip` reads like a pass.
>
> **`[cited]` marker (machine-CHECKED — you write it, the ladder verifies it).** A row cited
> from the ladder's scan scope carries ` [cited]` after its number. The ladder checks it in
> BOTH directions — cited-but-unmarked and marked-but-uncited each fail the build — but it
> never edits this file: nothing syncs the marker for you. The marker warns you that code
> resolves here before you lean on or reword a row. Known Goodhart path, unguarded: the
> cheapest way to strip a protected row's marker is to delete the code comment citing it,
> which the guard then *requires*. If you find yourself doing that, you are removing the
> warning rather than heeding it. **One carve-out, and only one:** a citation inside a
> SHIPPED script is not a citation at all in the tree that receives it — those rows are ours
> and can never exist in an adopter's ledger — so removing one is correcting a false promise,
> not evading a warning. The reasoning prose stays and the row is named in a form the guard
> does not read (`AMH ledger row DCNNN`). That carve-out is no longer prose you have to
> remember:
> `scripts/guards/shipped-citations.sh` fails on a real id in anything this repository installs
> into an adopter's citation-scan paths — the shipped scripts, the seed scripts and the CI
> workflow, whatever the file extension. The one exception is the shipped fixture suite, whose
> ids are fixture material; the `CITATION_EXCLUDE` default in `harness/templates/amh.conf.example`
> keeps that file out of the scan of any adopter whose own `amh.conf` carries the key, and an
> adopter whose config predates it does not get the exclusion. Anywhere else, the sentence above binds.

- DC-001: **Redirections are syntax — strip them before any word is judged.** The push rail
  counted `2>` and `>/dev/null` as refspecs, denying `git push -u origin session/x 2>&1` for
  "naming another branch" — false of the command it read. Filtering the refspec loop alone was
  both too narrow and too broad: a redirection between `git` and `push` had always hidden
  `--force` and `--mirror`; one before the command word hid the command itself; and filtering
  already-unquoted words read a literal `'2>'` argument as syntax and swallowed the `--force`
  behind it, D-007 one layer down. One quote-aware strip now runs first, in every position.
  Sessions route around rails (**DB-030**); a rail provably wrong about what it just read
  supplies the argument.

- DC-002: **"Not judged" and "nothing to object to" must never share an exit path** — a rail's
  form of the failure DA-008 records for generators. A scanner read its word list through a
  process substitution; an empty read took the "no words" branch and ALLOWED the command, so
  the rail could report a clean read of text it never parsed. Observed as 18 fixtures red on
  stock macOS Bash 3.2 and green on a re-run at the same commit; the mechanism is inferred, not
  proven, and the contiguity of the failing block fits sustained pressure over a window rather
  than a per-call coin flip. Removing the subshells is the repair. The fail-closed arms are a
  tripwire for the next transport, unreachable against these parsers by construction, which is
  the honest claim for them.

- DC-003 [cited]: **A limit an agent writes toward needs a second unit, because one unit is
  always cheap to satisfy.** The state floor and the new-row cap were byte thresholds, and both
  produced the same reflex: a draft over the line got trimmed word by word until it fit, landing
  7 bytes under the floor in one instance and going 874 to 797 against an 800-byte cap in
  another. Removing the number from green output (**DB-040**) could not reach it, because a
  session measures its own draft against a cap it read from `amh.conf` — the anchor is the cap,
  not the report of it. Counting sentences kills the shave, since the smallest edit that moves
  that count deletes a whole sentence; the review pass then showed a sentence floor alone is
  just as cheap to satisfy in the other direction, rewriting `. T` to `; t` across this state
  file from 85 sentences to 41 while freeing no byte at all. So an aim-point is bounded in both
  units and a landing satisfies both, each blocking the move that fools the other, while bytes
  still stand alone where nobody drafts: the soft and hard caps, and the edit delta.

- DC-004: **When a rail asks for something it cannot see, make the compliant move the one that
  removes the hazard, and make the sidestep leave a trace.** The `rm -rf` advisory spends a turn
  on a check no guard can observe, so a session cleared it by renaming the target and dropping
  the deletion — one round of wording had already been tried against exactly that move. Two
  layers replaced a second round: the advisory now asks for `"${d:?}"`, whose presence IS the
  protection rather than evidence of one — bounded to unset-or-empty, since a set-but-wrong
  variable still deletes — and the signature folds `${d}` and `${d:?}` onto `$d`
  so that the rewrite the rail requested counts as the rerun instead of arming a second prompt.
  Beside it the rail records whether an advised command ever came back, and the ladder prints the
  ones that did not as a note no counter, exit code or gate reads. The claim stays bounded on
  purpose: this cannot tell whether anyone looked, only that a prompt fired and the command was
  abandoned, which is the one fact about compliance the rail actually holds. Building it found
  the brace hole in `split_segments` — an unquoted `${d}` operand records the target `$`, so two
  unrelated deletions clear each other.

- DC-005: **A lenient counting heuristic must be tested for false positives, not only known
  exclusions.** The sentence counter promised to undercount rather than reject honest prose,
  yet its fixtures covered only the two abbreviations its implementation already named; a
  title or initialism created phantom sentences. The same adversarial pass found two lockstep
  defects outside that fixture's frame: fd duplication was split before redirections were
  stripped, hiding a destructive push, and the ladder's no-config byte backstop disagreed with
  both shipped configs. Each repair pins the boundary that made the promise false: titles and
  initialisms, a duplication before operands, and an otherwise-valid row between the old and
  adopted defaults.

- DC-006: **"AMH manages stored context but not the model's window" is a true observation with
  no agent-neutral mechanism behind it — it closes as a non-item, not a backlog entry.** An
  external-harness comparison raised it, and three candidates died in turn: a byte budget over a
  declared read set cannot reach source code, which is where a real project's window actually
  goes and whose read set is discovered by grepping toward a bug rather than declared in
  advance. A closed read set breaks fixes across hidden coupling — the invariant sits in a file
  nothing in the changed one names, so the list is weakest exactly where it matters — and it
  contradicts session discipline 9, which requires establishing that a search COULD have seen
  the thing before reporting its absence. A curated read floor survives both objections but is
  already what every host harness does unprompted, so it buys no behaviour this repo lacks, and
  an index that goes stale is then a net loss: it replaces "look around" with a confident wrong
  pointer that stops the search. Reopening needs a mechanism that acts on the window itself,
  which no agent-neutral substrate exposes — a session cannot read its own token count, and
  prose cannot evict what a host already injected.

- DC-007: **Same script does not mean same verification input, and an opaque editing style is
  not a rail-shaped hazard.** A downstream comment-budget guard used `git ls-files`, so its
  local run omitted a new untracked test and CI counted the file only after it was staged; the
  runbook's claim that local-green/CI-red could only be environmental directed diagnosis away
  from the index state that caused it. In the same report an agent used an interpreter heredoc
  for a multi-site replacement instead of its host's structured edit tool, making review
  needlessly opaque, but AMH cannot prefer a built-in tool agent-neutrally and cannot infer
  arbitrary interpreter writes without inspecting heredoc program text that the command rail
  deliberately treats as data. Correct the false CI claim and leave editing-tool choice to
  host guidance and reviewer judgement; a Python-write advisory would block ordinary
  interpreter use while still missing equivalent writes in every other language.

- DC-008: **An `Unreleased` heading must not hide a missing version bump from the lockstep
  guard.** A release was described as PATCH impact and placed under an
  `Unreleased` changelog heading while all five hand-maintained copies still named the
  published 8.0.0; `version-lockstep.sh` skipped nonnumeric headings, found 8.0.0 below, and
  passed. The guard now requires the first changelog entry itself to name `harness/VERSION`,
  with a fixture that reproduces that exact green omission; it does not infer release impact
  from arbitrary prose added beneath an already-current numeric entry.

- DC-009: **A git-native pre-push rail earns its place — the publication invariants gain a
  layer git invokes rather than the agent.** D-016 item 1 was the incident: a `<<<` here-string
  defect voided command-guard's force-push and push-to-default rails, leaving server-side branch
  protection as the only surviving layer, which earns a second independent enforcement point
  instead of trusting one parser never to regress. The idea came from AGit
  (github.com/hudishkin/agit), whose pre-push hook AMH borrows ONLY as Git-level enforcement of
  invariants it already holds — rejecting AGit's human `finish`/token flow, worktree
  concurrency, local mirror and doctor. `command-guard.sh --pre-push` judges git's per-ref stdin
  by OUTCOME (default-branch, non-fast-forward as force-by-effect, deletion) and carries NO
  branch-prefix check, because DA-022 established the harness assigns branch names the repository
  does not prefix, so a prefix rail would reject the very branches it protects. It binds a
  hook-less agent's pushes since git runs it whatever drives the shell, but it is a guardrail not
  a boundary: `--no-verify` skips it, it sees git-CLI pushes only and never a forge-API push, and
  `.git/hooks` is untracked so session-start.sh installs it non-clobbering every boot. The
  forge/API mutation surface AGit also guards is left as an adversarial test vector, not
  machinery, until a real session crosses that boundary (Owner queue).

- DC-010: **A shell-syntax splitter must distinguish command-group braces from parameter-
  expansion braces.** `split_segments` treated every unquoted `{` and `}` as a command
  separator, so `rm -rf ${a}/x` reached the destructive advisory as `rm -rf $`. Every such
  target therefore shared one signature: clearing the advisory for `${a}/x` silently cleared
  it for `${b}/y`, and the truncated operand also lost the rootish empty-variable warning.
  The splitter now counts `${...}` nesting while leaving ordinary command-group braces as
  separators. Fixtures pin both cross-target rearming and the stronger warning, including a
  nested expansion; the old splitter fails all three.
- DC-011 [cited]: **A destructive rail scoped by verb has a blast-radius blind spot, and gating it on
  "the target is a variable" alone rewards the more dangerous spelling.** A public incident
  report showed `git worktree add -q --detach "$TEMP_WT" HEAD` run with `$TEMP_WT` unset and
  the repository directory emptied — a shape the rail already detected via
  `DESTRUCTIVE_ROOTISH` but only ever computed for `rm -r -f` and `git clean -f -d`, so
  `rm -rf "$TEMP_WT"` was advised while the worktree spelling was not. The dispatch now
  extends DB-014's category to `git rm -r -f` and the tree-mutating verbs
  `worktree add|remove|move`, `reset --hard`, `checkout|switch --force` and `restore`. Three
  durable lessons from the review pass, none of them specific to git: (a) gating on an
  unexpanded `$` alone left the escape hatch STRICTLY worse than the block, since bare
  `git reset --hard` discards every uncommitted change and was silent, so an empty operand
  list and the whole-tree pathspecs (dot and `:/`) must arm it too; (b) a rail may not assert
  a mechanism the command lacks, because "an empty variable becomes an absolute path" is
  false for a revision operand where `git reset --hard /main` is merely an unknown-revision
  error, so that paragraph is suppressed there; (c) the advisory said "delete" against verbs
  that overwrite, handing a reader a correct reason to file the whole rail as a false
  positive, so its lead and non-compliance clauses now follow the verb. A path arriving via
  `-C`, `--git-dir` or `--work-tree` is collected as an operand: git treats an empty `-C` as
  a no-op, so an empty value silently redirects the command at the current repository.
  Literal spellings stay silent by design, since the rail's credibility for `rm -rf` is the
  budget being protected, and negative fixtures pin that direction.
- DC-012: **Prose at the point of temptation lost to instructions injected into context, and
  D-009's stated reason for having no guard was false.** D-009 recorded a session spawning three
  reviewers at once and answered it by putting the rule where the temptation is; a later session
  in this repository spawned three again after a plan-mode workflow arriving in its context told
  it to fan out, which lifts nothing — the durable lesson is the precedence one, that
  instructions delivered in context, whether a host workflow, a skill file or a tool
  description, never override binding session discipline, and an agent that thinks they conflict
  asks rather than picks. That row closed by calling the failure not machine-checkable "because
  the harness cannot see its own agent's tool calls", which is false wherever the host matches
  hooks on tool NAME, since a spawn is a tool call and the adapter simply had no matcher for
  one. The guard now carries a `--pre-task` entry point wired to the Claude adapter's spawn
  matcher, advising EVERY spawn rather than only a session's first and recording each one that
  proceeds, because a per-session one-shot is spent at precisely the moment a burst happens and
  leaves the sidestep invisible (**DC-004**). It reads no payload field, so the vendor coupling
  stays in the adapter and a host that spells the spawn differently points at the same flag;
  **DC-007**'s refusal of a Python-write rail does not reach it, because that objection was to
  inferring intent from program text whereas this is a host-delivered event. The bounded claim,
  stated because a count looks like a measurement: a pre-spawn hook can see spawns and their
  rate but never their liveness, so nothing here reports overlap and no gate may read the count
  as evidence that any rule was honoured.

- DC-013: **Working memory's byte cap was charging a quarter of its budget to rules no
  compression pass may touch.** `docs/STATE.md`'s length-guard preamble (1,865 bytes) and
  Owner-queue preamble (634) sat inside a 9,216-byte compression floor, so every pass folded
  volatile stages to make room for text that changes only under the rule-review protocol — the
  same defect **DB-028** measured at a fifth for the length-guard block alone, and the figure is
  quoted rather than rounded because the measurement is the only part a later reader can audit.
  Both moved into `docs/RUNBOOK.md` under **Working-memory compression** and **Session
  discipline** 7 on the owner's second grant of the **DB-029** precedent, and `## Project` shrank
  to three sentences carrying the one `version-lockstep.sh` greps. The destination is why this
  is not the repeal **P2** warns about: the runbook is read on demand and its heading is
  machine-checked, whereas the ledger would have been repeal, since a live rule in retrieval
  storage binds nothing. **DB-029** had recorded its own relocated pointer as "prose only", and
  a review pass proved the cost of leaving that true — deleting the new pointer from
  `docs/STATE.md` left the whole guard suite green — so `doc-navigation.sh` gained a
  pointer-file field and now checks both pointers where it had checked only the constitution's.
  What no guard recovers is the read that was unavoidable while the rules sat in the file being
  edited, which is why each relocation stays the owner's call rather than a tidying an agent
  performs; the seed scaffold carried the defect worse at 4,859 bytes of 6,045, and the instance
  file fell 9,292 → 7,174 with no rule repealed.

- DC-014: **A preamble promising a correction the guard refuses is the D-010 class, and the fix
  is a second pointer verb rather than a wider guard.** All five volume preambles said "trust the
  code and **correct** the entry" while `ledger-append-only.sh` rejected every edit to a committed
  row except `[cited]` and `Superseded by D-NNN.`, and DC-011 hit it for real: DB-014's
  enumeration of the destructive rail's commands went INCOMPLETE rather than false, the remedy the preamble named was a
  correction, and the guard refused. Supersession was the wrong marker because DC-011 *extends*
  DB-014's category rather than carrying its rule, so the pointer would have sent a reader to a
  row without what they came for — which is why the owner's answer (2026-08-25) deletes the
  correction promise AND adds `Corrected by D-NNN.` beside `Superseded by D-NNN.`, both strictly
  append-only. The distinction is linguistic and is labelled as such in the guard, the preambles
  and the changelog: the two forms are mechanically identical, so the guard checks the FORM and
  cannot check which verb is honest, and a guard that appeared to police it would be the D-014
  shape. One limit is left deliberately unbuilt under the **D-010**/**D-023** incident bar — a row
  carries at most one pointer and the first is final, so a wrong verb is unrepairable — while
  the review pass showed the limit was not even true as first written, since new rows are never
  form-checked and a pointer committed off the end of a row left the row exempt forever.
- DC-015: **A reported collision between the citation rung's id shape and hardware domain
  constants is real, and none of the three apparent escapes is clean.** `DB-9`, `DA-100`,
  `DC-12` and `DI-1` all reproduce as unresolved citations against the real ladder in an
  adopter-shaped tree, and none is a regression — each matched the pre-8.0.0 `D[A-Z]?-[0-9]+`
  pattern too. Checked again against a tree that HAS marked rows, two of the escapes need a
  second step nobody documents: `CITATION_SCAN_PATHS=''` empties the citation set and converts
  every `[cited]` row into a stale-marker failure, and a `CITATION_EXCLUDE` entry reddens the
  ladder at once whenever the excluded file held the last citation of a marked row. A fixture
  tree with no marked rows can see neither, so the first pass reported both working from the one
  tree where they cannot fail. A `LEDGER_PREFIX` key stays refused on the sound legs — any
  prefix relocates the collision into the adopter's own taxonomy rather than removing it, and
  P3's incident bar is unmet — never on immutability, since this ledger already spans `D-`,
  `DA-`, `DB-` and `DC-` at once with nothing renumbered, the patterns being a union. The
  adopter-facing note this earns is still unwritten: its first draft carried five factual errors
  and the review pass cut it.
- DC-016: **The adopter-facing note DC-015 earned is written, and the claim that nearly shipped
  false is the one INHERITED from a ledger row rather than derived from the code.** DC-015
  scoped its non-regression finding to four single-capital ids, the draft restated it as a
  property of the whole class, and DB-007(d) had already recorded that as false — 8.0.0's
  widening from one capital to any run of them can redden a tree on a file nobody touched,
  which is why that release was MAJOR. Everything the draft took straight from
  `guard_citations` survived the pass intact, so the lesson is not "verify claims" but that a
  citation FEELS verified precisely because a row is standing behind it, and the pass is the
  only thing checking that the row says what the sentence says. The shape is named in words
  and never shown, an example id in `amh.conf.example` being a real citation for any adopter
  who widens their scan paths to the repository root — `shipped-citations.sh`'s own trap one
  file further out, and its globs do not reach this one. Shipped as PATCH 10.0.1 on 6.0.1's
  precedent: optional prose beside a key, changing no verdict for an adopter who skips it.
  The owner lifted this session's standing no-subagent instruction (2026-08-25) so the
  mandatory pass could run and directed that forks be settled rather than queued, being
  asleep; the PATCH call and carrying the version bump inside this unit are both that, noted
  because nothing else would show they were decided unilaterally.
- DC-017: **A rail that asks for something it cannot see gets its question changed, not its
  wording — and the row that predicted this one was already in the ledger.** The command
  guard's push scanner required one ref under `BRANCH_PREFIX/` from 7.0.0 (DB-035, narrowed by
  DB-036) and blocked a correctly assigned `claude/<codename>` branch, after DA-022 declined a
  prefix guard elsewhere on reasoning that transfers verbatim and P13 made the same conclusion
  standing instruction for the `--pre-push` rail in the SAME script — two rails contradicting
  each other for four majors, both self-tests green. Fixtures cannot see that class: a
  self-test matrix proves a rail does what its author asked, never that the question was
  answerable. Swapping one broad test for narrow ones is where the cost lands and it has to be
  measured rather than reasoned — a differential over 844 push spellings found the first draft
  had opened `heads/main`, a live path to the default branch the retired namespace test was
  closing by accident, in a draft whose own prose claimed the default branch was denied.
  DB-035 and DB-036 carry `Corrected by DC-017.` meaning different things: DB-036's stale
  detail is one clause, while DB-035's headline principle is what this row contradicts and only
  its PR-template and Stop-hook halves still stand, so there the verb is the least-bad of the
  two permitted rather than a fit. Shipped as MINOR 10.1.0, decided by the session under a
  standing owner mandate over `CONTRIBUTING.md`'s clause reserving an ambiguous
  major-vs-minor call to the owner, noted because the DC-016 precedent covered a PATCH and
  stretching one silently is how a bar dissolves.
