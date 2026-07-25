# The Agentic Maintenance Harness

**Harness version @AMH_VERSION@.** Repos that adopt it record the version they took
(`AMH_VERSION` in `amh.conf`, and a line in their constitution), so process drift stays
diagnosable as the harness evolves.

This is an operating harness for **any** repository maintained by agentic AI sessions — any
agent, any model vendor — with a human in the loop. It is deliberately agent-agnostic: the
behaviour lives in a constitution file, a state file, a runbook, an append-only ledger and a
handful of shell scripts, and each agent gets a thin adapter that wires them up.

It has three parts:

- **Part 1 — Design principles.** The extracted logic: *why* each mechanism exists. Read this
  first, so you can adapt the harness intelligently rather than cargo-culting it.
- **Part 2 — The constitution.** A drop-in, placeholder-parameterised operating prompt: the
  target repo's always-loaded agent-instructions file. This is what the agent reads every
  session.
- **Part 3 — Scaffolds.** The supporting artifacts the constitution refers to: state file,
  runbook, ledger, the guard and rail scripts, session bootstrap, and permission rails.

Placeholders use `{{DOUBLE_BRACES}}`. Instantiate them for the target repo and delete anything
that genuinely does not apply — but read Part 1 first: most pieces earn their keep only in
combination.

**Source of truth.** The canonical home of this harness is a repository that both distributes
it and is maintained under it. This file is generated there from the same template files an
adopting repo copies, so the document and the artifacts cannot disagree. If you have the
repository, prefer `scripts/amh-init.sh` over copying out of this document by hand.
