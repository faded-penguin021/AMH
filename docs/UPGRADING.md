# Upgrading an adopting repository to a new harness version

For maintainers of a repo that has adopted the AMH. If you maintain *this* repo, see
`CONTRIBUTING.md` instead — cutting a release is a different job from consuming one.

Upgrading is deliberately not automatic. The harness is process, and process that changes
under you without your reading it is worse than process that lags a version behind.

## What is upgradeable and what is yours

This split is the whole reason upgrades are cheap, so it is worth internalising:

| | Upgradeable | Yours forever |
|---|---|---|
| `scripts/ladder.sh`, `session-start.sh`, `command-guard.sh`, `redact.sh`, `test-ladder-guards.sh` | **copy over** — they are parameter-free | — |
| `amh.conf` | — | yours; new keys are additive, listed in the changelog |
| `scripts/verify.sh`, `scripts/guards/*` | — | yours; the ladder's extension points |
| `AGENTS.md`, `docs/RUNBOOK.md`, `docs/STATE.md`, `docs/LEDGER.md` | — | yours; seed changes arrive as hand-applied notes |
| `.claude/settings.json`, `.github/workflows/*` | — | yours; diff against the template and take what applies |
| `AMH-ADOPT.md` | — | yours, and one-time: written only on a FRESH instantiation, and yours to delete when you have finished it. An upgrade run never re-issues it |

The shipped scripts are the only files you copy, and they are safe to copy *because* they
contain nothing specific to your repo. If you have edited one, stop and undo that first: the
edit belongs in `amh.conf`, in a `scripts/guards/*.sh`, or in `scripts/verify.sh`. If it fits
none of those, the harness is missing an extension point — open an issue upstream rather than
carrying a local patch, because a local patch turns every future upgrade into a merge.

## The procedure

**1. Find where you are.** `AMH_VERSION` in your `amh.conf`, and the version recorded in your
constitution. If they disagree, you have already drifted; believe `amh.conf` and fix the doc.

**2. Read forward.** Every entry in `harness/CHANGELOG.md` from your version to the target,
oldest first. The version numbers tell you the shape of the work:

- **PATCH** — clarifications. Copy the scripts, done.
- **MINOR** — additive. New guards, templates or principles you may take or leave.
- **MAJOR** — a binding rule changed. Something you are doing now becomes wrong. The
  Upgrading section of that entry is the complete list.

**3. Do it on a session branch, in one unit.** Not spread across a week of sessions: a
half-upgraded harness is a harness whose rules disagree with its guards.

**4. Copy the shipped scripts.**

```bash
cp /path/to/AMH/harness/templates/scripts/*.sh scripts/
chmod +x scripts/*.sh
```

If you have the harness repo checked out, `scripts/amh-init.sh /path/to/your-repo` does the
same thing and is safe to re-run: it overwrites exactly the shipped scripts and leaves every
file you own — `amh.conf`, the seed prose, your workflow and adapter config — untouched.

The `--profile` flag it grew in 2.0.0 does not change that, and you do not need to pass it on
an upgrade. It decides which seed prose a **fresh** install receives; a file you already have
is kept whatever profile the run names, so a bare re-run never removes or declines a scaffold
you are using. Pass a larger profile only when you actually want the extra scaffolds — e.g.
`--profile full` to pick up `docs/history/`, the archive tier, which installs no longer ship by
default.

**5. Apply the changelog's Upgrading notes.** New `amh.conf` keys, seed-file changes you want,
adapter or CI changes. Nothing here is automatic — that is the point.

**6. Run the ladder before anything else.**

```bash
scripts/ladder.sh
```

Expect the new version's guards to fail on pre-existing conditions: a state file over a
threshold the old version did not enforce, an unmarked `[cited]` row, a credential-shaped
string that was always there. These are findings, not upgrade damage. Fix them; do not
weaken the guard to get green. If a new guard is genuinely wrong for your repo, delete it
from your copy of `ladder.sh` and record *why* in your ledger — but understand you have now
taken a local patch, with the merge cost that implies.

**7. Record it.** Set `AMH_VERSION` in `amh.conf`, update the version in your constitution,
add a ledger row for anything the upgrade taught you, and add the changelog line.

## Skipping versions

Fine. Read every intervening entry, oldest first, and apply each MAJOR's Upgrading notes in
order — a later entry may assume an earlier one landed. The scripts you simply copy at the
end; only the prose obligations accumulate.

## Staying behind on purpose

Also fine, and often correct. The harness has no telemetry, no auto-update and no deprecation
clock; a repo pinned at an older version keeps working indefinitely. The only cost is that
upstream bug fixes to guards and rails do not reach you. Record the decision under **Decided
non-items** in your state file with the date and reason, so the next session does not
re-litigate it.

## If the upgrade goes wrong

Nothing here is irreversible: the scripts are copies and `git checkout` puts the old ones
back. Reset to the last green checkpoint, run the ladder to confirm green, and record what
blocked you in the Owner queue. An upgrade that will not go green after two attempts is an
owner decision, not something to thrash on.
