# Squash-PR body — the founding branch train

> **What this file is.** The drafted body for the ONE squash pull request that merges the
> whole branch train into `main`. Drafting it was the session's job; opening the PR,
> merging it and tagging `amh-v1.8.0` are the owner's. Copy the section below the rule
> into the PR description; delete this file once the PR is merged, since a merged PR is
> its own record and a stale copy in the tree is a second source of truth.
>
> It describes the net `origin/main..HEAD` diff — **not** the last branch's — because
> `amh.conf` declares `MERGE_MODE=branch-train`: each session branch is cut from the
> previous one and contains it whole, so only this final superset branch merges.

---

## Establish the Agentic Maintenance Harness, and run it on itself

This is the founding change. `main` currently holds a single commit; everything else in
the repository arrives here, as one squash of a 38-commit branch train — 56 files,
roughly 13,300 insertions.

The repository is two things at once, and the second is what makes the first credible:

- **The source of truth for the harness** — a reusable operating prompt plus scaffolds for
  repositories maintained by agentic AI sessions. That product lives entirely under
  `harness/`: prose source in `harness/src/`, the artifacts an adopter receives in
  `harness/templates/`, and the generated single-file bundle in `harness/dist/`.
- **Its own reference instance.** `AGENTS.md`, `docs/`, `scripts/` and `amh.conf` are this
  repository running the harness, executing byte-identical copies of the scripts it ships.
  A guard (`scripts/guards/copy-drift.sh`) fails the build if the two ever differ, which is
  what turns "we dogfood it" from a claim into a check.

### What is here

**The acceptance ladder** (`scripts/ladder.sh`) is the single verification entrypoint, run
identically by the agent and by CI, so "green locally, red in CI" can only ever mean the
environment. It carries guards over working memory size, required document structure,
ledger rollover, citations in both directions, a secret-shape scan, commit-message poison
tokens, git author identity, rail self-tests and a repo-local extension point, then hands
off to `scripts/verify.sh` for the full test set.

**The author-identity rung is worth singling out**, because it is the one guard here that
can reject a newcomer's real address. It fails on the identities git invents when nothing
is configured — `root@host`, `you@localhost`, `you@laptop.local`, `(none)`, an address with
no `@` — which need no configuration to detect and are never a person's address. Beyond
that it checks `AUTHOR_EMAIL_ALLOW`, an optional regex **defaulted to empty in the script**
so that no adopter's existing `amh.conf` has to gain a key to keep a ladder green. The
allowlist is consulted first, so a project whose real addresses look machine-generated can
name them rather than edit a shipped script. It cannot tell a personal address from a work
one, and says so wherever it is described.

**Two rails that run as filters rather than advice.** `scripts/redact.sh` is the output
redaction filter and *is* the repository's secret scan — the ladder pipes every text file
through it and fails on any difference, so the patterns cannot drift out of sync with the
scan. `scripts/command-guard.sh` is the pre-execution command guard. Both carry their own
self-test matrices, and both generate their fixture tokens at runtime, because a stored
credential-shaped literal would make a file permanently fail its own scan.

**Memory in two tiers.** `docs/STATE.md` is working memory under a hysteresis size band —
grow to a soft cap, then one deep compression pass to a floor, never to just under the cap.
`docs/LEDGER.md` is the permanent, append-only registry of numbered deviations and
discoveries: 35 rows, never deleted, corrected in place with pointers when they go stale.

**The adopter's path exists and has been walked.** `scripts/amh-init.sh` instantiates the
harness into a fresh repository, `scripts/tests/test-init-e2e.sh` builds one end to end on
every ladder run, and `CONTRIBUTING.md`, `README.md` and `docs/UPGRADING.md` are the front
door. This matters more than it sounds: for most of the branch train the harness had never
been instantiated, and the first time anyone ran that path it was red — the shipped scripts
cited ledger rows that cannot exist in an adopter's tree. Nothing had detected it, because
nothing had executed it.

**Session bootstrap and CI.** `scripts/session-start.sh` is the agent-neutral boot sequence
any hook mechanism invokes; `scripts/bootstrap.sh` is this repository's own toolchain step
behind it. `.github/workflows/ci.yml` runs the ladder; `.github/workflows/release.yml`
verifies the tree against `harness/VERSION` and publishes the bundle on a version tag.

### How it was built, and what that produced

Every unit took one fresh-context reviewer, blocking, one pass, with the diff held
uncommitted while it ran. Of the nineteen such passes, **eighteen found the blocking
defect inside the fix rather than in the original problem**. That is the single most
reproducible fact in this history, and several of the ledger's rows exist only because of
it: a lint waiver widened to cover a whole compound and blinding the secret scan; a fixture
whose token satisfied its predicate only *usually*, giving roughly a one-in-five chance of
a red CI run per push; an assertion helper named for a condition it never asserted, twice,
the second time in a helper written after the row recording the first.

A few consequences are worth stating plainly, because they read as odd in the diff:

- **The shipped scripts cite nothing.** They refer to harness ledger rows in a form the
  citation guard does not read as a citation. A citation is a promise the ID resolves, and
  in an adopter's tree it cannot. The earlier fix — excluding the shipped scripts in the
  shipped config — was retracted, because `amh.conf` is the adopter's forever and a harness
  cannot upgrade it; shipping that list would have turned every existing adopter's ladder
  red until they hand-edited a file they were told they own.
- **Two ledger rows deliberately carry no `[cited]` marker**, and say so, with a note naming
  the files that lean on them. That is the accepted cost of the point above.
- **Two failures of verification itself are recorded rather than smoothed over.** A review
  pass that dies and one that finds nothing both end as "no findings", so a stalled-looking
  reviewer was replaced while it was still working and the two then ran concurrently — one
  mutating a script the other's fixtures were copying. The conclusion is in the ledger and
  is not "add a completion checkbox": a completion marker is a self-report, and what earns
  trust is a falsifiable claim the caller replays. Separately, a scripted edit to the
  working-memory file spliced the document into itself, duplicating every section, and
  shipped green — the structure guard asked whether sections existed, not whether they
  appeared once. It counts now, and has a fixture.
- **`shellcheck` is CI-only by constitutional carve-out**, and the ledger records the price
  rather than pretending there isn't one: it is the rung most often red in this history and
  it is invisible to a local run, so `scripts/bootstrap.sh` installs it on every remote
  session.

### Verification

`scripts/ladder.sh` is green on this branch, run directly. CI is green. The instantiation
test builds a fresh adopter repository and runs *its* ladder as part of every run.

### After merge

Tag `amh-v1.8.0`. The release workflow verifies the tree, checks the tag against
`harness/VERSION`, and publishes the bundle.

Delete `docs/SQUASH_PR_BODY.md` — this description is its own record, and a copy left in
the tree is a second source of truth. Later pull requests have
`.github/pull_request_template.md` instead.
