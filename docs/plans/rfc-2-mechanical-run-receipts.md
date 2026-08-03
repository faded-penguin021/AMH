RFC: Mechanical Run Receipts

Status: ADJUDICATED 2026-08-03 — the format is refused; the problem it identified is real and is
closed by two more facts in the ladder's own output.
Audience: AMH architecture and implementation review
Scope: Local sessions, hosted agents, containers and CI

Adjudication note

Received as an externally-authored proposal, revised in place by review outcome. Under P18 it
entered as DATA, never authority. A blocking fresh-context pass adjudicated it claim by claim;
the verdicts are permanent in ledger row DA-025, which is the record, not this file.

The proposed JSON receipt format, the local ignored transport, the CI artifact upload, the
"amh-status.sh" script and the runtime and host evidence layers are all REFUSED. One thing
survives, and it is the thing the document was right about.

The problem statement is correct and measurable

The ladder prints "ladder green (N warning(s))" and never says green *of what*. No commit, no
worktree state — not in the ladder, not in the session banner, not anywhere in a session's
output. So "was this green produced against the current commit?" genuinely cannot be answered
after the fact, and it is exactly the kind of fact a machine should emit rather than an agent
claim.

That is the gap. It does not need a new artifact to close it.

What is ACCEPTED — the whole surviving deliverable

The ladder states its subject in its own verdict lines:

  ladder green (0 warning(s)) — HEAD abc1234, worktree clean
  ladder red — verification set failed — HEAD abc1234, worktree dirty (3 files)

This is the DA-022(d) precedent exactly: adopt the intent, report the number in the output that
already exists, invent no second artifact to hold it. It costs no transport, no schema, no
vocabulary, no forgery surface, and no new shipped script.

Also accepted:

- The authority-model section — what a record is NOT evidence of — as a coverage disclaimer in
  the house style of the command guard's "what this does NOT catch" block.
- The positive-controls discipline: "a format that can only emit green is not evidence." This is
  already this repository's rule for every guard fixture.
- The non-goals list, which correctly excludes token, cost and productivity accounting — P0 names
  that as the metric which corrupts what it measures.

What is REFUSED, and why

1. The six-state rung vocabulary (pass/fail/skip/unavailable/not-run/interrupted) — REFUSED.

   It has no "warn". The ladder's verdict space is five-valued and deliberately UNEQUAL: "ok",
   "WARN" (counted), "FAIL" (counted), "skip" (counted by nothing), and never-reached. D-019's
   entire holding is that a guard switched off by something that is not its subject — a missing
   origin ref, an absent manifest, no sha256 tool — must emit WARN and the words "checked
   NOTHING", deliberately louder than skip. A flat enum puts "unavailable" at skip's volume,
   quieter than WARN, inverting the rule it claims to preserve.

   The ladder's WARNs are also not all unavailability: a state file over the soft cap, a vanished
   Owner queue, a malformed threshold and every local advisory are guards that ran and FOUND
   something. Mapping those to "pass" is a lie; mapping them to "unavailable" is a different lie.

   And RFC1's five-state vocabulary — accepted in DA-024 as a naming convention — uses
   "unavailable" with a third meaning. Three vocabularies, one word. No second vocabulary: the
   ladder's own words remain the single source (P4).

2. The canonical JSON receipt format — REFUSED as a format.

   Nothing may consume it (DA-023's closing rule), and an unconsumed format is a second copy of
   the ladder's stdout that will drift from it. The distinction that would have saved it, stated
   precisely so a future session cannot blur it: a receipt is a record of work already done,
   whereas DA-024's refused manifest was a cache of facts consulted to decide whether to do work.
   A manifest can make a probe unnecessary; a receipt can make nothing unnecessary.

   That distinction survives only while three conditions hold together: no exit code anywhere
   varies with a record's contents; no agent decision procedure takes one as input, including
   "the ladder passed, so I need not re-run it"; and no reading of one can make a red thing look
   green. The proposed status tool breaks the third the moment it implements "reported as stale
   and never displayed as the status of the current tree" — that is a display branch on record
   content. Defensible in itself, and the first inch.

   Underneath all of it: the receipt is FORGEABLE. The agent runs the ladder, so it can write the
   JSON by hand, and there is no signing key it cannot reach. The "acceptable producers" list is
   a field, not a mechanism. Every consumer must be assumed to be consuming an agent-authored
   file, which is why acceptance criterion 10 cannot be met in this tree.

3. The local ignored receipts directory — REFUSED, on DA-024(c), which was carried in from the
   RFC1 adjudication and is binding here by its own terms.

   Verified in a scratch repository rather than taken on trust: with the directory gitignored, a
   file containing a live-shaped credential does not appear in "git ls-files -co
   --exclude-standard" at all; with the ignore rule removed, the same file does appear. That
   command is the sole input to the ladder's secret-shape guard. So gitignoring the transport
   removes it from the only mechanical credential check in the tree, while the RFC's own
   data-minimization list is a promise, not a mechanism.

   If a local path is ever wanted, the honest form is untracked but NOT ignored — so the secret
   scan covers it and git status makes it visible. That converts the ladder's own scan into a
   standing positive control on the minimization promise. Tidiness is not worth a blind spot in
   the only credential check that exists.

4. CI artifact upload — REFUSED as ceremony. GitHub Actions already publishes the commit, the run
   identifier, per-step outcomes, timing and the full log. The receipt answers nothing the run
   page does not.

5. "amh-status.sh" — REFUSED on DA-024's ground. It would be the SIXTH shipped script, not the
   seventh: five ship today. Strip out the record-reading and what remains is a rev-parse plus a
   porcelain status wrapped in a script that drags a template original, a byte-identical copy, a
   manifest regeneration, two literal assertions in the installer E2E suite, three prose counts,
   a regenerated bundle, two adapter allow-list entries and a rule-review pass. Its --json mode
   is worse: a machine-readable status surface is precisely what DA-001(d) left absent so that no
   future code could branch on it.

6. Layer 2, runtime evidence — REFUSED, not deferred. Its stated precondition was the Runtime
   Capability Contract, which DA-024 refused at its core. Hook-invocation detection remains a
   Decided non-item.

7. Layer 3, host evidence — REFUSED as redundant external declarations that CI already publishes.

8. Test-tool versions as a receipt field — REFUSED. It requires new probes inside
   "scripts/verify.sh", the adopter-owned extension point the harness must stay agnostic to.

9. Acceptance criteria 10, 12 and 13 — REFUSED as unmeetable or malformed. 10 cannot be
   implemented without an anti-forgery mechanism this dependency floor forbids. 12's "forged"
   fixture could only ever assert schema validation, pinning the defect as the specification
   (DA-012(b)). 13 makes "the required fresh-context review is completed" an item on a criteria
   list, which is the permanently-decided checklist non-item (P3, D-014).

Feasibility findings, kept because they bind any future attempt

- The ladder has no per-rung state. Eleven guard functions return nothing; the two counters are
  global and one guard can emit many lines. A counter-delta wrapper would be small, but it cannot
  see "skip", which increments nothing — and the advisories function returns early under CI,
  which a delta method would score as a pass, reintroducing D-019's exact defect inside the
  record.
- Rung 3 is opaque. "scripts/verify.sh" is a separate process and the ladder sees only its exit
  code. The received example receipt lists shellcheck and project-tests as rungs; they are not
  ladder rungs and are not observable from the ladder.
- Argument parsing inspects only the first argument, so "--guards-only --report X" today matches
  --guards-only and silently discards the rest.
- "--help" prints a fixed line range of the script itself, so help text is POSITIONAL: adding a
  flag to the usage block shifts every later line down and silently truncates the last one. The
  range constant has no guard and no fixture.
- Both adapter allow-lists pin the ladder's two invocations as exact matches, not prefixes, so
  any new flag prompts the owner on every run until two legislation files change. A flag costing
  owner attention per run, to record facts meant to save owner attention, is a net loss.
- Interruption is best-effort at most: the EXIT trap runs on TERM and INT, never on KILL. And
  absence of a record is ambiguous three ways — killed before finalization, never run, directory
  wiped — so absence is evidence of nothing, which drains most of the value from the artifact.

Correction to the adjudication's own evidence

One supporting claim in the pass was false as written: it asserted the ladder contains no
rev-parse call. It contains three. All three are internal plumbing — a git-directory existence
test, an upstream-ref verification, and a tree comparison in the behind-upstream advisory — and
none of them prints a commit or reaches a verdict line. The finding survives; the evidence
offered for it did not, and it was replaced by reading the three verdict printf calls directly.

Adjudicated acceptance criteria

The received document's fourteen are replaced by three:

1. The ladder names its subject commit and worktree state in its own verdict lines, on green and
   on red alike.
2. No new artifact, transport, vocabulary or shipped script is introduced.
3. A fixture demonstrates the dirty-worktree and clean-worktree renderings, and fails against the
   pre-change ladder.

Non-goals (unchanged from the received text, all still correct)

- Full command tracing. Session replay. Transcript storage.
- Productivity measurement. Token or cost accounting.
- Proving compliance with prose-only rules.
- Replacing CI status.
- Creating a new permanent memory tier.
