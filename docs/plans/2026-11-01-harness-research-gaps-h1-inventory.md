# H1 — what each session must read, item by item

> **Companion to `docs/plans/2026-11-01-harness-research-gaps.md`, unit H1. Measured 2026-11-13
> at input revision `9ea4cee`.** A measurement, not a proposal: it grants no relocation
> authority and changes no rule (the plan's H1 **Output**). Every number below came from the
> commands in §7, run against that revision. They will drift, so a unit that acts on one first
> re-takes it (the plan's status block). H2, H3 and H5 read this file. If any of them changes an
> input, the inventory is redone at the new revision or left frozen at this one (the plan's §7.1).

## 1. Contexts and read classes

Eight contexts: this reference instance and an adopter install at each of the three `--profile`s,
each under the two first-class hosts. Standard and full share a row below, because they measured
the same. An adopter install was rendered by the revision's own `scripts/amh-init.sh`
into an empty git repository, with defaults. Its content placeholders (`{{$MODULE_MAP}}` and the
rest) are still unfilled, so an adopter's real constitution differs by whatever they write there.

Four read classes, kept apart:

- **Injected:** text the host puts in front of the model with no action by the agent.
- **Mandatory:** text a binding sentence tells every session to read before or during its work,
  traced through every file it names.
- **Task-triggered:** text bound to a task, a phase or a condition.
- **Available:** text that can be retrieved, with no rule saying when.

| Context | Injected | Mandatory (beyond injected) | Total, bytes |
|---|---|---|---|
| reference / Claude Code | `CLAUDE.md` 430; banner 1,630 | `AGENTS.md` 15,274; `docs/STATE.md` 9,164; RUNBOOK **Session discipline** 13,586 | 40,084 |
| reference / Codex | `AGENTS.md` 15,274 (documented, unverified); banner 1,630 (unverified) | `docs/STATE.md` 9,164; **Session discipline** 13,586 | 39,654 |
| adopter light / Claude Code | `CLAUDE.md` 430; banner 790 | `AGENTS.md` 20,580; `docs/STATE.md` 3,661; **Session discipline**: not installed | 25,461 |
| adopter light / Codex | `AGENTS.md` 20,580 (unverified); banner 790 (unverified) | `docs/STATE.md` 3,661; **Session discipline**: not installed | 25,031 |
| adopter standard or full / Claude Code | `CLAUDE.md` 430; banner 802 | `AGENTS.md` 20,580; `docs/STATE.md` 3,661; **Session discipline** 12,291 | 37,764 |
| adopter standard or full / Codex | `AGENTS.md` 20,580 (unverified); banner 802 (unverified) | `docs/STATE.md` 3,661; **Session discipline** 12,291 | 37,334 |

How each cell is known:

- **Claude Code injection, observed** in the session that measured this, on 2026-11-13. The
  project `CLAUDE.md` and the SessionStart hook's output both appeared in its context. Nothing
  imports `AGENTS.md` into `CLAUDE.md`, so `AGENTS.md` reaches a Claude Code session only
  because `CLAUDE.md` tells it to "Read `AGENTS.md` in full". It is mandatory, not injected.
- **Codex injection, documented only.** Codex's own documentation says it loads `AGENTS.md`
  as its project document. Nothing in this repository sets a project-document key
  (`project_doc_max_bytes` or a fallback filename). No Codex session was run here, so neither
  that load nor whether Codex shows the SessionStart hook's output to the model was observed.
- **The banner's size, measured,** by running the revision's `scripts/session-start.sh` in the
  exported or rendered tree. It has no `origin` remote and a throwaway `HOME`. A live clone
  prints more lines (release-tag and remote-branch probes), so 1,630 is a floor for the
  reference instance. This session's own banner was longer.
- **Not counted:** user-level host files outside the repository (a user `CLAUDE.md`, a
  user-level settings file, the local orchestration banner under the untracked `.orch/`). They
  are not part of AMH, and nothing here can see them.

**Task-triggered text at the reference instance**, in bytes. Each is a whole RUNBOOK section, an
upper bound for a task that needs one playbook from it:

- **Change-type playbooks** 15,820, when selecting the task's procedure (step 3);
- **Acceptance ladder** 4,050, at unit end (step 6);
- **Rule-review protocol** 9,447, for a legislation diff;
- **Adversarial review protocol** 3,728, for a diff the fixtures cannot see;
- **Working-memory compression** 7,153, when `docs/STATE.md` crosses its trigger;
- **Efficient document retrieval** 1,142, named from **Working guidance**;
- **Incident: leaked credential** 1,568, on exposure;
- `amh.conf` 11,864, for current values;
- the command guard's **what this guard does NOT catch** header block, before treating a
  green check as safety;
- one ledger row per lookup, by grep.

At an adopter's standard profile the same sections measure 1,088, 4,226, 3,250, 1,775, 7,859,
none (the seed runbook has no **Efficient document retrieval**) and 876. `amh.conf` is 14,747.

**Available, not mandatory:** the rest of `docs/RUNBOOK.md` (61,348 in full here, 34,020 in the
seed), the ledger volumes (`docs/LEDGER.md` alone is 74,276 here, 3,053 in the seed), `harness/`
and `docs/history/`.

## 2. The trace, and what it found

Mandatory references, followed recursively from the injected files:

- **Reference instance.** `CLAUDE.md` → `AGENTS.md` (A011–A018). From `AGENTS.md`:
  - `scripts/session-start.sh`, wired to SessionStart in both adapters. It was seen running
    under Claude Code; under Codex only the wiring is established;
  - `docs/STATE.md`, step 2;
  - **Session discipline**, "every session" (A018.1).
  
  `docs/STATE.md`'s preambles point at **Working-memory compression**, conditionally, and at
  **Session discipline** 7, already mandatory. **Session discipline** item 4 makes "the review
  protocols below" mandatory, triggered by the diff's kind, and item 5 points at the plan file
  of multi-unit work. That plan file is task-triggered, and today it is 71,174 bytes for the
  research-gaps plan alone.
- **Cycles, both benign:**
  - **Session discipline** 10 ↔ **Rule-review protocol**;
  - `docs/STATE.md` ↔ **Working-memory compression**.
  
  `AGENTS.md` mentions `CLAUDE.md` only to describe what a host mode skips. It does not tell a
  session to read it, so the two files form no cycle.
- **Missing destinations at the light profile, the default.** At light, `amh-init.sh` installs
  no `docs/RUNBOOK.md` and no `docs/LEDGER.md` (`seed_min_rank`). The seed constitution still
  names both unconditionally, and five of those names are mandatory or phase-bound:
  - S012, the step-3 playbook;
  - S013, "Do the work under RUNBOOK **Session discipline**";
  - S026.5, **Session discipline** 12;
  - S038, the incident playbook;
  - S006, S030 and S031, the ledger.
  
  The seed `docs/STATE.md` preambles also point at **Working-memory compression** and
  **Session discipline** 7. `scripts/session-start.sh` alone adapts: its protocol pointer
  changes when `docs/RUNBOOK.md` is absent. So a light adopter's agent is told to follow
  procedures its tree does not contain. This inventory records that and decides nothing about
  it. It is H3's input (layout and migration).
- **Missing at every profile, by design.** S002, the seed's install comment, names
  `harness/src/10-principles.md` and `docs/UPGRADING.md`. Both are AMH files and are never
  installed into an adopter. The comment addresses the human adopting AMH, who reads them in
  this repository.
- **Unknowns, and what would settle each:**
  - **Codex's project-document load and its byte limit.** A Codex session in this repository
    that reports what it was given.
  - **Whether either host passes SessionStart output to the model on every start mode.** Claude
    Code's was observed on startup only; resume, clear and compact were not observed.
  - **Whether a host truncates a long `CLAUDE.md` or `AGENTS.md`.** Not measured. Both
    constitutions are under 21 KB.
  - **How much of a mandatory read an agent actually performs.** Not measurable from the tree.
    It is H6a's kind of question.

## 3. Method and legend

Each constitution was split by the extractor in §7 into **spans**:
- a heading;
- a paragraph;
- a top-level list item with its indented continuation;
- a blockquote run;
- a fenced block.

A span carrying more than one obligation, or more than one content type, was then split by hand
into **items**. Each item is anchored by its exact opening words. The checker in §7 finds each
anchor in the source text itself, not in the extractor's output.

**Type:**
- **B**, a binding obligation;
- **C**, a description of what a guard or rail covers or misses;
- **R**, rationale or history.

Two more types were needed and are marked as added here:
- **M**, map: a heading, a layout description or a pointer;
- **P**, a placeholder the adopter fills, which becomes whatever they write.

**Applicability** is four independent columns, and combinations are allowed:
- **host:** `all`, `claude`, `codex`, `hookless` (no pre-execution hook), or `adopter` (the human
  installing);
- **platform:** `all` or `windows`;
- **task:** `any`, or the task that triggers it;
- **phase:** `start`, `work`, `unit-end`, `commit`, `push`, `PR`, `incident`, `install` or
  `any`.

A seed placeholder is written here as `{{$NAME}}`, because a live file in this repository may not hold an unfilled one (`scripts/guards/placeholder-integrity.sh`). The checker reads it back as the source spells it. An item's bytes (`~`) are measured on its whitespace-normalised text. They undercount the
source slightly, so a span's own byte count is the exact figure.

The classification is one reader's judgement. The checker verifies that it is complete and
anchored. It cannot verify that a type or an applicability is right. That is review work.

## 4. Totals

Each line gives items, then bytes (items at `~`). The bytes are measured on whitespace-normalised
text and undercount slightly.

**`AGENTS.md`:**
- B: 73 items, 8,577 bytes;
- C: 15 items, 3,720 bytes;
- R: 3 items, 527 bytes;
- M: 24 items, 2,140 bytes.

Of the B bytes, 2,937 apply to any task and 5,640 to a named task. By phase, `work` holds 7,112
bytes and `start` 1,850. By host: 1,152 bytes apply to Claude Code alone, 729 to a hook-less
agent alone, and 361 to the two first-class hosts routing PowerShell. 498 bytes are Windows-only.

**Seed `AGENTS.md`:**
- B: 91 items, 12,221 bytes;
- C: 23 items, 4,810 bytes;
- R: 7 items, 1,658 bytes;
- M: 19 items, 1,122 bytes;
- P: 13 items, 328 bytes.

Of the B bytes, 3,571 apply to any task and 8,650 to a named task. By phase, `work` holds 9,504
bytes and `start` 1,134. 908 bytes apply to a hook-less agent alone, 402 only to the human
adopting AMH, and 677 are Windows-only.

What the totals do not say: whether any item could move. Lesson 3 of the plan governs that,
and a byte count is not evidence for a move (§1 item 9).

## 5. Reconciliation

Checked at `9ea4cee` with the commands in §7:

- **`AGENTS.md`.** 180 nonblank source lines: none uncovered, none overlapping, and no blank line
  inside a span. 47 spans, all 47 classified, none unknown or duplicated. 25 spans split into 93
  items. Every anchor occurs exactly once, in order, and the first starts its span.
- **Seed `AGENTS.md`.** 258 nonblank lines, the same results: 54 spans, all classified, and 30
  spans split into 129 items.

The checker was made to fail before it was trusted, each case run against a scratch copy:
- a changed anchor exits 1 ("first child does not start the span");
- a deleted classification row is reported unclassified;
- a deleted extractor span leaves lines 80–81 uncovered.

The span byte counts, plus the file's blank lines, add up to its size: 15,260 + 14 = 15,274 and
20,608 + 29 = 20,637.

**What checked the splits, since the checker cannot.** The checker establishes completeness and
anchoring. It cannot tell whether an unsplit span holds two obligations, or whether a type is
right. That inspection was done twice, independently of the extractor:

1. **The author's own read.** It split 30 spans.
2. **A fresh-context review of that draft**, `gpt-6.1-sol` on 2026-11-13, the one review this
   unit took. Verdict FAIL. It found:
   - six items typed C or M that carry an obligation ("do not infer coverage", "binds you",
     "Read the size of that claim");
   - 26 spans that still bundled several obligations;
   - six applicability errors;
   - three errors in §1 and §2.
   
   Each finding was re-read against the source and applied. A022 was split as well, because it
   holds a rule and its exception. S043.7, "Everything around it is yours", was retyped B,
   because it has the same force as the items the review named.

After the corrections, the checker's §7 list of unsplit multi-sentence spans names one: A027. It
was inspected and left whole. Its second sentence enumerates the first sentence's single
prohibition. That list is a prompt for a reader, not a verdict.

## 6. The inventory

### 6.1 `AGENTS.md` at `9ea4cee`

| id | lines | bytes | type | host | platform | task | phase | opens with |
|---|---|---|---|---|---|---|---|---|
| A001 | 1–1 | 44 | M | all | all | any | any | AMH meta-repository — maintenance guide |
| A002 | 3–5 | 209 | M | all | all | any | start | This repository is the source of |
| **A003** | 7–16 | 910 | split (para) | | | | | This file states the harness and |
| A003.1 | | ~176 | B | all | all | constitution-edit | work | This file states the harness |
| A003.2 | | ~99 | B | all | all | constitution-edit | work | A rule that still binds stays |
| A003.3 | | ~288 | B | all | all | constitution-edit | work | Supersession history, adoption narratives |
| A003.4 | | ~158 | R | all | all | constitution-edit | work | No byte cap governs this file |
| A003.5 | | ~188 | C | all | all | constitution-edit | work | What stands in is a reader |
| A004 | 18–18 | 35 | M | all | all | any | any | Sources and generated artifacts |
| A005 | 20–21 | 100 | M | all | all | harness-change | work | `harness/src/*.md` is hand-edited harness prose; `harness/dist/AMH.md` |
| A006 | 22–23 | 164 | M | all | all | shipped-script | work | `harness/templates/scripts/` contains the shipped, repository-agnostic scripts; |
| A007 | 24–25 | 171 | M | all | all | seed-change | work | `harness/templates/seed/` contains scaffolds copied once for |
| A008 | 26–27 | 133 | M | all | all | config-change | work | `harness/templates/configs/` contains adopter configuration templates; `amh.conf` |
| **A009** | 29–35 | 607 | split (para) | | | | | Code and guard fixtures settle what |
| A009.1 | | ~288 | B | all | all | doc-repair, ledger | work | Code and guard fixtures settle |
| A009.2 | | ~153 | B | all | all | ledger | work | marker is the one exception |
| A009.3 | | ~165 | B | all | all | rule-change | work | They do not settle what the harness |
| A010 | 37–37 | 30 | M | all | all | any | any | Universal session sequence |
| A011 | 39–39 | 70 | B | all | all | any | start | Run `scripts/session-start.sh` if the host has |
| **A012** | 40–43 | 380 | split (item) | | | | | Read `docs/STATE.md`, including the Owner queue; |
| A012.1 | | ~49 | B | all | all | any | start | Read `docs/STATE.md`, including the Owner queue |
| A012.2 | | ~67 | B | all | all | any | start | verify observable queue claims |
| A012.3 | | ~147 | M | all | all | any | start | The file is tree-relative by rule |
| A012.4 | | ~104 | B | all | all | any | start | check such a claim against a live source |
| **A013** | 44–45 | 136 | split (item) | | | | | Select the relevant procedure under `docs/RUNBOOK.md` |
| A013.1 | | ~85 | B | all | all | any | start | Select the relevant procedure |
| A013.2 | | ~44 | B | all | all | any | start | and read everything it names before editing |
| **A014** | 46–46 | 72 | split (item) | | | | | Work sequentially in a small, shippable |
| A014.1 | | ~18 | B | all | all | any | work | Work sequentially |
| A014.2 | | ~27 | B | all | all | any | work | in a small, shippable unit |
| A014.3 | | ~23 | B | all | all | any | work | with binary acceptance |
| **A015** | 47–51 | 550 | split (item) | | | | | Update `docs/STATE.md` with what stays true |
| A015.1 | | ~333 | B | all | all | any | unit-end | Update `docs/STATE.md` with what stays |
| A015.2 | | ~125 | B | all | all | state-over-trigger | unit-end | Over the compression trigger |
| A015.3 | | ~76 | B | all | all | runbook-insufficient | unit-end | Improve the runbook in the same change |
| **A016** | 52–54 | 230 | split (item) | | | | | With every file change of the |
| A016.1 | | ~123 | B | all | all | any | unit-end | With every file change of the unit made |
| A016.2 | | ~40 | B | all | all | any | unit-end | and review the command's actual output |
| A016.3 | | ~57 | B | all | all | any | commit | The tree the ladder verified is then |
| **A017** | 55–60 | 552 | split (item) | | | | | Commit with an honest verification disclosure. |
| A017.1 | | ~47 | B | all | all | any | commit | Commit with an honest verification |
| A017.2 | | ~184 | B | all | all | any | commit | Then run `scripts/ladder.sh --guards-only` |
| A017.3 | | ~236 | B | all | all | any | commit | If either fails, fix the commit |
| A017.4 | | ~66 | B | all | all | any | push | Then push the permitted |
| **A018** | 62–66 | 352 | split (para) | | | | | The procedures named in `docs/RUNBOOK.md` are |
| A018.1 | | ~283 | B | all | all | any | start | The procedures named in |
| A018.2 | | ~68 | C | all | all | rule-change | work | `RULE_FILES` is a tripwire |
| A019 | 68–68 | 19 | M | all | all | any | any | Hard boundaries |
| **A020** | 70–79 | 875 | split (item) | | | | | Never inspect or disclose credential values |
| A020.1 | | ~189 | B | all | all | any | any | Never inspect or disclose |
| A020.2 | | ~96 | B | all | all | guard-authoring | work | Automated identity checks may |
| A020.3 | | ~310 | B | all | all | credential | work | See `scripts/command-guard.sh` |
| A020.4 | | ~47 | C | all | all | credential | work | That block is the authority |
| A020.5 | | ~58 | B | all | all | credential | work | do not infer coverage in either direction |
| A020.6 | | ~73 | B | all | all | credential | any | This rule binds you whether |
| A020.7 | | ~81 | B | all | all | credential | incident | If exposure occurs |
| **A021** | 80–81 | 129 | split (item) | | | | | Never force-push or push to the |
| A021.1 | | ~17 | B | all | all | any | push | Never force-push |
| A021.2 | | ~49 | B | all | all | any | push | or push to the branch named by |
| A021.3 | | ~41 | B | all | all | any | push | Push only the configured session branch |
| A021.4 | | ~17 | B | all | all | any | push, PR | the owner merges |
| **A022** | 82–83 | 146 | split (item) | | | | | Never rewrite pushed history. The only |
| A022.1 | | ~30 | B | all | all | any | push | Never rewrite pushed history |
| A022.2 | | ~111 | B | all | all | credential | incident | The only exception is the owner-directed |
| **A023** | 84–85 | 145 | split (item) | | | | | Never hand-edit generated output, including `harness/dist/AMH.md` |
| A023.1 | | ~89 | B | all | all | generated-output | work | Never hand-edit generated output |
| A023.2 | | ~51 | B | all | all | generated-output | work | change its source and run the documented generator |
| **A024** | 86–88 | 219 | split (item) | | | | | Never patch a local `scripts/` copy |
| A024.1 | | ~66 | B | all | all | shipped-script | work | Never patch a local |
| A024.2 | | ~66 | B | all | all | shipped-script | work | Change the corresponding file under |
| A024.3 | | ~28 | B | all | all | shipped-script | work | copy it down byte-for-byte |
| A024.4 | | ~52 | B | all | all | shipped-script | work | and regenerate the manifest |
| **A025** | 89–90 | 171 | split (item) | | | | | Never rewrite, compress, renumber, or remove |
| A025.1 | | ~73 | B | all | all | ledger | work | Never rewrite, compress, renumber |
| A025.2 | | ~54 | B | all | all | ledger | work | Append the next identifier |
| A025.3 | | ~39 | M | all | all | ledger | work | `docs/STATE.md` identifies that volume |
| **A026** | 91–113 | 2213 | split (item) | | | | | Never exercise an unguarded destructive path |
| A026.1 | | ~154 | B | all | all | destructive | work | Never exercise an unguarded destructive path |
| A026.2 | | ~292 | B | all | all | destructive, guard-authoring | work | Deletions, truncations and resets |
| A026.3 | | ~151 | R | all | all | destructive | work | Running the unguarded operation |
| A026.4 | | ~559 | C | all | all, windows | destructive | work | `scripts/command-guard.sh` holds a literal |
| A026.5 | | ~366 | B | all | all, windows | destructive | work | A deletion the guard denied |
| A026.6 | | ~205 | B | all | all | destructive | work | A one-time advisory is different |
| A026.7 | | ~225 | C | all | all | destructive | work | An INLINE interpreter deletion |
| A026.8 | | ~159 | C | all | all | destructive | work | A path built from a variable |
| A026.9 | | ~55 | B | all | all | destructive | work | are prose-only and bind you, not a script |
| A027 | 114–116 | 269 | B | all | all | any | work | Never use self-reported attestations as machine-consumed |
| A028 | 118–118 | 26 | M | all | all | any | any | Progressive disclosure |
| A029 | 120–120 | 88 | M | all | all | credential | incident | Secret handling and incidents: `docs/RUNBOOK.md` → |
| A030 | 121–121 | 107 | M | all | all | any | start | Session execution, checkpoints, recovery, and owner |
| A031 | 122–122 | 70 | M | all | all | any | start | Change procedures: `docs/RUNBOOK.md` → **Change-type playbooks**. |
| A032 | 123–123 | 72 | M | all | all | rule-change | work | Binding-rule changes: `docs/RUNBOOK.md` → **Rule-review protocol**. |
| A033 | 124–124 | 95 | M | all | all | any | unit-end | Verification and locally unverifiable coverage: `docs/RUNBOOK.md` |
| A034 | 125–125 | 84 | M | all | all | state-over-trigger | unit-end | Compressing working memory: `docs/RUNBOOK.md` → **Working-memory |
| A035 | 126–127 | 105 | M | all | all | config-change | work | Current values, branch policy, rule-file scope, |
| **A036** | 128–131 | 363 | split (item) | | | | | Durable rationale, deviations, and discoveries: `docs/LEDGER.md` |
| A036.1 | | ~118 | M | all | all | ledger | work | Durable rationale, deviations |
| A036.2 | | ~236 | B | all | all | ledger | work | These are **retrieval storage** |
| A037 | 132–133 | 98 | M | all | all | any | start | Current work, owner decisions, historical pointers, |
| A038 | 135–135 | 20 | M | all | all | any | any | Working guidance |
| **A039** | 137–138 | 158 | split (item) | | | | | Match existing shell style and file |
| A039.1 | | ~44 | B | all | all | code-change | work | Match existing shell style |
| A039.2 | | ~109 | B | all | all | code-change | work | Preserve functional invariants |
| **A040** | 139–142 | 330 | split (item) | | | | | Keep document reads query-first and bounded: |
| A040.1 | | ~133 | B | all | all | reads | any | Keep document reads query-first |
| A040.2 | | ~126 | B | all | all | reads | any | Widen to adjacent or full content |
| A040.3 | | ~62 | M | all | all | reads | any | follow `docs/RUNBOOK.md` |
| **A041** | 143–144 | 159 | split (item) | | | | | Keep shipped scripts repository-agnostic. A repository-specific |
| A041.1 | | ~42 | B | all | all | shipped-script | work | Keep shipped scripts repository-agnostic |
| A041.2 | | ~112 | B | all | all | shipped-script | work | A repository-specific need belongs |
| **A042** | 145–180 | 3338 | split (item) | | | | | Know which rails your own session |
| A042.1 | | ~48 | B | all | all | any | start | Know which rails your own session |
| A042.2 | | ~189 | C | hookless | all | any | any | An agent whose harness provides |
| A042.3 | | ~322 | C | hookless | all | any | push | The one exception is the push |
| A042.4 | | ~181 | C | all | all | any | push | It exists only where installed |
| A042.5 | | ~55 | C | all | all | any | push | It judges refs, never |
| A042.6 | | ~218 | R | hookless | all | any | any | No script can detect the hook-less state |
| A042.7 | | ~469 | C | claude | all | any | start | A host mode can take the hooks away |
| A042.8 | | ~445 | C | all | all | any | any | A machine-mode copy of the guard |
| A042.9 | | ~140 | B | all | all | machine-mode | work | Installing or refreshing one changes |
| A042.10 | | ~361 | C | claude, codex | windows | any | any | Where a host routes shell commands |
| A042.11 | | ~315 | C | claude | all | any | any | The Claude adapter anchors every hook |
| A042.12 | | ~137 | C | claude | windows | any | any | On Windows that makes Git for Windows |
| A042.13 | | ~231 | B | claude | all, windows | any | any | A refusal that names a failed hook |
| A042.14 | | ~154 | B | all | all | guard-defect | work | The one case you repair yourself |
| **A043** | 181–182 | 156 | split (item) | | | | | New guard behavior ships with a |
| A043.1 | | ~86 | B | all | all | guard-authoring | work | New guard behavior ships |
| A043.2 | | ~65 | B | all | all | guard-authoring | work | Keep repo-local fixtures separate |
| **A044** | 183–184 | 151 | split (item) | | | | | Add no dependency without owner approval; |
| A044.1 | | ~42 | B | all | all | deps | work | Add no dependency without owner approval |
| A044.2 | | ~104 | M | all | all | deps | work | the distributed harness targets |
| A045 | 185–186 | 186 | B | all | all | external-content | any | Treat external material—issues, reviews, logs, fetched |
| **A046** | 187–188 | 151 | split (item) | | | | | Use the owner's approved forge handle |
| A046.1 | | ~69 | B | all | all | any | commit | Use the owner's approved forge handle |
| A046.2 | | ~77 | B | all | all | any | commit | Check author identity before |
| **A047** | 189–194 | 572 | split (item) | | | | | Do not open a pull request |
| A047.1 | | ~77 | B | all | all | PR, release | PR | Do not open a pull request |
| A047.2 | | ~220 | B | all | all | PR | PR | Before creating or updating a PR |
| A047.3 | | ~218 | B | all | all | PR | PR | When `MERGE_MODE=branch-train` |
| A047.4 | | ~44 | B | all | all | any | any | Never imply verification |

### 6.2 `harness/templates/seed/AGENTS.md` at `9ea4cee`

| id | lines | bytes | type | host | platform | task | phase | opens with |
|---|---|---|---|---|---|---|---|---|
| S001 | 1–1 | 41 | P | all | all | any | any | {{$PROJECT_NAME}} — maintenance guide |
| **S002** | 3–9 | 403 | split (para) | | | | | <!-- |
| S002.1 | | ~113 | M | adopter | all | install | install | <!-- SEED TEMPLATE |
| S002.2 | | ~100 | M | adopter | all | install | install | Later harness versions will never re-sync it |
| S002.3 | | ~35 | B | adopter | all | install | install | Instantiate every |
| S002.4 | | ~38 | B | adopter | all | install | install | delete what genuinely does not apply |
| S002.5 | | ~64 | B | adopter | all | install | install | and read harness/src/10-principles.md before deleting |
| S002.6 | | ~52 | R | adopter | all | install | install | most pieces earn their keep |
| S003 | 11–11 | 24 | P | all | all | any | start | {{$PROJECT_DESCRIPTION}} |
| S004 | 13–13 | 21 | P | all | all | any | start | {{$REFERENCE_SYSTEM}} |
| **S005** | 15–22 | 725 | split (quote) | | | | | **Ground truth:** code + {{$IMMUTABLE_FIXTURES}}. Docs |
| S005.1 | | ~187 | B | all | all | doc-repair | work | **Ground truth:** |
| S005.2 | | ~169 | B | all | all | ledger | work | The append-only ledger is the exception |
| S005.3 | | ~242 | B | all | all | rule-change | work | And the code settles only what |
| S005.4 | | ~110 | B | all | all | rule-change | work | Changing a binding rule to match |
| **S006** | 24–30 | 581 | split (para) | | | | | Long-term memory: numbered deviations and discoveries |
| S006.1 | | ~122 | M | all | all | ledger | work | Long-term memory: numbered deviations |
| S006.2 | | ~24 | B | all | all | ledger | work | code cites bare |
| S006.3 | | ~103 | B | all | all | ledger | work | code-cited rows carry a |
| S006.4 | | ~26 | C | all | all | ledger | work | nothing syncs it for you |
| S006.5 | | ~34 | B | all | all | ledger | work | never compress or delete entries |
| S006.6 | | ~51 | B | all | all | ledger | work | append the next number in |
| S006.7 | | ~107 | M | all | all | ledger | work | each file caps at |
| S006.8 | | ~113 | B | all | all | ledger | work | the final row may overflow the |
| **S007** | 32–54 | 1902 | split (quote) | | | | | **This file states the harness and |
| S007.1 | | ~282 | B | all | all | constitution-edit | work | **This file states the harness and the project |
| S007.2 | | ~164 | B | all | all | constitution-edit | work | **A rule that still binds stays |
| S007.3 | | ~322 | B | all | all | constitution-edit | work | Supersession history, adoption and upgrade |
| S007.4 | | ~143 | R | all | all | constitution-edit | work | That is not deletion |
| S007.5 | | ~168 | B | all | all | constitution-edit | work | Moving anything out of this file |
| S007.6 | | ~348 | R | all | all | constitution-edit | work | **No byte cap governs this file |
| S007.7 | | ~161 | C | all | all | constitution-edit | work | What stands in for a cap is a reader |
| S007.8 | | ~37 | B | all | all | constitution-edit | work | and know exactly what that is worth |
| S007.9 | | ~230 | C | all | all | constitution-edit | work | it is a WARN that blocks nothing |
| **S008** | 56–65 | 855 | split (quote) | | | | | **Establish coverage before you report an |
| S008.1 | | ~294 | B | all | all | any | any | **Establish coverage before you report |
| S008.2 | | ~446 | R | all | all | any | any | The recurring trap is local git state |
| S008.3 | | ~94 | C | all | all | any | any | Nothing enforces this |
| S009 | 67–67 | 40 | M | all | all | any | any | Maintenance protocol (every session) |
| S010 | 69–69 | 22 | P | all | all | any | start | {{$BOOTSTRAP_STEP}} |
| **S011** | 70–77 | 713 | split (item) | | | | | Read `docs/STATE.md` — current project state, |
| S011.1 | | ~93 | B | all | all | any | start | Read `docs/STATE.md` — current |
| S011.2 | | ~344 | B | all | all | any | start | **A queue item is a claim |
| S011.3 | | ~251 | B | all | all | any | start | The same caution reaches |
| **S012** | 78–79 | 122 | split (item) | | | | | Open the matching change-type playbook in |
| S012.1 | | ~61 | B | all | all | any | start | Open the matching change-type playbook |
| S012.2 | | ~54 | B | all | all | any | start | read the reference docs it names |
| **S013** | 80–81 | 113 | split (item) | | | | | Do the work under RUNBOOK **Session |
| S013.1 | | ~50 | B | all | all | any | work | Do the work under RUNBOOK |
| S013.2 | | ~38 | B | all | all | any | work | sequential, small checkpointed units |
| S013.3 | | ~18 | B | all | all | any | work | binary acceptance. |
| **S014** | 82–85 | 454 | split (item) | | | | | Update `docs/STATE.md` with what stays true |
| S014.1 | | ~99 | B | all | all | any | unit-end | Update `docs/STATE.md` with what stays |
| S014.2 | | ~267 | B | all | all | any | unit-end | Never cache world-controlled status |
| S014.3 | | ~75 | B | all | all | runbook-insufficient | unit-end | If the runbook itself was insufficient |
| **S015** | 86–87 | 185 | split (item) | | | | | With every file change made — |
| S015.1 | | ~99 | B | all | all | any | unit-end | With every file change made |
| S015.2 | | ~48 | B | all | all | any | commit | so the tree it verified is the tree you commit |
| S015.3 | | ~31 | B | all | all | any | any | **Never leave the branch red.** |
| **S016** | 88–92 | 434 | split (item) | | | | | Commit, then run `scripts/ladder.sh --guards-only` once |
| S016.1 | | ~181 | B | all | all | any | commit | Commit, then run |
| S016.2 | | ~183 | B | all | all | any | commit | If either fails |
| S016.3 | | ~54 | B | all | all | any | push | Then push: |
| S017 | 94–94 | 27 | M | all | all | any | any | Build & verify commands |
| **S018** | 96–100 | 210 | split (fence) | | | | | ```bash |
| S018.1 | | ~166 | M | all | all | verify | unit-end | ```bash |
| S018.2 | | ~43 | P | all | all | verify | unit-end | {{$INDIVIDUAL_TEST_BUILD_LINT_COMMANDS}} |
| **S019** | 102–103 | 177 | split (para) | | | | | {{$VERIFICATION_LIMITS}} Every commit body states what |
| S019.1 | | ~24 | P | all | all | verify | commit | {{$VERIFICATION_LIMITS}} |
| S019.2 | | ~152 | B | all | all | any | commit | Every commit body states |
| S020 | 105–105 | 16 | M | all | all | any | any | Architecture |
| S021 | 107–107 | 15 | P | all | all | code-change | work | {{$MODULE_MAP}} |
| S022 | 109–109 | 22 | M | all | all | any | any | Coding conventions |
| S023 | 111–111 | 29 | P | all | all | code-change | work | {{$SEMANTIC_FIDELITY_RULE}} |
| S024 | 112–112 | 105 | B | all | all | code-change | work | Provenance comments on ported or spec-derived |
| S025 | 113–113 | 32 | P | all | all | tests | work | {{$FIXTURE_IMMUTABILITY_RULE}} |
| **S026** | 114–121 | 673 | split (item) | | | | | **A fix's test comes first, and |
| S026.1 | | ~219 | B | all | all | fix | work | **A fix's test comes first |
| S026.2 | | ~271 | B | all | all | fix, tests | work | A test that existed before the fix |
| S026.3 | | ~73 | B | all | all | fix, tests | work | The fixture rule above may forbid |
| S026.4 | | ~41 | C | all | all | fix | work | Prose-only: no guard checks |
| S026.5 | | ~52 | M | all | all | fix | work | See `docs/RUNBOOK.md` |
| S027 | 122–122 | 61 | B | all | all | deps | work | No new dependencies unless the change |
| S028 | 123–123 | 22 | P | all | all | code-change | work | {{$TOOLCHAIN_FLOOR}} |
| S029 | 124–124 | 53 | B | all | all | code-change | work | Match existing code style and file/package |
| S030 | 126–126 | 63 | M | all | all | any | any | Invariants that still bind (full catalog: |
| **S031** | 128–130 | 259 | split (para) | | | | | The catalog is **retrieval storage**: grep |
| S031.1 | | ~106 | B | all | all | ledger | work | The catalog is **retrieval storage** |
| S031.2 | | ~73 | B | all | all | ledger | work | Never read a ledger volume whole |
| S031.3 | | ~79 | B | all | all | any | any | and the shortlist below is what a session |
| S032 | 132–132 | 24 | P | all | all | any | start | {{$INVARIANT_SHORTLIST}} |
| S033 | 134–134 | 18 | M | all | all | any | any | Secret hygiene |
| **S034** | 136–141 | 473 | split (item) | | | | | The session environment carries credentials even |
| S034.1 | | ~84 | M | all | all | any | any | The session environment carries credentials |
| S034.2 | | ~200 | B | all | all | any | any | Never dump environments |
| S034.3 | | ~114 | B | all | all | any | any | Never print a credential's value |
| S034.4 | | ~62 | B | all | all | any | any | report key presence only |
| **S035** | 142–154 | 1128 | split (item) | | | | | **Which layer holds which half.** `scripts/command-guard.sh` |
| S035.1 | | ~365 | C | all | all | credential | any | **Which layer holds which half.** |
| S035.2 | | ~209 | C | all | all | credential | any | That enumeration is a **list, not a category** |
| S035.3 | | ~129 | B | all | all | credential | any | Its header carries the consolidated |
| S035.4 | | ~80 | B | all | all | credential | any | The bullet above binds you |
| S035.5 | | ~63 | C | all | all | credential | any | The deny rails add the spellings |
| S035.6 | | ~126 | B | all | all | credential | any | Anything else in this section |
| S035.7 | | ~129 | B | all | all | constitution-edit | work | Say which layer holds a rule |
| **S036** | 155–165 | 951 | split (item) | | | | | **The owner's personal identifiers are secrets |
| S036.1 | | ~333 | B | all | all | any | work, commit | **The owner's personal identifiers are secrets too** |
| S036.2 | | ~172 | B | all | all | commit | commit | **No PRE-COMMIT guard can see this** |
| S036.3 | | ~238 | C | all | all | commit | commit | Once it is committed the ladder's |
| S036.4 | | ~94 | C | all | all | commit | commit | **It cannot tell a personal address |
| S036.5 | | ~91 | B | all | all | commit | push | Fix what it finds before you push |
| S037 | 166–167 | 154 | B | all | all | credential | any | A diagnostic that seems to need |
| **S038** | 168–171 | 322 | split (item) | | | | | A **leaked** secret (commit, push, log): |
| S038.1 | | ~47 | B | all | all | credential | incident | A **leaked** secret (commit, push, log): stop |
| S038.2 | | ~42 | B | all | all | credential | incident | never repeat the value |
| S038.3 | | ~25 | B | all | all | credential | incident | Owner queue immediately |
| S038.4 | | ~59 | B | all | all | credential | incident | the owner rotates FIRST |
| S038.5 | | ~93 | B | all | all | credential | incident | (owner-executed, never by an agent) |
| S038.6 | | ~47 | M | all | all | credential | incident | See the incident playbook |
| S039 | 173–173 | 20 | M | all | all | any | any | Destructive work |
| **S040** | 175–182 | 724 | split (item) | | | | | **Exercise an unguarded destructive path against |
| S040.1 | | ~320 | B | all | all | destructive | work | **Exercise an unguarded destructive path |
| S040.2 | | ~228 | B | all | all | destructive, guard-authoring | work | This covers the demonstration |
| S040.3 | | ~159 | B | all | all | runbook-edit | work | If your `docs/RUNBOOK.md` has a guard-adding |
| **S041** | 183–186 | 310 | split (item) | | | | | **Never remove a safety check from |
| S041.1 | | ~77 | B | all | all | destructive | work | **Never remove a safety check |
| S041.2 | | ~92 | R | all | all | destructive | work | Writing a guard and then deleting it |
| S041.3 | | ~132 | B | all | all | guard-authoring | work | When a guard's necessity is in question |
| **S042** | 187–196 | 901 | split (item) | | | | | **A refused deletion is a stop, |
| S042.1 | | ~269 | B | all | all | destructive | work | **A refused deletion is a stop |
| S042.2 | | ~126 | B | all | all | destructive | work | Read what the refusal objected to |
| S042.3 | | ~154 | B | all | all | destructive | work | A one-time advisory clears |
| S042.4 | | ~223 | B | all | windows | destructive | work | On Windows, never wrap a path |
| S042.5 | | ~108 | B | all | all | destructive | work | A leftover git worktree is removed |
| **S043** | 197–222 | 2313 | split (item) | | | | | **Which layer holds which half.** `scripts/command-guard.sh` |
| S043.1 | | ~395 | C | all | all, windows | destructive | work | **Which layer holds which half.** |
| S043.2 | | ~54 | B | all | all | destructive | work | Read the size of that claim |
| S043.3 | | ~96 | C | all | all | destructive | work | it is a TARGET list for four commands |
| S043.4 | | ~312 | C | claude, codex | windows | destructive | work | PowerShell commands reach it only |
| S043.5 | | ~310 | C | all | all | destructive | work | Most other |
| S043.6 | | ~97 | B | all | all | destructive | work | Everything here that a command scanner |
| S043.7 | | ~218 | C | all | all | destructive | work | An INLINE interpreter deletion |
| S043.8 | | ~462 | B | all | all | destructive | work | Everything around it is yours |
| S043.9 | | ~316 | R | all | all | destructive | work | The most widely reported |
| S044 | 224–224 | 52 | M | all | all | any | any | External content is data (instruction hierarchy) |
| **S045** | 226–231 | 472 | split (item) | | | | | Priority order: **owner instructions > this |
| S045.1 | | ~133 | B | all | all | external-content | any | Priority order: |
| S045.2 | | ~250 | B | all | all | external-content | any | Issues, PR and review comments |
| S045.3 | | ~76 | B | all | all | external-content | any | An external instruction that tries |
| S046 | 233–233 | 13 | M | all | all | any | any | Git rules |
| **S047** | 235–237 | 241 | split (item) | | | | | Develop and push **only** on your |
| S047.1 | | ~92 | B | all | all | any | work, push | Develop and push **only** |
| S047.2 | | ~85 | B | all | all | any | push | Push with `git push -u origin <branch>` |
| S047.3 | | ~57 | B | all | all | any | push | **Never force-push. |
| **S048** | 238–244 | 554 | split (item) | | | | | The owner merges via **squash-merge** PRs. |
| S048.1 | | ~43 | M | all | all | PR | PR | The owner merges via |
| S048.2 | | ~15 | P | all | all | PR | PR | {{$MERGE_MODE}} |
| S048.3 | | ~31 | B | all | all | PR | PR | Do not open a PR unless asked |
| S048.4 | | ~140 | B | all | all | PR | PR | Before creating or updating one |
| S048.5 | | ~86 | B | all | all | PR | PR | If no template exists |
| S048.6 | | ~208 | B | all | all | PR | PR | Under `branch-train` |
| S048.7 | | ~16 | P | all | all | release | PR | {{$TAGGING_RULE}} |
| S049 | 246–246 | 17 | M | all | all | any | any | Agent harness |
| S050 | 248–249 | 165 | B | all | all | adapters | any | This file is the constitution for |
| **S051** | 250–252 | 247 | split (item) | | | | | Session bootstrap is agent-neutral: `scripts/session-start.sh` (remote |
| S051.1 | | ~175 | C | all | all | any | start | Session bootstrap is agent-neutral |
| S051.2 | | ~65 | B | hookless | all | any | start | If your harness has no session-start hook |
| **S052** | 253–261 | 719 | split (item) | | | | | Per-agent adapters live in dot-dirs and |
| S052.1 | | ~61 | B | all | all | adapters | work | Per-agent adapters live in dot-dirs |
| S052.2 | | ~570 | B | all | all | adapters | work | A new agent's adapter must |
| S052.3 | | ~69 | B | all | all | adapters | work | State explicitly which of those layers |
| **S053** | 262–280 | 1748 | split (item) | | | | | **An agent with no pre-execution hook |
| S053.1 | | ~215 | C | hookless | all | any | any | **An agent with no pre-execution hook |
| S053.2 | | ~367 | C | hookless | all | any | push | The git-native `pre-push` rail |
| S053.3 | | ~211 | C | all | all | any | push | Where it is installed |
| S053.4 | | ~122 | C | all | all | any | push | It is a guardrail `--no-verify` bypasses |
| S053.5 | | ~261 | R | hookless | all | any | any | No check can tell you |
| S053.6 | | ~407 | C | all | all | any | any | A machine-mode copy of the guard |
| S053.7 | | ~126 | B | all | all | machine-mode | work | Installing or refreshing one changes |
| **S054** | 281–287 | 643 | split (item) | | | | | **A hook that fails refuses the |
| S054.1 | | ~319 | C | all | all | any | any | **A hook that fails refuses the call |
| S054.2 | | ~142 | C | all | windows | any | any | Under such an adapter on Windows |
| S054.3 | | ~167 | B | all | all, windows | any | any | A refusal that names a failed hook |

## 7. Replay

Save the three blocks below to files in a scratch directory outside the repository, then run
these from the repository root. `<scratch>` is that directory:

```bash
git show 9ea4cee:AGENTS.md > <scratch>/A.md
git show 9ea4cee:harness/templates/seed/AGENTS.md > <scratch>/S.md
awk -v tag=A -f <scratch>/h1-spans.awk <scratch>/A.md > <scratch>/A.tsv
awk -v tag=S -f <scratch>/h1-spans.awk <scratch>/S.md > <scratch>/S.tsv
python3 -I <scratch>/h1-check.py <scratch>/A.md <scratch>/A.tsv docs/plans/2026-11-01-harness-research-gaps-h1-inventory.md A
python3 -I <scratch>/h1-check.py <scratch>/S.md <scratch>/S.tsv docs/plans/2026-11-01-harness-research-gaps-h1-inventory.md S
bash <scratch>/h1-measure.sh "$PWD" 9ea4cee
```

The checker reads the classification from §6 of this file, so an edit to a table is checked by
the next replay. The awk extractor counts bytes, not characters, under `mawk`, which is what
reproduced the totals above. Under another awk, compare `wc -c` first.

### `h1-spans.awk`

```awk
# h1-spans.awk — split a Markdown constitution into item spans.
# usage: awk -v tag=A -f h1-spans.awk FILE
# Prints one TSV row per span: id, start line, end line, kind, bytes, heading, first words.
# A span is a heading, a paragraph, a top-level list item with its indented continuation,
# a blockquote run, or a fenced block. Blank lines end paragraphs and list items.
function flush() {
	if (start) {
		n++
		printf "%s%03d\t%d\t%d\t%s\t%d\t%s\t%s\n", tag, n, start, last, kind, bytes, sect, substr(first, 1, 70)
	}
	start = 0; bytes = 0
}
function begin(k) { flush(); start = NR; kind = k; first = $0; bytes = 0 }
{
	line = $0
	if (infence) { last = NR; bytes += length(line) + 1; if (line ~ /^```/) { infence = 0; flush() } ; next }
	if (line ~ /^```/) { begin("fence"); infence = 1; last = NR; bytes += length(line) + 1; next }
	if (line ~ /^[ \t]*$/) { flush(); next }
	if (line ~ /^#+ /) { begin("heading"); sect = line; sub(/^#+ /, "", sect); last = NR; bytes += length(line) + 1; flush(); next }
	if (line ~ /^(- |\* |[0-9]+\. )/) { begin("item"); last = NR; bytes += length(line) + 1; next }
	if (line ~ /^>/) { if (!start || kind != "quote") begin("quote"); last = NR; bytes += length(line) + 1; next }
	if (!start) begin("para")
	last = NR; bytes += length(line) + 1
}
END { flush() }
```

### `h1-check.py`

```python
"""H1 reconciliation: check an item inventory against its source, independently of the extractor.

usage: python3 -I h1-check.py <source.md> <spans.tsv> <class.tsv|inventory.md> <prefix> [--table]

<source.md> is the constitution at the pinned revision (git show REV:path). <spans.tsv> is
h1-spans.awk's output for it. <class.tsv> is the hand classification: one row per span and per
split child (id, type, host, platform, task, phase, anchor); passing the inventory .md instead
reads the same classification from its tables. <prefix> is A or S.

Checks, each printed with its count:
  1. coverage, from the SOURCE, not from the extractor: every nonblank line lies in exactly one
     span; uncovered and overlapping lines are listed;
  2. identities: the extractor's span ids and the classification's parent ids are the same set;
  3. splits, from the SOURCE text: each child's anchor occurs exactly once in its parent's
     normalised text, the first child starts the span, and anchors appear in order;
  4. a list, not a check: unsplit spans of more than one sentence, for a reader to inspect.
Exit 1 on any failure of 1-3. --table prints the inventory as Markdown rows instead.
"""
import re
import sys

src_path, spans_path, class_path, prefix = sys.argv[1:5]
table = "--table" in sys.argv[5:]
src = open(src_path, encoding="utf-8").read().split("\n")
if src and src[-1] == "":
    src.pop()

spans = {}
for line in open(spans_path, encoding="utf-8", errors="replace"):
    f = line.rstrip("\n").split("\t")
    # the opening words come from the source line, never from awk's byte-cut excerpt
    spans[f[0]] = (int(f[1]), int(f[2]), f[3], int(f[4]), src[int(f[1]) - 1])

rows = []
if class_path.endswith(".md"):
    # The inventory file itself: its table rows are the classification. A parent row's type
    # cell reads "split (kind)"; a child's last cell is its anchor; an unsplit row has none.
    for line in open(class_path, encoding="utf-8"):
        cells = [c.strip() for c in line.strip().strip("|").split("|")]
        if len(cells) != 9:
            continue
        rid = cells[0].strip("*")
        if not re.fullmatch(prefix + r"[0-9]{3}(\.[0-9]+)?", rid):
            continue
        typ = "split" if cells[3].startswith("split") else cells[3]
        # This repository may not hold a live seed placeholder, so the file spells one with a
        # `$` after the braces; the source has none.
        anchor = cells[8].replace("{{$", "{{") if "." in rid else ""
        rows.append([rid, typ, cells[4], cells[5], cells[6], cells[7], anchor])
else:
    for line in open(class_path, encoding="utf-8"):
        f = line.rstrip("\n").split("\t")
        if not f[0].startswith(prefix):
            continue
        f += [""] * (7 - len(f))
        rows.append(f[:7])

fail = 0

# 1. coverage from the source
owner = {}
overlap = []
for sid, (a, b, *_rest) in spans.items():
    for n in range(a, b + 1):
        if n in owner:
            overlap.append(n)
        owner[n] = sid
nonblank = [i + 1 for i, t in enumerate(src) if t.strip()]
uncovered = [n for n in nonblank if n not in owner]
blank_in_span = [n for n in owner if not src[n - 1].strip()]
print(f"coverage: {len(nonblank)} nonblank source lines; uncovered {len(uncovered)} {uncovered[:10]}; "
      f"overlapping {len(overlap)} {overlap[:10]}; blank lines inside spans {len(blank_in_span)}")
fail |= bool(uncovered or overlap)

# 2. identities
parents = [r[0] for r in rows if "." not in r[0]]
missing = sorted(set(spans) - set(parents))
extra = sorted(set(parents) - set(spans))
dupes = sorted({p for p in parents if parents.count(p) > 1})
print(f"identities: {len(spans)} spans, {len(parents)} classified; unclassified {missing}; "
      f"unknown {extra}; duplicated {dupes}")
fail |= bool(missing or extra or dupes)


def norm(a, b):
    out = []
    for i, t in enumerate(src[a - 1:b]):
        t = re.sub(r"^>\s?", "", t).strip()
        if i == 0:
            t = re.sub(r"^(- |\* |[0-9]+\. )", "", t)
        out.append(t)
    return " ".join(x for x in out if x)


# 3. splits
child_bytes = {}
nsplit = nchild = 0
for r in rows:
    if r[1] != "split":
        continue
    pid = r[0]
    nsplit += 1
    a, b = spans[pid][0], spans[pid][1]
    text = norm(a, b)
    kids = [k for k in rows if k[0].startswith(pid + ".")]
    if not kids:
        print(f"  {pid}: marked split with no children")
        fail = 1
        continue
    offs = []
    for k in kids:
        nchild += 1
        cnt = text.count(k[6])
        if cnt != 1:
            print(f"  {k[0]}: anchor {k[6]!r} occurs {cnt} times in {pid}")
            fail = 1
            offs.append(None)
        else:
            offs.append(text.index(k[6]))
    good = [o for o in offs if o is not None]
    if offs and offs[0] != 0:
        print(f"  {pid}: first child does not start the span (offset {offs[0]})")
        fail = 1
    if good != sorted(good):
        print(f"  {pid}: anchors out of order {offs}")
        fail = 1
    ends = offs[1:] + [len(text)]
    for k, o, e in zip(kids, offs, ends):
        if o is not None and e is not None:
            child_bytes[k[0]] = len(text[o:e].encode("utf-8"))
print(f"splits: {nsplit} mixed spans split into {nchild} items")

# 4. a list for the reader, never a verdict: unsplit B/C/R spans of more than one sentence. One
# obligation can take two sentences, so each is for a reader to inspect; the checker cannot judge
# what an obligation is.
multi = []
for r in rows:
    if "." in r[0] or r[1] not in ("B", "C", "R"):
        continue
    a, b = spans[r[0]][0], spans[r[0]][1]
    n = len(re.findall(r"[.!?](?:\*\*)?(?=\s+[A-Z`*(]|$)", norm(a, b)))
    if n > 1:
        multi.append(f"{r[0]}({n})")
print(f"unsplit multi-sentence spans, to inspect: {len(multi)} {' '.join(multi)}")

if table:
    print()
    print("| id | lines | bytes | type | host | platform | task | phase | opens with |")
    print("|---|---|---|---|---|---|---|---|---|")
    for r in rows:
        if "." in r[0]:
            op = r[6]
            print(f"| {r[0]} | | ~{child_bytes.get(r[0], '?')} | {r[1]} | {r[2]} | {r[3]} | {r[4]} | {r[5]} | {op.replace('|', '/')} |")
        else:
            a, b, kind, nb, first = spans[r[0]]
            first = re.sub(r"^(>\s?|- |\* |[0-9]+\. |#+ )", "", first).strip()
            first = " ".join(first.split()[:6]).replace("|", "/")
            if r[1] == "split":
                print(f"| **{r[0]}** | {a}–{b} | {nb} | split ({kind}) | | | | | {first} |")
            else:
                print(f"| {r[0]} | {a}–{b} | {nb} | {r[1]} | {r[2]} | {r[3]} | {r[4]} | {r[5]} | {first} |")
sys.exit(1 if fail else 0)
```

### `h1-measure.sh`

```bash
#!/usr/bin/env bash
# H1 measurement: bytes a session is handed or told to read, per context.
# usage: h1-measure.sh <source-repo> <revision>
# Exports <revision> with git archive into a mktemp tree, renders an adopter install per
# profile with that tree's own scripts/amh-init.sh into fresh git repos, and prints TSV:
# context, class, item, bytes. Nothing in <source-repo> changes. The session-start banner is
# measured by running the exported tree's script with HOME pointed at the scratch tree.
set -euo pipefail
src=$1 rev=$2
work=$(mktemp -d) || { echo "mktemp failed" >&2; exit 1; }
trap 'rm -rf -- "$work"' EXIT
mkdir "$work/ref"
git -C "$src" archive "$rev" | tar -x -C "$work/ref"
# session-start.sh reads git state, so the export needs to be a repository.
git -C "$work/ref" init -q -b session/h1 && git -C "$work/ref" add -A &&
	git -C "$work/ref" -c user.name=h1 -c user.email=h1@example.invalid commit -q -m export

bytes() { if [ -f "$1" ]; then wc -c <"$1" | tr -d ' '; else echo MISSING; fi; }
# section <file> <heading text>: bytes from the '## <heading>' line to the next '## ' line.
section() {
	[ -f "$1" ] || { echo MISSING; return; }
	awk -v h="## $2" 'index($0, h) == 1 { p = 1; print; next } p && /^## / { exit } p' "$1" | wc -c | tr -d ' '
}
banner() { (cd "$1" && HOME="$work/home" AMH_REMOTE='' bash scripts/session-start.sh 2>/dev/null | wc -c | tr -d ' '); }
mkdir -p "$work/home"

row() { printf '%s\t%s\t%s\t%s\n' "$@"; }

measure() { # <context-label> <tree>
	local c=$1 t=$2 b
	b=$(banner "$t")
	row "$c/claude" injected CLAUDE.md "$(bytes "$t/CLAUDE.md")"
	row "$c/claude" injected session-start-banner "$b"
	row "$c/claude" mandatory AGENTS.md "$(bytes "$t/AGENTS.md")"
	row "$c/codex" injected AGENTS.md "$(bytes "$t/AGENTS.md")"
	row "$c/codex" injected session-start-banner "$b"
	for h in claude codex; do
		row "$c/$h" mandatory docs/STATE.md "$(bytes "$t/docs/STATE.md")"
		row "$c/$h" mandatory 'RUNBOOK Session discipline' "$(section "$t/docs/RUNBOOK.md" 'Session discipline')"
	done
	for s in 'Change-type playbooks' 'Acceptance ladder' 'Rule-review protocol' \
		'Adversarial review protocol' 'Working-memory compression' 'Efficient document retrieval' \
		'Incident: leaked credential'; do
		row "$c/both" task "RUNBOOK $s" "$(section "$t/docs/RUNBOOK.md" "$s")"
	done
	row "$c/both" task amh.conf "$(bytes "$t/amh.conf")"
	row "$c/both" available docs/RUNBOOK.md "$(bytes "$t/docs/RUNBOOK.md")"
	row "$c/both" available docs/LEDGER.md "$(bytes "$t/docs/LEDGER.md")"
}

measure reference "$work/ref"
for p in light standard full; do
	d="$work/adopt-$p"
	mkdir "$d" && git -C "$d" init -q -b main
	"$work/ref/scripts/amh-init.sh" --profile "$p" "$d" >/dev/null
	git -C "$d" add -A && git -C "$d" -c user.name=h1 -c user.email=h1@example.invalid commit -q -m init
	git -C "$d" checkout -q -b session/h1
	measure "adopter-$p" "$d"
done
```
