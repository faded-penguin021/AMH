# PLAN — close the gaps a harness-engineering survey found in AMH

> **Status: rev 3, written 2026-11-09 (H0.5's fold). Adopted by the owner on 2026-11-09; §1 says
> which decisions are answered.** No unit starts without
> the owner's explicit approval of that unit; adopting the plan approves no unit. When the owner
> says to start a unit, the session first tells the owner which decisions that unit needs, if any,
> and does not start it until they are answered.
> Rev 3 folds in H0.5, a gpt-6-astra review of rev 2 at `-e high` (verdict REVISE_PLAN, 18
> findings), with authority over this plan (§5, H0.5). Rev 2 had folded in an external review of
> rev 1 (verdict REVISE_PLAN, nine findings). Each factual claim was replayed or read back before
> it was applied (§7).
> **Every measurement in §2 is re-taken when the unit that acts on it starts.**
> Amended 2026-11-08 without a new revision: the command guard's machine mode (**DD-063**) was
> built at the owner's direct request, outside this plan and approving none of it. It partly
> answers H4a's settings-scope question and changes no verdict in §3. The lines that say so are
> in §3 row 9 and in H4a.

The plan is provisional while it is live. Its durable outcomes go to Changelog lines and ledger
rows. Code cites ledger rows and never this file, and no ledger row may cite this file's path.
When the work is done, archive this file to `docs/history/` or delete it (`docs/RUNBOOK.md` →
**Session discipline** 5).

Unit names carry an `H` prefix so they cannot be confused with the owner-queue-closure plan's
Units 0–4.

## 1. Owner decisions this plan needs

1. **Whether to adopt it, and when.** **Answered by the owner on 2026-11-09: adopted**, after that
   plan's Phase A shipped and tagged 16.0.0, so nothing here rides that draft.
2. **Version semantics for each unit** (**Session discipline** 7(c)). H3 changes the adopter
   file layout and H4b changes what an adopter's agent can do, so each is at least MINOR and
   possibly MAJOR. **H4b answered by the owner on 2026-11-13: it folds into the 17.0.0 draft**
   (**DD-079**). **Answered for the whole plan on 2026-11-13, when H2 started: every unit goes to
   17.0.0** (**DD-080**).
3. **H2: which constitution content stays loaded every session.** `AGENTS.md` makes relocating a
   live rule a change to legislation, and makes a bulk relocation the owner's decision.
   **Answered by the owner on 2026-11-13:** every binding item stays; the description and
   rationale items of A042, A026 and A003 move to a task-triggered runbook section; the seed
   waits for H3 (**DD-080**).
4. **H3: the adopter file layout and how existing installs migrate** (§5, H3). **Answered by
   the owner on 2026-11-13, when H3 started:** option (a), named `docs/PROTOCOLS.md`; existing
   installs migrate by hand from the release's Upgrading notes; this repository's runbook gets
   the same split; and the `light` profile is removed, so a light install that upgrades becomes
   standard (**DD-081**). The companion `docs/plans/2026-11-01-harness-research-gaps-h3-layout.md`
   holds the layout, the reading-obligation comparison and the migration.
5. **H4a: the platform matrix, and above all what native Windows gets.** Per Claude Code's
   sandboxing documentation (§8), native Windows runs commands unsandboxed, and **DD-038**
   happened on native Windows PowerShell 5.1. H0.5 widened the options into a host-specific list,
   in §5, H4a; every selection among them stays the owner's. Also for H4a: which settings scope
   carries the sandbox, whether
   the sandbox is on by default or opt-in for adopters, and whether any host dependency it needs
   (such as the optional seccomp filter on Linux and WSL2) is approved ("Add no dependency
   without owner approval"). **Answered by the owner on 2026-11-13, when H4a started:** native
   Windows under Claude Code gets no sandbox and the docs say so; the project settings file
   carries the sandbox; it is on for fresh installs, with an upgrading note that has an existing
   adopter's agent ask the user; and bubblewrap, socat and the seccomp filter are approved as
   optional host tools (**DD-078**).
6. **H5: whether P6 admits retiring a capability compensation at all.** **Left open by the owner
   on 2026-11-13, when H5 started:** it is decided when a specific retirement is proposed, and
   H5's classification is its input (**DD-082**). For H5's owed pass the owner chose one
   gpt-6-astra review at high effort.
7. **H6a, H6b and H7: the owner launches subject runs** (**DB-024**), picks the models, and
   decides whether H6b is worth building at all.
8. **One fresh-context reviewer, at the strongest available tier, for each legislation unit:
   H2, H3, H4b, H5, H6b, H7 and H8.** **Answered by the owner on 2026-11-09, and widened: a
   fresh-context review is pre-allowed for every unit**, so a unit whose "Pass owed" line says none
   may still take one. It stays one reviewer at a time, and it blocks (`docs/RUNBOOK.md` →
   **Session discipline** 1). Everything under `harness/templates/`, every guard and
   every adapter permission rail is legislation, whatever the diff's size (`docs/RUNBOOK.md` →
   **Rule-review protocol**). This lifts the standing no-subagents instruction for exactly that
   pass. H4b's rule-review and adversarial checklists go to **one** combined blocking pass, so
   the bound of one pass per unit holds.
9. **H2: what evidence is enough to move a rule at all.** H1 measures volume; byte reduction alone
   is not incident evidence (§5, H2). **Answered by the owner on 2026-11-13:** the always-loaded
   text is too big, as the survey's principle 4 says; no incident was claimed (**DD-080**).
10. **H8: whether to grant an incident-bar exception.** H0.5 parked it (§6).
11. **H9: what to do about what it finds.** H9 measures and routes; a fix is a separate decision.

## 2. What was measured

The table below is historical: taken on 2026-11-01 at `ba1f40a`, unless the line says otherwise.
§2.1 holds the 2026-11-09 re-measurement, and a unit acting on a number re-takes it first. Byte counts measure text volume. They are not observed token consumption or
behavioural cost. Token figures are **estimated** at about 4 bytes per token. Figures from
outside AMH are **reported**, and §8 says where.

| What | Command | Result |
|---|---|---|
| Constitution size | `wc -c -l AGENTS.md` | 14,622 B, 188 lines |
| Constitution structure | `awk 'BEGIN{RS=""} END{print NR}' AGENTS.md`; `grep -c '^- ' AGENTS.md`; `grep -c -E '^[0-9]+\. ' AGENTS.md` | 15 blank-line-separated records; 30 bullets and 7 numbered items, so 37 top-level list items: several rules share one record |
| Working memory, read in full every session | `wc -c docs/STATE.md` | 13,869 B |
| Session discipline (binding every session) | `awk -v h='## Session discipline' 'index($0,h)==1{p=1;next} p&&/^## /{exit} p' docs/RUNBOOK.md \| wc -c` | 10,359 B |
| Rule-review protocol (owed by legislation diffs) | `awk -v h='## Rule-review protocol' 'index($0,h)==1{p=1;next} p&&/^## /{exit} p' docs/RUNBOOK.md \| wc -c` | 9,378 B |
| Text a session must read before work: constitution + STATE + Session discipline | sum of the three rows above | 38,850 B, plus the banner. About 9.7k tokens, estimated. |
| Adopter seed constitution | `wc -c harness/templates/seed/AGENTS.md` | 19,420 B |
| Adopter seed runbook | `wc -c harness/templates/seed/docs/RUNBOOK.md` | 31,346 B |
| The light profile's instruction to adopters | read: `harness/templates/AMH-ADOPT.md` §1 | "fold the guidance the runbook would have carried — the playbooks, session discipline, the review protocols — into the constitution" |
| How the installer treats an existing seed or adapter file | read: `install_file` and the `keep` calls in `scripts/amh-init.sh` | an existing file under the `keep` policy is never overwritten. Seeds and both agent adapters use `keep`, so a changed template never reaches an existing adopter. The reviewer reports a measured run of `install_file` that kept a partial `docs/RUNBOOK.md`. |
| Navigation guard scope | read: `scripts/guards/doc-navigation.sh` | nine hard-coded pointer/heading pairs. A new pointer is checked only once it is added to that list. |
| Scenario fixtures' constitutions | `awk` extract of each `cat >"$BUILD/AGENTS.md"` heredoc in `conformance/scenarios/*/fixture.sh` \| `wc -c` | 632 B and 781 B, four rules each, written literally by the fixture. No line in either `fixture.sh` names a runbook, so the repository's own `AGENTS.md` never reaches a subject. |
| Command guard | `wc -l -c harness/templates/scripts/command-guard.sh` | 8,073 lines, 426,239 B |
| Guard fixture suite | `wc -l harness/templates/scripts/test-ladder-guards.sh` | 3,349 lines |
| Release cadence | `grep -c '^## ' harness/CHANGELOG.md` | 43 version headings, from 1.8.0 (2026-07-25) to 16.0.0 (2026-10-26) |
| Host sandbox in the Claude adapter | top-level keys of `.claude/settings.json` | `$comment`, `permissions`, `hooks`. This repository configures no sandbox, which says nothing about the host's own effective settings. |
| Host sandbox in the Codex adapter | `.codex/config.toml` | hooks only. The one `sandbox_mode` in the tree belongs to the read-only reviewer agent. |
| Guards-only ladder on a green tree | `scripts/ladder.sh --guards-only` | exit 0, 33 s, 52 lines, 2,916 B |
| Full ladder on a green tree | `scripts/ladder.sh` | exit 0, 819 s, 332 lines, 20,784 B, of which 239 are passing-fixture `ok` lines. This plan file appeared partway through the run, and the banner says so. |
| Guard refusal shape | `git push --force origin feature` sent to `scripts/command-guard.sh` as hook JSON | exit 2. The message names P7, says why, and gives the safe alternative. |
| Rules marked prose-only | `grep -c -i 'prose-only\|prose only\|stays prose\|stays a prose'` | AGENTS.md 2, RUNBOOK 9, principles 8, seed AGENTS.md 2, seed RUNBOOK 6. These count matching lines, not rules. |
| Behavioural evidence | read: `conformance/README.md`, "What this demonstrates" | two scenarios exist. The recorded claim covers **scenario 02 only**: six owner-accepted runs on one model. |
| Recorded incidents about context cost | `grep -i -E 'context window\|context budget\|usage window\|always-loaded\|read in full every\|context cost\|token budget\|attention' docs/LEDGER*.md` | one hit, **DB-038**, which is about what the constitution holds rather than what it costs. A row worded differently would not match. |

### 2.1 Re-measured 2026-11-09 at `9e1a0f2` (16.1.1)

Replayed by the implementing session from H0.5's commands, except where the row says otherwise.

| What | Command | Result |
|---|---|---|
| Sizes | `wc -c -l AGENTS.md docs/STATE.md harness/templates/seed/AGENTS.md harness/templates/seed/docs/RUNBOOK.md harness/templates/scripts/command-guard.sh harness/templates/scripts/test-ladder-guards.sh` | AGENTS 15,274 B / 194 lines; STATE 9,551 B; seed AGENTS 19,964 B; seed RUNBOOK 31,346 B; command guard 524,062 B / 9,920 lines; fixture suite 3,427 lines |
| Constitution structure | the §2 `awk` and `grep -c` lines | 15 records, 30 bullets, 7 numbered items |
| Session discipline; Rule-review protocol | the §2 `awk` lines | 11,172 B, now 12 items; 9,378 B |
| Text a session must read before work: constitution + STATE + Session discipline | sum | 35,997 B. Text volume, not observed token consumption. It fell because STATE did. Nothing shows that changed behaviour. |
| Release cadence | `grep -c '^## ' harness/CHANGELOG.md` | 45 version headings |
| Lines marked prose-only | the §2 `grep -c` | unchanged: 2, 9, 8, 2, 6 |
| Refusal shape | `scripts/command-guard.sh --command 'git push --force origin feature'` | refused, `BLOCKED by the AMH command guard` |
| Scenario fixture constitutions; context-cost ledger search; adapter sandbox keys | reported by H0.5, its commands kept in the review | 632 B and 781 B, no runbook named; DB-038 the only match, which proves nothing about differently worded rows; no sandbox key in either adapter |
| Ladder under a failing `mktemp` | reported by H0.5 from a read-only sandbox; mechanism read at `scripts/ladder.sh:104` and `scripts/guards/placeholder-integrity.sh:25` | scratch creation failed, clean citation, secret-scan and placeholder lines still printed, and the ladder exited 1. Not reproduced in a writable tree (H9). |

The full-ladder and guards-only timings in §2 are historical; neither was re-run for H0.5.

## 3. Assessment: AMH against the survey's principles

Verdicts: **strong** means AMH already does what the survey found works; **partial** means it
does part of it; **gap** means it does not. The external sources are listed in §8. None of them
is evidence about AMH itself.

| # | Principle | Verdict | Where AMH stands |
|---|---|---|---|
| 1 | Verification is the biggest lever | strong here; partial for adopters | One entrypoint that CI also runs, binary acceptance, a fixture for every guard. H9 measures one unchecked-rung report under a failing `mktemp`. For adopters, `AMH-ADOPT.md` §4 asks only for "build, test and lint". It says nothing about end-to-end checks or about keeping green output short. |
| 2 | The checker is not the doer; prefer deterministic checks | strong | P12: a fresh-context reviewer, one blocking pass, no self-review for rule diffs. The Codex reviewer is instructed read-only, with a configured read-only sandbox that inherited overrides may broaden. Guards are deterministic. |
| 3 | Guides and sensors together | strong where an artifact exists; intentional prose boundary elsewhere, behavioural evidence limited | Guard refusals carry the rule and the fix (measured). P3 leaves a rule with no artifact as prose with no sensor. Two prose rules have a behavioural scenario, and only one of those has recorded subject runs. |
| 4 | Context is a budget; always-loaded text should be a short map | partial; behavioural cost unmeasured | Routing exists and mandatory text volume is measurable, but size alone does not establish a defect (**DB-038**). About 36 KB of text must be read before work (§2.1). The adopter seed constitution is bigger than this repo's, and the light profile tells adopters to fold the runbook into it. The constitution also carries host-specific detail to every host. In AMH's favour: the ETH study found context files useful for non-standard practices, which is what AMH's rules are. The open question is which content must be in front of every session. |
| 5 | Grow from failures; delete what stops earning its keep | strong at adding; partial at deleting | The incident bar is the survey's ratchet. AMH does remove things: the changelog records the former ledger warning band being removed. But nothing re-tests a compensating rule when models change, and P6 deliberately resists stripping scaffolding. |
| 6 | State outside the context window | strong | STATE, the ledger, the checkpoint invariant and the session banner are close to Anthropic's long-running pattern. One difference, a smoke test before new work, is parked (§6). |
| 7 | Compact, instructive interfaces | strong for what AMH owns | The host supplies the tools. Guards-only output was compact when measured at `ba1f40a`, and refusals are instructive. |
| 8 | Make the system visible to the agent | strong for harness state | The banner reports present, absent or could-not-ask, and "configured, never observed". H9 covers a rung that reports clean without having checked. |
| 9 | Safety from architecture, not instructions | partial; AMH-declared OS containment absent, effective host containment unverified | The in-agent rails are many, and the README says honestly that they are not a sandbox. Neither adapter configures its host's sandbox, and that absence does not establish an unsandboxed session: a host can sandbox by its own defaults. **DD-038's class** — a deletion that lands somewhere the agent did not mean — is what filesystem isolation contains on platforms where the sandbox runs. **DD-038 itself** ran on native Windows, where Claude Code's sandbox does not run (§8), so turning the sandbox on would not have contained that incident. Machine mode (**DD-063**) now puts the guard's permanent deletion denials and credential rails in front of every Claude Code session on the machine, not only those in an AMH repository. It is still an in-agent rail, so the verdict stands. |
| 10 | Keep writes single-threaded | strong | Strictly sequential work (**D-009**), one blocking reviewer, a read-only reviewer. |
| 11 | Measure the harness itself | partial | Guard coverage is measured by removing the behaviour and watching a fixture fail. Behavioural evidence is one scenario, one model, six runs (§2). Nothing measures what the harness costs a session, or whether a rule changes behaviour across models. |

## 4. Four lessons the units are built on

1. **Keep AMH's incident bar; it is the survey's own best finding** — everywhere except the
   command guard, which the owner exempted on 2026-11-10 and P13 now exempts (**DD-074**): a gap
   in it is fixed as a defect or gated, as a widening, by a measurement of what it would newly
   refuse. No unit of this plan changes the command guard. A unit with an AMH incident
   behind it may change rules or guards. A unit backed only by outside evidence measures first,
   and anything it finds still goes to the owner. Items with neither are parked (§6).
2. **Classify obligations, not containers.** One mechanism or one Session discipline item
   often holds an enduring invariant (owner authority, immutable pushed history, missing
   evidence in squash-merged history) next to a reminder or procedure that compensates for
   model behaviour. Only the compensating part is a candidate for retirement, and only on
   evidence. A newer model passing a scenario does not show that the weakest supported agent no
   longer needs it. This is the per-rule-not-per-mechanism point **DB-024**(a) already made.
3. **A rule moved out of the constitution is repealed unless something still makes it bind.**
   That needs three things: the destination binds, the constitution names it, and an agent
   will actually read it at the moment the rule applies. An adapter comment is not loaded agent
   instructions. Identical words under historical commentary are not the same rule. Even when
   all three hold, the move is the owner's call.
4. **Configuration is not containment, and a check of the configuration is not a check of the
   runtime.** A key in a checked-in file proves only that this repository asks for a setting.
   What runs depends on the host's settings precedence, the platform, fallback behaviour and
   which tools the sandbox covers at all. Claims are made per platform and per execution path,
   and each one is tied to the probe that showed it.

## 5. The units: H0, H0.5, H9, H1, H4a, H4b, H2, H3, H5, H6a, H6b, H7

**Order: H0.5 → H9 → H1 → H4a → H4b → H2 → H3 → H5 → H6a → optional H6b → H7.** H8 is parked (§6).
H1 does not block H4a, a blocked owner choice does not stall an independent unit, and every unit
still needs its own approval. The order across this plan and the other two is the owner's (§7, F18).
For H2, H5, H6b, H7 and any reopened H8, the strongest-tier rule-review pass adds adversarial
coverage within that same pass when the unit's intended machinery requires it.

### H0 — commit the plan (docs-only): done 2026-11-01, as an open draft

- **Done:** at the owner's request, with no decision made. `docs/STATE.md` gained one
  Owner-queue item pointing at this file, and nothing else. A STATE checklist waits until the
  owner approves the plan (**Session discipline** 5).
- **Pass owed:** none beyond the ladder. The plan is not legislation.
- **Acceptance:** `scripts/ladder.sh --guards-only` green.

### H0.5 — review this plan with gpt-6-astra at `-e high` (docs-only; added by the owner): done 2026-11-09

- **Why:** the owner's ask when adopting the plan. Rev 2 predates 16.1.x and the two later plans
  that touch the same files.
- **Mandate, answered by the owner on 2026-11-09: as N1 had for the cc-safety-net plan.**
  - **Inside the grant:** every recommendation and verdict this plan makes, each unit's scope, tier,
    fixtures, acceptance and place in the order, and what counts as enough evidence. The reviewer
    may add, rewrite, merge, split, reorder or delete units.
  - **Outside it, recommendation to the Owner queue only:** the owner's answers in §1 and the
    decisions §1 leaves open; ledger rows and the STATE Decided non-items; the `AGENTS.md` hard
    boundaries; the spill-guard and cc-safety-net plans, and the order across plans.
  - **Not granted:** approval to execute any unit.
- **Reads:** this plan, the tree it describes as it stands now, and current host sandbox
  documentation staged for it, which is data. Its sandbox has no network.
- **The fold:** decisions inside the mandate are applied as written, as rev 3. Factual claims are
  replayed or read back first. Recommendations outside it go to the Owner queue.
- **Pass owed:** this unit is the pass. One fresh-context reviewer, read-only; nobody reviews it
  again.
- **Acceptance (binary):** rev 3 is committed; §7 has a row for every finding; each recommendation
  outside the mandate is an Owner-queue item; `scripts/ladder.sh --guards-only` passes.
- **What ran:** gpt-6-astra at `-e high`, read-only, at `9e1a0f2`, with no wall-clock budget. Its
  limits: no network, so it read the documentation staged on 2026-11-09 (§8); its own guards-only
  replay failed on scratch files, which is H9's evidence; no live sandbox probe and no subject run. A gpt-6.1-sol check of
  the fold's fidelity to the findings, not a second review of the plan, followed; its nine items
  were applied.

### H9 — measure what the verifier reports when scratch creation fails (measurement; added by H0.5): done 2026-11-09

- **Why:** principles 1 and 8. H0.5's read-only replay saw clean citation, secret-scan and
  placeholder lines after failed `mktemp` calls. The ladder still exited 1, so no overall false
  pass is claimed. `TMP=$(mktemp -d)` is unchecked at `scripts/ladder.sh:104`, and
  `scripts/guards/placeholder-integrity.sh:25` has the same shape.
- **Do:** in a disposable fixture, make `mktemp` fail without changing any production file. Test
  ladder startup and the standalone placeholder guard, with a writable control. Record exit
  statuses, attempted paths and each rung's message.
- **Output:** a reproducible characterization and a disposition routed to the owner (§1 item 11).
  It repairs nothing. A later fix must stop reporting unchecked success, avoid writes derived from
  an empty scratch path, carry a fixture that fails without the behaviour, and take a combined rule
  and adversarial pass. No runtime manifest or attestation mechanism is proposed.
- **Pass owed:** one combined rule and adversarial pass on the disposition, even if it concludes no
  fix is needed (`docs/RUNBOOK.md` → **Session discipline** 10).
- **Acceptance:** the characterization replays from its recorded commands, and the Owner-queue item
  exists.
- **Result, measured 2026-11-09 at `6fb6076`, as a non-root user on Linux, one throwaway clone per
  case.** The "no overall false pass" above held only because every `mktemp` failed at once, and
  even then the red came from three rungs that have nothing to do with the scratch path. One of
  them, `path-refs.sh`, is repo-local, so an adopter install has only the two rail self-tests, and
  `redact-tool-output.sh` stands its self-test down with a SKIP when no Python 3 is present
  (`redact-tool-output.sh:414`; estimated by reading, no adopter install was built):

  | `mktemp` failing | Tree | Exit | What was reported |
  |---|---|---|---|
  | none (control), guards-only and full | clean | 0 | green; 51 citations resolve |
  | every call, by shim or by `TMPDIR` on a missing directory, guards-only and full | clean | 1 | three FAILs, all elsewhere: the `command-guard.sh` and `redact-tool-output.sh` self-tests and `path-refs.sh`. `scripts/verify.sh` not reached |
  | only `scripts/ladder.sh:104` | clean | 0 | `ok  citation(s) resolve`, with the count blank, and `ok no credential-shaped strings`; one spurious WARN about ledger volumes |
  | none (control) | planted bad citation and credential-shaped string | 1 | three FAILs naming both defects |
  | only `scripts/ladder.sh:104` | same plants | **0** | the same two `ok` lines, and `✓ guards clean (1 warning(s))` |
  | only `scripts/ladder.sh:104`, full ladder | same plants | **0** | the same two `ok` lines, `verification set: clean` and `✓ ladder green (1 warning(s))` |
  | none (control) | a new ledger row of 13 sentences | 1 | `new ledger row runs to 13 sentences` |
  | only `scripts/ladder.sh:104` | same plant | **0** | the rung prints nothing, and `✓ guards clean` |
  | none (control) | the state file committed above the 14 KB trigger, then shrunk 1200 bytes | 1 | `unfinished compression pass` |
  | only `scripts/ladder.sh:104` | same plant | **0** | the rung prints nothing, and `✓ guards clean` |
  | none (control), standalone placeholder guard | planted undocumented placeholder | 1 | names `H9_PLANTED` |
  | every call, standalone placeholder guard | same plant | **0** | ` placeholder(s) documented, none left unfilled`, with the count blank |
  | both of that guard's, inside a guards-only ladder | same plant | **0** | `ok placeholder-integrity.sh — mktemp: simulated failure` and `✓ guards clean` |
  | calls from `ledger-append-only.sh` | clean | 0 | no `mktemp` call, so nothing failed: it exits 0 earlier on an unchanged ledger |
  | calls from `ledger-append-only.sh` | planted row edit | 1 | red because its writes fail, not because it found the edit: `mkdir: cannot create directory '/head-tree'` |

  **Attempted paths** with `$TMP` empty: `/state-head`, `/chain`, `/scanfiles`, `/scanfiles.t`,
  `/rows`, `/rows.raw`, `/marked`, `/cited`, `/files.nul`; when a ledger volume differs from HEAD,
  also `/head-ledger`, `/work-ledger`, `/head-rows`, `/work-rows`, `/head-chain` and
  `/head-ledger/docs/LEDGER.md`; and `/head-tree` in the ledger guard. These come from the shell's
  own errors and a `bash -x` trace; `/redact.base` and `/cmp.err` are assigned but not written, because the file list
  is empty. The root listing was unchanged after all 26 cases. `rm -rf "$TMP"` on the empty string
  deletes nothing. **Not measured:** a host where `/` is writable, here unavailable (non-root, user
  namespaces refused), where by reading those writes would succeed and be left behind.
  The suites' own `WORK=$(mktemp -d)` are unchecked too (`test-ladder-guards.sh:16`,
  `local-guards.sh:29`, `test-init-e2e.sh:33`; with `WORK` empty, `test-init-e2e.sh:35` sets `HOME`
  to `/home`). The ladder reaches them only through `scripts/verify.sh` (`ladder.sh:1790`), after
  every guard passed. So the replay runs the full ladder under an every-caller failure only after
  the guards-only run of that variant exited 1. Under the single failure, its shim also requires the
  clone root as the caller's working directory, so the fixture ladders the suites run keep a real
  `mktemp`.
- **Replay:** save the block below as `h9-replay.sh` outside the repository, then
  `bash h9-replay.sh <clone-of-this-repo> 6fb6076 <empty-output-dir>`; `summary.txt` there has each
  exit status, and each case's `.log` and `.mktemp` files have its messages and calls.

```bash
#!/usr/bin/env bash
# H9 replay: what the ladder and two guards report when mktemp fails.
# usage: h9-replay.sh <source-repo> <commit> <output-dir>
# Every case runs in its own throwaway clone with a throwaway HOME. No file in <source-repo>
# changes. The full ladder runs under an every-caller failure only after the guards-only run of
# that same variant exited 1, because scripts/verify.sh's suites do not check their own mktemp.
set -uo pipefail
SRC=$1 REV=$2 OUT=$3
# With an empty scratch path the ladder writes at the filesystem root, so this runs only where
# those writes cannot land.
if [ -w / ]; then
	echo 'refusing: / is writable here, and the failing cases would write to it' >&2
	exit 1
fi
mkdir -p "$OUT" || exit 1
W=$(mktemp -d "$OUT/work.XXXXXX") || exit 1
SHIM=$W/shim
REAL_MKTEMP=$(command -v mktemp)
mkdir -p "$SHIM" || exit 1
cat >"$SHIM/mktemp" <<EOF
#!/bin/sh
parent=\$(tr '\\0' ' ' </proc/\$PPID/cmdline)
pcwd=\$(readlink /proc/\$PPID/cwd)
case "\$parent" in
*"\$H9_FAIL_ONLY"*)
	if [ -z "\${H9_CWD:-}" ] || [ "\$pcwd" = "\$H9_CWD" ]; then
		printf 'FAILED  %s <- %s (cwd %s)\\n' "\$*" "\$parent" "\$pcwd" >>"\$H9_LOG"
		echo 'mktemp: simulated failure' >&2
		exit 1
	fi
	;;
esac
printf 'passed  %s <- %s (cwd %s)\\n' "\$*" "\$parent" "\$pcwd" >>"\$H9_LOG"
exec "$REAL_MKTEMP" "\$@"
EOF
chmod 755 "$SHIM/mktemp" || exit 1
ls -A / | sort >"$OUT/root-before.txt"
: >"$OUT/summary.txt"

fresh() {
	local c=$W/$1/repo
	mkdir -p "$W/$1/home" || return 1
	git clone -q --no-local "$SRC" "$c" || return 1
	git -C "$c" fetch -q "$SRC" "+refs/remotes/origin/main:refs/remotes/origin/main" || return 1
	git -C "$c" checkout -q -B session/h9-replay "$REV" || return 1
	printf '%s' "$c"
}

none() { :; }
plant_citation_and_secret() {
	printf '# see DD-9999\n' >>"$1/scripts/verify.sh"
	printf 'key AKIA%s\n' 'H9PLANTEDH9PLANT' >"$1/docs/h9-canary.txt"
}
plant_placeholder() { printf '{{%s}}\n' H9_PLANTED >"$1/harness/templates/seed/h9-planted.md"; }
plant_ledger_edit() { sed -i '/^- DD-071:/s/Reported by/Reported BY/' "$1/docs/LEDGER_D.md"; }
plant_long_row() {
	{
		printf -- '- DD-072: **A planted row that is far too long.**'
		local i
		for i in 1 2 3 4 5 6 7 8 9 10 11 12; do
			printf ' This is planted sentence number %s of the probe row.' "$i"
		done
		printf '\n'
	} >>"$1/docs/LEDGER_D.md"
}
plant_state_shrink() {
	# Commit a state file above the 14 KB trigger, then shrink it by more than the 1024-byte
	# edit delta while it stays above the trigger: an unfinished compression pass.
	local c=$1 an ae pad
	an=$(git -C "$c" log -1 --format=%an)
	ae=$(git -C "$c" log -1 --format=%ae)
	pad=$(head -c 5800 /dev/zero | tr '\0' 'x')
	printf '\n- 2026-11-01 — probe padding %s\n' "$pad" >>"$c/docs/STATE.md"
	git -C "$c" -c user.name="$an" -c user.email="$ae" commit -q -m 'H9 probe: pad the state file' docs/STATE.md || return 1
	sed -i 's/probe padding x\{1200\}/probe padding /' "$c/docs/STATE.md"
}

LAST_RC=0
run() { # name planter mode command...
	local name=$1 plant=$2 mode=$3 c
	shift 3
	c=$(fresh "$name") || {
		printf '%-30s CLONE FAILED\n' "$name" | tee -a "$OUT/summary.txt"
		LAST_RC=99
		return
	}
	"$plant" "$c"
	(
		cd "$c" || exit 98
		export HOME=$W/$name/home H9_LOG=$OUT/$name.mktemp
		: >"$H9_LOG"
		unset CI
		case $mode in
		real) ;;
		tmpdir) export TMPDIR=/nonexistent/h9 ;;
		shim-all) export H9_FAIL_ONLY='' PATH=$SHIM:$PATH ;;
		shim:*) export H9_FAIL_ONLY=${mode#shim:} PATH=$SHIM:$PATH ;;
		shimcwd:*) export H9_FAIL_ONLY=${mode#shimcwd:} H9_CWD=$c PATH=$SHIM:$PATH ;;
		esac
		timeout 1500 "$@"
	) >"$OUT/$name.log" 2>&1
	LAST_RC=$?
	printf '%-30s plant=%-26s mode=%-40s rc=%s\n' "$name" "$plant" "$mode" "$LAST_RC" | tee -a "$OUT/summary.txt"
}

LADDER=(bash scripts/ladder.sh --guards-only)
FULL=(bash scripts/ladder.sh)
PH=(bash scripts/guards/placeholder-integrity.sh)
LA=(bash scripts/guards/ledger-append-only.sh)

# Every mktemp fails, by the two routes; the writable control first.
run ladder-control none real "${LADDER[@]}"
run ladder-tmpdir none tmpdir "${LADDER[@]}"
tmpdir_rc=$LAST_RC
run ladder-shim-all none shim-all "${LADDER[@]}"
shim_rc=$LAST_RC
run full-control none real "${FULL[@]}"
if [ "$tmpdir_rc" -eq 1 ]; then
	run full-tmpdir none tmpdir "${FULL[@]}"
else
	printf 'full-tmpdir SKIPPED: guards-only did not exit 1 under this failure\n' | tee -a "$OUT/summary.txt"
fi
if [ "$shim_rc" -eq 1 ]; then
	run full-shim-all none shim-all "${FULL[@]}"
else
	printf 'full-shim-all SKIPPED: guards-only did not exit 1 under this failure\n' | tee -a "$OUT/summary.txt"
fi

# Only the ladder's own scratch directory fails; nothing else can go red on mktemp's account.
run ladder-only-clean none shim:scripts/ladder.sh "${LADDER[@]}"
run ladder-only-control-planted plant_citation_and_secret real "${LADDER[@]}"
run ladder-only-planted plant_citation_and_secret shim:scripts/ladder.sh "${LADDER[@]}"
run ladder-only-trace none shim:scripts/ladder.sh bash -x scripts/ladder.sh --guards-only
run ladder-only-rowlen-control plant_long_row real "${LADDER[@]}"
run ladder-only-rowlen plant_long_row shim:scripts/ladder.sh "${LADDER[@]}"
run ladder-only-state-control plant_state_shrink real "${LADDER[@]}"
run ladder-only-state plant_state_shrink shim:scripts/ladder.sh "${LADDER[@]}"
# The full ladder under the single failure. The shim also requires the clone root as the caller's
# working directory, so the fixture ladders that scripts/verify.sh's suites run keep a real mktemp.
run full-ladder-only-planted plant_citation_and_secret shimcwd:scripts/ladder.sh "${FULL[@]}"

# The standalone guards, clean and over a planted defect.
run placeholder-control none real "${PH[@]}"
run placeholder-shim none shim-all "${PH[@]}"
run placeholder-tmpdir none tmpdir "${PH[@]}"
run placeholder-control-planted plant_placeholder real "${PH[@]}"
run placeholder-shim-planted plant_placeholder shim-all "${PH[@]}"
run ledger-control none real "${LA[@]}"
run ledger-shim none shim-all "${LA[@]}"
run ledger-control-planted plant_ledger_edit real "${LA[@]}"
run ledger-shim-planted plant_ledger_edit shim-all "${LA[@]}"

# Only one guard's mktemp fails inside a whole ladder run, over its planted defect.
run ladder-placeholder-planted plant_placeholder shim:scripts/guards/placeholder-integrity.sh "${LADDER[@]}"
run ladder-ledger-planted plant_ledger_edit shim:scripts/guards/ledger-append-only.sh "${LADDER[@]}"

ls -A / | sort >"$OUT/root-after.txt"
if cmp -s "$OUT/root-before.txt" "$OUT/root-after.txt"; then
	printf 'filesystem root listing: unchanged\n' | tee -a "$OUT/summary.txt"
else
	printf 'filesystem root listing: CHANGED\n' | tee -a "$OUT/summary.txt"
fi
```

- **Disposition, routed to the owner (§1 item 11), a recommendation only:** fix it. A single failed
  `mktemp` can turn the ladder green, guards-only or full, over a planted credential-shaped string,
  a bad citation, an over-long ledger row or an unfinished compression. That failure was simulated by
  a shim keyed on the caller and was not observed outside it. A failure of every `mktemp` is red
  in this repository, but only by the accident the Result describes, and with fewer rungs in an
  adopter install; `ladder.sh` is shipped, so the adopter case is the one to weigh. The repair is
  small and has a precedent in this tree: `scripts/guards/path-refs.sh:266` already exits 1 with
  "this guard checked NOTHING". It belongs at `scripts/ladder.sh:104`, with its shipped original and
  manifest, and at `placeholder-integrity.sh:25-26`; `ledger-append-only.sh:356` fails closed, so
  only its empty-path write remains. This measurement adds two requirements to the Output bullet's
  list for that fix:
  - Its fixture must fail only the ladder's own `mktemp`, over a planted defect. With every `mktemp`
    failing, the ladder is already red at `6fb6076`, so a fixture built that way passes without the
    fix.
  - It either covers the three suites' unchecked `WORK=$(mktemp -d)`, one of them in the shipped
    `test-ladder-guards.sh`, or says why it leaves them.

  This unit repairs nothing.
- **What ran:** the owner chose the reviewer on 2026-11-09: Fable 5.2, one fresh-context pass,
  read-only and blocking, with a findings-only mandate that let it correct the characterization and
  the disposition but not approve a fix or change what H9 covers. Before it, a gpt-6.1-sol check of
  the replay, not counted as the pass, added the writable-root refusal and the exit-1 precondition.
  Fable replayed the 21 cases then recorded, matching on every exit status, and probed further. Its
  eight findings were applied: the row-length and landing-check cases, the full ladder under the
  single failure, the missing attempted paths, the adopter caveat, the fix's two added requirements,
  the realism limit and two wording fixes. The 26-case script above was then replayed from this
  text.

### H1 — inventory what each session must read, item by item (docs-only, measurement): done 2026-11-13

- **Why:** principle 4. The evidence so far is external, and this repository has no recorded
  incident (§2).
- **Do:**
  - Inventory the reference instance separately from rendered adopter profiles, for each
    first-class host and install profile.
  - Distinguish host-injected text, mandatory startup reads, task-triggered reads and merely
    available text. Trace mandatory references recursively. Record missing destinations, cycles
    and host instruction-loading limits as unknowns where unverified.
  - Inventory `AGENTS.md` and the seed constitution **item by item**: every paragraph and every
    individual list item, with mixed blocks split. Preserve source text, revision, spans,
    individual obligations and exceptions.
  - Record two dimensions separately:
    - **applicability:** by host, platform, task and phase, allowing combinations;
    - **content type:** binding obligation, a description of what a guard covers or misses, or
      rationale and history.
- **Output:** the inventory in a linked companion file beside this plan, with a bounded summary
  appended here. It grants no relocation authority and changes no rule.
- **Pass owed:** none mandatory for a pure inventory (§1 item 8 still pre-allows one). If it comes
  to evaluate a legislative change, `docs/RUNBOOK.md` → **Session discipline** 10 applies.
- **Acceptance:** every nonblank source span is reconciled, with uncovered and overlapping spans
  shown, and mixed-block splits are inspected independently of the extractor. Equality with the
  extractor's own set of identities is not enough, because both can omit the same obligation.
  Per-context byte totals and unknowns are reproducible from the kept command and input revision.
- **Result (2026-11-13, at `9ea4cee`).** The inventory is in
  [`2026-11-01-harness-research-gaps-h1-inventory.md`](2026-11-01-harness-research-gaps-h1-inventory.md),
  with its extractor, checker and measurement script. The checker reads that file's own tables,
  so replaying it re-checks the classification. Measured, not estimated:
  - **Bytes injected or mandatory per session:** 40,084 at the reference instance under Claude
    Code and 39,654 under Codex. An adopter is at 25,461 or 25,031 at the light profile and
    37,764 or 37,334 at standard or full. Codex's load of `AGENTS.md` is documented, not
    observed here.
  - **Item counts:** `AGENTS.md` splits into 73 binding items, 15 coverage descriptions, 3
    rationale items and 24 map items. The seed splits into 91, 23, 7 and 19, plus 13
    placeholders. Every nonblank line is reconciled. A fresh-context review of the draft failed
    it, on obligations left bundled and six mistyped items, and its findings are applied (the
    companion's §5).
  - **The finding H3 inherits:** at the default light profile, the seed constitution still makes
    `docs/RUNBOOK.md` → **Session discipline**, a playbook, the incident playbook and the ledger
    mandatory or phase-bound reads, and none of them is installed (**DD-075**). The inventory
    decides nothing about that.
  - **Unknowns:** Codex's project-document load and limit, SessionStart output on start modes
    other than startup, truncation of long instruction files, and how much of a mandatory read
    an agent performs.

### H4a — specify the containment the sandbox can actually provide (docs-only, design): done 2026-11-13

- **Why:** principle 9, and lesson 4.
- **Do:** Read each host's current sandbox documentation and write the following into this
  plan:
  - **A documented-versus-observed matrix:** host × client or execution surface × platform ×
    host version, each row carrying shell and tool path, dependencies, approval and escalation
    policy, and fallback. Availability, requested configuration, effective configuration and
    observed enforcement are separate columns, not alternative states. Platforms: macOS, Linux,
    WSL2, WSL1, native Windows.
    - **Claude Code, documented:** macOS, Linux and WSL2 sandboxed; native Windows runs commands
      unsandboxed; WSL1 unsupported.
    - **Codex, documented:** macOS by Seatbelt; Linux and WSL2 by bubblewrap, which must be
      installed; native Windows through its own sandbox. WSL1 is unverified. `sandbox_mode`,
      approval policy, writable roots, temporary-directory exclusions and named permission
      profiles exist; `default_permissions` must not be combined with `sandbox_mode` or
      `sandbox_workspace_write`. Projects with `trust_level = "untrusted"` skip project-scoped
      `.codex/` config, hooks and rules, so the Codex adapter can be absent from a session.
      Exact supported versions, complete precedence and platform failure behaviour still need
      targeted documentation or probes.
  - **Native Windows options for the owner, host by host** (§1 item 5). None is settled here, and
    no two are equated without platform evidence:
    - Claude Code on native Windows without its shell sandbox: the command guard and prose remain
      its only layers, said plainly in the README and the adapters.
    - Claude Code in WSL2, with verified interop restrictions.
    - Claude Code inside an independently verified container or VM boundary.
    - Refusing to start when required isolation is unavailable. This prevents execution. It does
      not contain a completed native execution.
    - Codex's native Windows sandbox: `windows.sandbox` values `mxc`, `elevated` and `unelevated`;
      explicit `mxc` failing when MXC is unavailable, versus `features.prefer_mxc` falling back,
      with managed `require_mxc` recorded separately.
    Requiring WSL2 alone does not establish interop containment. Blocking DD-038's original path
    and testing an analogous path after migration are different claims. Machine mode (**DD-063**)
    settles none of these: a denial is a rail, not containment, and the README sentence for the
    unsandboxed option should say machine mode exists and is not containment.
  - **The WSL2 interop boundary.** A sandboxed command can launch a Windows binary through a
    Unix socket. Blocking that needs the socket settings plus the optional seccomp filter.
    Allowing every Unix socket reopens it.
  - **Settings scope and precedence, per key:** a table of scope, merge rule and version, covering
    scalar precedence; merged filesystem and permission lists; `allowUnsandboxedCommands: false`,
    which since 2.1.285 holds against a project's `true`; admin-required sandboxes, which ignore
    repository widening entries; and `strictAllowlist`, which has no effect in project or local
    files. An `allowedDomains` list alone is not a closed network boundary: permission mode,
    WebFetch rules and per-command approvals can widen access. Machine mode (**DD-063**) is an
    optional rail, not sandbox configuration and not proof that hooks loaded; its fragment
    `harness/templates/configs/claude-machine-settings.json` is at user scope, and whether Claude
    Code runs the hooks of both scopes has not been observed. Generic list merging does not
    establish dual-hook execution. The host-mode limits stand: `--safe-mode` and `--bare` skip
    configured hooks, and `--restricted` ignores project settings unless they are supplied again
    with `--settings`. The Claude adapter's fail-closed hook handling needs Claude Code 2.1.295 or
    later; an older version fails open. Still open: whether H4b's sandbox, like machine mode, belongs at
    user or managed scope rather than in the project file.
  - **Behaviour when the sandbox is unavailable, and the escape hatches:** unsandboxed retries,
    excluded commands, `!`-prompt commands. Which of them the adapter turns off. Strict retry mode
    normally leaves user-entered `!` commands unsandboxed and does not remove exclusions; keep the
    documented background-session and environment exceptions.
  - **Legitimate access outside the working tree:** temporary directories, caches and git
    worktrees. The ladder's fixture suite builds repositories under a temporary directory.
  - **What stays outside the boundary, as separate claims** for write containment, read
    confidentiality, environment, network and whole process. Claude Code's default sandbox still
    permits credential reads, and its file and web tools, hooks, MCP servers and listed helpers are
    outside the shell boundary; Codex's command-network rules do not cover web search, apps or MCP.
    AMH's own hooks run outside the sandbox. Catalogue these residual paths without automatically
    adding new rails. Include sockets, mounted drives and a linked worktree's shared git storage.
    Never claim an allowlist prevents exfiltration to an allowed destination.
  - **Adopter migration.** Adapters install under `keep`, so existing adopters get nothing
    automatically. Version-specific migration goes in the release CHANGELOG's Upgrading subsection;
    `docs/UPGRADING.md` changes only for a genuinely recurring procedure. User or managed
    installation needs separate owner authorization, must preserve existing settings and must not
    print their contents.
  - **Two claims, kept apart:** "containment added on supported platforms" versus "DD-038's
    execution path contained". The second is made only if the owner picks a Windows option that
    delivers it.
- **Pass owed:** one combined rule-review and adversarial pass at the strongest tier, over the
  design or a no-change conclusion. H4b's later pass cannot substitute for it.
- **Acceptance:** every cell of the matrix names its source, as a documentation section or a
  probe, or says unverified.
- **Result (2026-11-13, at `cd36199`).** The design is in
  [`2026-11-01-harness-research-gaps-h4a-containment.md`](2026-11-01-harness-research-gaps-h4a-containment.md),
  on the owner's answers to §1 item 5 (its §1). Reported by the vendors' pages, fetched that
  day and checksummed there; observed only by read-only probes on a Docker container on a WSL2
  kernel, which is not a WSL2 distribution:
  - **Claude Code** sandboxes Bash, PowerShell and Monitor commands on macOS, Linux and WSL2, and
    runs them unsandboxed when the sandbox cannot start unless `failIfUnavailable` is set. The
    design leaves that key unset, because setting it stops Claude Code starting on native Windows,
    so H4b must make the silent fallback visible. A project file sets defaults that a local
    file outranks; the adapter's existing `Read` and `Edit` denies merge into the sandbox. The
    proposed block is `enabled`, `allowUnsandboxedCommands: false` and
    `autoAllowBashIfSandboxed: false`.
  - **Codex** sandboxes by default, so its adapter pins no key: one would collide with a user's
    `default_permissions` profile. H4b validates that the shipped file loosens nothing.
  - **DD-038's path is not contained**, by the owner's Windows choice, and no cell is claimed
    contained before H4b's live probes. The design names what the sandbox would break in AMH's
    own workflow (hook installation, `git merge` over protected files, credential-reading tools,
    SSH push) for H4b to probe.
  - **The review:** gpt-6-astra `-e high`, verdict REVISE, 14 findings (4 P1), each replayed
    against the fetched pages and applied (the companion's §14).
  - **Left for H4b's approval:** the six design defaults in the companion's §11, whether to add
    `credentials` entries, the reading that leaves Codex's own Windows sandbox alone, and H4b's
    version semantics (§1 item 2).

### H4b — wire the host sandbox into both first-class adapters, per H4a: done 2026-11-13 as configuration, live probes owed

- **Why:** H4a, as the owner decided it. **DD-038** and **DD-063** support containing the
  deletion class.
- **Do:**
  - Bound the work to the owner-selected cells and policies. Change `harness/templates/configs/`
    and this repo's adapter copies as H4a specifies, and keep every existing rail. The sandbox is a layer under them, not a replacement.
  - Extend `scripts/guards/adapter-set.sh`, and label it **configuration validation**, not
    runtime attestation.
  - Keep the README's truthful statement that AMH's rails are not a security sandbox, and add
    beside it a precisely scoped statement of the platform/host cells that now have one.
  - Put version-specific migration in the release CHANGELOG's Upgrading subsection, as H4a says.
- **Pass owed:** one combined blocking fresh-context pass at the strongest tier, with both the
  rule-review and adversarial checklists. Adapter rails are legislation, and adapter wiring is
  glue.
- **Acceptance**, each probe run in a disposable tree and none of them destructive:
  - (a) Fixtures: each configuration-loosening mutation fails the adapter-set guard for the
    intended reason, and restoring it passes, and each fails without the validating behaviour.
    Mutations: sandbox off, fallback allowed, unsandboxed retries allowed, a widened write path, a
    widened network allowlist, wrong scope or table, unknown or misspelled keys, duplicate
    effective keys, disabled filesystem isolation, exclusions, additional directories, permissive
    sockets, escalation, and proxy-off domain rules (Codex domain rules need an active proxy;
    `network.enabled` alone permits direct networking).
  - (b) For each platform cell claimed as contained, in a live session with the adapter loaded:
    a write inside the working tree succeeds and one outside it is refused; network as the selected
    policy requires (a deliberately network-disabled cell need not reach an allowed host); on WSL2,
    if claimed, a harmless Windows-executable launch is refused. Each negative has a positive
    control proving the target was otherwise reachable, writable or executable, and the final
    artifact is inspected independently. DNS failure, a missing `cmd.exe` or an unrelated
    permission refusal is not containment evidence.
  - (c) Startup and runtime unavailability, retries and the relevant shell and tool paths are
    probed, and worktrees, temporary files, git operations and bootstrap compatibility work, not
    merely an ordinary in-tree write.
  - (d) The full ladder passes inside the configured sandbox.
  - (e) If credential isolation is selected, synthetic file and synthetic environment probes,
    including the relevant non-shell paths. Real credentials are never inspected.
  - (f) A retained old adapter stays unchanged and the documented migration reaches the selected
    configuration; a fresh-install test does not establish upgrade delivery.
  - (g) An unprobed required cell blocks that containment claim, and disclosure alone cannot
    satisfy it. Every combination not probed is recorded as unverified in the README, the ledger
    row and the commit body.
  - Live probes are observed by the owner or a named session and are not CI evidence. The
    disclosure says so.
- **Result (2026-11-13, at `ec959cf`): shipped as configuration; the live probes are owed.**
  The owner's answers, taken when it started: (1) ship the configuration, the guard and its
  fixtures now, call every cell unverified, and let a follow-up claim only the cells a live probe
  passes, on the owner's own host or a session the owner names; (2) the five design defaults of
  the companion's §11, as proposed; (3) no `credentials` entries for now, reopened on an incident
  or on outside findings or proof; (4) Codex's own sandbox left alone; (5) it folds into the
  17.0.0 draft, whatever that draft is ruled; (6) the owed pass is gpt-6.1-sol at `-e high`
  (**DD-079**).
  - **Done:** the Claude block in the template and this repo's copy; `adapter-set.sh` extended
    and labelled configuration validation; acceptance (a) as fixtures in
    `scripts/tests/local-guards.sh`, each seen failing against the committed guard; the README
    section **The host's sandbox**; the 17.0.0 Upgrading step; `bwrap socat` in this repo's
    `REQUIRED_TOOLS` rather than in `session-start.sh`, which names no vendor's tools (P14).
  - **Mapped mutations.** "Fallback allowed" is the shipped Claude state by the owner's choice,
    so its fixture is `failIfUnavailable` set either way, a change of decision the guard
    reports; for Codex it is `[windows] sandbox` and `features.prefer_mxc`. "Disabled filesystem
    isolation" cannot be set from a project file (the companion's §5), and is refused anyway.
  - **The reviews.** A mid-unit gpt-6.1-sol `ask` at `-e medium` found the first guard reading by
    layout (4 P1, 5 P2): indentation taken for JSON scope, an escaped key, the reviewer pin
    readable inside a string, and permission rules that widen the sandbox beside an exact block;
    the Claude check became a tokenizer. The owed pass, gpt-6.1-sol `rules` at `-e high` over both
    checklists, then found 5 P1, each replayed and fixed with a fixture seen failing first: a
    literal dotted key, an escaped allow value, a triple quote inside an ordinary TOML string, a
    crashed scanner reading as a pass, and a Codex diagnostic echoing the rejected line. Citation
    validity and agent-agnosticism were clean.
  - **Not done:** (b) to (g). This host has no `bwrap` or `socat` and cannot create a user
    namespace (`unshare -Ur`: "Operation not permitted"), so no sandbox could start here; (e) is
    moot, since no credential isolation was selected. The probe list is the companion's §7 and
    this unit's acceptance; it is in the Owner queue.

### H2 — keep in the constitution what every session needs; point at the rest: done 2026-11-13

- **Outcome.** The owner's answers of 2026-11-13: the problem is that the always-loaded text is
  too big (§1 item 9); move the description and rationale items of A042, A026 and A003 into a
  new task-triggered runbook section, keep every binding item, and leave the seed to H3 (§1
  item 3); fold into 17.0.0 (§1 item 2). The mapping, where it departs from the selection (two
  items stayed, one went to the rule-review protocol), each acceptance output, both reviews and
  the matching seed passages are in
  [`2026-11-01-harness-research-gaps-h2-relocation.md`](2026-11-01-harness-research-gaps-h2-relocation.md).
  `AGENTS.md` went from 15,274 to 12,338 bytes (**DD-080**).
- **Why:** principle 4. Conditional: it runs only if the owner selects exact obligations from
  H1's inventory and accepts the specific measured problem (§1 item 9). Byte reduction alone is not
  incident evidence.
- **Do:** For each obligation the owner chooses to move, record an old-to-new mapping that preserves
  scope, exceptions, precedence and force:
  - its original scope;
  - its destination: a binding runbook section for a live obligation, or a ledger row for
    rationale and history. A comment is never a destination for a binding rule;
  - the retrieval trigger, meaning a binding read encountered before the governed action. A
    trigger must not require knowing the relocated rule first;
  - the binding declaration that makes it bind there.
  Leave a one-line binding pointer in `AGENTS.md`. Keep rationale and history apart from live
  requirements. Destinations that are comments, history, unreachable sections or circular pointers
  are rejected. Search and reconcile matching seed wording in the same unit. Put version-specific
  seed migration in the release CHANGELOG's Upgrading subsection, and change `docs/UPGRADING.md`
  only for a genuinely recurring procedure.
- **Pass owed:** rule review, at the strongest tier. The reviewer judges whether each move kept
  the obligation's scope and force.
- **Acceptance:**
  - (a) A script checks that every binding sentence removed from `AGENTS.md` appears word for
    word at its destination. This is textual evidence only, and its output is kept for the
    reviewer. A verbatim but operationally unreachable move fails this unit.
  - (b) `scripts/guards/doc-navigation.sh`'s expectations gain every new pointer/heading pair.
    Fixtures show that a missing pointer, a missing or duplicate heading, a wrong destination and
    pointer-plus-heading removal each fail the guard.
  - (c) The transitive reading set is recomputed for each affected context as in H1, pointer
    overhead included. Moving text into a section every session reads anyway saves nothing, and the
    measurement shows whether it did.
  - (d) The full ladder is green.
  - These checks cannot prove an agent actually retrieves the rule, and the unit says so.
- **Not a byte cap** (**DB-038**). No rung judges the result, and no size target is set.

### H3 — the light profile keeps the constitution a map, without an upgrade trap: done 2026-11-13

- **Why:** principle 4. Conditional on H1 and the owner's layout decision. Light is the default
  profile, yet it tells adopters to fold the runbook into the always-loaded file (§2). The
  demonstrated issue is profile and read-path coherence, not proven context exhaustion.
- **Constraint:** installs never overwrite an adopter's file (`keep`). So one adopter-owned path
  must never mean different completeness levels at different profiles. A light install that
  writes a partial `docs/RUNBOOK.md` would be kept, partial, by a later standard install.
- **Options for the owner:**
  - (a) a separate **binding document** that every profile installs, holding Session discipline
    and the review protocols. The option specifies where every required operational playbook lives
    for light, standard and full. The constitution gives binding read paths to those documents in
    every profile, so light needs no fold.
  - (b) the seed ships a short, pre-written light-profile digest of those sections, and the fold
    instruction goes. This means two copies of the rules, kept in sync by hand.
  - (c) no change.
  - Recommendation: (a). It keeps one copy of each rule and no path changes meaning. It changes
    the adopter file layout, so it needs a version decision (§1 item 2), and this repository's
    own runbook may need the same split. The selected layout's complete reading obligations are compared
    before implementation.
- **Touch:** `scripts/amh-init.sh`, the seed templates, `harness/templates/AMH-ADOPT.md` §1,
  the README and any seed prose that describes folding the runbook into the constitution,
  the release CHANGELOG's Upgrading subsection, and `scripts/tests/test-init-e2e.sh`. Change
  `docs/UPGRADING.md` only for a genuinely recurring procedure. Follow `docs/RUNBOOK.md` →
  **Change a seed template**.
- **Pass owed:** one combined rule-review and adversarial pass, at the strongest tier: the
  installer and its filesystem migration are glue.
- **Acceptance:** e2e cases for each of these:
  - fresh light, standard and full installs;
  - light→standard and light→full escalation;
  - a repeated install;
  - preservation of adopter edits;
  - upgrade of a historical light install with folded rules, and of historical standard and full
    installs with their existing runbook, then repeat and escalate. A retained old constitution
    that never references the new binding document fails.
  Each case asserts the required **sections**, that every pointer destination resolves, complete
  playbooks, and no conflicting duplicate authority after the documented hand migration. File or
  heading presence alone does not pass. Then the full ladder is green.

### H5 — separate the enduring invariants from the compensations: done 2026-11-13

- **Why:** principle 5, and lesson 2.
- **Do:** A measurement and classification unit only. Start from H1's item inventory and the
  current Session discipline items, split into individual obligations, and enumerate them rather
  than assume a count. Classify each obligation as an invariant, a compensation, or mixed, and
  preserve mixed invariants: for a mixed one, say which part is which. For each compensation,
  record:
  - the ledger row that actually supports it (provenance), or "provenance unresolved";
  - an observable failure condition: what would go wrong without it, in a form some instrument
    could detect, or "no artifact-level failure condition identified".
  Write the result beside H1's results, not beside P6 in the distributed principles. A P6 change
  and any retirement stay the owner's call and never happen in this unit. Neither a populated field
  nor a passing model run authorizes retirement. Any later retirement experiment names the one
  compensation it removes and shows the invariant beside it still holds.
- **Pass owed:** rule review, at the strongest tier. Narrowing the outcome does not erase it
  (`docs/RUNBOOK.md` → **Session discipline** 10).
- **Acceptance:**
  - every inventoried obligation has a classification;
  - script checks establish coverage and citation resolution only, and a reader judges whether the
    provenance supports the classification;
  - the full ladder is green.
- **Result (2026-11-13, at `c0d0b74`).** The classification is in
  [`2026-11-01-harness-research-gaps-h5-classification.md`](2026-11-01-harness-research-gaps-h5-classification.md),
  with its checker. The checker reads that file's own tables, so replaying it re-checks them.
  H1's inventory was re-taken first, because H2 and H3 had changed its inputs. Measured by the
  checker:
  - **Coverage:** 325 binding items across `AGENTS.md`, the seed constitution and both
    **Session discipline** sections. 177 are classified directly: 103 invariants, 51
    compensations and 23 mixed. 148 point at a row stating the same obligation: 140 seed rows
    and 8 reference Session discipline rows.
  - **Compensating and mixed rows:** 74 classified directly. For 37 of them the search
    identified no artifact-level failure condition; that bounds the search, not the world. 15
    trace to no ledger row.
  - **Review:** the owed gpt-6-astra pass, at high effort, failed the first draft on nine
    findings. They included binding sentences excluded as rationale, classes against the
    file's own test, and a checker that accepted a duplicated anchor. All nine were applied
    (companion §8).
  - **Retired:** nothing. A retirement and any change to P6 stay the owner's call.

### H6a — owner-launched replication of the existing scenarios across models

- **Why:** principle 11. **DB-024** says broadening the lab to more models is not refused on
  its merits and is owner-launched.
- **Do:** The owner runs scenarios 01 and 02 unchanged on the models they choose.
- **Pass owed:** none mandatory for unchanged replication; unchanged runs alone entail no rule
  change or mandatory review. If the unit evaluates a legislative change, `docs/RUNBOOK.md` →
  **Session discipline** 10 applies.
- **Acceptance:** a ledger row records evaluator output against identified result trees and
  baselines, the exact scenario, model and settings, and PASS, FAIL and INCONCLUSIVE counts. A
  sentence repeating claimed counts is not the experiment. The conformance README's claim widens by
  exactly what was run and no further.

### H6b — OPTIONAL: an instruction-set experiment for H2's relocation

- **Why:** H6a cannot test H2. The fixtures hand subjects their own four-rule constitutions
  (§2), so a checkout from before or after H2 gives subjects identical instructions. The lab's
  authors kept those constitutions short on purpose, because "a fixture constitution long
  enough to skim is measuring reading stamina instead". H6b is therefore a different experiment, not a
  variant of the existing one: it tests particular behavioural regressions from relocation, and it
  measures neither reading stamina nor reduced context cost.
- **Label:** a relocation-regression experiment, not evidence of reduced context cost. It is not
  mandatory acceptance for H2.
- **Do:** Extend the fixtures so each arm receives a complete, dependency-resolved instruction set:
  the pre-H2 or post-H2 constitution, the runbook sections it references, and their dependencies.
  Preserve the original two scenarios and their historical claim, and isolate the experimental
  arms. Model settings, task, evaluator and unrelated fixture content are fixed between arms. Follow
  `docs/RUNBOOK.md` → **Add or change a conformance scenario**.
- **Pass owed:** rule review, at the strongest tier. Scenario machinery encodes a reading of a
  rule.
- **Acceptance:**
  - Before any subject runs, an independent inspection of the generated instruction artifacts
    shows the two arms differ, and differ only in the intended content.
  - `conformance/selftest.sh` is green, with evaluator mutation checks.
  - Behavioural results are claimed only from owner-launched paired runs; selftest plus different
    arm text establishes machinery only.
  - The claim is bounded: these scenarios may detect particular regressions, and equal verdicts
    establish neither equivalence nor benefit.

### H7 — a third scenario, seeded on DD-038: refused deletions leave no prohibited effect

- **Why:** principles 3 and 11. **DB-024** asks for a third recorded failure class, and
  **DD-038** is one.
- **The claim is narrowed to what work-product evaluation can see.** It covers prohibited
  effects and retained artifacts, never the absence of an attempt (`conformance/README.md`,
  "the act stays unreachable").
  - An attempt-level claim would need an independent observation mechanism. Hook markers and
    run receipts were refused (**DA-024**, **DA-025**), so that would be a separate, reviewed
    owner decision, and this plan does not propose it.
- **Do, before any implementation:**
  - Identify an observable failure residue beyond what the existing deterministic guard fixtures
    already test.
  - Define the refusal trigger the subject meets.
  - Define the observable contract, which needs:
    - a positive task-completion condition, so doing nothing fails;
    - sentinel **integrity**, as a content hash, not mere directory existence;
    - a finite, testable definition of a retained prohibited artifact that a legitimate
      negative-test script does not match, never one that turns on a script's intent.
  - Keep **containment** apart from **behavioural compliance**. If a sandbox blocks the retry,
    the sentinel survives, but that is containment, not compliance. The subject runs with
    containment held constant and recorded.
- **Pass owed:** the playbook's acceptance plus rule review, at the strongest tier.
- **Acceptance:** `conformance/selftest.sh` green, with a reason-specific mutation for every
  assertion and every enumerated INCONCLUSIVE trigger. It includes these counterexamples, each
  with the verdict the contract assigns it:
  - a completed task, intact sentinel and no prohibited retained artifact passes, even if a retry
    was blocked by containment or a wrapper was created, run and removed;
  - a damaged sentinel or a retained prohibited artifact fails;
  - a subject that does nothing fails;
  - a legitimate negative-test script that names the sentinel passes when the positive task also
    completes.
  Restored damage and removed attempts are outside final-state observability: they are not
  classified as compliance, and INCONCLUSIVE is not invented to hide that limit.
  Then break the evaluator, watch the suite go red, and restore it. Subjects run only in a
  throwaway container the owner launches, never on a machine with real data.

## 6. Parked: no AMH incident yet

Each item reopens on a recorded incident, not on this survey.

- **H8 — measure an adopter verification or output failure** (parked by H0.5). First identify a
  concrete adopter verification or output failure, or obtain an explicit owner exception (§1 item
  10); otherwise the advice stays parked. The advice was: in `harness/templates/AMH-ADOPT.md` §4 and
  the seed `verify.sh` comments, one step that exercises the product as a user would, and green
  output short with failures loud. External evidence plus "a few sentences" does not satisfy lesson
  1. If reopened for a template change, acceptance inspects the rendered advice and exercises a
  relevant verification example, and a green AMH ladder does not establish adopter effectiveness.
  Any decision to make or decline the planned template-rule change keeps strongest-tier rule review.

- **Run the ladder before a session's first edit**, to catch a red tree inherited from the
  previous session (Anthropic's smoke test). Guards-only costs about 33 s here (§2).
- **`ladder.sh --guards-only` in the git-native pre-push rail.** It would make "never push red"
  a machine rule rather than prose. Its cost is that run on every push.
- **A measurement-only line reporting the text a session must read.** Precedent: the ledger
  rung reports a size and never judges it (**DA-022**). Risk: a printed number anchors the
  reader (**DB-040**), and it edges toward the cap **DB-038** refused.
- **Shorter fixture output on a green full ladder.** It is 332 lines, 239 of them passing
  fixtures (§2): far from the 4,000 lines HumanLayer saw cause hallucinations, and AMH has no
  such incident. If it ever needs fixing, print one summary line on green and keep the
  per-fixture lines for failures and SLOW timings.

## 7. Reviews of this plan

### 7.1 H0.5: review of rev 2 and how rev 3 answers it

gpt-6-astra at `-e high`, `9e1a0f2`, verdict REVISE_PLAN. "Replayed" means the implementing session
ran the command and got the same number. "Read back" means it read the cited source. The sandbox
documentation is reported by its publishers and was not probed at runtime.

| Finding | Re-checked by | Rev 3 |
|---|---|---|
| F1 (P2): stale §2, §3.5, H5's item count | Replayed: `wc`, `awk`, `grep` lines of §2.1 | §2 marked historical; §2.1 added; "shallow clone" deleted; H5 enumerates |
| F2 (P2): §3 verdicts | Read back against the §3 rows | Rows 1, 2, 3, 4, 7, 8 and 9 rewritten |
| F3 (P1): H1 | Read back: the plan's H1, `docs/RUNBOOK.md` | H1 rewritten; acceptance reconciles spans, not an extractor's own IDs |
| F4 (P1): H2 | Read back: `scripts/guards/doc-navigation.sh` | H2 conditional; mapping, read trigger, unreachable destinations rejected; fixtures widened |
| F5 (P1): Codex claims and matrix | Read back: the staged Codex pages | Matrix is documented-versus-observed; §8 and §9 corrected |
| F6 (P1): native Windows options | Read back: Claude sandboxing page; Codex `windows.sandbox`, `features.prefer_mxc`, `require_mxc` | Host-specific list; "contained only by" sentence deleted; selections stay the owner's |
| F7 (P1): settings scope and escape hatches | Read back: `allowUnsandboxedCommands` since v2.1.285, admin-required, `strictAllowlist`, strict mode and `!` | Per-key table; allowlist caveat |
| F8 (P1): H4b acceptance | Read back: the plan's H4b, Codex network settings | Mutations widened; positive controls; unprobed required cell blocks the claim |
| F9 (P1): boundary claims | Read back: Claude credential and outside-sandbox sections | Separate claims catalogued; README statement kept and scoped |
| F10 (P2): H3 | Read back: `scripts/amh-init.sh` `keep` behaviour | Conditional; historical-install upgrades in acceptance; playbook location explicit |
| F11 (P2): migration | Read back: `docs/UPGRADING.md` scope, `docs/RUNBOOK.md` | CHANGELOG Upgrading subsection; retained-adapter test |
| F12 (P2): H5 | Read back: the plan's H5, P6 | Measurement only; beside H1, not P6; unresolved provenance allowed |
| F13 (P2): H6a, H6b | Read back: `conformance/README.md` | Evidence rewritten; H6b labelled a regression experiment |
| F14 (P2): H7 | Read back: the plan's H7, `conformance/README.md` | Residue required; counterexample verdicts assigned; INCONCLUSIVE not used to hide a limit |
| F15 (P2): H8 | Read back: lesson 1 and H8's own "external evidence only" | Parked in §6; §1 item 10 |
| F16 (P2): add H9 | Read back: `scripts/ladder.sh:104`, `scripts/guards/placeholder-integrity.sh:25`. Not reproduced here: H0.5 saw it under a read-only sandbox | H9 added, measurement only |
| F17 (P1): pass-owed lines | Read back: `docs/RUNBOOK.md` → **Session discipline** 10 and **Rule-review protocol** | H4a, H3, H1, H6a and H9 lines rewritten |
| F18 (P2): owner decisions, cross-plan order | Owner-queue recommendation; not answered here | §1 items 4, 5, 9, 10 and 11; the Owner queue carries the cross-plan order below |

**Cross-plan order, a recommendation only (the owner's call, and outside H0.5's grant):** S1 → S2 →
S6a → S3 → N2 → N6a → H9 → H1 → H4a → H4b → N3 → N4 → N5 → N7a → N7b → H2 → H3 → H5 → H6a → optional
H6b → H7. Unadopted or blocked units do not block independent approved work; release placement stays
open. H4a must not claim its shell-network boundary covers every metadata-fetch path or replaces
N6b's owner-selected justification. N4's verified credential-path evidence is coordinated with H4a
without promoting N4 candidates automatically.

**File conflicts it names:** H4b and N4 share `.claude/settings.json`,
`harness/templates/configs/claude-settings.json`, `scripts/guards/adapter-set.sh` and
`scripts/tests/local-guards.sh`, and `claude-machine-settings.json` if H4b changes that fragment. S1,
S6a, N3, N4, N5, N7a if it ships code and N7b share `command-guard.sh`, its copy, embedded fixtures
and manifest; N7b and S6a also share wrapper parsing. S2 and S3 share `redact.sh`. H9's follow-up,
H4b and H2 share `scripts/tests/local-guards.sh`; a shipped H9 repair touches `ladder.sh`,
`test-ladder-guards.sh`, their originals and the manifest. H1, H2, H3 and H5 share inventory input
revisions, so H1 and H5 results are frozen or redone after a change. H6b and H7 share
`conformance/selftest.sh` and `conformance/README.md`. All plans share `docs/STATE.md`,
`harness/CHANGELOG.md` and ledger additions, and overlap on `README.md` and `docs/UPGRADING.md` where
migration or coverage wording changes.

### 7.2 Review of rev 1 and how rev 2 answers it

The external review (verdict REVISE_PLAN) was taken as data and re-checked against this tree at
`ba1f40a` before any of it was accepted. All nine findings were accepted.

| Finding | Re-checked by | Rev 2 |
|---|---|---|
| F01: H4 does not contain DD-038 as specified | read **DD-038** (native Windows PowerShell 5.1); read Claude Code's sandboxing docs: native Windows runs unsandboxed, WSL2 interop goes through a Unix socket, seccomp is optional | H4 split into H4a (matrix, Windows options, interop boundary, two claims kept apart) and H4b; §3 row 9 corrected |
| F02: H6's ablation does not reach subjects | measured: fixture constitutions of 632 B and 781 B, literal heredocs, no runbook | H6 split into H6a (replication) and optional H6b (instruction-set experiment, with its own pass and bounded claim) |
| F03: H7's oracle cannot show no attempt | read `conformance/README.md` on unreachable acts | claim narrowed to effects and retained artifacts; contract, counterexamples, sentinel integrity, containment kept separate |
| F04: H3(a) creates a partial-runbook trap | read `install_file`'s `keep` branch; the reviewer's measured run reported | H3 layout constraint; option (a) redefined as a separate binding document; escalation and repeat-install tests |
| F05: configuration conflated with containment | read the `keep` installs of adapters; Claude docs on fallback and on tools outside the sandbox. The Codex claims are reported by the reviewer and third-party guides, not confirmed. | lesson 4; H4a scope, precedence, fallback, exclusions and migration; H4b probes and the configuration-validation label |
| F06: H2's acceptance misses new navigation and scope | read `doc-navigation.sh`: nine fixed pairs | per-obligation scope, trigger and binding record; navigation fixtures; re-measurement of the reading set |
| F07: H5 classifies containers | read Session discipline item 7 and P5; **DB-024**(a) | lesson 2; classification per obligation, with a mixed class, provenance and failure conditions |
| F08: H1's count cannot show coverage | measured: 15 records against 37 list items | identity-set inventory, two separate dimensions, byte counts labelled as text volume |
| F09: H8's tier, and the reviewer authorization | read `docs/RUNBOOK.md` → **Rule-review protocol** | strongest tier for H8; §1 item 8 lists every legislation unit; H4b gets one combined pass |
| Evidence corrections | — | exact `awk` commands in §2; §3 row 11 now says scenario 02 only; sources with URLs in §8. The full-ladder placeholder the review saw had already been replaced in-session by the measured result, which rev 2 keeps. |

## 8. Sources

External figures are **reported**. None of them is evidence about AMH.

- Claude Code sandboxing documentation, read 2026-11-01 and again 2026-11-09:
  https://code.claude.com/docs/en/sandboxing. Covers platforms (macOS, Linux and WSL2; native
  Windows unsandboxed; WSL1 unsupported), `sandbox.failIfUnavailable`, unsandboxed retries and
  `allowUnsandboxedCommands`, the tools and processes outside the sandbox, and WSL2's Unix-socket
  interop with the optional seccomp filter.
- Claude Code settings documentation, read 2026-11-09: https://code.claude.com/docs/en/settings.
- Codex sandbox and configuration documentation, read 2026-11-09:
  https://developers.openai.com/codex/concepts/sandboxing and
  https://developers.openai.com/codex/config-reference (both redirect to learn.chatgpt.com).
  Covers platforms, `sandbox_mode`, `default_permissions`, `windows.sandbox`, trust levels and
  network settings. `https://developers.openai.com/codex/security` now reaches a Codex Security
  product page, not the sandbox authority. These pages are not a probe of any AMH runtime.
- ETH Zurich, "Evaluating AGENTS.md: Are Repository-Level Context Files Helpful for Coding
  Agents?", https://arxiv.org/abs/2602.11988 (abstract read): context files did not generally
  raise task success and raised inference cost by over 20%, while agents followed them. Useful
  for non-standard practices.
- HumanLayer, "Skill Issue: Harness Engineering for Coding Agents",
  https://www.humanlayer.dev/blog/skill-issue-harness-engineering-for-coding-agents: a
  CLAUDE.md under 60 lines; full-suite output (4,000 lines) caused hallucinations; start simple
  and add configuration after failures. Practitioner experience, not a controlled study.
- OpenAI, "Harness engineering", https://openai.com/index/harness-engineering/. The primary page
  refused the fetch. As reported by InfoQ
  (https://www.infoq.com/news/2026/02/openai-harness-engineering-codex) and a survey quoting it
  (https://yage.ai/share/harness-engineering-survey-en-20260312.html): an AGENTS.md of about
  100 lines as a table of contents.
- Vercel, "AGENTS.md outperforms skills in our agent evals",
  https://vercel.com/blog/agents-md-outperforms-skills-in-our-agent-evals: passive context beat
  on-demand skills on one framework's evals.
- Anthropic, "Effective harnesses for long-running agents",
  https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents: a
  smoke test before new work, a progress file, one feature per session.
- Anthropic, "Harness design for long-running application development",
  https://www.anthropic.com/engineering/harness-design-long-running-apps: "every component in a
  harness encodes an assumption about what the model can't do on its own".
- Anthropic, "Making Claude Code more secure and autonomous with sandboxing",
  https://www.anthropic.com/engineering/claude-code-sandboxing: filesystem and network
  isolation are both needed; credentials are kept outside the sandbox.
- Birgitta Böckeler, "Harness engineering for coding agent users",
  https://martinfowler.com/articles/harness-engineering.html: guides and sensors; computational
  versus inferential controls; the open problems.
- Cognition, "Multi-Agents: What's Actually Working",
  https://cognition.com/blog/multi-agents-working: writes stay single-threaded.

## 9. Not verified

- Codex's exact supported versions, complete precedence and platform failure behaviour; the
  platform facts in H4a are documented, not observed. H4a's matrix keeps the two apart.
- H9's scratch-failure behaviour was measured only with `/` unwritable; a host where `/` is writable
  is read from the code, not observed.
- No live sandbox probe was run. Every containment claim waits for H4b's probes.
- Token figures are estimates. Byte figures measure text volume, not consumption.
- Of `harness/src/10-principles.md` and `docs/RUNBOOK.md`, only the sections quoted in this
  session were read. Each unit re-reads what its playbook names.
- Several external figures come from secondary coverage or abstracts (§8).
- No subject runs took place. Nothing here is a claim about how any agent behaves under AMH.
