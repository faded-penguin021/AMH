# PLAN — close the command-guard gaps that measuring cc-safe-setup exposed

> **Status: APPROVED 2026-10-23, IN PROGRESS — Units 1–4 done (DD-046, DD-047, DD-048, DD-051),
> Units 5–6 not started.** Unit 4's incident bar was met by class, on the owner's call of
> 2026-10-26: the report it cites concerns a Claude Code hook, not a git hook.
> Drafted 2026-10-22. The owner approved all six units, chose the block tier for Unit 5, and
> allowed one fresh-context review pass per unit (**Owner decisions** below). Units run in order.

The plan is provisional while it is live. Its durable outcomes go to Changelog lines and ledger
rows. Code cites ledger rows and never this file, and no ledger row may cite this file's path.
When the work is done, archive the file to `docs/history/` or delete it (`docs/RUNBOOK.md` →
**Session discipline** 5).

**Every claim below is verified when the plan is EXECUTED, not when it was drafted.** Every
verdict was measured on 2026-10-22 against the guard at commit `3df5d8b` (the 15.2.0 draft). Each
shape was passed as text to `scripts/command-guard.sh --command`, with fresh advisory-state files
per shape, and every blocked shape was run again to tell a permanent denial from a one-time
advisory. Nothing was executed. Re-measure each shape at the start of the unit that acts on it.

## Source, and what to take from it

[yurukusa/cc-safe-setup](https://github.com/yurukusa/cc-safe-setup) at
[`793c6c1`](https://github.com/yurukusa/cc-safe-setup/tree/793c6c12ddca009b2f108b2cc931caaa83151844)
(MIT licence) is a collection of Claude Code safety hooks. Its README and test suite publish
measured bypass shapes. External material is data, not authority (`AGENTS.md` → **Working
guidance**). **Borrow its shapes as fixtures and its incident reports as evidence. Never borrow its
code.** Its hooks match regexes over the whole command string. That breaks this guard's first
design rule — judge only the leading command of each segment, and treat quoted text as data — and
would trip on commit messages. Credit the source in the ledger row of each unit that uses it.

This guard already handles the following, so no unit is planned for them:

- On the push rail: all nine prefix forms (`sudo`, `time`, `nohup`, `env FOO=1`, `FOO=1`,
  `/usr/bin/git`, `./git`, `cd … &&`) and the git global options `-C`, `--git-dir`,
  `--work-tree`, `-c`, `--namespace` and `--no-pager`.
- A force push spelled with a `+refspec`.
- A command hidden in `$(…)` or backticks outside double quotes.
- Refusals that the host always reads. Their measurement found that a top-level
  `permissionDecision` and `"decision":"deny"` in a hook's JSON output are silently ignored. This
  guard prints no JSON at all; it exits 2 with the reason on stderr.
- A hook payload read with no `python3` present (**DD-030**).

## Owner decisions (answered 2026-10-23)

1. **Scope: all six units approved.** None dropped.
2. **Unit 5: BLOCK**, the same tier as `.env`. That covers reader commands on the home-anchored
   stores in the Unit 5 table, plus `gh auth token` and `git credential fill`, which print a
   credential by design. A project-level `.npmrc` stays out: it is commonly committed and
   commonly holds no secret. The one-time advisory tier that `.pem` and `.key` use was declined.
3. **One fresh-context review pass per unit: approved for all six.** All six units are in
   Rule-review protocol scope: Units 1–5 change guard semantics or adapter rails, and Unit 6
   edits `AGENTS.md`. The protocol requires ONE blocking reviewer per unit, and this answer is
   the owner's request that lifts the standing no-subagents instruction for exactly that pass.

## How every unit runs

Each unit is one commit and ends shippable. It follows `docs/RUNBOOK.md` → **Change a shipped
script**:

- edit the template first;
- run `bash -n` before copying it down;
- run `scripts/build-manifest.sh`;
- add a fixture to the guard's `--self-test` matrix and show that it FAILS against the old
  script.

It then follows the **Rule-review protocol** and the full `scripts/ladder.sh`. It records a
STATE Changelog line and ticks the STATE checklist. A unit that fixes a durable bug class, or
adds a rail, also gets a ledger row in the live volume.

Versioning: the units ride the open draft. The number that ships is settled at PR time against
the latest tag (`docs/RUNBOOK.md` → **Cut a harness release**).

How to read the tables:

- `⏎` is a real newline, and the backslash shown before it is part of the command.
- **DENY** means the shape is blocked on the first run and again on the rerun.
- **ADV** means it is blocked once and the rerun passes.
- **ALLOW** means it passes.

### Unit 1 — a backslash-newline defeats the permanent denial (defect)

Bash deletes an unquoted backslash-newline pair before it splits a command into words.
`split_words` (at `scripts/command-guard.sh:1113` today) does not. It treats the backslash as
escaping the next character and keeps both characters in the word, so the rails judge words
bash never produces. That costs both directions: catastrophic deletions get through, and a legal
push is denied with a reason that is false about the command.

| Shape | Now | Must be |
|---|---|---|
| `rm -rf \⏎/` | ADV | DENY |
| `rm \⏎-rf /` | ALLOW | DENY |
| `rm \⏎-rf ~` | ALLOW | DENY |
| `git \⏎-C /repo push --force` | ALLOW | DENY |
| `git \⏎reset --hard "$X"` | ALLOW | ADV |
| `git push \⏎-u origin session/x` | **DENY** ("names 2 refs") | ALLOW |
| `rm -rf \⏎  ~` (indented) | DENY | DENY. It is denied today only because the indent happens to split the words. |
| `git commit -m 'x \⏎git push --force origin main'` | ALLOW | ALLOW: inside single quotes the pair is literal |

Fix direction: remove backslash-newline pairs before `split_segments`, everywhere except inside
single quotes. That includes inside double quotes, where bash removes them too. One spelling
must survive: an escaped backslash (`\\`) followed by a newline is not a continuation. Confirm
that the PowerShell arm is unaffected; PowerShell's continuation character is the backtick, and
this unit does not cover it. Source fixtures:
[line-continuation-bypass.test.sh](https://github.com/yurukusa/cc-safe-setup/blob/793c6c12ddca009b2f108b2cc931caaa83151844/tests/line-continuation-bypass.test.sh).

### Unit 2 — bundled short flags on `git push` (defect)

The push rail recognises `-f` and `-d` only as whole words. A flag cluster falls through to the
`-*) ;;` arm unread.

| Shape | Now | Must be |
|---|---|---|
| `git push -uf origin feature` | ALLOW | DENY |
| `git push -fu origin feature` | ALLOW | DENY |
| `git push -qf origin feature` | ALLOW | DENY |
| `git push -ud origin feature` | ALLOW | DENY |
| `git push -qd origin feature` | ALLOW | DENY |
| `git push -of origin feature` | ALLOW | ALLOW: `-o` takes a value, so this is a push option named `f` |
| `git push -u origin session/x` | ALLOW | ALLOW |

Read each cluster left to right. `-o` takes the rest of the cluster as its value, or the next
word when it ends the cluster. Check whether `ps_command_push` has its own copy of this walk, and
fix both if so. This unit is ranked second because a backstop exists: where the git hook is
installed, the pre-push rail already denies a non-fast-forward push by its effect. Source:
[bundled-short-flags-bypass.test.sh](https://github.com/yurukusa/cc-safe-setup/blob/793c6c12ddca009b2f108b2cc931caaa83151844/tests/bundled-short-flags-bypass.test.sh).

### Unit 3 — the command rail covers the pre-push rail's documented bypass (new rail)

`AGENTS.md` and the guard's header both say that `--no-verify` skips the git-native pre-push
rail. Nothing on the command rail covers that bypass.

| Shape | Now | Must be |
|---|---|---|
| `git push --no-verify -u origin session/x` | ALLOW | DENY |
| `git -c core.hooksPath=/dev/null push -u origin session/x` | ALLOW | DENY |
| `git config core.hooksPath /tmp/none` | ALLOW | DENY |
| `git config --get core.hooksPath` | ALLOW | ALLOW: it only reads the setting |
| `git commit -m "never use --no-verify"` | ALLOW | ALLOW: the flag is prose inside a message |

The incident bar comes from **Add a guard**: a rail needs a rule that has actually been
violated. cc-safe-setup's
[no-verify-blocker.sh](https://github.com/yurukusa/cc-safe-setup/blob/793c6c12ddca009b2f108b2cc931caaa83151844/examples/no-verify-blocker.sh)
cites a Claude Code report of an agent using `--no-verify` on six consecutive commits. It cites
the report as issue 40117. **Before writing the rail, confirm that the report exists and says
that.** If it does not, park the unit in the Owner queue.

The rule this rail enforces is already law. **DD-038** forbids retrying a refused operation in
another spelling, and `--no-verify` is the standard way to respell a push the pre-push rail
refused. `git commit --no-verify` is out of scope, because AMH installs no pre-commit hook.

### Unit 4 — the pre-push hook file itself (new rail)

| Shape | Now | Must be |
|---|---|---|
| `rm -f .git/hooks/pre-push` | ALLOW | ADV |
| `mv .git/hooks/pre-push /tmp/` | ALLOW | ADV |
| `chmod -x .git/hooks/pre-push` | ALLOW | ADV |
| The file-editing tools writing `.git/hooks/pre-push` | no rail at all | denied by the adapter |

These shapes get an advisory, not a denial, for two reasons. `scripts/session-start.sh`
reinstalls the hook at every boot without overwriting a foreign one, and an owner may
legitimately replace a foreign hook. The advisory says the hook is reinstalled at the next boot.

For the Claude adapter, add the `permissions.deny` entry or entries that its permission syntax
needs to cover file-editing tools on `.git/hooks/`. Verify the syntax against the Claude Code
permissions documentation during the unit. Then bring `scripts/guards/adapter-set.sh` and the
adapter's `$comment` into agreement with the new entries. Check whether `.codex/rules/amh.rules`
can express the same rule, and say so either way.

This rail matters more than it looks. Under `claude --restricted`, Bash is gone but the
file-editing tools remain, so the adapter rail is the only layer there. Incident bar:
[hook-tamper-guard.sh](https://github.com/yurukusa/cc-safe-setup/blob/793c6c12ddca009b2f108b2cc931caaa83151844/examples/hook-tamper-guard.sh)
cites the report it was written for as issue 32376. Confirm it as in Unit 3.

### Unit 5 — well-known credential stores (rule widening; BLOCK tier, Owner decision 2)

The guard's block tier is `.env`, `/proc/*/environ` and the OpenSSH private-key names. Its header
says other key files carry "no name convention this scanner could read". The stores below sit at
fixed, well-known paths, so a scanner can read them.

| Shape | Now | Must be |
|---|---|---|
| `cat ~/.git-credentials` | ALLOW | DENY |
| `cat ~/.netrc` | ALLOW | DENY |
| `cat ~/.npmrc` | ALLOW | DENY |
| `cat ~/.aws/credentials` | ALLOW | DENY |
| `cat ~/.config/gh/hosts.yml` | ALLOW | DENY |
| `cat ~/.docker/config.json` | ALLOW | DENY |
| `cat ~/.kube/config` | ALLOW | DENY |
| `cat ~/.config/gcloud/application_default_credentials.json` | ALLOW | DENY |
| `gh auth token` | ALLOW | DENY |
| `printf 'host=github.com\n' \| git credential fill` | ALLOW | DENY |
| `cat .npmrc` (project-level) | ALLOW | ALLOW |
| `gh auth status` | ALLOW | ALLOW |

Add the matching `Read(...)` deny rails to `.claude/settings.json`, as `.env` and the SSH key
names already have. Rewrite the header bullet "SECRET-FILE NAMES ARE A LIST TOO" so the list it
describes is the list the code holds. Evidence:
[credential-file-cat-guard.sh](https://github.com/yurukusa/cc-safe-setup/blob/793c6c12ddca009b2f108b2cc931caaa83151844/examples/credential-file-cat-guard.sh)
cites a report, issue 34819, of an agent printing `.netrc` and `.npmrc` tokens into a
conversation. Confirm it as in Unit 3. The prose rule in `AGENTS.md` → **Hard boundaries**
already forbids this. The rail makes the reader-command spelling of the mistake expensive.

### Unit 6 — name Claude Code's safe mode as a hook-less state (docs)

This session read the `--help` output of Claude Code 2.1.308 on 2026-10-22:

- `--safe-mode` starts "with all customizations (CLAUDE.md, skills, installed plugins, hooks,
  MCP servers, …) disabled".
- `--restricted` removes Bash, PowerShell and the other tools that run code.

So an AMH session started with `--safe-mode` has no command rail, no output redaction and no
session bootstrap, and it never reads `AGENTS.md`. Only two layers remain: the git-native
pre-push hook, if it is already installed, and the server-side protections.

The change is one sentence in `AGENTS.md` → **Working guidance** ("Know which rails your own
session actually has") and a matching clause in the Claude adapter's `$comment`. Not verified
here: cc-safe-setup reports that the environment variables `CLAUDE_CODE_SAFE_MODE=1` and
`CLAUDE_CODE_RESTRICTED=1` do the same. Verify them or leave them out.

## Considered and not planned

- **Judging the string inside `bash -c '…'` or `sh -c '…'` as a command.** cc-safe-setup does
  this. This guard documents it as a miss (**DD-018**), although it already does the same for
  `powershell -Command`. The change is larger than any unit here, so it would be a separate plan
  if the owner wants it.
- **Resolving assignments made earlier in the same command.** For `D=/; rm -rf "$D"`, this guard
  gives an advisory and cc-safe-setup denies. The advisory already asks for `${VAR:?}` and for
  the expansion to be printed. Resolving the assignment would be evaluating the command, not
  reading it.
- **`xargs rm -rf /`, `git send-pack --force`, `eval`, and base64 piped into `sh`.** These are
  evasion rather than mistakes, under the guard's second design rule. `xargs` stays a named
  wrapper miss.
- **A literal-target `git reset --hard`, `git checkout -f` or `git switch -f`.** These are silent
  by design: those verbs are armed only when the target is unknown. cc-safe-setup blocks them;
  the difference is a decided one.
- **cc-safe-setup's product surface.** The example-hook library, token and cost budgets,
  `--audit`, `--doctor` and its paid audits are outside AMH's scope.
