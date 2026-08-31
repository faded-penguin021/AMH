# STATE — project state & session memory

> **Length guard.** Thresholds are in `amh.conf`; the rules for compressing this file are
> `docs/RUNBOOK.md` → **Working-memory compression**, and they bind whether or not you follow
> this pointer. Read them before any edit that takes this file over the soft cap.

## Project

The AMH meta-repository — source of truth for the Agentic Maintenance Harness and its
reference instance, which runs byte-identical copies of the scripts it ships. `AGENTS.md`
describes both and is read in full every session.
Adopted harness version: **AMH 10.4.0** — see `harness/VERSION`, the copy that counts.

## Current state

AMH **10.4.0** is prepared on this branch and untagged, carrying 10.3.1 with it; the newest tag
is `amh-v10.3.0`, and the PR-time check wants the number exactly one bump above it. This train
gave the destructive rail a data-plane tier and grew it by reported incidents, taught all six
character walkers that `\"` inside double quotes is not the closing quote, stopped the secret
scan, the integrity rung and the citation rung failing falsely on a Windows checkout, and made
the README adoption-first (**DC-024**, **DC-027**, **DC-028**, **DC-030**, **DC-031**, changelog
below). Everything
from 10.0.1 through 10.2.0 shipped inside the published `amh-v10.2.0` tag; **9.2.0 has a
changelog entry and no tag**, and nothing checks that every changelog version got one.

Ledger rows are immutable and are never edited in place, except the ` [cited]` marker, which is
metadata and is synced in place in both directions. A correction is a new row plus one appended
pointer — `Superseded by D-NNN.` when the row is replaced, `Corrected by D-NNN.` when one detail
went stale under a principle that stands; which verb is honest is the reviewer's half. The
append-only guard's sanctioned exceptions and draft-row rule are **DB-008** and **DB-013**, and
its HEAD baseline means it polices uncommitted work only (**DC-020**). The live volume is
`docs/LEDGER_C.md`, opened at the 8.0.0 rollover; `docs/LEDGER_B.md` is closed at **DB-040**.
`main`'s protection is repointed at `ladder`.

## Owner queue

> **Protected section.** Never delete it, and never silently drop items during compression.
> Items leave only when done, answered or triaged — then delete the item and record the outcome
> as a Changelog line or a ledger row. How to test an item before restating it, and why the
> final chat message must: `docs/RUNBOOK.md` → **Session discipline** 7.

**OPEN — tag and publish AMH 10.4.0 after merge.** The release commit is prepared on the PR
branch; tagging and publication are owner-only actions. Check: `git tag -l amh-v10.4.0` —
resolved when it prints `amh-v10.4.0`.

**OPEN — approved plan, not yet started: `docs/plans/2026-08-31-ci-sees-windows.md`.** Two units,
sequential, each shippable: (1) a committed binary file inside `CITATION_SCAN_PATHS` plus tool
versions printed by the portability job, (2) a CI job that runs the shipped rungs on a genuinely
CRLF adopter tree. The owner pre-approved the mandated fresh-context review pass for both units
(one blocking reviewer each, strongest tier, the one-pass bound unchanged) and asked for the
work to be paced around a usage window that resets ~22:30 UTC on 2026-08-31 — the plan carries
the schedule and the `send_later` waits. Checklist: [x] unit 1 [ ] unit 2 [x] PR #58 body
corrected [ ] plan archived or deleted.

**OPEN — the destructive rail sees no Windows shell, and two reported incidents live there.**
The owner supplied one (2026-08-29): an agent ran `cmd /c "rd /s /q \"D:\Coding\Mobile
App\surprise\""` twice, and a backslash-quote mismatch between the shell that built the line and
the one that parsed it left `\` as the target, which resolved to the root of `D:`; which layer
mis-parsed — outer shell, `cmd.exe`, or the C-runtime argv split — is unsettled and matters to
whoever builds the arm. It pairs with the Antigravity incident the **DC-027** search found,
`rmdir /s /q d:\` truncated at the drive root by an unquoted space. Neither is reachable here —
the verbs are Windows and `cmd /c "..."` hides its command as `bash -c` does — and a Windows arm
is the owner's call, since the harness targets bash. No check until a session builds it.

**OPEN — investigate the forge/API mutation surface as an escape around the local rails.** The
pre-push rail (DC-009) guards git-CLI pushes only, so an owner-reserved side effect through
`gh pr merge`, `gh release create`, `gh api -X POST` or a `curl`/`wget` mutation bypasses every
local rail. No longer only adversarial: the **DC-027** search turned up PocketOS, where an agent
found a token in an unrelated file and deleted a production volume AND its backups with one
`curl` GraphQL mutation. No check — nobody but a session actually crossing it settles this.

**OPEN — the `path-refs.sh` fix is PARKED UNREVIEWED on `session/readme-adoption`.** It touches
`scripts/guards/`, which is in `RULE_FILES`, so the rule-review protocol applies — but the
owner's pre-approval (**DC-033**) covers the two CI-sees-Windows units and this is neither. A
standing no-subagent instruction is a policy, not a capability, and the runbook says to ASK
before parking; nobody was awake, so the work is committed and pushed rather than held, which is
what parking requires. Authorising a pass is the owner's to grant. No check: it is a question.

**OPEN — `scripts/command-guard.sh` carries the same `printf | grep -q` shape, and there it
fails OPEN.** In `extract_command`'s no-python3 fallback, `printf '%s' "$payload" | grep -qE
'"tool_name"...' || return 0` reads a SUCCESSFUL match as a failure whenever the writer still had
bytes pending, standing the rail down on a Bash command it should have inspected; the
`printf | sed | head -1` beneath it is the same class. Not fixed here — a shipped rail takes
playbook 2 and its own pass. Check: `bash -c 'set -uo pipefail; { printf "a\n"; sleep 0.1;
printf "b\n"; } | grep -qxF a'; echo $?` prints 1 for a match that succeeded.

**OPEN — the grep half is CONFIRMED on Windows CI; the CRLF half and rung 3 are not.** The
adopter tree (Tideo-Auto-Brightness) confirmed **DC-030** on a real Git-for-Windows clone — four
`--guards-only` runs, 533 failures on 9.1.0 down to 2 — and the 2 survivors were the grep defect
**DC-031** fixed. That half is now settled by CI rather than by a shim: run 33432523501 prints
`grep (GNU grep) 3.0` on `portability (windows-latest)`, inside the <= 3.4 range where the
binary-file notice goes to STDOUT, and the citation rung passed there over the committed
`scripts/fixtures/binary-citation.bin` — so that leg is a genuine regression check for `-I`
rather than the input merely being present (**DC-033**). Two gaps remain and neither is touched
by it: a CRLF worktree still needs the `.gitattributes` seed, and CI's Windows job sets
`core.autocrlf false` before checkout so it has never seen one (Unit 2 below); and `verify.sh`
(rung 3), where the shipped fixture suite lives, has never run on Windows or macOS at all, both
portability legs being `--guards-only` as the adopter's runs were. Check: read `portability
(windows-latest)` on the newest run — resolved for the grep half while its printed grep stays
<= 3.4 and the citation rung passes; a runner image that moves grep to >= 3.5 silently retires
that confirmation, which is why the version is printed rather than assumed.

**OPEN — `amh.conf`'s `LEDGER_ROW_CHAR_CAP` comment calibrates against a figure the rows
falsify.** It states that the longest sentence-compliant row is ~1450 bytes, leaving 2000 "about
a quarter of headroom"; measured across the volumes, **DC-030** is 1962, **DC-027** 1866 and
**DC-011** 1858, so the headroom the comment describes does not exist. Pre-existing and found by
a review pass looking at something else. Code is ground truth, so the prose is what is wrong —
but it is legislation in a `RULE_FILES` file, so repairing it is a reviewed unit, not a typo fix.
Check: `awk` the volumes for the longest row under the sentence cap and compare with the comment.

## Decided non-items (don't re-litigate without new evidence)

A pointer index, not an argument: **read the cited row before reopening any of these**, because
the row is where the reasoning that settled it lives and this line is deliberately too short to
re-litigate from.

- **Pre-3.0.0 refusals:** rendered or templated shipped scripts, assurance-level configuration,
  a packaged CLI, broad doc-fact/link guards, section-granular `RULE_FILES`, machine-consumed
  self-attestations, a `git log` rail under branch-train, failing ledger caps, hook-invocation
  detection, a shipped config-schema guard, and a `BRANCH_PREFIX` push check (**D-002**,
  **D-010**, **D-014**, **D-023**, **DA-001**, **DA-003**, **DA-022**).
- **RFC refusals:** runtime capability/profile/probe machinery and a second setup extension
  (**DA-024**); run receipts, transport, CI artifact and status tool (**DA-025**); and five
  provenance-defective scenarios plus their YAML/oracle/report machinery (**DA-026**).
- **Later refusals:** the top-decile/inverted-gradient warning (**DB-040**, with **DC-003** the
  adopted two-unit alternative); a constitution byte cap (**DB-038**); a Python-write advisory
  (**DC-007**); the two 2026-08-10 review proposals (**DB-024**); any guard that opens a file
  to classify it (**DB-027**); a configurable ledger-id prefix, which relocates a domain-constant
  collision into the adopter's taxonomy rather than removing it (**DC-015**); and making ledger
  immutability hold across commits, which needs a history rail no incident has earned
  (**DC-020**).

## Changelog

One line per shipped change or completed unit (newest first). Details live in the cited ledger
rows — this section is a pointer index, not a narrative.

- 2026-08-31 — **A guard reported a file that exists as missing, and the cut-short listing was
  its own pipeline rather than git's.** `path-refs.sh` looked up bare names with `printf |
  grep -qxF`: grep exits at the first match, a pending write takes EPIPE, and `pipefail` turned
  the successful match into a failure — green on Linux, red on `macos-latest` naming `AGENTS.md`.
  Fixed with a here-string and fixtured by padding the listing past the pipe buffer, which is
  what makes the defect reproducible on Linux at all. Closes that open question (**DC-034**).
- 2026-08-31 — **CI now runs the citation rung against the input that breaks it, not merely on
  the platform.** `scripts/fixtures/binary-citation.bin` is a committed binary file inside
  `CITATION_SCAN_PATHS` — outside the shipped set, skipped by the secret scan and
  `placeholder-integrity.sh`, carrying an id-shaped token that makes the rung fail by name if it
  ever stops being binary, though nothing enforces its presence. It moves no verdict on grep
  >= 3.5 and is not a regression check for `-I` — that is the grep shim in the shipped fixture
  suite, which runs on Linux only; what it buys is that any runner shipping an older GNU grep
  reports the defect. The portability job also prints `bash`/`grep`/`sed`/`git` versions on both
  legs, printed and never asserted (**DC-033**); the queue item above carries what the first run
  printed.
- 2026-08-31 — **The adopter tree confirmed the CRLF fix on real Windows, and the 2 failures it
  had left were a second tool assumption.** GNU grep prints its binary-file notice on stdout
  through 3.4 (Git for Windows ships 3.0) and on stderr from 3.5, so the citation rung captured
  it as a token and failed naming two fonts; `-I` closes it there and in
  `placeholder-integrity.sh`, demonstrated by a grep shim as **DC-030** used a sed shim. The
  upgrade notes now say to copy every script the manifest names — not only the changed ones,
  which left `session-start.sh` stale and the integrity rung red — and state the CRLF secret
  scan's doubled CPU as designed cost rather than leaving it to be filed as a regression
  (**DC-031**).
- 2026-08-31 — **Two rungs stopped failing falsely on a Windows checkout.** A CRLF worktree made
  the secret scan report a credential in every text file and the integrity rung report five
  present scripts as deleted; the scan now subtracts a `--baseline` pass and refuses a file that
  baseline cannot reproduce, the manifest parse strips the CR, and a `.gitattributes` seed
  carries the halves no rung can reach (**DC-030**).
- 2026-08-25 through 2026-08-30 — **The unreleased 10.3.0–10.4.0 train, folded.** The
  destructive rail gained a data-plane tier and then grew it by reported incidents only; an
  escaped quote stopped voiding the rails behind it; `path-refs.sh` stopped reporting a listing
  it could not make as a verdict; the release number became a PR-time check against the latest
  tag; the seed ledger preamble stopped contradicting `amh.conf.example`; ledger rows stopped
  claiming releases they only drafted, with the four `Shipped as` rows left unpointered by the
  owner; and the README became adoption-first (**DC-020**–**DC-030**).
- 2026-08-26 — **The 10.1.0–10.2.0 train, published as `amh-v10.2.0`.** CI stopped running the
  whole matrix twice per commit; the command rail learned to read `env` as POSIX defines it,
  closing a false positive and the `env FOO=1` hole together; the push rail stopped policing
  branch names and started policing the push; the bootstrap stopped leaving the guard's
  `.resumed` ledger behind; and the adopter-facing citation-collision note shipped
  (**DC-016**–**DC-019**, **DB-030**).
- 2026-08-25 — **The 9.2.0–10.0.0 train, published as `amh-v10.0.0`.** Working memory stopped
  paying for its own rules; ledger rows became immutable with correction by pointer; a
  citation-guard collision was reproduced and found to have no clean fix, and the owner
  confirmed the MAJOR (**DB-022**–**DB-029**, **DC-011**, **DC-015**).
- 2026-07-25 through 2026-08-20 — **Everything through 9.1.0, folded:** founding through portable
  rails, the constitution rewrite, the 8.0.0–9.0.0 train, and git-native pre-push enforcement.
  The ledger volumes carry the detail; this line carries the dates.
