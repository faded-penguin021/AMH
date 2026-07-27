---

## Adaptation notes

**Scope: one owner, sequential sessions.** The harness assumes a single human owner and one
agent session at a time on the repo (P5's sequential discipline; the branch rules extend it
across sessions). Multi-owner arbitration, concurrent agent sessions and external-contributor
PR flows are out of scope — using it there needs at least task claims, ledger-ID allocation and
state-file merge rules the harness deliberately does not define.

**Smallest useful subset**, for a repo with light AI maintenance: the constitution + a state
file with the Owner queue + a single verification command. For small repos, fold the runbook
into the constitution — fewer files to keep straight; split only when the playbooks multiply.
Add the ledger the first time you catch yourself re-explaining a past mistake; add guards the
first time a rule is violated.

**Bootstrap `ladder.sh` as nothing but the verification commands.** Guards accrete one at a
time, each earning its place after a real violation, and each landing with a fixture test in
the guard suite — a botched guard that false-passes is worse than no guard. Treat the first few
sessions as a shakedown: watch adherence, and when a rule proves ambiguous, the fix is a
clarified runbook or constitution in the same change, not more rules.

**The ledger earns its cost** once two or more distinct sessions (or agents) touch the repo. It
is the only channel through which session N's shipped bug teaches session N+9's review pass.

**Human effort budget.** The owner's recurring touchpoints are exactly three: merge squash PRs,
action the Owner queue, and drop manual-test findings into Incoming findings. Every other
mechanism runs agent-side. If a proposed addition to the harness increases the owner's
per-change workload, it is probably wrong (see P3).
