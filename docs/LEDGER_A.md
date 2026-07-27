# DEVIATIONS & DISCOVERIES LEDGER — volume A (DA-001…)

> **Append-only registry — NEVER archived, compressed or truncated.** This is volume A,
> opened when `docs/LEDGER.md` reached its 800-line cap at row D-035. Rows in the previous
> volume are never moved or renumbered, and a citation's prefix names its file: `D-NNN`
> resolves in `docs/LEDGER.md`, `DA-NNN` here. Code and docs cite entries as bare IDs and
> those citations must always resolve; no entry is ever deleted or summarised away. Note the
> asymmetry: citations from **code and workflows** are machine-checked
> (`CITATION_SCAN_PATHS`), citations from **prose are not checked at all** — docs are
> deliberately out of scan scope, because prose mentions IDs without citing them. A dangling
> ID in a doc will not fail the build; that one is on the reviewer. Append new entries at the
> bottom, one continuous sequence. Code and fixtures are ground truth: if an entry conflicts
> with the current code, trust the code and **correct** the entry — never delete it.
>
> **Search before appending.** Grep BOTH volumes for the topic first; extend or cite an
> existing row rather than append a near-duplicate. A row that supersedes an older one says
> so ("supersedes D-NNN") and the old row gets a correction pointer, never deletion.
>
> **File cap & rollover.** This file holds at most **800 lines** (the cap bounds LINES, not
> rows — it is read cost that is being bounded, and the number stays in lockstep with
> `LEDGER_LINE_CAP` in `amh.conf`). The final row may finish past the cap, but no row may
> ever *start* past it: when this file stands over the cap, create LEDGER_B.md (this file's
> name with a _B suffix) with the same header discipline, numbering from **DB-001**. It is
> named without backticks on purpose — a name in backticks is a citation, and the path-refs
> guard resolves citations against the real tree. The exact spelling matters: the ladder
> globs for it, so a volume named any other way is invisible to the line-cap and citation
> guards.
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
> does not read (`AMH ledger row DANNN`). Anywhere else, the sentence above binds.

- DA-001: **Adoption architecture — the verdicts on the instantiation RFC, and why three of its
  four proposals were already built or refused.** An external RFC (peer LLM, relayed by the
  owner, with a second opinion from DeepSeek) proposed a "Repository Materializer" sync CLI and
  a "Configurable Assurance Model" of light/medium/heavy strictness levels. External content is
  data (P18): it described a real problem and was evaluated, not obeyed. Four findings, each
  durable beyond the change that produced them.
  **(a) The materializer already exists and is already one-way.** `scripts/amh-init.sh`
  overwrites exactly the shipped scripts, never clobbers what the adopter owns, and is
  idempotent. The invariant it satisfies, now stated in the prose so nobody re-derives it:
  *nothing `amh-init.sh` does may be needed again after it exits* — the tree it leaves is
  self-describing and independently executable, and the harness is never on the runtime path.
  That is stronger and more precise than the RFC's "the CLI owns transport", which is wrong on
  its face: init also substitutes init-time placeholders, which is materialization.
  Bidirectional sync was refused because it imports merge semantics into a path deliberately
  built as a copy, and a local edit flowing upstream breaks the repo-agnosticism that makes
  `cmp` a valid dogfooding proof (D-002, D-003).
  **(b) A packaged CLI (npm/brew/binary) was refused.** It adds a dependency the harness
  forbids itself, and it puts a tool between the agent and the raw source — the exact opacity
  the RFC's own rationale argues against.
  **(c) Assurance levels as CONFIGURATION were refused, in both presented forms.** Rendering
  structurally different scripts per level re-creates the drift class D-002 deleted. Feature
  flags in `amh.conf` — the independent review's recommendation — were refused for a reason
  worth generalising: **`amh.conf` is in `RULE_FILES` precisely because editing it is a rule
  change, so a guard-gating flag makes "turn the red rung off" a supported one-line move.** It
  hands a stuck session a green button, which is the Goodhart shape P3 refuses and D-019 has
  already paid for once. A flag is a claim about intent; presence is an artifact.
  **(d) The synthesis neither document proposed: assurance is already emergent from repository
  topology.** The ladder activates on artifact PRESENCE — no ledger prints `skip`, no
  `scripts/guards/` prints `skip`, an unset `AUTHOR_EMAIL_ALLOW` runs the zero-config half and
  the `ok` line says which. The missing piece was discoverability, not configurability. So the
  profile is an init-time choice of WHAT TO INSTALL over the seed layer (materialized prose,
  copied once, owned thereafter), while the shipped scripts stay parametric and byte-identical
  for everyone. After init there is no "level" anywhere in the tree to flip, and nothing
  machine-readable records the choice — deliberately, so no future code can branch on it.
  Moving light → full is re-running init at the higher profile: it adds the missing seeds and,
  under keep policy, changes nothing the adopter has written.
- DA-002: **A prose citation is a delete-blocker, so a file and the prose citing it must go in
  the SAME commit.** docs/SQUASH_PR_BODY.md — named here without backticks, for the reason this
  row is about — had done its job once PR #1 merged, and deleting
  it turned the release red: `scripts/guards/path-refs.sh` resolves backticked paths against
  the real tree, and `docs/STATE.md` still cited the file. The deletion was reverted (`7d322d7`)
  to unblock the release, which is the right call under time pressure and leaves the tree
  carrying a spent artifact. The generalisation is an ordering rule, not a guard change — the
  guard behaved correctly, and this is the cost it is supposed to impose: **removing a file
  means removing its citations first or alongside, never after.** `path-refs.sh` makes prose a
  referential dependency of the tree, which is the entire point of admitting it (D-023), so
  "grep for the name before `git rm`" is now part of deleting anything this repository's docs
  discuss. Note the asymmetry that makes this bite at release time specifically: `docs/plans/*`
  is exempt from the guard, so a plan may name a file that does not exist, and only the live
  docs impose the ordering.
  **This row failed the ladder on its first run, for its own subject.** A permanent ledger row
  about a deleted file necessarily names that file, and a name in backticks is a citation — so
  the row recording the delete-ordering rule was itself blocked by it. That is the accepted
  residue `path-refs.sh` documents (a name quoted BECAUSE it is historical), and the remedy is
  the one the guard prescribes: do not code-span a name that is not a live citation. Every
  future row naming something deleted has the same obligation, and the ledger is append-only,
  so getting it wrong here would have been permanent.
  A second, smaller lesson from the same exchange, recorded because it is a claim-honesty
  failure rather than a mechanical one: a session reported "no tag exists" from `git tag` in a
  clone that had never fetched tags. `amh-v1.8.0` existed the whole time. **A local read of a
  distributed fact is a claim about the clone, not about the repository** — `git ls-remote
  --tags origin` is the question that was actually being asked. Generalised by **DA-003**,
  which is the same failure through a second door and should be read with this one.
- DA-003: **This repository has no file history, by construction — so `git log` cannot answer a
  question about its past.** A session asserted that `docs/STATE.md` "has never crossed its soft
  cap, so no compression pass has ever run", from `git log --follow` on the default branch. It
  is false: the file has been over the cap repeatedly, and two ledger rows exist *because* of
  it — D-011 records the grow-to-15.5 / trim-to-14.2 loop, D-027 records the landing check
  firing twice and once making "pad the file back" the compliant move. The reason the log
  disagreed with reality is structural: `MERGE_MODE=branch-train` plus squash-merge means an
  entire train of sessions arrives as ONE commit and the branches are then pruned, so on `main`
  the file has three commits and no past. **Every intermediate state is destroyed on purpose.**
  The generalisation, and the reason this is a ledger row rather than an apology: **in a
  squash-merged repository the memory tiers ARE the history — the ledger and the STATE
  changelog are not a convenience layer over git, they are the only surviving record**, which
  is the strongest argument for P2 the harness has produced so far. An agent reconstructing the
  past from `git log` here will be confidently and systematically wrong. Ask the ledger.
  Both this row and the tag error in DA-002 share one shape, and it is worth naming once:
  **a local artifact was read, and the answer was reported as a property of the repository.**
  The tell in both cases was available before the claim — the ledger rows were already read,
  and the merge mode is declared in `amh.conf`. The check is not "did I run a command", it is
  **"could this command see the thing I am claiming?"**
  One consequence, immediately: this repo's `docs/history/` is empty *despite* many compression
  passes, not because none ran. That falsifies the archive README's stated intake ("spent
  narrative from compressed STATE passes lands here") — a flow that has had many chances to
  happen and never has, which is the D-010 class arriving from the evidence side rather than
  the review side. Carried as an owner question; the correction is normative, not descriptive.
  **Mechanism considered and declined: a pre-execution warning on `git log`.** It clears the
  incident bar — this row IS the incident — and it was still the wrong layer, for four reasons
  worth keeping because the idea will recur. (1) `command-guard.sh` is binary, exit 0 or 2,
  with the reason fed back only on a block; a warn channel is new capability in the harness's
  highest-privilege rail, carrying something that is not an enforcement decision (P13 reserves
  that layer for denials that must never be crossed). (2) It fires on a command that is correct
  nearly every time, including inside two shipped rungs — the poison-token and author-identity
  guards both read `git log` over `origin/<default>..HEAD`, the one window squashing does not
  touch. That is the 24-hits-for-2-true-positives arithmetic that already sank a broadened
  `path-refs.sh`. (3) The defect was not the command but the generalisation from its output,
  and no pre-execution hook can see a belief formed afterwards (P3: what cannot be derived from
  an artifact stays prose). (4) The shape is not enumerable — `git show`, `blame`, `diff HEAD~5`,
  `branch -a`, `tag`, `shortlog` all reach it; the category is "reading local git state", which
  is most of git. **Accepted instead:** one line in `scripts/session-start.sh`'s banner, emitted
  only when `MERGE_MODE` is `branch-train`, saying that history on the default branch is
  squashed and the ledger is the record. It fires once, before any belief is formed, in the
  script whose job is orienting a fresh session (P14), and has no false-positive population at
  all.
- DA-004: **The archive's stated intake was wrong for the harness's whole life, and practice
  had already decided it.** `docs/history/README.md` said spent narrative from compressed STATE
  passes lands there, and P2's corollary said the same ("spent narrative in cold storage"),
  while `docs/STATE.md`'s preamble said to compress by folding into Changelog lines and moving
  durable gotchas to the ledger, *"not by cutting text into a new file"*. Both shipped. The file
  has been over its cap repeatedly (D-011, D-027) and the archive holds nothing but its own
  README, with no ledger row or changelog line recording anything ever retired into it.
  **State that evidence precisely, because the review pass caught this row overclaiming it:**
  the first draft said "many compression passes ran (D-011, D-027); every one folded", and
  neither row supports the second clause — D-011 records grow-then-nibble, D-027 a 15-byte typo
  deletion and a pass whose compliant move was padding the file back. Neither is a fold. What is
  actually established is the *absence of a record* of archiving, and it cannot be strengthened
  by walking history, because squash-merge destroyed it (DA-003). A row that cited two real
  entries for a claim they do not make would have been the citation defect no guard can see —
  the ID resolves, the support does not — caught here only because a fresh context was asked for
  falsifiable claims and this one was replayed.
  Owner decision 2026-07-27: **folding is the compression method, and the archive holds
  documents retired WHOLE** — a superseded state file, a frozen prior-era doc — never the
  residue of a pass. Corrected in the archive README, in P2's tier row ("consult, never extend"
  was itself wrong: retiring a document into the archive IS extending it, so the row now says
  it grows only by whole documents and is never edited in place) and in P2's corollary (b).
  Two things worth carrying forward. **The conflict was normative, so the ground-truth rule
  could not settle it** — "trust the code and correct the doc" answers *what does the system
  do*, and no byte count can answer *where should narrative go*. What broke the tie was
  evidence of a different kind: an instruction with many chances to be followed and no record
  of ever being followed. That is **adjacent to D-010 and not the same class** — D-010 is about
  prose claiming *enforcement* nothing performs, and its five instances are all enforcement
  claims, whereas "spent narrative lands here" claimed a *practice*. The new class deserves its
  own sentence and is worth hunting deliberately: **an instruction nobody has ever followed is a
  finding, even when nothing contradicts it.** (The first draft filed it under D-010; the review
  pass rejected the widening, correctly — a ledger class that quietly absorbs adjacent cases
  stops discriminating, and this file is append-only, so the overreach would have been permanent.)
  And the exposed consequence, now stated in the prose rather than left to be discovered: with
  folding as the method and squash-merge destroying intermediate states (DA-003), narrative the
  fold does not preserve is genuinely gone. Extract to the ledger BEFORE compressing.
  **Gap noticed while making this change, not fixed here:** `harness/src/` is absent from
  `RULE_FILES`, so editing the harness's own principles — the binding rules every adopter
  inherits — trips no legislation advisory, while `harness/templates` does. The review pass was
  run because P12 binds on the diff's nature rather than on the advisory firing, but that is
  discipline standing in for a tripwire. Owner queue; changing `RULE_FILES` is itself a rule
  change.
  **Second owner question raised by the same pass, and the one that must not be guessed:** this
  diff DELETES a clause adopters could have relied on ("consult, never extend"), and
  `CONTRIBUTING.md` says in terms that deleting such a clause is a **MAJOR**, while the current
  plan schedules a MINOR bump to 1.9.0 — and that an ambiguous major-vs-minor call is an
  Owner-queue question rather than a judgement call, because the number's whole value is that an
  adopter can trust it without reading the diff. Carried, unresolved, deliberately.
  **What the pass demonstrates about the protocol itself** is worth as much as the fixes: eight
  of its ten findings were about the tree AROUND the diff — a README line, a stale open question,
  a plan file quoting text that no longer existed — none of which a reviewer reading only the
  diff would have seen. The rule-review gate earns its cost on the second-order edits a change
  obliges, not on the change itself.
- DA-005: **Both questions DA-004 raised, answered by the owner 2026-07-27 — and one of them
  moves a version number for a reason no diff stat can see.**
  **(a) This release is a MAJOR (2.0.0), not the planned MINOR.** Everything in the plan is
  additive except one deletion: the archive correction removed "consult, never extend", a clause
  an adopter could have been relying on. `CONTRIBUTING.md` states the test — *"Rewriting half the
  prose without changing what any rule requires is a PATCH; deleting one clause that adopters
  relied on is a MAJOR. Ask what breaks for someone who has already adopted, and nothing else."*
  Worth recording because the intuition pulls the other way: the change makes the harness *more*
  permissive (a directory that was frozen may now grow), and a permission is not obviously a
  break. It is one, because an adopter's agent may have been enforcing the old clause, and
  because the number's whole value is that it can be trusted without reading the diff. That is
  also why the call was routed rather than made: the same file names an ambiguous major-vs-minor
  as an Owner-queue question. **The obligation the bump creates:** a MAJOR's Upgrading section is
  a promise to be COMPLETE, which is why the bump lands in the plan's last unit — the list cannot
  be written before the units it describes exist — and it must say plainly that an adopter
  relocating compressed narrative into their archive should stop, and that nothing enforces it.
  **(b) `harness/src` joins `RULE_FILES`.** `harness/templates` was covered and the PRINCIPLES
  were not, so editing P2 — the rules every adopter inherits, and the source the shipped bundle
  is generated from — tripped no legislation advisory, while editing a seed file did. The
  asymmetry was invisible until a session edited P2 and watched the advisory stay silent.
  Three things this does NOT change, said out loud because a tripwire is easy to mistake for the
  rule it reminds you of. P12 binds on what a diff IS, so the review was owed either way and the
  pass ran without the warning. The advisory is a WARN, so nothing is blocked. And it fires only
  when an agent runs the ladder while the change is still uncommitted — `advisories()` reads the
  working tree and the index, it is skipped in CI, and no pre-commit hook exists — so this
  **swaps one remembered act for another** rather than removing the remembering. It is a
  courtesy, prose-only, and saying otherwise would be the D-010 claim this repo treats as worse
  than no claim. The first draft of this row said the reminder "no longer depends on an agent
  remembering"; the review pass killed it.
  **Two claims in the first draft of this row were removed for lack of admissible evidence, and
  the first is the more embarrassing.** It argued the warn-fatigue objection away with
  "`harness/src` changes about as often as `harness/templates`" — a frequency claim resting on
  `git log` in a squash-merged tree, which is the method **DA-003** exists to forbid, made a
  third time, inside the row that records the tripwire for it. No admissible record of relative
  edit frequency exists, so the objection is answered differently: the entry widens a WARN and
  blocks nothing, so the cost of being wrong is one line of output, and if it does prove noisy
  the remedy is deleting the entry rather than weakening a review obligation P12 imposes
  independently. The second claim, "strictly more rule-bearing", was simply false —
  `harness/templates` carries the rail scripts and the seed constitution. The real case for
  `harness/src` is not that it outranks templates but that it was the last rule-bearing tree
  omitted.
- DA-006: **Documentation written in the present tense about a future release is a broken
  install path, and a version-pinning guard will cement it.** U1 added an adoption brief that
  the installer writes into an adopter's tree, and rewrote the README quickstart to describe it
  — while pinning the clone to `amh-v1.8.0`, a released tag whose tree contains neither the
  brief nor the code that writes it. A reader following the quickstart verbatim got the 1.8.0
  installer, no brief, and then an instruction to point their agent at a file that does not
  exist. The same unit's new lockstep arm binds the README's tag to `harness/VERSION`, so the
  text could not be corrected without a release. **The rule: the quickstart describes the tag it
  pins, never the working tree** — the two are the same document only in the commit that cuts a
  release. The brief's own §1 had the identical defect one layer down, describing a `--profile`
  flag that exits 1 today because it lands in a later unit.
  Five further findings from the same pass, each a shape worth recognising again.
  **(a) A conditional nobody tests is a coin flip.** The install used `keep` policy *and* a
  fresh-install gate; since a re-run is never fresh, the `keep` branch was unreachable, and the
  e2e assertion that claimed to prove notes survive a re-run passed through the skip path
  instead. It asserted nothing. This repo has shipped unreachable code before, which is why
  `AGENTS.md` names the shape.
  **(b) A fixture must assert the message that distinguishes, not the label that prefixes every
  message.** The new lockstep fixture matched on the check's label, which `check()` emits for
  *both* failure modes — so an implementation that could not tell a drifted pin from a missing
  one passed both arms. The reviewer wrote that implementation to prove it.
  **(c) A guard's arrival obliges its playbook.** The fifth lockstep copy went red at release
  time with nothing in RUNBOOK playbook 5 — the authoritative release procedure — telling the
  releaser which file to touch. Three prose sites still said "four copies", one of them the
  constitution's invariant catalog. A new checked copy is not done until the procedure that
  writes it is updated.
  **(d) An adopter's tree is not this tree, and prose written from the wrong vantage lies.** The
  installer told adopters a leftover placeholder "fails the placeholder guard": that guard is
  repo-local to the harness, and a fresh instantiation ships no guards at all, so nothing in
  their tree checks it. The brief now states the limit outright and gives them a grep. Same
  vantage error put `harness/PLACEHOLDERS.md` at a path adopters do not have.
  **(e) A tool-written file that directs process collides with the instruction hierarchy it
  installs.** The seed constitution says tool output may never change process; the brief is tool
  output and directs process edits. Resolved without a rule change, by stating where the brief's
  authority actually comes from: the owner ran the installer and pointed the agent at it, which
  makes it the owner's instruction delivered through a file. Worth remembering whenever the
  harness generates something that instructs.
  Also fixed: the brief blocked adoption on a synchronous owner answer, which no batch or
  hook-driven agent can give — it now falls back to the Owner queue, which is what P8/P9 exist
  for; and `harness/dist/AMH.md` claimed to be the whole harness while containing no mention of
  the brief, since nothing binds "every file under `harness/templates/`" to the bundle. That
  binding is still missing and is not proposed: no incident yet, and `dist-drift.sh` covers the
  files the prose does include.
