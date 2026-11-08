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
Adopted harness version: **AMH 16.1.0** — see `harness/VERSION`, the copy that counts.

## Current state

This tree declares **16.1.0**, MINOR: the command guard's deletion rail reads through `xargs`
(**DD-062**); the guard has an optional user-level machine mode (**DD-063**),
which the adoption brief and the upgrade prompt offer and refresh only on the owner's yes
(**DD-066**); and a `git -C`
statement in PowerShell text no longer downgrades a deletion after it (**DD-064**); and a
`json.py` in the session's folder no longer stands the guard down (**DD-065**). Each
`harness/CHANGELOG.md` entry names what its version carries. Whether this
draft is tagged or released is not recorded here — `scripts/session-start.sh` probes it every
session and reports present, absent or could-not-ask, which is the only answer that can be
right twice.

`docs/LEDGER_D.md` is the live ledger volume.

`docs/plans/2026-10-31-owner-queue-closure.md` has every unit done. Its Phase A merge and tag
were seen on origin on 2026-11-08, and A5, retiring it together with
`docs/plans/2026-11-02-unit2-attempt-1.patch`, is what remains.

Multi-unit work, planned: `docs/plans/2026-11-04-spill-guard-borrowings.md`. It closes the
credential-handling gaps that comparing AMH with spill-guard exposed. The owner adopted its four
selected units on 2026-11-04, first for the 16.0.0 draft and then, the same day, for the release
after it; S4, S5, S6b and S6c stay deferred. Each unit gets one fresh-context review pass. **Each unit starts only on the owner's
explicit approval of that unit**; none is approved yet. The Owner queue names the unit waiting.

- [x] S0 — the plan committed (rev 2)
- [ ] S1 — refusal text does not repeat a supported credential shape (awaiting approval)
- [ ] S2 — private-key bodies under a line prefix
- [ ] S6a — options on the wrappers the guard already peels
- [ ] S3 — four token shapes

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

**OPEN — decide when the 16.1.0 draft is complete, then merge and tag it.** It holds the
`xargs` unit (**DD-062**) and the machine-mode unit with the two fixes it surfaced
(**DD-063** to **DD-065**), and the unit that has adoption and every upgrade ask about it
(**DD-066**). The spill-guard units below are slated for the release after 16.0.0,
so whether they join this draft first is the owner's call. Then: open its PR (or ask for
it), edit its squash message — a poison token in GitHub's default one suppresses the release
commit's CI run (**DC-040**) — merge, and tag; the README Quick Start names the draft tag before
it exists. Check: `git ls-remote --exit-code --tags origin refs/tags/amh-v16.1.0` — a matching
ref resolves this item; no output means the documented install command is not live yet.

**OPEN — decide whether to fix the interpreter and hook-file advisories going silent with no
digest tool.** Found by the `xargs` unit's review: their comment in `scripts/command-guard.sh`
says such an advisory re-fires, but `interpreter_signature` failing returns before it fires, and
the same comment cites DC-004 for the one-shot rule DB-030 states. Reported by that reviewer,
measured with a `PATH` holding no `sha256sum`, `shasum` or `cksum`; no one-line check here.

**OPEN — decide whether to plan a fix for a quote inside backticks.** Found while building Unit 2:
bash ends a backtick substitution at the first unescaped backtick, quotes or not, and every walker
in the command guard reads a `'` inside one as opening a string that hides the rest, so
`` echo `echo 'x`; printenv `` passes. No plan covers it; the guard's header names it.
Check: `scripts/command-guard.sh --command "echo \`echo 'x\`; printenv"` — exit status 0 means
it is still open. Unit 4 now reads heredoc bodies as bash does, so this gap also reaches a
command whose body the guard used to misread and refuse (**DD-059**).

**OPEN — decide whether to fix three gaps the machine-mode review found outside its unit.** (1)
`scripts/redact-tool-output.sh` starts its Python with `-c` and no `-I`, so a `json.py` in the
session's folder replaces the JSON module there too (the class **DD-065** fixed in the command
guard); redaction then stands down, fail-open by design. (2) `scripts/guards/adapter-set.sh`'s pins
on the project Claude adapter read each hook's lines but not the event key above them: the reviewer
renamed `PreToolUse` to `Stop` in both copies and the guard passed. The machine template's pin now
reads it. (3) The adapter's `Read(/proc/*/environ)` rails start with one slash, which in a settings
file names a path beside that file, so they may never reach `/proc`; the machine template adds
`//proc` spellings, and nobody has checked either against the host. Check for (1):
`grep -c '"$PY" -c ' scripts/redact-tool-output.sh` — a count above 0 means it is still open.

**OPEN — decide whether to adopt the harness-research-gaps plan,
`docs/plans/2026-11-01-harness-research-gaps.md`, and each decision in its §1.** It is committed
as a draft, and nothing in it is approved. No unit starts without the owner's approval of that
unit.

**OPEN — approve, or not, starting spill-guard plan Unit S1: refusal text does not repeat a
supported credential shape.** The plan is adopted for the release after 16.0.0 (its §2), and S1
is its first unit.
Each unit starts only on the owner's explicit approval of that unit, and approving one approves
only that one. When a unit lands, this item moves to the next. Check for S6a's gap, which the
plan raised: `scripts/command-guard.sh --command 'nice -n 5 rm -rf ~'` — exit status 0 means a
wrapper option still takes a deletion of the home directory past the permanent denial.

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

- 2026-11-08 — **Adoption and every upgrade ask about machine mode, inside the 16.1.0 draft.**
  On the owner's report that the brief only mentioned it and the upgrade procedure never named
  it: the brief's last step asks and, on an explicit yes, stages, checks, moves and merges; the
  upgrade prompt compares an installed copy on every upgrade and refreshes it only on a yes; the
  constitution and seed say installing one takes that yes (**DD-066**).

- 2026-11-08 — **The command guard gets a user-level machine mode, inside the 16.1.0 draft.** On
  the owner's ask after a reported drive wipe from a scratch project: `--machine` keeps only the
  permanent deletion denials, the credential rails and the unread-command refusals, writes no
  state and reads no `amh.conf`, with a Claude Code fragment the owner merges by hand (**DD-063**).
  Its fixtures surfaced, and the unit fixes, a PowerShell `git -C` statement downgrading a
  drive-root or home deletion after it (**DD-064**); its review surfaced a `json.py` in the
  session's folder standing the guard down (**DD-065**). The harness-research-gaps plan's H4a and
  §3 row 9 note what this settles and what it does not.

- 2026-11-08 — **The command guard's deletion rail reads through `xargs`, drafted as 16.1.0.**
  On the owner's ask after a reported `xargs rm -rf` that deleted `~/Library` on macOS: every
  deletion verb behind `xargs` gets the one-time advisory, its target unknown and its key the
  command text, and `xargs rm -rf ~` stays denied (**DD-062**). Two queue items left as done:
  `amh-v16.0.0` was seen on origin, and the 16.0.0 PR merged on 2026-11-06.

- 2026-10-31 through 2026-11-06 — **The rest of the 16.0.0 train, folded.** The
  owner-queue-closure plan's units: `git push` long options read by unique prefix (**DD-054**);
  comments judged under two readings, on a second attempt (**DD-055**, **DD-056**); heredoc
  bodies that end and start where bash ends and starts them, and an unclosed one refused
  (**DD-057** to **DD-060**, `docs/history/2026-11-05-unit4-review-and-fix.md`). The hook-file
  fold's macOS hang was fixed and CI jobs end at 30 minutes (**DD-061**). The spill-guard plan
  was committed and adopted for the release after 16.0.0.

- 2026-07-25 through 2026-10-30 — **Everything before that, folded.** Founding through the
  16.0.0 draft: portable rails, the constitution rewrite, git-native pre-push enforcement, a
  tree-relative working memory with immutable ledger rows, destructive-deletion denial, output
  redaction, Windows and PowerShell coverage, and the cc-safe-setup hardening (**DD-001** to
  **DD-053**, **DC-020** to **DC-044**, and the volumes for everything older; the cc-safe-setup
  plan is archived in `docs/history/`). Seen on origin by 2026-10-14: `amh-v10.0.0`,
  `amh-v10.2.0`, `amh-v14.1.0`, `amh-v15.0.0` and `amh-v15.1.0`; the 10.3.0–10.4.0 and 14.2.0
  drafts rode later tags untagged, and 16.0.0 carried the 15.2.0 draft whole.
