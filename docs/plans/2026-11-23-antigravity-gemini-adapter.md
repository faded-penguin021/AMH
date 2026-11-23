# PLAN — a third host adapter: the Gemini CLI and Antigravity

> **Status: adopted by the owner on 2026-11-23; A0 done.** Units A1 to A5, run in order by the
> plan runner on `session/antigravity-adapter`. **Do not archive or delete this file in any
> unit**: the runner reads each unit's done marker here. The session that merges the train
> archives it afterwards.

The plan is provisional while it is live. Its durable outcomes go to Changelog lines and ledger
rows. Code cites the ledger rows and never this file, and no ledger row may cite this file's path.

## 1. Why, and the owner's decisions

The AMH ships two host adapters: Claude Code (`.claude/settings.json` and its hooks) and Codex
(`.codex/config.toml`, `.codex/rules/amh.rules`, `.codex/agents/amh-rule-reviewer.toml`). The
owner asked for a third, for Google's Gemini model family as its agent hosts run it: the
**Gemini CLI** and the **Antigravity** agent IDE (and its `agy` CLI). Neither host's binary is
on this container's `PATH`; nothing about either is measured in this repository yet.

**Owner decisions (2026-11-23):** the plan is pre-approved in full, every unit included, for the
plan runner; the owner is away and **the session decides every fork itself**, recording each
choice and its reason in the unit's ledger row. This overrides, for this plan only, the standing
habit of asking the owner a unit's decisions before it starts. An item the session cannot settle
— above all, whether a configured rail actually fires on a live host — goes to the Owner queue as
an observation to make, never as a blocker for the next unit.

**The adapter has two layers, and each host gets only the ones it really has** (owner,
2026-11-23, after reading the draft). The Claude and Codex adapters are mostly **rails**: hooks
that run the command guard and the output redactor, static deny rules, a sandbox setting. A host
may instead offer mostly **procedure surfaces**: skills loaded on demand, rules, workflows, and
subagents with a fresh context. Antigravity is expected to be of that second kind, so its adapter
is likely skills, perhaps a read-only reviewer subagent, and git's own `pre-push` hook as its only
rail. A procedure surface is prose: it helps an agent find and follow the binding documents, and
it enforces nothing. It is never described as a rail.

Decisions taken when the plan was drafted, which a unit may revisit only with a stated reason in
its ledger row:

1. **Unit prefix `A`.** `G1` is an open Owner-queue item, so `G*` is not used.
2. **Two hosts, decided separately.** The Gemini CLI and Antigravity are distinct hosts. Neither
   may be assumed to share the other's config path, instruction-file discovery or hook schema.
   A1 settles, per host, whether it gets adapter files, a prose-only entry, or nothing.
3. **Evidence bar for anything shipped.** A setting key, hook event, payload field, exit-code
   contract or rule syntax may enter a template only if the host vendor's own documentation for
   a named version states it, cited with URL and retrieval date in A1's evidence table. Memory,
   blogs, forum posts and model answers are leads, never evidence. A capability the vendor does
   not document stays out of the templates and is written down as `unverified`.
4. **Same honesty as the existing adapters.** Every shipped file says, as the Claude and Codex
   templates do, that it is configured and has never been observed firing. Only a live probe the
   owner runs can change that, and A5 queues it.
5. **Version: MINOR, 17.1.0**, settled once in A5 for the whole train (`amh-v17.0.0` was
   verified on `origin` on 2026-11-23). If a later unit on this train changes shipped behaviour
   after A5, the version is re-settled at PR time as `docs/RUNBOOK.md` already directs.
6. **A skill points, it does not restate.** A shipped skill, rule or workflow carries a short
   trigger and names the binding section to read (`docs/RUNBOOK.md` → a playbook,
   `docs/PROTOCOLS.md` → **Acceptance ladder**, and so on). It never copies a rule's text: a copy
   drifts from the source, and moving a live rule out of its document is repeal (`AGENTS.md`).
7. **A complexity budget.** Neon's own warning about this repository is that its discipline can
   turn into bureaucracy. So each host gets the fewest files that cover its documented surfaces,
   every shipped file traces to a §3 row, and no new guard is added beyond one wiring check per
   new surface in `scripts/guards/adapter-set.sh`. A procedure is shipped as a skill only if it is
   a session-time entry point: the session start, the acceptance ladder, the rule review, and
   reading **Host rails and what they miss**. Repackaging the whole RUNBOOK as skills, and shipping
   AMH skills to Claude and Codex as well, are not part of this plan.
8. **B0 on the same branch.** `2026-11-22-build-output-secret-scan.md` (draft, B1 queued) rides
   this train untouched. No A unit edits it; both plans touch `docs/STATE.md`, so each unit
   rereads it before editing.

Leads for A1 to verify or discard — **not facts**, and nothing below may be copied into a
template on its own authority: the Gemini CLI is reported to read project settings from
`.gemini/settings.json`, to load `GEMINI.md` by default with a setting that can name other
context files (such as `AGENTS.md`), and in recent versions to support lifecycle hooks around
tool calls and an allow/deny mechanism for tools; Antigravity is reported to read workspace rules
and workflows from a `.agent/` directory and to keep terminal auto-run allow/deny lists in user
settings rather than in the repository. Neon, asked from inside an Antigravity session on
2026-11-23, reported: no repository-local pre-tool or post-tool hook surface; subagents it can
define and invoke, read-only ones included, each with a clean context; skills whose short
description is always visible and whose body loads on demand; and remote agents that run in an
ephemeral, non-root Linux VM with plugin credentials exchanged outside it. That is a model
describing its own host, so it counts as a lead too. The VM point, even once documented, weakens
no rule: local desktop use keeps the whole threat model, and the AMH does not relax a rule because
one host's containment would catch the same mistake.

## 2. The units: A0 to A5

Every unit:
- rereads `AGENTS.md`, `docs/STATE.md` and the `docs/RUNBOOK.md` playbooks named in its steps
  before editing;
- starts a `neon-review` beside its own writes and again before the commit;
- runs `bash .orch/neon.sh rules` before the commit whenever its diff touches a `RULE_FILES` path,
  and triages what comes back;
- runs the full `scripts/ladder.sh` on its final tree (A1: `--guards-only` suffices when it
  changes Markdown only), then `scripts/ladder.sh --guards-only` again after the commit, as
  `AGENTS.md` step 7 directs;
- marks its own heading here `: done <date>` (or `: dropped <date>` with the reason) in the same
  commit, and writes one ledger row in the live volume and one `docs/STATE.md` Changelog line.

### A0 — commit this plan: done 2026-11-23

- **Done:** committed with the owner's decisions; `docs/STATE.md` lists it under Live plans. The
  Owner-queue item asking for the `amh-v17.0.0` tag left the queue: `git ls-remote --tags origin
  amh-v17.0.0` answered with a tag on 2026-11-23.
- **Acceptance:** `scripts/ladder.sh --guards-only` green.

### A1 — establish what each host offers, and decide the adapter's shape

1. **Read how the existing adapters are wired** before looking outward: `scripts/guards/adapter-set.sh`,
   `harness/templates/configs/`, `scripts/amh-init.sh` (`KEEP_CONFIGS`, the seed ranking),
   `amh.conf` (`ADAPTER_FILES`, `RULE_FILES`), `harness/src/30-scaffolds.md`, `docs/RUNBOOK.md` →
   **Host rails and what they miss**, and the payload branches in
   `harness/templates/scripts/command-guard.sh` and `redact-tool-output.sh` (which tells Codex
   from Claude by `turn_id` and treats every other payload as Claude's).
2. **Research each host from its vendor's own documentation** (web search and fetch; the Gemini
   CLI's documentation and repository, Google's Antigravity documentation). For each of the
   Gemini CLI and Antigravity, fill one row per surface in an evidence table added to this plan
   as §3:
   1. instruction-file discovery (does it read `AGENTS.md` natively, by a setting, or not at all);
   2. repository-local settings path and format (the AMH installs repo-local files only, never
      under `$HOME`);
   3. static command, tool or file allow/deny rules, and their matching semantics;
   4. lifecycle hooks: event names, matcher syntax, stdin payload, stdout and exit-code contract,
      timeout, whether a failing hook fails open or closed, the working directory a hook runs in;
   5. sandboxing defaults, and any flag or mode that skips project settings or hooks;
   6. the names of its shell, file-read, file-write and subagent tools;
   7. skills, rules and workflows: the repository-local location, file format, how each is
      discovered and triggered, and what is always in context and what loads on demand;
   8. subagent definitions: whether one can be declared in the repository, and whether it can be
      held read-only, with a fresh context and without the author's rationale — what
      `docs/PROTOCOLS.md` asks of the rule reviewer that `.codex/agents/amh-rule-reviewer.toml`
      supplies for Codex;
   9. where the agent runs (local, remote VM) and what that does and does not contain.

   Each cell carries its evidence kind — `documented` (vendor docs, URL, retrieval date, the
   version they describe) or `unverified` — and nothing else counts. Nothing is `measured`: no
   host runs here.
3. **Decide the adapter's shape, per host**, with these rules and no owner question:
   - a host with documented repo-local settings gets adapter files under its own directory;
   - a host with documented pre-tool and post-tool hooks whose payload and response contract are
     documented gets the command guard and the output redactor wired to it (A2 then runs);
   - a host whose instruction-file discovery cannot be pointed at `AGENTS.md` by a documented
     repo-local setting gets a pointer stub seeded the way `CLAUDE.md` is; one that can, gets the
     setting and no stub;
   - a host with documented repo-local skills, rules or workflows gets the session-time entry
     points of decision 7 there, written as pointers (decision 6), each file saying it is prose
     and enforces nothing;
   - a host with a documented repo-local subagent definition that can be held read-only gets a
     rule-reviewer subagent equivalent to Codex's, and nothing more;
   - a host with none of these gets a prose-only entry in A4 and no files.
   Write the decision, the file list each later unit will create, and the exact keys, events and
   matchers that may appear in them (each traced to a §3 row) into this plan as §4. A3 and A2
   may ship nothing that §4 does not list.
4. **Record** the ledger row (the decision and why, and every `unverified` cell) and the Changelog
   line. Add no Owner-queue item unless a decision here truly cannot be taken from the evidence;
   then take the conservative branch (fewer files, prose-only) and queue the question.

**Acceptance:** §3 has a row per surface per host, each with an evidence kind and a source; §4
names each host's shape and the full list of files, keys and events; no `G*` id introduced; the
ladder is green.

### A2 — make the shipped rails tell the new host apart

Runs only if §4 wires a hook for at least one host; otherwise mark it `: dropped <date>` with §4's
reason, write the Changelog line, and stop.

1. Follow `docs/RUNBOOK.md` → **Change a shipped script** and **Add a guard**.
2. In `harness/templates/scripts/command-guard.sh` and `redact-tool-output.sh`, teach the payload
   parsers the new host's documented payload and response, and make host recognition explicit, so
   that an unrecognised payload stands down the way each script already documents, rather than
   being answered in Claude's shape (which the new host may reject, failing open). Claude's and
   Codex's behaviour must not change.
3. Fixtures in `harness/templates/scripts/test-ladder-guards.sh` (and the script self-tests): the
   new host's payload denied or redacted, Claude's and Codex's unchanged, an unrecognised payload
   answered as documented. Show each new fixture red without the behaviour and green with it.
4. Copy each changed script byte-for-byte to `scripts/`, run `scripts/build-manifest.sh`.

**Acceptance:** each new fixture seen red without its behaviour and green with it; copy and
manifest drift clean; the full ladder green; the rule review run and triaged.

### A3 — ship the adapter files and wire them into every surface that lists adapters

1. Create exactly the files §4 lists, settings, skills, rules, workflows and subagent
   definitions alike: the templates under `harness/templates/configs/`, this repository's own
   copies, and a seed pointer stub only if §4 calls for one. A skill or rule names the binding
   section it points to by its exact heading, so its `adapter-set.sh` wiring check can confirm
   that the heading resolves.
2. Update together every surface that enumerates adapters — `scripts/guards/adapter-set.sh` and its
   wiring checks, `scripts/amh-init.sh` (`KEEP_CONFIGS`, seed ranking), `amh.conf`
   (`ADAPTER_FILES`, `RULE_FILES`), `harness/templates/amh.conf.example`,
   `harness/templates/AMH-ADOPT.md`, `harness/PLACEHOLDERS.md` for any new placeholder,
   `scripts/session-start.sh`'s `adapters:` line if it lists files, `scripts/tests/local-guards.sh`,
   and `scripts/tests/test-init-e2e.sh`. Changes to a shipped script still go through the
   template and the byte copy.
3. Every new adapter file opens with the same "configured, never observed firing" honesty the
   Claude and Codex templates carry, names the vendor-doc version it was written against, and
   leaves out anything §4 does not list.
4. Fixtures: each new `adapter-set.sh` check and init e2e case fails when its target entry is
   removed or altered and passes on the clean tree; no `{{` left in an installed adapter file.

**Acceptance:** the fixtures above seen red and green; the full ladder green, including the init
e2e test; the rule review run and triaged.

### A4 — say what the new host's rails do and do not catch

1. `docs/RUNBOOK.md` → **Host rails and what they miss** (keep the heading): one entry per host
   from §4 naming each rail it has, each one it lacks and what then binds only as prose (no
   pre-tool hook → no command rail; no post-tool rewrite → no automatic redaction; no session hook
   → manual bootstrap; no file deny rules → `.git/hooks/**` and secret-file reads prose-only), the
   flags that skip project settings, and every `unverified` cell. Skills, rules, workflows and
   subagents are listed as procedure, never as rails; git's `pre-push` hook is named as the rail it
   is, with `--no-verify` as its bypass. Where the host runs agents in a remote VM, say what that
   contains and that no rule is relaxed for it.
2. The harness prose that describes adapters — `harness/src/30-scaffolds.md` and any other
   `harness/src` section A1 found — plus `README.md` and `docs/UPGRADING.md` where they list hosts.
   Edit `harness/templates/seed/AGENTS.md` only if an adopter-facing rule changes.
3. Run `scripts/build-dist.sh`.

**Acceptance:** dist, doc-navigation and path-reference rungs green; the full ladder green; the
rule review run and triaged.

### A5 — the release record for 17.1.0

1. Follow `docs/RUNBOOK.md`'s release playbook: `harness/VERSION` to `17.1.0` and every lockstep
   copy the version guard checks; a `harness/CHANGELOG.md` entry with an **Upgrading** section
   (the new adapter files are optional and copied by hand; the `RULE_FILES` and `ADAPTER_FILES`
   additions; every shipped script A2 changed); `scripts/build-dist.sh`; `scripts/build-manifest.sh`.
2. Owner queue: add one item for the tag (`amh-v17.1.0`, after the train merges, with its
   `git ls-remote` check) and one for a live probe on each host that got hooks or rules — run the
   host on a scratch repository and see a deny, a redaction and a session-start line actually fire
   — with what to record in the ledger afterwards.
3. Run `git fetch --tags` first so the version guard's tag comparison has something to read.

**Acceptance:** the version-lockstep rung green against the latest tag; dist and manifest drift
clean; the full ladder green; the rule review run and triaged; both Owner-queue items present
with checks.

## 3. Host evidence (A1 fills this in)

Not yet written.

## 4. The adapter's shape (A1 fills this in)

Not yet written.
