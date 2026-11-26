---
trigger: model_decision
description: Use before counting on a hook or a deny rule to stop a command, before the first push of a session, and when a hook or the host refuses a call. Names the section saying what an adapter must wire, what an agent without a pre-execution hook loses, and how a failing hook behaves.
---

# AMH: Host rails

Configured, never observed loading on a live host; written against the Antigravity documentation for CLI 1.5.12 and App 2.34.0, retrieved 2026-11-23. This rule is prose: it names one binding section and enforces nothing.

What this adapter provides, since its hooks file carries no comment: the session bootstrap and a command guard on `run_command` (a `PreToolUse` hook), in `.agents/hooks.json`. It has no output redaction and no repository-local deny rules, so a command's printed output reaches the model unfiltered, and a write under `.git/hooks/` or a read of a secret file is stopped by nothing but the written rules. What a failing hook does to the call is undocumented, and the host's terminal sandbox is set in user or App settings, which no file here can see. Git's `pre-push` hook, once the bootstrap has installed it, is the one rail that holds without these hooks, and `--no-verify` bypasses it.

Read and follow:

`AGENTS.md` → **Agent harness**

It restates none of that section's rules. Read the section itself, in full, and where this file and the section seem to differ, the section binds.
