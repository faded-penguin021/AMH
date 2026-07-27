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
