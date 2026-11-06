# Unit 4: the failed rule review, and the fix in place

Archived narrative behind **DD-059** and **DD-060** (owner-queue-closure plan, Unit 4: heredoc
bodies start where bash starts them). Retires with the plan.

## 1. Attempt 1 and its review

Attempt 1 (uncommitted, on `95c52a0`) cut the text into logical lines (`logical_line`), read
each line's operators (`heredoc_delim`) with a fresh quote state, and started every body after
the logical line. Its mandatory rule-review pass, gpt-6.1-sol at `-e high`, ran on 2026-11-04 and
returned **REQUEST_CHANGES** with four verified regressions. The session replayed each one on
2026-11-05 with `scripts/command-guard.sh --command` and bash 5.2.21 (`bash -c` in a fresh
`mktemp -d`, `printenv` on `PATH` a stub that creates a file):

| | command | `95c52a0` | attempt 1 | bash |
|---|---|---|---|---|
| F1 | `echo <<E"O"F $(printf x⏎); printenv⏎EOF` | refuses | allows | runs the stub |
| F2 | `x=$(⏎cat <<E"O"F⏎hi⏎EOF); printenv⏎: <<EOF⏎EOF` | refuses | allows | runs the stub |
| F3 | `cat <<''""⏎'⏎⏎printenv` | refuses | allows | runs the stub |
| F4 | `git commit -m "$(cat <<'EOF'⏎subject⏎⏎See "here <<TOKEN" in docs⏎EOF⏎)"` | allows | refuses | commits, no stub |

All four come from one model error: each logical line was read with a fresh context, so a `$(`
opened after the operator (F1) or on an earlier line (F2), and the quotes nested inside
`"$(…)"` (F4), were invisible. F3 was an empty quoted word discarded as no word. The review's
fifth finding was the header promising what F1–F3 broke.

On 2026-11-05 the owner chose to fix the unit in place and granted it a fresh rule-review pass
(**DD-060**), and kept 16.0.0 waiting for Unit 4.

## 2. What bash 5.2.21 does, measured

Each rule below was measured with the harness above before the code was written; the rule's
cases are named by the probe set that measured them.

- A body starts at the next newline that is a **token at its operator's level**. Bash keeps one
  list of waiting operators per parser level: the command line, each `$(…)`, `<(…)` or `>(…)`,
  each backtick substitution. A newline inside a quote, `${…}`, `$((…))`, `$[…]`, `((…))`, a
  backtick word, or a substitution opened after the operator is no token for it; a newline
  inside a subshell's `(…)` is. (F1, F2, ``cat <<EOF `echo⏎`; printenv⏎EOF``,
  `cat <<EOF ${x:-⏎}; printenv⏎EOF`, `cat <<EOF $((1+⏎2)); printenv⏎EOF`,
  `cat <<EOF; ((x⏎)); printenv⏎EOF`, `cat <<EOF <(echo⏎); printenv⏎EOF` — each one also let
  through by `95c52a0` and by attempt 1.)
- A `$(…)` that closes with a body still waiting (`echo $(cat <<EOF)`) hands it on: it starts at
  the very **next physical newline**, inside a quote, after a backslash, in a comment or not,
  and before the bodies waiting at the level where that newline falls
  (`cat <<A $(cat <<B)⏎b⏎B⏎printenv⏎A` reads B first).
- Inside `$(…)`, nested parens and `"$(…)"` included, a body also ends at a line that is the
  delimiter, blanks and `)`. The rest of that line is code, and the substitution's other waiting
  bodies are handed on to the next newline:
  `x=$(cat <<"EOF" \⏎<<A⏎…⏎EOF)⏎'⏎A⏎B⏎printenv` reads `'` as A's body and runs `printenv`.
- Inside backticks `EOF)` ends nothing. A backtick substitution is a script of its own, found
  first: its closing backtick ends the bodies it left open, even in the middle of a body line,
  and the lines after it are commands (`` echo `cat <<EOF`⏎printenv⏎EOF `` runs the stub; so does
  `` echo `cat <<EOF⏎x` ; printenv⏎EOF ``).
- `<<''`, `<<""` and `<<''""` are delimiters, and an empty line ends their body.

Attempt 1 also kept the whole `EOF)` line for the walkers, so `x=$(cat <<'E"F'⏎hi⏎E"F); printenv`
passed: the `"` of the delimiter opened a string that hid the `printenv`. The fix reads only
what follows the delimiter again.

## 3. The fix

`heredoc_walk` reads the whole command once with one stack of open contexts and one list of
waiting operators, each marked with the level it waits at, and applies the rules above.
`heredoc_word` gained the continuation rule and the backtick end. Comments are inert to the
stack under both readings; under the first reading a `<<` in a comment still opens a body unless
a quote before it on that line hides it, which is what the guard did before comments were read.

## 4. The differential fuzz

`docs/history/2026-11-04-unit4-heredoc-start-fuzz.py`, seed 20261104, 24000 structured and 6000
fragment cases, 28,785 after deduplication, against `95c52a0`, run on the final tree:

| `95c52a0` | fix | bash ran the stub | cases |
|---|---|---|---|
| allows | refuses | yes | 401 (closed) |
| allows | allows | yes | 2 (still open) |
| refuses | allows | yes | 21 (newly allowed, below) |
| refuses | allows | no | 904 (refusals removed) |
| allows | refuses | no | 1,429 (refusals added; 750 of them text bash parses) |

Of the 750, a random sample of 300 (seed 20261105) held 297 refused as a body that never
closes and 3 a `printenv` after `&&`. Of the 297, bash itself warns that 293 end at end-of-file;
the other 4 are misreads the guard's header names, three a `<<` inside a comment under the
first reading and one an escape inside `$'…'`. The two still open
are the DD-056 shape below, and `95c52a0` allows each without its heredoc too.

The first run of the fix newly allowed 23 commands that `95c52a0` refuses and bash runs. Two were
a scanner error, the `EOF)` close dropping the substitution's other bodies, fixed above. For each
of the other 21 the session built the command with the heredoc operator and its body deleted, and
`95c52a0` itself allows every one of those while bash runs it: 18 are the DD-056 shape, a quote
inside `"$(printf "fix #1")⏎"` that no walker nests (DC-028), and 3 are the backtick-quote gap
the Owner queue holds. `95c52a0` refused them only because its own heredoc misread cut the text
somewhere bash does not. A gpt-6-astra (`-e low`) consult chose to accept them over a second,
walker-model strip reading judged beside the first, which would have kept every such refusal at
the cost of a second rail pass on every commit-message heredoc and a second parser; the risk it
named is recorded in DD-059: refusal coverage does go down on those inputs.

## 5. The fresh pass, and its triage

The owner-granted pass (gpt-6.1-sol, `-e high`, 633 s) on the fixed, uncommitted unit returned
REQUEST_CHANGES with two P1 findings, each replayed:

| command | `95c52a0` | fix | bash |
|---|---|---|---|
| ``echo `echo $(cat <<EOF)`⏎printenv⏎EOF⏎:`` | refuses | allows | runs the stub |
| ``echo `cat <<E"O"F # hi`⏎printenv⏎EOF⏎:`` | refuses | allows | runs the stub |

Both are a closing backtick the walk did not see: a body a `$(…)` inside backticks handed on
outlived the backtick, and the comment arm stopped reading at `#`. Reading for the fix found a
third of the same kind, a body read at a `$(…)` level inside backticks, whose lines were never
checked for the backtick (``echo `x=$(cat <<EOF⏎hi⏎`⏎printenv⏎EOF``, which `95c52a0` let through
too). At most one backtick substitution is ever open, since any backtick inside one ends it, so
each waiting body now records whether one was open as it was read, and its closing backtick
ends all of those; a comment inside one ends at that backtick; and every body read while one is
open is checked for it. Each case is a fixture. The review also reported its own verification:
the 123 heredoc assertions passed, 120 memo comparisons found no stale answer, and the fuzz's
guard-side counts reproduced; its sandbox refused `mktemp -d`, so it did not replay the bash side.
As the protocol requires, the corrected unit was checked by the ladder and the fuzz, not by a
third review.
