# PLAN — close the three open Owner-queue items inside 16.0.0

> **Status: rev 4, 2026-11-02. Units 0 and 1 are done. Unit 2's first attempt failed its review
> and was not shipped; rev 3 redesigned Unit 2 on the owner's decision, the owner approved
> executing it after a spec review, and rev 4 folds that review in. Every unit starts only on the
> owner's explicit approval of that unit (§1, decision 5).** Unit 3's safety net is split out as Unit 3s, and that decision is still open with
> the owner. Rev 2 recorded the owner's first four decisions and folded in an external review
> (verdict REVISE_PLAN, four findings, each re-measured, §2.2). Revs 3 and 4 change only Unit 2,
> §2.3, §3 and §6–§7.
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
5. **Each unit needs the owner's approval; the safety net stays open.** The owner approved
   Unit 0 only, on 2026-10-31.
   - **No unit starts without the owner's explicit approval of that unit.** Approving one unit
     approves only that unit, and an approved plan is not an approval of its units.
   - **The safety net is still the owner's open decision.** It is split out as **Unit 3s**,
     decided before any review pass, and it waits in the Owner queue. Units 3 and 4, if
     approved, run without it.
   - **Queue items 2 and 3 are answered.** They asked whether to plan these fixes, and decision 2
     answered that, so Unit 0 removed them. An Owner-queue item names the next unit waiting for
     approval, and the STATE checklist tracks what is done.

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
- `>` or `<` (C5 `echo a >#x`, C6 `cat <<<#x`). The redirection is then left without a target,
  and bash refuses the whole line with a syntax error and runs nothing. Re-measured on
  2026-11-02 (bash 5.2.21, exit 2, `syntax error near unexpected token `newline'`); rev 2 said
  that C5 writes a file named `#x`, and that was wrong (**DD-055**);
- any `(`, including the `(` of `$(` (S4, S5);
- an **opening** backtick (R1m);
- a `)` that closes a plain `(`: a subshell (R1d, C15), `((…))` (C4), or a case pattern, with
  its leading `(` (C16) or without it (R1h).

**Bash does not start a comment** at a `#` that comes after any of these:

- `=` (C13), `]` (R1k) or `}` (C9).
- a **closing** backtick (R1f).
- a `)` that closes `$(` (R1g, nested R1e, C14), `<(` (R1a), `>(` (R1b), `$((` (R1c), `=(`
  (R1i), or `@(` with extglob on (C8). This includes `$(case … esac)` (C7).

**Where a comment ends:** at the newline. Inside backticks it also ends at the closing backtick.
C1 is `` echo `#x`; printenv ``, and bash runs `printenv`.

**What the guard does today.** `join_continuations`' comment rule (`command-guard.sh:483–486`)
counts `<`, `>`, every `)` and every backtick as places a comment can follow. That is wrong for
C1, C7, C8, C14, R1a–c, R1e–g and R1i; it is right for C5 and C6. Today the rule only drops backslashes, so those
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

## 3. Three lessons the units are built on

1. **No heredoc boundary error fails closed.** Body text that gets read as commands can open a
   quote that hides the real command after the terminator (R2a, R2b, R2d, R2g). A body that closes
   late hides commands outright. Rev 1 claimed that `cat <<A <<B` fails closed; that claim was
   wrong and is withdrawn (finding 2).
2. **Dropping text the shell drops turns every disagreement about where that text starts into a
   hole.** So Unit 2's comment rule is bash's rule, measured context by context (§2.3). Some cases
   the walker cannot decide, such as a `)` whose `(` it never saw. In those cases each reader takes
   the reading that judges more text.
3. **Where a reader may be wrong about what the shell drops, it makes that text inert instead of
   removing it, and keeps the old reading beside the new one** (revs 3 and 4, from Unit 2's
   first attempt and its spec review). The walkers' model of bash is not complete — no walker
   nests the quotes inside `"$(…)"` — so a rule that is bash's on paper still misplaces some
   comments. Removed, a misplaced comment hides the commands in it from every rail. Made inert,
   it can still turn a later closing quote into an opener. Judged under both readings, with the
   stricter verdict winning, it costs at most a refusal of something bash would run harmlessly.

## 4. The units, in order: 0 → 1 → 2 → 3 → 4, with Unit 3s parked, then Phase A

**Each unit starts only when the owner approves that unit** (§1, decision 5). The order below
is the plan's proposed order, not a licence to start the next unit.

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

### Unit 2 — comments are made inert before any walker reads the text (item 2(a), a′; finding 1) — rev 4, attempt 2

**Attempt 1, 2026-11-02: not shipped.** The owner approved the unit, and the attempt built rev 2's
design: comments REMOVED by one shared yes/no/unknown predicate, which grew into a stack of open
shell contexts (subshell, substitution, backtick, group, case pattern list and arm, array,
arithmetic, word-level paren, `${`). Measured against bash 5.2.21 (`bash -c`, a sentinel, a fresh
`mktemp -d`), it closed queue 2(a), a′, R1d, R1h and the rest of rev 2's "must become 2" list. On
40,211 generated commands HEAD (`be7a4df`) let 2,869 through that bash ran; the attempt let 100
through. Its rule-review pass did not hold it:

- Two gpt-6.1-sol runs were stopped by that model's content filter, at 344s and 456s, without a
  report. Their transcripts still showed probes the session then fixed: arithmetic, extglob, `${x:-)}`,
  `ca\⏎se`, `[[ x =~ (#x) ]]` and a case pattern named `case`.
- A fresh-context Claude reviewer then reported 11 inputs the attempt allowed, HEAD refused and
  bash ran (F1–F7). The session replayed five, all confirmed. Each is a "yes" the model got wrong:
  - F1: `git commit -m "$(printf "fix #1")" && git push --force origin main`. No walker nests the
    double quotes inside `"$(…)"`, so ` #1")…` read as an unquoted comment and was removed.
  - F2: `heredoc_delim` reads each line with no state from the line before, so a `)` or backtick
    at a line's start that closes an earlier line's `$(` or backtick stopped the scan. The body
    was then judged as commands, and a `'` in it hid every line after the terminator.
  - F3–F7: `[[ x =~ a|(#x) ]]`, an extglob `!(#x)`, `(( 1<(2 #x) ))`, `$[1 #x]`, and an argument
    named `esac` closing a case arm.
- The diff was reversed, and the tree is HEAD's. The whole attempt — model, 91 fixtures, header,
  CHANGELOG and ledger text — is kept as `docs/plans/2026-11-02-unit2-attempt-1.patch`, which
  applies to `be7a4df`. It retires with this plan.

**The owner's decision, 2026-11-02:** redesign, and grant the unit a fresh rule-review pass — the
protocol's one route to a second reviewer. Rev 3 wrote the redesign. On 2026-11-02 the owner
approved executing it, after a spec review by gpt-6-astra (`-e high`) whose findings were to be
folded in first. Rev 4 is the result.

**What the spec review found in rev 3** (verdict REDESIGN; the session replayed the decisive
inputs against bash 5.2.21):

- **Inert quotes alone are not safe.** A misplaced comment region can hold a quote that bash
  closes on a LATER line. Made inert, that quote's partner becomes an opener and hides what follows:
  `echo "$(printf "fix #1")⏎"; printenv` is refused at HEAD and would pass. A false comment can
  also suppress a real heredoc, whose body quote then hides the next lines (`echo "$(printf "fix
  #1")"; cat <<EOF⏎'⏎EOF⏎printenv`). So rev 3's "every command in view" and §3 lesson 3's "at
  most a refusal" do not hold for one reading on its own.
- **Header prose cannot stand in for zero.** Rev 3's acceptance let a newly allowed input pass
  by being named in the header. Rev 4 does not.
- **Quoted prose can gain refusals:** `echo "$(printf "fix #1")" "; printenv "` (finding 7).
- **§2.3 had C5 and C6 wrong**, as corrected above.

**The design (rev 4): two readings, and the stricter verdict wins.**

- **Reading 1 is HEAD's, byte for byte.** It goes through every rail exactly as `4d7d716` does.
  Whatever HEAD refuses stays refused: no input can be newly ALLOWED by this unit. That holds
  by construction, not by measurement, and the fuzz below confirms it.
- **Reading 2 makes comments inert.** It differs from reading 1 in two readers, and only there:
  - `join_continuations` walks any text that holds a `#`, not only text with a
    backslash-newline. In each comment region it DELETES every `'` and `"`, escaped or not,
    and keeps every other character. Deleting is bash's own quote removal, so a region that is
    really code still reads as bash reads it: `"printenv"` and `print"env"` become `printenv`,
    where an inert `_` would hide the word. Backslashes stay, with two exceptions. The run right
    before a deleted quote goes with it: kept, it would escape the next character, or read as
    joining the newline (`echo a # say "a\'⏎printenv`). The trailing run before the newline is
    dropped, as HEAD already drops it (`echo a # \; printenv` stays allowed).
  - `heredoc_delim` stops scanning a line at a `#` that starts a comment, so a′'s `<<` inside a
    comment opens no body.
- **One comment rule, HEAD's own,** for both readers: an unquoted `#` outside `${…}`, after a
  blank, a newline, `;`, `&`, `|`, `(`, `)`, `<`, `>` or a backtick, or at the start of the text
  or line. It covers every place in §2.3 where bash starts a comment, and its extra places
  are exactly HEAD's known errors. With reading 1 underneath, a wrong "yes" costs at most a
  refusal. Attempt 1's context stack and rev 3's narrower rule for `heredoc_delim` were there
  to make a removed comment safe; with reading 1 underneath they buy only fewer false refusals,
  and they are withdrawn.
- **A region ends at the newline,** inside backticks too. Ending it at the closing backtick
  would put a `'` back into play wherever the backtick state is wrong:
  ``echo a # `don't⏎printenv``.
- **When reading 2 runs.** Only when the text holds a `#`, and only when reading 2 would hand the
  rails different text: `strip_heredocs` and `join_continuations` are compared under both
  readings. Those are the only two readers that differ, so identical output means identical
  verdicts, and the second pass is skipped. A heredoc body full of Markdown `#` lines costs
  one extra strip and join, not a second run of every rail.
- **Advisory state.** Both readings go through the one-time tiers. Their state is append-only,
  so each advisory clears on its own rerun and none can loop. A command can take more reruns
  than at HEAD: every tier whose target a comment's quote used to hide now fires in turn, and
  a destructive signature recorded only by reading 2 adds one more. The rule review measured four
  reruns for a deletion, a hook-file `chmod` and an inline `os.unlink` behind one `# don't`.
- **Residual, named in the header:** whatever HEAD already lets through and reading 2 does not
  catch. One example is a comment inside `"$(…)"`, which no walker sees (**DC-028**). Rev 3's
  "residual to measure" is closed by reading 1.

**Fixtures:**

- **Must become 2:** attempt 1's whole "must become 2" set (queue 2(a), a′, R1d, R1h, every
  context in §2.3 that starts a comment), plus the spec review's three probes.
- **Must stay 2:** attempt 1's "must stay 2" set and F1–F7's 11 inputs. Reading 1 holds them, so
  they pin it: dropping reading 1 must turn some of them to 0.
- **Must stay 0:** rev 2's list; `echo a # \; printenv`; 40 ordinary `#` shapes (`fix #12`,
  `${#a}`, `16#ff`, a Markdown heredoc body and others), the check attempt 1's review ran.
- **Accepted refusals, pinned so the choice is visible:** `echo "$(printf "fix #1")" "; printenv "`
  and any other prose whose nested quotes the walkers misread around a `#` (finding 7). It fails
  closed, the direction §3 lesson 2 chooses.
- **Each rule pinned by a mutant** that applies, still parses, and fails a fixture by a wrong
  verdict, not by a crash: no reading 1; no reading 2; the walk gated on backslash-newline
  only; quotes kept in a region; `heredoc_delim` with no comment stop; the skip test always
  skipping.

**Acceptance, beyond the ladder:** a differential fuzz against bash, with baseline `4d7d716`, a
fixed seed, structured commands as in attempt 1 plus fragment strings, and each case's
generator, seed and count recorded in the ledger row. Bash runs each input under `bash -c` in a
fresh `mktemp -d`, with `printenv` resolved on `PATH` to a stub that creates a file. Running
the stub is the observation, so neither echoed text nor the exit status can forge or hide a
run. The count must be zero for each of the following:
1. inputs the new guard allows, HEAD refuses and bash runs;
2. inputs the new guard allows, HEAD refuses, whatever bash does: zero by construction;
3. "must stay 0" inputs the new guard refuses.

Also report how many inputs HEAD allows, bash runs and the new guard refuses (closed), and how
many HEAD allows, bash does not run and the new guard refuses (false refusals, each class
named). A case that times out counts as allowed by the guard that timed out.

**Review:** one fresh-context pass, under the owner's grant. If the gpt-6.1-sol content filter
stops the run again, a fresh Claude subagent at the strongest tier serves, as it did for attempt 1.

**Header:** replace the "A QUOTE INSIDE A `#` COMMENT" bullet with one that says what the two
readings do and what they leave. Name a quote inside backticks, which bash ignores and every
walker honours (`` echo `echo 'x`; printenv `` passes at HEAD), and the residual above.

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

**Rev 4 (2026-11-02):** the owner approved executing Unit 2 after a gpt-6-astra (`-e high`) spec
review, with its findings folded in first. That review's verdict was REDESIGN, on three inputs
that rev 3's single inert reading would newly allow. Rev 4 keeps the owner's inert design as a
second reading beside HEAD's, with the stricter verdict winning. It deletes quotes rather than
replacing them, ends a region at the newline, uses HEAD's comment rule for both readers, and
tightens the acceptance fuzz. §2.3's C5 and C6 are corrected, and lesson 3 is extended.

**Rev 3 (2026-11-02):** Unit 2 is redesigned after its first attempt failed review. Comments are
made inert instead of removed, and lesson 3 is added to §3. Both rest on the owner's decision of
2026-11-02, which also granted the unit a fresh review pass. Units 3, 3s and 4 are unchanged.

**Rev 2:**

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

- **Rev 4's Unit 2 was built and measured on 2026-11-02 (DD-056):** none newly allowed over
  42,569 generated commands, 599 closed, 66 still open as at HEAD, and 437 refusals added of text
  bash parses. The fuzz harness and its corpus lived in the session's scratch space and are not
  committed; the seed, the generator's shape and the counts are in the row.

- **No implementation exists yet.** Every "must become" or "must stay" is a requirement, not a
  measurement of new code.
- **The ladder and the full self-test were not run,** because the tree is unchanged.
- **Unit 3's safety net might flip an existing fixture.** I did not check whether any of the 614
  `st_blocked`/`st_allowed` fixtures deliberately leaves a heredoc unterminated; Unit 3 will find
  out.
- **A3's lockstep outcome is an estimate.** The line numbers are for `0e3c908`.
