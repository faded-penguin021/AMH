# CLAUDE.md — pointer

**Read [`AGENTS.md`](AGENTS.md) in full.** It is the canonical constitution for every agent
working in this repository; this file only points at it and must never diverge from it.

If your harness has no session-start hook, run `scripts/session-start.sh` yourself before
anything else. Claude Code wires it — along with the pre-execution command guard and the deny
rails — in `.claude/settings.json`.
