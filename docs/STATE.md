# STATE — project state & session memory

> **Length guard.** Thresholds are in `amh.conf`; the rules for compressing this file are
> `docs/RUNBOOK.md` → **Working-memory compression**, and they bind whether or not you follow
> this pointer. Read them before any edit that takes this file over the compression trigger.
>
> **Tree-relative.** That same section says what may be in `Current state` at all — the Changelog
> and ledger pointers below are historical storage and are exempt: what stays true of the
> checked-out tree, never world-controlled status (merged, tagged, released, PR and CI state,
> deployments, remote branches, forge settings) as current truth. Point at a live probe instead
> of storing its last answer, route an unresolved external action to the Owner queue, and scope a
> retained past observation to when it was observed. Prose-only — no guard judges it.

## Project

The AMH meta-repository — source of truth for the harness and its reference instance, which runs
byte-identical copies of the scripts it ships; `AGENTS.md` describes both and is read in full
every session.
Adopted harness version: **AMH 16.0.0** — see `harness/VERSION`, the copy that counts.

## Current state

This tree declares **16.0.0**, MAJOR on the owner's call: a unit owes the review of what it
was set to change, never only that of the diff it ends with, and a decision says whether its
evidence was measured, estimated or reported (**DD-050**). It carries the 15.2.0 draft whole,
and every command-guard, adapter and banner change since, each named by a bullet of the 16.0.0
entry in `harness/CHANGELOG.md` and by its row (**DD-040** to **DD-042**, **DD-044** to
**DD-049**, **DD-051** to **DD-054**). Whether this draft is tagged or released is not recorded
here — `scripts/session-start.sh` probes it every session and reports present, absent or
could-not-ask, which is the only answer that can be right twice.

`docs/LEDGER_D.md` is the live ledger volume.

Multi-unit work, planned: `docs/plans/2026-10-31-owner-queue-closure.md`. It closes the
command-guard gaps the Owner queue named: a quote inside a `#` comment, heredoc bodies cut at
the wrong line, and abbreviated `git push` long options. It also closes the related shapes that
measuring those gaps turned up. All of it rides the 16.0.0 draft, and each guard unit gets one
fresh-context review pass. **Each unit starts only on the owner's explicit approval of that
unit.** The owner approved Units 0, 1 and 2, one at a time. Unit 2's first attempt failed its
review and was not shipped (**DD-055**). Its second attempt, plan rev 4, judges a command under two
readings of its comments, and the stricter verdict wins (**DD-056**). The first attempt is kept
whole as `docs/plans/2026-11-02-unit2-attempt-1.patch`, which applies to `be7a4df` and retires
with the plan. The Owner queue names the unit waiting.

- [x] 0 — the plan committed, and the cc-safe-setup Changelog lines folded
- [x] 1 — `git push` long options read by unique prefix
- [x] 2 — comments made inert before any walker reads the text (rev 4, attempt 2)
- [ ] 3 — heredoc bodies end where bash ends them
- [ ] 3s — an unclosed heredoc body blocks the command (parked: the owner's open decision)
- [ ] 4 — heredoc bodies start where bash starts them

Operational gotchas:

- A poison token in a squash-merge message suppresses the release commit's CI run entirely. Edit
  the squash message before merging; the guard checks commits on a branch, not the message the
  forge composes at merge time (**DC-040**).
- Nothing checks that every version with a changelog entry actually got a tag, so a merged
  release can sit untagged with every rung green (**DA-010**). `scripts/session-start.sh` probes
  the current version's tag every session; `git ls-remote --tags origin` settles any other.

## Owner queue

> **Protected section.** Never delete it, and never silently drop items during compression.
> Items leave only when done, answered or triaged — then delete the item and record the outcome
> as a Changelog line or a ledger row. How to test an item before restating it, and why the
> final chat message must: `docs/RUNBOOK.md` → **Session discipline** 7.

**OPEN — tag the drafted 16.0.0 release after its PR merges.** Tagging is an owner action, and
the README Quick Start names the draft tag before it exists. Check: `git ls-remote --exit-code
--tags origin refs/tags/amh-v16.0.0` — a matching ref resolves this item; no output means the
documented install command is not live yet.

**OPEN — decide whether a heredoc body still open at the end of a command blocks the command
(plan Unit 3s).** Today the guard silently skips everything after such a body. So a delimiter it
misreads, such as `<<E"O"F`, `<<"E O F"` or a backslash-newline inside the delimiter, hides every
later line from every rail. Blocking turns each misread into a refusal; the cost is refusing a
command that bash runs with a warning. Plan Unit 4 corrects the misreads known today, and the net
would cover the ones not yet found. Recommendation: block. The decision is the owner's and still
open; Units 3 and 4, if the owner approves them, run without it.

**OPEN — approve, or not, starting plan Unit 3: heredoc bodies end where bash ends them.** Each
unit of the plan starts only on the owner's explicit approval of that unit, and approving one
unit approves only that one. When a unit lands, this item moves to the next one. Units 3 and 4
each owe a rule-review pass, which the owner has already allowed.

**OPEN — decide whether to plan a fix for a quote inside backticks.** Found while building Unit 2:
bash ends a backtick substitution at the first unescaped backtick, quotes or not, and every walker
in the command guard reads a `'` inside one as opening a string that hides the rest, so
`` echo `echo 'x`; printenv `` passes. No plan covers it; the guard's header names it.
Check: `scripts/command-guard.sh --command "echo \`echo 'x\`; printenv"` — exit status 0 means
it is still open.

**OPEN — decide whether to adopt the harness-research-gaps plan,
`docs/plans/2026-11-01-harness-research-gaps.md`, and each decision in its §1.** It is committed
as a draft, and nothing in it is approved. No unit starts without the owner's approval of that
unit.

## Decided non-items (don't re-litigate without new evidence)

A pointer index, not an argument: **read the cited row before reopening any of these**, because
the row is where the reasoning lives and these lines are deliberately too short to re-litigate
from.

- **Pre-3.0.0:** templated shipped scripts, assurance levels, a packaged CLI, broad
  doc-fact/link guards, section-granular `RULE_FILES`, machine-consumed self-attestations, a
  `git log` rail under branch-train, failing ledger caps, hook-invocation detection, a shipped
  config-schema guard, a `BRANCH_PREFIX` push check (**D-002**, **D-010**, **D-014**, **D-023**,
  **DA-001**, **DA-003**, **DA-022**).
- **RFCs:** capability/profile/probe machinery and a second setup extension (**DA-024**); run
  receipts, transport, CI artifact and status tool (**DA-025**); five provenance-defective
  scenarios and their YAML/oracle/report machinery (**DA-026**).
- **Later:** the top-decile warning (**DB-040**, **DC-003** the adopted alternative); a
  constitution byte cap (**DB-038**); a Python-write advisory (**DC-007**); the 2026-08-10 review
  proposals (**DB-024**); a guard that opens a file to classify it (**DB-027**); a configurable
  ledger-id prefix (**DC-015**); ledger immutability across commits (**DC-020**); a guard that
  judges a State sentence's temporal validity (**DD-006**).

## Changelog

One line per shipped change or completed unit (newest first). Details live in the cited ledger
rows — this section is a pointer index, not a narrative.

- 2026-11-02 — **Owner-queue-closure plan: Unit 2 done, on its second attempt.** A gpt-6-astra
  spec review found inputs that rev 3's inert comments would newly allow, and plan rev 4 folded
  it in. The command guard now judges a command with a `#` twice, comments as text and comments
  inert, and either refusal stands, so `echo a # don't⏎printenv` and a `<<` inside a comment
  are refused (**DD-056**). The backtick queue item's header gap is now named.

- 2026-10-31 to 2026-11-02 — **Owner-queue-closure plan: Units 0 and 1, each approved by the
  owner on its own, are done.** Unit 0 committed the plan; the two queue items asking whether to
  fix the command-guard parse gaps and abbreviated `git push` options were answered (fix both
  inside 16.0.0, one fresh-context review per unit) and left the queue. Unit 1 made the push rail
  read a long option by unique prefix, as git does, and skip the value of an option that takes
  one, so item 3's check, `git push --del origin session/x`, now blocks (**DD-054**).
  Unit 2's first attempt, which removed comments, failed its review on 11 inputs the guard then
  passed and bash ran; it was reversed unshipped, and plan rev 3 redesigns the unit (**DD-055**).

- 2026-10-04 through 2026-10-30 — **15.0.1, 15.1.0 and the 16.0.0 draft so far, folded.** The
  author-identity rung stopped judging the forge's test merge (**DD-036**). Windows drive roots,
  `cmd /c` deletions and PowerShell reached the command guard (**DD-038**, **DD-039**). The
  15.2.0 draft, which 16.0.0 carries whole, and the cc-safe-setup plan's six units hardened the
  Claude hooks and the guard's reading of commands (**DD-040** to **DD-042**, **DD-044** to
  **DD-049**, **DD-051** to **DD-053**); the owner made the draft MAJOR on 2026-10-26
  (**DD-050**). The redaction hook was observed firing (**DD-037**), and the queue was triaged
  to actionable items (**DD-043**). `amh-v15.0.0` and `amh-v15.1.0` were seen on origin on
  2026-10-04 and 2026-10-14. The cc-safe-setup plan is archived in `docs/history/`.

- 2026-07-25 through 2026-09-29 — **Everything before 15.0.1, folded.** Founding through the
  15.0.0 train: portable rails, the constitution rewrite, git-native pre-push enforcement, a
  tree-relative working memory with immutable ledger rows, destructive-deletion denial, and
  output redaction in both adapters (**DD-001** to **DD-035**, **DC-020** to **DC-044**, and the
  volumes for everything older). Seen on origin by 2026-10-04: `amh-v10.0.0`, `amh-v10.2.0`,
  `amh-v14.1.0` and `amh-v15.0.0`; the 10.3.0–10.4.0 and 14.2.0 drafts rode later tags untagged.
