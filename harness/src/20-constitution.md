---

## Part 2 — The constitution (drop-in template)

Instantiate the placeholders, then place this at the repo root as the always-loaded agent
instructions file.

**One file is canonical; every other agent's expected filename is a pointer to it, and pointers
only point — they never diverge.** `AGENTS.md` is the emerging cross-agent default; agents that
read a different filename (Claude Code reads `CLAUDE.md`) get a short stub referring to the
canonical file. Which file is canonical matters less than the single-source rule: an
established repo whose citations all name one file keeps that file canonical and points the
others at it.

### `AGENTS.md`

<!-- amh:include harness/templates/seed/AGENTS.md -->

### `CLAUDE.md` — the pointer stub

<!-- amh:include harness/templates/seed/CLAUDE.md -->
