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

- DA-007: **A gate ordered before a presence test turns an upgrade into a lie, and the profile
  mechanism's own review found it in the fix rather than in the design.** `--profile
  light|standard|full` landed in `scripts/amh-init.sh`, defaulting to `light`, selecting which
  `harness/templates/seed/**` files a fresh install receives. The architecture was already
  settled by **DA-001**(d) — init-time choice of what to install, nothing machine-readable
  recorded, assurance emergent from artifact presence — and implementing it raised no new
  architectural question. Every defect below was in the implementation, and the review pass
  found all of them; this is the twenty-fourth of twenty-five passes to find a real defect
  inside a FIX rather than in the thing being fixed.
  **(a) Presence outranks configuration, and the test order is the rule.** The first draft
  gated on the profile *before* asking whether the file was already there. `docs/UPGRADING.md`
  documents a bare `amh-init.sh <target>` as the upgrade path and the default had just become
  the smallest profile, so an existing adopter's plain re-run told them their runbook and
  ledger were "not in the light profile — add it with `--profile standard`" while both sat in
  their tree, and printed a tally that counted them as declined. The silent half was worse: a
  declined file never entered the installed list, so those files also vanished from the
  unfilled-placeholder report while the seed runbook's twelve real `{{…}}` slots sat in one of
  them — the D-025 shape (a list quietly diverging from what it describes) reproduced in the
  script whose own comment cites D-025 for it. **The general rule: when a new switch decides
  what a tool installs, the switch governs absence only. What already exists belongs to the
  person whose tree it is.**
  **(b) A default value is behaviour, and an untested default is an untested feature.** Every
  profile assertion passed `--profile` explicitly, so changing `PROFILE=light` to
  `PROFILE=full` left the whole suite green — the diff's headline claim, asserted nowhere. A
  flag's default needs its own fixture precisely because it is what nearly every caller gets.
  **(c) An assertion that stops one word short leaves the load-bearing word untested.** The
  fixture matched `docs/LEDGER.md (not in the light profile` and stopped before the advice,
  so deleting the standard/full distinction — making the ledger's line read "add it with
  `--profile full`", telling an adopter to install the archive tier to obtain a ledger — passed.
  D-007's "matched the word but not its position", this time in a fixture rather than a guard.
  **(d) A shipped script may not name a file an install profile declines.**
  `session-start.sh` printed "then the matching playbook in `docs/RUNBOOK.md`" unconditionally,
  which under the new default pointed every session's first screen at a file that is not there
  — and the adopter cannot fix it, because shipped scripts are overwritten on every upgrade.
  Now conditional on the file existing, with fixtures in both directions. Any prose in a
  *shipped* artifact that names a *profile-gated* file has this bug.
  **(e) "Prune what you do not have" is a rule change wearing housekeeping's clothes.** A draft
  comment in `amh.conf.example` told adopters to drop `RULE_FILES` entries for files their
  profile skipped. Escalating later would then deliver the runbook — legislation — with the
  tripwire no longer covering it and nothing saying so. A stale entry is inert (the tripwire
  matches paths in a diff; a path that cannot appear never matches) and starts working by
  itself when the file arrives, so the correct advice is the opposite: leave it.
  **(f) Naming the escape hatch in a shipped brief is not the same as it being possible.**
  `git rm` as the documented downgrade is the green button **DA-001**(c) refused, respelled:
  the ladder is presence-activated, so deleting a seed deletes its rung. Always mechanically
  possible; what a brief must not do is present it as the routine move. It is now marked an
  owner decision.
  One consequence outside the diff, recorded because it will recur: three profiles must be
  three distinct file sets. The plan called for the new `docs/history/` seed under both
  `standard` and `full`, which would have made those two byte-identical and the third name
  decorative; it ships under `full` only, matching the brief's own table.

- DA-008: **The shipped-script integrity manifest — the second guard in this repo's history
  admitted before its violation, on the same authority as the first.** (The identity guard was
  also admitted pre-incident and also by owner decision — **D-032**, **D-033**. The first
  draft of this row claimed the owner-decision half was novel here; it is not, and the pattern
  now has two instances rather than one precedent.) `CONTRIBUTING.md` sets an incident bar: new machinery earns its place
  after a real violation, never after a hypothesis, and `docs/RUNBOOK.md`'s playbook 3 repeats
  it. This one deviates, by owner decision 2026-07-27, and the
  reasoning is recorded here rather than left as a precedent a future session can cite
  loosely: with zero adopters the incident can only ever be discovered **at an adopter's
  expense**, and they are the one party who cannot pay it. The bar still stands for everything
  else; what this row licenses is *an owner overriding it on a stated argument*, not "the
  incident bar is negotiable".
  What ships: `scripts/build-manifest.sh` generates `MANIFEST.sha256` over
  `harness/templates/scripts/*.sh`; `amh-init.sh` installs it beside the scripts it describes
  (policy `overwrite` — it is a shipped artifact, not the adopter's);
  `guard_shipped_integrity` in the shipped ladder hashes each named file against it;
  `scripts/guards/manifest-drift.sh` rebuilds and diffs it here, the way `dist-drift.sh` does
  for the bundle. It is deliberately the SECOND integrity check over these bytes in this
  repository and the FIRST in an adopter's: `copy-drift.sh` proves *this repo runs what it
  ships*, the manifest proves *an adopter still runs what we shipped them*. Different claims,
  different trees, and only one of them travels.
  **(a) A guard that can fail on the documented upgrade path is a guard that will be
  deleted.** The upgrade instruction was `cp .../scripts/*.sh scripts/`, which delivers new
  scripts against the previous version's manifest — every one of them then reads as locally
  edited. Two changes close it and both were needed: the manifest lives IN the same directory
  as the scripts so that copying the directory keeps them together, and `docs/UPGRADING.md`
  now says to copy the whole directory. The failure text names this case too, because the
  reader who hits it will be reading that line and not this row. Same family as **D-030**: a
  fix whose repair falls on the person it broke is not a fix.
  **(b) Absence WARNS, a missing hashing tool warns, and an empty manifest fails — and the
  first of those was a `skip` until the review pass.** Absence is a state the adopter is
  legitimately in (they upgraded by hand before this existed), so it cannot be fatal, and the
  ladder's convention for an absent artifact is `skip`. The convention is wrong here, for a
  reason specific to this rung: deleting the manifest is ALSO the documented way to live with a
  deliberate local patch, so absence is the one off-switch someone reaches on purpose — and
  `skip` increments no counter and leaves no trace in the summary line, making the deliberate
  disable quieter than the accidental one. That inverts **D-019**. It warns. (No `sha256sum` or
  `shasum` warns too, for the plainer D-019 reason: the machine is not the subject.) A manifest
  whose every line is a comment parses cleanly and checks nothing, which would print
  `ok 0 shipped script(s)`: green earned by an empty file is the one verdict this rung may
  never give, so it fails.
  **(c) A guard cannot defend a file the adopter owns against the adopter — so state the
  residue and refuse only the self-serving case.** The manifest path is a constant rather than
  an `amh.conf` key, because a configurable path is a supported way to point the rung at
  nothing and collect a green verdict. But the manifest itself is a text file in their repo,
  and the first draft of this row and of `docs/UPGRADING.md` both claimed "there is no way to
  excuse a single file" — which the review falsified in one command: comment out a line, edit
  that script, ladder green. What the code can honestly do is refuse the ONE omission that is
  self-serving (an entry missing for `scripts/ladder.sh`, the file that decides whether
  anything else is excused) and print the count it checked, so a shrinking count is the signal
  for the rest. Both now ship, with a fixture each, and the prose says exactly that much.
  **The general rule: when a guard's subject is a file its target owns, the guard's claim is
  bounded by what it can refuse, and the documentation must state the bound. An enforcement
  claim one line stronger than the code is worse than no claim — it is what stops the next
  reader checking by hand (D-010).**
  **(d) A generator that fails open publishes an artifact that verifies nothing.**
  `build-manifest.sh` resolved its hashing tool inside the function that used it, with `exit 1`
  in the else-branch — and `exit` inside `$(…)` kills the substitution's subshell only. With no
  hasher on PATH it printed its refusal five times, wrote a manifest of empty hashes over both
  copies, and reported success, rc 0. The same defect was in the fixture suite's copy of the
  helper, where its comment claimed the opposite. **Resolve a required tool once, at the top
  level, where `exit` means exit.**
  **(e) A guard scoped by file extension stops being the guard it claims to be the moment a
  non-`.sh` artifact ships.** `copy-drift.sh` globbed `"$SRC"/*.sh`, so this repo's copy of
  the manifest could have drifted from the one adopters receive while the guard's own line
  said the shipped set was identical. It now compares every file under
  `harness/templates/scripts/`. Worth generalising: an artifact set defined by extension is a
  bet that the set will never gain a member of a different kind. Its closing count moved into
  the loop in the same change — it was a recursive `find` describing a non-recursive glob's
  work, which is the same lockstep defect one size down.
  **(f) The rung's own blind spots are in its header, not left to be discovered.** It cannot
  see the edit that deletes it from `run_guards` (nothing inside a script can), and it cannot
  see a removed manifest line except as a lower count. Both are written where the next reader
  will be standing, and the manifest is `sha256sum -c`-compatible so the check survives without
  any of this code.
- DA-009: **The squash-history banner line (U3b), and a shipped script's first read of a key
  it had never read before.** `session-start.sh` now prints, under `MERGE_MODE`
  `branch-train` only, that the default branch's history is squashed and the memory tiers are
  the record. The decision to put it here rather than in a pre-execution rail is **DA-003**;
  this row is only what implementing it cost. The key had never been read by this script, so
  it needed a default IN THE SCRIPT — a shipped script that reads a key without defaulting it
  dies under `set -u` and takes the whole banner with it. **Be precise about which config file
  that defends against, because the first draft of this row was not**: `MERGE_MODE` is a
  substituted placeholder in `amh.conf.example`, so every repo instantiated by `amh-init.sh`
  already has the key, and the "existing adopters' files predate it" story the review checked
  is false for all of them. What remains is real and is the actual rule: `amh.conf` is the
  adopter's forever, the harness cannot upgrade it, and they may edit or delete any line in it
  — so a shipped script may never assume a key is present, whatever the template ships. That
  is `AUTHOR_EMAIL_ALLOW`'s rule (**D-033**) arriving from a second direction, which is what
  makes it a rule rather than a detail: **every key a shipped script reads gets a default in
  the script, and its fixture is a config file with the key removed.** The gating is asserted in both directions — printed under `branch-train`, absent
  under `branch-per-change`, where the same sentence would be false.
- DA-010: **A release's Upgrading section is the only part of a changelog with a reader who is
  obliged to act — so it is written from the adopter's tree, not from the diff.** AMH 2.0.0's
  entry is this repo's first MAJOR, and the drafting error to avoid was writing the notes as a
  summary of what changed here. Three things follow, and they generalise past this release.
  **(a) The MAJOR is the deleted clause, not the size of the release.** 2.0.0 ships two
  substantial additions (install profiles, the integrity rung) and neither one earns a major:
  both are additive, and an adopter who ignores them keeps working. What earns it is a single
  sentence removed from P2's table — "consult, never extend" permitted relocating compression
  residue into `docs/history/`, and the corrected wording forbids it (**DA-004**). Semver here
  is a promise about the adopter's workload, so the version is decided by what stops being
  allowed, never by diff volume (**DA-005** records the owner making exactly that call).
  **(b) An Upgrading note for a prose-only rule must say that nothing enforces it, in the note
  itself.** No guard reads the archive and none is proposed, because the discriminator is the
  self-assessment P3 bans machinery on. An adopter reading a MAJOR reasonably expects their
  ladder to tell them if they missed something; here it will not, and the note that omitted
  that sentence would be the **D-010** shape — an enforcement claim, by implication, one line
  stronger than the code. It also has to answer "and what about the residue I already moved?",
  because a rule change with no story for existing state gets ignored or over-applied.
  **(c) The quickstart describes the tag it pins, which makes the merge-to-tag window a real
  interval rather than a formality.** `README.md` now names `amh-v2.0.0`, a tag that does not
  exist until the owner cuts it after the merge — so the documented clone command 404s for that
  window. This is the ordering **DA-006** paid for from the other direction (that time the tag
  existed and lacked the feature the text described). The window is not removable — the release
  workflow checks the tag against `harness/VERSION`, so the tag must follow the merged bump.
  **Be exact about what closes it, because the first draft of this row was not, in the
  subsection that cites D-010 for that exact failure mode.** `version-lockstep.sh` cannot see
  tags: it checks the README's pinned *string* against `harness/VERSION`, and its only
  tag-aware arm (`--tag`) is invoked by `.github/workflows/release.yml`, which fires on a tag
  push — i.e. after the tag exists. So merged-but-never-tagged is a state every guard in this
  repo reports as green while the README's clone command 404s for every new adopter, forever.
  What bounds the window is the **Owner-queue item**, a human step, and nothing else. **The
  general rule: when documentation pins an artifact the owner creates later, the ordering
  belongs in the Owner queue as an ordering, not as two independent items — and the thing
  bounding the gap is that queue entry, not whichever guard happens to be nearby.**
- DA-011: **An Owner-queue item is a claim about the world, and this repo had no step that
  tested one before repeating it.** DA-010 closed by making the Owner queue the thing that
  bounds the merge-to-tag window — a human step, correctly, since no guard can see a tag. What
  that row did not ask is what the *next session* does with the entry. The answer was: repeat
  it. On 2026-07-27 a session opened after `amh-v2.0.0` was merged AND tagged, read "merge,
  then tag" in the queue, did the unrelated work it was asked for, and restated the item to the
  owner as pending. `git ls-remote --tags origin` would have settled it in one command and was
  never run, because nothing named it as a step. The owner reports this recurring across
  sessions, which makes it a protocol hole rather than one session's slip.
  **(a) The failure is structural, and the protocol's own wording invites it.** "Every
  session's final chat message restates this queue" makes restating an *obligation* and
  verifying nothing, so the cheapest compliant act is to copy the text forward. A queue item is
  written at the moment of maximum knowledge and read at the moment of minimum; carrying it
  verbatim is not neutral, it asserts to a human that the item is still true. Worse, the stale
  restatement is *indistinguishable* from a correct one at the point of reading — the owner
  cannot tell "checked, still pending" from "copied without looking", so the queue's whole
  signal degrades. **A protocol that mandates repeating a claim must mandate testing it.**
  **(b) The fix that suggests itself is a required field, and it Goodharts on contact.** The
  first draft here gave every item a mandatory `Done when:` line. Item 1 of the live queue —
  branch protection, readable only through an admin-only API — got "Done when: the owner says
  so", which is a check the way a checkbox is evidence (**D-014**). A field every item must
  carry is a field every item will carry, and a queue of them reads as verified while asserting
  nothing. The shipped shape makes the check **optional and load-bearing**: items whose truth
  is observable carry the command, items whose truth is not say so and name who settles them,
  and the *absence* of a check is information rather than a gap to be filled.
  **(c) What a guard may check here, and what it may not.** No guard can ask "is this item
  still true" — the items are prose. It can only run an item's own stated command, which means
  the mechanical form has to be a queue that carries commands, not a queue that carries
  attestations. Anything that checks whether a session "verified the queue" is the banned shape
  (**D-014**), and the ban's own test applies: does anything downstream consume it?
  **(d) Generalises past the queue.** Any durable instruction addressed to a future session —
  queue item, TODO, handoff paragraph — has this shape, and the same session that restated the
  tag item also inherited a handoff saying "cut the next branch from `…-ol544l`, not from main"
  after that branch had merged. **Written-once state read by a session that cannot see when it
  was written must carry the means of testing itself, or it becomes confident misinformation
  with age.**
- DA-012: **A presence check answers the question it can reach, not the question it was asked —
  and the gap between the two is invisible from its own output.** The fix for DA-011 added a
  session-start line reporting whether the release tag named by the version file exists. It
  asked `git rev-parse --verify refs/tags/<tag>`, which reads refs in the local clone, while
  `AGENTS.md` and P9 said it reported whether the tag *existed*. Both statements look identical
  in a repo where clones carry tags. This one does not: the default fetch refspec covers heads,
  so `git tag` here is empty while `git ls-remote --tags origin` lists two — the very command
  DA-011 records as the one that settles the question.
  **(a) The wrong-layer check does not fail, it alarms — and an alarm that is always on is
  worse than no alarm.** Every session in this repo would have read "NO tag amh-v2.0.0 in this
  clone" from the moment it shipped, for a tag that had been cut before the line was written.
  The load-bearing state (merged-but-untagged) would have been byte-identical to the steady
  state, so the tripwire would have been decorative on its first day. `amh.conf` already names
  this failure — warn fatigue kills tripwires — and the diff walked into it anyway.
  **(b) The fixture pinned the defect as the specification.** `ss_release_untagged` asserted the
  false-alarm text was correct behaviour, so the suite would have gone green forever on it, and
  a later session reading the fixture would have concluded the alarm was intended. **A fixture
  written from the implementation inherits its bugs as requirements**; the fixture that would
  have caught this — tagged on origin, absent locally — was the one case nobody thought to
  write, because the implementation had no branch for it. Write the fixture from the CLAIM.
  **(c) "Cannot tell" is a third outcome and needs its own branch.** The first draft had two:
  found, and not-found. No git, no repo, no remote, network down and a credential prompt all
  fell into not-found, so the banner manufactured a fact whenever it was least able to check
  one. The shipped form reports present / absent / unreachable, bounds the probe with `timeout`
  and `GIT_TERMINAL_PROMPT=0`, and never lets an unanswerable question render as an answer.
  **(d) The prose is where the over-claim lands, and rule files are the expensive place for it.**
  The script's own comment was accurate ("this reads refs in THIS clone"); the constitution and
  P9 dropped the bound, and P9 ships to every adopter. This is D-010's shape for the third time
  (**DA-008**, **DA-010**), which is enough repetitions to state the rule flatly: **when a check
  and a sentence about the check are written in the same change, the sentence is the part to
  distrust** — the code was tested, the sentence was not, and only one of them is legislation.

- DA-013: **Prompt-level priming matters more than document-level instructions for agent behavior.** Two failures in a real AMH deployment: (a) a compression pass that landed at 10.2 KB (above the 9 KB floor) triggered a micro-trim cascade — the guard's fail message said "go to the floor or leave the file alone" without saying HOW (fold stages, move content to ledger), so the agent shaved clauses iteratively. Fixed: the guard's Branch 1 and Branch 3 fail messages now name the compression techniques and explicitly say "do not micro-trim"; the seed template preamble addresses the short-first-pass pattern. (b) The agent instantiated AMH on the `light` profile without asking the owner which profile they wanted. AMH-ADOPT.md step 1 says "ask the owner before you fill anything in" — but the Quick Start prompt block (what the owner pastes, and what the agent reads first) said nothing about the profile question. The agent had no primed expectation of needing to ask. Fixed: the Quick Start prompt now includes "It will ask you which installation profile to use — present the options and wait for my answer before proceeding." **The generalisation:** when an instruction matters, it must appear in the agent's first-read context (the owner's prompt), not only in a document the agent reads later. A document the agent "should" read is not the same as one it will act on — the prompt is the one context an agent cannot skip.
- DA-014: **A shared harness's default namespace must describe the work, not the agent that
  happens to perform it.** The reference instance and initializer used `claude`, even though
  the shipped scripts' safe fallback was already `session` and the repository now supports
  multiple agent adapters. The owner selected `session` through the binding-rule review path:
  `amh.conf`, initializer help/defaults, adopter-facing examples and this repository's
  constitution now agree, while `--branch-prefix` remains the configuration path for an
  adopter that wants any other namespace. The fixture therefore pins both halves: a default
  initialization yields `session`, and an explicit arbitrary value survives.
  **Commit identity is a separate decision, not a reason to brand branches.** A reachability
  audit found every address form already admitted by `AUTHOR_EMAIL_ALLOW` in repository
  history, so removing any would reject commits this branch train legitimately contains.
  They remain as the owner-approved no-reply set. No Codex/OpenAI address was added: agent
  name does not establish approval, and inventing a plausible no-reply address would turn an
  identity-protection rule into an inference. A new agent identity requires the owner's
  approved non-personal commit address first.
- DA-015: **A template that exists only at the interface one tool bypasses is not an
  action-point instruction.** The agent-neutral branch-prefix PR was created through a metadata
  tool that accepted a free-form title and body without surfacing GitHub's repository template.
  The template already had the exact section the resulting body needed — “What the review pass
  found” — but the contributor workflow mentioned the template only while defending prose from
  the self-attestation ban. The review did happen and found a defect, yet the PR body omitted
  it, so the owner had to ask whether the mandatory pass had run. The fix is deliberately
  prose-only: immediately before the merge rules' owner-actions line, contributors are told to
  open `.github/pull_request_template.md`, use every applicable heading and delete the rest.
  **It must not become a presence check.** Requiring or grepping for those headings would prove
  only that an agent can reproduce headings and would violate D-014; the nudge earns its place
  by making useful disclosure easier at the moment the body is written, not by treating that
  disclosure as evidence.
- DA-016: **A first-class adapter is a cross-layer contract, not merely a file that exists.**
  Claude Code and Codex adapter files had source templates, reference-instance counterparts,
  initializer actions and permission-scope entries, but no single check declared that set. A
  partial removal could therefore leave the remaining layers internally green. The repo-local
  adapter-set guard now names the expected source/destination pairs and checks delivery plus
  both the reference and adopter `RULE_FILES` values. Its fixtures independently remove a
  Codex reference path, installer action, reference legislation entry and adopter legislation
  entry; inference from surviving files is deliberately avoided because it would let the
  expected set shrink with the defect.
- DA-017 [cited]: **Context-efficient reading is a bounded-retrieval rule, not a command-use
  attestation.** Large runbooks and ledger volumes can be loaded whole even
  when one named section or identifier answered the question, spending the agent's context on
  irrelevant history. The entry constitution now requires query-first, section-bounded reads
  with an explicit widening rule for prerequisites, interacting rules and ambiguity; the
  runbook gives portable `grep`/`awk` examples but admits equivalent native range tools. Stored
  line-number indexes were rejected because ordinary edits make them drift. The repo-local
  navigation guard declares the binding runbook headings independently and rejects missing or
  duplicate headings; it deliberately cannot check which commands ran or what an agent read,
  because consuming such an attestation would recreate D-014.
- DA-018 [cited]: **The constitution compaction itself caused the pointer-loss incident that
  earns the navigation guard.** Review found that the shortened entry route omitted the binding
  Session discipline section and incorrectly equated `RULE_FILES` with rule-review scope,
  despite the runbook explicitly defining that list as an incomplete, file-granular tripwire.
  This was a real rule-discoverability regression in the proposed repository state, not a
  mutation invented to justify machinery. The correction restores an explicit Session
  discipline pointer, adds that pointer/heading pair to the independently declared navigation
  contract, and adds a fixture that deletes it. The same pass reconciled stale Current state
  claims and narrowed secret wording so automated identity checks may inspect commit metadata
  without rendering an unapproved address.
