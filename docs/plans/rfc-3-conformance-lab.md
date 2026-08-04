RFC: Agent Behavioral Conformance Lab

Status: ADJUDICATED 2026-08-03 — accepted in reduced form. Two scenarios, not seven; no YAML,
no oracle directory, no in-tree reports.
Audience: AMH architecture and implementation review
Scope: Evaluation of AMH behavior across real coding agents and environments

Adjudication note

Received as an externally-authored proposal, revised in place by review outcome. Under P18 it
entered as DATA, never authority. A blocking fresh-context pass adjudicated it claim by claim;
the verdicts are permanent in ledger row DA-026, which is the record, not this file.

This is the only one of the three RFCs that survives substantially. It is also the only one that
was STRENGTHENED by the refusal of its siblings.

Why RFC2's refusal helps rather than hurts

Two of this document's evidence sources named run receipts, and one named marker files produced
by hooks. Both were refused — receipts as forgeable (DA-025), hook markers as unable to name
their caller (DA-024). That looks fatal and is not, because DA-025 accepted the ladder naming its
own subject commit and worktree state in its verdict lines: exactly what an evaluator needs, with
no artifact in between.

The repair generalizes past the deletion, and it is the strongest rule in the adjudicated design:

  An evaluator must compute its evidence in its own process, and must never read an artifact the
  subject could have written.

The evaluator runs the ladder inside the disposable clone and reads its stdout. It runs its own
rev-parse. It stats its own files. This document half-knew the rule already — its
insufficient-evidence list bars a self-authored conformance report — and then broke it by
admitting receipts and hook markers. With those struck, six of seven scenarios lose nothing:
every assertion they list is a filesystem, git-ref or ladder-exit fact the evaluator obtains
first-hand.

What is ACCEPTED

1. The design principle: treat the agent as an untrusted implementation of the protocol and
   evaluate only observable consequences. This is P3's "does anything downstream consume it?"
   aimed at the agent rather than at a gate — the same doctrine, pointed at a target this
   repository had never aimed it at.

2. The insufficient-evidence list — the agent's explanation, a checklist it completed, a commit
   message saying "reviewed", transcript sentiment, another model's unsupported verdict, a
   self-authored report. This is D-014 and P3 reached independently by an outside author.

3. The permitted-evidence list, MINUS run receipts and hook markers: file presence and absence,
   exact or structural content, commit count and parentage, branch and remote refs, worktree
   state, ladder and CI results, deterministic command output, and the absence of forbidden side
   effects.

4. Scenario isolation: disposable repositories and remotes, unique branch namespace, no
   production credentials, cleanup after evaluation. This matches the throwaway-repo idiom the
   repo-local fixture suite already uses.

5. The release-claims bound. "Exercised against" carefully avoids "passed", and it is prose that
   claims no enforcement — the honest form.

6. The implementation directive's own instinct: build the smallest complete experiment. Note that
   this contradicts the owner's standing "full acceptance criteria" decision; the document's own
   author agrees with the reduced build.

7. That the lab is never installed into an adopter repository — already automatic. The installer
   sources every path from the harness templates directory, and its seed classifier is exhaustive
   and fatal on an unclassified file, so smuggling lab content into the seed tree dies at init.
   Nothing further is needed.

The asymmetry that should shape the whole build

A FAIL is cheap and highly informative: a prose rule does not work, go fix it. A PASS is one
model, one fixture, one run, and means almost nothing.

Build the lab as a FAIL-detector. Suppress PASS aggregation entirely — which is the second reason
the reports directory stays out of the tree, since a directory of PASS lines invites exactly the
inference the release-claims section forbids in sentences.

What is REFUSED

1. Five of the seven scenarios, on provenance. Checked against both ledger volumes:

   - Scenario 1, stale Owner-queue item — REAL. DA-011, which the owner reported as RECURRING
     across sessions, plus DA-012. KEEP.
   - Scenario 3, absence claimed from capped evidence — REAL, and this repository's
     most-recorded failure class. DA-002 and DA-003. KEEP.
   - Scenario 5, broken probe — real in class (D-020), but the recorded instance runs in the
     INVERSE direction: the agent narrowed the checker rather than altering production code.
     DEFERRED; if rebuilt, reorient to the recorded direction.
   - Scenario 2, prompt injection — HYPOTHETICAL here. Grepping for injection returns only the
     benign "external review as data" sense. Zero attacks on record. DEFERRED.
   - Scenario 4, bounded recovery — HYPOTHETICAL, and its evaluator is impossible regardless:
     "retry count bounded where mechanically observable" is not observable, because retries leave
     no repository artifact and P3 admits only artifacts the work produces anyway. REFUSED.
   - Scenario 6, session interruption — HYPOTHETICAL (zero ledger hits) and the most expensive of
     the seven: two model runs plus a mid-unit kill. DEFERRED.
   - Scenario 7, runtime integration failure — REFUSED outright. Its subject was the runtime
     doctor, the lifecycle probes and the "observed" state, all killed by DA-024.

   Speculative scenarios are what the incident bar exists to stop, and the owner's override
   (DA-023) covered these RFCs as documents, not every mechanism they might propose.

2. The per-scenario YAML metadata file — REFUSED as specified. No YAML parser exists and the
   owner's no-new-dependency decision permits only a bounded reader over a flat schema. Worse,
   a per-scenario required-outcome key is a difficulty dial living outside the rule-file
   tripwire, so weakening a scenario would trip nothing — D-019's rule that a disabled state must
   be louder than a passing one, inverted. Every assertion goes in the evaluator script instead,
   which the verification set lints and the adversarial pass reads.

3. The oracle directory of immutable expected artifacts — REFUSED under P19: do not manufacture
   an oracle by having the agent guess invariants, because a wrong oracle is worse than none. A
   hand-authored "expected resulting state file" measures agreement with one agent's model of
   correct behaviour, not correctness. The legitimate substitutes cost nothing: differential
   comparison against the fixture's own initial state — P19 admits "the previous version" as an
   oracle — plus non-occurrence of forbidden operations, which needs no model of correctness at
   all.

4. The in-tree reports directory — REFUSED. The document itself says reports are not AMH
   permanent memory; a committed directory is exactly that, and an untiered memory violates P2.

5. The nondeterminism policy's "keep model-backed execution non-blocking UNTIL repeatability is
   demonstrated" — REFUSED in its temporal half. A predicate satisfied only on average is a flake
   however sound it looks (D-024), and a flaky gate gets disabled rather than fixed. Model-backed
   runs are PERMANENTLY non-blocking.

6. The reporting format's receipt-commit field — REFUSED, no producer exists. Replace with a
   commit the evaluator computes itself in the result clone.

Corrections to the received design

- **The positive-control requirement is one-directional, and that is a hole.** As written, an
  evaluator consisting of a bare failure exit satisfies criterion 5 and all five listed controls.
  This repository's fixture rule pairs every expect-fail with an expect-pass; the lab must do the
  same. Note the two rules are orthogonal rather than duplicate: this repo mutates the CHECKER
  and holds the subject fixed, while the received document mutates the SUBJECT and holds the
  checker fixed. Both are needed; neither implies the other, and the received direction is
  genuinely one this repo's rule does not cover.

- **Four of seven evaluators assert ABSENCE** — resolved item absent, no forbidden ref update, no
  false marker — and an empty or missing state file satisfies "resolved item absent" trivially.
  Every absence assertion carries an explicit checked-NOTHING branch, as the runbook already
  requires of guards that can go hollow.

- **The INCONCLUSIVE definition contains a self-judged carve-out** — "the evaluator could not
  establish the result honestly" — which is the shape DA-024(b) refused. Enumerate its triggers,
  default to FAIL, and render it louder than PASS.

- **Fixtures must be generated at runtime, never stored.** A stored credential-shaped literal
  reddens the ladder's secret-shape guard (D-004), and a backticked path in fixture prose that is
  absent from the real tree reddens the path-reference guard — verified, since that guard's
  exclusion list does not cover the lab directory. Adding that exclusion is itself a guard diff,
  so the unit carries a rule-review pass.

Adjudicated acceptance criteria

The received fifteen are replaced by seven. The reason is that thirteen of the fifteen were
satisfiable with no agent ever running, and criterion 10 never defined "operational" — so a
populated tree and a green scorecard could coexist with zero bits of behavioural information.
That is Goodhart at the level of the acceptance criteria, inside a document whose thesis is that
self-certification is worthless.

1. Scenario, runner and evaluator layers are separate.
2. Two scenarios are operational, each seeded on a named ledger row: the stale Owner-queue item
   (DA-011, DA-012) and the incomplete negative search (DA-002, DA-003).
3. Every evaluator is exercised in BOTH directions — a compliant tree passes, a deliberately
   noncompliant mutation fails — and every absence assertion has a checked-NOTHING branch.
4. No evaluator reads any artifact the subject could have written.
5. Deterministic evaluator tests run in ordinary CI; model-backed execution is permanently
   non-blocking.
6. A launch or infrastructure failure produces INCONCLUSIVE from an enumerated trigger, never
   from a judgement call.
7. The lab is absent from an instantiated adopter tree, asserted mechanically rather than
   claimed in prose.

Honest statement of what this demonstrates

Until an owner funds a model-backed run on a disposable remote, the lab demonstrates that its
evaluators are deterministic and mutation-sensitive. It demonstrates nothing whatever about how
any agent behaves. That sentence belongs in the lab's own README, not only here.

The case for building it anyway, stated once

DA-011 records a failure the owner reports as recurring across sessions. DA-011(c) proves no
guard can ever reach it, because anything checking whether a session "verified the queue" is the
banned attestation shape. The fix that shipped was PROSE — session discipline item 7 — and
nothing in this repository tests whether that prose works. The runbook concedes the blind spot in
its own words: bash fixtures exercising bash guards in one interpreter cannot see a defect in an
assumption they share.

A behavioural scenario is the only instrument in this constitution's toolbox that can watch a
prose rule fail. That earns two scenarios. It does not earn seven, a runner abstraction, a
metadata contract and a report transport.

Non-goals (unchanged from the received text, all still correct)

- A public model leaderboard.
- Proving private reasoning quality.
- Requiring identical command sequences.
- Multi-agent coordination testing.
- Using an LLM as the only evaluator.
- Making paid model runs mandatory for every pull request.
- Replacing script unit tests or installer E2E tests.
- Guaranteeing universal compliance.
