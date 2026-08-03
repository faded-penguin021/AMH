RFC: Runtime Capability Contract

Status: Proposed
Audience: AMH architecture and implementation review
Scope: All agent environments: hosted cloud, local CLI, containers, VMs and CI workers

Summary

Introduce a repository-owned runtime capability contract that determines what an agent environment can actually support before AMH relies on it.

AMH currently defines how an agent should work inside a repository. It does not have a general mechanism for distinguishing between environments that provide different lifecycle hooks, network access, filesystem persistence, credentials, tooling or isolation.

That gap causes two opposite failures:

1. AMH may assume a capability that is unavailable, leaving a mechanism silently inactive.
2. AMH may avoid a useful mechanism because one supported environment lacks it, forcing every environment down to the weakest common denominator.

The proposed capability contract provides a third option: define canonical AMH behavior once, detect which parts the active environment can support, and degrade explicitly where they cannot.

Motivation

An AMH-maintained repository may be opened through:

- a hosted coding-agent task;
- a local Claude Code or Codex session;
- a development container;
- a CI worker;
- a plain shell with no lifecycle integration;
- a future agent with a different adapter model.

These environments differ in ways that materially affect AMH:

- whether a session-start command runs automatically;
- whether commands can be inspected before execution;
- whether post-command events exist;
- whether terminal output can be filtered;
- whether the home directory persists between sessions;
- whether outbound network access is available;
- whether Git credentials are present;
- whether setup runs before or during the agent session;
- whether background processes survive between commands;
- whether the environment is already isolated from the host.

Today these differences are expressed indirectly through adapter files and prose. There is no canonical representation of the effective runtime.

Design principle

«AMH must distinguish required repository behavior from optional runtime acceleration.»

The constitution, state, ledger, runbook and ladder remain portable repository artifacts.

Lifecycle hooks, automatic setup, command interception, telemetry and sandboxing are runtime capabilities. They may strengthen or automate AMH, but their absence must not make the repository unintelligible or unverifiable.

Proposed architecture

Add a canonical runtime diagnostic:

scripts/runtime-doctor.sh

It produces both human-readable and machine-readable output:

scripts/runtime-doctor.sh
scripts/runtime-doctor.sh --json

Example:

AMH runtime

Repository:
  git worktree                 observed
  repository writable         observed
  origin remote               observed

Lifecycle:
  automatic session start     unavailable
  pre-command interception    observed
  post-command observation    unknown
  stop hook                   unavailable

Environment:
  persistent home             unknown
  outbound network            unavailable
  required tools              complete
  default-branch ref          observed

Security:
  static command rails        configured
  server branch protection    not observable here
  output filtering            unavailable
  host isolation              externally provided; not verified

Capability states

Every capability uses one of these states:

- "observed" — directly established by a deterministic probe;
- "configured" — repository configuration requests it, but execution was not observed;
- "unavailable" — the environment or adapter explicitly lacks it;
- "failed" — a supported probe ran and demonstrated that it is broken;
- "unknown" — AMH cannot determine the fact honestly.

"unknown" must never be translated into "unavailable", "disabled" or "safe".

Capability manifest

Define a versioned, vendor-neutral schema:

{
  "schema": 1,
  "repository": {
    "writable": "observed",
    "remote_origin": "observed"
  },
  "lifecycle": {
    "session_start": "configured",
    "pre_command": "observed",
    "post_command": "unknown",
    "session_stop": "unavailable"
  },
  "environment": {
    "persistent_home": "unknown",
    "network": "unavailable",
    "required_tools": "observed"
  },
  "security": {
    "static_command_policy": "configured",
    "output_filter": "unavailable",
    "host_isolation": "unknown"
  }
}

The schema describes capabilities, not vendors. Vendor adapters populate the same fields.

Probe design

A capability may be marked "observed" only through a mechanical effect.

Examples:

- A session-start hook writes a nonce-bearing marker before the agent’s first command.
- A pre-command hook blocks a harmless probe command with a known result.
- A post-command hook records the exit code of a fixed command.
- Persistence is tested by reading a stamp written in a prior environment lifecycle.
- Network availability is tested only when the repository has a legitimate need to know it.
- Required tools are tested by executing their version or help command.
- Repository write access is tested inside a temporary ignored path.

Do not infer capabilities from:

- environment names;
- model names;
- vendor documentation alone;
- an agent saying that a hook fired;
- the existence of a configuration file;
- a successful process exit that produced no expected artifact.

Runtime profiles

The contract may synthesize descriptive profiles, but profiles are outputs rather than configuration inputs.

Examples:

Repository-only

- no lifecycle hooks;
- no automatic command guard;
- ladder available;
- manual session entry required.

Guarded

- session-start and pre-command integration observed;
- no post-command telemetry;
- repository verification fully available.

Observable

- start, pre-command, post-command and stop integration observed;
- runtime receipts available;
- repository verification fully available.

Managed environment

- external isolation or credential handling is declared by the host;
- AMH reports that boundary as external and does not claim to verify it.

These labels improve diagnostics. No gate should consume the profile name; gates consume specific observed facts where justified.

Setup contract

Repositories may add an optional project-owned setup script:

scripts/environment-setup.sh

Its responsibilities are repository-specific:

- install or restore toolchain dependencies;
- prepare caches;
- verify installed tools;
- perform idempotent setup;
- write a successful setup stamp only after verification.

Hosted platforms, local wrappers and containers all invoke the same script where appropriate.

AMH must not place language-specific package installation inside its universal shipped scripts.

Session entry

"scripts/session-start.sh" remains the canonical entry procedure.

Where an automatic lifecycle hook is observed, the adapter invokes it.

Where no lifecycle hook exists, the constitution instructs the agent to run it manually.

The runtime doctor reports which path is active. It does not make the protocol dependent on automation.

Configuration and effective state

Keep these concepts distinct:

- Requested state: what adapter files and runtime configuration ask for.
- Observed state: what mechanical probes demonstrate.
- Required state: what this repository needs to complete its ladder.

A configured hook that has never produced its marker is "configured", not "observed".

A missing optional hook is advisory.

A missing capability required by "scripts/verify.sh" is a verification failure or explicit unavailable rung, according to existing ladder semantics.

Security boundary

The runtime contract must not claim to prove:

- container or VM isolation;
- provider credential handling;
- effective firewall policy;
- absence of sandbox escape vulnerabilities;
- protection implemented outside the repository.

It may state that such protection is externally provided or configured, but the value remains "unknown" unless a meaningful repository-side probe exists.

Storage

The latest diagnostic may be cached under an ignored runtime directory:

.amh/runtime.json

It is diagnostic cache, not a memory tier.

It must not be committed, cited from implementation or treated as historical truth.

Adoption model

The runtime contract is additive.

A minimal AMH installation remains functional without any automatic integration:

- the agent reads the constitution;
- runs session start manually;
- uses the state file;
- executes the ladder;
- checkpoints through Git.

Additional capabilities automate or strengthen that path.

Acceptance criteria

1. "runtime-doctor.sh" runs in a plain local shell, CI and at least one hosted agent environment.
2. The same capability schema is used in every environment.
3. Requested, observed, unavailable, failed and unknown states remain distinct.
4. A configured-but-nonfunctional hook is not reported as observed.
5. A failed probe cannot leave behind a successful marker.
6. The doctor contains no secrets, raw environment dumps or arbitrary command output.
7. A hookless agent retains a complete manual AMH workflow.
8. Environment-specific setup remains repository-owned.
9. No runtime profile becomes an agent-authored attestation gate.
10. The ladder remains the repository acceptance authority.
11. Fixture tests demonstrate both successful and deliberately broken capability probes.
12. The required fresh-context review for binding rule and adapter changes is completed.
13. The ladder is green.

Non-goals

- Building a container or VM runtime.
- Replacing provider isolation.
- Requiring identical features from every agent.
- Selecting a preferred vendor.
- Treating configuration as proof of execution.
- Moving repository policy into vendor settings.
- Making runtime diagnostics a new durable memory tier.

Implementation directive

Implement one vertical slice before generalizing:

1. Define the capability schema.
2. Add "runtime-doctor.sh".
3. Probe session-start and pre-command behavior for existing adapters.
4. Demonstrate an environment where a capability is configured but deliberately fails.
5. Preserve the complete manual fallback.
6. Record any genuinely new failure class in the ledger.

Do not add capability fields without a concrete consumer or diagnostic purpose.