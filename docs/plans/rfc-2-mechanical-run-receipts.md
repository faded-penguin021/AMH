RFC: Mechanical Run Receipts

Status: Proposed
Audience: AMH architecture and implementation review
Scope: Local sessions, hosted agents, containers and CI

Summary

Introduce a standard format for recording mechanically observed execution facts about an AMH work unit.

AMH currently preserves repository state and durable lessons. It does not produce a concise, portable record of which verification steps executed against a particular commit, which steps were unavailable, or which runtime integrations were active.

A run receipt fills that gap without storing prompts, conversations or full command histories.

Problem

After an agent hands work back, the owner can inspect:

- the diff;
- commits;
- state and ledger changes;
- the ladder or CI result.

What remains difficult to answer is:

- Which ladder rungs actually executed?
- Which rungs were skipped because a tool was absent?
- Was the reported green result produced against the current commit?
- Did runtime setup match the repository version?
- Did a command rail mechanically block anything?
- Was the run local, hosted or in CI?
- Which facts are known, and which were unobservable?

Chat summaries cannot answer these questions reliably because they are agent-authored disclosures. Full transcripts are noisy, vendor-specific and may contain sensitive material.

Design principle

«Store bounded facts emitted by mechanisms, not narratives emitted by the agent.»

A receipt records observations made by scripts, hooks, Git and CI.

It never records private reasoning or claims that a review was intellectually adequate.

Receipt layers

The format supports three independent evidence layers.

Layer 1: Repository evidence

Portable everywhere.

Examples:

- commit SHA;
- branch;
- dirty or clean worktree;
- ladder mode;
- rung names and outcomes;
- test-tool versions;
- state-file size;
- AMH version.

Layer 2: Runtime evidence

Available only where lifecycle integration exists.

Examples:

- session-start observed;
- command denied by the AMH guard;
- ladder invocation observed;
- session-stop observed;
- elapsed duration.

Layer 3: Host evidence

Produced by an external platform or CI, not inferred by AMH.

Examples:

- CI run identifier;
- hosted-task identifier;
- container image digest;
- provider-reported environment class.

The receipt must identify the source of every field so that external declarations are not confused with repository observations.

Canonical format

Use versioned JSON:

{
  "schema": 1,
  "subject": {
    "commit": "abc1234",
    "branch": "session/example",
    "amh_version": "3.0.0"
  },
  "producer": {
    "type": "github-actions",
    "id": "run-123456"
  },
  "verification": {
    "mode": "full",
    "result": "pass",
    "started_at": "2026-08-03T18:20:00Z",
    "finished_at": "2026-08-03T18:20:18Z",
    "rungs": [
      {
        "name": "guards",
        "state": "pass"
      },
      {
        "name": "shellcheck",
        "state": "unavailable"
      },
      {
        "name": "project-tests",
        "state": "pass"
      }
    ]
  },
  "runtime": {
    "session_start": "observed",
    "pre_command_guard": "observed",
    "post_command_observation": "unknown"
  }
}

State vocabulary

Verification rungs use:

- "pass"
- "fail"
- "skip"
- "unavailable"
- "not-run"
- "interrupted"

Runtime facts use the capability states defined by the Runtime Capability Contract:

- "observed"
- "configured"
- "unavailable"
- "failed"
- "unknown"

These values must remain distinct.

A skipped optional check is not the same as an unavailable required tool.

An interrupted ladder is never a passing ladder.

Ladder integration

Extend the existing interface:

scripts/ladder.sh --report path/to/receipt.json
scripts/ladder.sh --guards-only --report path/to/receipt.json

Requirements:

1. Human-readable output remains unchanged.
2. The ladder’s exit code remains authoritative.
3. A report is written for passing and failing runs.
4. A successful report is finalized only after every selected rung completes.
5. An interrupted run produces either no final receipt or an explicitly interrupted receipt.
6. The receipt’s commit must match the tree that was verified.
7. A dirty worktree is recorded rather than silently associated with "HEAD".

Runtime integration

Where post-command or stop hooks are observed, they may contribute runtime events.

Where those hooks are absent, the receipt still contains repository and verification evidence.

This makes the mechanism useful in:

- hosted environments with limited hooks;
- local CLIs with full lifecycle integration;
- CI;
- containers;
- plain shells.

The richest environment produces more evidence, but no environment changes the receipt’s authority model.

Storage and transport

Receipts are ephemeral diagnostic artifacts.

Supported transports:

- GitHub Actions artifact;
- CI job artifact;
- local ignored ".amh/receipts/" directory;
- hosted-agent task artifact where supported.

Receipts must not be committed to the product repository by default.

They are not permanent memory. Durable lessons discovered through them still belong in the ledger.

Status command

Add:

scripts/amh-status.sh
scripts/amh-status.sh --json

It combines current repository state with the newest matching receipt.

Example:

AMH status

Current commit: abc1234
Worktree: clean

Latest matching receipt:
  producer: GitHub Actions
  ladder: pass
  completed: 18 seconds
  guards: pass
  shellcheck: unavailable
  project tests: pass

Runtime integration:
  session start: observed
  pre-command guard: observed
  post-command observation: unknown

A receipt for another commit is reported as stale and never displayed as the status of the current tree.

Data minimization

Receipts must not contain:

- prompts;
- assistant responses;
- chain of thought;
- raw stdout or stderr;
- environment-variable values;
- source-file contents;
- issue or review bodies;
- arbitrary shell commands;
- credentials or credential fingerprints;
- personal identifiers not already present in repository metadata;
- agent-authored review attestations.

Exact command text is unnecessary for normal receipts. Store the canonical rung or operation name.

Authority model

The receipt is evidence that a named producer observed particular events.

It is not proof that:

- the agent followed every prose rule;
- a fresh-context review was intellectually independent;
- the provider’s sandbox was secure;
- no unrecorded command ran;
- absence of a denial means no dangerous command was attempted;
- the underlying tests are sufficient.

The Git tree, fixtures, ladder exit and CI status remain authoritative for their respective facts.

P3 compatibility

The receipt must not become a checklist the agent fills.

Acceptable producers:

- the ladder;
- deterministic hooks;
- Git;
- CI;
- the runtime doctor.

Unacceptable producers:

- an agent-authored JSON file claiming checks were performed;
- a commit message parsed as execution evidence;
- a review summary consumed by a merge gate.

Consumers must validate the receipt producer and subject commit before relying on it.

Positive controls

Every producer requires a control demonstrating that it can emit failure honestly.

Examples:

- plant a failing guard and require a "fail" rung;
- terminate the ladder and require "interrupted" or no finalized result;
- remove a required tool and require "unavailable";
- reuse a receipt after another commit and require a stale warning;
- alter the receipt and require schema or producer validation failure.

A format that can only emit green is not evidence.

Acceptance criteria

1. The ladder produces valid receipts for green and red runs.
2. A receipt is bound to the exact verified commit and worktree state.
3. Interrupted execution cannot yield "pass".
4. "skip", "unavailable", "not-run" and "interrupted" remain distinguishable.
5. CI uploads receipts for both successful and failed verification.
6. Local use works without CI or lifecycle hooks.
7. Hosted-agent branches can be evaluated through CI-generated receipts.
8. Runtime fields are absent or unknown where integration is unavailable.
9. No raw output, prompts or secrets enter the format.
10. Agent-authored receipts are not accepted as mechanical evidence.
11. "amh-status.sh" rejects or labels stale receipts.
12. Fixture tests cover malformed, forged, stale, failed and interrupted receipts.
13. The required fresh-context review is completed.
14. The ladder is green.

Non-goals

- Full command tracing.
- Session replay.
- Transcript storage.
- Productivity measurement.
- Token or cost accounting.
- Proving compliance with prose-only rules.
- Replacing CI status.
- Creating a new permanent memory tier.

Implementation directive

Start with ladder-generated receipts only.

Implement and test:

1. schema;
2. green receipt;
3. red receipt;
4. interrupted behavior;
5. exact commit binding;
6. CI artifact upload;
7. status display.

Add runtime hook evidence only after the Runtime Capability Contract can establish that the relevant hook actually operates.