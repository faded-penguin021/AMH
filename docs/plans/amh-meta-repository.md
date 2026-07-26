# AMH meta-repository — build plan

> **Status, 2026-07-26 (added on commit; the plan body below is unchanged from the one the
> work was started against).** Committed late, at the owner's request, after U1–U4 had
> shipped — it had lived only in session context until now, which is the failure mode P16's
> plan directory exists to prevent. **Where the built tree differs from this plan:**
>
> - **Merge mode is `branch-train`**, not the `branch-per-change` below. The topology has been
>   a train since the second branch; the config was corrected on 2026-07-26 by owner decision,
>   not the topology.
> - **U6 was never built.** `CONTRIBUTING.md`, `scripts/amh-init.sh` and
>   `scripts/tests/test-init-e2e.sh` do not exist. The first two are cited from prose that
>   does exist, which makes RUNBOOK playbook 5 unfollowable (**D-017 B11**).
> - **`scripts/tests/`** holds `local-guards.sh`, not the `test-rails.sh` /
>   `test-init-e2e.sh` this plan names: repo-local fixtures needed a third slot that the
>   rules as written did not have (**D-013**).
> - **A fifth guard, `scripts/guards/path-refs.sh`**, was admitted after the "no link
>   checker" decided non-item was overturned the same day it was recorded (**D-010**).
> - **U5 is incomplete**: no release workflow exists (so the `amh-v1.8.0` tag triggers
>   nothing), and the review's prose corrections landed in this repo's instance without being
>   mirrored into `harness/templates/seed/` and `harness/src/`.
> - **Two acceptance claims below were not met on first pass.** CI has never been green in
>   this repo's history (**D-016** item 8), and the shipped command guard shipped with a
>   rail-voiding regression (**D-016** items 1–7, repaired 2026-07-26).
>
> A plan is a disposable artifact: it dies when the work lands, and code cites ledger rows,
> never plans. This one is kept because the owner asked for it as a handoff aid. Delete it
> when U6 closes, and record the outcome as a Changelog line.

## Context

`faded-penguin021/AMH` is currently empty (one 5-byte `README.md`). The Agentic Maintenance
Harness exists only as a single uploaded markdown document — a prompt people paste around,
with no home, no version history, and no repo that actually runs it.

This plan turns the repo into the harness's **source of truth** *and* its **reference
instance**: it distributes the harness (versioned prose, copyable templates, an instantiation
tool, an upgrade path) and is itself maintained under the harness (constitution, memory tiers,
ladder, rails). Dogfooding is not decoration here — a template no repo executes is a liability,
and the meta-repo executing the exact files it ships is the only honest proof they work.

Outcome: a stranger can read `README.md`, decide whether the harness is for them, instantiate it
into their own repo in one command, and later move to a newer harness version by following
`docs/UPGRADING.md` — while every change to the harness itself lands under the harness's own
discipline.

**Confirmed decisions:** semver (`1.8.0`) · split source + generated single-file bundle · full
reference instance.

## Architecture

Two things live here, cleanly separated:

| | The product (distributed) | The instance (this repo runs it) |
|---|---|---|
| Prose | `harness/src/*.md` → generated `harness/dist/AMH.md` | `AGENTS.md`, `docs/RUNBOOK.md` |
| Scripts | `harness/templates/scripts/*.sh` | byte-identical copies in `scripts/` |
| Memory | `harness/templates/seed/docs/*` | `docs/STATE.md`, `docs/LEDGER.md` |

Three design choices carry the whole structure:

1. **Shipped scripts are parameter-free.** Instead of `{{PLACEHOLDER}}` substitution, the five
   shipped scripts read `amh.conf` at runtime (branch names, KB thresholds, ledger line cap,
   citation scan paths, poison tokens). No render step, no rendered-vs-template drift class.
   This repo's `scripts/*.sh` are *byte-identical copies* of `harness/templates/scripts/*.sh`,
   enforced by `cmp` in a guard — so the reference instance provably runs the shipped artifact.
2. **Two extension points keep those scripts repo-agnostic**, so they never need local edits
   (which is what makes the `cmp` guard viable): `ladder.sh` runs `scripts/guards/*.sh` after
   its built-in guards and then `scripts/verify.sh` as the full verification rung;
   `session-start.sh` calls `scripts/bootstrap.sh` if present.
3. **Mechanical vs seed templates.** Scripts and configs are copied verbatim and stay
   upgradeable; prose scaffolds (constitution, RUNBOOK, STATE, LEDGER) are *seeds* — copied once,
   then owned by the adopting repo and never drift-checked. Only `configs/` (JSON/YAML that can't
   read `amh.conf`) uses `{{PLACEHOLDER}}` substitution, applied once at init.

```
README.md  CONTRIBUTING.md  AGENTS.md  CLAUDE.md  amh.conf  .gitignore
.claude/settings.json          .github/workflows/ci.yml
docs/    STATE.md RUNBOOK.md LEDGER.md UPGRADING.md history/.gitkeep
harness/ VERSION CHANGELOG.md PLACEHOLDERS.md
         src/{00-overview,10-principles,20-constitution,30-scaffolds,40-adaptation}.md
         templates/scripts/{ladder,session-start,command-guard,redact,test-ladder-guards}.sh
         templates/configs/{claude-settings.json,ci.yml}  templates/amh.conf.example
         templates/seed/{AGENTS.md,CLAUDE.md,docs/{STATE,RUNBOOK,LEDGER}.md}
         dist/AMH.md                      # GENERATED — never hand-edited
scripts/ ladder.sh session-start.sh command-guard.sh redact.sh test-ladder-guards.sh  # copies
         verify.sh amh-init.sh build-dist.sh
         guards/{copy-drift,dist-drift,version-lockstep,placeholder-integrity}.sh
         tests/{test-rails.sh,test-init-e2e.sh}
```

**Harness settings for this repo** (`amh.conf`): default branch `main`, branch prefix `claude`,
merge mode **branch-per-change**, STATE thresholds 9/14/16 KB, ledger cap 800 lines, citation
scan scope `scripts/ .github/` (explicitly **not** `harness/` — template and dist prose contain
illustrative `D-NNN` text that is not a citation).

## Build units

Sequential, each ends *ladder green → STATE changelog line → commit → push* (P5).

**U1 — Self-hosting core.** `amh.conf`; the five shipped scripts under
`harness/templates/scripts/` + copies in `scripts/`; `scripts/verify.sh`; minimal `docs/STATE.md`
and `docs/LEDGER.md` (D-001 founding decisions, D-002 the copy-not-render choice);
`.claude/settings.json` (deny force-push / push to `main` / env dumps; allow the ladder;
PreToolUse → `command-guard.sh`; SessionStart → `session-start.sh`); `.github/workflows/ci.yml`
invoking `scripts/ladder.sh`; `.gitignore`.
`ladder.sh` guards per §3.4: STATE size hysteresis + landing check, STATE structure, ledger
rollover, citation integrity with `[cited]` sync, secret-shape scan via `redact.sh`,
poison-token scan over `origin/main..HEAD`, rail self-tests, local-only advisories (checkpoint,
stale-branch with the `git merge-tree` classifier, plan-orphan, rule-review tripwire), then
`scripts/guards/*.sh`, then `--guards-only` exit, then `scripts/verify.sh`.
*Acceptance:* `scripts/ladder.sh` green; `test-ladder-guards.sh` fixture suite green;
`command-guard.sh --self-test` and `redact.sh --self-test` green.

**U2 — Legislation.** `AGENTS.md` (canonical constitution, records "AMH v1.8.0"), `CLAUDE.md`
pointer stub, `docs/RUNBOOK.md` with playbooks specific to a harness repo: *change a principle ·
change a template · add a guard · cut a harness release · CI failure · leaked credential*, plus
session discipline and both review protocols. Adds `scripts/guards/copy-drift.sh`.
*Acceptance:* ladder green including the new copy-drift guard.

**U3 — Templates for adopters.** `harness/templates/seed/*`, `harness/templates/configs/*`,
`harness/templates/amh.conf.example`, `harness/PLACEHOLDERS.md` (every placeholder, its meaning,
its default). Adds `scripts/guards/placeholder-integrity.sh` — every `{{X}}` in templates is
documented, and no `{{X}}` survives in this repo's live files.
*Acceptance:* ladder green.

**U4 — Harness prose + bundle.** `harness/src/*.md` carrying Parts 1–3 and the adaptation notes
of the uploaded document, with scaffold bodies referenced rather than inlined;
`scripts/build-dist.sh` assembles `harness/dist/AMH.md` (template files inlined into fenced
blocks, `GENERATED — edit harness/src/` banner); `scripts/guards/dist-drift.sh` rebuilds to a
temp dir and fails on any difference.
*Acceptance:* rebuild-and-diff clean; ladder green.

**U5 — Version & upgrade path.** `harness/VERSION` = `1.8.0`; `harness/CHANGELOG.md` with a
`1.8.0` entry and a per-release **Upgrading** subsection; `docs/UPGRADING.md` (read CHANGELOG
from your recorded version forward → copy new shipped scripts, diff configs → apply seed changes
by hand, they are yours → bump the version note in your constitution → ledger the upgrade → pin
or skip guidance); `scripts/guards/version-lockstep.sh` binds `VERSION` ↔ `dist/AMH.md` header ↔
CHANGELOG top entry ↔ `AGENTS.md`'s recorded version. Semver rule stated in CONTRIBUTING: MAJOR =
binding rule changed, adopters must act; MINOR = additive; PATCH = clarification only.
*Acceptance:* lockstep guard green; ladder green.

**U6 — Human docs + instantiation.** `README.md` (what the harness is · **who it's for**:
single-owner repos maintained by sequential agentic sessions, any agent or vendor, with
human-in-the-loop — **not** multi-owner arbitration, concurrent sessions, or
external-contributor PR flows · quickstart · the smallest-useful-subset path · repo map).
`CONTRIBUTING.md` (how to change the harness: the repo is governed by its own `AGENTS.md`;
rule-review protocol mandatory and strongest-tier for every legislation diff; semver policy;
where a new principle goes and the bar it must clear against P0; the decided-non-items vaccine
for re-proposed ideas; branch/merge rules; release flow). `scripts/amh-init.sh <target-repo>`
copies scripts + seeds, substitutes config placeholders, writes `amh.conf`, and is idempotent.
`scripts/tests/test-init-e2e.sh` instantiates into a temp git repo and runs *that* repo's
`ladder.sh --guards-only`.
*Acceptance:* the e2e test passes; ladder green.

## Verification

- `scripts/ladder.sh` — the single entrypoint, invoked identically by CI (P4).
- `scripts/ladder.sh --guards-only` — seconds, for docs-only units.
- `scripts/test-ladder-guards.sh` — fixture repos asserting each guard's pass/warn/fail,
  including the STATE landing check and the value-free property of the secret-scan diagnostic.
- `command-guard.sh --self-test` — blocked *and* allowed matrices (quoted text naming a
  forbidden command must stay allowed).
- `scripts/tests/test-init-e2e.sh` — end-to-end: instantiate into a scratch repo, run its ladder.
- `bash -n` on every script; `shellcheck` when present (required in CI, warn-and-skip locally).

## Owner queue seeded at U1

1. License choice for the distributed harness (unset today).
2. Server-side rails (P13): branch protection on `main` + secret-scanning push protection.
3. Tag `amh-v1.8.0` after merge — tagging stays an owner step.
4. Founding legislation (U1–U2) has no fresh-context reviewer: the protocol binds from the commit
   that installs it, so the owner is the reviewer at merge. Recorded as a ledger row, not skipped
   silently. No subagents will be spawned for this unless you ask.

## Notes

- Deliberately *not* built: doc-fact guards (P20 admits a check only after a claim has actually
  drifted), a link checker, and any self-reported attestation (P3). Recorded under decided
  non-items so they are not re-proposed.
- Every guard beyond §3.4's core set lands with a fixture test in the same unit.
