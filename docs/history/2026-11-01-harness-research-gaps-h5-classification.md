# H5 — enduring invariants and compensations, obligation by obligation

> **Companion to `docs/plans/2026-11-01-harness-research-gaps.md`, unit H5. Classified 2026-11-13
> at input revision `c0d0b74`.** A measurement and classification, not a proposal. It retires
> nothing, changes no rule and grants no retirement authority (the plan's H5). Neither a
> populated field below nor a passing model run authorizes a retirement. Any later retirement
> experiment names the one compensation it removes and shows that the invariant beside it still
> holds. Whether P6 admits retiring a compensation at all is the owner's question. The owner
> left it open on 2026-11-13, when H5 started, to be decided when a specific retirement is
> proposed. Every count below came from the checker in §7, run against the sources at that
> revision. A unit that acts on one re-takes it first.

## 1. What was classified

Four sources, as the plan's H5 names them: "H1's item inventory and the current Session
discipline items".

| Prefix | Source | Binding items |
|---|---|---|
| A | `AGENTS.md` | 82 |
| P | `docs/PROTOCOLS.md` → **Session discipline** | 72 |
| S | `harness/templates/seed/AGENTS.md` | 100 |
| Q | `harness/templates/seed/docs/PROTOCOLS.md` → **Session discipline** | 71 |

H1 measured the two constitutions at `9ea4cee`. H2 and H3 have changed both since, so H1's
inventory was re-taken here rather than reused (the plan's §7.1: an input that changed is
redone). H1 never itemized Session discipline, so P and Q are split here for the first time. The
other sections of the two protocols files are task-triggered, so H5 does not cover them: the
review protocols, the leaked-credential incident, the ladder and compression.

Only items typed **B** (binding) are classified. The other types follow H1's legend:
- **C**, what a guard or rail covers or misses;
- **R**, rationale or history;
- **M**, a map item;
- **P**, a placeholder.

Each of those rows stays in the tables, so the checker can reconcile every line of every source.

## 2. The three classes, and the test applied

- **I — invariant.** The obligation holds whatever the agent's capability. It encodes one of
  four things:
  - owner authority;
  - an effect that cannot be undone or that leaves the repository, such as pushed history, a
    disclosed credential, a deleted live tree or a published PR;
  - a property of the artifacts or of the evidence;
  - a policy the owner chose for the project.

  Removing it changes which outcomes are acceptable.
- **C — compensation.** A step, an order, a reading, a reminder or a self-check that exists
  because agents fail in a particular way: they skip steps, misjudge, over-trust a rail,
  overclaim, fan out or thrash. Removing it changes how reliably an acceptable outcome is reached,
  not which outcomes are acceptable.
- **X — mixed.** An obligation, still whole after H1-style splitting, whose wording carries both
  kinds. Its row names each part. Deleting the sentence would retire its invariant along with
  the compensation, so a retirement would first have to separate the wording (lesson 2).

The question asked of each item: *would this sentence still constrain an agent that never makes
the error it names?* Four boundary calls recur. They are stated so that a reader can dispute them
directly:

- **Session death is environment; context size is capability.** An obligation that exists
  because a session can end at any moment is an invariant (P004.7, P007.2). One that exists to
  save context is a compensation (A036.2, A040.1), because context windows are a model property
  that changes between models.
- **Reading binding text is an invariant; when to read it is a compensation.** The repository's
  procedures are owner-made and cannot be inferred. Under lesson 3 they bind only if they are
  read, so reading them is an invariant (A013.2). A timing attached to the read — "before
  editing", "before your first bulk deletion" — exists because agents act before reading, so it
  is a compensation (A013.3, A026.4).
- **Routing is an invariant.** A sentence whose only content is that another text binds is
  classified I, because removing it repeals that text (lesson 3). The text it routes to is
  classified where it stands (A018.2 → §6.2).
- **Disclosure is an invariant; the procedure behind it is a compensation.** The owner cannot see
  what ran, so a disclosure of what was verified is an invariant (A017.1, P011.8). A specific
  labelling or self-check procedure is a compensation (P012.2, A017.2).

For each C and X row the table records two fields:

- **Provenance:** the ledger row that records the incident, failure or decision the obligation
  answers, or "provenance unresolved". An adjacent row is not cited.
- **Failure condition:** what would go wrong without the obligation. It is "artifact-level" when
  the repository, its history, the forge or a filesystem sentinel could show it after the
  session. Where none was found, the row says "no artifact-level failure condition identified". A
  transcript might show such a failure, but AMH keeps no run receipts (**DA-025**).

A note that reads "as <id>" takes that row's failure condition.

Invariants carry provenance where it is known; the plan does not ask for it.

## 3. Method

1. **Spans.** H1's extractor (§7) split each source into spans at `c0d0b74`. P and Q are their
   **Session discipline** sections, cut at the next `## ` heading.
2. **Carried splits.** H1's splits were carried forward to A and S wherever H1's anchor text
   still occurs in the span. The script that did this was an authoring aid; the checker in §7 is
   what verifies the result against the source. H2 and H3 rewrote some spans, which were split
   again by hand: A018, A026, A042, S002, S013 and S018. The progressive-disclosure pointers H3
   added (A029, A032–A034) are typed M. P and Q were split by hand. The review (§8) then had more
   items split: A003, A013, S012 and S052. It also had seven items retyped B that H1's types had
   excluded: A040.3, A042.2, S013.4, S048.1, S053.5, P014.11 and Q013.13.
3. **Seed rows by reference.** A seed row that states the same obligation as a reference row
   reads "= <id>" and takes that row's class. A seed row whose substance differs is classified
   on its own. There are 31 of those: S002.3–.5, S006.2, S006.8, S007.8, S013.2, S013.4, S024,
   S026.3, S027, S031.3, S035.7, S037, S040.3, S042.4, S042.5, S047.2, S050, S052.1–.7, Q010.4,
   Q013.1, Q013.8, Q013.9 and Q013.11. One reference obligation has no seed counterpart: P013,
   which says a branch that outlives its squash merge is merged, never rebased. Eight rows of the
   reference Session discipline also point at the `AGENTS.md` row that states the same
   obligation.
4. **Provenance.**
   - First, the rows a source span cites inline.
   - Then one search of `docs/LEDGER*.md` by the read-only repository explorer (a Haiku model),
     given the list of compensations with no inline citation.
   - The session then read back the headline of every row the explorer named. Three candidates it
     offered did not support their obligation and were dropped: **DA-006**(c) is about release
     playbooks, not reading before editing; **D-018** only quotes "one focused hour"; **DC-016**
     is about settling forks while the owner slept.
   - P010 cites **DA-002** inline, but that row is about delete-blockers, so the provenance here
     is **DA-003**.
   - `docs/history/` was not searched.
5. **Judgement.** One reader made every classification: the session that wrote this file. The
   checker establishes reconciliation, coverage and citation resolution, and nothing about
   whether a class is right. That judgement is the owed rule-review pass (§8).

## 4. Totals

From the checker in §7 (measured):

| Source | B | classified here: I | C | X | by reference | C/X: provenance unresolved | C/X: no artifact-level failure condition |
|---|---|---|---|---|---|---|---|
| A | 82 | 50 | 21 | 11 | 0 | 3 | 12 |
| P | 72 | 31 | 23 | 10 | 8 | 9 | 19 |
| S | 100 | 19 | 5 | 2 | 74 | 3 | 5 |
| Q | 71 | 3 | 2 | 0 | 66 | 0 | 1 |
| **all** | **325** | **103** | **51** | **23** | **148** | **15** | **37** |

177 obligations are classified directly. 148 point at another row: 140 seed rows and 8 rows of
the reference Session discipline. Of the 74 directly classified compensating or mixed rows, 15
trace to no ledger row, and for 37 this search identified no artifact-level failure condition.
With every reference resolved, the 325 rows come to 183 invariants, 96 compensations and 46
mixed.

## 5. What the classification shows

These are observations about the table. None of them is a recommendation to retire anything.

- **Lesson 2's three invariants appear as invariants.** Owner authority: A021.4, A044.1, A047.1,
  P008.1, P011.6. Immutable pushed history: A022.1, P007.8, P013.1. Evidence a squash merge
  destroys: P006.4, P010.3.
- **Compensations cluster in four places:**
  - the checks of the universal sequence (A012.2, A012.4, A016, A017.2–.3);
  - the rail-reading and deletion items (A020.3–.6, A026, A042.1);
  - review and evidence procedure (P011, P012);
  - recovery and test-first (P007, P014).
- **For 37 of the 74 directly classified C and X rows, this search identified no artifact-level
  failure condition.** That bounds the search, not the world (§9). As far as it found, an
  experiment that retired one of them would need a behavioural observation, and the run
  receipts and hook markers that would provide one were refused (**DA-024**, **DA-025**). This
  bears on the open P6 question. It does not answer it.
- **15 C and X rows trace to no ledger row:** A013.3, A014.2, A014.3, P005.1, P007.1, P007.3,
  P007.4, P007.5, P007.7, P008.2, P013.4, P013.5, S002.5, S031.3 and S047.2. P005.1 restates P6
  ("you are the last reviewer"), and the P007 rows restate P7. Those principles are in
  `harness/src/10-principles.md`, not in a row. "Unresolved" means only that no row turned up in
  this search, not that none exists (§3 step 4).
- **The 23 mixed rows are where a retirement would first have to separate wording:** A003.1,
  A011, A014.2, A015.2, A018.4, A020.6, A026.2, A026.9, A042.4, A043.1, A047.3, P004.1, P005.2,
  P006.2, P007.4, P010.1, P011.1, P012.1, P013.4, P014.2, P014.6, S013.2 and S031.3.

## 6. The inventory

Columns:
- **id:** span ids from the extractor, then `.n` for each item split out of a span;
- **type:** H1's legend;
- **class:** I, C, X or "= <id>";
- **invariant, compensation, failure condition:** for an X row, "I:" and "C:" name each part;
- **provenance:** ledger rows, or "provenance unresolved";
- **opens with:** the item's anchor, which the checker finds in the source. A seed placeholder
  is written `{{$NAME}}`, as in H1, because this repository may not hold an unfilled one.

### 6.1 `AGENTS.md`

| id | type | class | invariant, compensation, failure condition | provenance | opens with |
|---|---|---|---|---|---|
| A001 | M |  |  |  | AMH meta-repository — maintenance guide |
| A002 | M |  |  |  | This repository is the source of |
| **A003** | split | | | | This file states the harness and |
| A003.1 | B | X | I: what this file says is what binds. C: keeping superseded wording out, for a reader who takes past wording as live. Fails: superseded wording sits in `AGENTS.md` beside its replacement | **DB-039** | This file states the harness |
| A003.2 | B | I | relocating a live rule repeals it (lesson 3); repeal is legislation | **DB-039** | A rule that still binds stays |
| A003.3 | B | C | fails: a supersession narrative or past version in `AGENTS.md`, or text moved out with no ledger row and changelog pointer (visible in the tree) | **DB-039** | Supersession history, adoption narratives |
| A003.4 | B | I | moving text out is legislation, and a bulk move is the owner's call | **DB-039** | moving anything out of this file takes |
| A004 | M |  |  |  | Sources and generated artifacts |
| A005 | M |  |  |  | `harness/src/*.md` is hand-edited harness prose; `harness/dist/AMH.md` |
| A006 | M |  |  |  | `harness/templates/scripts/` contains the shipped, repository-agnostic scripts; |
| A007 | M |  |  |  | `harness/templates/seed/` contains scaffolds copied once for |
| A008 | M |  |  |  | `harness/templates/configs/` contains adopter configuration templates; `amh.conf` |
| **A009** | split | | | | Code and guard fixtures settle what |
| A009.1 | B | I | code and fixtures settle current behaviour; a committed ledger row is immutable | — | Code and guard fixtures settle |
| A009.2 | B | I | the ` [cited]` marker tracks citations both ways, and the citation rung checks it | — | marker is the one exception |
| A009.3 | B | I | what the harness should do changes only by legislation | — | They do not settle what the harness |
| A010 | M |  |  |  | Universal session sequence |
| A011 | B | X | I: a fresh clone has no pre-push rail until the bootstrap installs one, since hooks are not cloned. C: its banner restates facts a session misjudged (squash history, release state). Fails: a push from a clone with no `.git/hooks/pre-push` | **DC-009**, **DA-003**, **DA-009**, **DA-012** | Run `scripts/session-start.sh` if the host has |
| **A012** | split | | | | Read `docs/STATE.md`, including the Owner queue; |
| A012.1 | B | I | owner decisions and current work persist only in the state file across session death | — | Read `docs/STATE.md`, including the Owner queue |
| A012.2 | B | C | fails: a queue item restated or acted on while its `Check:` output shows it resolved | **DA-011** | verify observable queue claims |
| A012.3 | M |  |  |  | The file is tree-relative by rule |
| A012.4 | B | C | fails: a session repeats or acts on a world claim in the state file that a live probe contradicts | **DD-006** | check such a claim against a live source |
| **A013** | split | | | | Select the relevant procedure under `docs/RUNBOOK.md` |
| A013.1 | B | I | the repository's procedures are owner-made and cannot be inferred; reading them is how they bind (lesson 3) | — | Select the relevant procedure |
| A013.2 | B | I | the playbook's procedure is owner-made, and it binds only if read (lesson 3) | — | and read everything it names |
| A013.3 | B | C | fails: a commit that breaks a step of the playbook its task selects (for a shipped script, the shipped-copy rung goes red) | provenance unresolved | before editing |
| **A014** | split | | | | Work sequentially in a small, shippable |
| A014.1 | B | C | fails: no artifact-level failure condition identified; interleaved commits do not show that two runs overlapped | **D-009**, **DC-012** | Work sequentially |
| A014.2 | B | X | I: a session can die at any moment, so work lands in independently shippable pieces. C: the one-hour size, for an agent that loses the thread on long units. Fails: no artifact-level failure condition identified | provenance unresolved | in a small, shippable unit |
| A014.3 | B | C | fails: no artifact-level failure condition identified (a unit closed on "looks right" leaves no trace) | provenance unresolved | with binary acceptance |
| **A015** | split | | | | Update `docs/STATE.md` with what stays true |
| A015.1 | B | I | working memory outlives the session only in the file; a cached world fact has no invalidation | **DD-006** | Update `docs/STATE.md` with what stays |
| A015.2 | B | X | I: the state file is bounded, and the hard cap is a failing rung. C: reading the compression procedure first, for the micro-trim and splice failures. Fails: the state-size rung fails, or a landing misses its ceilings | **D-027**, **D-034**, **DC-003**, **DB-031** | Over the compression trigger |
| A015.3 | B | I | a lesson not written into the runbook is lost when the session ends | — | Improve the runbook in the same change |
| **A016** | split | | | | With every file change of the |
| A016.1 | B | C | fails: the committed tree differs from the tree the ladder verified, so CI on that commit is red | **DD-027** | With every file change of the unit made |
| A016.2 | B | C | fails: a commit pushed while a rung it ran was red or reported that it checked nothing | **DD-076**, **DA-025** | and review the command's actual output |
| A016.3 | B | I | the tree that was verified is the tree committed | — | The tree the ladder verified is then |
| **A017** | split | | | | Commit with an honest verification disclosure. |
| A017.1 | B | I | the owner cannot see what ran; verification is disclosed, never implied | **D-014** | Commit with an honest verification |
| A017.2 | B | C | fails: a pushed commit carries a poison token, or an author or committer outside the allowed identities | **DD-027**, **DC-040**, **D-033**, **DD-036** | Then run `scripts/ladder.sh --guards-only` |
| A017.3 | B | C | fails: as A017.2, or a WARN that a rung checked nothing is treated as a pass | **DA-025**, **D-032**, **DD-076** | If either fails, fix the commit |
| A017.4 | B | I | publication goes only to the permitted session branch | — | Then push the permitted |
| **A018** | split | | | | The procedures in `docs/PROTOCOLS.md` and the |
| A018.1 | B | I | what makes the protocols and playbooks bind (lesson 3) | — | The procedures in `docs/PROTOCOLS.md` |
| A018.2 | B | I | routes every session to Session discipline, classified item by item in §6.2 | — | Follow **Session discipline** every session |
| A018.3 | B | I | as A013.1 | — | use **Change-type playbooks** for the task |
| A018.4 | B | X | I: legislation changes only through the owner's process. C: the fresh-context pass, for the author's blindness to their own diff. Fails: no artifact-level failure condition identified; a review marker is a self-report (**D-014**) | **D-005**, **D-015** | apply **Rule-review protocol** when the |
| A018.5 | C |  |  |  | `RULE_FILES` is a tripwire |
| A019 | M |  |  |  | Hard boundaries |
| **A020** | split | | | | Never inspect or disclose credential values |
| A020.1 | B | I | a disclosed credential or identifier cannot be withdrawn | — | Never inspect or disclose |
| A020.2 | B | I | as A020.1, for automated checks | — | Automated identity checks may |
| A020.3 | B | C | fails: no artifact-level failure condition identified; a read the guard missed leaves no trace in the repository | **D-016**, **DB-010**, **DC-024** | See `scripts/command-guard.sh` |
| A020.4 | C |  |  |  | That block is the authority |
| A020.5 | B | C | as A020.3 | **DC-024** | do not infer coverage in either direction |
| A020.6 | B | X | I: the credential prohibition binds whatever a guard sees. C: saying so, for an agent that reads a guard's silence as permission. Fails: no artifact-level failure condition identified | **DB-010** | This rule binds you whether |
| A020.7 | B | I | exposure is handled by the owner's incident procedure: rotation first | — | If exposure occurs |
| **A021** | split | | | | Never force-push or push to the |
| A021.1 | B | I | a force-push destroys published history | — | Never force-push |
| A021.2 | B | I | the default branch is the owner's | — | or push to the branch named by |
| A021.3 | B | I | publication policy | — | Push only the configured session branch |
| A021.4 | B | I | merging is the owner's | — | the owner merges |
| **A022** | split | | | | Never rewrite pushed history. The only |
| A022.1 | B | I | pushed history is immutable | — | Never rewrite pushed history |
| A022.2 | B | I | the one exception is owner-directed and owner-executed | — | The only exception is the owner-directed |
| **A023** | split | | | | Never hand-edit generated output, including `harness/dist/AMH.md` |
| A023.1 | B | I | generated output is regenerated from its source; a hand edit is overwritten or drifts | — | Never hand-edit generated output |
| A023.2 | B | I | as A023.1 | — | change its source and run the documented generator |
| **A024** | split | | | | Never patch a local `scripts/` copy |
| A024.1 | B | I | the local copies are byte-identical to the shipped originals | — | Never patch a local |
| A024.2 | B | I | as A024.1 | — | Change the corresponding file under |
| A024.3 | B | I | as A024.1 | — | copy it down byte-for-byte |
| A024.4 | B | I | the manifest records the shipped set | — | and regenerate the manifest |
| **A025** | split | | | | Never rewrite, compress, renumber, or remove |
| A025.1 | B | I | ledger rows are immutable | — | Never rewrite, compress, renumber |
| A025.2 | B | I | identifiers are allocated in the live volume | — | Append the next identifier |
| A025.3 | M |  |  |  | `docs/STATE.md` identifies that volume |
| **A026** | split | | | | Never exercise an unguarded destructive path |
| A026.1 | B | I | no unguarded destructive run against a live target, and no safety check removed to watch what it prevents: both losses are irreversible | **DD-018** | Never exercise an unguarded destructive path |
| A026.2 | B | X | I: deletions are exercised only against a tree made for the test (**DD-018**). C: showing a guard is needed by removing the behaviour and re-running the suite (**D-008**). Fails: a sentinel outside the fixture is gone, or a fixture stays green with its behaviour removed | **DD-018**, **D-008** | Deletions, truncations and resets |
| A026.3 | R |  |  |  | Running the unguarded operation |
| A026.4 | B | C | fails: no artifact-level failure condition identified | **DD-038**, **DD-080** | Before your first bulk deletion of a session |
| A026.5 | B | C | fails: a target the refusal protected is gone or changed after the session (a sentinel) | **DD-038** | A deletion the guard denied |
| A026.6 | B | C | as A026.5 | **DD-038** | Read what the refusal objected to |
| A026.7 | B | C | as A026.5, for an advisory dodged by respelling | **DD-038** | A one-time advisory is different |
| A026.8 | C |  |  |  | A path built from a variable |
| A026.9 | B | X | I: the deletion prohibitions bind whatever a scanner sees. C: saying so, for an agent that reads a scanner's silence as permission. Fails: as A026.5 | **DD-018** | are prose-only and bind you, not a script |
| A027 | B | I | an assertion is not evidence; a gate that consumes one is satisfied either way | **D-014** | Never use self-reported attestations as machine-consumed |
| A028 | M |  |  |  | Progressive disclosure |
| A029 | M |  |  |  | Secret handling and incidents: `docs/PROTOCOLS.md` → |
| A030 | M |  |  |  | Session execution, checkpoints, recovery, and owner |
| A031 | M |  |  |  | Change procedures: `docs/RUNBOOK.md` → **Change-type playbooks**. |
| A032 | M |  |  |  | Binding-rule changes: `docs/PROTOCOLS.md` → **Rule-review protocol**. |
| A033 | M |  |  |  | Verification and locally unverifiable coverage: `docs/PROTOCOLS.md` |
| A034 | M |  |  |  | Compressing working memory: `docs/PROTOCOLS.md` → **Working-memory |
| A035 | M |  |  |  | Current values, branch policy, rule-file scope, |
| **A036** | split | | | | Durable rationale, deviations, and discoveries: `docs/LEDGER.md` |
| A036.1 | M |  |  |  | Durable rationale, deviations |
| A036.2 | B | C | fails: no artifact-level failure condition identified; a whole-volume read costs context and leaves no trace | **DA-022**, **DA-017** | These are **retrieval storage** |
| A037 | M |  |  |  | Current work, owner decisions, historical pointers, |
| A038 | M |  |  |  | Working guidance |
| **A039** | split | | | | Match existing shell style and file |
| A039.1 | B | I | project convention | — | Match existing shell style |
| A039.2 | B | I | the functional invariants the code already carries | — | Preserve functional invariants |
| **A040** | split | | | | Keep document reads query-first and bounded: |
| A040.1 | B | C | fails: no artifact-level failure condition identified | **DA-017** | Keep document reads query-first |
| A040.2 | B | C | fails: no artifact-level failure condition identified (a misreading from an excerpt shows only as the error it causes) | **DA-017** | Widen to adjacent or full content |
| A040.3 | B | I | routes reads to the runbook's retrieval procedure, which binds only if read (lesson 3) | — | follow `docs/RUNBOOK.md` |
| **A041** | split | | | | Keep shipped scripts repository-agnostic. A repository-specific |
| A041.1 | B | I | shipped scripts serve every adopter | **D-002**, **D-003** | Keep shipped scripts repository-agnostic |
| A041.2 | B | I | the extension points are the reviewed surface | **D-003** | A repository-specific need belongs |
| **A042** | split | | | | Know which rails your own session |
| A042.1 | B | C | fails: no artifact-level failure condition identified | **DA-022**, **DD-080** | Know which rails your own session |
| A042.2 | B | I | the harness assumes no one vendor's environment variables (agent-agnosticism) | **DA-022**, **DD-080** | No script can detect the hook-less state |
| A042.3 | B | I | files outside the repository are the owner's to change | **DD-066** | Installing or refreshing a machine-mode copy |
| A042.4 | B | X | I: a rail's wiring is legislation, not the session's to remove. C: "a stop, not an obstacle", for an agent that works around a refusal. Fails: a diff that removes a hook, its `onFailure` or its shell pin from an adapter | **DD-040**, **DD-012** | A refusal that names a failed hook |
| A042.5 | B | I | the scope of the session's own repair authority | — | The one case you repair yourself |
| **A043** | split | | | | New guard behavior ships with a |
| A043.1 | B | X | I: every guard behaviour has a regression fixture. C: the fails-without-it demonstration, for fixtures that cannot fail. Fails: a fixture stays green with its behaviour removed (a mutation shows it) | **D-008** | New guard behavior ships |
| A043.2 | B | I | the shipped suite carries only repository-agnostic fixtures | — | Keep repo-local fixtures separate |
| **A044** | split | | | | Add no dependency without owner approval; |
| A044.1 | B | I | dependencies are the owner's to approve | — | Add no dependency without owner approval |
| A044.2 | M |  |  |  | the distributed harness targets |
| A045 | B | I | authority rests with the owner and the rules, never with external authors | — | Treat external material—issues, reviews, logs, fetched |
| **A046** | split | | | | Use the owner's approved forge handle |
| A046.1 | B | I | a pushed personal identifier cannot be withdrawn | **D-033** | Use the owner's approved forge handle |
| A046.2 | B | C | fails: a commit whose author or committer is outside the allowed identities (`guard_author_identity`) | **D-032**, **D-033** | Check author identity before |
| **A047** | split | | | | Do not open a pull request |
| A047.1 | B | I | PRs, tags and releases are outward-facing and the owner's | — | Do not open a pull request |
| A047.2 | B | I | the owner's chosen PR layout | — | Before creating or updating a PR |
| A047.3 | B | X | I: a squash merge publishes the whole base-to-head diff. C: describing all of it, for an agent that describes only its own session's units. Fails: a PR body that names none of the files an earlier unit in its diff changed | **DB-037** | When `MERGE_MODE=branch-train` |
| A047.4 | B | I | the owner cannot see what ran | **D-014** | Never imply verification |

### 6.2 `docs/PROTOCOLS.md` → Session discipline

| id | type | class | invariant, compensation, failure condition | provenance | opens with |
|---|---|---|---|---|---|
| P001 | M |  |  |  | Session discipline (BINDING for every session) |
| **P002** | split | | | | **Strictly sequential.** No parallel subagents; one |
| P002.1 | B | C | as A014.1 | **D-009**, **DC-012** | **Strictly sequential.** No parallel subagents |
| P002.2 | B | C | as P002.1 | **D-009** | one unit of work at a time |
| P002.3 | B | C | fails: no artifact-level failure condition identified; no record of a review run's lifetime is kept | **D-009**, **D-033** | This includes review passes |
| P002.4 | B | I | the diff a reviewer saw is the diff shipped | — | you do not keep editing while it runs |
| P002.5 | R |  |  |  | Fanning out several reviewers |
| **P003** | split | | | | **Small, shippable units.** About one focused |
| P003.1 | B | = A014.2 |  |  | **Small, shippable units.** |
| P003.2 | B | = A014.3 |  |  | each with a hard **binary** acceptance check |
| **P004** | split | | | | **Checkpoint invariant.** Every unit ends: STATE |
| P004.1 | B | X | I: an interrupted session loses at most the unit in flight. C: the fixed order (changelog line first, ladder, commit, check, push), for an agent that verifies a tree and then edits it. Fails: a unit's commit with no changelog line, or a red CI run on that commit | **DD-027** | **Checkpoint invariant.** Every unit ends |
| P004.2 | R |  |  |  | The changelog line comes FIRST |
| P004.3 | B | = A017.2 |  |  | The check after the commit is |
| P004.4 | B | = A017.3 |  |  | A failure there is fixed by amending |
| P004.5 | B | = A017.3 |  |  | a WARN that either rung checked NOTHING |
| P004.6 | B | I | two uncommitted units die together, and one review cannot see two units | — | Never start a second unit on top |
| P004.7 | B | I | sessions die at any moment | — | Assume the session dies at any moment |
| **P005** | split | | | | **You are the last reviewer.** The |
| P005.1 | B | C | fails: no artifact-level failure condition identified | provenance unresolved | **You are the last reviewer.** |
| P005.2 | B | X | I: the review protocols are the owner's process. C: a fresh context, for the author's blindness. Fails: no artifact-level failure condition identified | **D-005**, **D-015** | The review protocols below are mandatory |
| **P006** | split | | | | **Multi-unit work** persists an owner-approved plan |
| P006.1 | B | I | multi-unit work runs only on an owner-approved plan, persisted outside the session | — | **Multi-unit work** persists an owner-approved plan |
| P006.2 | B | X | I: each segment ends shippable, since a session can die. C: running them sequentially, as A014.1. Fails: as A014.1 | **D-009** | segments run sequentially and each ends shippable |
| P006.3 | B | I | a plan is provisional and leaves the tree when its work is done | — | At the end, move a completed plan |
| P006.4 | B | I | the ledger and the changelog are what survive a squash merge | **DA-003** | Its durable outcomes live in changelog lines |
| P006.5 | B | I | a citation must outlive the file it points at | — | Code cites ledger rows, never plans |
| P006.6 | B | I | an immutable row cannot be repaired after its plan retires | — | **And no ledger row may cite a plan's PATH** |
| P006.7 | R |  |  |  | A plan is provisional context |
| P006.8 | B | I | as P006.6 | — | Record what the plan DELIVERED in the row |
| P006.9 | B | I | a row's immutability covers its text, not its target's lifetime | — | **A legacy citation does NOT pin its plan.** |
| P006.10 | C |  |  |  | `scripts/guards/path-refs.sh` implements that |
| **P007** | split | | | | **Recovery (bounded).** If the unit in |
| P007.1 | B | C | fails: no artifact-level failure condition identified; a final commit does not show a red run before it, or a missing reset | provenance unresolved | **Recovery (bounded).** If the unit in flight |
| P007.2 | B | I | a lesson not recorded is lost when the session dies | — | recording any durable lesson first |
| P007.3 | B | C | fails: no artifact-level failure condition identified (a window spent re-running a gate leaves only a transcript) | provenance unresolved | Recovery is not infinite |
| P007.4 | B | X | I: a unit never ends red, and a blocker persists past session death. C: the stop procedure. Fails: a pushed commit red on CI, or a blocker named only in chat | provenance unresolved | Reset once more to green |
| P007.5 | B | C | fails: no artifact-level failure condition identified | provenance unresolved | A gate that will not go green is either |
| P007.6 | R |  |  |  | Neither is solved by burning |
| P007.7 | B | C | fails: no artifact-level failure condition identified | provenance unresolved | The stop is for a genuinely stuck blocker |
| P007.8 | B | I | as A022.1 | — | Pushed checkpoints are immutable |
| **P008** | split | | | | **Ask, don't assume.** Forks that are |
| P008.1 | B | I | forks of these four kinds are the owner's | — | **Ask, don't assume.** Forks that are |
| P008.2 | B | C | fails: a commit settles an owner-class fork with no owner answer and no queue item | provenance unresolved | Genuinely unsure whether something is a fork? |
| P008.3 | B | I | the boundary of the session's delegated judgement | — | Routine engineering judgement inside |
| P008.4 | B | I | the owner learns what is open from the final message | — | The final chat message restates the Owner queue |
| P008.5 | B | C | fails: a queue item restated while its `Check:` output shows it resolved | **DA-011**, **DB-004** | Run the `Check:` command an item carries |
| P008.6 | B | I | the queue lists only open items | **DA-011** | Resolved means done in this session |
| P008.7 | B | I | an unverified item is labelled unverified, with who settles it named (disclosure) | **DA-011** | An item with no check is restated as |
| P008.8 | B | I | a required field gets filled either way, so it is no evidence | **D-014** | **`Check:` is deliberately NOT a required field** |
| P008.9 | B | I | as A027 | **D-014**, **DA-011** | Nothing enforces this and nothing may |
| **P009** | split | | | | **Verification disclosure.** Every commit body states |
| P009.1 | B | = A017.1 |  |  | **Verification disclosure.** Every commit body states |
| P009.2 | B | I | a commit cannot disclose a check of itself | **D-032** | The post-commit metadata check cannot be disclosed |
| P009.3 | B | = A027 |  |  | Disclosure of real actions, addressed to a human |
| **P010** | split | | | | **Establish coverage before reporting an absence.** |
| P010.1 | B | X | I: an absence claim stands only on a search that could have seen the thing. C: establishing that before reporting, and naming the artifact searched, for an agent that generalises from a local read. Fails: a row or report that claims an absence without naming what was searched (visible to a reader of the artifact) | **DA-003** | **Establish coverage before reporting an absence.** |
| P010.2 | R |  |  |  | The tell is available before the claim |
| P010.3 | B | I | a squash merge destroys a train's intermediate history (lesson 2) | **DA-003** | `MERGE_MODE=branch-train` plus squash-merge |
| P010.4 | R |  |  |  | A pre-execution rail on |
| P010.5 | C |  |  |  | What was accepted instead is a line in the session banner |
| **P011** | split | | | | **A unit owes the review of |
| P011.1 | B | X | I: legislation is reviewed. C: fixing the owed pass from the intent, before the work, for an agent that shrinks the unit to dodge it. Fails: no artifact-level failure condition identified | **DD-050** | **A unit owes the review of what it was set to change |
| P011.2 | B | C | fails: no artifact-level failure condition identified | **DD-050** | A unit framed as evaluating whether to make a change |
| P011.3 | B | C | as P011.2 | **DD-050** | Keep the pass when the unit ends smaller |
| P011.4 | R |  |  |  | "No code changed, so no review" is the shape |
| P011.5 | B | C | as P011.2 | **DD-050** | Concluding "not needed" is an outcome the pass tests |
| P011.6 | B | I | what a unit of an owner-approved plan is set to change is the owner's | **DD-050** | redefining what a unit of an owner-approved plan |
| P011.7 | B | C | as P011.2 | **DD-050** | A unit that stops at a blocker |
| P011.8 | B | I | as A017.1 | **DD-050** | The commit body says what the unit was set to change |
| P011.9 | M |  |  |  | "A unit is what one reviewer saw" counts passes |
| P011.10 | B | I | the ladder verifies what is committed | — | The acceptance ladder still follows the tree |
| P011.11 | C |  |  |  | Prose-only: which pass a unit owes |
| **P012** | split | | | | **A decision says whether its evidence |
| P012.1 | B | X | I: an estimate is never presented as a measurement. C: the labelling procedure. Fails: a retained row or commit message that states a measured number with no command or attribution (visible to a reader) | **DD-050** | **A decision says whether its evidence was measured |
| P012.2 | B | C | fails: a retained row or commit message asserting an outcome in the past tense with no command (visible to a reader) | **DD-050** | A past tense is a measurement claim |
| P012.3 | B | I | what nobody can replay is not a measurement | **DD-050** | A measurement nobody can replay reads as an estimate |
| P012.4 | B | I | a row outlives every session branch | **DD-050** | A ledger row outlives every session branch |
| P012.5 | B | C | fails: no artifact-level failure condition identified | **D-033**, **DA-025** | Where a pass is owed its reviewer replays |
| P012.6 | B | = A027 |  |  | Prose-only, and it must stay so |
| **P013** | split | | | | **A branch that outlives its squash |
| P013.1 | B | I | pushed history is immutable, and force-pushing is a hard boundary | — | **A branch that outlives its squash merge is merged, never rebased.** |
| P013.2 | R |  |  |  | Under `MERGE_MODE=branch-train` the forge |
| P013.3 | R |  |  |  | A rebase would rewrite pushed history |
| P013.4 | B | X | I: the squash merge is recorded without rewriting pushed history. C: this particular procedure (the diff check, then `-s ours` or an ordinary merge), for an agent that would rebase. Fails: the forge reports the branch diverged, or a push needs force | provenance unresolved | Find the branch's last commit the squash carried |
| P013.5 | B | C | fails: the forge reports the session branch diverged from the default branch (`git merge-base --is-ancestor` exits non-zero) | provenance unresolved | Either way a plain push follows |
| **P014** | split | | | | **A fix's fixture is written before |
| P014.1 | B | C | fails: a fix commit whose new fixture passes on the fix's parent commit (a fixture written from the fix) | **DD-073** | **A fix's fixture is written before the fix |
| P014.2 | B | X | I: a reproduction counts only if it fails for the reported reason. C: the order, fix after failure. Fails: as P014.1, or a fixture that fails on the parent commit for an unrelated reason | **DD-073** | It must fail for the reason the report names |
| P014.3 | B | C | as P014.1 | **DD-073** | The fixture committed is the fixture that was seen failing |
| P014.4 | B | I | the branch is never left red | — | The failing fixture is never committed on its own |
| P014.5 | B | I | as A017.1 | **DD-073** | Where a defect cannot be reproduced in a fixture |
| P014.6 | B | X | I: a test encodes what the behaviour should be, and changing one is a decision about that. C: freezing tests for the fix, for an agent that loosens a test to pass it. Fails: a fix commit that modifies or deletes a pre-existing test file | **DD-073** | (b) A fixture that existed before the fix is not the fix's to change. |
| P014.7 | B | C | fails: no artifact-level failure condition identified; no pass record is kept, so a missing pass cannot be told from an unrecorded one | **DD-073** | A fixture changed to make way for a fix is covered |
| P014.8 | B | C | fails: no artifact-level failure condition identified | **DD-073** | That unit owes the rule-review pass |
| P014.9 | B | C | as P014.8 | **DD-073** | The reviewer gets the old fixture |
| P014.10 | B | C | as P014.8 | **D-015** | Where the unit already owes that pass |
| P014.11 | B | I | an added test redefines no existing specification, so it is not a second decision | **DD-073** | Adding a fixture is not covered |
| P014.12 | R |  |  |  | The reason for both |
| P014.13 | C |  |  |  | Prose-only: nothing records the order |
| P014.14 | B | I | as A017.1 | **DD-073** | The commit body says the fixture was seen failing first |

### 6.3 `harness/templates/seed/AGENTS.md`

| id | type | class | invariant, compensation, failure condition | provenance | opens with |
|---|---|---|---|---|---|
| S001 | P |  |  |  | {{$PROJECT_NAME}} — maintenance guide |
| **S002** | split | | | | <!-- |
| S002.1 | M |  |  |  | <!-- SEED TEMPLATE |
| S002.2 | M |  |  |  | Later harness versions will never re-sync it |
| S002.3 | B | I | an unfilled placeholder is not the adopter's rule | — | Instantiate every |
| S002.4 | B | I | the adopter's project defines what applies | — | delete what genuinely does not apply |
| S002.5 | B | C | fails: no artifact-level failure condition identified | provenance unresolved | and read that checkout's |
| S002.6 | R |  |  |  | most pieces earn their keep |
| S003 | P |  |  |  | {{$PROJECT_DESCRIPTION}} |
| S004 | P |  |  |  | {{$REFERENCE_SYSTEM}} |
| **S005** | split | | | | **Ground truth:** code + {{$IMMUTABLE_FIXTURES}}. Docs |
| S005.1 | B | = A009.1 |  |  | **Ground truth:** |
| S005.2 | B | = A009.1 |  |  | The append-only ledger is the exception |
| S005.3 | B | = A009.3 |  |  | And the code settles only what |
| S005.4 | B | = A009.3 |  |  | Changing a binding rule to match |
| **S006** | split | | | | Long-term memory: numbered deviations and discoveries |
| S006.1 | M |  |  |  | Long-term memory: numbered deviations |
| S006.2 | B | I | citation format the citation rung resolves | — | code cites bare |
| S006.3 | B | = A009.2 |  |  | code-cited rows carry a |
| S006.4 | C |  |  |  | nothing syncs it for you |
| S006.5 | B | = A025.1 |  |  | never compress or delete entries |
| S006.6 | B | = A025.2 |  |  | append the next number in |
| S006.7 | M |  |  |  | each file caps at |
| S006.8 | B | I | the volume rollover rule the cap rung enforces | — | the final row may overflow the |
| **S007** | split | | | | **This file states the harness and |
| S007.1 | B | = A003.1 |  |  | **This file states the harness and the project |
| S007.2 | B | = A003.2 |  |  | **A rule that still binds stays |
| S007.3 | B | = A003.3 |  |  | Supersession history, adoption and upgrade |
| S007.4 | R |  |  |  | That is not deletion |
| S007.5 | B | = A003.4 |  |  | Moving anything out of this file |
| S007.6 | R |  |  |  | **No byte cap governs this file |
| S007.7 | C |  |  |  | What stands in for a cap is a reader |
| S007.8 | B | C | fails: no artifact-level failure condition identified; a WARN taken for a gate leaves no trace | **DB-039** | and know exactly what that is worth |
| S007.9 | C |  |  |  | it is a WARN that blocks nothing |
| **S008** | split | | | | **Establish coverage before you report an |
| S008.1 | B | = P010.1 |  |  | **Establish coverage before you report |
| S008.2 | R |  |  |  | The recurring trap is local git state |
| S008.3 | C |  |  |  | Nothing enforces this |
| S009 | M |  |  |  | Maintenance protocol (every session) |
| S010 | P |  |  |  | {{$BOOTSTRAP_STEP}} |
| **S011** | split | | | | Read `docs/STATE.md` — current project state, |
| S011.1 | B | = A012.1 |  |  | Read `docs/STATE.md` — current |
| S011.2 | B | = P008.5 |  |  | **A queue item is a claim |
| S011.3 | B | = A012.4 |  |  | The same caution reaches |
| **S012** | split | | | | Open the matching change-type playbook in |
| S012.1 | B | = A013.1 |  |  | Open the matching change-type playbook |
| S012.2 | B | = A013.2 |  |  | read the reference docs it names |
| S012.3 | B | = A013.3 |  |  | before touching code |
| **S013** | split | | | | Do the work under `docs/PROTOCOLS.md` → |
| S013.1 | B | = A018.2 |  |  | Do the work under `docs/PROTOCOLS.md` |
| S013.2 | B | X | I: work lands in checkpointed, independently shippable units, since a session can die. C: sequential and small, for an agent that fans out or loses the thread. Fails: no artifact-level failure condition identified | **D-009** | sequential, small checkpointed units |
| S013.3 | B | = A014.3 |  |  | binary acceptance. |
| S013.4 | B | I | routes every session to the protocols file, whatever playbook the task took (lesson 3) | — | That file holds the procedures |
| **S014** | split | | | | Update `docs/STATE.md` with what stays true |
| S014.1 | B | = A015.1 |  |  | Update `docs/STATE.md` with what stays |
| S014.2 | B | = A015.1 |  |  | Never cache world-controlled status |
| S014.3 | B | = A015.3 |  |  | If the runbook itself was insufficient |
| **S015** | split | | | | With every file change made — |
| S015.1 | B | = A016.1 |  |  | With every file change made |
| S015.2 | B | = A016.3 |  |  | so the tree it verified is the tree you commit |
| S015.3 | B | = P014.4 |  |  | **Never leave the branch red.** |
| **S016** | split | | | | Commit, then run `scripts/ladder.sh --guards-only` once |
| S016.1 | B | = A017.2 |  |  | Commit, then run |
| S016.2 | B | = A017.3 |  |  | If either fails |
| S016.3 | B | = A017.4 |  |  | Then push: |
| S017 | M |  |  |  | Build & verify commands |
| **S018** | split | | | | ```bash |
| S018.1 | M |  |  |  | ```bash |
| S018.2 | P |  |  |  | {{$INDIVIDUAL_TEST_BUILD_LINT_COMMANDS}} |
| **S019** | split | | | | {{$VERIFICATION_LIMITS}} Every commit body states what |
| S019.1 | P |  |  |  | {{$VERIFICATION_LIMITS}} |
| S019.2 | B | = A017.1 |  |  | Every commit body states |
| S020 | M |  |  |  | Architecture |
| S021 | P |  |  |  | {{$MODULE_MAP}} |
| S022 | M |  |  |  | Coding conventions |
| S023 | P |  |  |  | {{$SEMANTIC_FIDELITY_RULE}} |
| S024 | B | I | traceability of ported logic to its source | — | Provenance comments on ported or spec-derived |
| S025 | P |  |  |  | {{$FIXTURE_IMMUTABILITY_RULE}} |
| **S026** | split | | | | **A fix's test comes first, and |
| S026.1 | B | = P014.1 |  |  | **A fix's test comes first |
| S026.2 | B | = Q013.6 |  |  | A test that existed before the fix |
| S026.3 | B | I | the adopter's fixture rule outranks this one | — | The fixture rule above may forbid |
| S026.4 | C |  |  |  | Prose-only: no guard checks |
| S027 | B | I | the adopter's dependency policy | — | No new dependencies unless the change |
| S028 | P |  |  |  | {{$TOOLCHAIN_FLOOR}} |
| S029 | B | = A039.1 |  |  | Match existing code style and file/package |
| S030 | M |  |  |  | Invariants that still bind (full catalog: |
| **S031** | split | | | | The catalog is **retrieval storage**: grep |
| S031.1 | B | = A036.2 |  |  | The catalog is **retrieval storage** |
| S031.2 | B | = A036.2 |  |  | Never read a ledger volume whole |
| S031.3 | B | X | I: the shortlisted invariants bind every session. C: carrying them in context rather than retrieving them, for a session that would not look. Fails: no artifact-level failure condition identified | provenance unresolved | and the shortlist below is what a session |
| S032 | P |  |  |  | {{$INVARIANT_SHORTLIST}} |
| S033 | M |  |  |  | Secret hygiene |
| **S034** | split | | | | The session environment carries credentials even |
| S034.1 | M |  |  |  | The session environment carries credentials |
| S034.2 | B | = A020.1 |  |  | Never dump environments |
| S034.3 | B | = A020.1 |  |  | Never print a credential's value |
| S034.4 | B | = A020.1 |  |  | report key presence only |
| **S035** | split | | | | **Which layer holds which half.** `scripts/command-guard.sh` |
| S035.1 | C |  |  |  | **Which layer holds which half.** |
| S035.2 | C |  |  |  | That enumeration is a **list, not a category** |
| S035.3 | B | = A020.3 |  |  | Its header carries the consolidated |
| S035.4 | B | = A020.6 |  |  | The bullet above binds you |
| S035.5 | C |  |  |  | The deny rails add the spellings |
| S035.6 | B | = A020.6 |  |  | Anything else in this section |
| S035.7 | B | I | an enforcement claim is a claim the next reader relies on, so a false one is never written | — | Say which layer holds a rule |
| **S036** | split | | | | **The owner's personal identifiers are secrets |
| S036.1 | B | = A046.1 |  |  | **The owner's personal identifiers are secrets too** |
| S036.2 | B | = A046.2 |  |  | **No PRE-COMMIT guard can see this** |
| S036.3 | C |  |  |  | Once it is committed the ladder's |
| S036.4 | C |  |  |  | **It cannot tell a personal address |
| S036.5 | B | = A017.3 |  |  | Fix what it finds before you push |
| S037 | B | I | raw secret material is never output; a narrower evidence contract is the owner's | — | A diagnostic that seems to need |
| **S038** | split | | | | A **leaked** secret (commit, push, log): |
| S038.1 | B | = A020.7 |  |  | A **leaked** secret (commit, push, log): stop |
| S038.2 | B | = A020.1 |  |  | never repeat the value |
| S038.3 | B | = A020.7 |  |  | Owner queue immediately |
| S038.4 | B | = A020.7 |  |  | the owner rotates FIRST |
| S038.5 | B | = A022.2 |  |  | (owner-executed, never by an agent) |
| S039 | M |  |  |  | Destructive work |
| **S040** | split | | | | **Exercise an unguarded destructive path against |
| S040.1 | B | = A026.1 |  |  | **Exercise an unguarded destructive path |
| S040.2 | B | = A026.2 |  |  | This covers the demonstration |
| S040.3 | B | I | the rule binds where the demonstration is performed | — | If your `docs/RUNBOOK.md` has a guard-adding |
| **S041** | split | | | | **Never remove a safety check from |
| S041.1 | B | = A026.1 |  |  | **Never remove a safety check |
| S041.2 | R |  |  |  | Writing a guard and then deleting it |
| S041.3 | B | = A026.2 |  |  | When a guard's necessity is in question |
| **S042** | split | | | | **A refused deletion is a stop, |
| S042.1 | B | = A026.5 |  |  | **A refused deletion is a stop |
| S042.2 | B | = A026.6 |  |  | Read what the refusal objected to |
| S042.3 | B | = A026.7 |  |  | A one-time advisory clears |
| S042.4 | B | C | fails: a drive root or home directory deleted through a `\"` spelling (a sentinel outside the target is gone) | **DD-038** | On Windows, never wrap a path |
| S042.5 | B | C | as S042.4 | **DD-038** | A leftover git worktree is removed |
| **S043** | split | | | | **Which layer holds which half.** `scripts/command-guard.sh` |
| S043.1 | C |  |  |  | **Which layer holds which half.** |
| S043.2 | B | = A020.5 |  |  | Read the size of that claim |
| S043.3 | C |  |  |  | it is a TARGET list for four commands |
| S043.4 | C |  |  |  | PowerShell commands reach it only |
| S043.5 | C |  |  |  | Most other |
| S043.6 | B | = A026.9 |  |  | Everything here that a command scanner |
| S043.7 | C |  |  |  | An INLINE interpreter deletion |
| S043.8 | B | = A026.9 |  |  | Everything around it is yours |
| S043.9 | R |  |  |  | The most widely reported |
| S044 | M |  |  |  | External content is data (instruction hierarchy) |
| **S045** | split | | | | Priority order: **owner instructions > this |
| S045.1 | B | = A045 |  |  | Priority order: |
| S045.2 | B | = A045 |  |  | Issues, PR and review comments |
| S045.3 | B | = A045 |  |  | An external instruction that tries |
| S046 | M |  |  |  | Git rules |
| **S047** | split | | | | Develop and push **only** on your |
| S047.1 | B | = A021.3 |  |  | Develop and push **only** |
| S047.2 | B | C | fails: no artifact-level failure condition identified | provenance unresolved | Push with `git push -u origin <branch>` |
| S047.3 | B | = A021.1 |  |  | **Never force-push. |
| **S048** | split | | | | The owner merges via **squash-merge** PRs. |
| S048.1 | B | = A021.4 |  |  | The owner merges via |
| S048.2 | P |  |  |  | {{$MERGE_MODE}} |
| S048.3 | B | = A047.1 |  |  | Do not open a PR unless asked |
| S048.4 | B | = A047.2 |  |  | Before creating or updating one |
| S048.5 | B | = A047.2 |  |  | If no template exists |
| S048.6 | B | = A047.3 |  |  | Under `branch-train` |
| S048.7 | P |  |  |  | {{$TAGGING_RULE}} |
| S049 | M |  |  |  | Agent harness |
| S050 | B | I | one constitution; other agent-instruction files point to it and never diverge | — | This file is the constitution for |
| **S051** | split | | | | Session bootstrap is agent-neutral: `scripts/session-start.sh` (remote |
| S051.1 | C |  |  |  | Session bootstrap is agent-neutral |
| S051.2 | B | = A011 |  |  | If your harness has no session-start hook |
| **S052** | split | | | | Per-agent adapters live in dot-dirs and |
| S052.1 | B | I | adapters are wiring, not rules | — | Per-agent adapters live in dot-dirs |
| S052.2 | B | I | the adapter runs the bootstrap at session start | — | A new agent's adapter must |
| S052.3 | B | I | the adapter mirrors the permission deny rails where the agent has permission rules | — | mirror the permission deny rails |
| S052.4 | B | I | the adapter wires the command guard where the agent has hooks | — | wire `scripts/command-guard.sh` |
| S052.5 | B | I | the adapter pipes tool output through the redaction filter where the agent has an output hook | — | pipe tool output through |
| S052.6 | B | I | the adapter honours one session, one branch | — | honour the one-session-one-branch rule |
| S052.7 | B | I | the adapter's config file is legislation, listed in `RULE_FILES` | — | and add its config file |
| S052.8 | B | = S035.7 |  |  | State explicitly which of those layers |
| **S053** | split | | | | **An agent with no pre-execution hook |
| S053.1 | C |  |  |  | **An agent with no pre-execution hook |
| S053.2 | C |  |  |  | The git-native `pre-push` rail |
| S053.3 | C |  |  |  | Where it is installed |
| S053.4 | C |  |  |  | It is a guardrail `--no-verify` bypasses |
| S053.5 | B | = A042.2 |  |  | No check can tell you |
| S053.6 | C |  |  |  | A machine-mode copy of the guard |
| S053.7 | B | = A042.3 |  |  | Installing or refreshing one changes |
| **S054** | split | | | | **A hook that fails refuses the |
| S054.1 | C |  |  |  | **A hook that fails refuses the call |
| S054.2 | C |  |  |  | Under such an adapter on Windows |
| S054.3 | B | = A042.4 |  |  | A refusal that names a failed hook |

### 6.4 `harness/templates/seed/docs/PROTOCOLS.md` → Session discipline

| id | type | class | invariant, compensation, failure condition | provenance | opens with |
|---|---|---|---|---|---|
| Q001 | M |  |  |  | Session discipline (BINDING for every session) |
| **Q002** | split | | | | **Strictly sequential.** No parallel subagents; one |
| Q002.1 | B | = P002.1 |  |  | **Strictly sequential.** No parallel subagents |
| Q002.2 | B | = P002.2 |  |  | one unit of work at a time |
| Q002.3 | R |  |  |  | Parallel agents on one repo |
| **Q003** | split | | | | **Small, shippable units.** About one focused |
| Q003.1 | B | = A014.2 |  |  | **Small, shippable units.** |
| Q003.2 | B | = A014.3 |  |  | each with a hard **binary** acceptance check |
| **Q004** | split | | | | **Checkpoint invariant.** Every unit ends: STATE |
| Q004.1 | B | = P004.1 |  |  | **Checkpoint invariant.** Every unit ends |
| Q004.2 | R |  |  |  | The changelog line comes FIRST |
| Q004.3 | B | = A017.2 |  |  | The check after the commit is |
| Q004.4 | B | = A017.3 |  |  | A failure there is fixed by amending |
| Q004.5 | B | = A017.3 |  |  | a WARN that either rung checked NOTHING |
| Q004.6 | B | = P004.6 |  |  | Never start a second unit on top |
| Q004.7 | B | = P004.7 |  |  | Assume the session dies at any moment |
| **Q005** | split | | | | **You are the last reviewer.** The |
| Q005.1 | B | = P005.1 |  |  | **You are the last reviewer.** |
| Q005.2 | B | = P005.2 |  |  | The review protocols below are mandatory |
| **Q006** | split | | | | **Multi-unit work** persists an owner-approved plan |
| Q006.1 | B | = P006.1 |  |  | **Multi-unit work** persists an owner-approved plan |
| Q006.2 | B | = P006.2 |  |  | segments run sequentially and each ends shippable |
| Q006.3 | B | = P006.3 |  |  | At the end, move a completed plan |
| Q006.4 | B | = P006.4 |  |  | Its durable outcomes live in changelog lines |
| Q006.5 | B | = P006.5 |  |  | Code cites ledger rows, never plans |
| Q006.6 | B | = P006.6 |  |  | **And no ledger row may cite a plan's PATH** |
| Q006.7 | R |  |  |  | A plan is provisional context |
| Q006.8 | B | = P006.8 |  |  | Record what the plan DELIVERED in the row |
| Q006.9 | B | = P006.9 |  |  | **A legacy citation does NOT pin its plan.** |
| Q006.10 | B | = P006.9 |  |  | A path guard here must let it |
| **Q007** | split | | | | **Recovery (bounded).** If the unit in |
| Q007.1 | B | = P007.1 |  |  | **Recovery (bounded).** If the unit in flight |
| Q007.2 | B | = P007.2 |  |  | recording any durable lesson first |
| Q007.3 | B | = P007.3 |  |  | Recovery is not infinite |
| Q007.4 | B | = P007.4 |  |  | Reset once more to green |
| Q007.5 | B | = P007.5 |  |  | A gate that will not go green is either |
| Q007.6 | R |  |  |  | Neither is solved by burning |
| Q007.7 | B | = P007.7 |  |  | The stop is for a genuinely stuck blocker |
| Q007.8 | B | = A022.1 |  |  | Pushed checkpoints are immutable |
| **Q008** | split | | | | **Ask, don't assume.** Forks that are |
| Q008.1 | B | = P008.1 |  |  | **Ask, don't assume.** Forks that are |
| Q008.2 | B | = P008.2 |  |  | Genuinely unsure whether something is a fork? |
| Q008.3 | B | = P008.3 |  |  | Routine engineering judgement inside |
| Q008.4 | B | = P008.4 |  |  | The final chat message restates the Owner queue |
| Q008.5 | B | = P008.5 |  |  | Run the `Check:` command an item carries |
| Q008.6 | B | = P008.6 |  |  | Resolved means done in this session |
| Q008.7 | B | = P008.7 |  |  | An item with no check is restated as |
| Q008.8 | B | = P008.8 |  |  | **`Check:` is deliberately not a required field** |
| Q008.9 | B | = A027 |  |  | Nothing enforces this and nothing may |
| **Q009** | split | | | | **Verification disclosure.** Every commit body states |
| Q009.1 | B | = A017.1 |  |  | **Verification disclosure.** Every commit body states |
| Q009.2 | B | = A027 |  |  | Disclosure of real actions, addressed to a human |
| Q009.3 | B | = P009.2 |  |  | The post-commit metadata check cannot be disclosed |
| **Q010** | split | | | | **Establish coverage before reporting an absence.** |
| Q010.1 | B | = P010.1 |  |  | **Establish coverage before reporting an absence.** |
| Q010.2 | R |  |  |  | A local artifact was read and the answer reported |
| Q010.3 | B | = P010.3 |  |  | The standing trap is git |
| Q010.4 | B | I | no pre-execution rail can see a belief formed after a command returns, so none may claim to | — | This is prose-only and must stay so |
| **Q011** | split | | | | **A unit owes the review of |
| Q011.1 | B | = P011.1 |  |  | **A unit owes the review of what it was set to change |
| Q011.2 | B | = P011.2 |  |  | A unit framed as evaluating whether to make a change |
| Q011.3 | B | = P011.3 |  |  | Keep the pass when the unit ends smaller |
| Q011.4 | R |  |  |  | "No code changed, so no review" is the shape |
| Q011.5 | B | = P011.5 |  |  | Concluding "not needed" is an outcome the pass tests |
| Q011.6 | B | = P011.6 |  |  | redefining what a unit of an owner-approved plan |
| Q011.7 | B | = P011.7 |  |  | A unit that stops at a blocker |
| Q011.8 | B | = P011.8 |  |  | The commit body says what the unit was set to change |
| Q011.9 | M |  |  |  | "A unit is what one reviewer saw" counts passes |
| Q011.10 | B | = P011.10 |  |  | The acceptance ladder still follows the tree |
| Q011.11 | C |  |  |  | Prose-only: which pass a unit owes |
| **Q012** | split | | | | **A decision says whether its evidence |
| Q012.1 | B | = P012.1 |  |  | **A decision says whether its evidence was measured |
| Q012.2 | B | = P012.2 |  |  | A past tense is a measurement claim |
| Q012.3 | B | = P012.3 |  |  | A measurement nobody can replay reads as an estimate |
| Q012.4 | B | = P012.4 |  |  | A ledger row outlives every session branch |
| Q012.5 | B | = P012.5 |  |  | Where a pass is owed its reviewer replays |
| Q012.6 | B | = A027 |  |  | Prose-only, and it must stay so |
| **Q013** | split | | | | **A fix's test is written before |
| Q013.1 | B | C | the seed's scope is every defect, not only those a named suite covers. Fails: a fix commit whose new test passes on the fix's parent commit | **DD-073** | **A fix's test is written before the fix |
| Q013.2 | B | = P014.2 |  |  | It must fail for the reason the report names |
| Q013.3 | B | = P014.3 |  |  | The test committed is the test that was seen failing |
| Q013.4 | B | = P014.4 |  |  | The failing test is never committed on its own |
| Q013.5 | B | = P014.5 |  |  | Where a defect cannot be reproduced in a test |
| Q013.6 | B | = P014.6 |  |  | (b) A test that existed before the fix is not the fix's to change. |
| Q013.7 | B | = P014.7 |  |  | A test changed to make way for a fix is covered |
| Q013.8 | B | C | the seed names a modified adversarial pass, at the strongest tier, with no self-review fallback. Fails: no artifact-level failure condition identified; no pass record is kept | **DD-073** | That unit owes a fresh-context pass |
| Q013.9 | B | I | with no fresh pass available the test stays as it was, and the question is the owner's | **DD-073** | Where no fresh context can be spawned |
| Q013.10 | B | = P014.9 |  |  | The reviewer gets the old test |
| Q013.11 | B | I | what the behaviour should be, where no specification settles it, is the owner's | — | Where no specification settles what the behaviour should be |
| Q013.12 | B | = P014.10 |  |  | Where the unit already owes a pass |
| Q013.13 | B | = P014.11 |  |  | Adding a test is not covered |
| Q013.14 | R |  |  |  | The reason for both |
| Q013.15 | C |  |  |  | Prose-only: nothing records the order |
| Q013.16 | B | = P014.14 |  |  | The commit body says the test was seen failing first |

## 7. Replay

Save the two blocks below to files in a scratch directory outside the repository, then run these
from the repository root. `<scratch>` is that directory:

```bash
git show c0d0b74:AGENTS.md > <scratch>/A.md
git show c0d0b74:harness/templates/seed/AGENTS.md > <scratch>/S.md
git show c0d0b74:docs/PROTOCOLS.md | sed -n '/^## Session discipline/,/^## Adversarial/p' | sed '$d' > <scratch>/P.md
git show c0d0b74:harness/templates/seed/docs/PROTOCOLS.md | sed -n '/^## Session discipline/,/^## Adversarial/p' | sed '$d' > <scratch>/Q.md
for x in A S P Q; do awk -v tag=$x -f <scratch>/h1-spans.awk <scratch>/$x.md > <scratch>/$x.tsv; done
python3 -I <scratch>/h5-check.py docs/plans/2026-11-01-harness-research-gaps-h5-classification.md docs \
  A:<scratch>/A.md:<scratch>/A.tsv P:<scratch>/P.md:<scratch>/P.tsv \
  S:<scratch>/S.md:<scratch>/S.tsv Q:<scratch>/Q.md:<scratch>/Q.tsv
```

The checker reads the classification from §6 of this file, so the next replay checks any edit to
a table. Its second argument is the ledger directory, read at whatever revision is checked out;
the ledger is append-only, so a later checkout resolves every id this one did. The awk extractor
is H1's, unchanged, and counts bytes under `mawk`.

**The checker was made to fail before it was trusted.** Each case ran against a scratch copy of
§6 with one change, and each exited 1 naming the change:
- a B row's class cell emptied — `unresolved ['A012.2']`;
- a cited id changed to one no volume holds — `dangling ['DA-999']`;
- an anchor changed to words the source lacks — `A012.2 anchor occurs 0 times`;
- a seed row pointed at an M row — `unresolved ['S013.2']`;
- a C row's provenance replaced by other words — `missing or malformed field ['P007.1']`.

One first attempt at the anchor case changed "claims" to "claim". That stayed green, correctly,
because the shorter anchor still occurs exactly once in its span. It was redone with a word the
source lacks.

The review (§8) found two more faults that the first version of the checker accepted with exit
0. The checker now refuses both, and each case exits 1:
- a child given its sibling's anchor, so that two children start at one offset —
  `A012 anchors out of order or sharing an offset`;
- an invented child row with no split parent — `A999.1 has no split parent span`.

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

### `h5-check.py`

```python
"""H5 check: coverage and citation resolution for the obligation classification. Never a verdict
on whether a classification is right; that is a reader's work.

usage: python3 -I h5-check.py <h5.md> <ledger-dir> X:<source.md>:<spans.tsv> ...
X is the table's id prefix (A, P, S, Q). <spans.tsv> is h1-spans.awk's output for <source.md>.

Checks, each printed with its count; exit 1 on any failure:
  1. reconciliation, per source: every nonblank line lies in exactly one span; the table's
     parent ids are the extractor's span ids; each child's anchor occurs exactly once in its
     parent's normalised text, the first child starts the span, and anchors run in order;
  2. classification coverage: every B row carries I, C, X or "= <id>"; every "= <id>" resolves,
     through any chain, to a B row carrying I, C or X; no row of another type carries a class;
  3. compensation fields: every C and X row has a non-empty note and provenance cell, and its
     provenance is ledger ids or the words "provenance unresolved";
  4. citation resolution: every bold ledger id in any note or provenance cell is a row in a
     volume under <ledger-dir>.
Then it prints the totals by source and by effective class.
"""
import glob
import re
import sys

doc_path, ledger_dir = sys.argv[1:3]
sources = [a.split(":", 2) for a in sys.argv[3:]]
ID = r"[A-Z][0-9]{3}(?:\.[0-9]+)?"

rows = {}
order = {}
for line in open(doc_path, encoding="utf-8"):
    cells = [c.strip() for c in line.strip().strip("|").split("|")]
    if len(cells) != 6:
        continue
    rid = cells[0].strip("*")
    if not re.fullmatch(ID, rid):
        continue
    if rid in rows:
        print(f"  duplicated row {rid}")
        sys.exit(1)
    rows[rid] = {"type": cells[1], "class": cells[2], "note": cells[3], "prov": cells[4],
                 "anchor": cells[5].replace("{{$", "{{")}
    order.setdefault(rid[0], []).append(rid)

fail = 0
for prefix, src_path, spans_path in sources:
    src = open(src_path, encoding="utf-8").read().split("\n")
    if src and src[-1] == "":
        src.pop()
    spans = {}
    for line in open(spans_path, encoding="utf-8", errors="replace"):
        f = line.rstrip("\n").split("\t")
        spans[f[0]] = (int(f[1]), int(f[2]))
    owner, overlap = {}, []
    for sid, (a, b) in spans.items():
        for n in range(a, b + 1):
            if n in owner:
                overlap.append(n)
            owner[n] = sid
    uncovered = [i + 1 for i, t in enumerate(src) if t.strip() and i + 1 not in owner]
    ids = order.get(prefix, [])
    parents = [r for r in ids if "." not in r]
    missing = sorted(set(spans) - set(parents))
    extra = sorted(set(parents) - set(spans))

    def norm(a, b):
        out = []
        for i, t in enumerate(src[a - 1:b]):
            t = re.sub(r"^>\s?", "", t).strip()
            if i == 0:
                t = re.sub(r"^(- |\* |[0-9]+\. )", "", t)
            out.append(t)
        return " ".join(x for x in out if x)

    bad = []
    nsplit = nchild = 0
    for pid in parents:
        if rows[pid]["type"] != "split":
            continue
        nsplit += 1
        text = norm(*spans[pid])
        kids = [k for k in ids if k.startswith(pid + ".")]
        offs = []
        for k in kids:
            nchild += 1
            cnt = text.count(rows[k]["anchor"])
            offs.append(text.index(rows[k]["anchor"]) if cnt == 1 else None)
            if cnt != 1:
                bad.append(f"{k} anchor occurs {cnt} times")
        if not kids:
            bad.append(f"{pid} split with no children")
        elif offs[0] != 0:
            bad.append(f"{pid} first child does not start the span")
        good = [o for o in offs if o is not None]
        if any(b <= a for a, b in zip(good, good[1:])):
            bad.append(f"{pid} anchors out of order or sharing an offset")
    for k in ids:
        if "." in k and (k.split(".")[0] not in spans or rows[k.split(".")[0]]["type"] != "split"):
            bad.append(f"{k} has no split parent span")
    print(f"{prefix}: {len(src)} lines, uncovered {uncovered[:5]}, overlapping {overlap[:5]}; "
          f"{len(spans)} spans, unclassified {missing}, unknown {extra}; "
          f"{nsplit} split into {nchild}; anchor faults {bad}")
    fail |= bool(uncovered or overlap or missing or extra or bad)


def effective(rid, seen=()):
    c = rows[rid]["class"]
    if c in ("I", "C", "X"):
        return c
    m = re.fullmatch(r"= (" + ID + ")", c)
    if not m or m.group(1) not in rows or rows[m.group(1)]["type"] != "B" or m.group(1) in seen:
        return None
    return effective(m.group(1), seen + (rid,))


unclassified, stray, fields, eff = [], [], [], {}
for rid, r in rows.items():
    if r["type"] == "B":
        e = effective(rid)
        if e is None:
            unclassified.append(rid)
        eff[rid] = e
        if r["class"] in ("C", "X"):
            prov_ok = r["prov"] == "provenance unresolved" or re.fullmatch(
                r"\*\*D[A-D]?-[0-9]{3}\*\*(, \*\*D[A-D]?-[0-9]{3}\*\*)*", r["prov"])
            if not r["note"] or not prov_ok:
                fields.append(rid)
    elif r["class"] and r["type"] != "split":
        stray.append(rid)
print(f"classification: {len(eff)} B rows; unresolved {unclassified}; class on a non-B row {stray}; "
      f"C/X rows with a missing or malformed field {fields}")
fail |= bool(unclassified or stray or fields)

ledger = set()
for vol in glob.glob(ledger_dir.rstrip("/") + "/LEDGER*.md"):
    for line in open(vol, encoding="utf-8"):
        m = re.match(r"- (D[A-D]?-[0-9]{3})\b", line)
        if m:
            ledger.add(m.group(1))
cited = {c for r in rows.values() for c in re.findall(r"\*\*(D[A-D]?-[0-9]{3})\*\*", r["note"] + r["prov"])}
dangling = sorted(cited - ledger)
print(f"citations: {len(cited)} distinct ledger ids cited, {len(ledger)} rows in the ledger; dangling {dangling}")
fail |= bool(dangling)

def noart(rid, depth=0):
    # a note reading "as <id>" takes that row's failure condition
    note = rows[rid]["note"]
    if "no artifact-level failure condition identified" in note:
        return True
    m = re.match(r"as (" + ID + r")\b", note)
    return bool(m and m.group(1) in rows and depth < 5 and noart(m.group(1), depth + 1))


grand = {k: 0 for k in ("B", "I", "C", "X", "ref", "unres", "noart")}
for prefix, _, _ in sources:
    b = [r for r in order.get(prefix, []) if rows[r]["type"] == "B"]
    ref = [r for r in b if rows[r]["class"].startswith("=")]
    counts = {k: sum(1 for r in b if rows[r]["class"] == k) for k in "ICX"}
    cx = [r for r in b if rows[r]["class"] in ("C", "X")]
    unres = sum(1 for r in cx if rows[r]["prov"] == "provenance unresolved")
    na = sum(1 for r in cx if noart(r))
    print(f"totals {prefix}: {len(b)} B; classified here I {counts['I']}, C {counts['C']}, X {counts['X']}; "
          f"by reference {len(ref)}; of the C and X rows, provenance unresolved {unres}, "
          f"no artifact-level failure condition {na}")
    for k, v in (("B", len(b)), ("ref", len(ref)), ("unres", unres), ("noart", na), *counts.items()):
        grand[k] += v
print("totals all: " + ", ".join(f"{k} {v}" for k, v in grand.items()))
print("totals effective (references resolved): " +
      ", ".join(f"{k} {sum(1 for e in eff.values() if e == k)}" for k in "ICX"))
sys.exit(1 if fail else 0)
```

## 8. Review

The owed pass was one gpt-6-astra review at high effort, the owner's choice. It ran read-only
over the uncommitted unit. It replayed the checker and confirmed every total. It replayed the
five failing cases, and it read in full the 40 ledger rows then cited. Its verdict was
**FAIL**, on nine findings. Each was re-read against the source and applied; none was
re-reviewed, because a unit gets one pass (`docs/PROTOCOLS.md` → **Rule-review protocol**).

1. **Binding obligations had been excluded as rationale or map items.** Retyped B and classified:
   - A042.2, and its seed form S053.5, which forbids assuming a vendor's environment variables.
     **DD-080** had recorded the same sentence carrying that prohibition.
   - A040.3 and S013.4, which route reads to a binding procedure.
   - S048.1: the owner merges.
   - P014.11 and Q013.13: an added test is not a second decision.
2. **Classes against the §2 test.**
   - A013's read is now split from its timing.
   - P010.1, P014.2 and P013.4 became mixed.
   - P008.7 and Q013.9 became invariants.
   - A026.1 is now wholly invariant. A026.2 became mixed, separating the disposable-target
     restriction (**DD-018**) from the mutation demonstration (**D-008**).
3. **References and bundles.**
   - S013.2, Q013.1 and Q013.8 are classified on their own, because the seed's wording differs in
     substance.
   - A003.3 was split, so S007.3 and S007.5 each point at the half they state.
   - P006.2 became mixed.
   - S052.2's six adapter obligations were split.
4. **The checker** accepted a duplicated anchor and an orphan child row. Both are now refused
   (§7).
5. **Failure conditions.**
   - A003.3, P010.1, P012.1 and P012.2 name a failure a reader can see in the artifact.
   - A014.1, P002.1, P002.3, P007.1 and P014.7 no longer claim one. Interleaved commits, a final
     commit or a missing pass record do not show the failure.
6. **The summary** had turned "not identified" into "cannot exist". §5, the plan's Result and
   the ledger row now keep the search bound.
7. **Provenance.**
   - **DD-027** records the checkpoint-order failure and the corrected sequence. It now backs
     A016.1, P004.1 and A017.2.
   - P008.7 cites **DA-011**, not **D-014**.
8. **"147 seed rows" was wrong.** Eight of those references are rows of the reference Session
   discipline. The counts now say so.
9. **The ledger row** carried counts without the command that produced them, which Session
   discipline 11 requires. It now names the command.

The pass sampled rows for each check rather than reading every judgement. A classification it
did not sample has one reader behind it.

## 9. Not verified

- **Whether any class is right.** The classification is one reader's judgement, with the one
  review pass in §8 behind it. The checker cannot see a wrong class.
- **That an unresolved provenance has no row.** One search of the ledger volumes by a smaller
  model, plus the session's own targeted searches, found none. Rows were read back by headline,
  not in full. `docs/history/` was not searched.
- **That an absent artifact-level failure condition is truly absent.** It means only that this
  reader found none in the repository, its history, the forge or the filesystem.
- **The seed rows by reference.** "Same obligation" was judged by reading both texts. Where the
  seed's wording is broader or narrower, a reader may split it differently.
