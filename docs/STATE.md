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
scan and the integrity rung failing falsely on a CRLF checkout, and made the README
adoption-first (**DC-024**, **DC-027**, **DC-028**, **DC-030**, changelog below). Everything
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

**OPEN — `path-refs.sh` may still report a false failure if a listing comes back short.** One
full ladder run failed it on `` `session-start.sh` `` — a file that exists — and it did not
reproduce on two clean runs; the guard now refuses a listing that failed or came back empty
rather than reporting either as a verdict (**DC-029**). Still uncovered: a listing git completed,
reported success for, and cut short anyway. No check; only a recurrence settles which it was.

**OPEN — the Windows CRLF report is fixed here but unconfirmed there.** **DC-030** was fixed
against a `sed` shim that models MSYS2, on Linux; nobody has run the ladder on Windows since. The
adopter tree that filed it (Tideo-Auto-Brightness) is where confirmation has to come from, and a
CRLF worktree also needs the new `.gitattributes` — the scripts alone do not make it green.
Check: `bash scripts/ladder.sh --guards-only` on a stock Git-for-Windows clone.

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
