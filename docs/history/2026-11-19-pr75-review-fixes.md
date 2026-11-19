# PLAN — fix the adopter-facing findings of the 17.0.0 train's PR-time review

> **Status: done — every unit, F0 to F3, finished on 2026-11-19 (DD-107 to DD-109); archived.
> Adopted by the owner on 2026-11-19, with F1, F2 and F3 approved to run in that order.** The
> owner answered the three decisions before any unit started (§1). Each unit was one fresh
> session; a unit that found a decision §1 does not settle stopped and asked.

The plan is provisional while it is live. Its durable outcomes go to Changelog lines and ledger
rows. Code cites ledger rows and never this file, and no ledger row may cite this file's path.
When F3 is done, archive this file to `docs/history/` or delete it (`docs/PROTOCOLS.md` →
**Session discipline** 5).

## 1. Owner decisions (2026-11-19)

1. **Scope: every adopter-facing finding** of the review in §2. That means every finding about
   what ships — the shipped scripts, `scripts/amh-init.sh`, the seeds, `README.md`,
   `docs/UPGRADING.md` and the 17.0.0 entry of `harness/CHANGELOG.md`. Out of scope: the
   repo-local guards and tests (`scripts/guards/`, `scripts/tests/`) except where a unit's own
   fixture lives there, and all of `conformance/`.
2. **The two upgrade-order P1s are fixed in the Upgrading text, not in `amh-init.sh`.** No
   installer upgrade mode is added.
3. **`session-start.sh` reports a failed advisory-marker removal** (shipped behaviour change).

Conventional defaults, not owner decisions, which a unit may revisit only with a stated reason:
every fix folds into the unreleased 17.0.0 entry, and `harness/VERSION` does not change. Every
shipped-script change goes through `docs/RUNBOOK.md` → **Change a shipped script**: edit under
`harness/templates/scripts/`, copy it down byte for byte, and regenerate the manifest. Every
behaviour change ships a fixture shown to fail with the behaviour removed (**Add a guard**).
**No item is added to the Owner queue:** a finding a unit cannot fix, or does not reproduce, is
recorded with its reason in that unit's section below and in its ledger row.

## 2. The review

One gpt-6.2-astra `-e xhigh` read-only review of `git diff origin/main...f2df31b`, verdict HOLD,
archived locally at `.orch/runs/20261119T083801Z-pr-17-train/answer.md`, and summarized in PR
#75's description. The file:line references below are as of `f2df31b`. **Every unit first
verifies each of its findings against the current tree** — by reading the code, or by a probe in
a `mktemp -d` tree — and fixes only what holds. The session that wrote this plan confirmed the
items marked *(confirmed)* by reading the code; the rest are the reviewer's claims.

## 3. The units: F0, F1, F2, F3

**Order: F1 → F2 → F3.** Every unit owes a Sol review beside its writes and the rule-review
protocol (`bash .orch/codex.sh rules`) before its commit whenever its diff touches `RULE_FILES`.
Each unit also owes the full `scripts/ladder.sh` on its final tree, one ledger row in the live
volume, one `docs/STATE.md` Changelog line, and its section's Status marked done here, all in
the same commit, then the post-commit guards-only run and a push of the session branch.

### F0 — commit this plan: done 2026-11-19

- **Done:** committed with the owner's three answers; `docs/STATE.md` lists it under Live plans.
- **Acceptance:** `scripts/ladder.sh --guards-only` green.

### F1 — the Upgrading text, the README and the seed ledger (docs)

Findings, all in prose:

- *(confirmed, P1)* `harness/CHANGELOG.md:127` and `:150`. The entry has the adopter re-run
  `amh-init.sh` after `docs/UPGRADING.md:41` has re-applied a script fork, and `amh-init.sh`
  installs shipped scripts with `overwrite` (`scripts/amh-init.sh:667`), so the fork is reverted
  and the manifest restored. Reorder so that every writing installer run comes before the
  scripts are copied and the fork re-applied, or say explicitly to re-apply the fork after it.
  Check `docs/UPGRADING.md` reads consistently with the new order.
- *(confirmed, P1)* `harness/CHANGELOG.md:127` against `:172`. In a repository with no
  `.claude/settings.json`, re-running `amh-init.sh` installs the sandbox-on adapter
  (`keep`-if-absent, `scripts/amh-init.sh:709`) before step 5 asks for consent. Before that run,
  have the agent check whether the file is absent and, if so, ask the user step 5's question
  first, then either keep the installed adapter or remove its `sandbox` block.
- *(confirmed, P2)* `harness/CHANGELOG.md:120`. The inventory says `command-guard.sh` changed in
  comments alone and omits `session-start.sh`. List every shipped script that changed against
  `amh-v16.1.1` (`git diff amh-v16.1.1 -- harness/templates/scripts/` settles it), with each
  one's behaviour changes. That includes whatever F2 and F3 change, so F2 and F3 each extend
  this list.
- *(confirmed, P2)* `harness/CHANGELOG.md:160`. Steps 2 and 3 duplicate Session discipline 12 and
  the adversarial-review sentence, which the freshly written `docs/PROTOCOLS.md` already holds.
  Make both steps conditional on the text being absent.
- P2 `harness/CHANGELOG.md:135`. A 16.1.1 light adopter was told to remove ledger instructions
  and fold runbook guidance (`amh-v16.1.1:harness/templates/AMH-ADOPT.md:81`), and nothing
  restores the ledger rules or the instruction to select a runbook playbook. Name what to restore
  from `harness/templates/seed/AGENTS.md`.
- P2 `harness/CHANGELOG.md:150`. The disappearance of the migration block does not prove
  completion. Call it a diagnostic, and have the adopter compare each old customized section
  with its destination.
- P2 `harness/CHANGELOG.md:174`. Step 5's consent text omits the linked-worktree limit recorded
  at `README.md:305`. Add it, and scope the platform claims to the README's evidence.
- P3 `README.md:264`. The "fresh installs" sandbox claim does not hold where an existing
  `.claude/settings.json` is kept (`scripts/amh-init.sh:613`). Qualify it and point at the
  Upgrading step.
- P3 `README.md:166`. The profile table attributes `docs/plans/` to `full`; it is
  adopter-created.
- P3 `harness/templates/seed/docs/LEDGER.md:17`. The seed says a guard checks the correction
  pointer's form, but that guard is repo-local and not shipped. Qualify the claim. This is a
  seed under `RULE_FILES`, so the rule review applies.
- P3 `harness/CHANGELOG.md:117`. Add one line noting that the train also carries repo-local
  conformance and guard changes that ship nothing, kept apart from adopter actions.

**Acceptance:** each finding is fixed or recorded here as not reproduced; the full ladder green;
the rule review run, with its findings triaged in the ledger row.

**Status: done 2026-11-19 (DD-107).** Every finding reproduced and is fixed; none is recorded as
not reproduced. The rule review and a Sol review added a hand-applied step 7 for the seed
ledger's preamble and ten lesser fixes, all in DD-107. The inventory F2 and F3 extend is the
bullet list at the head of the 17.0.0 entry's **Upgrading** subsection.

### F2 — `session-start.sh`, `test-ladder-guards.sh` and `amh-init.sh` (shipped scripts)

- *(confirmed, P1; owner decision 3)* `harness/templates/scripts/session-start.sh:113`. The
  advisory reset removes markers with `2>/dev/null` and returns 0, so a marker it cannot remove
  (a `/tmp` it sees read-only, while the hook wrote there) leaves the next session holding a
  spent one-time advisory, unseen. Print a WARN naming the directory, never the marker's path
  (**DD-097**'s rule against printing a marker path), and keep the session-start exit status as
  it is. Add a fixture in the shipped suite that fails without the WARN.
- P3 `harness/templates/scripts/session-start.sh:525`. The bootstrap still calls a missing
  runbook deliberate in the default profile; every profile now installs it. Reword it as an
  incomplete or legacy install.
- P3 `harness/templates/scripts/test-ladder-guards.sh:2087`. An unwritable `/tmp` records omitted
  fallback fixtures as `ok`. Report them as skipped, with a separate count, so a pass total counts
  only assertions that ran.
- P2 `scripts/amh-init.sh:890`. The migration report greps the `RULE_FILES` assignment text,
  while the ladder matches effective entries with directory prefixes
  (`harness/templates/scripts/ladder.sh:1599`): a `docs` entry warns forever, and a later
  reassignment can hide missing coverage. Source the effective value and use the ladder's
  matching. `scripts/tests/test-init-e2e.sh` gets the fixture.
- Extend F1's changelog inventory with each of these behaviour changes.

**Acceptance:** each fixture is shown red with its behaviour removed, then green; copies
byte-identical; the manifest regenerated; the full ladder green; the rule review run and
triaged.

**Status: done 2026-11-19 (DD-108).** All four findings reproduced and are fixed. One departure
from the letter: the warning names the directory by its role, `/tmp` or `TMPDIR`, rather than
printing `TMPDIR`'s value, which the rule review showed can carry a home directory. The rule
review's other findings are applied, all in DD-108.

### F3 — the command guard's advisory state (shipped script)

All four are the reviewer's claims, so reproduce each one in a `mktemp -d` state directory
before changing anything:

- P2 `harness/templates/scripts/command-guard.sh:1726`. An explicit advisory-state override
  directly under `TMPDIR` is taken for a default path, and the report also reads an unrelated
  file of the same basename under `/tmp` (printed at `:9964`). Track whether an override was
  given, and read only that file.
- P2 `command-guard.sh:1928`. The dotenv and key-material advisories treat any existing entry at
  the marker path as a spent marker, a directory included. Require a regular file, and report an
  unusable state through the existing unwritable-marker path (**DD-097**: the advisory fires).
- P2 `command-guard.sh:9961`. A destructive advisory recorded in both directories but resumed in
  only one is reported as abandoned. Report the union of advised signatures minus the union of
  resumed ones.
- P2 `command-guard.sh:10004`. The spawn report counts one directory twice when it is reached by
  two spellings. Deduplicate by filesystem identity (`-ef`) before summing.
- Extend F1's changelog inventory with each of these behaviour changes, and update the guard
  header where it describes the advisory state.

**Acceptance:** each fixture is shown red with its behaviour removed, then green; the guard's
existing suite still passes; copies byte-identical; the manifest regenerated; the full ladder
green; the rule review run and triaged. Then archive or delete this plan (see above) in the same
commit, and leave PR #75's description for the owner's session to update.

**Status: done 2026-11-19 (DD-109).** All four findings reproduced in a `mktemp -d` state
directory and are fixed. The guard header meant here is the comment block above
`advisory_state_dir`, since the file's own header does not describe the state. The Sol review and
the rule review added a dangling-symlink case, silent opens, array-framed state paths (a newline
in an override), setup checks in every fixture and three prose fixes, all in DD-109. This plan is
archived to `docs/history/` in the same commit; PR #75's description is left for the owner's
session.
