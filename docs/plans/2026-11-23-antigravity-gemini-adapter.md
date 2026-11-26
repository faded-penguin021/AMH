# PLAN — a third host adapter: the Gemini CLI and Antigravity

> **Status: adopted by the owner on 2026-11-23; every unit done, A5 last on 2026-11-24.** Units A1 to A5, run in order by the
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

### A1 — establish what each host offers, and decide the adapter's shape: done 2026-11-23

- **Done:** §3 and §4 written; both hosts get files, and A2 runs (**DD-111**, **DD-112**).


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

### A2 — make the shipped rails tell the new host apart: done 2026-11-23

- **Done:** both payload readers of the command guard, the redactor and `session-start.sh`'s two
  JSON envelopes, as "What A2 changes" in §4 lists; each behaviour fixture seen red without its
  behaviour (the previous commit's scripts, or a scratch mutation) and green with it (**DD-113**).

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

### A3 — ship the adapter files and wire them into every surface that lists adapters: done 2026-11-23

- **Done:** the pre-commit Neon review's findings (run `20261123T202449Z-neon-a3-precommit`) are
  fixed: the hook files go through the guard's `JSON_PATHS` tokenizer, which now tracks JSON's
  grammar and prints every container it opens, the pointer check refuses a leading `/` before the
  seed prefix, and the reviewer and pointer counts are per host, with a fixture per bypass seen
  red on the old guard (**DD-115**).
- **Earlier in the unit:** the twelve files §4 lists, each a template under `harness/templates/configs/` and this
  repository's copy, in every adapter list; `adapter-set.sh` gained one check per surface, the hook
  files' an exact key-path set after the rule review found the first version passable, and the
  init e2e test the install, placeholder and re-run cases, each seen red under its mutation. The
  shipped session-start and host-rails pointers name the seed's headings, because the seed has
  neither of this repository's, and this repository's host-rails pointers name `AGENTS.md` →
  **Working guidance**, since the conformance lab's pre-H2 arm has no runbook section (**DD-114**).

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

### A4 — say what the new host's rails do and do not catch: done 2026-11-23

- **Done:** one entry per host in `docs/RUNBOOK.md` → **Host rails and what they miss**, the
  harness prose of §3.7 and §3.8, README and UPGRADING; the seed constitution unchanged, since no
  adopter-facing rule changed (**DD-116**).

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

### A5 — the release record for 17.1.0: done 2026-11-24

- **Done:** drafted as MINOR 17.1.0 against `amh-v17.0.0`, with the changelog entry, its
  Upgrading section, the lockstep copies, dist and manifest; the tag and a live probe of each host
  are in the Owner queue with their checks (**DD-117**).

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

## 3. Host evidence (A1, 2026-11-23)

Every source below was retrieved on 2026-11-23. Nothing here is `measured`: neither host runs in
this container. `documented` means the named vendor page states it; `unverified` means no vendor
page read for this unit states it, whatever a lead or a model said.

**Gemini CLI sources** — the repository's own docs at tag `v0.70.0` (the latest release, published
2026-11-19; the same pages on `main` at `eecccfc`, 2026-11-20, were byte-identical), each at
`https://github.com/google-gemini/gemini-cli/blob/v0.70.0/docs/<path>`:
G-md `cli/gemini-md.md` · G-conf `reference/configuration.md` · G-trust `cli/trusted-folders.md` ·
G-hooks `hooks/index.md` · G-href `hooks/reference.md` · G-hbp `hooks/best-practices.md` ·
G-policy `reference/policy-engine.md` · G-shell `tools/shell.md` · G-tools `reference/tools.md` ·
G-sbx `cli/sandbox.md` · G-cli `cli/cli-reference.md` · G-skills `cli/skills.md` and
`cli/creating-skills.md` · G-agents `core/subagents.md` · G-remote `core/remote-agents.md`.

**Antigravity sources** — `https://antigravity.google/docs/<path>/`; the pages carry no version of
their own, and the changelog that day named Antigravity CLI **1.5.12** (2026-11-19) and the App
**2.34.0** as latest, so the evidence is taken to describe those: AG-rules `rules` · AG-hooks
`hooks` · AG-perm `permissions` · AG-sbx `sandbox` · AG-cli `cli/reference` and `cli/using` ·
AG-skills `skills` · AG-disc `customization-discovery` · AG-agents `subagents` · AG-remote
`remote-agents` · AG-wf `ide/workflows` · AG-set `settings` · AG-log `changelog`.

**Codex source** (one row of §4 depends on it) — C-skills
`https://developers.openai.com/codex/skills`: Codex scans `.agents/skills` in every directory from
its working directory up to the repository root.

### 3.1 Gemini CLI (v0.70.0)

| # | Surface | Finding | Evidence |
| - | ------- | ------- | -------- |
| 1 | Instruction files | Loads `GEMINI.md` by default — `~/.gemini/GEMINI.md`, then the workspace directories and their parents, then just-in-time in a directory a tool touches. `context.fileName` (string or array) names other files, the page's own example being `["AGENTS.md", "CONTEXT.md", "GEMINI.md"]`. So `AGENTS.md` is read **by a setting**, not natively. | documented, G-md, G-conf |
| 1a | — whether `context.fileName` also renames the global `~/.gemini/` file | not stated | unverified |
| 2 | Repo-local settings | `.gemini/settings.json` at the project root, JSON, layered over user settings and under the system override file. String values may reference `$VAR` / `${VAR}`. In an **untrusted** folder the CLI ignores `.gemini/settings.json` entirely (and `.env`, custom commands, MCP). | documented, G-conf, G-trust |
| 2a | — whether folder trust is on by default | the two pages disagree: G-trust says the feature is "disabled by default"; G-conf gives `security.folderTrust.enabled` the default `true` | unverified |
| 2b | — a comment key, or comments, in `settings.json` | not stated; a schema is published | unverified |
| 3 | Static allow/deny | The policy engine (TOML, `commandPrefix` / `commandRegex` / `argsPattern`, priority tiers) is the documented mechanism, but its **Workspace tier is "currently non-functional"** — `.gemini/policies/*.toml` in a repository has no effect. `tools.exclude` in `settings.json` is **deprecated** in favour of policy rules; it prefix-matches `run_shell_command(<cmd>)` per chained segment, and the page shows it only beside `tools.core`, which, once set, allowlists *every* built-in tool. | documented, G-policy, G-shell, G-conf |
| 3a | — `tools.exclude` without `tools.core` | not stated | unverified |
| 4 | Hooks: events and matchers | Under `hooks` in `settings.json`: `SessionStart`, `SessionEnd`, `BeforeAgent`, `AfterAgent`, `BeforeModel`, `AfterModel`, `BeforeToolSelection`, `BeforeTool`, `AfterTool`, `PreCompress`, `Notification`. A group is `{matcher, sequential, hooks:[{type:"command", command, name, timeout, description}]}`. Tool-event matchers are regular expressions on the tool name; lifecycle matchers are exact strings; `"*"` or `""` matches all. `SessionStart` sources: `startup`, `resume`, `clear`. | documented, G-hooks, G-href |
| 4a | Hooks: payload | stdin JSON with `session_id`, `transcript_path`, `cwd`, `hook_event_name`, `timestamp`; `BeforeTool` adds `tool_name`, `tool_input`; `AfterTool` adds `tool_response` (`llmContent`, `returnDisplay`, optional `error`). The shell tool's argument is `tool_input.command`. | documented, G-href, G-tools |
| 4b | Hooks: response | Exit 0: stdout parsed as JSON. Exit 2: the action is blocked and stderr is the reason — for `BeforeTool` the call does not run and the turn continues; for `AfterTool` the result is hidden and stderr replaces it. `BeforeTool` JSON `decision: "deny"` (alias `"block"`) + `reason` blocks; `AfterTool` `decision: "deny"` + `reason` **replaces the tool result sent to the model**. `SessionStart` reads `hookSpecificOutput.additionalContext` (injected as the first turn, or prepended to the prompt headless) and `systemMessage`; it can never block. Non-JSON stdout "defaults to Allow" and is shown as a `systemMessage`. | documented, G-hooks, G-href |
| 4c | Hooks: failure, timeout, environment | Any exit other than 0 or 2 is a warning and the call **proceeds with its original parameters: fail-open**. Timeout in milliseconds, default 60000. Hooks get a sanitised environment with `GEMINI_PROJECT_DIR` (project root), `GEMINI_CWD`, `GEMINI_SESSION_ID`, and `CLAUDE_PROJECT_DIR` as an alias; the page's own example command is `"$GEMINI_PROJECT_DIR/.gemini/hooks/security.sh"`. A project hook is fingerprinted by `name` + `command`: a new or changed one is warned about before it runs. `hooksConfig.enabled: false` or `/hooks disable-all` turns every hook off. | documented, G-hooks, G-hbp, G-conf |
| 4d | — what a timed-out hook does to the call; the process's working directory; which shell runs `command` on Windows; whether `$GEMINI_PROJECT_DIR` is expanded by settings interpolation at load time or by the shell at run time; whether hooks fire for a subagent's tool calls | not stated | unverified |
| 5 | Sandbox and skipping modes | Sandbox **off** by default (`--sandbox` default false); providers are Seatbelt on macOS, Docker/Podman, gVisor, LXC, `windows-native`, set by `tools.sandbox` or `GEMINI_SANDBOX`. An untrusted folder skips project settings and so every project hook; `--skip-trust` / `GEMINI_CLI_TRUST_WORKSPACE=true` trust it for one session; `--approval-mode=yolo` auto-approves. | documented, G-sbx, G-cli, G-trust |
| 5a | — whether `yolo` or headless `-p` mode still runs hooks | not stated | unverified |
| 6 | Tool names | Shell `run_shell_command` (`bash -c` on POSIX, `powershell.exe -NoProfile -Command` on Windows); read `read_file`, `read_many_files`; write `write_file`, `replace`; search `glob`, `grep_search`, `list_directory`; skills `activate_skill`; subagents invoked as a tool named after the agent, policy-matched through `invoke_agent`. | documented, G-tools, G-shell, G-policy |
| 7 | Skills, rules, workflows | Workspace skills at `.gemini/skills/<name>/SKILL.md` or the `.agents/skills/` alias (the alias wins on a name clash); YAML frontmatter `name` and `description`. Name and description are in the system prompt from session start; the body loads when the model calls `activate_skill`, after a user consent prompt. No separate rules or workflows surface; custom commands (`.gemini/commands/*.toml`) are user-invoked prompts. | documented, G-skills |
| 8 | Subagents | Repository-declared at `.gemini/agents/<name>.md`: frontmatter `name`, `description`, `kind: local`, `tools` (omitted = inherit all), `model`, `temperature`, `max_turns`, `timeout_mins`; the body is the system prompt. Each runs in "its own isolated context loop" with only the tools listed, and a subagent cannot call another. A `tools` list without the shell and write tools holds it read-only. Enabled by `experimental.enableAgents` (default `true`). | documented, G-agents, G-conf |
| 8a | — that the subagent starts with none of the parent's history, and receives only the prompt the parent passes | "isolated context loop" and "independent history" are stated; the exact contents of its first turn are not | unverified |
| 9 | Where it runs | A local process on the user's machine, as the user. "Remote subagents" (A2A) are remote agent services it calls, not a place the CLI runs. | documented, G-hooks, G-remote |

### 3.2 Antigravity (CLI 1.5.12, App 2.34.0)

| # | Surface | Finding | Evidence |
| - | ------- | ------- | -------- |
| 1 | Instruction files | Reads `AGENTS.md` **natively** (also `GEMINI.md`, `.agents/AGENTS.md`, `.agents/rules/*.md`) in the workspace folder and each parent up to the repository root, always on; not below the workspace folder. Limits: a rule file over **24,000 bytes is truncated**, and always-on rules share a 20,000-token budget past which the largest are demoted to a path-and-description pointer. | documented, AG-rules, AG-disc |
| 2 | Repo-local settings | The workspace customisation directory is `.agents/` (`.agent/`, `_agents/`, `_agent/` still recognised): `rules/`, `skills/`, `agents/`, `hooks.json`, `mcp_config.json`. There is **no repo-local settings file**: the CLI's settings are `~/.gemini/antigravity-cli/settings.json`, and the App's project settings are set in its UI. | documented, AG-disc, AG-cli, AG-set |
| 2a | — where the App stores a project's settings | not stated | unverified |
| 3 | Static allow/deny | `permissions.allow` / `ask` / `deny` lists of `action(target)` (`command(prefix)` word-by-word or `command(regex:…)`, `read_file(path)`, `write_file(path)`, …), Deny > Ask > Allow — **in user settings only**; nothing repo-local. | documented, AG-perm |
| 4 | Hooks: events and matchers | `.agents/hooks.json` at the workspace root, for the CLI, App and IDE alike. Top-level keys are hook names, each with optional `enabled` and event arrays: `SessionStart`, `PreToolUse`, `PostToolUse`, `PreInvocation`, `PostInvocation`, `Stop`. `PreToolUse`/`PostToolUse` take `{matcher, hooks:[{type, command, timeout}]}`, matcher a regular expression on the tool name (`"run_command"` matches exactly that tool); the other events take a handler list directly and ignore matchers. `timeout` in **seconds**, default 30. | documented, AG-hooks |
| 4a | Hooks: payload | stdin JSON, camelCase: `conversationId`, `workspacePaths`, `transcriptPath`, `artifactDirectoryPath`, `modelName`, `lastUserInput`; CLI 1.5.4 added `hookEventName`, `cwd`, `toolCall.id`. `PreToolUse` adds `toolCall.name` and `toolCall.args` — for `run_command`, `CommandLine` and `Cwd` — and `stepIdx`. `PostToolUse` adds `toolCall`, `stepIdx` and `error`, and **no tool output**. | documented, AG-hooks, AG-log |
| 4b | Hooks: response | stdout JSON. `PreToolUse`: `decision` (required) — `allow`, `auto_approve`, `deny` ("hard blocks execution immediately"), `ask`, `force_ask`, `deny_unless_prior_grant` — with optional `reason` (shown to the agent or the user), `overwrite`, `permissionOverrides`. `PostToolUse` returns `{}` only, so it **cannot rewrite or hide a result**. `SessionStart` returns `injectSteps`, e.g. `[{"systemMessage":{"systemMessage":"…"}}]`. | documented, AG-hooks |
| 4c | — exit-code semantics; what a non-zero exit, a timeout or malformed stdout does to the call; the working directory of a workspace hook (plugin hooks run in the plugin's folder); which shell runs `command` on Windows; any trust gate on workspace hooks | not stated. The App 2.12.0 changelog says a failing hook "no longer ends the session; it is now reported as an error and the conversation continues", which does not say whether the tool call ran | unverified |
| 4d | Load-time rejection | A hook configuration "that could never run" is rejected at load time with an error instead of being ignored (App changelog). | documented, AG-log |
| 5 | Sandbox and skipping modes | A terminal sandbox, **on by default** (Linux namespaces, macOS Seatbelt, a Windows AppContainer on 11 24H2+), blocks `~/.ssh` and `.env` and cuts the network to approved domains; it is a user or App-project setting. `--dangerously-skip-permissions` auto-approves every request; `--mode` sets the execution mode; a hook entry with `enabled: false` is off. | documented, AG-sbx, AG-cli, AG-hooks |
| 5a | — a flag or mode that skips workspace hooks or rules | none found | unverified |
| 6 | Tool names | Shell `run_command` ("Propose a Bash command"); read `view_file`, `list_dir`, `find_by_name`, `grep_search`; write `write_to_file`, `replace_file_content`, `multi_replace_file_content`; subagents `invoke_subagent`, `define_subagent`. | documented, AG-hooks |
| 6a | — the shell `run_command` uses on Windows | AG-perm names PowerShell and Command Prompt for command matching on Windows | unverified |
| 7 | Skills, rules, workflows | Skills: `.agents/skills/<name>/SKILL.md` (the only workspace path; legacy `.agent/skills`), frontmatter `description` required and `name` optional; names and descriptions visible every turn, body read on demand. Rules: `.agents/rules/*.md` (flat), frontmatter `trigger` required — `always_on`, `model_decision` (path and `description` injected up front, body read on demand), `glob`, `manual` — and a missing or unknown trigger **silently discards** the rule. Workflows: **deprecated**, to be migrated to skills. | documented, AG-skills, AG-rules, AG-wf |
| 8 | Subagents | Repository-declared at `.agents/agents/<name>.md` (or `<name>/agent.md`): frontmatter `name`, `description`, `tools` (default `[]`), `mainAgent`, `subagent`, `model`, `commandExecutionPolicy` (`off`, `auto`, `eager`, `sandbox`), `mcpServers`, `skills`. A subagent "does not inherit the parent's existing conversation history … starting with a clean slate", and inherits the parent's command prefixes, file scopes and sandbox. A `tools` list without the shell and write tools holds it read-only. Known issue: a misspelled tool name in `tools` may hang it. | documented, AG-agents |
| 9 | Where it runs | Locally (App, IDE, CLI) with the user's privileges, inside the terminal sandbox when on; or as **Remote Agents** in "an isolated, Google-managed remote environment" working on attached GitHub repositories, Drive files and uploads, with plugin OAuth tokens "securely injected" on its requests. | documented, AG-remote, AG-sbx |
| 9a | — that the remote environment is an ephemeral, non-root Linux VM; whether it loads the repository's `.agents/` customisations and runs its hooks | not stated (the plan's §1 lead) | unverified |

## 4. The adapter's shape (A1, 2026-11-23)

The A1 rules applied host by host, with three choices the rules leave open and their reasons.
Any file, key, event or matcher not listed here is out of scope for A2 and A3.

**Choices.**

1. **A SessionStart hook on both hosts, with a JSON envelope (A2).** Both hosts document a session
   hook whose output must be JSON (§3.1 4b, §3.2 4b), and `scripts/session-start.sh` prints plain
   text. Without the hook, the pre-push rail goes uninstalled and the command guard's advisory
   state is never reset unless the agent runs the bootstrap by hand. Redirecting the banner to
   stderr would throw away the warnings the session needs to see. So A2 gives
   `session-start.sh` an explicit, vendor-neutral output-shape option. It captures the script's
   whole stdout and escapes it as a JSON string without `python3`. A bare run stays plain text.
   Neon (`-e high`) recommended this too.
2. **Entry-point pointers per host, never in `.agents/skills/`.** Codex scans `.agents/skills/` (C-skills),
   so a shared set there would ship AMH skills to Codex, which decision 7 excludes; Gemini CLI also
   reads that alias. So the Gemini CLI gets skills under `.gemini/skills/`, which neither Codex nor
   Antigravity reads, and Antigravity gets `model_decision` rules under `.agents/rules/` — the
   same progressive disclosure as a skill (§3.2 7), on a surface only Antigravity reads.
   Workflows are deprecated and unused. Neon (`-e high`) preferred one shared `.agents/skills/`
   set for having half the files, and it was overruled on decision 7.
3. **No static deny rules and no sandbox setting, on either host.** The Gemini CLI's repo-local
   options are a deprecated key whose semantics without `tools.core` are unverified, and a
   policy tier documented as non-functional (§3.1 3). `tools.sandbox` needs a container runtime or
   Seatbelt and would break a session without one. Antigravity has no repo-local permission or
   sandbox file at all (§3.2 2, 3).

**Gemini CLI — adapter files under `.gemini/`, three rails wired (A2 runs), skills, a reviewer
subagent, no stub.**

- `.gemini/settings.json` (template `harness/templates/configs/gemini-settings.json`). Keys, and
  nothing else:
  - `context.fileName`: `["AGENTS.md", "GEMINI.md"]` — §3.1 1; `GEMINI.md` is kept so the default
    file still loads, given 1a.
  - `hooks.SessionStart`: one group, `matcher` `"*"`, one hook named `amh-session-start`,
    `type` `"command"`, command `bash "$GEMINI_PROJECT_DIR/scripts/session-start.sh"` plus A2's
    output-shape option for `hookSpecificOutput.additionalContext`, `timeout` `30000` —
    §3.1 4, 4b, 4c.
  - `hooks.BeforeTool`: one group, `matcher` `"^run_shell_command$"`, one hook named
    `amh-command-guard`, `type` `"command"`, command `bash "$GEMINI_PROJECT_DIR/scripts/command-guard.sh"`, `timeout`
    `10000` — §3.1 4, 4a, 4b, 6.
  - `hooks.AfterTool`: one group, `matcher` `"*"`, one hook named `amh-redact-tool-output`,
    `type` `"command"`, command `bash "$GEMINI_PROJECT_DIR/scripts/redact-tool-output.sh"`, `timeout` `40000` —
    §3.1 4, 4a, 4b.
  - `description` on each of the three hooks carries the "configured, never observed firing" text
    and the docs version (§3.1 4). There is no file-level comment, because a comment key is
    unverified (2b). The hook `name` values above are fixed because the host fingerprints
    `name` + `command` (4c).
- `.gemini/skills/amh-session-start/SKILL.md`, `.gemini/skills/amh-acceptance-ladder/SKILL.md`,
  `.gemini/skills/amh-rule-review/SKILL.md`, `.gemini/skills/amh-host-rails/SKILL.md`. Frontmatter
  `name` and `description` only — §3.1 7. Each body names one binding section by its exact heading
  (`AGENTS.md` → **Universal session sequence**, `docs/PROTOCOLS.md` → **Acceptance ladder**,
  `docs/PROTOCOLS.md` → **Rule-review protocol (MANDATORY for binding-rule and guard diffs)**, `docs/RUNBOOK.md` → **Host rails and what they
  miss**) and says it is prose that enforces nothing. It also says it is configured and has never been
  observed firing, and names the docs version, as every Markdown adapter file below does.
- `.gemini/agents/amh-rule-reviewer.md`. Frontmatter `name: amh-rule-reviewer`, `description`,
  `kind: local`, `tools: [read_file, read_many_files, grep_search, glob, list_directory]`. The
  list has no shell and no write tool, and leaving `tools` out would inherit every tool. The body
  is the instructions `.codex/agents/amh-rule-reviewer.toml` carries — §3.1 8, 6.
- No pointer stub: `context.fileName` points the host at `AGENTS.md` (§3.1 1). In an untrusted
  folder the settings file, and with it every hook and the `AGENTS.md` setting, is ignored
  (§3.1 2). That gap is A4's to state.

**Antigravity — hooks, rules and a reviewer subagent under `.agents/`, two rails wired (A2 runs),
no settings file, no redactor, no stub.**

- `.agents/hooks.json` (template `harness/templates/configs/antigravity-hooks.json`). Two named
  entries, and nothing else:
  - `amh-session-start`: `SessionStart`, one handler, `type` `"command"`, command
    `root=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0; exec bash "$root/scripts/session-start.sh"`
    plus A2's output-shape option for `injectSteps` / `systemMessage`, `timeout` `30` — §3.2 4, 4b.
  - `amh-command-guard`: `PreToolUse`, `matcher` `"run_command"`, one handler, `type` `"command"`, command
    `root=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0; exec bash "$root/scripts/command-guard.sh"`,
    `timeout` `10` — §3.2 4, 4a, 4b, 6. The command is the Codex adapter's root lookup, because
    no project-directory variable and no hook working directory are documented (4c).
  - No `PostToolUse` entry: its response cannot redact (§3.2 4b). No `$comment` or other unlisted
    key, since Antigravity rejects at load time a hook configuration that could never run
    (§3.2 4d). The honesty text for this one file therefore lives in A4's entry, a departure from
    decision 4 recorded in **DD-112**.
- `.agents/rules/amh-session-start.md`, `.agents/rules/amh-acceptance-ladder.md`,
  `.agents/rules/amh-rule-review.md`, `.agents/rules/amh-host-rails.md`. Frontmatter
  `trigger: model_decision` and `description`, nothing else — §3.2 7. The bodies are the same
  pointers as the Gemini CLI skills.
- `.agents/agents/amh-rule-reviewer.md`. Frontmatter `name: amh-rule-reviewer`, `description`,
  `tools: [view_file, grep_search, list_dir, find_by_name]`, `subagent: true`,
  `mainAgent: false`, `commandExecutionPolicy: off`. The tool names are copied exactly, given the
  documented hang on a misspelled one. The body is the same instructions as the Gemini CLI
  reviewer — §3.2 8, 6.
- No pointer stub and no setting: `AGENTS.md` is read natively (§3.2 1). Its 24,000-byte
  truncation is A4's to state.

**What A2 changes** (each shipped script through its template, byte copy and manifest):

- `command-guard.sh`:
  - Recognise the Gemini CLI's `BeforeTool` payload (`hook_event_name` `BeforeTool`, `tool_name`
    `run_shell_command`, `tool_input.command`) and refuse it by exit 2 plus stderr (§3.1 4b).
  - Recognise Antigravity's `PreToolUse` payload (`toolCall.name` `run_command`,
    `toolCall.args.CommandLine`) and answer on stdout with `{"decision":"deny","reason":…}` or
    `{"decision":"allow"}`, exiting 0 either way, since the documented examples answer in JSON and
    no page gives exit 2 a meaning there (§3.2 4b; the exit code's meaning is unverified, 4c).
  - Route the Gemini CLI's command to the PowerShell reader only where the host is Windows
    (§3.1 6; Antigravity's Windows shell is unverified, §3.2 6a).
  - Make host recognition explicit, so an unrecognised payload stands down as documented.
- `redact-tool-output.sh`: recognise the Gemini CLI's `AfterTool` payload and, only when a leaf
  was redacted, answer `{"decision":"deny","reason":<filtered result>}` (§3.1 4b). Same explicit
  host recognition as the guard.
- `session-start.sh`: the output-shape option of choice 1, in two shapes —
  `{"hookSpecificOutput":{"additionalContext":…}}` and
  `{"injectSteps":[{"systemMessage":{"systemMessage":…}}]}`. It drains a non-terminal stdin, as
  `--pre-task` does.
- Not wired on either host: the `--pre-task` spawn speed bump. The A1 rules do not call for it, and
  decision 7's budget keeps it out.

**What A3 adds to the surfaces that list adapters:** the four installed paths
`.gemini/settings.json`, `.gemini/agents/amh-rule-reviewer.md`, `.agents/hooks.json` and
`.agents/agents/amh-rule-reviewer.md`, plus the eight skill and rule files, each with its template
under `harness/templates/configs/` at the same relative path. They go into `ADAPTERS`,
`KEEP_CONFIGS`, `ADAPTER_FILES` and both `RULE_FILES`, each as an explicit path, because
`adapter-set.sh` matches each installed path exactly. The checks in `adapter-set.sh` are limited
to one wiring check per new surface. That means the Gemini CLI's three hook groups and the
`context.fileName` value, Antigravity's two hook entries, each reviewer's tool list, and each
pointer's heading resolving.
