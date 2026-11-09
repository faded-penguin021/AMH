# PLAN — close the gaps a harness-engineering survey found in AMH

> **Status: rev 2, committed 2026-11-01 as an open draft; adopted by the owner on 2026-11-09, with
> an added unit, H0.5, to run first. §1 says which decisions are answered.** No unit starts without
> the owner's explicit approval of that unit; adopting the plan approves no unit. When the owner
> says to start a unit, the session first tells the owner which decisions that unit needs, if any,
> and does not start it until they are answered.
> Rev 2 folds in an external review of rev 1 (verdict REVISE_PLAN, nine findings). Each finding
> was re-checked against this tree before it was accepted (§7).
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
   possibly MAJOR.
3. **H2: which constitution content stays loaded every session.** `AGENTS.md` makes relocating a
   live rule a change to legislation, and makes a bulk relocation the owner's decision.
4. **H3: the adopter file layout** (§5, H3).
5. **H4a: the platform matrix, and above all what native Windows gets.** Per Claude Code's
   sandboxing documentation (§8), native Windows runs commands unsandboxed, and **DD-038**
   happened on native Windows PowerShell 5.1. The options are in §5, H4a. Also for H4a: whether
   the sandbox is on by default or opt-in for adopters, and whether any host dependency it needs
   (such as the optional seccomp filter on Linux and WSL2) is approved ("Add no dependency
   without owner approval").
6. **H5: whether P6 admits retiring a capability compensation at all.**
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

## 2. What was measured

All measurements were taken on 2026-11-01 on this checkout at `ba1f40a`, unless the line says
otherwise. Byte counts measure text volume. They are not observed token consumption or
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

## 3. Assessment: AMH against the survey's principles

Verdicts: **strong** means AMH already does what the survey found works; **partial** means it
does part of it; **gap** means it does not. The external sources are listed in §8. None of them
is evidence about AMH itself.

| # | Principle | Verdict | Where AMH stands |
|---|---|---|---|
| 1 | Verification is the biggest lever | strong here; partial for adopters | One entrypoint that CI also runs, binary acceptance, a fixture for every guard. For adopters, `AMH-ADOPT.md` §4 asks only for "build, test and lint". It says nothing about end-to-end checks or about keeping green output short. |
| 2 | The checker is not the doer; prefer deterministic checks | strong | P12: a fresh-context reviewer, one blocking pass, no self-review for rule diffs. The Codex reviewer is read-only. Guards are deterministic. |
| 3 | Guides and sensors together | strong where an artifact exists; gap by design elsewhere | Guard refusals carry the rule and the fix (measured). P3 leaves a rule with no artifact as prose with no sensor. Two prose rules have a behavioural scenario, and only one of those has recorded subject runs. |
| 4 | Context is a budget; always-loaded text should be a short map | **gap** | About 39 KB of text must be read before work. The adopter seed constitution is bigger than this repo's, and the light profile tells adopters to fold the runbook into it. The constitution also carries host-specific detail to every host. In AMH's favour: the ETH study found context files useful for non-standard practices, which is what AMH's rules are. The open question is which content must be in front of every session. |
| 5 | Grow from failures; delete what stops earning its keep | strong at adding; partial at deleting | The incident bar is the survey's ratchet. AMH does remove things: the changelog records the former ledger warning band being removed. But nothing re-tests a compensating rule when models change, and P6 deliberately resists stripping scaffolding. This shallow clone cannot show the trend. |
| 6 | State outside the context window | strong | STATE, the ledger, the checkpoint invariant and the session banner are close to Anthropic's long-running pattern. One difference, a smoke test before new work, is parked (§6). |
| 7 | Compact, instructive interfaces | strong for what AMH owns | The host supplies the tools. Guards-only output is compact (measured), and refusals are instructive. |
| 8 | Make the system visible to the agent | strong for harness state | The banner reports present, absent or could-not-ask, and "configured, never observed". |
| 9 | Safety from architecture, not instructions | **gap** | The in-agent rails are many, and the README says honestly that they are not a sandbox. Neither adapter configures its host's sandbox. **DD-038's class** — a deletion that lands somewhere the agent did not mean — is what filesystem isolation contains on platforms where the sandbox runs. **DD-038 itself** ran on native Windows, where Claude Code's sandbox does not run (§8), so turning the sandbox on would not have contained that incident. Machine mode (**DD-063**) now puts the guard's permanent deletion denials and credential rails in front of every Claude Code session on the machine, not only those in an AMH repository. It is still an in-agent rail, so the verdict stands. |
| 10 | Keep writes single-threaded | strong | Strictly sequential work (**D-009**), one blocking reviewer, a read-only reviewer. |
| 11 | Measure the harness itself | partial | Guard coverage is measured by removing the behaviour and watching a fixture fail. Behavioural evidence is one scenario, one model, six runs (§2). Nothing measures what the harness costs a session, or whether a rule changes behaviour across models. |

## 4. Four lessons the units are built on

1. **Keep AMH's incident bar; it is the survey's own best finding.** A unit with an AMH incident
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

## 5. The units: H0, H0.5, H1, H4a, H4b, H2, H3, H5, H6a, H6b, H7, H8

The order runs: H0.5's review, then measurement, then the safety design and its build, then the context work
that H1 informs, then the lab. H8 is independent, and the owner may approve it at any point.
H6b is optional.

### H0 — commit the plan (docs-only): done 2026-11-01, as an open draft

- **Done:** at the owner's request, with no decision made. `docs/STATE.md` gained one
  Owner-queue item pointing at this file, and nothing else. A STATE checklist waits until the
  owner approves the plan (**Session discipline** 5).
- **Pass owed:** none beyond the ladder. The plan is not legislation.
- **Acceptance:** `scripts/ladder.sh --guards-only` green.

### H0.5 — review this plan with gpt-6-astra at `-e high` (docs-only; added by the owner, 2026-11-09)

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
- **Pass owed:** this unit is the pass. One fresh-context reviewer, read-only.
- **Acceptance (binary):** rev 3 is committed; §7 has a row for every finding; each recommendation
  outside the mandate is an Owner-queue item; `scripts/ladder.sh --guards-only` passes.

### H1 — inventory what each session must read, item by item (docs-only, measurement)

- **Why:** principle 4. The evidence so far is external, and this repository has no recorded
  incident (§2).
- **Do:**
  - For each first-class host and each install profile, list the files and sections a
    session must read before work, and measure their text volume.
  - Then inventory `AGENTS.md` and the seed constitution **item by item**: every paragraph and
    every individual list item, with mixed blocks split. Key each item by input revision, file
    and line range.
  - Record two dimensions separately:
    - **applicability:** every session, one host, or one platform;
    - **content type:** binding obligation, a description of what a guard covers or misses, or
      rationale and history.
- **Output:** the inventory, appended to this plan. No rule changes.
- **Acceptance:** an extraction script, kept with the exact command and input revision, emits
  the set of item identities. The inventory's identity set equals it exactly, with no item
  missing and none duplicated.

### H4a — specify the containment the sandbox can actually provide (docs-only, design)

- **Why:** principle 9, and lesson 4.
- **Do:** Read each host's current sandbox documentation and write the following into this
  plan:
  - **A supported matrix:** host × platform × host version → sandbox available, configured by
    AMH, or unsupported. Platforms: macOS, Linux, WSL2, WSL1, native Windows. Per Claude Code's
    documentation, native Windows runs commands unsandboxed and WSL1 is unsupported. Codex's
    platform support has not been verified.
  - **Native Windows options for the owner.** DD-038's path is contained only by (ii), or by
    (iii) on WSL2:
    - (i) native Windows stays unsandboxed, and the command guard and prose remain its only
      layers. This is said plainly in the README and the adapters.
    - (ii) AMH on Windows requires WSL2.
    - (iii) the adapter sets the host's fail-if-unavailable setting, so a session where the
      sandbox cannot start refuses to run rather than running unsandboxed. On native Windows
      this makes the Claude adapter unusable.
    - None of the three is settled by machine mode (**DD-063**). It puts the drive-root and
      nested-quote denials in front of every Claude Code session on a native Windows machine
      that installs it, AMH repository or not, but a denial is a rail and none of the three
      options is about rails. Option (i)'s README sentence should say that machine mode exists
      and is not containment.
  - **The WSL2 interop boundary.** A sandboxed command can launch a Windows binary through a
    Unix socket. Blocking that needs the socket settings plus the optional seccomp filter.
    Allowing every Unix socket reopens it.
  - **Settings scope and precedence:** project file versus user, local and managed settings,
    and what a looser setting at another layer does to AMH's. Partly answered by machine mode
    (**DD-063**). The command guard now ships a user-scope fragment,
    `harness/templates/configs/claude-machine-settings.json`, because a deletion's blast radius
    is the machine, not the project. Its verdicts are a subset of the project guard's at the same
    version, so if a host runs the hooks of both scopes on one call, the pair repeats a refusal
    and never adds one. Whether Claude Code runs both has not been observed or checked against
    its documentation here. Managed settings are the one scope `--restricted` still loads
    (**DD-053**), which makes them the stronger home for that fragment. Still open: how an allow
    rule or a sandbox key at user, local or managed scope interacts with the adapter's deny rules
    and with H4b's sandbox keys; and whether H4b's sandbox, like machine mode, belongs at user
    or managed scope rather than in the project file.
  - **Behaviour when the sandbox is unavailable, and the escape hatches:** unsandboxed retries,
    excluded commands, `!`-prompt commands. Which of them the adapter turns off.
  - **Legitimate access outside the working tree:** temporary directories, caches and git
    worktrees. The ladder's fixture suite builds repositories under a temporary directory.
  - **What stays outside the boundary:** at least the built-in file and web tools, command
    hooks, MCP servers and helper commands, per Claude Code's documentation. AMH's own hooks run
    outside the sandbox.
  - **Adopter migration.** Adapters install under `keep`, so existing adopters get nothing
    automatically. `docs/UPGRADING.md` must say what to apply by hand.
  - **Two claims, kept apart:** "containment added on supported platforms" versus "DD-038's
    execution path contained". The second is made only if the owner picks a Windows option that
    delivers it.
- **Pass owed:** none. No legislation changes, and H4b's pass reviews the design along with
  the diff.
- **Acceptance:** every cell of the matrix names its source, as a documentation section or a
  probe, or says unverified.

### H4b — wire the host sandbox into both first-class adapters, per H4a

- **Why:** H4a, as the owner decided it.
- **Do:**
  - Change `harness/templates/configs/` and this repo's adapter copies as H4a specifies, and
    keep every existing rail. The sandbox is a layer under them, not a replacement.
  - Extend `scripts/guards/adapter-set.sh`, and label it **configuration validation**, not
    runtime attestation.
  - Update the README's "not a security sandbox" sentence so it names exactly the
    platform/host cells that now have one.
  - Update `docs/UPGRADING.md`.
- **Pass owed:** one combined blocking fresh-context pass at the strongest tier, with both the
  rule-review and adversarial checklists. Adapter rails are legislation, and adapter wiring is
  glue.
- **Acceptance**, each probe run in a disposable tree and none of them destructive:
  - (a) Fixtures: each configuration-loosening mutation (sandbox off, fallback allowed,
    unsandboxed retries allowed, a widened write path, a widened network allowlist) fails the
    adapter-set guard. Restoring it passes.
  - (b) For each platform cell claimed as contained, in a live session with the adapter loaded:
    - a write inside the working tree succeeds and one outside it is refused;
    - an allowed host is reachable and a denied one is not;
    - on WSL2, if claimed, a harmless Windows-executable launch is refused.
  - (c) The full ladder passes inside the configured sandbox.
  - (d) A synthetic credential probe only if credential isolation is claimed.
  - (e) Every combination not probed is recorded as unverified in the README, the ledger row
    and the commit body.
  - Live probes are observed by the owner or a named session and are not CI evidence. The
    disclosure says so.

### H2 — keep in the constitution what every session needs; point at the rest

- **Why:** principle 4. The owner decides from H1's inventory.
- **Do:** For each obligation the owner chooses to move, record four things:
  - its original scope;
  - its destination: a binding runbook section, or a ledger row for rationale and history. An
    adapter comment is never a destination for a binding rule unless H2 also gives the host
    that applies an explicit read path to it;
  - the retrieval trigger, meaning the moment an agent will read it;
  - the binding declaration that makes it bind there.
  Leave a one-line binding pointer in `AGENTS.md`. Keep rationale and history apart from live
  requirements.
- **Pass owed:** rule review, at the strongest tier. The reviewer judges whether each move kept
  the obligation's scope and force.
- **Acceptance:**
  - (a) A script checks that every binding sentence removed from `AGENTS.md` appears word for
    word at its destination. This is textual evidence only, and its output is kept for the
    reviewer.
  - (b) `scripts/guards/doc-navigation.sh`'s expectations gain every new pointer/heading pair.
    A fixture shows that removing each new pointer, and each new heading, fails the guard.
  - (c) The complete mandatory reading set is re-measured as in §2. Moving text into a section
    every session reads anyway saves nothing, and the measurement shows whether it did.
  - (d) The full ladder is green.
- **Not a byte cap** (**DB-038**). No rung judges the result, and no size target is set.

### H3 — the light profile keeps the constitution a map, without an upgrade trap

- **Why:** principle 4. Light is the default profile, yet it tells adopters to fold the runbook
  into the always-loaded file (§2).
- **Constraint:** installs never overwrite an adopter's file (`keep`). So one adopter-owned path
  must never mean different completeness levels at different profiles. A light install that
  writes a partial `docs/RUNBOOK.md` would be kept, partial, by a later standard install.
- **Options for the owner:**
  - (a) a separate **binding document** that every profile installs, holding Session discipline
    and the review protocols. The operational playbooks are installed separately at standard and
    full. The constitution points at the binding document in every profile, so light needs no
    fold.
  - (b) the seed ships a short, pre-written light-profile digest of those sections, and the fold
    instruction goes. This means two copies of the rules, kept in sync by hand.
  - (c) no change.
  - Recommendation: (a). It keeps one copy of each rule and no path changes meaning. It changes
    the adopter file layout, so it needs a version decision (§1 item 2), and this repository's
    own runbook may need the same split.
- **Touch:** `scripts/amh-init.sh`, the seed templates, `harness/templates/AMH-ADOPT.md` §1,
  the README and any seed prose that describes folding the runbook into the constitution,
  `docs/UPGRADING.md`, and `scripts/tests/test-init-e2e.sh`. Follow `docs/RUNBOOK.md` →
  **Change a seed template**.
- **Pass owed:** rule review, at the strongest tier.
- **Acceptance:** e2e cases for each of these:
  - fresh light, standard and full installs;
  - light→standard and light→full escalation;
  - a repeated install;
  - preservation of adopter edits.
  Each case asserts the required **sections** and that every pointer destination resolves, not
  only that files exist. Then the full ladder is green.

### H5 — separate the enduring invariants from the compensations

- **Why:** principle 5, and lesson 2.
- **Do:** Start from H1's item inventory and the eleven Session discipline items, split into
  individual obligations. Classify each obligation as an invariant, a compensation, or mixed.
  For a mixed one, say which part is which. For each compensation, record:
  - the ledger row that actually supports it (provenance);
  - an observable failure condition: what would go wrong without it, in a form some instrument
    could detect.
  Write the result into `harness/src/10-principles.md` beside P6. Retiring anything stays the
  owner's call and never happens in this unit. Any later retirement experiment names the one
  compensation it removes and shows the invariant beside it still holds.
- **Pass owed:** rule review, at the strongest tier. This changes a principle.
- **Acceptance:**
  - every inventoried obligation has a classification;
  - every compensation has a resolving ledger citation and a stated failure condition, checked
    by script;
  - `scripts/build-dist.sh` and the full ladder are green.

### H6a — owner-launched replication of the existing scenarios across models

- **Why:** principle 11. **DB-024** says broadening the lab to more models is not refused on
  its merits and is owner-launched.
- **Do:** The owner runs scenarios 01 and 02 unchanged on the models they choose.
- **Pass owed:** none. No code changes.
- **Acceptance:** a ledger row carrying each model's evaluator verdict counts, in the
  evaluators' own words. The conformance README's claim widens by exactly what was run and no
  further.

### H6b — OPTIONAL: an instruction-set experiment for H2's relocation

- **Why:** H6a cannot test H2. The fixtures hand subjects their own four-rule constitutions
  (§2), so a checkout from before or after H2 gives subjects identical instructions. The lab's
  authors kept those constitutions short on purpose, because "a fixture constitution long
  enough to skim is measuring reading stamina instead". Reading stamina is exactly what H2's
  question is about, so this is a different experiment, not a variant of the existing one.
- **Do:** Extend the fixtures so each arm receives a coherent instruction set: the pre-H2 or
  post-H2 constitution, the runbook sections it references, and their dependencies. Model
  settings, task, evaluator and unrelated fixture content are fixed between arms. Follow
  `docs/RUNBOOK.md` → **Add or change a conformance scenario**.
- **Pass owed:** rule review, at the strongest tier. Scenario machinery encodes a reading of a
  rule.
- **Acceptance:**
  - Before any subject runs, an independent inspection of the generated instruction artifacts
    shows the two arms differ, and differ only in the intended content.
  - `conformance/selftest.sh` is green.
  - The claim is bounded: these scenarios may detect particular regressions, and equal verdicts
    do not establish that the arms are equivalent.

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
  - Define the refusal trigger the subject meets.
  - Define the observable contract, which needs:
    - a positive task-completion condition, so doing nothing fails;
    - sentinel **integrity**, as a content hash, not mere directory existence;
    - a precise definition of a retained prohibited artifact that a legitimate negative-test
      script does not match.
  - Keep **containment** apart from **behavioural compliance**. If a sandbox blocks the retry,
    the sentinel survives, but that is containment, not compliance. The subject runs with
    containment held constant and recorded.
- **Pass owed:** the playbook's acceptance plus rule review, at the strongest tier.
- **Acceptance:** `conformance/selftest.sh` green, with a reason-specific mutation for every
  assertion and every enumerated INCONCLUSIVE trigger. It includes these counterexamples, each
  with the verdict the contract assigns it:
  - a retry blocked by containment;
  - a wrapper that is created, run and then removed;
  - a subject that does nothing;
  - a legitimate negative-test script that names the sentinel.
  Then break the evaluator, watch the suite go red, and restore it. Subjects run only in a
  throwaway container the owner launches, never on a machine with real data.

### H8 — tell adopters what a strong `verify.sh` looks like (seed template)

- **Why:** principle 1. External evidence only, and the change is a few sentences.
- **Do:** In `harness/templates/AMH-ADOPT.md` §4 and the seed `verify.sh` comments, add two
  things:
  - where the product allows it, one step that exercises it the way a user would;
  - keep green output short and failures loud, because the agent reads the whole output.
- **Pass owed:** rule review, at the **strongest available tier**. Everything under
  `harness/templates/` is legislation, whatever the diff's size.
- **Acceptance:** `scripts/tests/test-init-e2e.sh` and the full ladder are green.

## 6. Parked: no AMH incident yet

Each item reopens on a recorded incident, not on this survey.

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

## 7. Review of rev 1 and how rev 2 answers it

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

- Claude Code sandboxing documentation, read 2026-11-01:
  https://code.claude.com/docs/en/sandboxing. Covers platforms (macOS, Linux and WSL2; native
  Windows unsandboxed; WSL1 unsupported), `sandbox.failIfUnavailable`, unsandboxed retries and
  `allowUnsandboxedCommands`, the tools and processes outside the sandbox, and WSL2's Unix-socket
  interop with the optional seccomp filter.
- Codex sandbox settings: official documentation not retrieved. The developers.openai.com
  security page redirected to a page that only links elsewhere. H4a must read the official
  pages first.
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

- Codex's sandbox settings and platform support. H4a starts there.
- No live sandbox probe was run. Every containment claim waits for H4b's probes.
- Token figures are estimates. Byte figures measure text volume, not consumption.
- Of `harness/src/10-principles.md` and `docs/RUNBOOK.md`, only the sections quoted in this
  session were read. Each unit re-reads what its playbook names.
- Several external figures come from secondary coverage or abstracts (§8).
- No subject runs took place. Nothing here is a claim about how any agent behaves under AMH.
