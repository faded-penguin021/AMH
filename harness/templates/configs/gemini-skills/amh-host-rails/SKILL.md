---
name: amh-host-rails
description: Use before counting on a hook or a deny rule to stop a command, before the first push of a session, and when a hook or the host refuses a call. Names the section saying what an adapter must wire, what an agent without a pre-execution hook loses, and how a failing hook behaves.
---

# AMH: Host rails

Configured, never observed loading on a live host; written against the Gemini CLI v0.70.0 documentation, retrieved 2026-11-23. This skill is prose: it names one binding section and enforces nothing.

What this adapter provides, since its settings file carries no comment: the session bootstrap, a command guard on `run_shell_command` (a `BeforeTool` hook) and output redaction (an `AfterTool` hook), all in `.gemini/settings.json`, which the Gemini CLI ignores whole in a folder it does not trust. It has no file deny rules and no sandbox, so a write under `.git/hooks/` or a read of a secret file is stopped by nothing but the written rules, and its hooks are documented as fail-open: a guard that crashes refuses nothing. Git's `pre-push` hook, once the bootstrap has installed it, is the one rail that holds without these hooks, and `--no-verify` bypasses it.

Read and follow:

`AGENTS.md` → **Agent harness**

It restates none of that section's rules. Read the section itself, in full, and where this file and the section seem to differ, the section binds.
