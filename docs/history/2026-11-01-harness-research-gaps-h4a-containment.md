# H4a — the containment the host sandboxes can provide

> Companion to the research-gaps plan (its §5, H4a), written 2026-11-13 at `cd36199`. Docs-only
> design: it changes no adapter, guard or rule. H4b, a separate unit needing its own approval,
> wires what this file specifies. Provisional like its plan: it retires with it, and no ledger
> row cites this path. §14 records the review it owed and how each finding was applied.

Every documentation fact here was **reported** by the host vendor's pages, fetched on
2026-11-13 (§12), and is not a probe of any AMH runtime. Every **observed** fact is a read-only
probe run on the author's host, listed in §12 with its output. A cell that is neither says
**unverified**. No sandboxed session was started, and no containment claim is made here: every
claim waits for H4b's probes.

## 1. The owner's decisions, taken when the unit started (2026-11-13)

The owner approved H4a and answered §1 item 5 of the plan before the research started:

1. **Native Windows (Claude Code): no sandbox, and say so.** On native Windows, Claude Code keeps
   the command guard and prose as its only layers, and the README and the adapters say so
   plainly. This applies to native Windows only; macOS, Linux and WSL2 get a sandbox design.
2. **Scope: the project file.** The sandbox H4b ships lives in the adapter's
   `.claude/settings.json` (template `harness/templates/configs/claude-settings.json`); for
   Codex, the adapter is `.codex/config.toml` (template
   `harness/templates/configs/codex-config.toml`).
3. **Default: on for fresh installs.** Existing adopters keep their adapters (installed under
   `keep`), and the release's upgrading note tells the adopter's agent to ask the user whether
   they want the sandbox, not to install it unasked.
4. **Dependencies: optional, including the seccomp filter.** `bubblewrap` and `socat` (Claude
   Code on Linux and WSL2), `bubblewrap` (Codex on Linux and WSL2) and the seccomp filter
   (Claude Code; installed with the npm package `@anthropic-ai/sandbox-runtime` when missing)
   are approved as optional host tools. AMH's own scripts still need only bash, git and
   coreutils; a missing tool is documented, never fatal to AMH.
5. **Probes: read-only on this host**, and the review: one gpt-6-astra pass at `-e high`.

**Reading applied to Codex.** The Windows choice was offered for Claude Code. Codex already
sandboxes by default on every platform it supports, native Windows included (§2.2), so this
design leaves Codex's defaults alone: it sets no Codex sandbox key at all (§11), which also
satisfies "on for fresh installs" there. Disabling a host's default sandbox is not what "no
sandbox, and say so" asked for. The owner can overturn this reading at H4b's approval.

## 2. The documented-versus-observed matrix

Source tags: **CS** Claude Code sandboxing page, by section; **CR** Claude Code settings
reference, by key; **CSet** Claude Code settings page, by section; **XS** Codex sandboxing page,
by section; **XR** Codex configuration reference, by key; **P1–P6** probes in §12. The columns
are separate facts, never alternative states: whether the platform supports a sandbox
(availability), what AMH's adapter asks for (requested), what a session would actually run
under (effective), and what anyone has seen enforced (observed).

**Effective state is unverified in every cell, today as under H4b.** The adapter requesting
nothing does not make a session unsandboxed: user, local, `--settings` and managed settings can
all enable the sandbox (CSet Settings precedence), and no probe read a session's resolved
settings.

### 2.1 Claude Code

Client and version for every row: the Claude Code CLI on the user's own machine; the pages carry
no version stamp, and the build installed here is 2.1.323 (P3). The sandbox applies to Bash,
PowerShell and Monitor tool commands and their children (CS intro); cloud sessions are covered by
another page (CS intro, note); background sessions are sandboxed when their own settings enable
it, and subagents share the parent's configuration (CS Limitations, Scope). The desktop app and
IDE extensions are **unverified**: neither page read names them.

Requested, every platform: **today** no `sandbox` key in either adapter copy (P6); **under
H4b** the project-file block of §11.

| Platform | Availability (documented) | Mechanism, dependencies | When it cannot start | Observed |
|---|---|---|---|---|
| macOS | Supported (CS intro) | Seatbelt, built in (CS Get started; OS-level enforcement) | Runs commands unsandboxed unless `failIfUnavailable` is `true` — the general rule, stated for any platform or dependency failure (CS Get started, warning; CR `sandbox.failIfUnavailable`) | unverified: no macOS host |
| Linux | Supported (CS intro) | bubblewrap and socat required; seccomp filter optional, adds Unix-socket blocking (CS Set up Linux and WSL2) | Unsandboxed unless `failIfUnavailable` (CS Get started, warning) | P1–P4: a Docker container on a WSL2 kernel, aarch64, Claude Code 2.1.323, with no `bwrap` or `socat` on `PATH`, so by the documented rule the sandbox could not start here |
| Linux in an unprivileged container | Supported with a caveat: bwrap cannot mount a fresh `/proc`, and `enableWeakerNestedSandbox` is for use "only ... when the outer container already provides the isolation boundary" (CS Troubleshooting, Bubblewrap fails to start inside a container; Security limitations) | as the Linux row, plus that setting (same sections) | Unsandboxed unless `failIfUnavailable` (CS Get started, warning) | P2 shows a Docker container; whether it is unprivileged is **unverified** |
| WSL2 | Supported, by bubblewrap as on Linux (CS OS-level enforcement) | bubblewrap and socat required, seccomp filter optional (CS Set up Linux and WSL2); a Windows-binary launch goes over a Unix socket only the seccomp filter blocks (CS WSL2 notes) | Unsandboxed unless `failIfUnavailable` (CS Get started, warning) | unverified: P2 shows no WSL interop, no `/mnt` drives and no `cmd.exe` here, so this host is not a WSL2 distribution |
| WSL1 | **Not supported**: "Sandboxing requires WSL2" (CS WSL2 notes) | — | Unsandboxed, by the general rule (CS Get started, warning); the WSL1 behaviour itself is unverified | unverified |
| Native Windows | **Not supported**: "On native Windows, Claude Code runs commands unsandboxed" (CS intro) | — | Unsandboxed; with `failIfUnavailable` set, Claude Code exits at startup (CS Enforce sandboxing with managed settings) | unverified: no Windows host |

Under H4b the native-Windows row stays unsandboxed **by the owner's choice** (§1 item 1).

Approval and escalation, all platforms: an unsandboxed retry with `dangerouslyDisableSandbox`
is allowed unless `allowUnsandboxedCommands` is `false` (default `true`; CR
`sandbox.allowUnsandboxedCommands`); who approves a retry depends on the permission mode —
`bypassPermissions` runs it with no prompt, `dontAsk` denies it (CS The unsandboxed retry escape
hatch). Sandboxed commands run without a prompt by default (`autoAllowBashIfSandboxed`, default
`true`; CR).

### 2.2 Codex

Client and version: the pages say local chats in the ChatGPT desktop app, the Codex CLI and the
IDE extension run commands inside the sandbox (XS intro); the pages carry no version stamp, and
the CLI installed here is codex-cli 0.159.0 (P3). The desktop app and IDE extension rows are
**unverified** beyond that sentence.

Requested, every platform: **today and under H4b**, no Codex sandbox key; AMH's adapter wires
three hooks only (P6). The documented default applies unless other configuration changes it:
"The default permissions mode applies sandboxing automatically", with `workspace-write` "the
default low-friction mode for local work" (XS Getting started; Configure defaults).

| Platform | Availability (documented) | Mechanism, dependencies | When it cannot start | Observed |
|---|---|---|---|---|
| macOS | Supported: "platform-native enforcement on each OS ... macOS, Linux, WSL2, and native Windows" (XS What the sandbox does) | Seatbelt, built in (XS Prerequisites) | unverified | unverified |
| Linux | Supported (XS What the sandbox does) | bubblewrap, installed by the user; the first `bwrap` on `PATH`, else a bundled helper that needs unprivileged user-namespace creation (XS Prerequisites) | A startup **warning** when `bwrap` is missing or the helper cannot create the namespace (XS Prerequisites); whether commands then run unsandboxed, are refused or fail is unverified | P3–P5: codex-cli 0.159.0, no `bwrap` on `PATH`, `max_user_namespaces` 79959; whether the bundled helper can create a namespace here was not attempted |
| WSL2 | Supported: "the Linux sandbox implementation when you run in WSL2" (XS Prerequisites) | bubblewrap, as on Linux (XS Prerequisites) | the Linux warning (XS Prerequisites); run behaviour unverified | unverified: not a WSL2 distribution (P2) |
| WSL1 | unverified: neither page read names it | unverified | unverified | unverified |
| Native Windows | Supported: "the native Windows sandbox when you run in PowerShell" (XS Prerequisites) | Codex's own: `windows.sandbox` = `mxc`, `elevated` or `unelevated` (XR `windows.sandbox`); with no mode selected and both legacy implementations allowed, Codex prefers `elevated` (XR managed requirement `windows.allowed_sandbox_implementations`) | Explicit `mxc` fails when MXC is unavailable or prohibited; `features.prefer_mxc`, off by default in the CLI, falls back to the legacy sandbox (XR `windows.sandbox`, `features.prefer_mxc`); the managed requirement `windows.require_mxc` fails configuration instead of falling back (XR `windows.require_mxc`) | unverified |

Approval and escalation: approval policies `on-request` and `never` (and a `granular` table);
`untrusted` is retired as a selectable policy and survives only as a project `trust_level`
(XS Configure defaults; XR `approval_policy`). Rules can allow, prompt or forbid command
prefixes outside the sandbox (XS Configure defaults); AMH's `.codex/rules/amh.rules` holds
only `forbidden` rules (P6), so it opens nothing.

**AMH's Codex layers can be absent.** Project-scoped `.codex/` config, hooks and rules load only
for a trusted project; an untrusted one skips them all (XR `projects.<path>.trust_level`;
`config.toml` section). AMH's hooks and rules then do not run; the user's own configuration,
launch options and managed requirements still decide the sandbox.

## 3. Native Windows

The owner's selection (§1 item 1) stands as the design: Claude Code on native Windows runs every
shell command unsandboxed, and the only layers there are the command guard, its PowerShell
reader (**DD-039**) and the constitution's prose. Draft wording for H4b's README and adapter
comment, beside the existing "they are not a security sandbox" sentence:

> On native Windows, Claude Code runs shell commands with no sandbox, so the command guard and
> these rules are the only layers there. The guard's machine mode is a rail, not containment. To
> get the sandbox on a Windows machine, run Claude Code inside WSL2, with the seccomp filter
> installed if Windows programs must not be launchable from a sandboxed command.

Consequences the design accepts:

- **`failIfUnavailable` stays unset (false) in the shipped project file.** With it set, Claude
  Code exits at startup on native Windows (CS Enforce sandboxing with managed settings), which
  would turn the owner's "no sandbox, say so" into "AMH does not start". The cost is that on
  Linux or WSL2 with bwrap or socat missing, commands also fall back to unsandboxed, silently.
  §11 proposes how H4b says so.
- **The options not selected** — requiring WSL2, a container or VM boundary, refusing to start —
  stay available to an adopter who sets them in their own user or managed settings, and the
  README may name them; AMH ships none of them.

## 4. The WSL2 interop boundary

On WSL2 a launch of `cmd.exe`, `powershell.exe` or anything under `/mnt/c/` is handed to the
Windows host over a Unix socket; only the optional seccomp filter blocks that socket, and
`allowAllUnixSockets: true` reopens it (CS WSL2 notes; CR `sandbox.network.allowAllUnixSockets`).
On Linux and WSL2, `allowUnixSockets` path lists are ignored (CR
`sandbox.network.allowUnixSockets`). A Windows program launched that way runs as a Windows
process with the user's Windows rights, outside bubblewrap — the shape of **DD-038**'s
`cmd /c rmdir`. So the WSL2 cell carries two separate claims: Linux processes contained (if
probed), and Windows-binary launches blocked **only where the seccomp filter is installed** (if
probed). Without the filter, the second claim is not made.

## 5. Settings scope and precedence, per key

Claude Code scalar precedence, highest first: managed, `--settings`, project local
(`.claude/settings.local.json`), shared project (`.claude/settings.json`), user; list keys
merge across scopes (CSet Settings precedence; Lists merge instead of overriding). **A shipped
project file therefore sets defaults, not locks:** a user's `.claude/settings.local.json`
outranks it for every scalar, and `/sandbox` writes its mode there (CS Get started, step 3).

Permission rules feed the sandbox too: `Edit` allow rules grant sandbox write access like
`allowWrite`, `Read` and `Edit` deny rules block access, `WebFetch(domain:...)` rules control
domains, and "paths and domains from both sandbox settings and permission rules are merged into
the final sandbox configuration" (CS Permission rules). **AMH's adapter already carries such
rules**: 35 `Read` deny rules over credential and environment paths (SSH private keys, `.env` files,
`~/.git-credentials`, `~/.netrc`, `~/.npmrc`, `~/.config/gh/hosts.yml`, `~/.docker/config.json`,
`~/.kube/config`, cloud credentials, `/proc/*/environ`) and an `Edit` deny on
`//**/.git/hooks/**` (P6). With the sandbox on, these become restrictions on sandboxed commands
as well — read-confidentiality for those paths, and consequences §7 names. How each glob
translates into the sandbox's own path rules is unverified.

| Key | Default | Project file can… | What outranks or locks it | Version |
|---|---|---|---|---|
| `sandbox.enabled` | `false` | set `true` or `false` | local file; `--settings`; managed (a managed Boolean wins); under an admin-required sandbox a repo `false` is ignored when the user sets `true` | — (CR; CS Repository settings under an admin-required sandbox) |
| `sandbox.failIfUnavailable` | `false` | set it | as `enabled` | — (CR) |
| `sandbox.allowUnsandboxedCommands` | `true` | set `false` | a `false` in user settings, `--settings` or managed holds against a project's `true`; a local-file `true` outranks a project `false` by scalar precedence; a `false` from managed or `--settings` makes the sandbox admin-required | user-`false`-holds needs 2.1.285 (CR; CS Turn off the retry) |
| `sandbox.autoAllowBashIfSandboxed` | `true` | set it; still honoured under an admin-required sandbox | managed, to stop a repo changing it | — (CR; CS Repository settings…) |
| `sandbox.excludedCommands` | unset | add entries | lists merge; ignored from repo files under an admin-required sandbox | admin-required behaviour 2.1.285 (CR) |
| `sandbox.filesystem.denyWrite` / `denyRead` | none | add entries | list entries merge, and no scope removes another's entry — but a **narrower `allowRead` from any scope reopens part of a `denyRead` region** (CS Configure sandboxing, overlap table), so keeping an entry is not keeping its effect; only the locks in CS "Locks that apply without an admin-required sandbox" (a `denyRead`, `Read(...)` deny or `credentials.files` entry set in managed or `--settings`) and managed `allowManagedReadPathsOnly` stop a repository's `allowRead` from doing so | locks 2.1.285 (CS Locks…; Keep developers from widening the policy) |
| `sandbox.filesystem.allowWrite` / `allowRead` | defaults in §7 | add entries | merge; ignored from repo files under an admin-required sandbox (write access) or under the locks above (read) | — (CS Repository settings…) |
| `sandbox.filesystem.disabled` | `false` | **cannot set it** | only user, managed or `--settings`; only managed once managed configures `filesystem` | — (CS Which settings can disable it) |
| `sandbox.credentials` deny entries | none ("no built-in credential deny list") | add them | merge; no scope removes another's deny; `mask` entries are **ignored** in repo files | 2.1.246 for source exclusion (CS Protect credentials; Mask credentials) |
| `sandbox.network.allowedDomains` | empty | add entries | merge; ignored from repo files under an admin-required sandbox | — (CS Network isolation) |
| `sandbox.network.strictAllowlist` | off | **no effect** in project or local files | user, managed, `--settings` | 2.1.219 (CS Network isolation) |
| `allowAllUnixSockets`, `allowLocalBinding`, `enableWeakerNestedSandbox`, `enableWeakerNetworkIsolation` | `false` | turn on (each weakens the sandbox) | managed `false`; under admin-required a repo `true` is ignored | — (CS Keep developers from widening the policy) |
| `allowAppleEvents`, `allowNestedUserNamespaces` | `false` | **cannot** turn on | user, managed, `--settings` | — (same section) |

`allowedDomains` alone is not a closed network boundary: with no strict allowlist, an unlisted
host is allowed with no prompt in `bypassPermissions`, prompted in Manual and `acceptEdits`,
classifier-decided in auto mode, refused in `dontAsk` (CS Hosts outside your allowed domains);
WebFetch follows permission rules, not the sandbox list (CS What runs outside the sandbox).

Codex: user-level `~/.codex/config.toml`, project `.codex/config.toml` loaded only when trusted;
project config cannot set provider, auth, notification, profile or telemetry keys (XR
`config.toml`). `sandbox_mode` and `sandbox_workspace_write.*` are not on that excluded list.
`default_permissions` must not be combined with `sandbox_mode` or `[sandbox_workspace_write]`
(XR `default_permissions`), which is one reason §11 pins no Codex key: a user's existing
permission profile and a pinned legacy key in the project file could not both stand. **The
precedence between user and project config is not stated on the pages read and stays
unverified**, as do managed requirements beyond those quoted.

Machine mode (**DD-063**) is a user-scope rail in
`harness/templates/configs/claude-machine-settings.json`, not sandbox configuration and not
proof that hooks loaded; whether Claude Code runs the hooks of both scopes is still unobserved.
Host modes stand: `--safe-mode` and `--bare` skip configured hooks, `--restricted` ignores
project settings unless passed again with `--settings` (**DD-053**) — and so a session started
in `--restricted` also gets none of the project file's sandbox keys. The fail-closed hook
handling needs Claude Code 2.1.295 or later (**DD-040**).

## 6. Unavailability and the escape hatches

| Path out of the sandbox | Documented behaviour | H4b proposal |
|---|---|---|
| Platform or dependency unavailable at startup | unsandboxed unless `failIfUnavailable` (CS Get started) | leave unset, forced by §3; say so (§11) |
| Sandbox fails after start, with `failIfUnavailable` | each sandboxed command refused with `Sandbox is required…`, and the retry refused; excluded commands keep running outside; typed `!` commands keep running outside **except in a background session, where they are refused**; on Linux with `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` set, **excluded and typed commands are refused too** (CS Commands are refused with `Sandbox is required`) | n/a while unset |
| Unsandboxed retry (`dangerouslyDisableSandbox`) | allowed by default; mode decides approval (CS The unsandboxed retry escape hatch) | **turn off**: `allowUnsandboxedCommands: false` in the project file — a default, which a local-file `true` overrides (§5) |
| `excludedCommands` | matching calls run with full access; "a convenience, not a security boundary" (CR) | ship **none** |
| `!` typed commands | unsandboxed in most sessions; sandboxed in background sessions under strict mode, and every command on Linux with `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` (CS Turn off the retry) | not changed; documented as outside |
| An allow rule matching a command | also approves its unsandboxed retry with no prompt (CS The unsandboxed retry escape hatch) | moot once the retry is off; record it for adopters who turn it back on |
| Codex escalation | `on-request` asks before going beyond the boundary; rules can allow prefixes outside it (XS Configure defaults) | AMH ships only `forbidden` rules; approval policy left to the user |

## 7. Legitimate access outside the working tree, and what the sandbox would break

- **Temporary directories.** Claude Code: a per-user temp directory is writable and `$TMPDIR`
  points sandboxed commands at it; unsandboxed commands may resolve `$TMPDIR` elsewhere (CS
  Temporary directories). Codex `workspace-write`: `/tmp` and `$TMPDIR` are writable unless
  `exclude_slash_tmp` or `exclude_tmpdir_env_var` is set (XR). The ladder's fixture suites build
  repositories under `mktemp -d`; that they pass inside either sandbox is H4b acceptance (d).
- **Git worktrees.** Claude Code allows writes to a linked worktree's shared `.git` so `git commit`
  works, with `hooks/` and `config` there still denied (CS Filesystem isolation). Codex:
  unverified.
- **Protected paths inside the working tree** (Claude Code): writes to `.claude` settings files,
  `.claude/skills`, `.claude/agents`, `.claude/hooks`, `.mcp.json`, `.gitconfig`, and
  `.git/hooks` and `.git/config` are denied to sandboxed commands even inside writable
  directories (CS Protected paths). For AMH this means a sandboxed **shell** command cannot
  install `.git/hooks/pre-push`, run `git config` to set an author identity, or copy a template
  over `.claude/settings.json`. The SessionStart hook that installs the pre-push rail runs
  outside the sandbox, as every hook does (CS What runs outside the sandbox), and the Edit and
  Write tools follow permission rules instead; but `scripts/amh-init.sh` run as a sandboxed
  command against the working tree, and any playbook step that does these through Bash, must be
  probed in H4b (c).
- **`git merge` and `git checkout` over protected files.** They fail with `unable to unlink old`
  when they must replace a file the sandbox denies, such as one under `.claude/skills`; with
  `allowUnsandboxedCommands: false` Claude cannot offer the retry, so the user runs the git
  command in another terminal (CS A git command fails with `unable to unlink old`). AMH's train
  merges (`docs/RUNBOOK.md` → **Session discipline** 12) and any merge that changes an adapter,
  agent or skill file hit this; the recovery is owner-operated, and Edit and Write availability
  does not make a merge succeed.
- **The adapter's inherited denies (§5).** The `Edit` deny on `//**/.git/hooks/**` would also
  deny sandboxed writes to `.git/hooks` in every repository, fixture repositories under
  `mktemp -d` included, so a fixture that installs a hook from a sandboxed command can fail.
  The `Read` denies would stop sandboxed tools reading their own credential stores: git's
  `store` helper (`~/.git-credentials`), `gh` (`~/.config/gh/hosts.yml`), `npm` (`~/.npmrc`),
  `docker` and `kubectl`. Every existing rail stays (plan, H4b); H4b probes these with synthetic
  files, never real credentials (its acceptance (c) and (e)).
- **Network for git.** Sandboxed `git` over HTTPS reaches a host only once it is allowed; plain
  `ssh` ignores the proxy and cannot connect even to an allowed host (CS Network isolation), so
  with the retry off, `git push` over SSH fails inside the sandbox, and HTTPS push also needs
  its credential, which the inherited denies may block. H4b (c) probes the push path; nothing
  here allows a host.
- **Caches** (package managers, `~/.cache`): writes outside the defaults need `allowWrite`;
  on Linux and WSL2 an entry for a path that does not exist yet has no effect (CS Configure
  sandboxing). AMH's scripts need none; adopters' toolchains may.

## 8. What stays outside the boundary, claim by claim

Catalogued, not answered with new rails:

- **Write containment** (shell): working tree, temp, added directories (§7). Not covered: the
  Read, Edit and Write tools, which follow permission rules (CS What runs outside the sandbox);
  excluded commands; `!` commands; with the seccomp filter absent on WSL2, Windows programs
  (§4); a linked worktree's shared git storage, which is writable by design.
- **Read confidentiality**: none by default — sandboxed commands read "most of the machine,
  including credential files such as `~/.ssh` and `~/.aws/credentials`" (CS What the sandbox
  restricts). It narrows only by `credentials` and `denyRead` entries **and by `Read` and
  `Edit` deny rules**, which merge in (CS Permission rules) — so AMH's existing `Read` denies do
  apply (§5) — and a narrower `allowRead` can reopen part of a denied region (§5). A `denyRead`
  entry does not stop the Read tool. Mounted drives (`/mnt/c` on WSL2) are readable under the
  default.
- **Environment**: inherited, "including any secrets in its environment" (CS What the sandbox
  restricts), unless `credentials.envVars` or `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` remove them.
- **Network**: no direct route; HTTP(S) through a hostname-checking proxy; non-TCP cannot leave
  (CS Network isolation). The proxy refuses a hostname that resolves only to local addresses,
  the `169.254.169.254` metadata endpoint included, **with exceptions**: `localhost` and
  `*.localhost` may resolve to loopback, an IP address added to `allowedDomains` is allowed,
  connections to an IP address are decided by the allowlist and mode rather than this check,
  and the check is skipped for connections sent through an upstream corporate proxy (CS
  Hostnames that resolve to local addresses). So no general metadata-endpoint containment is
  claimed. An allowlist does **not** prevent exfiltration to an allowed destination, and the
  proxy does not inspect TLS, so domain fronting can reach unlisted hosts (CS Security
  limitations). WebFetch and WebSearch are outside it. Codex: permission-profile domain rules
  "do not restrict web search, apps, or MCP servers" and are enforced only while
  `features.network_proxy` (off by default) or managed networking starts the proxy; a profile's
  `network.enabled` alone gives direct, unfiltered network (XR
  `permissions.<name>.network.domains`, `permissions.<name>.network.enabled`,
  `features.network_proxy`). Runtime enforcement is unverified.
- **Whole process**: hooks — AMH's command guard, redaction and session bootstrap among them —
  local MCP servers, plugin monitors, LSP servers, the status line, `apiKeyHelper` and mods run
  with full access (CS What runs outside the sandbox). Only running Claude Code itself inside a
  container, VM or the sandbox runtime bounds them (same section; CS Limitations, Scope).
- **Desktop and OS services**: computer use runs on the actual desktop, gated by per-app
  prompts, not in an isolated environment; on macOS, each service listed in
  `network.allowMachLookup` acts for sandboxed commands beyond the sandbox, and
  `allowAppleEvents` — off by default, settable only from user, managed or CLI settings — lets
  sandboxed commands launch other applications unsandboxed (CS Limitations, Security
  limitations and Scope).
- **Sockets**: on macOS every Unix socket is blocked unless listed; on Linux and WSL2 only the
  seccomp filter blocks them, and a listed `/var/run/docker.sock` is host access (CR
  `sandbox.network.allowUnixSockets`; CS Security limitations).

## 9. Adopter migration

Adapters install under `keep`, so an existing adopter gets nothing automatically. Per the
owner's decision (§1 item 3), H4b's release carries, in the CHANGELOG's **Upgrading** subsection,
a note addressed to the adopter's agent: **ask the user whether they want the sandbox**; only on
a yes, merge the `sandbox` block of §11 into the existing `.claude/settings.json` without
replacing or printing its other contents, and point at the optional host tools (§1 item 4) for
Linux and WSL2. Codex needs no merge, since §11 pins no Codex key and leaves whatever Codex
policy the user already has — a `default_permissions` profile included — untouched.
`docs/UPGRADING.md` changes only if this becomes a recurring procedure. Installing anything at
user or managed scope needs separate owner authorization (**DD-066**) and is not part of this
design.

## 10. Two claims, kept apart

- **"Containment added on supported platforms"**: H4b may make this, per probed cell, for
  macOS, Linux and WSL2 shell commands under Claude Code, and for Codex where probed — each
  cell only after H4b's live probes, and WSL2's Windows-binary half only with the seccomp
  filter (§4). Nothing in this file makes it.
- **"DD-038's execution path contained"**: **not made, and not makeable under the owner's
  choice.** DD-038 ran in Claude Code on native Windows PowerShell 5.1, where this design ships
  no sandbox (§3). Blocking that path would need one of the unselected options, and testing an
  analogous path after a migration to WSL2 would be a different claim again.

## 11. What H4b inherits

**Proposed Claude Code project-file block** (template and this repo's copy), every existing rail
unchanged:

```json
"sandbox": {
  "enabled": true,
  "allowUnsandboxedCommands": false,
  "autoAllowBashIfSandboxed": false
}
```

**Codex: no key added.** Codex's documented default already sandboxes (§2.2). Pinning
`sandbox_mode` or `[sandbox_workspace_write]` would collide with a user's `default_permissions`
profile (§5) and could override the user's own policy under a precedence the pages do not
state. H4b's configuration validation instead fails the shipped Codex file if it sets a
loosening key — `sandbox_mode = "danger-full-access"`, a `[sandbox_workspace_write]` with
`network_access = true` or added `writable_roots`, a `default_permissions` naming
`:danger-full-access`, or a `windows.sandbox` value — and says in the README that AMH relies on
Codex's default and does not enforce it.

Design defaults this unit chose, each open to the owner at H4b's approval:

1. **`autoAllowBashIfSandboxed: false`** keeps today's prompt behaviour: its default `true`
   would let every sandboxed command run unprompted, changing what users see. The sandbox is a
   layer under the existing rails, not a replacement (plan, H4b).
2. **`allowUnsandboxedCommands: false`**, knowing it is a default a local file can undo (§5),
   and that it moves `unable to unlink old` recovery to the user's own terminal (§7).
3. **No `excludedCommands`, no `allowWrite`, no `allowedDomains`, no socket widening** in the
   shipped file; adopters add what their toolchain needs.
4. **No `credentials` entries.** The adapter's existing `Read` denies already restrict the
   commonest credential paths for sandboxed commands (§5). Whether H4b adds `credentials`
   entries — environment variables above all, which no current rule covers — is an owner
   choice not yet asked; it was not in §1 item 5.
5. **Saying the silent fallback.** Because `failIfUnavailable` stays unset (§3), H4b should make
   the fallback visible: the README and adapter comment, and a proposed addition of `bwrap` and
   `socat` to the tools line `scripts/session-start.sh` already prints, as an observation that
   decides nothing — presence on `PATH` only, since the seccomp filter and a working namespace
   cannot be seen that way.
6. **Version semantics** (plan §1 item 2): H4b changes what an adopter's agent can do, so it is
   at least MINOR and possibly MAJOR, settled when its behaviour is final.

## 12. Sources and probes

Documentation, fetched 2026-11-13T11:31Z with `curl -sSL`, first 16 hex digits of SHA-256 shown
so a later reader can tell whether a page changed:

| Tag | URL | Bytes | SHA-256 (16) |
|---|---|---|---|
| CS | https://code.claude.com/docs/en/sandboxing.md | 111,177 | `c6f2a884a7867218` |
| CSet | https://code.claude.com/docs/en/settings.md | 45,980 | `bc72fdd5dc45fdf7` |
| CR | https://code.claude.com/docs/en/settings-reference.md | 456,279 | `1a90c9ee8c64dc91` |
| XS | https://developers.openai.com/codex/concepts/sandboxing (served by learn.chatgpt.com/docs/sandboxing) | 509,266 | `e132ef5f4e628b1c` |
| XR | https://developers.openai.com/codex/config-reference (served by learn.chatgpt.com/docs/config-file/config-reference) | 1,615,535 | `81f47cfeea6cace1` |

Probes, all read-only, run 2026-11-13 on the author's host:

- **P1** `uname -srm` → `Linux 6.18.33.2-microsoft-standard-WSL2 aarch64`.
- **P2** `/.dockerenv` present and PID 1 is `docker-init`; `/proc/sys/fs/binfmt_misc/WSLInterop`
  absent, `WSL_DISTRO_NAME` unset, `/mnt` empty, no `cmd.exe`, `powershell.exe` or `wsl.exe` on
  `PATH` → a Docker container on a WSL2 kernel, not a WSL2 distribution. Whether the container
  is privileged was not probed.
- **P3** `claude --version` → `2.1.323 (Claude Code)`; `codex --version` → `codex-cli 0.159.0`.
- **P4** `command -v bwrap`, `command -v socat` → absent; `npm` absent. Whether the seccomp
  filter is available was not probed (the `/sandbox` Dependencies tab is the documented check).
- **P5** `/proc/sys/user/max_user_namespaces` → `79959`;
  `kernel.unprivileged_userns_clone` and `kernel.apparmor_restrict_unprivileged_userns` not
  present on this kernel.
- **P6** the adapter files read at `cd36199`: no `sandbox` key in either Claude settings copy or
  the machine fragment; the template's `Read` and `Edit` deny rules listed with
  `grep -o '"\(Edit\|Write\|Read\)([^"]*)"' harness/templates/configs/claude-settings.json`; no
  sandbox key in `harness/templates/configs/codex-config.toml`; every rule in
  `.codex/rules/amh.rules` is `forbidden`.

## 13. Not verified

- **No effective or enforced state in any cell.** No sandboxed session ran and no session's
  resolved settings were read; H4b (b)–(d) owns that, and an unprobed cell blocks its claim.
- macOS, WSL2 distributions, WSL1 and native Windows: no such host here. Whether this container
  is unprivileged, and whether the seccomp filter is available here.
- How each of the adapter's `Read` and `Edit` deny globs translates into a sandbox path rule.
- Codex: behaviour when bwrap and the helper both fail; WSL1; worktree handling; user-versus-
  project precedence; whether its hooks run outside its sandbox; runtime enforcement of any
  network rule.
- Claude Code desktop app and IDE extensions; whether project-file sandbox keys load in every
  start mode beyond those **DD-053** names.
- That the documentation describes the builds installed here (2.1.323, 0.159.0); the pages carry
  no version stamp.

## 14. The review this unit owed

One combined rule-review and adversarial pass, gpt-6-astra at `-e high`, over the first draft
of this file, at `cd36199` plus the uncommitted draft. Verdict **REVISE**, 14 findings (4 P1,
10 P2). The reviewer replayed all five SHA-256 prefixes and byte counts and the P6 adapter
observations, and confirmed the DD-038 attribution; it could not replay P2–P5, its executor
being a different container. Each finding was re-read against the cited source before it was
applied, and all 14 held:

| # | Finding | Applied in |
|---|---|---|
| 1 (P1) | "Today's effective state is unsandboxed" did not follow from absent project keys | §2 lead; §2.1 |
| 2 (P1) | Matrices lacked the requested-configuration and client/version dimensions; inherited and `n/a` cells had no source | §2.1, §2.2 rebuilt |
| 3 (P1) | `Read` and `Edit` deny rules merge into the sandbox, and the adapter already has them | §5, §7, §8, §11 item 4, P6 |
| 4 (P1) | Pinned legacy Codex keys conflict with a user's `default_permissions` profile | §11 pins no Codex key; §5, §9 |
| 5 | `git merge` and `git checkout` fail on protected files, with no retry under strict mode | §7 |
| 6 | Codex's search, apps and MCP exclusion is documented in the profile and proxy entries, not only for Work Cloud | §8 |
| 7 | Background-session and `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` exceptions after a required-sandbox failure | §6 |
| 8 | A narrower `allowRead` reopens a denied region; entry retention is not effect retention | §5 table |
| 9 | The local-address check has exceptions | §8 |
| 10 | Computer use, Mach and XPC services, Apple Events | §8 |
| 11 | P2 shows a container, not an unprivileged one | §2.1, P2, §13 |
| 12 | npm's absence does not show the seccomp filter's absence | P4, §13 |
| 13 | Managed requirements still apply when Codex skips project layers | §2.2 |
| 14 | `network_access = false` was attributed to a default the page does not state | removed with §11's Codex keys |
