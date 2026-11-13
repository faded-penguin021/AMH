# RUNBOOK — maintenance playbook

<!--
SEED TEMPLATE (AMH). Yours from the moment it is copied. Process docs are code: if a playbook
is wrong, stale or missing the case you just handled, fixing it is part of that change, not a
follow-up. The procedures every session is bound by, whatever its task, are not here: they
are in docs/PROTOCOLS.md, which the playbooks below route into.
-->

Entry point for changing the system. Pick the playbook matching your task, read the reference
docs it names, then do the work under `docs/PROTOCOLS.md`. **Code + {{IMMUTABLE_FIXTURES}} are ground truth** for what
the system does; where descriptive prose disagrees with the code, trust the code (and fix the
prose) — never a binding rule, which the code does not settle (see the constitution's
ground-truth note) — and never the append-only ledger, whose rows are never edited in place: a
correction is a new row plus one appended pointer on the old one.

## Where logic lives

{{MODULE_MAP — the same shape as the constitution's, one level more detail.}}

## Reference-doc index

| Question | Doc |
|---|---|
| {{QUESTION}} | {{DOC_PATH}} |
| What binds every session? | `docs/PROTOCOLS.md` |
| How do I compress `docs/STATE.md`? | `docs/PROTOCOLS.md` → **Working-memory compression** |

## Change-type playbooks

Each: *when · read first · code to touch · obligations · acceptance · record it.* That is the
order to READ them in. In execution the record is written before the acceptance run, so the
ladder verifies the tree that is committed (`docs/PROTOCOLS.md` → **Session discipline** 3).

### 1. {{CHANGE_TYPE, e.g. "Bug fix"}}

- **Read first:** {{reference docs + related ledger rows}}
- **Steps / code:** {{where the change goes — e.g. reproduce → failing test first → fix so it
  conforms to the fixtures (never edit a fixture to pass) → ladder → adversarial review if the
  unit was set to touch {{UNTESTED_GLUE_AREAS}}, whatever its diff ends as —
  `docs/PROTOCOLS.md` → Session discipline 10}}
- **Acceptance:** {{the binary gate — which ladder rungs}}
- **Record:** {{STATE changelog line; ledger row if durable; which reference doc to update}}

{{Repeat for each recurring change type: feature, config/schema change, dependency or
platform bump (two reviewable commits: forward-compat first, behaviour flip second), release
cut (version invariants; the owner does the tagging), etc.}}

## When CI fails (workflow vs code)

The local ladder and CI run the same script, but the commit, index and worktree are inputs too.
A guard built on `git ls-files` may omit an untracked file; staging it after the local run
changes the input CI receives and can turn local-green into CI-red without any environment
difference. Triage: (1) read the failing log; (2) reproduce from the exact tree state CI
checked, staging new files before the local ladder when a guard's file discovery is
index-dependent; then classify a real failure (fix the code), a toolchain mismatch (fix the
workflow, in the same PR), or a flake (re-run once; never "fix" code for a flake). (3) Never
weaken a gate to get green. (4) Real but out of scope: say so, with the log excerpt.

## Self-adaptation — keep this runbook useful

If this runbook lacks what you need: consult the ledger — and `docs/history/` if this repo has
an archive; only the full profile installs one — record durable facts as ledger rows, and if a
playbook is wrong, stale or missing the case you just handled, **fix this runbook in the same
change.** Treat it as code.

Self-adaptation covers *operational* content — playbooks, the doc index, module maps,
commands. *Binding* rules (session discipline, the review protocols, guard semantics, git and
permission policy) are never self-adaptation: they live in `docs/PROTOCOLS.md` and go through its
rule-review protocol, and process-reshaping changes go through the Owner queue (its Session
discipline 7).
