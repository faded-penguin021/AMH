# RUNBOOK — maintenance playbook

Entry point for changing this repository. Pick the playbook matching your task, read what it
names, then do the work. **Code + the guard fixture suite are ground truth** for what the
system does; where descriptive prose disagrees with the code, trust the code and fix the prose
— never a binding rule, which the code does not settle (see the constitution's ground-truth
note) — and never the append-only ledger, whose rows are never edited in place: a correction is
a new row plus one appended pointer on the old one (see any volume preamble for the two verbs).
Syncing a row's ` [cited]` marker is the one in-place edit that rule does not cover.

The procedures every session is bound by — **Session discipline**, the **Adversarial review
protocol**, the **Rule-review protocol**, **Incident: leaked credential**, the **Acceptance
ladder** and **Working-memory compression** — are in `docs/PROTOCOLS.md`, and where this file
names one of them by its heading alone, that is the file it means.

## Where logic lives

| Path | What it is | The invariant that protects it |
|---|---|---|
| `harness/src/*.md` | the harness's prose, in ordered parts | hand-edited; the only source for `dist/` |
| `harness/templates/scripts/*.sh` | the shipped scripts | repo-agnostic; parameter-free (D-002, D-003) |
| `harness/templates/seed/**` | prose scaffolds for adopters | copied once, then owned by the adopter; never drift-checked |
| `harness/templates/configs/**` | JSON/YAML for adopters | carries `{{PLACEHOLDER}}`s; substituted at init — except `claude-machine-settings.json`, the user-level machine-mode fragment, which carries none, is merged only on the owner's yes and never by the installer; `scripts/guards/adapter-set.sh` pins its hook and its credential rails |
| `harness/templates/scripts/MANIFEST.sha256` | hashes of the shipped scripts, installed beside them | **generated** — rebuilt and diffed by a guard |
| `harness/dist/AMH.md` | the single-file bundle | **generated** — rebuilt and diffed by a guard |
| `harness/VERSION` | the harness version | single source; lockstep-checked |
| `scripts/*.sh` (five) + `scripts/MANIFEST.sha256` | this repo's instance of the shipped files | byte-identical copies (D-002) |
| `scripts/verify.sh`, `scripts/guards/*`, `scripts/tests/*` | this repo's local verification | the ladder's only two extension points; `tests/` hangs off `verify.sh` |
| `scripts/amh-init.sh`, `scripts/build-dist.sh`, `scripts/build-manifest.sh` | repo-local tooling: instantiate an adopter, generate the bundle, generate the integrity manifest | not shipped — they run FROM here, never inside an adopting repo |
| `conformance/` | behavioural scenarios for the prose rules no guard can reach | repo-local, never installed; evaluators compute their own evidence |
| `docs/PROTOCOLS.md` | the procedures every session is bound by | legislation: changes only under its rule-review protocol; the constitution's pointers into it are guarded |
| `docs/STATE.md` | working memory | capped, compressible, Owner queue protected |
| `docs/LEDGER.md` | permanent memory | append-only; never rewritten |

## Reference-doc index

| Question | Doc |
|---|---|
| What binds me this session? | `AGENTS.md`, and the procedures in `docs/PROTOCOLS.md` |
| Why does mechanism X exist? | `harness/src/10-principles.md` |
| What is pending for the owner? | `docs/STATE.md` → Owner queue |
| Why was Y decided/rejected? | `docs/LEDGER.md`; `docs/STATE.md` → Decided non-items |
| How do I compress `docs/STATE.md`? | `docs/PROTOCOLS.md` → **Working-memory compression** |
| How does an adopter move to a new version? | `docs/UPGRADING.md` |
| What changed between versions? | `harness/CHANGELOG.md` |
| How do I contribute a harness change? | `CONTRIBUTING.md` |

## Efficient document retrieval

Keep context relevant by locating before loading. For a large structured document, list its
headings or search for the exact identifier, then print only the matching section; widen the
read when that section names prerequisites, rules may interact across sections, or the excerpt
is ambiguous. This is an outcome rule, not a command ritual: native range-reading tools are
equally valid. The entry constitution and `docs/STATE.md` are read in full at session start,
and any playbook instruction to read a file in full overrides this optimization.

Portable examples (headings and ledger identifiers are stable navigation keys; stored line
numbers are not):

```bash
grep -nE '^#{1,3} ' docs/RUNBOOK.md
awk '/^## Rule-review protocol/{p=1} p && /^## / && !/^## Rule-review protocol/{exit} p' docs/PROTOCOLS.md
grep -nF 'DA-016:' docs/LEDGER_A.md
```

The documentation-navigation guard checks that every runbook or protocols section named by the
entry constitution exists exactly once, in the file its pointer names and not in the other. It cannot prove what an agent read, and no attestation or
shell history may be used as evidence that this procedure was followed (DA-017).

## Change-type playbooks

Each: *when · read first · what to touch · obligations · acceptance · record it.* That is the
order to READ them in. In execution the record — the STATE changelog line, a ledger row — is
written before the acceptance run, so the ladder verifies the tree that is committed
(**Session discipline** 3).

### 1. Change or add a harness principle

- **When:** the harness's *logic* changes — a new principle, a revised one, a retired one.
- **Read first:** `harness/src/10-principles.md` in full, plus `docs/STATE.md` → Decided
  non-items (the idea may already have been declined) and `CONTRIBUTING.md` → version
  semantics.
- **Touch:** `harness/src/10-principles.md`; the constitution template
  (`harness/templates/seed/AGENTS.md`) if the principle changes what an adopting repo must
  do; `harness/CHANGELOG.md`; `harness/VERSION` if the release warrants a bump.
- **Obligations:** every principle must justify itself against P0 in one sentence — more
  shipped correctness, or less owner attention per change. A principle that satisfies
  neither is ceremony no matter how sophisticated it sounds. Rebuild the bundle
  (`scripts/build-dist.sh`). **Rule-review protocol applies.**
- **Acceptance:** `scripts/ladder.sh` green (dist-drift and version-lockstep guards included).
- **Record:** STATE changelog line; a concise ledger row if the change encodes a durable
  lesson. Record that lesson, not the whole debugging narrative; archive a larger narrative
  under `docs/history/` and point to it from the `docs/STATE.md` changelog.

### 2. Change a shipped script

- **When:** a guard, rail or the bootstrap needs different behaviour.
- **Read first:** the script itself, and its fixtures in `scripts/test-ladder-guards.sh` or
  its `--self-test` matrix.
- **Touch:** `harness/templates/scripts/<name>.sh` — **the template is the original**. Then
  copy it into `scripts/`. Never edit `scripts/<name>.sh` directly; `copy-drift.sh` will
  fail, and the fix is always in the same direction (D-002).
- **Obligations:** the script must stay repo-agnostic. Needing a repo-specific branch means
  an extension point is missing — add the extension point instead (D-003). **Never cite a
  ledger row by its real id in anything shipped** — not the rails, not the seed scripts, not
  the CI workflow — because our rows cannot exist in an adopter's ledger; name it `AMH ledger
  row DBNNN` without the hyphen. `shipped-citations.sh` fails on the hyphenated form, scoped by
  where a file is installed rather than by its extension. New behaviour
  lands with its fixture in the same change. **Run `scripts/build-manifest.sh` in the same
  change**: the shipped scripts' hashes ship with them, and `manifest-drift.sh` fails on a
  manifest that describes bytes nobody has. **Rule-review protocol applies** (guard
  semantics are legislation). **Run `bash -n` on the template before copying it down**: the
  command guard is this harness's own pre-execution hook, so an unparseable copy in `scripts/`
  refuses the next Bash call — including the one that would repair it — and the way out is an
  editor path that does not go through the hook (**DD-021**). Since the Claude adapter's
  `PreToolUse` hooks refuse the call on failure, the same holds for ANY crash of that copy, not
  just a syntax error — an unbound variable under `set -u` exits 1 and refuses every Bash call.
  The way out is unchanged: with the editor, write `scripts/command-guard.sh` back to its last
  committed bytes (restoring the byte-identical copy is not patching it), and then fix the
  template. Never remove the hook or its `onFailure` to get a shell back (**DD-040**).
- **Acceptance:** `scripts/ladder.sh` green, including the fixture suite and both rail
  self-tests; the new fixture must FAIL against the old script — check by stashing the
  behaviour change, or the fixture proves nothing. For a defect fix, the fixture is also
  written and seen failing BEFORE the fix (**Session discipline** 13); that is a second
  demonstration and does not replace this one.
- **Record:** STATE changelog line; a concise ledger row for any durable bug class the change
  fixes, not its whole debugging narrative. Archive a larger narrative under `docs/history/`
  and point to it from the `docs/STATE.md` changelog.

### 3. Add a guard

- **When:** a rule has actually been violated. Not before — guards accrete one at a time,
  each earning its place after a real incident. Speculative guards are how a harness turns
  into ceremony (P3, P20). **The command guard is the one exception** (P13, **DD-074**): a
  shape that `command-guard.sh` misses, in any of its modes, is closed without waiting for the
  loss, as a defect fixed like a bug or as a widening gated by a measurement of what ordinary
  work it would newly refuse. That work follows **Change a shipped script**, not this playbook;
  this exception does not reach any other rail.
- **Read first:** `scripts/ladder.sh`'s guard section for the house style.
- **Touch:** a repo-specific guard goes in `scripts/guards/<name>.sh`. Three verdicts: exit 0
  passes, exit 2 whose MERGED output (stdout and stderr together, which is what the ladder
  captures) begins `WARN ` warns without turning the run red, any other non-zero fails. The
  warn line is the guard's first line; later lines are indented under it. That contract is the
  ladder's — a workflow invoking a guard directly, as the release job does, sees any non-zero
  as a failure. Its fixture goes in `scripts/tests/local-guards.sh`. A guard
  every adopter needs goes in the shipped `harness/templates/scripts/ladder.sh` with its
  fixture in `harness/templates/scripts/test-ladder-guards.sh`, both then copied into
  `scripts/`. Do not cross the streams: a repo-local fixture in the shipped suite breaks
  `copy-drift.sh`, and it should — that file is a repo-agnostic artifact.
- **Obligations:** the guard must check an artifact the work produces anyway — a file size, a
  diff, a commit message, a citation. If a rule cannot be derived from a real artifact it
  stays prose plus reviewer attention; never make a gate out of something the agent
  self-reports (D-014).
- **Acceptance:** ladder green; the new fixture demonstrably fails without the guard.
  Demonstrate it by removing the *behaviour* — stash the diff, or delete the added lines —
  and re-running the suite. Deleting the guard FILE proves only that the file must exist:
  every fixture then dies at exit 127, including one that never checked anything.
  **The demonstration is the suite, never the real operation.** Removing a guard and then
  performing the thing it guards against — against the working tree, a home directory, a live
  database — is not a stronger form of this check; it is the incident the guard was being
  written to prevent, and a public report of exactly that sequence is what put the rule in
  `AGENTS.md` → **Hard boundaries**. Where the behaviour can only be observed by executing
  something destructive, execute it against a tree the fixture made (`mktemp -d`, a fixture
  directory) and assert on what is left there.
  Know what this acceptance does not reach: these are bash fixtures exercising bash guards
  in the same interpreter, so a defect in an assumption they share is invisible to them —
  quoting, locale, `set -u` behaviour, a stubbed tool that silently returns success. Making
  the fixture fail against the old script is the mitigation, not a proof of correctness, and
  it is why guards that can go hollow (a missing tool, an extraction that yields nothing)
  carry an explicit checked-NOTHING branch instead of trusting the comparison to be loud.
- **Record:** STATE changelog line; a concise ledger row naming the incident and durable
  lesson that earned the guard, not the whole debugging narrative. Archive a larger narrative
  under `docs/history/` and point to it from the `docs/STATE.md` changelog.

### 4. Change a seed template

- **When:** the scaffold an adopting repo starts from should change — and whenever a unit changes
  a rule in `AGENTS.md`, `docs/PROTOCOLS.md` or this runbook that the seed restates. Seeds are never drift-checked, so
  search `harness/templates/seed/` for the same sentence in the same change; a correction made
  here alone reaches no adopter (**DD-028**).
- **Read first:** `harness/templates/seed/` and `harness/PLACEHOLDERS.md`.
- **Touch:** the seed file; `harness/PLACEHOLDERS.md` if placeholders changed; the changelog.
- **Obligations:** seeds are *starting points*, not upgradeable artifacts — an adopter owns
  their copy and will never re-sync it. So a seed change reaches existing adopters only as a
  hand-applied note: write it in the **Upgrading** subsection of this version's
  `harness/CHANGELOG.md` entry, naming the seed file to copy the wording from.
  `docs/UPGRADING.md` is the version-agnostic procedure and routes adopters to those entries —
  it does not carry per-version notes, so it usually needs no edit. Every `{{PLACEHOLDER}}`
  must be documented, or the placeholder-integrity guard fails.
- **Acceptance:** ladder green.
- **Record:** STATE changelog line; CHANGELOG entry under the next version.

### 5. Cut a harness release

- **When:** the owner asks. Version semantics are in `CONTRIBUTING.md`; an ambiguous
  major-vs-minor call is an Owner-queue question, not an agent's judgement call.
- **The number is one bump above the LATEST TAG, and it is settled at PR time** (owner,
  2026-08-27). Keep writing a version as you work — that half is unchanged — but the number that
  ships is decided against `git tag -l` when the PR goes up, not accumulated per unit: four
  numbers once rode inside the 10.2.0 train and only the head one was ever tagged (**DC-023**).
  CI's `pull_request` event runs `scripts/guards/version-lockstep.sh --against-latest-tag`, which
  fails unless `harness/VERSION` is exactly the MAJOR, MINOR or PATCH successor of the newest
  `amh-v` tag. If a merged release was never tagged, that check compares against a stale tag and
  reddens a legitimate number — its message says so; tag the predecessor rather than moving the
  number to satisfy it.
- **A ledger row says what the session DRAFTED, never what shipped** (owner, 2026-08-27, closing
  the prose half of **DC-023**). Write the number as drafted — `Drafted as MINOR X.Y.Z` — and
  assert no release: "shipped", "published" and "released" are one claim, and only a tag settles
  it. A *later* row may name the tag once it exists; what a train actually published is in the
  `docs/STATE.md` changelog's train lines. The habit this replaces was not a style preference:
  committed rows say `Shipped as` for numbers `git ls-remote --tags origin` does not carry — ask
  the remote, never `git tag -l`, because a session clone routinely holds no tags (**DA-002**) —
  so a number written mid-train was reported as a published release (**DC-026**). Those rows keep
  their wording and were deliberately left without a `Corrected by` pointer, so read the number in
  one as the draft it was. **Prose-only, unlike the bullet above:** nothing checks a version claim
  inside a row, and at the moment one is written the tag that would falsify it does not exist yet.
- **Steps:** update `harness/VERSION` → add the `harness/CHANGELOG.md` entry, including its
  **Upgrading** subsection (what an adopter must actually do) → update the version recorded
  in `AGENTS.md`, `docs/STATE.md` and `amh.conf` → **update the release tag in the `README.md`
  Quick Start's clone command** → `scripts/build-dist.sh` → **`scripts/build-manifest.sh`** →
  ladder.
- **Obligations:** `scripts/guards/version-lockstep.sh` binds `harness/VERSION` to five
  hand-written copies — the changelog's top entry, `AGENTS.md`, `docs/STATE.md`,
  `AMH_VERSION` in `amh.conf`, and the `README.md` Quick Start's tag. Never edit one alone.
  The README copy is the one this list forgot once: the guard went red at the end of a
  release with nothing in these steps telling the releaser which file to touch. **The manifest
  is the second**, found the same way in 2.1.0 — `MANIFEST.sha256`'s header carries the version,
  so a bump makes it stale even though no shipped script changed, and `manifest-drift.sh`
  reports it as a script edited without its manifest. Neither copy is lockstep-checked: they are
  generated, so the rebuild steps above are what keep them true. The bundle header is generated from
  `harness/VERSION`, so `dist-drift.sh` covers it and the lockstep guard deliberately does
  not. **Tagging and publishing are owner steps** — queue them, do not attempt them.
- **Acceptance:** ladder green.
- **Record:** STATE changelog line; Owner-queue item for the tag.

### 6. Docs-only change

- `scripts/ladder.sh --guards-only` is the acceptance gate (seconds). If the change touches
  `harness/src/`, rebuild the bundle first — otherwise the dist-drift guard fails, correctly.
- That gate is the acceptance check only. A unit planned or asked as a code or rule change that
  ends docs-only still owes the review of that change (**Session discipline** 10).

### 7. Add or change a conformance scenario

- **When:** a *prose* rule needs testing — one no guard can reach, because reaching it would
  mean consuming the session's own account of what it did. Not for anything a guard can
  check: a scenario costs a model run, a guard costs milliseconds.
- **Read first:** `conformance/README.md` in full, and the ledger rows the scenario claims as
  its provenance.
- **Touch:** `conformance/scenarios/<name>/` (a `fixture.sh` that builds the disposable repo
  at runtime and prints its baseline commit, plus the `task.md` handed to the subject),
  `conformance/evaluators/<name>.sh`, and `conformance/selftest.sh`, which the acceptance
  rule below requires cases in. The runner is shared and should not need changing; if it
  does, keep it one concrete runner rather than growing the abstraction that was refused.
- **Obligations:** the scenario is seeded on a named ledger row recording a real failure
  here — a hypothetical one is what the incident bar exists to stop, and three of RFC3's
  seven died on exactly that, with two more failing provenance in their own ways: one runs
  inverse to the instance it cites, and one lost its subject entirely (**DA-026**(b)). The
  three are not one class, and flattening them is how a checklist starts overstating its
  own provenance. The evaluator computes every fact in its own
  process and never reads the subject's account of its own behaviour. Every absence
  assertion is paired with the presence check that keeps it from passing over nothing.
  INCONCLUSIVE comes only from a trigger enumerated in the evaluator's header; everything
  else is FAIL. Fixtures are generated, never stored.
- **Acceptance:** `conformance/selftest.sh` green, with the new evaluator exercised in BOTH
  directions — a compliant tree passes, and each mutation it claims to detect fails *naming
  the reason*. Then demonstrate the other direction the same way guards are demonstrated:
  break the evaluator, watch the suite go red, restore it. Those two rules are orthogonal —
  one mutates the subject, one mutates the checker — and neither implies the other.
- **Record:** STATE changelog line; a concise ledger row for the durable lesson the scenario
  taught, not the whole debugging narrative. Archive a larger narrative under `docs/history/`
  and point to it from the `docs/STATE.md` changelog.
- **What a green run does NOT say:** anything about how an agent behaves. Until a scenario
  has been run against a real agent it has demonstrated only that its evaluator is
  deterministic. Any release claim that mentions the lab carries that sentence.

## Host rails and what they miss

Read this before you count on a rail to stop a command, before your first push of a session,
before your first bulk deletion of a session, when a hook or the host refuses a call, before your
first command through a PowerShell tool, before you change an adapter, a hook or a guard, and at
the start of a session on Windows or one started with a flag that changes which settings or hooks
the host loads (`AGENTS.md` → **Working guidance** and **Hard boundaries**). It says what the rails cover and miss; it relaxes no rule in `AGENTS.md`.

**The command rail.** An agent whose harness provides no pre-execution hook runs with **no
command rail at all** — `scripts/command-guard.sh` is then a script nobody calls, and the written
rules are the only layer. The one exception is the push: the git-native `pre-push` rail
(`command-guard.sh --pre-push`, installed into `.git/hooks/pre-push` by `session-start.sh`) is
invoked by git rather than by the agent, so it still guards the publication invariants for a
hook-less agent — a guardrail `--no-verify` bypasses, not a boundary. It exists only where
installed: `session-start.sh` never overwrites a foreign pre-push hook or writes one under
`core.hooksPath`, and a fresh clone has none until that script runs. It judges refs, never a
commit message or an identity.

**Host modes and machine mode.** A host mode can take the hooks away for one session, and no AMH
script checks for that either: Claude Code's `--safe-mode` and `--bare` skip the hooks its
settings files define, and the CLAUDE.md that points at `AGENTS.md`, and `--restricted` ignores the
project's settings file unless it is passed again with `--settings`, so a session started in any
of them has no command rail, no output redaction and no session bootstrap, whatever
`.claude/settings.json` says (**DD-053**). A machine-mode copy of the guard
(`command-guard.sh --machine`, wired from a user-level settings file) may also judge your
commands. It keeps only the permanent deletion denials, the credential rails and its refusals of
a command it could not read, names itself in the first line of its refusal, and stands in for
none of this repository's rails. Nothing here can see whether one is installed, and the host
modes above skip it too (**DD-063**).

**PowerShell, and the Claude adapter's hooks.** Where a host routes shell commands through a
PowerShell tool, the command rail exists only if the adapter's matcher names that tool and the
hook's own shell (bash) is present; the Claude adapter's matcher does, and PowerShell text then
goes to the guard's PowerShell reader, a shorter list than the bash one, whose misses the guard's
header names (**DD-039**). The Claude adapter anchors every hook at the project root and, on
Claude Code 2.1.295 or later (an older build fails open as before), sets both PreToolUse hooks to
refuse the call when the hook itself fails, so a guard that crashes, times out or cannot start
blocks the call instead of letting it run (**DD-040**). On Windows that makes Git for Windows a
hard requirement: without Git Bash every shell call and spawn is refused, and AMH is not usable.

**The command guard's deletion rails.** `scripts/command-guard.sh` holds a literal TARGET list
for four commands — an `rm -r -f`, a `git clean -f -d`, a `cmd /c` `rd /s` or `del /s`, or a
PowerShell `Remove-Item -Recurse` (any alias), naming the filesystem root, a Windows drive root or
a home directory, is blocked and does not clear on a rerun; a `cmd /c` recursive deletion whose
text carries `\"` nested quotes is blocked the same way, whatever its path — and the git verbs
armed only on an unknown target are silent on a literal path, except behind `xargs`, which adds
operands of its own. An INLINE interpreter deletion (`python3 -c` naming `rmtree`, `unlink` and
the rest of that list) buys one advisory a rerun clears, on the evidence of a word in a command
line and never a reading of the program (**DD-019**).

**The Gemini CLI adapter**, written against the Gemini CLI v0.70.0 documentation as retrieved on
2026-11-23. Nothing in it has been observed firing (**DD-111**, **DD-112**).
Its settings file carries no comment, so the adapter's host-rails skill carries a summary of it.

- *Rails it has*, all in `.gemini/settings.json`. A `BeforeTool` hook on `run_shell_command` runs
  the command guard, which refuses by exit 2, reading the command as PowerShell only under a
  Windows `uname`. An `AfterTool` hook on every tool runs `scripts/redact-tool-output.sh`, which,
  when it redacted a leaf, answers `deny` with the filtered text: the host documents that answer
  as replacing the result the model reads. A `SessionStart` hook runs the bootstrap, which
  installs the `pre-push` rail and resets the guard's advisory state. The `pre-push` rail is
  invoked by git, not by the host, so once installed it holds when every hook here is off, and
  `git push --no-verify` bypasses it; a fresh clone opened in an untrusted folder has none until
  `scripts/session-start.sh` has run.
- *What it lacks, and what then binds only as prose.* No file deny rules: the host's workspace
  policy tier is documented as non-functional and `tools.exclude` as deprecated, so a
  `write_file` or `replace` on `.git/hooks/**` and a `read_file` or `read_many_files` of a secret
  file are stopped by nothing but the written rules. The command guard judges `run_shell_command`
  alone, and the redactor scrubbing the shapes it knows out of a read's result is not a refusal
  to read. The redactor has the Claude adapter's bounds: the value was already produced, only
  what the model reads changes, it catches the shapes `scripts/redact.sh` enumerates, and it
  stands down where no Python 3 runs. The host's hook contract is fail-open, and nothing
  like Claude Code's `onFailure` is documented: a hook that exits with anything but 0 or 2 lets
  the call run unchanged, so a guard that crashes, or whose `bash` is missing on Windows, judges
  nothing and refuses nothing. No sandbox: the host's is off by default and the adapter turns
  none on. The spawn speed bump is not wired.
- *What skips it.* In an untrusted folder the host ignores `.gemini/settings.json` whole, and
  with it every hook and the `context.fileName` setting that loads `AGENTS.md`. Such a session
  has no command rail, no redaction, no bootstrap and no constitution unless it is told to read
  `AGENTS.md`. `--skip-trust` or `GEMINI_CLI_TRUST_WORKSPACE=true` trusts the folder for one
  session. `hooksConfig.enabled: false`, which the shipped file leaves unset so that a user or
  system settings file can set it, or `/hooks disable-all`, turns every hook off. A new or changed project hook is warned about before it runs.
  `--approval-mode=yolo` approves every call.
- *Procedure, not rails.* Four skills under `.gemini/skills/`, each naming one binding section,
  whose body loads only when the model activates it and the user consents, and the read-only
  reviewer `.gemini/agents/amh-rule-reviewer.md`, whose tool list holds no shell and no write
  tool. They help a session find the binding documents and enforce nothing.
- *Unverified* (**DD-112**): whether folder trust is on by default (the vendor's two pages
  disagree); what a timed-out hook does to the call; a hook's working directory and, on Windows,
  its shell; whether `$GEMINI_PROJECT_DIR` is expanded at load or by the shell; whether hooks
  fire in `yolo` mode, in headless `-p` mode or for a subagent's calls; whether
  `context.fileName` also renames the global `~/.gemini/` file; whether `settings.json` tolerates
  a comment key; what `tools.exclude` does without `tools.core`; and what a subagent's first turn
  holds.
- *Where it runs:* a local process, as the user. Its remote subagents are services it calls, not
  a place it runs, so nothing contains it but the user's account.

**The Antigravity adapter**, written against antigravity.google/docs as retrieved on 2026-11-23,
which then named CLI 1.5.12 and App 2.34.0. `.agents/hooks.json` carries no comment, because the
host documents no comment key and rejects at load time a hook configuration that could never
run, so this entry is its full honesty text, of which the adapter's host-rails rule carries a
summary written before any probe: configured, and never observed firing (**DD-111**,
**DD-112**). On CLI 1.5.15 in print mode on Linux both hooks have since fired and the rules been
listed by description (**DD-121**); on App 2.35.1 on Windows the hooks run and the shipped
commands do nothing (**DD-122**).

- *Rails it has*, in `.agents/hooks.json`, which the CLI, the App and the IDE all read. A
  `PreToolUse` hook on `run_command` runs the command guard, which answers
  `{"decision":"deny","reason":…}` or `{"decision":"allow"}` on stdout and exits 0. A
  `SessionStart` hook runs the bootstrap and injects its banner as a system message. Both find
  the project root through `git rev-parse --show-toplevel` and exit 0 with nothing outside a git
  work tree. On Linux both ran in `.agents/`, from which that lookup resolves (**DD-121**), as
  the vendor's hooks page says of every OS. On Linux CLI print mode a `PreToolUse` hook that
  exits non-zero, times out or answers with anything but JSON blocks the call, so a broken guard
  fails closed (**DD-121**); on App 2.35.1 on Windows an `exit 1` hook returned the host's hook
  error in place of the command's output, and one that exits 0 with no answer let the call run
  (**DD-122**). **On App 2.35.1 on Windows neither rail works:** it runs both hooks in `cmd.exe`,
  whose grammar fails the POSIX `root=$(…)` and so reaches the `|| exit 0` after it, ending the
  hook with no answer, so the guard allows every command and no banner arrives (**DD-122**; the
  mechanism is inferred, the hook's own error was not captured). The `pre-push` rail binds as it
  does everywhere, invoked by git, and `--no-verify` bypasses it.
- *What it lacks, and what then binds only as prose.* No output redaction: `PostToolUse` sees no
  tool output and can only answer `{}`, so a credential a command prints reaches the model as
  printed. No repo-local deny rules, since permissions live in user settings only: a
  `write_to_file`, `replace_file_content` or `multi_replace_file_content` on `.git/hooks/**`, and
  a `view_file` of a secret file, are stopped by nothing but the written rules, and the command
  guard judges `run_command` alone. The host's terminal sandbox is documented as on by default,
  blocking `~/.ssh` and `.env` and cutting the network to approved domains, but it is set in user
  or App settings:
  the adapter neither sets it nor can see it, and it is a layer under the rails, not one of
  them. The guard reads every `run_command` as Bash, while the vendor's permissions page names
  PowerShell and Command Prompt for command matching on Windows, on App 2.35.1 the agent's
  `run_command` ran PowerShell and the hooks `cmd.exe` (**DD-122**), and the hook commands are
  POSIX shell. The spawn speed bump is not wired.
- *What skips it.* A hook entry with `enabled: false`. There is no repo-local settings file to
  skip. `--dangerously-skip-permissions` approves every request; whether it, `--mode` or anything
  else skips workspace hooks or rules is not documented. Print mode (`agy -p`) on Linux skips
  neither and put no trust prompt in front of the workspace hooks (**DD-121**). `AGENTS.md` is
  read natively and always, but a rule file over 24,000 bytes is truncated, and always-on rules share a
  20,000-token budget past which the largest are cut to a path and a description: a constitution
  grown past either
  limit loses text on this host, and no AMH check warns of it.
- *Procedure, not rails.* Four `model_decision` rules under `.agents/rules/`, whose description
  is up front and whose body is read on demand (a rule with a missing or unknown trigger is
  silently discarded), and the read-only reviewer `.agents/agents/amh-rule-reviewer.md`, with no
  shell or write tool and `commandExecutionPolicy: "off"`, which starts with none of the parent's
  history. They help a session find the binding documents and enforce nothing.
- *Unverified* (**DD-112**, less what **DD-121** and **DD-122** settled): whether the
  interactive CLI and the IDE behave as print mode did, and the CLI and the IDE on Windows at
  all, their hook and `run_command` shells included; on Windows, whether an `exit 1` hook keeps
  the command from running, as a side effect would show, and what a timeout or a non-JSON answer
  does; on Linux, what a `PreToolUse` exit 0 with no answer does; what a failing `SessionStart`
  hook does anywhere; the hooks' working directory on Windows; any trust gate on workspace hooks
  outside print mode; any other flag or mode that skips them or the rules; whether the App keeps
  a project's settings in `~/.gemini/config/projects/`, the likeliest place (**DD-122**); and
  whether the terminal sandbox is on in a given session and enforces what its page describes.
- *Remote Agents* run in what the vendor calls an isolated, Google-managed remote environment,
  on attached GitHub repositories, Drive files and uploads, with plugin OAuth tokens injected on
  their requests. That contains the user's own machine: such an agent cannot reach local files,
  keys or a local `.env`. It does not contain what the agent does with what it was given, such as
  a push to an attached repository or a call made with an injected token. No rule is relaxed for
  it: every rule in `AGENTS.md` binds a remote agent as it binds a local one. The owner's probe of
  2026-11-24 (**DD-120**), on a non-root Linux VM with the repository cloned during the session
  rather than attached, saw `AGENTS.md`, the four rules and the reviewer load only from the
  workspace root at agent start, never from a clone below it. The reviewer got `view_file` and
  none of `grep_search`, `list_dir` or `find_by_name`, which that host lacks and drops without an
  error, so a session invoking it there passes it every path it is to read. Neither hook fired,
  even for a subagent started after `.agents/hooks.json` sat at the root. Until a top-level
  conversation in a Remote Project with the repository attached shows otherwise, treat a Remote
  Agent as hook-less: no command rail, no banner, and no `pre-push` rail until a bare
  `scripts/session-start.sh` has run in that clone. Its `run_command` keeps stdin open, so a
  `--json` run there waits for an end of input that never comes; the bare form never reads
  stdin (**DD-119**).

## When CI fails (workflow vs code)

Local and CI run the same script, so first compare what that script could see: the commit,
index and worktree are inputs too. A guard built on `git ls-files` may omit an untracked file;
staging it after the local run changes the input CI receives and can turn local-green into
CI-red without any environment difference. Triage: (1) read the failing log; (2) reproduce
from the exact tree state CI checked, staging new files before the local ladder when a guard's
file discovery is index-dependent; then classify a real failure (fix the code), a toolchain
mismatch (fix the workflow, in the same change), or a flake (re-run once; never "fix" code for
a flake). (3) Never weaken a gate to get green. (4) Real but out of scope: say so, with the log
excerpt. A common environment difference here is `shellcheck`, which CI installs and a local
container may not have — `verify.sh` deliberately FAILS rather than skips when it is missing
under `CI`.

## Self-adaptation — keep this runbook useful

If this runbook lacks what you need: consult the ledger and the archive, record durable facts
as ledger rows, and if a playbook is wrong, stale or missing the case you just handled, **fix
this runbook in the same change.** Treat it as code.

Self-adaptation covers *operational* content — playbooks, the doc index, the module map,
commands. *Binding* rules (session discipline, the review protocols, guard semantics, git and
permission policy) are never self-adaptation: they live in `docs/PROTOCOLS.md` and the
constitution and go through the rule-review protocol, and process-reshaping changes go through
the Owner queue.
