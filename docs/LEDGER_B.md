# DEVIATIONS & DISCOVERIES LEDGER — volume B (DB-001…)

> **Append-only registry — NEVER archived, compressed or truncated.** This is volume B,
> opened when `docs/LEDGER_A.md` reached its 800-line cap at row DA-026. Rows in the previous
> volumes are never moved or renumbered, and a citation's prefix names its file: `D-NNN`
> resolves in `docs/LEDGER.md`, `DA-NNN` in `docs/LEDGER_A.md`, `DB-NNN` here. Code and docs
> cite entries as bare IDs and those citations must always resolve; no entry is ever deleted
> or summarised away. Note the asymmetry: citations from **code and workflows** are
> machine-checked (`CITATION_SCAN_PATHS`), citations from **prose are not checked at all** —
> docs are deliberately out of scan scope, because prose mentions IDs without citing them. A
> dangling ID in a doc will not fail the build; that one is on the reviewer. Append new
> entries at the bottom, one continuous sequence. Code and fixtures are ground truth: if an
> entry conflicts with the current code, trust the code and **correct** the entry — never
> delete it.
>
> **This file is RETRIEVAL storage: grep it and cite it, never read it whole.** A `DB-NNN`
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
> so ("supersedes DA-NNN") and the old row gets a correction pointer, never deletion.
>
> **File cap & rollover.** This file holds at most **800 lines** (the cap bounds LINES, not
> rows — it is read cost that is being bounded, and the number stays in lockstep with
> `LEDGER_LINE_CAP` in `amh.conf`). The final row may finish past the cap, but no row may
> ever *start* past it: when this file stands over the cap, create LEDGER_C.md (this file's
> name with a _C suffix) with the same header discipline, numbering from **DC-001**. It is
> named without backticks on purpose — a name in backticks is a citation, and the path-refs
> guard resolves citations against the real tree. The exact spelling matters: the ladder
> globs for it, so a volume named any other way is invisible to the line-cap and citation
> guards.
>
> **As the code stands TODAY the scheme is single-letter and stops at Z, and DAA- is the one
> spelling that fails silently in both directions at once.** Verified against the code, not
> assumed: the row pattern both the cap rung and the citation guard use is `D[A-Z]?-[0-9]+`,
> which admits at most one letter, so a `DAA-001` row matches nothing — invisible to the cap
> check, and its citations resolve to no row in either direction, with every rung green. And
> `live_ledger()` takes the LAST glob match, whose order is the shell's collation rather than
> volume age: under C and C.UTF-8, LEDGER_AA.md lands between LEDGER_A.md and LEDGER_B.md, and
> under a locale that ignores punctuation at the primary level it sorts before LEDGER_A.md.
> Both orderings are wrong in the same way — the live volume stays Z — which is why the fix
> below replaces the assumption rather than picking a locale.
>
> **The owner approved the durable fix on 2026-08-04; it is unit U5, not yet built.** Unbounded
> shortlex: the row pattern widens to `D[A-Z]*-[0-9]+`, `live_ledger()` orders volumes by
> suffix LENGTH then alphabetically, and the next volume's name is COMPUTED by base-26 carry
> (Z→AA, AZ→BA, ZZ→AAA) rather than looked up — a table is the thing that has a last entry, a
> carry rule is not. Until that lands, do not invent DAA-: twenty-four volumes of headroom
> remain, and widening the pattern is a guard-semantics change owing its own rule-review pass.
> Owed with it: the shipped seed preamble at `harness/templates/seed/docs/LEDGER.md` still
> describes the sequence with an open-ended ellipsis, which invites exactly the spelling this
> paragraph refuses, and adopters read that file rather than this one.
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
> does not read (`AMH ledger row DBNNN`). Anywhere else, the sentence above binds.

- DB-001: **The ladder now names its subject — which commit, and whether the tree it just
  verified IS that commit.** This is the whole surviving deliverable of RFC2 (**DA-025**),
  built as one `printf` argument on five verdict lines that already existed: no new artifact,
  no new flag, no new vocabulary, no new shipped script, and no change to any exit code. The
  refused alternative was a versioned JSON receipt under an ignored `.amh/receipts/`; what
  replaced it is the shape **DA-022**(d) already settled on for the ledger's byte count —
  adopt the intent, report the fact in output the tool already prints, invent nothing to hold
  it.
  **(a) The dirty case is the reason the line exists, and it is not a word appended to the
  clean one.** The ladder verifies the WORKING TREE — the secret scan and the citation scan
  both read untracked files — so a green run rendered as `HEAD <sha>` while the tree differs
  from that commit is a claim about something nobody verified. The dirty rendering therefore
  states the count of uncommitted paths and says in those words that the verified tree is not
  that commit. A design that printed the sha and appended "(dirty)" would satisfy the RFC's
  criterion and still mislead the reader it was written for.
  **(b) Four states, because two of them read exactly like "clean" if they are collapsed.**
  No repository at all; git present but refusing to answer; an unborn HEAD; and a real
  commit. `git status --porcelain` printing nothing is INDISTINGUISHABLE from a clean tree, so
  its exit status is read and an unusable answer is reported as UNKNOWN — **D-019**'s rule
  (the switched-off state must be louder than the passing one) applied to a verdict annotation
  rather than to a guard. `git rev-parse --short HEAD` on an unborn HEAD yields the empty
  string, which is the same shape a naive implementation would print as a commit.
  **(c) The probe is NOT `git status --porcelain`, and the blocking pass is what established
  that it must not be.** `status` honours `status.showUntrackedFiles`, settable in `.git/config`
  or a user-level `~/.gitconfig`; `git ls-files -co --exclude-standard` — what the secret scan
  and the citation scan actually read — does not. With that key set to `no` the reviewer built a
  tree where the ladder printed `FAIL credential-shaped string in UNTRACKED-SECRET.txt` and
  `worktree clean` on the same run: the guard failing on content the verdict attributed to a
  commit not containing it, reachable by one command that edits no tracked file, appears in no
  diff and trips no guard. That is DA-001(c)'s "green button" shape, and it would have shipped.
  The probe is therefore built from the same sources the guards read. Residue, stated rather
  than papered over: `git update-index --assume-unchanged` hides a modified tracked file from
  `diff` and `status` alike and still reads as clean — a deliberate act on one path, which no
  probe built from git's plumbing escapes.
  **(d) `.gitignore` is honoured, and that is load-bearing rather than incidental.** Counting
  ignored files would render every adopter with a build directory permanently dirty, which
  trains the reader to skip the clause and kills the distinction the line exists to make — warn
  fatigue, one layer down from where the harness usually meets it. It also inherits **DA-024**(c)
  in full: an ignored directory is simultaneously unscanned by `guard_secret_shapes` AND counted
  clean here. Consistent, and worth knowing before anyone gitignores something interesting.
  **(e) Only the count is printed, never the paths.** A verdict line is not where a filename
  belongs, and the guard-diagnostic rule this repository already follows — report *where*, not
  *what* — has an analogue here: the number is the fact a reader needs, and the names are the
  tree's business. `--no-renames`, because the count claims PATHS and rename detection collapses
  a moved file into one entry.
  **(f) The pass also found that the fixtures asserted the wrong thing, which is the finding
  most worth carrying forward.** All five originally used bare-substring helpers, so they
  established "the string appears somewhere in the output" — and the reviewer demonstrated it by
  moving the subject out of the verdict lines and into an `ok` line inside the guard section
  with the suite still at 99/0. That is **D-027**(a) a third time, in the fix for the defect
  D-027(a) records, and `expect_pass_saying`'s own docstring already spelled out the discipline
  its callers skipped. The suite now extracts the verdict line and asserts on THAT, with a
  checked-NOTHING branch for a run that printed no verdict at all. Two of the five verdict lines
  were additionally unreachable through the suite by construction — `run()` always passes
  `--guards-only`, so nothing could reach either `✗ ladder red` — which is D-020's shape, and a
  full-ladder runner now covers them.
  **(g) The P3 line, stated for this artifact because the plan requires it per artifact.**
  Nothing consumes this string. It is not parsed, no exit code varies with it, no agent
  decision procedure takes it as input, and no rendering of it can make a red run look green —
  it is appended identically to the green and the red verdicts. Those are the three conditions
  **DA-025**(c) set for a record that has not become a consumed artifact, and the moment a
  guard, CI step or merge gate branches on this sentence it has failed all three.

- DB-002: **The session banner reports a runtime inventory — and the probe that seemed obviously
  right reported the script's own helper function as an installed tool.** RFC1's surviving
  residue (**DA-024**) ships: `REQUIRED_TOOLS` and `ADAPTER_FILES` in `amh.conf`, probed and
  printed at session start, writing no file and adding no shipped script. Tools are `observed` or
  `unavailable`; adapter files are `configured` or `unknown`, never `observed` and never
  `unavailable`. Eleven fixtures, ten of which fail against the pre-change tree.
  **(a) `command -v` is not a PATH probe, and the difference is the whole warrant for
  `observed`.** It resolves builtins, functions and aliases first, so `REQUIRED_TOOLS='say'`
  reported `session-start.sh`'s own output helper — defined 180 lines above the probe — as an
  installed tool, and `printf` read `observed` on a machine holding no binaries at all.
  `observed` means "a probe ran and the answer is a fact about this ENVIRONMENT"; a builtin makes
  it a fact about this bash. The design was scrupulous that `unknown` is never translated into
  `unavailable`; nobody had guarded the symmetric hazard, a non-fact becoming `observed`. Fixed
  to `type -P` with a fixture pinning the function case. Generalise: when a vocabulary's value
  comes from a probe, test the probe against a case whose answer you already know — the RFC that
  proposed this vocabulary said exactly that about diagnostics and it applied to its own residue.
  **(b) A guard that hardcodes the set it exists to keep from being copied.** `adapter-set.sh`
  gained a reverse check whose allowed list was written out literally instead of derived from the
  `ADAPTERS` array five lines above. Adding a fourth adapter correctly — array, installer, both
  `RULE_FILES`, `ADAPTER_FILES`, both files shipped — would make the forward loop REQUIRE the
  path and the reverse loop reject it, in the same run, with a message that is not a false
  positive but factually false. Now derived. The rule: a guard against duplication may hold
  exactly one copy of what it checks.
  **(c) Vendor names reached a shipped script for the first time, inside the diff whose stated
  rationale is that they do not.** The new fixtures used `.claude/settings.json` and
  `.codex/config.toml` as test data in `test-ladder-guards.sh`, which every adopter installs and
  runs — while `session-start.sh` three files away cites P14 for taking both lists from config so
  it names no vendor. Verified: all four shipped scripts contained zero vendor references before
  this change. Renamed to neutral placeholders. Shipped CONFIG templates may name adapters, since
  the installer installs those files; shipped SCRIPTS are the boundary, and it was intact until
  this diff nearly broke it.
  **(d) An assertion that cannot fail is not a fixture.** Every new assertion used a prefix
  `grep -qF`, so a mutation deleting the trailing-separator strip left the suite fully green. Now
  exact-line. This is D-020's shape in the fixtures added to satisfy D-020.
  **(e) One claim in the review was wrong, and replay caught it.** It reported the Decided
  non-items debt from DA-024(d) as still owed by this unit; **DB-001** discharged it in U1, and
  the section carries five such citations. The rest of that finding — that this diff owed a
  changelog line and a ledger row — was correct and is this row.

- DB-003: **The conformance lab ships one scenario — and its own self-test reported green over
  cases that never ran.** RFC3's reduced form (**DA-026**): `conformance/` with the stale
  Owner-queue scenario seeded on **DA-011**/**DA-012**, one concrete runner, a deterministic
  self-test wired into `scripts/verify.sh`. No YAML, no oracle directory, no in-tree reports,
  fixtures generated at runtime. The blocking pass found six defects and the fix for them
  introduced a seventh.
  **(a) A subshell cannot report a failure by incrementing a variable, and the whole rung
  rested on it.** `selftest.sh`'s tree-builder raised `FAILED` on both failure paths, but every
  one of its seventeen call sites is `if d=$(tree …)` — a command substitution. The increments
  died with the subshell, the `if` skipped the case body, and the case vanished from the tally
  without touching the count. With all seventeen setups failing the suite printed `19 passed, 0
  failed` and exited 0, and `verify.sh` never called `bad()`. Ambient config reaches it:
  `clone.defaultRemoteName = upstream` in a developer's `~/.gitconfig` renames the remote the
  scripted subject uses. Failure is now a FILE, which crosses the boundary; the suite asserts
  its own assertion COUNT, so a shrinking suite is louder than a passing one; and the self-test
  isolates `HOME` like the runner already did. Generalise: **when a helper reports failure to a
  caller, check what boundary the report crosses.** This is D-019 in the one file standing
  behind an evaluator, and the header claimed it "dies loudly" — it died loudly on stderr and
  silently in the verdict.
  **(b) The quiet verdict was reachable after all.** The evaluator claimed FAIL was the
  structural default so a broken subject could never route itself into INCONCLUSIVE, and the
  runner settled repository-destruction as FAIL first. Both checks read the baseline COMMIT; a
  subject that deletes one loose blob leaves the commit intact, passes both, and trips T6 — so
  maximal noncompliance was filed as infrastructure. `git archive` over the baseline walks the
  whole tree and closes it, with a case pinning the check.
  **(c) A trigger id is not a branch.** Seven preconditions shared two ids, so removing any one
  left a sibling firing the same id and the suite green: all seven were individually deletable.
  The file said exactly this about one trigger and did not carry it to the rest. Each now has a
  case anchored on its own message.
  **(d) A justification for a defence the code does not need stops the next reader checking.**
  The isolation was explained by `core.excludesFile` turning FAIL into PASS, "demonstrated, not
  theorised". Not reachable here — the untracked probe passes no `--exclude-standard`, and a
  hostile HOME produces an identical verdict either way. The isolation is still load-bearing,
  for a different and verified mechanism, and the prose now names that one (D-010).
  **(e) D-006, reintroduced in the fix for a review that asked for it.** The helper added to
  close (c) opened `local name=$1 snippet=$2 d=$WORK/pre-$name`, which expands `$name` before
  `name` is assigned and explodes under `set -u` — the first entry on this repository's own
  adversarial checklist, written into a diff that had just been told to check for it. Caught by
  running the suite, not by reading it.
  **(f) Criterion 7 was prose in two places.** DA-026 required the adopter-tree absence to be
  asserted mechanically; the README and the runbook asserted it and nothing checked it. One
  line in the installer E2E now does.

- DB-004: **The conformance lab's second scenario ships, and the sweep that proved it also
  proved six of the FIRST scenario's assertions were untested.** RFC3's criterion 2 closes:
  `conformance/scenarios/02-incomplete-negative-search/` reproduces **DA-003** — a session
  reporting that something never happened, from a command that could not have seen it happen —
  as a disposable repository whose git history is three commits saying nothing and whose ledger
  is the only place the answer exists. 48 new self-test cases, 95 in the suite; the plan is
  retired to the archive with this row.
  **(a) "Both directions" is not the acceptance rule for a checker; it is the weak form of
  it.** The real rule, which this repository's own suite header already stated and its cases
  did not meet: **every assertion needs a case that fails when THAT ONE is removed**, not a
  case that fails while it is removed. Flipping each `broke` to `held` and each `inconclusive`
  to a no-op, one at a time, killed 30 of 38 mutants in the scenario-01 evaluator and left
  eight standing — three checked-NOTHING branches sharing a case anchored on a different line,
  an unreachable-worktree branch nothing exercised, a `no --result given` trigger whose sibling
  printed a different message for the same id, and a scratch-directory trigger nobody had a
  route to. All six closable ones are now closed in both evaluators, which kill 36 each. The
  sweep costs minutes and is the only form of the rule that distinguishes an assertion from its
  own absence (**D-020**). The two survivors are declared in both files rather than counted:
  reaching them needs a directory whose execute bit is off, and a run as root ignores that bit,
  so the case would pass or fail depending on who ran it (**D-024**).
  **(b) Reading the subject's answer is not reading its account of itself, and the distinction
  is worth stating because it looks like the banned shape.** The evaluator reads
  docs/ANSWER.md, which the subject wrote. What it never does is BELIEVE it: the expected set
  of ledger rows is computed in this process from the baseline ledger, and a subject asserting
  "I searched thoroughly" satisfies nothing. The ids exist in exactly one file in the fixture,
  so naming them is the observable consequence of having read it — the same relationship
  scenario 01 has with a corrected README. Two bounds are stated in the file rather than
  discovered: a subject that GUESSED both ids would pass, and one that names both rows and then
  asserts the opposite in prose would too, because judging the sentence needs the manufactured
  oracle **P19** refuses. The failure the scenario exists to catch is the search that came back
  empty, and an answer naming both rows did not come back empty.
  **(c) One mechanism per scenario, and the reason is a hazard rather than tidiness.** DA-026's
  criterion 2 names DA-002 and DA-003 together. DA-002's instance — the distributed fact read
  locally — is already built into scenario 01, whose queue item is settled by `git ls-remote`
  against a clone carrying no tags. Reproducing it again in 02 would have meant an evaluator
  asking a remote what exists, which a subject can rob of its own preconditions by deleting a
  remote: maximal noncompliance routed into INCONCLUSIVE, which is exactly **DB-003**(b). Both
  rows are covered across the lab; neither scenario carries two mechanisms.
  **(d) Retiring a plan into the archive loses the guard exemption the plan was written
  under.** `scripts/guards/path-refs.sh` exempts the plans directory and not `docs/history/`,
  so the completed plan — which named nine paths belonging to designs that were adjudicated and
  refused — would have reddened the tree on arrival. The remedy is the one **DA-002** already
  prescribes: a name that is not a live citation loses its backticks. Stated here because the
  ordering rule generalises past deletion — **retiring a document is a move ACROSS guard scopes,
  and the scope it lands in is the one that binds.** The three RFC files were deleted rather
  than archived for the same reason and by the owner's decision 5: their durable content is
  DA-024, DA-025 and DA-026.
  **(e) The unit whose subject is the incomplete negative search opened by committing one.**
  `docs/STATE.md` listed the adopter-tree absence assertion as owed by this unit. It was not:
  U3 had already landed it and **DB-003**(f) records it. The cost of believing the queue would
  have been a duplicate assertion and a false claim in a changelog line; the cost of checking
  was one grep. This is DA-011's shape in the state file rather than the queue, and it argues
  for the same discipline — a work item is a claim about the tree, and the tree settles it.
  **(f) RFC3's seven adjudicated criteria, mapped, because a criterion with neither a fixture
  nor an honest "prose-only" is not met.** 1 (layers separate) — three directories, structural.
  2 (two scenarios on named rows) — met, see (c). 3 (both directions, checked-NOTHING branches)
  — met, and (a) is what it took. 4 (no evaluator reads what the subject could have written
  about itself) — met, with (b)'s bounds. 5 (deterministic tests in ordinary CI, model runs
  non-blocking) — `scripts/verify.sh` runs the suite; nothing runs a model. 6 (INCONCLUSIVE
  only from an enumerated trigger) — met, one case per trigger per (a). 7 (adopter-tree absence
  asserted mechanically) — met in U3, per (e). Criterion 2's second half, one scenario run
  through a hosted agent, is **not** a criterion an agent session can close and remains the
  owner's queue item (**DA-026**, C14).
  **(g) The one defect the sweep could not have found, found by reading the checklist instead.**
  The new evaluator collected cited row ids with `grep -oE 'L-[0-9]+'`, which matches inside a
  longer word: `XL-003` in an answer read as a citation to L-003 — and L-003 is the fixture's
  CONTROL row, the one an answer must not name, so an innocent token turned a compliant session
  into a FAIL. **D-007**'s entry, "matching a word anywhere instead of in position", in a helper
  written the same day the checklist was reread. A mutation sweep is blind to it by construction:
  every assertion was pinned, and the defect was in what an assertion was fed. The fix matches
  the whole surrounding word and keeps only exact ids, and it has a case — the sweep tests the
  checker's branches, the checklist tests its inputs, and neither substitutes for the other.

- DB-005: **"Durable" was claimed for a line in working memory — the tier whose defining property
  is that it gets compressed away.** Asked to make sure the last unbuilt unit would not be
  forgotten, this session answered that it was already safe because `docs/STATE.md` records it,
  and called that durable. It is not. STATE is RAM (P2): capacity-bounded, folded on a schedule,
  and its **Current state** section is precisely what a compression pass is instructed to turn
  into a Changelog pointer. Only the Owner queue is protected from silent dropping, and only the
  ledger is permanent. The owner caught it by asking whether the word was true; no check did, and
  none could.
  **(a) The cause is structural, not a slip of vocabulary.** P16 puts multi-session work in a
  plan file plus a STATE checklist. Close-out archived the plan — correctly, per the unit's
  approved scope — and the checklist went into cold storage with it, leaving the remaining unit
  tracked only in narrative. **Archiving a plan while work remains transfers a tracking
  obligation that nothing enforces.** Whoever archives owes the surviving work a new anchor in
  the same change; that is now the rule, and it is prose.
  **(b) The fix and its exact bound.** The remaining unit becomes an Owner-queue ITEM, because
  the queue is the one section whose preamble forbids dropping items during compression. What
  this does NOT do is make the tracking machine-checked: a guard asking "is the remaining work
  still tracked?" would have to consume the session's own account of what remains, which is the
  banned attestation shape (P3, D-014). So this is prose plus a protected section, and the item
  says so rather than implying a guard.
  **(c) The generalisation worth carrying: a claim about persistence is a claim about a TIER.**
  Before saying something survives, name the tier it lives in and check that tier's mutability
  rule. Constitution is read-mostly, working memory is folded, the ledger is append-only, the
  archive is frozen. The agent maintaining the hierarchy made a tier-confusion error inside it,
  which is the strongest evidence available that the analogy has to be applied deliberately
  rather than remembered.

- DB-006: **The second scenario's evaluator was correct and its coverage was not — and the
  asymmetry between two sibling evaluators is what exposed it.** The adversarial pass built
  result trees for every route it could think of and every one got the right verdict; no shipped
  behavioural defect. Then it mutated the evaluator and found ten survivors, four of them real.
  **(a) The sharpest finding was a two-command demonstration.** Evaluator 02 drops
  `--exclude-standard` from its untracked probe on purpose, because a subject can write
  `.git/info/exclude`. Scenario 01 has a case for that route; scenario 02 did not — its scripted
  subject implemented two of the three leftover-hiding routes and omitted that one. Adding the
  flag back to evaluator 02 left the suite at 97 green; the identical regression on evaluator 01
  went red. **A deliberate omission with no case is indistinguishable from an oversight**, and
  the way it surfaced generalises: when two components make the same decision, mutate both and
  compare — a defect that survives in one and not the other is a coverage hole, not a judgement
  call.
  **(b) The isolation comment overclaimed while citing the row about overclaiming.** Both
  evaluators justified their isolated HOME with `clone.defaultRemoteName` turning a correct run
  into a FAIL, "verified rather than supposed", and cited **DB-003**(d) — the row recording that
  exact error one unit earlier. Neither evaluator clones or names a remote, so the mechanism
  cannot reach them; with the isolation removed and a hostile config the verdict is byte-identical.
  The isolation stays as defence in depth on the honest ground (every git probe reads
  configuration); the specific claim is gone. Copying a justification along with the code it
  justified is how a true sentence becomes a false one.
  **(c) A proposed fix that closed half of what it was proposed for, and was recorded as such.**
  The pass suggested one prepend case to cover two surviving mutants on the append-only ledger
  check. It covers the assertion's ABSENCE; unquoting the comparison still survives, because a
  false PASS there needs a ledger crafted so its `**` markup globs. The case was added and the
  quoting is DECLARED UNTESTED in the code. Applying a reviewer's fix and then checking whether
  it did what the reviewer said is the replay bound doing its job on the remedy rather than the
  finding.
  **(d) Also fixed:** a body-scoping rule argued at length that this fixture cannot exercise
  (declared untested rather than deleted or oversold); `ids_named_in`'s `sort -u`, now load-bearing
  because one passing case cites its rows in descending order; and a T0 diagnostic that echoed an
  unrecognised argument verbatim, which the sibling runner already refuses to do by name (P17).
  Two evaluators, one leak, propagated by copy.
