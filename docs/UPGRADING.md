# Upgrading an adopting repository to a new harness version

For maintainers of a repo that has adopted the AMH. If you maintain *this* repo, see
`CONTRIBUTING.md` instead — cutting a release is a different job from consuming one.

Upgrading is deliberately not automatic. The harness is process, and process that changes
under you without your reading it is worse than process that lags a version behind.

## Hand it to your agent

Open your coding agent in the repository you want to upgrade, and paste this:

```text
Upgrade this repository's Agentic Maintenance Harness (AMH) to the newest release.

Find where we are first: AMH_VERSION in amh.conf, and the version recorded in the constitution.
If those two disagree, believe amh.conf and tell me.

Then resolve the newest release tag and clone exactly that tag — never a branch:

    git ls-remote --tags --refs https://github.com/faded-penguin021/AMH.git 'refs/tags/amh-v*' \
      | sed 's|.*refs/tags/||' | sort -V | tail -1
    git clone --depth 1 --branch <that tag> https://github.com/faded-penguin021/AMH.git /tmp/amh

Read /tmp/amh/harness/CHANGELOG.md forward, from our version to that one, oldest first. Each
entry's Upgrading section is the complete list for that step. Tell me what any MAJOR requires
before you act on it.

Copy the shipped scripts — the whole directory, not just the .sh files, because the manifest
beside them holds their hashes:

    cp /tmp/amh/harness/templates/scripts/* scripts/ && chmod +x scripts/*.sh

Then apply the changelog's Upgrading notes: new amh.conf keys, seed-prose changes I want by
hand, adapter or CI changes. Files I own are never overwritten — amh.conf, the seed documents,
scripts/verify.sh, scripts/guards, my workflow and adapter configs — and AMH-ADOPT.md is never
re-issued on an upgrade.

Run scripts/ladder.sh directly, never through a pipe, and drive it to green. A new guard
failing on something that was always there is a finding, not upgrade damage: fix the finding,
never weaken the guard to get green.

Record it: AMH_VERSION, the constitution's version line, a changelog line, and a ledger row for
anything this taught us.

Finally, delete /tmp/amh and tell me which version we moved from and to, what you changed by
hand, and anything that needs my attention. Do not invent repository information — derive it
from this repository and from the changelog.
```

If you are moving to a *specific* version rather than the newest, say so in that first line and
let the agent clone that tag instead. The rest of this document is what those instructions do,
in the order they do it, and it is worth reading before a MAJOR.

## What is upgradeable and what is yours

This split is the whole reason upgrades are cheap, so it is worth internalising:

| | Upgradeable | Yours forever |
|---|---|---|
| `scripts/ladder.sh`, `session-start.sh`, `command-guard.sh`, `redact.sh`, `test-ladder-guards.sh` | **copy over** — they are parameter-free | — |
| `scripts/MANIFEST.sha256` | **copy over** — generated at release, it holds the hashes of the five scripts above | — |
| `amh.conf` | — | yours; new keys are additive, listed in the changelog |
| `scripts/verify.sh`, `scripts/guards/*` | — | yours; the ladder's extension points |
| `AGENTS.md`, `docs/RUNBOOK.md`, `docs/STATE.md`, `docs/LEDGER.md` | — | yours; seed changes arrive as hand-applied notes |
| `.claude/settings.json`, `.codex/config.toml`, `.codex/rules/amh.rules`, `.github/workflows/*` | — | yours; diff each adapter or workflow against its template and take what applies |
| `AMH-ADOPT.md` | — | yours, and one-time: written only on a FRESH instantiation, and yours to delete when you have finished it. An upgrade run never re-issues it |

One invariant underwrites the whole table, and it is worth stating rather than inferring:
**nothing `amh-init.sh` does may be needed again after it exits.** Your tree is self-describing
and runs on `bash`, `git` and coreutils alone — the harness is never on your *runtime* path. It
is a claim about running your repo, not about never running the installer again: re-running it
is the supported way to upgrade the scripts and to escalate a profile, and both are you
choosing to copy files in. If a future release ever needed the harness present for your ladder
to work, that would be a defect in the release, not a new requirement on you.

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
cp /path/to/AMH/harness/templates/scripts/* scripts/
chmod +x scripts/*.sh
```

**Copy the whole directory, not just `*.sh`.** `scripts/MANIFEST.sha256` sits beside the
scripts because it holds their hashes, and your ladder's integrity rung compares the two. New
scripts against last version's manifest reads exactly like five locally edited scripts — the
rung will say so, and this is the fix. If you have no manifest at all (you upgraded before
this file existed), the rung warns on every run that the shipped scripts went unchecked;
copying it is what turns the rung on.

If you have the harness repo checked out, `scripts/amh-init.sh /path/to/your-repo` does the
same thing and is safe to re-run: it overwrites exactly the shipped scripts and leaves every
file you own — `amh.conf`, the seed prose, your workflow and adapter configs — untouched.

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

That patch is also exactly what the integrity rung reports, so it will not be quiet about it.
The way to live with a deliberate local patch is to delete `scripts/MANIFEST.sha256`: the rung
then warns, every run, that the shipped scripts went unchecked — a true description of your
tree, and deliberately not a silent one. Restore the manifest by copying it again once the
patch is gone.

Deleting the file is the *supported* way, not the only mechanical one, and the difference is
worth stating rather than implying: the manifest is an ordinary text file in your repo, so
removing one line excuses one script. Two things bound that. The rung refuses a manifest which
does not cover `scripts/ladder.sh` — the entry whose removal would excuse the file that decides
whether anything else is excused — and it prints the number of scripts it checked on every run,
so a count below what your version ships is the signal. Nothing else stops you. A guard cannot
defend a file you own against you, and a harness that claimed otherwise would only be teaching
you not to look.

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
