# PLAN — the Owner-queue cycle, working-memory pressure, and what the principles leave unsaid

> **Status: rev 2, 2026-11-26: an open draft. Nothing in it is approved.** Rev 1 was committed
> on 2026-11-10 (M0). Rev 2 adds the owner's four points of 2026-11-26 (§1, items 5 to 8), the
> measurements re-taken for them (§3.2), and two units, M3b and M4b. It changes no unit of rev 1
> except where those points bear on it.
> No unit starts without the owner's explicit approval of that unit, and adopting the plan
> approves no unit. Whether it gets a review before adoption, as the other three live plans
> did, is the owner's first decision (§2, item 1).
> **Every measurement in §3 is re-taken when the unit that acts on it starts.**

The plan is provisional while it is live. Its durable outcomes go to Changelog lines and ledger
rows. Code cites ledger rows and never this file, and no ledger row may cite this file's path.
When the work is done, archive this file to `docs/history/` or delete it (`docs/PROTOCOLS.md` →
**Session discipline** 5).

Unit names carry an `M` prefix (for *memory*), distinct from the `H`, `S`, `N` and `G` units of
the four other plans.

## 1. Where this came from, and what it leaves out

The owner asked on 2026-11-10 for a read of AMH outside the command guard: gaps, whether the
ROM/RAM/disk/tape analogy earns its place, what to consolidate or add, and which machinery is
justified. The read was reported in chat. The owner then asked for this plan and added three
things, which Part A is built on:

1. **Reported by the owner, not seen by this session:** in a downstream repository, Decided
   non-items was moved out of the state file into a separate file in order to meet the size
   limits.
2. **Not counting the Owner queue toward the size limits can be gamed:** an agent can move
   material into the queue to avoid a compression that is warranted. The chat report had
   recommended that exemption. It is withdrawn (§5, M4).
3. **The work cycles:** finishing a plan and working through its units adds items to the Owner
   queue, those items need a plan, and so on.
4. **The queue is the owner's backlog, not a list of demands** (owner, 2026-11-10): "A queue
   exists for me to decide at an opportune time. Not a bureaucracy that dictates what I must do,
   it's what I choose to do and when i choose to." So the defect §4 describes is not that items
   wait. It is that waiting items are charged to working memory, and that sessions open new ones
   faster than any owner pace would close them.

On 2026-11-26 the owner called the queue "out of hand" and added four more points:

5. **Keeping the queue outside what the state file's sizing can act on was a mistake, and it
   made the problem worse.** Measured (§3.2): the size rung counts every byte of the queue, as
   rev 1 found. What the queue escapes is compression: no pass may fold it, so it grows into the
   budget and never gives any back. It now takes most of the room a pass could land in.
6. **The long queue looks like an AMH pattern, not one Tideo shares.** Measured (§3.2): Tideo
   has a queue, but each item is one dated action or decision with one `Settles it` command.
   AMH items also carry whole procedures.
7. **Most live plans had no rule asking for them.** Measured: **Session discipline** 5 asks
   for "an owner-approved plan file" for multi-unit work, and says nothing about a draft nobody
   has approved. Three of the six live plans approve nothing, and a fourth approves only its
   own review. Five began when the owner asked a question or for a review or a read, and the
   session committed its answer as a plan. Each such draft then
   adds a "review it" or "decide on it" item to the queue.
8. **One leftover segment of a plan should not keep the whole plan in `docs/plans/`, and once
   its work is on `main` or in a tag, most of a plan belongs in `docs/history/`.** Measured
   (§3.2): `main` still carries the finished research-gaps plan, its eight companions and the
   finished pipefail plan in `docs/plans/`. The live plans tie archiving to "the session that
   merges the train", and sessions never merge: the owner does. The research-gaps item still in
   the queue asks the owner for nothing. P6 stays open "until one is proposed", and H8 stays
   parked until an incident: both are conditions for reopening.

**Left out, because another plan or queue item carries it:** what every session must read and
what may move out of the constitution (research-gaps H1, H2, H3); the host sandbox (H4a, H4b);
invariants against compensations (H5); behavioural evidence (H6a, H6b, H7); the fix for a
failed `mktemp` (Owner queue, **DD-072**); and every command-guard gap. §6 says where this
plan's read bears on those.

## 2. Owner decisions this plan needs

1. **Whether this plan is reviewed before adoption, by whom, and with what mandate** (M1).
2. **Whether to adopt it, and which units.**
3. **Facts about the downstream move** (M2): which section moved, where to, what bounds the new
   file, whether a pointer stayed in the state file, and whether anything is known about
   re-proposals since.
4. **M3: which dispositions a unit may give a finding without asking,** and whether to limit
   plans in progress.
   **M3b: what makes a plan retire, and whether an unapproved draft is committed at all.**
5. **M4: how the protected sections are sized, and where Decided non-items lives.** Moving a
   section out of the state file is the owner's grant, one at a time (`docs/PROTOCOLS.md` →
   **Working-memory compression**). **M4b: an answer for each item that triage would close**
   (its table), the Gemini CLI half of the probe item and the N1 cross-plan order item among
   them.
6. **M5b: whether the ledger's rollover boundary should follow rows now that a row is one
   line.**
7. **M7: whether P2 keeps the hardware analogy as stated, keeps it corrected, or replaces it.**
8. **M8 and M9: which principles to state once, and whether any consolidation is worth its
   references** (§3).
9. **Version semantics for each legislation unit** (**Session discipline** 7(c)).
10. **One fresh-context reviewer, at the strongest tier, for M3, M3b, M4, M5a's seed half, M6,
    M7, M8 and M9.** That needs the standing no-subagents instruction lifted for exactly that
    pass, or the owner runs the reviewer.
11. **Where M3, M3b and M4 ship** (2026-11-26): inside the unreleased 17.1.0, or as their own
    version after it is tagged. M4(c) adds a check that can fail an adopter's ladder, which
    argues for its own version.

## 3. What was measured

Taken on 2026-11-10 at `9cab805`, bash 5.2, on Linux. "Estimated" marks a figure nobody ran.

| What | Command | Result |
|---|---|---|
| State file against its band | `wc -c docs/STATE.md`; keys in `amh.conf` | 13,017 B. Trigger 14,336 B; landing ceilings 9,216 B and 50 sentences. |
| Bytes per section | `awk '/^## /{if(h)print n,h;h=$0;n=0}{n+=length($0)+1}END{print n,h}' docs/STATE.md` | preamble 903; Project 310; Current state 2,637; Owner queue 4,834; Decided non-items 1,357; Changelog 2,987 |
| Sentences per section | the awk body of `count_sentences` in `scripts/ladder.sh`, run on each section | whole file 69; Current state 12; Owner queue 38; Changelog 15; the rest 4 |
| What no compression pass may fold | sum of preamble, Project, Owner queue, Decided non-items | 7,404 B and 42 sentences. That leaves 1,812 B and 8 sentences for Current state and Changelog, which hold 5,624 B and 27 sentences. |
| Whether the size rung exempts any section | read: `guard_state_size` | none. It counts the whole file. |
| Queue items | `grep -c '^\*\*OPEN' docs/STATE.md`; per-item awk | 9 items; 314 to 666 B and 3 to 5 sentences each |
| Queue flow over the last 13 changes to the state file reachable here, 2026-09-02 to 2026-11-10 | item headings (first 60 characters) compared between consecutive commits with `comm` | 29 opened, 23 closed; never fewer than 3 open. A reworded heading counts once on each side, so both totals are upper bounds. The 16.0.0 train, which carried a plan written to close the queue, closed 8 and opened 5. |
| Protected sections over the same history | the per-section awk at eight commits | Owner queue between 2,707 and 5,680 B; Decided non-items 1,357 to 1,457 B; preamble and Project constant |
| Live plans | `wc -c docs/plans/*` before this file | four files, 197,193 B |
| Ledger volume D | `wc -l -c docs/LEDGER_D.md`; `grep -cE '^- DD-[0-9]+'` | 72 rows in 136 lines, 95,861 B: the largest volume. Nearly every row from DD-003 on is one physical line. Closed volumes: 26 to 44 rows in 726 to 832 lines. |
| When volume D would roll | 800 lines at 1.9 lines per row and 1,331 B per row | **estimated:** about 420 rows and 0.5 MB |
| What a topical search returns | `grep -i Windows docs/LEDGER_D.md \| wc -c`; the same piped to `grep -oE '^- D[A-Z]?-[0-9]+[^*]*\*\*[^*]+\*\*'` | 21,255 B as whole rows; 3,175 B as identifier and headline. For `command guard`: 19,550 B and 3,161 B. |
| Rows with a headline | the same pattern over all volumes | 216 of 217 open with a bold headline; 104 close it on the first physical line, because older volumes wrap |
| Full ladder on a green tree | `scripts/ladder.sh`, timed with `date` | exit 0, 790 s, 343 lines. The shipped fixture suite's 247 timed cases sum to 262 s; the rest was not broken down. |
| Verdict lines per guard section, same run | awk over the log, counting `ok`, `skip`, `WARN`, `FAIL`, `note` under each `▸` | every guard section printed at least one. Checks that share a section were not told apart. |
| A reference with no target | `grep -n -i companion harness/src/10-principles.md` | P3, P13 and P17 cite "P20's companion rule" or "companion failure". P20's text states no such rule. |
| One sentence, many copies | `grep -rlc 'oundaries determine when machinery intervenes' .` | 11 files, the five ledger preambles among them |
| References to principle numbers outside the principles file and the bundle | `grep -rwo` per number | P13: 59 in 13 files; P2: 52 in 19; P3: 50 in 19; P20: 8 in 6 |

### 3.1 Checked, and found sound

Recorded so they are not proposed again from this read.

- **Ledger identifiers cited in prose resolve.** Every identifier of the form used by the 217
  rows, in the constitution, runbook, state file, principles, plans and changelog, names a row.
  The one miss is P11's own example. No drift, so no guard (P20).
- **The command guard costs 30 to 41 ms per call** (`--command`, five runs each of four shapes).
- **The subagent rail's matcher fires on this host,** whose spawn tool is named `Agent`: one
  spawn was refused once with the rail's text. Observed once, in Claude Code on the web.

### 3.2 Re-taken on 2026-11-26, for the owner's points 5 to 8

Taken at `ffdb33f`, the tip of the train carrying 17.1.0, against `origin/main` at `6281bb5`,
on Linux. The same commands as §3; sentences by `count_sentences` on each section.

| What | Result |
|---|---|
| State file, by section | preamble 894 B, 6 sentences; Project 310, 2; Current state 1,719, 5; Owner queue 5,942, 40; Decided non-items 1,634, 1; Changelog 2,344, 3. Whole file 12,843 B and 52 sentences. |
| What no compression pass may fold | 8,780 B and 49 sentences, against landing ceilings of 9,216 B and 50. That leaves 436 B and one sentence for Current state and the Changelog, which hold 4,063 B and 8. **A pass over the trigger cannot land.** |
| Queue on this branch and on `main` | 11 items here, 193 to 1,803 B each; on `main`, 6 items in 2,270 B of a 9,507 B file. Since `main`, the train opened 6 items and closed 1, the 17.0.0 tag; the research-gaps item was reworded. |
| Kinds of item here | 4 decisions (backtick quotes, stand-down exits, the queue-cycle plan, N1's cross-plan order); 5 owner actions (G1, B1, the App re-probe, the tag, the Gemini CLI and Antigravity probe); 1 bug that asks for an investigation on Windows, not for an owner decision (**DD-124**); 1 with no action at all (the research-gaps leftovers). |
| The largest item | the Gemini CLI and Antigravity probe, 1,803 B: a probe procedure, its ledger-row format and its `grep`. |
| Tideo's queue, for comparison | 3 items in 3,304 B and 21 sentences, its preamble included. Each item is dated and asks for one action or decision, with one `Settles it` command. Its procedures live in its runbook and device test script. |
| Plans in `docs/plans/` | here: six, 207,690 B; three approve nothing and one approves only its own review (B1). On `main`: the finished research-gaps plan, its eight companions and the finished pipefail plan, besides four of today's six. |
| What ties a plan's archive to the merge | the status lines of the build-output and adapter plans ("The session that merges the train archives it afterwards") and the State file's line for the adapter plan. No session merges. Both plans' runner reads each unit's done marker from the file, which is a real reason not to move a plan while the runner has units left, and none once it has none. |
| What would notice a finished plan | the plan-orphan tripwire in `scripts/ladder.sh`, local and WARN-only, fires only for a plan the State file does not name. A finished plan the State file still lists never fires it. |

## 4. The cycle, read from the measurements

Four rules produce it together. Each is sound alone:

- a unit starts only on the owner's approval of that unit, so every unit is a queue item;
- a unit backed only by outside evidence measures first and routes what it finds, so one gap
  costs a measuring unit, a queue item and a fixing unit (H9 is the worked example);
- a reviewer may not apply what it has no mandate for, so each review leaves recommendations
  in the queue;
- anything a unit finds outside its scope is the owner's fork (**Session discipline** 7).

Nothing sets a default for a finding other than *ask*. So the queue grows with the amount of
work done, and it is charged to a file whose cap exists to evict volatile content. P0 says
owner attention is cut by removing unnecessary decisions and never by suppressing a warranted
one. The decisions to remove here are the repeated ones: the same question about a class of
finding, asked once per finding.

§3.2 adds three more drivers, and none of them is a rule:

- **a draft becomes a file.** An answer to the owner's question is committed as a plan with
  nothing approved, and the draft brings its own "review it" and "decide on it" items. That
  puts an extra plan and an extra item on top of every question;
- **nothing retires a plan.** Its archive step waits on a merge no session performs, and one
  parked segment keeps the rest live. The tripwire that should notice stays quiet while the
  State file still names the plan;
- **nothing bounds an item.** An item carries its procedure as well as its decision, so the
  queue grows by bytes faster than it grows by items, and the final chat message restates
  every byte (**Session discipline** 7).

M3 cuts the first rule's inflow, M3b the first two drivers, M4 the third, and M4b applies all
three once to the items open today.

**What this plan may not do.** P0 forbids making "owner decisions per change" a measured KPI.
§3's queue-flow count is a one-off diagnosis. No unit below prints it, stores it, or judges it.

## 5. The units

**Order: M1 → M2 → M3 → M3b → M4 → M4b → M5a → M5b → M6 → M8a → M7 → M8b to M8d → M9.**
Part A (M2 to M4b) carries the owner's points of 2026-11-10 and 2026-11-26 and comes first.
M3, M3b and M4 change rules and can share one review; M4b applies them and changes none. A blocked choice does not stall an independent
unit, and every unit still needs its own approval.

### M0 — commit the plan (docs-only): done 2026-11-10, as an open draft

### M1 — review of this plan, if the owner wants one (docs-only)

- **Do:** as H0.5 and N1 did. The reviewer replays §3, tests §4's reading against the queue's
  history, and attacks M3 and M4 for routes an agent could game. Findings fold in as rev 2
  with a row each.
- **Pass owed:** this unit is the pass.
- **Acceptance:** `scripts/ladder.sh --guards-only` green on the folded plan.

### M2 — measure the pressure and the flow (docs-only, measurement)

- **Why:** §3 shows the room left; it does not show a compression failing. And the downstream
  move is reported, not seen.
- **Do:**
  - In a throwaway clone, take the state file over the trigger the way ordinary work would,
    then compress it as the runbook directs, folding only completed stages. Record what the
    landing check says and how many bytes and sentences the fold could not reach.
  - For each queue item opened in the reachable history, record which rule in §4 opened it and
    how it closed. Where squash-merge has destroyed the answer, say so
    (**Session discipline** 9).
  - Record the owner's answers on the downstream move (§2, item 3).
- **Output:** a bounded summary appended here. It changes no rule.
- **Pass owed:** none mandatory.
- **Acceptance:** the replay script and its output are kept where a reviewer can reach them;
  every figure says measured, estimated or reported.

### M3 — give a finding a default other than *ask*

- **Why:** §4, and the owner's third point.
- **Options for the owner.** They combine.
  - (a) **Findings stay with their plan.** What a unit finds goes to a list in that plan, each
    entry with a disposition. The queue carries one item per live plan. Anything that cannot
    wait for the plan to close still goes to the queue at once: a leak, a red default branch,
    a fork that blocks the unit in flight, or any of the four fork kinds in
    **Session discipline** 7.
  - (b) **Dispositions are chosen once, at adoption.** With the plan, the owner picks what a
    unit may do with a finding unasked. The proposed class: fix it when the script's own header
    or a ledger row states the behaviour, a fixture fails without the fix, no list or rule
    widens, and the change is PATCH. Otherwise park it with the condition that reopens it.
    Otherwise queue it. The command-guard gap plan already splits its gaps into defects and
    widenings on this line.
  - (c) **A measuring unit says beforehand what result triggers the fix,** and the owner
    approves both together or neither.
  - (d) **A plan closes by triage.** Each parked finding is fixed, declined into the ledger as
    a non-item, or left parked with its condition. None becomes a new queue item by default.
  - (e) **A limit on plans in progress.** No new plan is drafted while more than a number the
    owner sets are unstarted, unless the owner asks for one. The owner asked for this one.
  - (f) No change.
  - Recommendation: (a), (b) and (d), with (c) for plans written from here on.
- **How each could be gamed.**
  - (b) lets a session call a widening a defect. The first two tests are artifacts: the quoted
    text and the failing fixture. The pass the unit already owes checks the classification.
    The class is the owner's and a session cannot widen it.
  - (a) lets findings sit where the owner does not look. The one queue item per plan states
    how many are parked, and the final chat message repeats it.
  - (e) can be met by growing one plan instead of opening another. It is prose-only and it
    stays so.
- **Touch:** `docs/PROTOCOLS.md` → **Session discipline** 5 and 7, the seed's
  `docs/PROTOCOLS.md`, and P8, P9 and P16 where they describe the queue and plans.
- **Pass owed:** rule review, at the strongest tier.
- **Acceptance:** the full ladder green; `scripts/guards/doc-navigation.sh` covers any new
  pointer. No check can show that sessions follow the new default, and the unit says so.

### M3b — a plan retires on its own trigger, and a draft is not a file

- **Why:** the owner's points 7 and 8 (§1); §3.2; §4's first two added drivers.
- **Proposed rules.** They combine.
  - (a) **A plan is archived by the commit that settles its last unit**, or earlier, once
    every unit left is done, parked or declined. No merge, tag or release gates it, and the
    archive travels in the train like any other change. Units on `main` or in a tag are done
    for this purpose.
  - (b) **Leftovers do not pin a plan.** At archive time each parked unit becomes one ledger
    row naming its reopening condition, with a Decided non-items line where one is due. A
    declined unit becomes a non-item. A reopened unit starts a new plan. The research-gaps item
    in the queue is the worked case (M4b).
  - (c) **A plan a runner drives is archived in the commit after its runner's last unit**, so
    the runner still finds its done markers. This is the one wait (a) allows, and it is on a
    file, not on the forge.
  - (d) **An answer to the owner's question is reported in chat, not committed as a plan.** It
    becomes a file when the owner approves a unit of it, or asks for the file. Then its first
    unit is the review or decision it needs, and it adds one queue item, never two.
  - (e) The tripwire stays as it is, local and WARN-only; it already catches a plan the State
    file forgets. A check that a listed plan is finished would judge meaning, and P3 forbids
    building a gate on that.
  - (f) No change.
  - Recommendation: (a) to (d). Of the live plans, rule (a) archives the adapter plan in the
    commit after A5's runner, and rule (b) closes the research-gaps item.
- **How each could be gamed.**
  - (a) lets a session call a unit parked to retire a plan early. Parking writes a ledger row
    with the reopening condition, and the owner sees the row; declining stays the owner's.
  - (d) lets a session keep a long answer in chat, where no later session reads it. That is
    the point: an unapproved answer is the owner's to keep or drop. If kept, it becomes a
    file under (d).
- **Touch:** `docs/PROTOCOLS.md` → **Session discipline** 5, the seed's `docs/PROTOCOLS.md`,
  the archive paragraphs of P2 in `harness/src/10-principles.md` (then
  `scripts/build-dist.sh`), and the status lines of the live plans that tie the archive to the
  merge.
- **Pass owed:** rule review, at the strongest tier; shared with M3's where the owner agrees.
- **Acceptance:** the full ladder green, dist-drift included; no live plan's status line names
  the merge as its archive trigger (`grep -n 'merges the train' docs/plans/*.md` prints
  nothing). No check can show that sessions report drafts in chat, and the unit says so.

### M4 — size the protected sections without an uncounted one

- **Why:** §3. The sections no pass may fold took 80 % of the byte ceiling and 84 % of the
  sentence ceiling on 2026-11-10, and 95 % and 98 % on 2026-11-26 (§3.2), when a pass over
  the trigger could no longer land. **DB-028** and **DB-029** met the same defect with the
  preambles, and the owner's first point is a downstream instance of it. The owner's fifth
  point (§1) names it as a mistake, and Tideo's queue (§3.2) shows the bounded form working.
- **Options for the owner.**

  | Option | What it does | What it costs, and how it could be gamed |
  |---|---|---|
  | (a) Exempt the queue from the landing ceilings | the fold is judged on what can be folded | **Withdrawn.** An uncounted section is somewhere to put text that should have been folded (owner, 2026-11-10). |
  | (b) Move the queue, Decided non-items or both to their own files | the state file holds only what folds | Without its own bound the new file is (a) by another route. P2 warns against moving the queue out of the one file every session is sure to read. Each new file is another mandatory read. For Decided non-items, a file read only on demand is no longer in front of a session before it proposes something. |
  | (c) Bound the form of a queue item | a new or changed item meets a sentence and byte boundary, as a new ledger row does; the detail lives in the plan section or ledger row it names | Nothing is uncounted. It does not limit how many items there are, so it cannot delay a fork. An agent can split one long item into several, which the owner sees. |
  | (d) One budget per region | ceilings for what folds, a separate boundary for the protected sections | Nothing is uncounted, and moving text between regions escapes nothing. But a boundary that refuses a new queue item suppresses a fork, which P0 forbids, and one that only warns is a soft version of (a). |
  | (e) Name the condition | when the protected sections alone leave too little room, the rung says the fold cannot reach the ceilings and that relief is the owner's; the session parks instead of shaving | No exemption and no new budget. Substantive work stops until the owner answers, which is either the limit M3(e) asks for or an outage, by the owner's reading. |
  | (f) Raise the numbers | more room | Treats the size and not the inflow; **DB-038** and **DB-040** are the cautions. |

  Recommendation: M3 and M3b first, because they cut what flows in; then (c) and (e); then
  measure again before considering (b) or (d). For (c), the form is Tideo's: an item is a
  decision (the fork, its options, a recommendation) or one owner action, dated, with at most
  one `Check:`; a procedure it needs lives in the runbook, a plan section or a ledger row, and
  the item names it. The boundary is set like the new-row boundary in `amh.conf`, and only a
  new or changed item is measured, so no open item fails the day the rung ships. For Decided non-items: leave it in the state file until
  M2 has the downstream facts. If it moves, the destination is a runbook section with the
  pointer and heading in `scripts/guards/doc-navigation.sh`, and every playbook that can
  propose machinery names it as a read. That would be the owner's third grant of this kind.
- **Pass owed:** one combined rule-review and adversarial pass, at the strongest tier. (c) and
  (e) change `scripts/ladder.sh`, which is glue.
- **Acceptance:** for each rung change, a fixture that fails without it
  (`docs/RUNBOOK.md` → **Add a guard**); the full ladder green; the seed state file and seed
  runbook reconciled in the same unit.

### M4b — triage the open queue under M3, M3b and M4 (docs-only)

- **Why:** the rules above slow the inflow; the 11 items open on 2026-11-26 are still there.
  This unit applies the rules once, and changes none.
- **Do:** re-take §3.2's item list, then for each item:

  | Item | Proposed disposition | Owner answer needed |
  |---|---|---|
  | Research-gaps leftovers (P6, H8) | one ledger row with both reopening conditions and a Decided non-items line; delete the item (M3b(b)) | none, if M3b is adopted |
  | G1 and B1, the two gpt-6-astra review runs | one item: "run these reviews", listing both | none |
  | Gemini CLI and Antigravity live probe | the procedure moves to `docs/RUNBOOK.md` → **Host rails and what they miss**; the item keeps the action and its `Check:` | whether to decline the Gemini CLI half: the owner reported its retirement for most users on 2026-06-18 |
  | Antigravity App re-probe on Windows | kept, shortened to the action and a pointer to the same runbook procedure | none |
  | N1's cross-plan order | the order it states interleaves research-gaps units that are all done | close it, or restate it for the plans still live |
  | Windows no-Python fallback exit 127 | an investigation for a session on a Windows host, not an owner decision: a parked finding of the adapter plan, with its condition | whether it waits for a Windows session |
  | Tag `amh-v17.1.0` | kept | none |
  | The queue-cycle plan itself | kept until M1 and adoption are decided | none |
  | Backtick quotes; stand-down exits | kept; each shortened to the M4(c) form | none |

- **Pass owed:** none mandatory: it moves text and changes no rule. A ledger row it writes
  carries the evidence for its condition (**Session discipline** 11).
- **Acceptance:** `scripts/ladder.sh --guards-only` green; every deleted item has its outcome
  as a ledger row or Changelog line (the queue's preamble); every kept item meets M4(c)'s
  boundary if that unit has shipped.

### M5a — a ledger search prints headlines first (docs)

- **Why:** §3. A row is now one line, so a search returns whole rows.
- **Do:** add one example to `docs/RUNBOOK.md` → **Efficient document retrieval**: search the
  volume chain, print each hit's identifier and bold headline, then read the rows chosen. It
  must also work on the wrapped volumes, where a headline can run past its first line.
- **Pass owed:** none for this repository's runbook, where the section is operational. The
  seed runbook is under `harness/templates/`, so carrying the example there owes the
  rule-review pass; the owner picks whether this unit includes it.
- **Acceptance:** the example, run as written, prints one line per matching row in every
  volume; `scripts/ladder.sh --guards-only` green.

### M5b — decide whether the rollover boundary still means anything (measurement, then the owner)

- **Why:** **DA-022**(d) kept the line boundary as a proxy and had the rung report bytes
  beside it. Its figures, 826 lines and 74 KB at rollover, describe wrapped rows.
- **Do:** re-take §3's ledger rows and put three options to the owner: no change; a boundary
  on rows instead of lines; a lower `LEDGER_LINE_CAP`. A failing byte cap is not among them:
  **DA-022** declined it and this plan has no incident to reopen it with.
- **Pass owed:** rule review if a boundary changes. The decision itself owes none.
- **Acceptance:** the figures are replayable; the choice is recorded as a ledger row.

### M6 — list the checks that can end without a verdict (measurement)

- **Why:** the ladder is green when no check counted a failure. **DD-072** found two checks
  that printed nothing over a defect. §3 shows every guard *section* printed a verdict on a
  green tree, which says nothing about checks that share a section.
- **Do:** for each check in `scripts/ladder.sh` and each repo-local guard, record whether it
  can return without printing `ok`, `skip`, `WARN` or `FAIL`, and whether that is by design.
  Hand the list to the open decision on **DD-072**, so a fix can cover the class and not only
  `mktemp`. This unit repairs nothing.
- **Pass owed:** rule review, since it evaluates a change to guard semantics
  (**Session discipline** 10).
- **Acceptance:** each entry names the line and a replay; the list is appended here.

### M7 — P2 says what the analogy holds and where it does not

- **Why:** P2 calls the analogy "load-bearing, not decorative". Read against the tree:
  - **the state file is not volatile.** It is committed, and P5's flush writes to it first.
    The volatile tier is the context window, which the table omits;
  - **read-only memory costs nothing to keep; the constitution is paid for every session.**
    "No number on it" rests on **DB-038**'s reasoning and not on the analogy;
  - **hardware relieves memory pressure by swapping to disk and ages a journal to tape.** AMH
    forbids rotating the state file and archiving the residue of a compression pass. Both
    rules are right, and the analogy points the other way;
  - **the runbook, plans, the guard's header and the configuration's comments have no tier.**
  P2 names three corollaries the analogy makes "self-evident" and then needs about ten
  paragraphs that it did not predict.
- **Options for the owner:** (a) keep the names; add the context window as the tier above;
  restate corollary (a) as context to commit; say where the analogy stops; drop the
  load-bearing claim until a scenario tests it. (b) Replace the table with two axes: when a
  text is loaded (always, on a trigger, by address, never) and how it may change. (c) No
  change. Recommendation: (a), with (b)'s two axes as one sentence.
- **Touch:** `harness/src/10-principles.md`, then `scripts/build-dist.sh`
  (`docs/RUNBOOK.md` → **Change or add a harness principle**).
- **Pass owed:** rule review, at the strongest tier.
- **Acceptance:** the full ladder green, dist-drift included. No rule's force changes; the
  reviewer checks that.

### M8 — state once what is now said in several places

Four separate units; each is the playbook above, rule review at the strongest tier, and the
full ladder.

- **M8a — the reference with no target.** State the rule that "P20's companion" points at:
  prose must not imply a check no script performs, and each rule says which layer holds it.
  **D-010** is its row. P3 is the likely home.
- **M8b — the incident bar.** It decides more proposals than any numbered principle and has
  no number. The owner's answer of 2026-11-10 is now written down for the command guard only,
  in P13 (**DD-074**): a defect in what it already claims is a bug, and a widening is gated by
  what it newly refuses. Whether that rule reaches any other rail stays M8b's question; the
  owner declined to widen it on 2026-11-13.
- **M8c — a check has three answers.** Clean, dirty and did-not-look, and the third never
  prints as the first. It is in P9's release line, **DC-002**, `scripts/guards/path-refs.sh`,
  the session banner and **DD-072**, and is stated as a principle nowhere.
- **M8d — what a threshold is for.** One principle in place of the sentence §3 found in 11
  files. The five ledger preambles are editable; the rows are not, and none need change.

### M9 — consolidate without renumbering

- **Why:** P13 holds permission rails, guard design rules, deletion case law, the pre-push
  rail and the branch model. P6 is inside P0. P8 and P9 are one mechanism. P20 follows from P3
  and the incident bar.
- **Constraint:** §3's reference counts. Renumbering would touch shipped scripts and every
  adopter's citations.
- **Options for the owner:** (a) move only the branch model out of P13 under a new number at
  the end, and move the Windows spelling detail to the guard's header, which is already the
  authority on coverage; (b) also merge the pairs, leaving the old numbers as one-line
  pointers; (c) no change. Recommendation: (a).
- **Pass owed:** rule review, at the strongest tier.
- **Acceptance:** the full ladder green; every moved sentence appears at its destination; no
  number changes meaning.

## 6. What this read hands to other plans

Recommendations only. Each belongs to the plan or queue item named, and none is a unit here.

- **Order across plans.** The research-gaps plan's evidence units (H5, H6a, H7) and its
  sandbox units (H4a, H4b) ahead of further guard arms, where a sandbox runs. 46 of volume D's
  72 rows concern the rails or redaction, and 20 of 45 changelog sections mention them. The cross-plan order is already an
  Owner-queue item. As of 2026-11-26 every research-gaps unit is done or parked, and M4b asks
  whether that item still has a question in it.
- **The live plans' archive lines.** Under M3b the build-output and adapter plans drop "the
  session that merges the train archives it"; that edit is M3b's, not theirs.
- **A stopping rule for guard arms.** M8b would supply it.
- **H2's first candidate.** The constitution and its seed describe guard coverage in detail,
  and the seed is copied once while the scripts upgrade, so an adopter's constitution comes to
  describe an older guard. The obligation can stay and the coverage can live in the header.
- **The adaptation notes say the owner's touchpoints are "exactly three".** Here the owner
  also approves units, launches reviewers and subject runs, and decides versions. Whether that
  sentence is a goal or a description is the owner's to say; M3 is what would move practice
  toward it.

## 7. Parked

- **The subagent rail refuses a page fetch once** on a host that fetches through an agent
  type. Observed once (§3.1). One blocked turn per fetch; reopens if it costs a session more
  than that.
- **Full-ladder time, 790 s.** No incident. Reopens if a session is recorded skipping the
  full ladder for its cost.

## 8. Not verified

- Anything about the downstream repository beyond the owner's sentence.
- That a compression pass would fail to land. §3 measures the room; M2 runs the fold.
- Which rule opened each queue item. §3 counts headings and does not classify them.
- Anything on Windows or macOS, and any host but Claude Code on the web.
- Every remedy. Each is a design, not measured code.
- The reading of P2 in M7 is this session's, checked by no reviewer.
- That Tideo's queue stays small *because* of its item form. §3.2 compares one snapshot of
  each; neither queue's history was measured for it.
- How each live plan began. §1, item 7 reads each plan's own account of its origin; no chat
  record was consulted.
