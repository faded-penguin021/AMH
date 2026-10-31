# PLAN — close the three open Owner-queue items inside 16.0.0

> **Status: APPROVED by the owner 2026-10-31 (rev 2), in progress.** Unit 3's safety net is
> split out as Unit 3s and **kept explicitly open as the owner's decision**. It is not
> implemented unless the owner decides for it (§1, decision 5). Rev 2 recorded the owner's first
> four decisions and folded in an external review (verdict REVISE_PLAN, four findings, each
> re-measured, §2.2).
> **Every claim is re-verified when the plan is EXECUTED.** Re-measure each shape at the start of
> the unit that acts on it.

The plan is provisional while it is live. Its durable outcomes go to Changelog lines and ledger
rows. Code cites ledger rows and never this file, and no ledger row may cite this file's path.
When the work is done, archive this file to `docs/history/` or delete it (`docs/RUNBOOK.md` →
**Session discipline** 5).

Reading key:

- `⏎` is a real newline. A backslash shown before one is part of the command.
- "guard 2" means the guard blocked the command; "guard 0" means it let it through.
- "bash runs it" means a harmless stand-in for `printenv` actually executed (method in §2).

## 1. Owner decisions (answered 2026-10-31)

1. **Fold the guard units into 16.0.0.** They ride the open 16.0.0 draft, and the tag comes after
   all of them (Phase A, §5).
2. **Fix all of it:** item 2, item 3, and every shape in §2 this plan takes on.
3. **One fresh-context reviewer per unit: approved.** The Rule-review protocol requires one
   blocking pass per legislation unit. This answer lifts the standing no-subagents instruction for
   exactly that pass in each of Units 1–4, and in Unit 3s if it runs.
4. **The version stays 16.0.0.** No new number. Each unit adds a bullet to the existing 16.0.0
   entry in `harness/CHANGELOG.md`. Each ledger row says the change was drafted as part of MAJOR
   16.0.0.
5. **Rev 2 approved; the safety net stays open.** The owner keeps the one decision rev 2 put to
   them, Unit 3's safety net, explicitly open. So:
   - it is split out as **Unit 3s**, decided before any review pass;
   - it waits in the Owner queue;
   - Units 3 and 4 run without it.

   Unit 0 removes the two queue items about planning fixes, because the owner has answered them;
   the STATE checklist tracks the work from then on.

## 2. What was measured

All measurements were taken on 2026-10-31 against commit `0e3c908`.

- **Guard verdicts:** each shape was passed to `scripts/command-guard.sh --command`, with fresh
  advisory state per shape.
- **Bash behaviour (bash 5.2.21):** the same text, with `printenv` replaced by
  `printf 'REACHED_SENTINEL\n'`, was run under `bash -c` inside a fresh `mktemp -d`.
- **Git behaviour (git 2.43.0):** `git push --dry-run --porcelain` against a throwaway bare
  repository.

Shapes that contain a push were written to scratch files first, because the guard refuses a
command line that names one. Nothing dangerous was executed, and nothing remote was changed. The
probe IDs (R…, C…, Q…, H…) are used throughout the plan.

### 2.1 The queue items: all three still open

| Item | Check | Result |
|---|---|---|
| 1. tag 16.0.0 | `git ls-remote --exit-code --tags origin refs/tags/amh-v16.0.0` | no output (exit 2); newest tag `amh-v15.1.0`; no PR exists for `ccr-be34178a-vdcp2f`, which is 16 commits ahead of `main` |
| 2(a). quote in a comment | `echo a # don't` ⏎ `printenv` | guard 0 |
| 2(b). backslash-newline on a heredoc's operator line | `cat <<EOF \` ⏎ `&& printenv` ⏎ `body` ⏎ `EOF` (R3c) | guard 0, bash runs it |
| 3. abbreviated push options | `git push --del origin session/x` | guard 0; git really deletes (dry run: `[deleted]`) |

### 2.2 The review's four findings: all four reproduced

| Finding | Shape | Guard | Bash runs it | Must become |
|---|---|---|---|---|
| 1 | R1a `echo <(echo a)#b; printenv` | 2 | yes | stay 2 |
| 1 | R1b `echo >(cat)#b; printenv` | 2 | yes | stay 2 |
| 1 | R1c `echo $((1+2))#b; printenv` | 2 | yes | stay 2 |
| 1 | R1d `(echo a)# don't` ⏎ `printenv` | 0 | yes | 2 |
| 2 | R2a `cat <<A <<B` ⏎ `A` ⏎ `'` ⏎ `B` ⏎ `printenv` | 0 | yes | 2 |
| 3 | R3a `cat <<EO\` ⏎ `F` ⏎ `body` ⏎ `EOF` ⏎ `printenv` | 0 | yes | 2 |
| 4 | `git push --mir`, `--al` or `--branches` followed by `origin session/x` | 0 | (not run) | 2 |

### 2.3 Where bash starts and ends a comment, by context (Unit 2's specification)

**Bash starts a comment** at a `#` that comes after any of these:

- a space, tab or newline; `;`, `&`, `&&` or `|` (S1–S7);
- any `(`, including the `(` of `$(` (S4, S5);
- an **opening** backtick (R1m);
- a `)` that closes a plain `(`: a subshell (R1d, C15), `((…))` (C4), or a case pattern, with
  its leading `(` (C16) or without it (R1h).

**Bash does not start a comment** at a `#` that comes after any of these:

- `>` or `<`. C5 `echo a >#x` writes a file named `#x`; C6 is `cat <<<#x`.
- `=` (C13), `]` (R1k) or `}` (C9).
- a **closing** backtick (R1f).
- a `)` that closes `$(` (R1g, nested R1e, C14), `<(` (R1a), `>(` (R1b), `$((` (R1c), `=(`
  (R1i), or `@(` with extglob on (C8). This includes `$(case … esac)` (C7).

**Where a comment ends:** at the newline. Inside backticks it also ends at the closing backtick.
C1 is `` echo `#x`; printenv ``, and bash runs `printenv`.

**What the guard does today.** `join_continuations`' comment rule (`command-guard.sh:483–486`)
counts `<`, `>`, every `)` and every backtick as places a comment can follow. That is wrong for
C1, C5, C6, C7, C8, C14, R1a–c, R1e–g and R1i. Today the rule only drops backslashes, so those
errors fail closed. Once comment text is dropped, every one of them fails open.

### 2.4 Heredoc boundaries: shapes that get through the guard (guard 0, bash runs it)

**Where the body ends.**

- R2a: two heredocs on one line (finding 2).
- R2b: an indented `  EOF` inside a plain `<<` heredoc. Bash does not treat it as the terminator.
- R2g: spaces before the terminator in a `<<-` heredoc. Bash strips leading tabs only.
- R2d: `foo\` ⏎ `EOF` in a body whose delimiter is unquoted. Bash joins the two lines into
  `fooEOF`, so the first `EOF` line does not end the body.

**How the delimiter word is read.** Each of these stores a delimiter that no line ever matches,
so the body never closes and every line after it goes unjudged:

- Q1 `<<E"O"F`
- Q2 `<<'E'OF`
- Q3 `<<"E O F"`
- Q5 `<<$'EOF'`
- R3a `<<EO\` ⏎ `F`

Q4 `<<E\OF` is already read correctly.

**Where the body starts.**

- R3c: queue item 2(b).
- R3d: `cat <<EOF "x` ⏎ `y" ; printenv`. Bash starts the body after the line where the quote
  closes.
- R2f: `echo "subject` ⏎ `see <<EOF in docs"` ⏎ `printenv`. A commit message that mentions a
  heredoc opens body mode.
- a′: `echo hi # see <<EOF` ⏎ `printenv`. A heredoc operator inside a comment opens body mode.

**Baselines that must not regress:**

- R2c (a tab-indented terminator in a `<<-` heredoc) and R2e (a quoted delimiter): guard 2 today.
- R3b `cat <\` ⏎ `<EOF`: guard 2 today, only because the operator is not recognised and the body
  gets judged.
- H1, the standard commit-message heredoc `git commit -m "$(cat <<'EOF'` … `EOF` ⏎ `)"`: guard 0.
- H2, the same followed by `; printenv`: guard 2.

**Out of scope, already documented.** H3 is a command after the terminator inside `"$(…)"`. It is
the gap DC-028 already records: the guard does not look inside `"$(…)"` at all, so
`echo "$(printenv)"` is guard 0.

### 2.5 Push options (Unit 1)

| Spelling | Guard | Git |
|---|---|---|
| `--del`, `--delet` | 0 | deletes |
| `--force-w`, `--force-with`, `--force-with=<ref>`, `--force-if` | 0 | force |
| `--no-veri`, `--no-verif` | 0 | `--no-verify` |
| `--mir`, `--al`, `--branc`, `--branches` + `origin session/x` | 0 | `--mirror`/`--all` push refs you did not name; whether git 2.43 knows `--branches` was not measured |
| `--d`, `--forc`, `--no-v` | 0 | refused as ambiguous |
| `--all`, `--mirror` + `origin session/x` | 2 | — |
| `--push-opt x origin session/x` | 2 ("two refs") | — a false positive that fails closed |
| `--no-force-with-lease`, `--dry-run`, `--set-up`, `--verify` | 0 | harmless; must stay 0 |

## 3. Two lessons the units are built on

1. **No heredoc boundary error fails closed.** Body text that gets read as commands can open a
   quote that hides the real command after the terminator (R2a, R2b, R2d, R2g). A body that closes
   late hides commands outright. Rev 1 claimed that `cat <<A <<B` fails closed; that claim was
   wrong and is withdrawn (finding 2).
2. **Dropping text the shell drops turns every disagreement about where that text starts into a
   hole.** So Unit 2's comment rule is bash's rule, measured context by context (§2.3). Some cases
   the walker cannot decide, such as a `)` whose `(` it never saw. In those cases each reader takes
   the reading that judges more text.

## 4. The units, in order: 0 → 1 → 2 → 3 → 4, with Unit 3s parked, then Phase A

Units 1–4, and Unit 3s if it runs, each follow `docs/RUNBOOK.md` → **Change a shipped script**:

- edit the template first;
- run `bash -n` before copying it down;
- run `scripts/build-manifest.sh`;
- show the new fixtures FAIL against the old script, by stashing the behaviour.

Each also gets the **Rule-review protocol**: one blocking fresh-context reviewer, one pass. Then:

- the full `scripts/ladder.sh`;
- a STATE Changelog line and a tick on the STATE checklist;
- a ledger row in `docs/LEDGER_D.md`;
- a bullet in the 16.0.0 CHANGELOG entry.

The commit body says what the unit was set to change and which pass that owed (**Session
discipline** 10). The split into Units 2, 3 and 4 is decided now, before any review pass.

### Unit 0 — commit the approved plan and make room in working memory (docs-only)

- Commit this file and add a STATE checklist for Units 0–4 and 3s (**Session discipline** 5).
  Phase A stays as Owner-queue item 1.
- Remove queue items 2 and 3, which the owner has answered, and record that outcome in a
  Changelog line. Add an Owner-queue item for Unit 3s, the safety net the owner keeps open.
- Fold the seven cc-safe-setup Changelog lines (the plan line and Units 1–6) into one pointer
  line citing DD-046 to DD-048 and DD-051 to DD-053. The grounds are lifecycle: that stage
  finished on 2026-10-30, so **Working-memory compression → When to compress** says to fold it.
  The byte count is not the reason. The DD-049 and DD-050 lines stay as they are.
- `docs/STATE.md` is 13,972 bytes today, against a 14,336-byte trigger.
- **Acceptance:** `scripts/ladder.sh --guards-only` is green, and the file is under the trigger.
- **Review:** none owed. The unit is docs-only and outside both review protocols' scope.

### Unit 1 — read push long options by unique prefix (item 3; finding 4)

- **Change:** in the push loop (`command-guard.sh:2164–2265`), pass any `--word[=value]` (except
  a bare `--`) through the existing `is_long_opt` (`:1645`). Then rewrite the word to the full
  option name, the way the short-cluster code already rewrites to `-f`:

  | Prefix of | Goes to |
  |---|---|
  | `force`, `force-with-lease`, `force-if-includes` | the force arm |
  | `delete` | `delete_push` |
  | `no-verify` | the no-verify arm |
  | `mirror`, `all`, `branches` | the mirror/all arm, which also gains the full `--branches` |

  `--no-force-with-lease` does not start with `force`, so it stays allowed.
- **Fixtures, blocked, each with an explicit `origin session/x`** so that the new reading is
  isolated from the implicit-ref rule: `--del`, `--delet`, `--force-w`, `--force-with=x`,
  `--force-if`, `--forc`, `--no-veri`, `--mir`, `--al`, `--branc`, `--branches`. These test how
  the guard classifies options. Git itself refuses `--mirror` or `--all` together with a refspec.
- **Fixtures, allowed:** `--no-force-with-lease`, `--dry-run`, `--set-up`, `--verify`, and
  `git commit -m "--del"`.
- **Mutation check, one mapping at a time.** Remove the force mapping and its fixtures must fail.
  Do the same for delete, no-verify and mirror/all, each on its own, not just by stashing the
  whole diff.
- **Optional:** add a `st_blocked_reason` helper, so the no-ref forms (`--mir origin`,
  `--al origin`) can be asserted to block for the mirror/all reason and not for the implicit-ref
  one. Also optional: read the options that take a value (`push-option`, `receive-pack`, `exec`)
  by prefix, which removes the fail-closed "two refs" false positive.
- **Header:** rewrite the push-rail bullet (`:276–278`) and the off-switch bullet (`:306–307`).
- **Acceptance (binary):** every row of §2.5 has the verdict this unit sets, and the ladder is
  green. Then add a Changelog line recording that item 3's check now blocks.

### Unit 2 — the comment rule becomes bash's, and comments are removed before any walker reads the text (item 2(a), a′; finding 1)

- **One predicate for both readers.** Add a single function that answers "does the `#` here
  start a comment?" with **yes**, **no** or **unknown**. Both `join_continuations` and
  `heredoc_delim` call it, so they share one set of semantics (finding 1). It implements §2.3:
  - Starters: a blank, newline, `;`, `&`, `|`, `(`, an opening backtick, and a `)` whose `(` was
    command-level. `<` and `>` are removed.
  - **A paren stack.** A `(` is command-level when it comes after the start of the text, a blank,
    a newline, `;`, `&`, `|`, `(` or an opening backtick. After anything else (`$`, `<`, `>`, `=`,
    `@`, a word character) it is word-level, and its `)` continues the word. That keeps real
    subshell comments (R1d, C15, C16) and leaves R1a–c, R1e, R1g, R1i, C7, C8 and C14 alone.
  - **Backticks** are tracked as open or closed. A comment inside backticks ends at the closing
    backtick (C1).
  - **A `)` with nothing on the stack is unknown.** That covers a case pattern written without
    its leading `(`, and a stack thrown off by a `case` inside `$(` (C7). For an unknown,
    `join_continuations` keeps the text and `heredoc_delim` opens no body.
  - **Residual, named in the header:** R1h, `case a in a)# don't` ⏎ `printenv`, stays guard 0.
- **`join_continuations` drops comment text**, keeping the newline. It now runs whenever the
  text contains a `#` or a backslash-newline.
- **`heredoc_delim` stops scanning at a `#` that starts a comment** (a′).
- **Fixtures that must become 2:**
  - queue 2(a): `echo a # don't` ⏎ `printenv`;
  - a′, R1d, R1m, C10, C11, C12, C15, C16;
  - permanently denied, through `st_destructive_never_clears`: `echo a # it's` ⏎ `rm -rf /`.
- **Fixtures that must stay 2:** R1a, R1b, R1c (the review's acceptance shapes), R1e, R1f, R1g,
  R1i, R1k, R1l, C1, C5, C6, C7, C8, C13, C14. These must also fail when the paren-kind tracking
  is removed (a mutation check).
- **Fixtures that must stay 0:** `git commit -m "it's # fine"`, `echo a#b`, `echo ${x:-#}`,
  `echo $#`.
- **Fixtures that become 0 by design.** Bash runs none of these, and the guard's first design
  rule says text that only contains a command must not trip it:
  - `echo a # ; printenv`
  - ``echo a # see `env` ``
  - `echo $x #$(printenv)`
  - a comment that merely mentions `rm -rf /`
- **Performance:** time the self-test and one command with a multi-KB heredoc, before and after.
- **Header:** delete the "A QUOTE INSIDE A `#` COMMENT" bullet (`:146–148`), add R1h to the list
  of misses, and rewrite the comment above `join_continuations`.

### Unit 3 — heredoc bodies END where bash ends them (part of item 2; finding 2)

Three changes, in `strip_heredocs` and `heredoc_delim`. A fourth, the safety net, is Unit 3s
below, waiting on the owner:

1. **Every operator counts.** All heredoc operators on a line are recorded in order, and their
   bodies are consumed one after another (R2a).
2. **Exact terminators.** A plain `<<` terminator must match the line exactly. `<<-` strips
   leading **tabs** only (R2b, R2g). Today both strip every leading blank.
3. **Continuations inside a body.** When the delimiter is unquoted, a body line ending in an odd
   run of backslashes is joined to the next line before the comparison, as bash does (R2d). There
   is no join when the delimiter is quoted (R2e). This is bash's own rule inside a body. It is
   not the global body join that DD-046 forbids.
- **Fixtures that become 2:** R2a, R2b, R2d, R2g.
- **Fixtures that become 0:** `cat <<A <<B` ⏎ `printenv` ⏎ `A` ⏎ `env` ⏎ `B`. Both bodies are
  data; today the second one is judged as commands.
- **Fixtures that must stay as they are:** R2c and R2e stay 2; H1 and ordinary heredocs stay 0.
- **Still open after this unit:** Q1, Q2, Q3, Q5 and R3a. Unit 4 closes them.
- **Header:** rewrite the HEREDOCS bullet (`:140–145`), with no "fails closed" wording.
- **Ledger row:** lesson 1 from §3.

### Unit 3s — PARKED: an unclosed heredoc body blocks the command (the owner's open decision)

**It runs only if the owner decides for it. It is not part of closing item 2.**

- **Change:** today, a body still open when the input ends silently discards everything after
  it. Instead, block the command, with a reason saying the guard could not find the heredoc's
  terminator.
- **Why:** it applies DC-002's principle, that a command the guard could not read gets blocked,
  not passed. Every delimiter the guard misreads would then be refused instead of passed. Before
  Unit 4 that means Q1–Q3, Q5 and R3a; after it, any spelling nobody has found yet.
- **Cost:** it refuses a command bash would run. Bash runs a command whose heredoc is never
  closed, with a warning.
- **Recommendation:** adopt it.
- **Fixtures:** an unterminated heredoc becomes 2 with the new reason. Before Unit 4, Q1–Q3, Q5
  and R3a become 2.
- **Review:** it changes guard semantics, so it owes its own rule-review pass. That pass is
  decided now, as the plan permits.

### Unit 4 — heredoc bodies START where bash starts them (the rest of item 2; finding 3)

`strip_heredocs` reads command text as logical lines, using Unit 2's walker:

1. **Continuations go first.** Backslash-newlines are removed from command text before the
   operator and delimiter are recognised. That includes one inside the operator (R3b `<\` ⏎ `<`)
   and one inside the delimiter word (R3a `<<EO\` ⏎ `F`). Body text is never joined before
   matching, as DD-046 requires, apart from Unit 3's in-body rule.
2. **State carries across lines.** Quote, comment, backtick and paren state carry from one line
   to the next. The logical line ends at the first newline that is outside quotes, outside a
   comment and not escaped, and the bodies begin after it (R3c, R3d). A `<<` inside a quoted
   string opens nothing (R2f).
3. **The delimiter word gets bash's quote removal.** Quotes anywhere in the word, backslashes and
   `$'…'` are removed, and the word ends at an unquoted blank or metacharacter. Q1, Q2, Q3 and Q5
   are then read correctly; if Unit 3s has shipped, its safety net stops firing for them.
4. **H1 stays at 0.** Inside `"…"` the guard does not see `$(` (DC-028), and this unit does not
   change that. Carrying quote state across lines must not turn H1's body into commands.

- **Fixtures that become 2:** R3a, R3b, R3c, R3d, R2f, Q1, Q2, Q3, Q5, each with the command after the body
  judged.
- **Fixtures that must stay as they are:** a′ stays 2; H2 stays 2; H1 stays 0; ordinary heredocs
  stay 0.
- **Not taken:** one lexer pass replacing `strip_heredocs`, `join_continuations` and
  `split_segments`' quote walk all at once. It is correct in principle, but too large for one
  review pass. Units 2–4 reach the same reading in three reviewable steps.
- **Acceptance (binary):** the fixtures above, and the ladder is green. Then add a Changelog line recording that item 2's checks now block.

## 5. Phase A — ship 16.0.0, after Unit 4

| Step | Who | What |
|---|---|---|
| A1 | owner → agent | Owner says "open the PR". The agent fills in `.github/pull_request_template.md` and describes the whole train against `main`: 15.2.0 rides whole inside it, DD-040 to DD-053, plus this plan's rows. |
| A2 | owner | Edit the squash message to remove any poison token before merging (**DC-040**). |
| A3 | owner | Merge. `version-lockstep.sh --against-latest-tag` should pass, because 16.0.0 is the MAJOR successor of `amh-v15.1.0`. Estimated by reading the rule; not run. |
| A4 | owner | Tag `amh-v16.0.0`. |
| A5 | agent, next session | Re-run item 1's check. If it prints a ref, delete the item and add a Changelog line. Archive this plan to `docs/history/`, or delete it (**Session discipline** 5). |

## 6. What changed since rev 1

- **Your decisions:** there is no 16.1.0. Phase A moved to the end. Unit 0 folds by lifecycle
  instead of waiting for the tag.
- **Finding 1:** Unit 2's comment rule is now the measured table in §2.3, implemented as one
  predicate shared by both readers, with a paren stack and with `<` and `>` removed. The four
  acceptance shapes are fixtures.
- **Finding 2:** "That fails closed" is withdrawn. Multiple delimiters are fixed in Unit 3.
- **Finding 3:** Unit 4 removes continuations before it recognises delimiters, including inside
  the operator and inside the delimiter word.
- **Finding 4:** the fixtures now use explicit refs, include the full `--branches`, and each
  mapping is mutation-checked on its own.
- **Found while checking the review:**
  - `<` and `>` wrongly counted as places a comment can follow (C5, C6);
  - a comment inside backticks ends at the closing backtick (C1);
  - a `case` inside `$(…)` throws off a simple paren counter (C7);
  - terminators must match exactly (R2b, R2g);
  - continuations inside a body (R2d);
  - quote removal in the delimiter word (Q1–Q3, Q5);
  - a heredoc operator inside a multi-line string (R2f).
- **Rev 1's Unit 3 is now Units 3 and 4.** Unit 3 is where the body ends; Unit 4 is where it
  starts.
- **The one decision rev 2 put to the owner, Unit 3's safety net, is kept open** (approval of 2026-10-31): it is now Unit 3s, parked in the Owner queue.

## 7. Not verified

- **No implementation exists yet.** Every "must become" or "must stay" is a requirement, not a
  measurement of new code.
- **The ladder and the full self-test were not run,** because the tree is unchanged.
- **Unit 3's safety net might flip an existing fixture.** I did not check whether any of the 614
  `st_blocked`/`st_allowed` fixtures deliberately leaves a heredoc unterminated; Unit 3 will find
  out.
- **A3's lockstep outcome is an estimate.** The line numbers are for `0e3c908`.
