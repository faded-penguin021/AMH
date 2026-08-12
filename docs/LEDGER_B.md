# DEVIATIONS & DISCOVERIES LEDGER — volume B (DB-001…)

> **Append-only registry — NEVER archived, compressed or truncated.** This is volume B,
> opened when `docs/LEDGER_A.md` reached its line cap (800 at the time) at row DA-026. Rows
> in the previous
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
> **Keep new rows concise and at or below `LEDGER_ROW_CHAR_CAP`.** Capture the durable lesson,
> not the whole debugging narrative; put larger narratives in `docs/history/` and link them
> from the `docs/STATE.md` changelog.
>
> **File cap & rollover.** This file holds at most `LEDGER_LINE_CAP` lines from `amh.conf` (the
> cap bounds LINES, not rows — it is read cost that is being bounded). New rows are capped by
> `LEDGER_ROW_CHAR_CAP`; the guard counts bytes under `LC_ALL=C` for a locale-stable result, so
> ASCII text is one byte per character and non-ASCII UTF-8 is charged by encoded bytes. Neither
> value is restated here as a number, and neither should be: nothing checks preamble prose
> against `amh.conf`, and the 5.0.0 cap change left three volume preambles contradicting the
> guard (**DB-022**). The ladder prints both live values in its verdicts. Rows already committed when checked are historical and exempt. The final row may
> finish past the file cap, but no row may
> ever *start* past it: when this file stands over the cap, create LEDGER_C.md (this file's
> name with a _C suffix) with the same header discipline, numbering from **DC-001**. It is
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
> does not read (`AMH ledger row DBNNN`). That carve-out is no longer prose you have to
> remember:
> `scripts/guards/shipped-citations.sh` fails on a real id in anything this repository installs
> into an adopter's citation-scan paths — the shipped scripts, the seed scripts and the CI
> workflow, whatever the file extension. The one exception is the shipped fixture suite, whose
> ids are fixture material; the `CITATION_EXCLUDE` default in `harness/templates/amh.conf.example`
> keeps that file out of the scan of any adopter whose own `amh.conf` carries the key, and an
> adopter whose config predates it does not get the exclusion. Anywhere else, the sentence above binds.

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

- DB-007: **The volume scheme stops being a table with a last entry — and the rule that
  replaced it was still a rule about SPELLING, which the blocking pass broke in one command.**
  U5, the last of the approved five: the row pattern goes from `D[A-Z]?-[0-9]+` to
  `D[A-Z]*-[0-9]+` in all three places that used it, matched as a whole word; the rollover
  failure names the next volume — file name and row prefix both — computed by an odometer over
  A–Z with carry; and the live volume is found by WALKING that carry rule from the base file,
  stopping at the first missing link. Fifteen new fixtures, thirteen of which fail against the
  pre-change script; the two that do not each die to their own mutation, checked rather than
  asserted — dropping `-w` kills the mid-word case and nothing else, and narrowing the pattern
  back to one letter kills the resolving multi-letter citation.
  **(a) The defect inside the fix, caught by the suite on its first run — and again on its
  third.** The new comments spelled complete example ids, and the fixture builder derives each
  fixture's ledger by grepping the SHIPPED SCRIPTS for the row pattern, so fixtures acquired
  marked rows for ids nothing cited. Fixed, and then reintroduced verbatim in the comment
  explaining the fix for finding 2 below, which needed to name two ids that must not exist.
  The generalisation is the part worth keeping: **widening a scanner's pattern retroactively
  changes what already-written text MEANS, including the scanner's own comments.** Examples now
  stop at the hyphen. This is D-004's shape (a stored literal that makes a file fail its own
  scan) reached from the other end, and the ladder's header already carried the rule for the
  harness's own rows — `AMH ledger row DNNN`, deliberately unmatchable — which is the same
  instinct one letter short of general.
  **(b) The pass's first blocking finding: a name-shaped membership rule is satisfiable by a
  file that belongs to no chain.** The reviewed version ordered volumes by shortlex — suffix
  length, then alphabet — and admitted any `[A-Z]+` suffix. LEDGER_ARCHIVE.md is all capitals
  and LONG, so it outranked every real volume: the reviewer created it in one command and
  watched a FAIL over a volume past its cap turn into `ok` over a one-line file. That is
  DA-001(c)'s green button, introduced by the fix for a different silent failure — collation
  ordering, which had pinned the live volume at Z. **Both wrong rules were rules about what a
  name looks like.** The rule now is reachability: the same carry function that computes the
  next name generates the chain, and a file the walk does not reach is not a volume however it
  is spelled. Two silences the walk would have created are closed with it — an unreachable
  volume-shaped file is WARNED and named rather than ignored, and a missing base volume with
  continuations present FAILS rather than printing `no ledger yet`, which is D-019's rule
  (the switched-off state must be louder than the passing one). Whether such a file is likely
  is not the question the guard can answer; whether the rung can be pointed at the wrong file
  by one is.
  **(c) The second blocking finding: `-o` without `-w` matches inside a word, and the widened
  pattern made that reachable.** Unanchored, `D[A-Z]*-[0-9]+` turns `README-<n>` and
  `PRODUCTION-<n>` into citations to ids built from the tails of those words — ids that appear
  nowhere in the tree, so the adopter's first move, grepping for the reported id, returns
  nothing. Whole-word matching also closes the same trap one letter down, which is **DB-004**(g)
  exactly: `XL-003` read as a citation to L-003, shipped. The narrowing is worth stating on its
  own, because it means the pattern is not a pure superset in the other direction either: an
  id-shaped substring inside a longer word USED to be a citation and is not one now.
  **(d) What the widening still costs, stated because it is the half a superset claim hides.**
  Every existing `D-`/`DA-`/`DB-` citation resolves — verified by diffing this repository's
  citation set under both patterns, 12 ids, byte-identical — but a standalone `DEBUG-2` in
  scanned code is now an unresolved citation, and a differently-named volume stops being live.
  A tree that was green can go red on a file nobody touched, which is an adopter-visible break
  by the version-bump item's own criterion, and is why the recommendation there moved from
  MINOR to MAJOR rather than resting on "no citation broke".
  **(e) The pass also confirmed the fixture claims rather than taking them, and that is the
  half of a review that usually goes unrecorded.** It ran the suite against the pre-change
  script and got exactly the eight failures the row claimed, mutated the two fixtures that pass
  either way and confirmed each dies to its own mutation, and verified the byte-identical copy
  rule, both manifests and the bundle rebuild. Findings 6 through 8 in its report — an unchecked
  prefix strip, an odometer that silently shortened its answer on an out-of-alphabet character,
  and a collation-dependent `[A-Z]` glob range — were all unreachable from the two callers and
  all fixed anyway: a helper that is correct only because of where it is called from is a trap
  for the next caller, and the next caller here was the citation guard three findings up.

- DB-008: **U6 made committed ledger history append-only by machine check, without freezing
  draft rows inside the active unit.** The guard compares the working tree to `HEAD`, not the
  default branch: under branch-train squash history and sometimes-unfetched remotes, `HEAD` is
  the local pre-commit boundary that the session can actually verify. Every row id reachable in
  the ledger chain at `HEAD` must still resolve in the working tree. New ids absent from `HEAD`
  are ignored until they are committed, so a session may draft, rewrite, renumber or delete its
  own in-flight row before the checkpoint.
  **(a) Keeping the id is not enough.** U5's preamble rewrite was the incident shape: a row can
  survive under the same id while losing historical detail that a squash merge would otherwise
  erase. So the guard compares each committed row byte-for-byte and permits exactly one edit to
  an existing row: append one standalone final sentence matching `Superseded by D[A-Z]*-NNN.`
  with a real numeric suffix. Anything broader would be Goodhart-open — a rewrite plus the magic
  words would satisfy the machine while defeating the point. The fixture suite pins unstaged deletion, staged deletion, arbitrary rewrite, strict
  supersession and draft-row freedom separately; staged deletion is the bypass the blocking pass
  caught before commit.

- DB-009: **Scenario 02's first agent-backed runs found a defect in the evaluator, not in the
  prose rule it watches — and the obvious fix made it worse.** Six runs, one model, one fixture,
  each subject given only `task.md` and a clone path. A5 held 6/6: every subject established
  that a squash-merged `git log` could not see the answer, went to the ledger, and named the
  recorded rows. The DA-003 class this scenario exists to catch was not reproduced once. A6
  broke 5/6, always on the control row `L-003`, always inside a sentence excluding it.
  **(a) The task-text fix failed its own verification on the first run.** Tightening the
  instruction to "name only rows that record such an occasion" was meant to make the exclusion
  unnecessary; instead the subject produced a "Rows examined and not counted" section naming
  `L-002` and `L-003` together, and A6 broke identically. Telling an agent to be selective
  invites it to show what it excluded. Reverted unshipped — the run is the whole reason, and
  the recommendation had 5-run evidence behind it before one run killed it.
  **(b) The cause is polarity-blindness in `ids_named_in`, and it cuts both ways.** The helper
  matches identifiers, never their sense, so a row named in order to DISMISS it is
  indistinguishable from one named to cite it. A6 therefore over-fires — an excluded control row
  reads as an irrelevant citation — and A5 under-fires by the same token. Run 6 is the
  demonstrated false PASS: the subject argued `L-002` was not an occasion and excluded it, and
  A5 credited it for naming the row. A held A5 does not mean the subject counted a row, only
  that it typed the id.
  **(c) It is declared, not patched.** Separating an asserted citation from a disclaimed one
  means reading what a sentence DOES with an id, which is the manufactured oracle P19 refuses
  and this evaluator's header already declines for the same reason. No task-text edit reaches
  it — (a) is the evidence, not a prediction. The honest form is a declared limit beside the
  existing `cd`-branch and ledger-quoting declarations.
  **(d) The owner accepted these runs as satisfying RFC3 criterion 2, over two named residues.**
  The residues are real and are recorded here rather than dropped with the queue item: subjects
  ran as subagents inside the maintaining session's own container, not on a disposable remote,
  and every verdict reached the owner through the process that launched the subject. What the
  evaluator did NOT do is the part that makes the runs worth accepting — it read work product
  only, computed its expected set from the baseline ledger in its own process, and consulted no
  subject's account of its own behaviour for any verdict. The queue item is therefore closed and
  what the lab may now CLAIM is open in its place: A5 holding 6/6 is one model, one fixture, six
  runs, and is not a conformance result.
  **(e) The fixture baseline is wall-clock-derived.** Builds inside one second share a commit
  SHA; builds seconds apart do not. A launch must therefore RECORD its baseline — an evaluator
  process cannot reconstruct it afterwards, which is why the queue item says a hosted product
  has to expose a result clone AND a baseline SHA before its runs can count.
  **(f) A deviation in the running of it.** Runs 2–5 were launched as concurrent subagents,
  which session discipline 1 forbids without qualification (D-009). It was rationalised in
  flight as experiment specimens rather than units of work; the rule carries no such exemption,
  and the section was read afterwards rather than before. Runs 1 and 6 were sequential.

- DB-010: **The interpreter `.env` hole earned a one-time speed bump, not a false promise of
  parsing every interpreter.** The command guard still cannot understand `python3 -c
  "open('.env')"` as a file read after the speed bump is spent; enumerating interpreters would
  only move the miss to a different spelling inside the interpreter program. The useful owner
  intervention is therefore a session-local advisory block on the first command text that names
  `.env`: it stops the likely mistake, explains that credential files can leak through values,
  hashes, lengths, copies and interpreter reads, and tells the agent to rerun only if the warning
  is inapplicable or false positive. `session-start.sh` rearms the state by deleting the
  repository's advisory marker, and the command-guard self-test uses an explicit temporary marker
  so verification cannot spend the live session's warning. Subsequent attempts fall through to the
  existing precise rails, so `cat .env` remains blocked by the real reader rail while a
  prose/template false positive does not brick the session.

- DB-011: **The long quiet ladder run was fixture cost, not an observed process leak.** During
  the 4.1.0 advisory work, `scripts/ladder.sh` appeared stuck while it was inside
  `scripts/test-ladder-guards.sh`; process inspection showed the suite repeatedly running
  `scripts/ladder.sh --guards-only`, whose rail rung runs `scripts/command-guard.sh --self-test`.
  A standalone command-guard self-test took about nine seconds in this container, and the shipped
  fixture suite invokes guard-only ladders across many temporary repos, producing long stretches
  with no terminal output before eventually reporting `133 passed, 0 failed`. No surviving guard
  or ladder processes remained after completion. This is a performance/observability cost rather
  than a correctness failure; do not add cleanup machinery without evidence of orphaned processes
  or stale state, because killing by name would risk deleting the command under verification.
  Prefer a future progress note or fixture-suite timing work if the silence becomes a repeated
  operational problem.

- DB-012 [cited]: **New ledger length enforcement belongs at append time, not as a history
  rewrite.** The incident behind this row is the owner request to prevent future ledger rows
  from becoming retrieval-hostile without compressing or renumbering the append-only record.
  The guard therefore compares the live ledger chain against `HEAD` as DB-008 established,
  preserves the byte-identical historical-row rule and its strict final `Superseded by
  D[A-Z]*-NNN.` exception, and checks only rows absent from `HEAD`. The cap is configured as
  `LEDGER_ROW_CHAR_CAP`; despite the human word "character", the script deliberately counts
  bytes under `LC_ALL=C`, because that verdict is stable across locales and matches the
  harness's existing byte-size diagnostics. For ordinary ASCII ledger prose that is one byte
  per character; non-ASCII UTF-8 pays by encoded bytes. The tradeoff is conservative but
  reviewable: future authors can always shorten a draft row before commit, while committed
  historical verbosity remains exempt instead of forcing forbidden ledger surgery.

- DB-013: **Append-only means immutable prose, not frozen machine-checked metadata.** The first
  row-length implementation inherited DB-008's supersession exception but overlooked the other
  sanctioned transition in the ledger preamble: citation changes require an existing row to gain
  `[cited]`. The append-only guard now normalizes only additive metadata before comparing with
  `HEAD`: it may remove one newly appended strict `Superseded by D[A-Z]*-NNN.` line and may remove
  one newly added `[cited]` header marker for comparison. This one-way normalization allows either
  addition or both together, while marker removal, pointer replacement, and prose edits still
  fail. Because the row id already exists at `HEAD`, neither metadata addition reclassifies the
  historical row as new or subjects it retroactively to `LEDGER_ROW_CHAR_CAP`.

- DB-014: **A broad destructive-command rail should be a category-scoped speed bump, not a
  permanent deny.** Recursive forced removal is sometimes necessary, but an accidental run can
  erase the guard fixtures, source files, or untracked evidence needed to understand the work.
  The command guard therefore recognizes leading `rm` invocations combining recursive and force
  options and leading `git clean` invocations combining force and directory options, using the
  same heredoc, segment, and word parsing that keeps command-shaped prose out of other rails. It
  blocks the category's first attempt with safer alternatives and lets an intentional rerun reach
  the precise rails. Category-specific state also prevents acknowledging the `.env` advisory from
  silently acknowledging destructive deletion, while one shared mechanism prevents each new
  advisory from inventing its own session-state implementation.

- DB-016: **A shared one-time-advisory mechanism needs a shared rearm, or the bootstrap keeps
  the session-local promise for one category only.** DB-014 made the command guard's advisory
  state category-scoped, but `scripts/session-start.sh` still deleted a single literal
  `dotenv` state path, so the destructive-command advisory was spent for a container's whole
  lifetime rather than one session — silently, because a spent advisory looks exactly like a
  command that was never destructive. The bootstrap now erases every advisory state file for
  the repository with the CATEGORY as the only globbed element and the uid and path slug
  quoted, so a repository path containing a glob character cannot widen the pattern; the
  category slot itself is a greedy `*`, bounded by not crossing `/`, so its widest reach is
  another repository's file of the same shape under /tmp. A literal list of categories was
  rejected: it reproduces this defect one category later. The failure direction is deliberate
  — erasing one file too many rearms an advisory early, which costs one extra explained block,
  while erasing one too few silently removes a rail. For the same reason the function forces
  globbing on for its own expansion: amh.conf is sourced before it runs and is the adopter's
  file forever, so a `set -f` or `GLOBIGNORE` there would leave the pattern unexpanded and
  `rm -f` would swallow the literal — the rail off, in silence, from a key nobody connects to
  it. Only the `.env` diagnostic states the session scope in words; the destructive one leaves
  it implicit, which is why the defect was invisible from the diagnostics alone.

- DB-017: **A rail whose rule has unenumerated legitimate exceptions warns; it does not fail
  closed.** DB-015 was appended to `docs/LEDGER.md` while the live volume was `LEDGER_B.md`,
  so its citation dangles by the prefix rule the preambles state and resolves fine to grep —
  which is why several sessions passed over it. The append-only guard now flags a new row
  filed outside the live volume, and the owner chose a warning over a failure on the explicit
  grounds that there may be a genuine reason to append elsewhere that nobody has thought of
  yet (2026-08-09). Do not "tighten" it to a failure without that reason being enumerated and
  refuted: a rail that fails closed on a legitimate case is one an adopter switches off rather
  than reads. It checks BOTH halves of the class, because the first draft checked only the
  obvious one and would have stayed silent on DB-015 itself: a new row must sit in the live
  volume, AND its id prefix must name the volume holding it — a `D-` row in the live
  `LEDGER_B.md` dangles for a reader following the prefix rule while the live-volume test
  passes. Carrying it needed a third verdict for repo-local guards, which were pass/fail:
  exit 2 whose output begins `WARN `. The marker is load-bearing because bash exits 2 on a
  syntax error, so an unmarked exit 2 stays a failure — a guard that cannot parse must not
  report as a mild opinion. The append-only rules themselves stay hard failures: this warning
  is about where a new row was filed, not whether history was rewritten.

- DB-018 [cited]: **A rule whose violation is invisible here and expensive elsewhere earns a
  guard before it has an incident.** The ledger preambles' carve-out — a shipped script names
  a row as `AMH ledger row DBNNN`, never `DB-016`, because our rows cannot exist in an
  adopter's ledger — was prose only. The incident bar (**D-010**, **D-023**) would normally
  hold a guard back until a violation actually happened, and the owner overrode it here on the
  ground the bar does not cover: this violation is green in every rung of THIS repository (the
  row exists, the citation rung asks for `[cited]`, the marker gets added) and turns an
  adopter's ladder red on a file they are told never to edit. Waiting for the incident means
  waiting for someone else's. `scripts/guards/shipped-citations.sh` scans the shipped scripts,
  excluding the fixture suite for the same reason the shipped `CITATION_EXCLUDE` does — its
  ids are fixture material that resolves against a ledger it synthesizes itself. It carries an
  explicit scanned-nothing failure: a moved directory is indistinguishable from a clean sweep.
  Superseded by DB-019.

- DB-019 [cited]: **Scope a shipped-artifact guard by DESTINATION, not by directory or extension —
  and corrects DB-018, which this row supersedes.** DB-018's guard scanned
  `harness/templates/scripts/*.sh` while calling that "any shipped script". `amh-init.sh` also
  installs the seed scripts into the adopter's `scripts/` and the shipped CI workflow into their
  `.github/`, both inside the default `CITATION_SCAN_PATHS`, and `MANIFEST.sha256` is not a
  `.sh` at all: a citation in any of them passed the guard and turned a fresh adopter's first
  ladder run red — the precise failure the guard was written to stop, reproduced end to end by
  the review pass. `copy-drift.sh` had already learned this over the same directory. Three
  further corrections to DB-018: the guard now inspects `grep`'s exit status, because trouble
  read as "no match" is a hollow scan reporting a clean sweep; a token matching the citation
  pattern but naming no row of ours gets the recorded remedy (rename, or a `CITATION_EXCLUDE`
  entry — never a wider pattern) instead of nonsense advice to write it hyphen-free; and the
  exclusion holds only for an adopter whose `amh.conf` carries `CITATION_EXCLUDE`, since the
  shipped ladder's own default is empty and the key is installed `keep`. DB-018's citation of
  D-023 for the incident bar was wrong: D-023 is the row that DISCOVERED this defect class,
  and the bar is stated in the runbook's guard playbook.

- DB-020 [cited]: **A row filed in the wrong volume is repaired by supersession, not relocation
  — DB-015's own case.** DB-015 was appended to `docs/LEDGER.md` while `LEDGER_B.md` was the
  live volume, so a reader following the preamble's prefix rule looks in volume B and does not
  find it. The obvious fix, moving the row, is the one thing forbidden: removing it from the
  file it is in is a rewrite of an append-only volume, and the constitution reserves that to an
  owner-directed process. What the ledger already provides is the repair used here — the
  original keeps its text and gains a strict `Superseded by` pointer, and this row carries the
  lesson forward from the right volume. Its content: fixture-only rung skips reduce repetition,
  not production coverage, and the shipped ladder exposes no skip flag; read DB-015 for the
  full account. Two residues worth knowing rather than hiding: the row is still physically in
  `LEDGER.md`, and code citing DB-015 must keep citing it, because dropping the citation would
  strand its `[cited]` marker and removing that marker is itself a rewrite the guard rejects.

- DB-021: **Three nits in the shipped-citation and warn-channel work, accepted with reasons so
  they are not re-derived.** An external fresh-context review (Codex, 2026-08-09) found no
  critical or major defect in the branch and raised three minor observations; all three were
  read, judged and left alone. (a) `shipped-citations.sh` scopes by a hand-maintained list of
  installation-source globs, so a future `amh-init.sh` destination under `scripts/` or
  `.github/` is covered only if someone extends the list. Deriving it by parsing install calls
  is more fragile than the list it would replace; the obligation is stated at the list. Reopen
  if a destination is ever missed in practice. (b) The fixture-suite exclusion matches on
  basename, so a second shipped artifact named `test-ladder-guards.sh` would inherit it —
  which would be its own problem; path-matching is two lines and costs a rule-review pass for
  no present defect. (c) The ladder splits a multi-line warning with separate `head` and `tail`
  pipelines rather than parameter expansion: heavier by two processes, correct for ordinary
  diagnostics and the multiline fixture. Each is a cost accepted against a real alternative,
  not an oversight; new evidence means an actual miss, not a re-reading of these trade-offs.

- DB-022: A cap chosen without measuring the population it bounds is a number, not a limit.
  `LEDGER_ROW_CHAR_CAP` stood at 2000 while the six rows written under it ran 1132–1657
  bytes, so it never once bound. Worse, the unit's first draft justified the new 800 as
  "above the median, below the four longest" — false in both halves, and it reached the owner
  as a recommendation before the arithmetic was checked. Measure the distribution FIRST and
  quote it, because a threshold's justification is the only part a later reader can audit.
  Two traps: `grep 2000` misses prose written **2,000**, which left three volume preambles
  contradicting the guard; and lowering a default is MAJOR, since an adopter omitting the key
  inherits a stricter guard and a legal row starts failing.
- DB-023: **When a check is impossible, delete the claim rather than restate it.** DB-022 left
  prose and config in hand-held lockstep — three volume preambles, the STATE band, four seed
  placeholders. A guard would have to lift a number out of a sentence; P20 steers doc-fact
  guards at code-against-constant instead, and the repo ships one prose-extracting exception
  (`version-lockstep.sh`, over a fixed sentence shape). Cheaper not to state the number. Prose names the `amh.conf` key; the live value comes from the ladder's
  verdicts — except the STATE compression floor, which a passing run never prints; read that
  one from the config. **A fact restated where only one copy is authoritative is a drift class,
  and the fix is subtraction, not machinery.**
  Superseded by DB-025.
- DB-024: **Two refusals from the external review of 2026-08-10, recorded so P10 does not have
  to re-argue them.** (a) *An enforcement-layer column on the README mechanism table.* Refused
  as an honesty regression in table form: the layer is per-RULE, not per-MECHANISM — "rails"
  is a script for an agent with a pre-execution hook and nothing at all without one, and
  "review protocols" is prose plus a spawned context. One cell cannot say that, and the seed's
  secret-hygiene section already models the per-rule form. (b) *A third conformance scenario,
  and broadening the lab to more models.* Not refused on merit — the incident bar wants a third
  recorded failure class, and running subjects is an owner-launched step (C14), not an agent's.

- DB-025: **Prose about a guard's OUTPUT drifts exactly like prose about its thresholds — and
  corrects DB-023, which this row supersedes.** DB-023's rule stands whole. Its closing clause
  broke it: it called the floor the one value a healthy tree never prints. False —
  `guard_state_size`'s landing branch names the floor on the `ok` confirming a completed
  landing, and `state_landing_good` makes a fully green ladder do it. **The first repair then
  reproduced the class it was closing**, calling that number the config value "quoted" when the
  line emits bytes and the key is KB. Read the branch that emits the line, and prefer a claim
  about DERIVATION to one about equality; a remembered verdict is not one.

- DB-026: **Tier a secret-file rail by whether its block reason is true of the file it names.**
  Asked whether `.pem`, `.key` and `id_rsa` belonged in the safeguard, the answer split by
  population, not risk: `id_rsa` and kin have no benign namesake, so they block, and `.pub`
  clears by construction — the list is exact literals, so an arm for it is dead code asserting a
  mechanism. `.pem`/`.key` are containers whose commonest bearer is a public certificate, so
  they get the one-time advisory. Two findings under it: `private_key_block` matches the BEGIN
  **line** and substitutes per line, so a key body prints and the read rail is the ONLY
  mechanical layer for keys; and a glob excluding `Object.keys` still fires on a singular
  `.key`, which no pattern separates from a field.
  Superseded by DB-027.

- DB-027: **A redaction marker over a live value is worse than no class at all — and an oracle
  written in the number under test tests nothing.** `private_key_block` matched the header LINE,
  so the filter printed the marker and then the whole body. The block stage that fixes it is
  anchored between the markers, so a manifest hash is not body, and matches only wholly base64
  lines, so an unterminated header cannot eat prose. Its first floor was 32 characters,
  from a comment nobody measured: real RSA tails run 20-28, so every key leaked one, and the
  fixture could not fail — its oracle reused that 32. Owner, 2026-08-11: the 6.0.0
  MAJOR stands, and **a guard never opens a file** — content-aware detection is refused, so
  extension tiering is the answer for `.pem`/`.key`.

- DB-028: **Compressing prose that DESCRIBES a mechanism deletes what made it auditable.** A
  length-guard preamble is legislation inside working memory, spending at the floor a fifth of
  the budget it rations; the seed's came down ~15% on restatement alone. The repo copy's first
  pass cut further and lost two clauses release 5.2.1 was cut to ADD — which numbers the size
  rung prints, and that they are DERIVED (landing line in bytes, key in KB) — leaving "printed
  numbers are the guard's arithmetic" an unscoped claim the rung's own `${STATE_WARN_KB} KB`
  interpolation falsifies. The mandatory pass caught it; restoring cost most of the saving. Fold
  what repeats; a sentence naming a guard's OUTPUT is not repetition.

- DB-029: **A description of a guard's output is not working memory — do not charge it to a byte
  cap.** Compressing the length-guard preamble hit a floor: a quarter of this instance's copy and
  an eighth of the seed's was not a rule but an account of what `guard_state_size` prints (DB-025,
  the subject of release 5.2.1). Owner, 2026-08-11: move it to `docs/RUNBOOK.md` -> Acceptance
  ladder, which no cap governs, over the argument for leaving it -- it is read when the guard
  fires, and STATE is read in full at session start. The pointer left behind is prose only. A
  relocation is not a compression, so the preamble's "never cut text into another file" now
  carries the exception in writing. Shape: ask which of a bounded file's bytes the bound is for.

- DB-030: **A one-time advisory keyed to a CATEGORY is spent by the first harmless instance;
  key it to the target.** A session blocked on `rm -rf "$S/base"` renamed the target so no `rm`
  was needed: "I routed around the trigger to save a turn." The text had offered "move the path
  set to a temporary directory" — its own sidestep — and never named the failure mode
  it exists for: an empty `S` makes that `rm -rf /base`, unseeable before expansion. One marker
  per category also let an early `rm -rf tmp/build` silence later ones. Now: rearm per
  operand set AS WRITTEN (text, not resolved path, and the advisory says so), the check named,
  renaming ruled out. Where nothing consumes an advisory its PROSE is the intervention: fixture
  what it must claim and what it must not.
