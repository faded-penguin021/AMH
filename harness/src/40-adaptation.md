---

## Adaptation notes

**Scope: one owner, sequential sessions.** The harness assumes a single human owner and one
agent session at a time on the repo (P5's sequential discipline; the branch rules extend it
across sessions). Multi-owner arbitration, concurrent agent sessions and external-contributor
PR flows are out of scope — using it there needs at least task claims, ledger-ID allocation and
state-file merge rules the harness deliberately does not define.

**Smallest useful subset**: every document the constitution sends a session to — the
constitution itself, `docs/PROTOCOLS.md` with the procedures every session is bound by, a
runbook for the change-type playbooks, a state file with the Owner queue and a ledger — plus a
single verification command. A smaller tree is one whose constitution names documents it does
not have, and a constitution citing a file that is not there teaches the next session to
distrust it. Grow the machinery, not the document set: write a playbook when a job recurs, a
ledger row the first time you catch yourself re-explaining a past mistake, a guard the first
time a rule is violated.

**Install profiles are that subset made executable.** `amh-init.sh --profile standard|full`
selects which seed prose lands in the target tree, and nothing else:

| Profile | Seeds it installs | When it is right |
|---|---|---|
| `standard` — the default | constitution, agent pointer, protocols, runbook, working memory, ledger, `verify.sh` | a new adoption, and most repos indefinitely |
| `full` | + the archive tier (`docs/history/`) | something has been retired whole and needs a home |

The layers are deliberately unlike each other. The **shipped scripts are parametric** —
byte-identical at every profile, so an upgrade stays a copy rather than a merge. The **seed
prose is materialised** — chosen once at init, owned by the adopter thereafter, never
drift-checked. And **rung activation is presence-derived**: no ledger means the citation rung
prints `skip`, no `scripts/guards/` means zero repo-local guards ran, and the ladder is green
either way, saying which checks it did not perform.

**Nothing records the level.** The profile reaches the adopter's agent through their adoption
brief and is written nowhere a script reads, so no future guard can branch on it and no session
can reach for a smaller level to make a red rung quiet. That is the point: a declared level is a
claim about intent, whereas the presence of a ledger file is an artifact the work produces
anyway (P3). Escalating is therefore not a setting but a re-run — `amh-init.sh --profile
full <target>` adds the missing seed and, because every seed is written only when absent,
changes nothing the adopter has written. Moving up a profile is a visible diff of added files,
which is what makes a smaller default safe.

**Nothing `amh-init.sh` does may be needed again after it exits.** The tree it leaves behind is
self-describing and independently executable with `bash`, `git` and coreutils; the harness is
never on the runtime path, and no tool sits between an agent and the raw files. That is why the
init script may materialise as much as it likes without becoming a dependency — and it is the
line any proposed sync tooling has to stay behind.

**Bootstrap `scripts/verify.sh` as nothing but the verification commands**, and leave the shipped
`ladder.sh` as delivered — its guards activate on artifact presence. Guards accrete one at a
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
