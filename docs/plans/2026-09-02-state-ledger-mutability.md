# PLAN — keep `docs/STATE.md` tree-relative (RFC unit 2 of 2)

Owner-approved as the second half of the RFC "Correct mutability boundaries in State and ledger
references", handed to this repository as external input and verified against the tree under P18.
Unit 1 shipped; this file carries what unit 2 owes so a cleared session can execute it from
`docs/STATE.md` alone. Provisional, as every plan is: the owner may pivot, and the unit ends
shippable. Archive or delete this file when unit 2 completes — the lifecycle unit 1 restored.

**Verification of every claim below happens during EXECUTION, not during drafting.** Re-read the
live files before editing them.

## What unit 1 already delivered (do not redo)

- `scripts/guards/path-refs.sh` classifies a ledger citation whose target is missing into three
  verdicts — established historical drift (exempt), must-resolve (fail), unclassifiable (`WARN`,
  exit 2) — against the commit that introduced the citing row, with a default-branch baseline
  fallback. Fixtures in `scripts/tests/local-guards.sh`, including the mutation case that
  restores the old `HEAD:<target>` test and watches the committed-removal case go red.
- The completed Windows CI plan is retired to `docs/history/2026-08-31-ci-sees-windows.md`.
  DC-033 keeps its original wording; `docs/plans/` was emptied.
- Live prose no longer says a committed ledger citation pins its target: `harness/src/10-principles.md`,
  `docs/RUNBOOK.md` session discipline 5, the seed runbook, all six ledger preambles,
  `scripts/guards/ledger-append-only.sh`, fixture commentary, the regenerated bundle, the 13.0.0
  changelog entry and its STATE pointer.
- Ledger row DD-004, with `Corrected by DD-004.` on DC-039 and DD-003. Both gained ` [cited]`
  because the guard's comments now name them.
- `harness/VERSION` deliberately still says 13.0.0. The RFC prepares ONE final MAJOR release for
  both units; do not churn the number between them.

## Unit 2 — the work

### State categories (the rule to encode)

1. **Repository-controlled state** — true for the checked-out tree until another repository
   change alters it: the version the tree declares, implemented behaviour, tracked active work,
   the live ledger volume.
2. **World-controlled state** — can change without changing the tree: whether a branch merged,
   whether a remote tag or release exists, PR and CI status, deployments, remote branches, forge
   protection settings.
3. **Historical observations** — past external facts kept for evidentiary value, explicitly
   scoped to when or where they were observed, never reading as current status.

Review test: *would this sentence remain accurate if the same commit were cloned tomorrow under
another branch name after forge state had changed?* If not, it is not unqualified truth in
`Current state`.

### The contract to state, at the smallest authoritative locations

- `Current state` records repository-controlled state and immediate operational information about
  the checked-out tree.
- It does not cache world-controlled status as current truth.
- Where a live probe already computes an external fact, State points at that probe rather than
  copying its most recent output.
- An unresolved owner action belongs in the Owner queue; observable items use the existing
  optional `Check:` form and are tested before repetition.
- External configuration a session cannot inspect must not be asserted as active — state the
  expected configuration or the unresolved owner action, without claiming observation.
- A historical observation may be retained only when useful and explicitly scoped to its
  observation time or ref. **No mandatory metadata schema.**
- Ledger and changelog history remain historical storage; sessions need not revalidate every past
  statement.
- Say explicitly that this is **prose-only**: no guard judges the temporal validity of
  natural-language State claims.

### Action points to inspect and update (minimum consistent set)

- P2/P9 in `harness/src/10-principles.md`
- `docs/RUNBOOK.md` (operational detail lives here)
- `harness/templates/seed/docs/RUNBOOK.md`
- `harness/src/30-scaffolds.md`
- `harness/templates/seed/docs/STATE.md`
- the State-reading and State-writing steps in `AGENTS.md` and `harness/templates/seed/AGENTS.md`

The first-read instruction must stop a session trusting an externally mutable legacy State claim
without checking it. The writing instruction must stop that class being written again. Keep
detailed reasoning in the new ledger row, operational detail in the runbook, short action-point
wording elsewhere.

### Repair `docs/STATE.md` itself

Audit all of it. At minimum:

- keep the mechanically required adopted-version statement (`version-lockstep.sh` binds it);
- express the current version as **declared by the tree**;
- point at `scripts/session-start.sh` for live release-tag status;
- do not repeat whether the current version is merged, tagged, released or awaiting a tag;
- remove completed release and CI narrative from `Current state`;
- remove or correctly route mutable claims about missing tags, remote branches, deployments and
  branch protection;
- name the live ledger volume **without** caching its latest row identifier;
- preserve genuinely active work, unresolved owner items and immediate operational gotchas;
- test every observable Owner-queue item before retaining it;
- do not turn historical residue into Owner-queue work merely to avoid deleting it.

Known offenders in the file as unit 1 left it: "prepared on this branch and untagged" (the tag
exists on origin), the 11.0.0/10.4.0 release narrative, "9.2.0 has a changelog entry and no tag",
"`docs/LEDGER_D.md` is live at **DD-002**" (DD-004 exists), and "`main` protection targets
`ladder`" — forge configuration no session can inspect.

### Preserve the live release probe

Revalidate `scripts/session-start.sh`'s release probe and its present / absent / unreachable
fixtures. **Do not change it for symmetry** — only for an independent defect with its own failing
fixture. Do not make startup or a new guard parse State looking for forbidden phrases.

## Release obligations (this unit, once)

**This is the largest single thing unit 2 owes, and it is owed for BOTH units.** Unit 1 changed a
binding rule and deliberately left `harness/VERSION` at 13.0.0, so the branch currently carries a
changed rule — visible in the regenerated bundle — with no changelog entry under any version. That
is the intended between-units state under "do not churn the version", and it stops being
acceptable the moment unit 2 ships. Do not leave the branch in it.

Verified 2026-09-02: `git ls-remote --tags origin` carries `amh-v13.0.0` at `6e79188`, which is
this branch's base commit, so 13.0.0 IS released and its changelog entry is a shipped record —
correct its description if it overclaims, never fold new behaviour into it. (Note for whoever
re-checks: `ls-remote` sorts lexically, so `amh-v9.1.0` prints last. Read the versions, not the
final line.)

Prepare one final **MAJOR** release for the combined RFC. Settle the number against the latest tag
at PR time: if `amh-v13.0.0` is still latest, it is **14.0.0**. Then the full playbook 5 lockstep —
`harness/VERSION`, the `harness/CHANGELOG.md` entry with its **Upgrading** subsection, `AGENTS.md`,
`docs/STATE.md`, `AMH_VERSION` in `amh.conf`, the `README.md` Quick Start tag, then
`scripts/build-dist.sh` and `scripts/build-manifest.sh`.

The **Upgrading** section must tell adopters to:

1. apply the revised State-writing rule;
2. audit `Current state` for world-controlled claims;
3. replace needed live status with a runtime check or an Owner-queue item;
4. remove advancing "live at D…-NNN" ledger identifiers while retaining the live volume;
5. update plan-lifecycle wording so legacy ledger citations no longer pin completed plans;
6. archive or delete completed plans retained only because an immutable row names their old path;
7. copy any shipped artifacts the normal upgrade procedure requires.

It must also carry unit 1's adopter-visible changes, since both units ship under one number:

- the path-guard rule itself (a committed ledger citation no longer pins its target; classify
  against the commit that introduced the row; `WARN` where nothing can classify it);
- the plan-lifecycle wording in `harness/templates/seed/docs/RUNBOOK.md` §5, which playbook 4
  requires Upgrading to name as the seed file to copy wording from;
- the ledger-preamble "Paths in rows" paragraph, from `harness/templates/seed/docs/LEDGER.md`.

## Non-goals (declined; do not add)

A database, MCP server, daemon, vector store or context-injection service; generated status files,
receipts, reports or decision summaries; mandatory observation metadata; a natural-language State
guard; a post-merge or post-tag bookkeeping commit; a redirect or tombstone for retired plans; a
general documentation-history database; a new conformance scenario; machine-consumed attestations;
a generic policy-engine integration.

## Acceptance

- `docs/STATE.md` contains no cached current release/tag/merge claim and names no latest ledger
  row identifier.
- Reference and shipped seed guidance express the same State and plan-lifecycle rules.
- No new service, status artifact, schema, dependency or conformance scenario exists.
- Generated artifacts rebuilt through their documented generators.
- `scripts/ladder.sh` green.
- **Exactly ONE blocking fresh-context rule review** on the complete green diff, before the commit.
  The RFC authorizes it; the standing no-subagent policy is lifted for it. The pre-execution
  command guard advises every spawn — re-issuing the identical spawn once is the sanctioned way
  through. The reviewer must specifically test that the State rules do not ban active work, the
  Owner queue or historical records, and that no required metadata or network dependency was
  introduced. Do NOT review a corrected diff a second time.
- Commit and push to `claude/state-ledger-mutability-qvj27g` only. Merging and tagging stay owner
  actions, represented by one correctly ordered Owner-queue item with a live check.
- Then delete or archive this plan file, and drop its `Current state` pointer.
