# STATE — project state & session memory

> **Length guard.** Thresholds are in `amh.conf`; the rules for compressing this file are
> `docs/PROTOCOLS.md` → **Working-memory compression**, and they bind whether or not you follow
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
Adopted harness version: **AMH 17.1.0** — see `harness/VERSION`, the copy that counts.

## Current state

Release state: `scripts/session-start.sh` probes the declared version's tag every session.
`docs/LEDGER_D.md` is the live ledger volume.

Live plans, each in `docs/plans/`, where a unit starts only on the owner's explicit approval of
that unit:

- `2026-11-04-spill-guard-borrowings.md`, adopted: S1, S2, S6a and S3 approved on 2026-11-10, to
  run in that order, each with its own review and its version settled when its behaviour is
  final (its §2, items 4 and 5); S4, S5, S6b and S6c deferred.
- `2026-11-10-command-guard-gap-review.md` and `2026-11-09-cc-safety-net-borrowings.md`: drafts,
  nothing approved; G1, one review of both, comes first (Owner queue).
- `2026-11-10-queue-cycle-and-memory-tiers.md`: a draft, nothing approved.
- `2026-11-22-build-output-secret-scan.md`: a draft, B0 done; only B1, its gpt-6-astra `-e high`
  review, is approved (owner, 2026-11-22), and the plan runner runs it (Owner queue).
- `2026-11-23-antigravity-gemini-adapter.md`, adopted: a Gemini CLI and Antigravity adapter,
  every unit done, A5 last, drafting 17.1.0 (**DD-117**); the tag and a live probe of each host
  are in the Owner queue, and the session that merges the train archives the plan.

Operational gotchas:

- A poison token in a squash-merge message suppresses the release commit's CI run entirely. Edit
  the squash message before merging; the guard checks branch commits, not the forge's message
  (**DC-040**).
- Nothing checks that every version with a changelog entry got a tag, so a merged release can
  sit untagged with every rung green (**DA-010**); `git ls-remote --tags origin` settles one.

## Owner queue

> **Protected section.** Never delete it, and never silently drop items during compression.
> Items leave only when done, answered or triaged — then delete the item and record the outcome
> as a Changelog line or a ledger row. How to test an item before restating it, and why the
> final chat message must: `docs/PROTOCOLS.md` → **Session discipline** 7.

**OPEN — decide whether to plan a fix for a quote inside backticks.** Bash ends a backtick
substitution at the first unescaped backtick, quotes or not, while every walker in the command
guard reads a `'` inside one as opening a string that hides the rest; no plan covers it, the
guard's header names it, and it reaches heredoc bodies too (**DD-059**).
Check: `scripts/command-guard.sh --command "echo \`echo 'x\`; printenv"` — exit 0 means open.

**OPEN — the research-gaps plan's remaining decisions; the plan itself is archived in
`docs/history/`.** Whether P6 admits retiring a compensation stays open until one is proposed,
with H5's classification as input (**DD-082**). H8 stays parked: measure an adopter verification
or output failure, reopened only on a recorded adopter incident or an explicit owner exception to
the incident bar. Its advice was one step in `harness/templates/AMH-ADOPT.md` §4 and the seed
`verify.sh` comments that exercises the product as a user would, with green output short and
failures loud; a reopened H8 gets a new plan and keeps strongest-tier rule review. No check
settles it.

**OPEN — run G1, one gpt-6-astra `-e high` review of both command-guard plans,
`docs/plans/2026-11-10-command-guard-gap-review.md` and
`docs/plans/2026-11-09-cc-safety-net-borrowings.md`, then decide adoption of both together and
which units** (owner, 2026-11-10, with N1's mandate, the gap plan's §2, item 2).
Check: `scripts/command-guard.sh --command 'rm -r ~'` — exit 0 means that gap is still open.

**OPEN — run B1, one gpt-6-astra `-e high` review of
`docs/plans/2026-11-22-build-output-secret-scan.md`, then decide on rev 2** (owner, 2026-11-22).
The review's first question is whether the incident bar admits the plan at all (its §2, item 2).
No check settles it.

**OPEN — decide on the queue-cycle plan, `docs/plans/2026-11-10-queue-cycle-and-memory-tiers.md`:
review first (M1), adoption, and the facts its §2, item 3 asks for.** No check settles it.

**OPEN — tag `amh-v17.1.0` once the train carrying 17.1.0 merges** (the adapter plan's A5).
`harness/VERSION` here says 17.1.0; tag the merge commit on `main`, after checking that the
squash message carries no poison token (**DC-040**). Check: `git ls-remote --tags origin
amh-v17.1.0` — a line naming the tag means done; no output with exit 0 means open, and a
non-zero exit means `origin` was not reached and settles nothing.

**OPEN — probe the Gemini CLI and Antigravity adapters on a live host** (the adapter plan's A5).
Nothing in either has been seen firing. On each host, open a scratch repository that has
`amh-init.sh`'s install, with the folder trusted on the Gemini CLI, and see: the session-start
banner reaching the agent; a deny, of `git push --force origin main` through the host's shell
tool, harmless in a scratch repository with no remote if no hook fires; on the Gemini CLI only, a
redaction, of an `echo` of `sk-ant-` followed by 20 or more made-up letters (Antigravity has no
redactor); and on Antigravity, a harmless `git status` still running, since its guard answers
every call `allow` or `deny`. Then append one ledger row per host whose bold lead opens `Live
probe of the Gemini CLI` or `Live probe of Antigravity`, naming the host version and OS, which
checks fired and how the agent saw each, and which **DD-112** cells it settled, such as a hook's
working directory or what a timed-out hook does. In the same unit, move each settled cell out of
that host's *Unverified* line in `docs/RUNBOOK.md` → **Host rails and what they miss**. Check:
`grep -nE '^- D[A-Z]*-[0-9]+( \[cited\])?: \*\*Live probe of (the Gemini CLI|Antigravity)'
docs/LEDGER_*.md` — a host with no row is still unprobed.

**OPEN — decide the N1 review's last recommendation it could not apply:** the cross-plan order
and release placement in that plan's §2, decision 3. H0.5 recommended S1 → S2 → S6a → S3 → N2 →
N6a → N3 → N4 → N5 → N7a → N7b, interleaved with research-gaps units that are now all done. No
check settles it.



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
- **2026-11-19:** a payload-parser fix for a non-UTF-8 code page until a host can test it
  (**DD-069**); a guard for a fix that changes an existing test until an incident earns one
  (**DD-073**); a `find` arm for the permanent targets, N8 (**DD-018**); all three **DD-106**.

## Changelog

One line per shipped change or completed unit (newest first). Details live in the cited ledger
rows — this section is a pointer index, not a narrative.

- 2026-11-24 — **Live-probe fixes: the manifest generator lists the scripts in byte order
  whatever the host's locale, and the shipped suite's JSON-envelope cases close stdin, so neither
  fails nor hangs on an Antigravity Remote Agents VM** (**DD-118**, **DD-119**).
- 2026-11-24 — **Gemini CLI and Antigravity adapter, A5, the last: drafted as MINOR 17.1.0, its
  changelog entry saying the new adapter files are optional and what an upgrade must do first;
  the tag and a live probe of each host are queued** (**DD-117**).
- 2026-11-23 — **Gemini CLI and Antigravity adapter, A4: the runbook's host-rails section says,
  per new host, which rails it has, which it lacks and what binds only as prose, what skips it,
  which files are procedure and what is unverified; the harness prose, README and UPGRADING name
  both hosts** (**DD-116**).
- 2026-11-23 — **Gemini CLI and Antigravity adapter, A3: twelve adapter files ship under
  `.gemini/` and `.agents/`, wired into every list of adapters, with one `adapter-set.sh` check
  per surface; the shipped pointers name the seed's headings, this repository's its own; the hook
  files are read by the sandbox check's tokenizer, which now tracks JSON's grammar** (**DD-114**,
  **DD-115**).
- 2026-11-23 — **Gemini CLI and Antigravity adapter, A2: the command guard and the redactor
  recognise each host's payload explicitly and answer in its documented shape, an unrecognised
  one gets nothing, and `session-start.sh` gains two JSON envelopes; Claude and Codex unchanged**
  (**DD-113**).
- 2026-11-23 — **Gemini CLI and Antigravity adapter, A1: each host's surfaces established from
  vendor docs, nothing measured; the Gemini CLI gets settings, three hooks, skills and a reviewer,
  Antigravity two hooks, rules and a reviewer, and A2 runs** (**DD-111**, **DD-112**).
- 2026-11-23 — **Housekeeping: the research-gaps plan and its eight companions, and the merged
  pipefail plan, archived to `docs/history/`; the Owner-queue items that pointed into the former
  now state H8 and H0.5's order themselves** (no ledger row: nothing is decided).
- 2026-11-23 — **Gemini CLI and Antigravity adapter, A0: a plan committed for a third host
  adapter, every unit approved for the plan runner; the `amh-v17.0.0` tag item left the Owner
  queue, the tag seen on `origin` that day** (no ledger row: nothing is decided yet).
- 2026-11-22 — **Build-output secret scan, B0: a draft plan committed for a ladder rung that runs
  the secret scan over the build output an adopter names, a Resend redaction class and a seed
  sentence on client-exposed variables; B1, its review, is queued** (no ledger row: nothing is
  decided yet).
- 2026-11-18 through 2026-11-19 — **The H4b follow-ups, the PR #75 review fixes F1 to F3 and
  the pipefail race R1, folded** (**DD-097** to **DD-110**; `docs/history/`
  `2026-11-01-harness-research-gaps-h4b-results.md` §5,
  `2026-11-01-harness-research-gaps-h4b-probe.sh`, `2026-11-19-pr75-review-fixes.md` and
  `2026-11-19-pipefail-grep-race.md`).
- 2026-11-13 through 2026-11-17 — **The research-gaps plan's units and H4b follow-ups, folded**
  (**DD-072** to **DD-096**, the plan's §1 and §5, companions
  `2026-11-01-harness-research-gaps-h1-inventory.md`,
  `2026-11-01-harness-research-gaps-h2-relocation.md`,
  `2026-11-01-harness-research-gaps-h3-layout.md`,
  `2026-11-01-harness-research-gaps-h4a-containment.md`,
  `2026-11-01-harness-research-gaps-h5-classification.md` and
  `2026-11-01-harness-research-gaps-h6-runs.md`).
- 2026-07-25 through 2026-11-12 — **Everything before that, folded.** Founding through the
  17.0.0 draft (**DD-001** to **DD-073**, **DC-020** to **DC-044**, and the volumes before them;
  `docs/history/`).
