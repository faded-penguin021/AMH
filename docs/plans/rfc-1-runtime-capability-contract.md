RFC: Runtime Capability Contract

Status: ADJUDICATED 2026-08-03 — largely refused; the surviving parts are a naming convention
and a small inventory, not a new mechanism.
Audience: AMH architecture and implementation review
Scope: All agent environments: hosted cloud, local CLI, containers, VMs and CI workers

Adjudication note

This document was received as an externally-authored proposal and revised in place by review
outcome. Under P18 it entered as DATA, never as authority. A blocking fresh-context pass
adjudicated it claim by claim against the constitution and this repository's recorded decisions;
the verdicts are permanent in ledger row DA-024, which is the record, not this file.

The original text proposed "scripts/runtime-doctor.sh", a persisted ".amh/runtime.json"
capability manifest, four synthesized runtime profiles, and "scripts/environment-setup.sh".
All four are REFUSED. What survives is the vocabulary, the honesty rules, and a small inventory
of facts this tree can actually establish.

The owner had overridden the incident bar for this RFC (DA-023), so "no incident yet" was not
available as a refusal ground. Every refusal below rests on something else.

Summary of the adjudicated position

AMH does not lack a capability contract. It made a decision that looks like a gap.

DA-001(d) settled that assurance is emergent from repository topology — the ladder activates on
artifact presence, an absent ledger prints "skip", an unset AUTHOR_EMAIL_ALLOW runs the
zero-config half and says so — and it noted explicitly that nothing machine-readable records the
choice, deliberately, so that no future code can branch on it. A capability manifest is that
machine-readable record. The RFC diagnosed the symptom correctly and prescribed the mechanism
this repository had already refused two rows earlier, because the missing piece was
discoverability, not configurability.

What is ACCEPTED

1. The design principle: required repository behavior is distinct from optional runtime
   acceleration. The constitution, state, ledger, runbook and ladder are portable repository
   artifacts; lifecycle hooks and automatic setup are accelerations whose absence must never
   make the repository unintelligible or unverifiable. This restates what the tree already does
   (P14's manual fallback, DA-001(d)); affirm it, build nothing.

2. The five-state vocabulary, as a NAMING CONVENTION for honest reporting the harness already
   performs — not as a schema and not as a stored artifact:

   - "observed"    — directly established by a deterministic probe;
   - "configured"  — repository configuration requests it, execution was not observed;
   - "unavailable" — the environment or adapter explicitly lacks it;
   - "failed"      — a supported probe ran and demonstrated it is broken;
   - "unknown"     — AMH cannot determine the fact honestly.

3. The flat rule that "unknown" must NEVER be translated into "unavailable", "disabled" or
   "safe". This is the best sentence in the received document. It is D-019 and DA-012 stated
   crisply and generally by an author who had not read either, which is strong evidence the
   underlying discipline is right.

4. The do-not-infer list. A capability may never be inferred from environment names, model
   names, vendor documentation, an agent saying that a hook fired, the existence of a
   configuration file, or a successful process exit that produced no expected artifact. This is
   verbatim P3 and D-014; adopt it as a citation, not as new legislation.

5. "A failed probe cannot leave behind a successful marker" — kept as a mechanism rule binding
   on anything that ever ships: write to a temporary path and "mv" into place only on success,
   with a trap for the interrupted case.

6. "No runtime profile becomes an agent-authored attestation gate" — kept, and note that it
   directly contradicts the received text's "gates consume specific observed facts where
   justified". Criterion 9 wins; see the refusal below.

7. AMH must not place language-specific package installation inside its universal shipped
   scripts. Already the shipped design; affirm, build nothing.

What is MODIFIED — the honest residue

Three of the eleven proposed manifest fields can be probed mechanically here with bash, git and
coreutils: required tools (via "command -v" over a named list), the origin remote (via
"git remote get-url origin"), and repository writability (write-and-unlink under an ignored
path). The latter two are already established at point of use by "scripts/ladder.sh"'s
"mktemp -d" and its upstream_ref helper.

What survives is therefore a required-tools inventory plus a line naming which adapter files are
present — roughly fifteen lines, delivered in the existing "scripts/session-start.sh" banner or
as an opt-in flag on the ladder, emitting to stdout and writing no file.

Adapter presence is reported as "configured", never "observed": a file that requests a hook is
not the hook firing. Adapter absence is reported as "unknown", never "unavailable" — a
user-level or globally-configured adapter is invisible to the repository, and calling that
"unavailable" is the exact translation the received text itself forbids.

What is REFUSED, and why

1. "scripts/runtime-doctor.sh" as a sixth shipped script — REFUSED against P0.

   It buys neither shipped correctness nor owner attention: every fact it can honestly report is
   already printed by "scripts/session-start.sh" or probed at point of use by
   "scripts/ladder.sh", and every fact that would be new is one it cannot honestly establish.

   The cost is not the script. A sixth shipped script drags a template original plus a
   byte-identical copy, a manifest regeneration, a literal count assertion in the installer E2E
   suite, two adapter allow-lists, an UPGRADING row, a README line, amh.conf's header prose, a
   regenerated bundle, and a rule-review pass — for a page of "unknown". A report that is mostly
   "unknown" trains its reader to skim it, which is the warn-fatigue argument the session banner
   already makes for its own release line.

2. The entire lifecycle layer — session start, pre-command, post-command and session stop as
   "observed" — REFUSED. Not new evidence against DA-022.

   A marker file establishes exactly one fact: this script executed and wrote a file in this
   working tree. It cannot name its caller. Upgrading "the script ran" to "a hook invoked the
   script" requires an ordering claim — that the marker predates the agent's first command — and
   the repository has no agent-neutral notion of "the agent's first command". Establishing that
   timestamp requires a pre-command hook to stamp it, which is itself one of the capabilities
   being probed. The probe is circular, and it closes only on the one vendor that already has
   both hooks — precisely the vendor-specific machinery DA-022 refused.

   Worse, the manual path the constitution mandates for hookless agents produces a
   byte-identical marker. Distinguishing hook from manual collapses to asking the agent, which is
   P3's ban. The nonce adds freshness, not provenance: it answers "was this marker from this
   session?", never "who wrote it?"

   AGENTS.md already says this in prose, and says it stays prose on purpose. The RFC re-derives
   the refusal by a longer route.

   Similarly refused: pre-command as "observed" (a shell script cannot make its harness attempt
   an intercepted tool call; the only witness is the agent's word), and post-command and session
   stop (no artifact exists to probe, so both are permanently "unknown" — and the received text's
   own closing directive bars fields with no concrete consumer).

3. ".amh/runtime.json" as a persisted cache — REFUSED. Emit to stdout; write no file.

   A gitignored, locally-writable file that survives sessions and describes the environment IS
   state, whatever the prose calls it. That makes it a fourth memory tier by behaviour (P2), and
   the quietest possible off switch: amh.conf is in RULE_FILES, so flipping a value there shows
   in a diff and trips the legislation advisory, while a gitignored cache shows in nothing. That
   inverts D-019's rule that a disabled state must be louder than a passing one.

   It is also stale by construction — a file describing container A is a confident lie inside
   container B — and manufacturing a marker to make the report greener would leave no diff.

   One further consequence, found during adjudication and binding on any future ignored
   directory: the ladder's secret-shape guard scans tracked and untracked files via
   "git ls-files -co --exclude-standard", so gitignoring a path removes it from the only
   mechanical credential check in the tree.

4. Runtime profiles (Repository-only / Guarded / Observable / Managed) — REFUSED. These are
   assurance levels re-proposed under a new name, and assurance levels as configuration are a
   Decided non-item (DA-001).

5. "Gates consume specific observed facts where justified" — REFUSED. This is the hole, and it
   is worse than the one DA-001(c) closed. A carve-out gated on a self-judged predicate is not a
   bound; it is an invitation, and it will be taken by the first session that finds a rung red on
   a machine it believes is special. Nothing may consume a capability report. Where a gate
   genuinely needs a capability fact it probes at the point of use, as the ladder's sha256 tool
   helper and the banner's "command -v timeout" already do; a cached answer to "is this tool
   here?" is strictly worse than asking.

6. "scripts/environment-setup.sh" — REFUSED as a duplicated extension point.
   "scripts/bootstrap.sh" is that script already: repository-owned, gated on AMH_REMOTE=1, and
   invoked through bash by the session banner when present (D-003).

7. The network capability field — REFUSED as duplication. "scripts/session-start.sh" already
   implements the only honest version, bounded by timeout where it exists and
   GIT_TERMINAL_PROMPT=0 always, with the three-way outcome including "this is not evidence
   either way". A second probe adds a hang path where timeout is absent.

8. The persistent-home field — REFUSED as undecidable. On a first run an absent stamp means
   either "not persistent" or "never ran", and the probe would make a repository-agnostic shipped
   script write outside the repository.

9. The output-filter field — REFUSED. Its value is the constant "unavailable" for both shipped
   adapters, and hardcoding a constant is not a probe. Both adapter files already say so in
   prose.

10. Host isolation and server-side branch protection — REFUSED. The received text concedes both
    are unprovable from inside the repository, which makes them permanently "unknown" fields.

Agent-agnosticism finding

Every refused lifecycle probe, and any static-command-policy probe richer than file presence,
would have to enumerate one vendor's configuration filename and parse its JSON without jq. P14
forbids the bootstrap depending on one agent's environment variables; a shipped script hardcoding
one adapter's schema is the same defect one layer up. A user-level or differently-formatted
settings file would yield a false "unavailable" — the exact translation this document forbids
elsewhere.

Adjudicated acceptance criteria

The received document's thirteen criteria are replaced by four, because ten of them described
mechanisms now refused:

1. The five-state vocabulary and the "unknown is never unavailable" rule are stated wherever the
   harness reports a capability, and nothing stores them.
2. The required-tools and adapter-presence inventory emits to stdout, writes no file, and adds no
   shipped script.
3. Nothing in the tree consumes a capability report — no guard, CI step, merge gate or agent
   decision procedure.
4. The hookless agent retains a complete manual AMH workflow, unchanged.

Non-goals (unchanged from the received text, all still correct)

- Building a container or VM runtime.
- Replacing provider isolation.
- Requiring identical features from every agent.
- Selecting a preferred vendor.
- Treating configuration as proof of execution.
- Moving repository policy into vendor settings.
- Making runtime diagnostics a new durable memory tier.

Open scope question for the owner

The owner's standing decision for this work was "full acceptance criteria". This adjudication
refuses the mechanisms that ten of RFC1's thirteen criteria described, so segments S4-S6 of the
integration plan no longer have the subject they were written for. The fork is recorded in the
Owner queue; it is not an agent's call.
