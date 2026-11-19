# H3 companion — the adopter layout after H3, and how existing installs migrate

> Companion to the research-gaps plan's H3. Written before implementation, as H3 requires ("the
> selected layout's complete reading obligations are compared before implementation"), and
> updated with what the implementation measured. It is plan material: retire it with the plan.

## 1. The owner's answers (2026-11-13, when H3 started)

1. **Layout: option (a).** A separate binding document, installed at every profile, holds the
   procedures every session is bound by; the runbook keeps the change-type playbooks.
2. **Migration:** as proposed — installs keep never overwriting an adopter's file, and an
   existing install migrates by hand from the release CHANGELOG's Upgrading subsection.
3. **This repository's runbook gets the same split** ("we have to if we are serious about
   dogfooding").
4. **Name:** `docs/PROTOCOLS.md`.
5. **The `light` profile is removed.** Asked whether `light` should install the ledger, the
   owner answered: "Remove light, if it needs a ledger that may as well be standard. Everyone
   that was on light and upgrades gets upgraded to standard."

Two readings the session took from (5), stated so the review can contest them: a bare re-run
— the documented upgrade — now defaults to `standard`, so a former light tree receives the
runbook, the ledger and `docs/PROTOCOLS.md` under keep policy; and `--profile light` is refused
with a message naming the removal, never silently mapped to `standard`, because a silent alias
would let an old command line believe it still chose something.

H3 was first split into **H3a** (the harness side) and **H3b** (this repository's own runbook
split), then recombined before either had a pass: the path guard resolves `docs/PROTOCOLS.md`,
named throughout the README, the changelog and the ledger, against this repository's tree, so
the harness half could not be green without this repository's half. One unit, one combined
rule-review and adversarial pass at the strongest tier.

## 2. The layout

| File | Before H3 | After H3 |
|---|---|---|
| `AGENTS.md`, `CLAUDE.md`, `.gitattributes`, `docs/STATE.md`, `scripts/verify.sh` | light | standard |
| `docs/PROTOCOLS.md` | — | standard |
| `docs/RUNBOOK.md`, `docs/LEDGER.md` | standard | standard |
| `docs/history/README.md` | full | full |

Two profiles, two distinct file sets (**DA-007**'s closing consequence still holds). `standard`
is the default.

**Section placement.** The seed runbook's sections are split, verbatim apart from the
cross-reference repairs listed in §5:

| `docs/PROTOCOLS.md` (bound by every session) | `docs/RUNBOOK.md` (read for the task in hand) |
|---|---|
| Session discipline | Where logic lives |
| Adversarial review protocol | Reference-doc index |
| Rule-review protocol | Change-type playbooks |
| Incident: leaked credential | When CI fails |
| Acceptance ladder | Self-adaptation |
| Working-memory compression | |

The Acceptance ladder goes with Working-memory compression because each names the other and
both describe the state-file thresholds; splitting them would leave a pointer pair across files
for no reader's benefit.

## 3. Reading obligations, before and after

What the seed constitution and the seed state file make a session read, and whether the
destination exists. "Unresolved" is **DD-075**'s finding.

| Pointer (seed) | light, before | standard/full, before | every profile, after |
|---|---|---|---|
| Step 3: the matching change-type playbook | `docs/RUNBOOK.md` — unresolved | resolves | `docs/RUNBOOK.md` — resolves |
| Step 4: Session discipline | `docs/RUNBOOK.md` — unresolved | resolves | `docs/PROTOCOLS.md` — resolves |
| Test-first rule → Session discipline item | unresolved | resolves | `docs/PROTOCOLS.md` — resolves |
| Leaked secret → the incident playbook | unresolved | resolves | `docs/PROTOCOLS.md` — resolves |
| The invariant catalog, the live ledger volume | `docs/LEDGER.md` — unresolved | resolves | resolves |
| State file: Working-memory compression | unresolved | resolves | `docs/PROTOCOLS.md` — resolves |
| State file: Session discipline 7 | unresolved | resolves | `docs/PROTOCOLS.md` — resolves |
| Archive tier (`docs/history/`) | conditional prose | conditional prose | unchanged — conditional prose, full only |

After H3 no seed pointer is profile-dependent except the archive, whose prose already says
"if this repository has the archive tier". The light fold instruction — in the adoption brief,
the README, `harness/src/40-adaptation.md` and the seed runbook's header comment — has no
profile left to apply to, and goes.

**Not moved by H3.** The seed-constitution passages H2 left for H3 (its companion's §7:
the byte-cap rationale, the deletion-rule layers, the rails, the failing-hook rule) stay in the
seed constitution. Moving them is a relocation of live rules, which `AGENTS.md` makes the
owner's call; with a runbook now at every profile it has a destination, and it is recorded as a
follow-up rather than done here. `scripts/session-start.sh` is not changed: its protocol line is
already conditional on `docs/RUNBOOK.md` existing, which stays correct for an adopter who
deleted theirs.

## 4. Migration

A seed is never re-synced, so an existing install reaches the new layout by a re-run plus a
hand migration. The re-run (`amh-init.sh <target>`, now `standard` by default) writes
`docs/PROTOCOLS.md` and, for a former light tree, `docs/RUNBOOK.md` and `docs/LEDGER.md`,
keeping every file that exists. Three historical shapes:

- **standard or full, runbook as shipped:** the runbook and `docs/PROTOCOLS.md` now both carry
  the six sections — two authorities. Hand step: carry any local edit of those sections into
  `docs/PROTOCOLS.md`, delete them from the runbook, and repoint the constitution's and state
  file's pointers to them.
- **light, with the runbook folded into the constitution:** the constitution carries some or all
  of the six sections. Hand step: the same, from the constitution instead of the runbook.
- **light, unfolded:** the pointers were dangling; the re-run makes them resolve once repointed.

The installer cannot do the hand step (every file involved is the adopter's), but it can see
when it is unfinished, so its closing report says so: it names a kept constitution that never
mentions `docs/PROTOCOLS.md`, and a kept constitution or runbook that still carries a heading of
one of the six sections. That report is what makes H3's "a retained old constitution that never
references the new binding document fails" an assertion the e2e suite can make. It is advice
for the adopter, not a gate: the installer's exit status does not change.

## 5. Results

### The harness side

- **The split, measured with `wc -l`:** the 464-line seed runbook became a 407-line
  `docs/PROTOCOLS.md` (13 lines of new header, 394 moved) and a 69-line `docs/RUNBOOK.md`; the
  one blank line at the seam was dropped. Cross-reference repairs, all in wording that named the
  runbook from inside a moved section or a moved section from inside the runbook: the rule-review
  protocol's "this runbook's protocols" and "in this runbook", compression's "This runbook is
  read on demand", the runbook's header comment (the fold sentence), its entry paragraph, its
  doc-index row for compression (plus a new "What binds every session?" row), the
  change-type-playbook preamble and placeholder, and self-adaptation.
- **Seed pointers repointed:** the constitution's ground-truth note, step 4, the test-first
  bullet, the leaked-secret bullet and the instruction hierarchy; the state file's comment,
  length guard and Owner-queue preamble. The constitution's install comment now says
  `docs/UPGRADING.md` and `harness/src/10-principles.md` are in the AMH checkout (a mid-unit
  review's finding: neither is installed into an adopter).
- **Beyond the seeds:** `amh.conf.example` adds `docs/PROTOCOLS.md` to `RULE_FILES`; the Codex
  reviewer agent (template and this repository's byte-identical copy) names "the Rule-review
  protocol" instead of `docs/RUNBOOK.md`, which needed no second change when this repository split too.
- **Mid-unit review** (gpt-6.1-sol, `ask`, medium, on this companion before implementation): six
  findings. Taken: CI's two `--profile light` calls; a kept, incomplete `docs/PROTOCOLS.md` must be
  reported; a half-done migration (state file not repointed) must be reported and tested;
  `RULE_FILES` and the reviewer agent; the light fold also moved playbooks, which the migration
  and report must cover; the install comment's two AMH-only paths.
- **Tests:** `scripts/tests/test-init-e2e.sh` section 5 rewritten for two profiles, keeping every
  property the light cases protected (the credential positive control, the presence-derived
  ledger skip on a tree whose ledger was removed, the kept-out-of-profile placeholder report, the
  declined-seed advice), and section 6 added for the layout and the migration.

### This repository

- **The split, measured with `wc -l`:** the 854-line runbook became a 518-line
  `docs/PROTOCOLS.md` (9 lines of new header) and a 344-line `docs/RUNBOOK.md`. **Host rails and
  what they miss** stays in the runbook: H2 made it task-triggered, and every trigger is a task.
- **Pointers repointed:** `AGENTS.md` step 6, the binding-procedures paragraph, the
  leaked-credential boundary and five progressive-disclosure lines; the state file's two
  preamble pointers; `CONTRIBUTING.md`'s two. The runbook's entry paragraph now says the six
  headings it names bare are in `docs/PROTOCOLS.md`. `amh.conf` adds the file to `RULE_FILES`.
- **Guard:** `scripts/guards/doc-navigation.sh` looks for each heading in the file its pointer
  names and fails on a copy in the other file. One existing fixture changed: the heading-rename
  case renamed `## Acceptance ladder` in the runbook, where after the split it no longer is, so
  its edit would have done nothing; it now renames it in `docs/PROTOCOLS.md`. The
  heading-duplicate case is unchanged and now exercises the cross-file branch. Five new
  assertions; both guard mutations (no cross-file check; lookup pinned to the runbook) turned the
  suite red.
- **Not changed, and outside this repository:** the untracked `.orch/codex.sh rules` prompt tells
  its reviewer to read the Rule-review protocol in `docs/RUNBOOK.md`; it is the owner's local
  tooling, not part of AMH.

### The pass

One combined rule-review and adversarial pass, `.orch/codex.sh rules` with gpt-6-astra at `-e
high` on the whole uncommitted unit; it replayed the matcher and the layout helpers itself, but
its read-only sandbox could not create scratch directories, so it ran neither fixture suite. Two
P2 findings, both applied, and the corrected tree was not reviewed again:

- **The report could go quiet with work left.** The pointer matcher missed two pointer shapes the
  Upgrading notes list (the incident sentence and the runbook's doc-index row), and nothing
  checked the two configuration steps, while the notes call the migration done when the report
  is gone. The matcher now takes both shapes, the report checks `RULE_FILES` and the Codex
  reviewer agent, the reconstructed historical installs carry all four, and one new case leaves
  only those undone.
- **The layout check passed a runbook whose playbooks were emptied.** It counted the heading. It
  now compares the whole section with the expected one — a fresh install's, or for the folded
  light install the scaffold's plus the playbook its owner wrote — and a negative case empties it.
