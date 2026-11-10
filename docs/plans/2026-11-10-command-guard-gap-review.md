# PLAN — close the command-guard gaps two reviews found

> **Status: rev 1, committed 2026-11-10 (G0) as an open draft. Nothing in it is approved.**
> Unit G1 is a review of this plan by gpt-6-astra at `-e high`, on the owner's instruction of
> 2026-11-10. No code unit starts before its findings are folded in as rev 2, and each code unit
> then starts only on the owner's explicit approval of that unit.
> One decision is already answered (§2, item 3): **the incident bar does not gate a
> command-guard gap.** What gates a unit here is what it would newly refuse, not whether the
> loss has happened yet.
> **Every measurement in §3 is re-taken when the unit that acts on it starts.**

The plan is provisional while it is live. Its durable outcomes go to Changelog lines and ledger
rows. Code cites ledger rows and never this file, and no ledger row may cite this file's path.
When the work is done, archive this file to `docs/history/` or delete it (`docs/RUNBOOK.md` →
**Session discipline** 5).

Unit names carry a `G` prefix (for *gap*). That keeps them distinct from the owner-queue-closure
plan's Units 0–4, the research-gaps plan's `H` units, the spill-guard plan's `S` units and the
cc-safety-net plan's `N` units. G0 and G1 are the owner's "unit 0" and "unit 1".

## 1. Sources, and what was left out on purpose

Two reviews of `scripts/command-guard.sh`, both asked for by the owner on 2026-11-10:

- **This session's read.** The header, the parsers up to the heredoc walker, every rail, the
  destructive dispatcher, and the hook, pre-push and pre-task entry points. It was made at
  `3b1d88f`, on a checkout two releases behind; the guard's logic changes from there to
  `8b7c836` were then read as a diff, and every measurement in §3 was re-taken at `8b7c836`.
  **Not read:** the heredoc walker's body (`heredoc_walk`, `heredoc_bodies`), the `cmd.exe` and
  PowerShell arms (`cmd_lower` through `check_powershell_command`) and the self-test. Nothing
  below is a claim about those.
- **An external review the owner relayed** (Gemini; fourteen findings). It is data, not
  authority (`AGENTS.md` → **Working guidance**): each finding was re-checked against this tree
  before it was accepted, and §6 gives the outcome one by one. Two do not hold as written.

**Left out, because something already carries it.** This plan does not restate:

- what the guard's own header lists under *WHAT THIS GUARD DOES NOT CATCH*;
- the spill-guard plan: options on the wrappers the guard already peels (S6a), new wrapper
  families (S6b), kubeconfig names (S6c), refusal text that repeats an operand (S1), and its
  considered-and-not-planned list;
- the cc-safety-net plan: a listed secret sent off the machine (N3), credential stores at a
  fixed path (N4), the `git checkout` spellings of `git restore` (N5), the string after
  `bash -c` (N7a, N7b), `find` (N8), the verbs it defers (N9), and its not-taken list;
- the Owner queue's open items: a quote inside backticks, and the payload parser on a
  non-UTF-8 code page (**DD-069**);
- the research-gaps plan's host-sandbox units (H4a, H4b);
- the STATE **Decided non-items**. Two of them bound the designs here: a guard never opens a
  file to classify a command (**DB-027**), and no script detects a host or a session through
  one vendor's variables (**DA-022**).

§5 lists what a review raised that landed in one of those. Two units here deliberately reopen
something another plan declined, and say so where they do it (G9, G10).

## 2. Owner decisions

1. **Whether to adopt this plan, and which units.** Open. G1 comes first and may change the
   options. Adopting the plan approves no unit.
2. **G1's reviewer and mandate.** The reviewer is answered: gpt-6-astra at `-e high`. This
   session cannot launch it (no `codex` on its `PATH`), so the owner launches it or a session
   that can. **Open: its mandate.** Recommended: the grant the cc-safety-net plan's N1 had, to
   overturn this plan's decisions and add, rewrite or delete units, with the ledger's decided
   rows, the `AGENTS.md` hard boundaries and the other plans outside it.
3. **Whether the incident bar gates these gaps. Answered by the owner, 2026-11-10: it does
   not.** In the owner's words: "I'd warn against the incident bar for the command guard. You
   don't want to delete the root of the drive, read a .env before thinking on how to guard
   against it." So no unit here waits for a report that the loss happened. §4 still says of
   each gap whether it is a **defect** (the script failing to do what its own text, or a ledger
   row it cites, says it does) or a **widening** (a new member of a list, or a rail on a new
   surface), because the two cost differently. A widening spends the false-positive budget the
   guard's design rules are built around, so each one states what ordinary work it would newly
   refuse and measures that before it ships. That measurement is the gate, in the incident's
   place.

   **Left open by that answer, and the owner's:**
   - Three texts still say the opposite. `docs/RUNBOOK.md` → **Add a guard** opens with "a
     rule has actually been violated. Not before". The guard header's data-plane bullet admits
     a verb on a public report (**DC-027**). The research-gaps plan's lesson 1 keeps the bar.
     Amending them is legislation, a rule-review unit of its own, and not something this plan
     changes by citing a chat message. Until then each unit's ledger row names the owner's
     call as its basis.
   - How far the answer reaches into the other plans. The cc-safety-net plan defers N9 and N6b
     on that bar and N8 on **DD-018**. This plan moves none of them.
4. **Order against the other plans.** S6a rewrites the prefix loops G8 and G9 also read. S1
   rewrites the reason text several units add to. N3 and N4 widen the reader and store lists
   that G12 widens, and N5 edits the destructive git arms beside G9. Recommended: S1 and S6a
   first; after that, whichever of two overlapping units lands second rebases onto the other.
5. **One fresh-context reviewer per code unit.** Every code unit changes a shipped script or
   guard semantics, so each owes the **Rule-review protocol**. That needs the standing
   no-subagents instruction lifted for exactly that pass, as the spill-guard plan's decision 4
   did.
6. **The forks named inside the units** (G2's shallow case, G3's unreadable-payload arm, G5's
   inventory, G6's key, G7's match, G9's `rm -r` tier and its `cd` placement, G10's deny rail,
   G12's members).
7. **Version semantics** stay provisional until each unit's final behaviour is known
   (**Session discipline** 7(c)).

## 3. What was measured

**Method (2026-11-10, at `8b7c836`; bash 5.2.21, git 2.43.0, GNU coreutils 9.4, Python 3.13,
`HOME=/root`).**

- Guard shapes went to `scripts/command-guard.sh --command` with every `*_ADVISORY_STATE`
  variable pointing into a fresh `mktemp -d` per shape, three runs each. **DENY** is refused on
  all three, **ADV** refused once and then allowed, **ALLOW** allowed on the first run. No
  shape below was refused exactly twice. The guard ran; the candidate command never did.
- Hook shapes went to the guard's stdin as a JSON payload; the result is its exit status
  (2 blocked, 0 allowed or not judged).
- Everything that really executed (pushes, a `chmod`, an `rm -r`) ran inside a `mktemp -d`
  tree against a throwaway bare repository, with a copy of the guard.
- No credential existed in these runs: every secret-shaped name is an unset variable or a path
  that was never opened.
- The probe scripts lived in the session's scratch space and are not committed. Every
  single-shape row replays with one `--command` call; §3.12 gives the recipes for the rest.

### 3.1 The pre-push rail allows the force push it was built for

| Situation | Outcome | Control |
|---|---|---|
| A full clone (`git rev-parse --is-shallow-repository` says `false`). Another clone pushed a commit to the branch. This clone never fetched it, committed something else, and ran `git push --force origin session/x` with the AMH wrapper installed | push exit 0; the remote tip went from the other clone's commit to this one's | the same push once the remote tip had been fetched: push exit 1, tip unchanged |
| That control again after `chmod -x scripts/command-guard.sh` | push exit 0; the other clone's commit overwritten | — |

**Reading.** `prepush_is_ancestor` maps every `git merge-base --is-ancestor` status other than 0
or 1 to "undetermined", and undetermined fails open. The header files that under "a shallow
clone's missing objects". A remote tip absent from a **full** clone's object store is the
ordinary case of a branch someone else advanced, and there the answer is decidable: a commit
this clone does not have cannot be an ancestor of one it does. It is also the case in which git
refuses a plain push and `--force` is the natural retry, on exactly the hook-less agent for
which this rail is the only one (`AGENTS.md` → **Working guidance**).

The wrapper `scripts/session-start.sh` installs tests `[ -x "$root/scripts/command-guard.sh" ]`
and exits 0 otherwise, then runs the script through `bash`, which needs no execute bit. The
Claude adapter's own comment gives a lost executable bit as the reason its hooks go through
`bash`; here the same loss switches the rail off in silence. And `install_prepush_hook` returns
as soon as it finds its own marker in an existing hook, so a corrected wrapper would never
reach a checkout that already has one (read, not run).

### 3.2 The hook does not judge every shell payload it is handed

| Payload (`tool_input.command` is `printenv` unless said) | Exit |
|---|---|
| control: `tool_name` `Bash` | 2 |
| `tool_name` `Monitor` | 0 |
| `command` given as an argv array | 0 |
| the command ends in ` # \ud83d` (a lone surrogate escape) | 0 |
| no `python3` on `PATH`; `"description":"command"` sits before `"command"` | 0 |
| no `python3`; a nested `{"command":1}` sits before `"command"` | 0 |
| no `python3`; `"description":"run command for build"` first (the external review's example) | 2 — not reproduced |

**Reading.** The Owner queue already holds the parser's swallowed encode or decode error on a
non-UTF-8 code page (**DD-069**), "measured only as the mechanism" and with no one-line check.
The surrogate row is the same swallow on the host in front of us, with no code page involved:
`print` cannot encode a lone surrogate, the `except` catches it, and the command passes
unjudged. It also bounds that item's proposed fix, because writing UTF-8 bytes raises on a lone
surrogate unless the encoder is told how to treat one. The argv-array row is a `command` that
is not a string, printed as its Python form and judged as that.

In the fallback, `json_command_string` cuts at the first `"command"` after `"tool_input"`,
whatever it is. A string value that is exactly `command`, or a nested key of that name, lands
on a character that is not `:` and the decoder gives up, which is the fail-open path.

**The tool surface.** This host lists a tool named `Monitor` whose schema describes its
`command` field as "Shell command or script". Both Claude fragments, the project adapter and
the machine-mode one, match the `Bash` and `PowerShell` tools only, and `extract_command`
accepts those two names only. On this host the spawn tool is also listed as `Agent`, while the
adapter's spawn matcher is `Task`. What the host does with either is not verified (§7).

### 3.3 The forge rail: three spellings, and an inventory with a client-shaped hole

| Shape | Verdict | Same operation, as the rail reads it |
|---|---|---|
| `gh api -X DELETE /repos/o/r`; `gh api -X PATCH /repos/o/r -f default_branch=dev` | ALLOW | `gh api -X DELETE repos/o/r`: DENY |
| `gh api -X DELETE 'repos/o/r/actions/caches?key=k'` | ALLOW | the storage class matches `/actions/caches/` only without a query string |
| `curl -X DELETE http://api.github.com/repos/o/r` | ALLOW | `https://`: DENY |
| `gh repo delete o/r --yes`; `gh repo edit o/r --visibility public …`; `gh release create v1.0.0`; `gh release delete v1.0.0 --yes --cleanup-tag`; `gh secret set X --body x`; `gh variable set …`; `gh pr merge 12 --squash --admin`; `gh workflow run deploy.yml` | ALLOW | each is a class the rail denies through `gh api` |
| `gh api -X PUT repos/o/r/pulls/12/merge`; `-X POST repos/o/r/merges`; `-X PUT repos/o/r/contents/README.md … -f branch=main`; `-X PUT repos/o/r/collaborators/someone -f permission=admin` | ALLOW | `-X DELETE repos/o/r/branches/main/protection`: DENY |
| `gh api graphql -f query='mutation { deleteBranchProtectionRule(…) }'`; `mergePullRequest`; `createCommitOnBranch` on `main` | ALLOW | `deleteRef`: DENY |
| `curl -X DELETE` against a GitHub Enterprise or self-hosted GitLab host; `glab api -X DELETE projects/1` | ALLOW | — |

**Reading.** The first three rows are spellings of operations the rail already denies: the
repository-root arm matches `repos/*/*` and the documented spelling starts with a slash; the
class match keeps the query string the path match strips; the scheme is matched as `https://`.
The rest is inventory. The header says what this rail cannot see (application code, a script,
an alias, a shell string, a UI). It does not say that the forge's own client reaches the same
operations by subcommand, or that merging into the default branch and committing to it through
the API are outside every class, though the push rail and the constitution both treat the
default branch as the owner's.

### 3.4 The subagent rail is a toggle, not an advisory per spawn

Four consecutive `--pre-task` calls sharing one state file: exit 2, 0, 2, 0. The state says
"the next call may pass", not "this spawn was advised". Two spawn calls issued together
therefore come out as: the first refused, the second through with no advisory of its own, and
the first refused again on its rerun. The header says the rail "advises every spawn". The order
in which a host runs hooks for calls issued in one turn was not observed (§7).

### 3.5 The `.env` and key advisories are spent by text that names no file

| Sequence, one state file | Exits |
|---|---|
| `node -e "console.log(process.env.NODE_ENV)"`, then `python3 -c "print(open('.env').read())"` | 2, then 0 |
| `grep -rn "os.environ" src/`, then the same `python3 -c` read | 2, then 0 |

**Reading.** The dotenv tier matches `*.env*` over the whole command text, so `process.env`,
`os.environ` and a commit message that mentions the file all spend it, once per session. The
destructive, interpreter and hook-file tiers were each moved to a per-target or per-text key
for the reason **DB-030** records; these two were not. The header's INTERPRETERS bullet calls
the interpreter read "the widest hole" and rests it on this speed bump.

### 3.6 Secret values the rail lets through

**Names.** `echo` of `"$DATABASE_URL"`, `$PGPASSWORD`, `$MYSQL_PWD`, `$SECRET_KEY_BASE`,
`$GH_PAT`, `$DB_PASS`, `$REDIS_URL`, `$SENTRY_DSN`, `$SLACK_WEBHOOK_URL`, `$OPENAI_APIKEY`,
`$API_KEYS`, `$JWT_SECRETS` and `$SSH_PASSPHRASE`: all ALLOW, and so is
`declare -p DATABASE_URL`. Control: `echo $GITHUB_TOKEN` and `declare -p GITHUB_TOKEN`, DENY.
`is_secret_name` compares the last underscore-delimited component with six words, so a
component such as `PGPASSWORD`, a plural, and every connection string miss. The guard's own
data-plane advisory tells the agent to print the `DATABASE_URL` host and "never the whole URL,
which carries a password".

**Printers.** The expansion check runs for `echo`, `printf` and `print` only:

| Shape | Verdict |
|---|---|
| `cat <<< "$GITHUB_TOKEN"`; `wc -c <<< "$GITHUB_TOKEN"` (a length) | ALLOW |
| `set -x; curl -sH "Authorization: Bearer $GITHUB_TOKEN" …`; `bash -x deploy.sh`; `curl -v -H "Authorization: Bearer $GITHUB_TOKEN" …` | ALLOW |

Shell tracing and a client's verbose mode print the expanded value on stderr. Output redaction
sees it only on a call that succeeded, and only in the shapes `scripts/redact.sh` enumerates.

### 3.7 The deletion rail

| Shape | Verdict | Control |
|---|---|---|
| `rm -r ~`; `rm -r /`; `rm --recursive ~/`; `rm -R "$S/base"` | ALLOW | `rm -rf ~`: DENY |
| `cd ~ && rm -rf *`; `cd / && rm -rf *`; `cd $BUILD_DIR && rm -rf *`; `cd ~ && git clean -fdx`; `pushd ~ && rm -rf .` | ADV | `git -C ~ clean -fdx`: DENY |
| `cd ~/.aws && cat credentials`; `cd ~/.kube && cat config`; `cd ~ && cat .npmrc` | ALLOW | `cat ~/.aws/credentials`: DENY |
| `git -C sub -C 'C:\Users\me' clean -fdx`; `git -C sub --work-tree='C:/Users/me' clean -fd` | ADV | the same with `/root`: DENY |
| `python3.12 -c "import shutil; shutil.rmtree('/tmp/dir')"`; `pypy3 -c …`; `uv run python -c …` | ALLOW | `python3 -c …`: ADV |

**Reading.**

- The rail arms on `-r` and `-f` together. Measured in a fixture tree: GNU `rm -r` with stdin
  not a terminal removed a tree holding a mode-444 file without asking. An agent's shell has no
  terminal, so there `-r` alone is as final as `-rf`, and the permanent denial of the root and
  the home directory does not reach it.
- The guard places a git pathspec under `-C` and judges where it lands. It does not place a
  relative operand under a `cd` in the same command, though the directory is in the text. With
  `$BUILD_DIR` unset and unquoted, `cd` goes home, and the advisory's unexpanded-variable
  paragraph stays silent because the `$` is not among `rm`'s operands (read from
  `record_destructive_targets`, not measured). The store rows are the same gap on the secret
  rail; `names_credential_store`'s comment calls `cat .npmrc` run from home something "no word
  in the command can tell", and here a word does.
- `git_place_join` treats a path as anchored when it starts with `/`, `~` or `$`. A Windows
  drive path is joined under the earlier directory, so the target list never sees it. It needs
  a second place option to reach; a lone `-C 'C:\Users\me'` is denied.
- `INTERPRETER_COMMANDS` is matched by exact name.

### 3.8 The guard's own files

`rm .git/hooks/pre-push` is ADV. All of these are ALLOW: `chmod -x scripts/command-guard.sh`,
`rm scripts/command-guard.sh`, `mv scripts/command-guard.sh /tmp/`,
`git rm -q scripts/command-guard.sh`, `git checkout v1.0.0 -- scripts/command-guard.sh`,
`sed -i 's/^DEFAULT_BRANCH=.*/DEFAULT_BRANCH=trunk/' amh.conf`, `rm .claude/settings.json`.

What each costs: without its execute bit the script no longer backs the pre-push rail (§3.1).
In project mode the guard sources `amh.conf` on every call. On a copy of the guard with its own
`amh.conf`: `DEFAULT_BRANCH=master` there made `git push origin main` exit 0, and a trailing
`exit 0` line made `git push --force origin main`, `printenv` and `rm -rf ~` all exit 0. The
header's machine-mode note already says why that mode reads no such file: sourcing it "would
run another file's code". Nothing compares `DEFAULT_BRANCH` with the remote's default branch
(searched `scripts/` for `symbolic-ref` and `origin/HEAD`: fixtures only), so an adopter whose
default is not the configured name has both push rails guarding a branch that does not exist.

**DD-051** states the class — a rail that lives in a file needs the commands that remove the
file judged — and the incident it cites is an agent rewriting the Claude Code hook that guarded
it. The rail that row built covers `.git/hooks/pre-push` only.

### 3.9 The command push rail and refs nobody named

| Shape | Guard | git 2.43 dry run against a throwaway remote |
|---|---|---|
| `git push origin 'refs/heads/*:refs/heads/*'` | ALLOW | updates `refs/heads/main` and creates `session/x` |
| `git push -u origin session/x --tags` | ALLOW | pushes the branch and both local tags |
| `git push --follow-tags origin session/x` | ALLOW | pushes the branch and the annotated tag |
| `git push --prune origin 'refs/heads/session/*:refs/heads/session/*'` | ALLOW | not measured |
| `git push -u origin $(git branch --show-current)` | DENY, "leaves the ref implicit" | a false reason: the command names one |

The rail denies `--all` and `--mirror` because they push "refs you did not name". The pre-push
rail judges resolved refs and stops the default branch and every tag, where it is installed;
this gap is the command rail's alone.

### 3.10 List members

- **Readers.** `jq . ~/.docker/config.json`, `jq -r .auths …` and `yq . ~/.config/gh/hosts.yml`
  are ALLOW, where `cat` on the same files is DENY. On `.env`, `tac`, `rev`, `paste`,
  `hexdump -C`, `jq -R .`, `stat -c %s`, `vim`, `sha224sum`, `b2sum`,
  `git diff --no-index /dev/null`, `git show HEAD:`, `git add -f` and `openssl base64 -in` are
  ADV: the session one-shot and nothing after it.
- **Env-file names.** `cat .envrc`, `cat prod.env` and `head -3 config/secrets.env` are ADV.
- **Store names not in the cc-safety-net plan's table.** `cat ~/.my.cnf`,
  `cat "$APPDATA/GitHub CLI/hosts.yml"` and
  `cat "$APPDATA/gcloud/application_default_credentials.json"` are ALLOW.
- **Process environments.** `ps e` and `ps auxe` are ALLOW. procps-ng 4.0.4's help text gives
  bare `e` as "show the environment after command".
- **Data plane.** `psql -c "DROP TABLE users CASCADE"` and
  `psql -c "ALTER TABLE users DROP COLUMN email"` are ALLOW.

### 3.11 Machine mode

Machine mode keeps the permanent deletion denials and the credential block tier
(**DD-063**), so the gaps in those two reach every project on a machine that installs it.
Measured with `--machine --command`: `rm -rf ~` exits 2; `rm -r ~`, `cd ~ && rm -rf *`,
`echo "$DATABASE_URL"`, `jq . ~/.docker/config.json`, `cd ~/.aws && cat credentials` and
`cat <<< "$GITHUB_TOKEN"` all exit 0. Machine mode has no advisory tier, so the `cd` row is a
silent pass there, where project mode stops it once. Through the machine hook, `rm -rf ~`
followed by a comment holding a lone surrogate exits 0, and so does `rm -rf ~` under
`tool_name` `Monitor`.

### 3.12 Replay recipes for the multi-step rows

```bash
# 3.1 — in a mktemp tree: one bare remote, clones a and b. Copy scripts/command-guard.sh into
# a/scripts/ (chmod +x), write a/amh.conf with DEFAULT_BRANCH=main, and install the wrapper
# lines from scripts/session-start.sh as a/.git/hooks/pre-push. a pushes session/x; b fetches,
# commits, pushes; a commits WITHOUT fetching, then:
git -C a push --force origin session/x; echo "exit $?"
git -C remote.git log -1 --format=%s refs/heads/session/x

# 3.2 — a payload on stdin; the surrogate row:
printf '%s' '{"tool_name":"Bash","tool_input":{"command":"printenv # \ud83d"}}' |
	bash scripts/command-guard.sh; echo "exit $?"
# the no-python rows: PATH set to a directory of symlinks to everything in /usr/bin and /bin
# except python*, then the payload with "description":"command" ahead of "command".

# 3.4 — four calls, one state file:
for n in 1 2 3 4; do
	SUBAGENT_ADVISORY_STATE=/tmp/x/sub bash scripts/command-guard.sh --pre-task </dev/null
	echo "exit $?"
done

# 3.8 — copy scripts/command-guard.sh to D/scripts/, write D/amh.conf, then:
bash D/scripts/command-guard.sh --command 'git push origin main'; echo "exit $?"
```

## 4. The units

**Common rules for every code unit.** Each follows `docs/RUNBOOK.md` → **Change a shipped
script**: the template first, `bash -n`, copy down, `scripts/build-manifest.sh`; a `--self-test`
fixture shown to FAIL against the old script; the **Rule-review protocol** and the full
`scripts/ladder.sh`; a STATE Changelog line and checklist tick, and a ledger row for a durable
bug class or a rail change. Each unit also corrects the header bullet it makes false.

**A widening unit carries one more acceptance line,** by §2's item 3: what it newly refuses,
measured over ordinary commands and written in the commit body, with the near-misses that must
stay allowed pinned as fixtures.

**Machine mode.** Each unit states its effect on machine mode (**DD-063**). G3, G8, G12 and the
permanent-denial half of G9 reach it. G2, G5, G6, G7, G10 and G11 change rails it drops.

**Proposed order: G0 → G1 → G2 → G9 → G3 → G7 → G8 → G12 → G10 → G5 → G11 → G13 → G14 → G6**,
with G4 whenever a host observation is available. The order follows what is lost: G2 is the one
measured case here in which a rail allowed the loss of someone else's commits; G9 holds
`rm -r ~`; G3 is a payload no rail judges at all; G7, G8 and G12 are credential disclosure. The
units are numbered in the order they were written, not the order they run. G1 may change it.

### 4.1 Proposed

#### G0 — commit this plan (administrative; this session)

Commits this file, with an Owner-queue item to run G1 and a Changelog line. It is docs-only, so
its acceptance is `scripts/ladder.sh --guards-only`. It approves nothing. **Review owed:** none
of its own; G1 is its review.

#### G1 — review of this plan by gpt-6-astra at `-e high`

- **Give the reviewer:** this file, `scripts/command-guard.sh`, `scripts/session-start.sh`,
  both adapters, and the other plans in `docs/plans/`, so that it can test §1's "left out" list
  as well as §3.
- **Ask it for:** measurements that do not replay; gaps misclassed between defect and widening;
  a remedy that would newly refuse ordinary work, above all in the widening units, where that
  cost is now the only gate; a remedy that fails open somewhere new; units too large for one
  pass; duplication of another plan that §1 missed; anything §3 missed in the code this
  session did not read (§1).
- **The fold.** A session re-checks each finding against the tree before accepting it, applies
  what the mandate covers (§2, item 2), sends the rest to the Owner queue, and gives every
  finding a row. A finding is not accepted on the reviewer's word, as none of §6's were.
- **Acceptance (binary).** rev 2 is committed; every finding has a row; the G1 Owner-queue
  item has become "decide whether to adopt rev 2, and which units"; `--guards-only` passes.

#### G2 — the pre-push rail decides the unfetched-tip case, and does not depend on an execute bit (defect)

- **Ancestry.** When the remote tip is not in the object store and the repository is neither
  shallow nor a partial clone, the push is not a fast-forward: block it, and say to fetch and
  merge. A shallow or partial clone keeps today's open verdict, because there a missing object
  may be an ancestor. **Fork:** whether that residue should instead block with fetch advice.
- **Wrapper.** Test that the script exists, not that it is executable. **Fork:** what a
  missing script means. Today it is a silent pass, and a checkout of a revision that predates
  the script legitimately has none.
- **Upgrade path.** The bootstrap rewrites a hook that carries its own marker and differs from
  the current wrapper text, and never touches a foreign one.
- **Acceptance.** Both §3.1 rows end with the remote tip unchanged; a shallow-clone fixture
  and a plain fast-forward stay allowed; a marked old wrapper is replaced and a foreign hook is
  byte-identical afterwards.

#### G3 — the hook judges every shell payload it is handed, or says that it could not (defect)

This is the unit the Owner queue's parser item (**DD-069**) asks about, with what §3.2 adds.

- Read and write bytes in the parser, decoding as UTF-8 with replacement and encoding a lone
  surrogate the same way, so neither the host's code page nor the payload's escapes can raise.
- Give "not a shell payload" and "a shell payload I could not render" different exits. The
  second, and a `command` that is not a string, is an unjudged command. **Fork:** block it with
  the parse-defect reason the guard already uses for a command that yields no words
  (**DC-002**), or keep the header's fail-open rule for malformed input. Recommended: block.
  The payload's shape is the host's, not the agent's, and "nothing was judged" is the state
  that row exists for.
- In the fallback, find `"command"` as a key: followed by `:`, at the depth of `tool_input`.
- **Acceptance.** Every exit-0 row of §3.2 except the `Monitor` row becomes 2, in both modes,
  and the external review's example stays 2. The queue item gains the surrogate payload as its
  one-line check. Windows stays unobserved, and the commit says so.

#### G4 — the host's other shell-running tools (adapter; needs a host observation first)

- **Measure first, on a real host:** whether PreToolUse fires for `Monitor`, under what tool
  name, and with the command in which field; and whether the `Task` matcher fires for the
  spawn tool this host lists as `Agent`. One observation each, scoped to the host version.
- **Then:** widen both Claude fragments' matchers and `extract_command`'s name list together.
  `scripts/guards/adapter-set.sh` pins the matchers, so it moves in the same unit. The Codex
  adapter's tool surface is not inventoried here.
- If the host fires nothing for `Monitor`, this ends as a sentence in the header and in
  `AGENTS.md` → **Working guidance**, and still owes its pass (**Session discipline** 10).

#### G5 — the forge rail reads the spellings it already denies (defect), and its inventory (widening)

- **Defect half.** A leading slash on a `gh api` endpoint; the query string in the class match;
  `http://`. Acceptance: §3.3's first three rows are DENY, and the controls do not move.
- **Widening half, the owner's call, row by row:** merging a pull request and writing content
  to the default branch through the API; collaborator and branch-protection mutations through
  GraphQL; and the client's subcommands for classes the rail already denies. **Fork:** this
  tier blocks with no rerun, and the owner sometimes instructs a merge or a release, so either
  these get the one-time advisory instead, or the block reason says how an instructed one
  proceeds.

#### G6 — the subagent rail binds its advisory to a spawn (defect against the header's claim)

**Fork**, and the reason this is not one obvious fix: binding needs something that identifies a
spawn, and the rail deliberately reads no payload field. Options: (a) key on a digest of the
spawn's own input, read through the parser the hook already has, giving up that neutrality for
the one field; (b) keep the toggle and correct the header to say that one advisory can be
cleared by a different spawn; (c) hold a spawn that arrives while another's advisory is
outstanding. Acceptance for (a) or (c): two different spawns interleaved are each refused once.

#### G7 — the `.env` and key advisories: what spends them, and when they rearm (defect against **DB-030**)

- **Match.** `.env` as a path component, not as a substring of an identifier, so that
  `process.env` and `os.environ` stop spending it. The cost is stated: `prod.env` then misses
  this tier unless the pattern is written to keep it.
- **Rearm.** Per command-text digest, as the interpreter and hook-file tiers do, re-firing
  where no digest tool exists (**DD-071**).
- **Measure first:** the advisory rate of the candidate pattern over a corpus of ordinary
  commands from a JavaScript and a Python repository. A per-text key over today's pattern would
  stop every distinct command that mentions `process.env`, which is the alarm that cries wolf.
  The corpus does not come from logging live sessions (the cc-safety-net plan's §5 says why).
- **Acceptance.** Both §3.5 sequences end in a refusal of the `.env` read; the corpus rate is
  in the commit body.

#### G8 — secret values: names, and readers fed a here-string (rule widening)

- **Names,** each with clean near-misses in the fixture, since a tail of `url` alone would
  refuse `$BASE_URL`: connection strings by their qualifier (`DATABASE_URL`, `DB_URL`,
  `REDIS_URL`, `*_DSN`, `CONNECTION_STRING`); components that end in `PASSWORD`; `_PWD`,
  `_PASS`, `PASSPHRASE`, `_PAT`, `APIKEY`; plurals; `SECRET_KEY_BASE`. Near-misses that must
  stay allowed: `$PWD`, `$OLDPWD`, `$BASE_URL`, `$BYPASS`, `$COMPASS`.
- **Here-strings,** for the reader commands only. `gh auth login --with-token <<< "$TOKEN"`
  and `docker login --password-stdin <<< "$PASS"` are the correct way to hand over a secret and
  must stay allowed.
- **Not in this unit:** tracing and verbose flags (G14).

#### G9 — the deletion rail: `rm -r`, a `cd` in the same command, and two list defects

- **`rm -r` without `-f`.** **Fork:** judge it against the permanent target list only, or
  give it the ordinary advisory as well. Recommended: both. Agents almost always write
  `-rf`, so the added prompts are few. The permanent half reaches machine mode.
- **Placement under `cd`.** When a `cd` or `pushd` with a literal operand precedes the verb in
  the same `&&` or `;` list, judge a relative operand where it lands, as `-C` is judged. A `cd`
  whose operand is an unquoted variable sets the unexpanded-variable paragraph. The same
  placement serves the credential-store names. Only for a `cd` the walk can read: a variable's
  value, a `cd` in an earlier command, and a subshell stay unknown.
  **This reopens something another plan declined.** The cc-safety-net plan's §5 declines
  "Expanding literal variables, `for` lists and `cd` operands" as evasion shapes, to reopen on
  an incident. The literal `cd` is taken out of that list here on two grounds: `cd ~ && rm -rf *`
  is a mistake's spelling, not an evasion's, and §2's item 3 removes the incident condition.
  Variables and `for` lists stay where that plan left them. **Fork:** the owner's.
- **`git_place_join`** treats a drive-letter path and a leading `\\` as anchored.
- **Interpreter names** fold a trailing version (`python3.12`); `pypy3` and a runner prefix
  such as `uv run` are separate list members and are the owner's call.
- **Acceptance.** §3.7's rows reach their control's verdict, except the rows left to a fork;
  the two `rm` rows of §3.11 exit 2.

#### G10 — the guard's own files (the **DD-051** class)

The cc-safety-net plan's §5 says the narrow self-protection AMH needs "exists already", naming
the hook-file deny rail and the adapter pins. §3.8 measures where that does not reach.

- The hook-file advisory also fires for `rm`, `mv` and `chmod` naming the guard script.
- The guard reads the two keys it needs from `amh.conf` and no longer sources the file, so a
  stray statement there cannot end the guard. The file stays the adopter's, and the other
  scripts are untouched.
- The session banner reports `DEFAULT_BRANCH` against the remote's default branch when a local
  ref records one, as present, differs, or could-not-ask. A report, not a gate.
- **Fork:** whether the Claude adapter also denies the editing tools on the guard script, as it
  does for `.git/hooks/`. In this repository the playbook already forbids editing the local
  copy.
- **Acceptance.** §3.8's `chmod`, `rm` and `mv` rows are ADV; the two `amh.conf` rows on a copy
  end in the default-branch verdict; the adapter rows are unchanged unless the fork says
  otherwise.

#### G11 — the command push rail and refs nobody named (rule widening, small)

- A refspec holding a glob, `--tags` and `--follow-tags` are denied with the reason `--all`
  already gives. `--prune` is measured against git first.
- An unquoted `$(…)` in the ref position gets a reason that is true of it.
- **Acceptance.** §3.9's rows; `git push -u origin session/x` stays allowed.

#### G12 — reader and env-file lists (rule widening)

- **Readers.** `jq` and `yq` first: the store list protects JSON and YAML files, and these are
  the tools that read them. Then the plain readers of §3.10 (`tac`, `rev`, `paste`, `hexdump`,
  `sha224sum`, `b2sum`), which cost nothing on any other operand. `stat`, an editor and the
  `git` subcommands each get their own line in the unit, because each has an ordinary use on a
  secret file's NAME that prints no value. **Fork:** which of those the owner wants. Programs
  that send a file elsewhere are N3's.
- **Env-file names.** `.envrc`, and a `*.env` suffix. The suffix is the costly one and is
  measured before it is proposed.
- **Store names go to N4, not here.** Its vendor-source table is where a store earns its
  place. This plan hands it three candidates it does not list: `~/.my.cnf`, and the Windows
  locations the external review reports for `gh` and `gcloud` (§6, finding 2C).
- **Acceptance.** §3.10's reader and env-file rows are DENY, in both modes; the precision line
  of §4's opening.

#### G13 — `DROP TABLE` in the `psql -c` arm (rule widening)

`DROP TABLE` and `ALTER TABLE … DROP COLUMN` join the three verbs the arm reads.

- **Measure first:** how often each appears in ordinary migration work, since a verb that
  fires on routine use teaches an agent to skim the advisory that also guards `rm -rf`.
- The header's sentence that this tier admits a verb on a public report changes with the
  unit, under §2's item 3.
- The git verbs a review raised here (`git branch -D`, `git stash clear`) are the
  cc-safety-net plan's N9, and `git clean -f` without `-d` is in its not-taken list (§5).

#### G14 — process environments and traced secrets (rule widening)

- **`ps`.** The option grammar per platform comes first. On Linux `-e` selects every process
  and only the bare `e` shows environments (procps-ng's help text); macOS and BSD were not
  measured. A rule that reads `e` in any cluster refuses `ps -ef`.
- **Tracing and verbose flags beside a credential-shaped expansion** (`set -x`, `bash -x`,
  `curl -v`). **Measure first:** how often `set -x` shares a command with such an expansion in
  ordinary work, and whether an advisory or a denial fits.

### 4.2 Deferred, with its prerequisite

- **Forge hosts beyond the four listed** (GitHub Enterprise, self-hosted GitLab, `glab`).
  Prerequisite: a way to name an adopter's forge host, which is a configuration key and so an
  extension-point change (`AGENTS.md` → **Working guidance**).

## 5. Raised by a review, and already carried elsewhere

| Raised | Where it lives | Note |
|---|---|---|
| Options on `sudo`, `nice`, `time` defeat every rail (external review 1A) | spill-guard plan, S6a | measured there; the Owner queue carries its check |
| `timeout`, `stdbuf`, `setsid` | spill-guard plan, S6b | — |
| `.pgpass`, `.pypirc`, the coding CLIs' own credential files (external review 2C, in part) | cc-safety-net plan, N4 | re-measured ALLOW here |
| `curl -F f=@.env`, `scp .env host:` | cc-safety-net plan, N3 | re-measured ADV here: the session one-shot only |
| `git branch -D`, `git stash clear` (external review 3C) | cc-safety-net plan, N9, deferred on the incident bar | §2's item 3 bears on that deferral; moving it is the owner's call |
| `git clean -f` without `-d` | cc-safety-net plan §5, not taken | `git clean -fx` and `-fX` re-measured ALLOW |
| The payload parser on a non-UTF-8 code page | Owner queue (**DD-069**) | G3 is the unit for it |
| PowerShell's own readers, `Get-Content .env` (external review 2E) | the guard's header, POWERSHELL bullet | re-measured: `Get-Content .env` is ADV, `Get-Content ~/.aws/credentials` is ALLOW. A named miss; no unit proposed |
| A glob in a secret-file operand | spill-guard plan §5, not planned | one data point for whoever reopens it: `cat .env.*` is DENY and `cat .env*` is ADV |
| State files outliving a session (external review 4B) | `scripts/session-start.sh` rearms them at every start; `AGENTS.md` step 1 covers a host with no start hook | a session identifier is the **DA-022** non-item; G7's per-text key makes the question moot for those tiers |
| A deletion in a `trap` string; a `$(…)` in an unquoted heredoc body | the header: shell strings, heredoc bodies | measured ALLOW; named classes |
| A quote inside backticks | Owner queue | — |
| Containment by the host's sandbox | research-gaps plan, H4a and H4b | — |

## 6. The external review, finding by finding

| Finding | Re-checked | Outcome |
|---|---|---|
| 1A wrapper options | already measured by the spill-guard plan | §5 |
| 1B `jq`, `yq` | reproduced: ALLOW on two stores, where `cat` is DENY | G12 |
| 1C fallback decoder | **the example as given does not reproduce** (exit 2: a description holding the word is not the quoted key). A narrower form does: a value that is exactly `command`, or a nested key | G3 |
| 1D `git_place_join` and a drive path | reproduced, only behind a second place option | G9 |
| 2A connection-string names | reproduced | G8; the remedy is narrowed, because a bare `url` tail refuses `$BASE_URL` |
| 2B `ps` | `ps e` and `ps auxe` reproduced as ALLOW. **The remedy is wrong on Linux**: `-e` selects every process, so reading `e` in any cluster refuses `ps -ef`. `ps -efE` was not verified | G14 |
| 2C `.envrc`, `.pgpass`, `.pypirc`, Windows paths | reproduced as verdicts. That `gh` and `gcloud` keep those files under `%APPDATA%` is the review's report, not verified here | `.envrc`: G12. The stores: N4 (§5) |
| 2D `cd` into the store's directory | reproduced | G9 |
| 2E PowerShell readers | reproduced | §5 |
| 3A `DROP TABLE` | reproduced | G13 |
| 3B versioned interpreters | reproduced | G9 |
| 3C `git branch -D` | reproduced | §5: N9 |
| 4A the spawn race | the toggle reproduced sequentially (2, 0, 2, 0). A concurrent order was not observed on a host | G6 |
| 4B state lifetime | read, not run: the bootstrap deletes the state at every start | §5 |

The review's summary table repeats these. Its severity labels were not adopted; §4's order is
this plan's own.

## 7. Not verified

- **G1 has not happened.** Nothing here has had a second reader.
- This session did not read the heredoc walker, the `cmd.exe` and PowerShell arms, or the
  self-test (§1). Whether a fixture already pins any §3 row was not checked; each unit checks
  its own.
- No Windows or macOS host was observed. `rm -r` was measured with GNU coreutils only; `ps`
  with procps-ng's help text only.
- Whether the host fires PreToolUse for `Monitor`, and whether the `Task` matcher fires for the
  tool this host lists as `Agent` (G4). Whether the PreToolUse guard fired at all in this
  session was not observed either.
- What Codex does when its hook's script is missing, how its payload presents a command, and
  its tool surface.
- The order in which a host runs hooks for tool calls issued in one turn (G6).
- `git push --prune` with a glob refspec, against git itself (G11).
- No corpus of ordinary commands was run for any widening unit; each precision line in §4 is
  owed at unit start. No search for public incidents was made either; under §2's item 3 none
  is required.
- Every remedy in §4 is a design, not a measurement of new code.
