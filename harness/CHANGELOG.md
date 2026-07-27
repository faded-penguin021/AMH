# Harness changelog

Versions are `MAJOR.MINOR.PATCH`, and the number is a promise about **your** workload as an
adopter, not about how much prose moved:

- **MAJOR** — a binding rule changed. Adopting repos must act; the Upgrading notes say how.
- **MINOR** — additive. New principles, guards or templates you may take or leave.
- **PATCH** — clarifications and fixes with no action required.

Each entry's **Upgrading** section is the complete list of what an adopter must do to move
from the previous version. Scripts are copied; seeds are yours, so seed changes appear here
as hand-applied notes. Full procedure: [`docs/UPGRADING.md`](../docs/UPGRADING.md).

## 1.8.0 — 2026-07-25

The first release packaged as a repository. Versions up to 1.8 existed only as a single
prose document passed around by hand; their history is not reconstructed here.

One rule's *wording* changed (P3, below); nothing about what the rules require of an adopter
did. What changed otherwise is the harness's form:

- The scaffolds are now real files under `harness/templates/`, not fenced blocks to be
  extracted from prose by hand.
- The shipped scripts are **parameter-free** and read `amh.conf` at runtime, instead of
  being templates you fill in. This is what makes later upgrades a copy rather than a merge.
- `scripts/ladder.sh` gained two extension points — `scripts/guards/*.sh` and
  `scripts/verify.sh` — so it never needs a local edit.
- Reference implementations now exist and are executed: the ladder and its guards, the
  redaction filter, the pre-execution command guard, the session bootstrap, and a fixture
  suite for the guards themselves.
- `harness/dist/AMH.md` is generated from the same files an adopter copies, so the document
  and the artifacts cannot disagree.
- **P3 reworded** to ban attestation-based *machinery* rather than attestation-shaped prose.
  The 1.x document said "never invent self-reported attestations" while P12 mandated writing
  a review verdict in the commit body — a contradiction carried by every instantiation. The
  rule is now that nothing downstream may consume a self-report; a commit-body sentence a
  human reads and may disbelieve is fine. Same prohibition, stated where the harm is.

### Upgrading

- **Nothing to change in `amh.conf`.** The shipped scripts used to carry `D-NNN` comments
  citing the *harness's* ledger, which failed your citation guard on rows your ledger cannot
  contain. They no longer cite anything — the references are written in a form the guard does
  not read as a citation — so no exclusion is needed and no config edit is asked of you.

- **Check that `scripts/verify.sh` is executable** (`chmod 755 scripts/verify.sh`). It is the
  one file whose execute bit is load-bearing: the ladder refuses to run a verification set it
  cannot execute, and a copy that arrived 0644 — an archive extraction, a copy out of a fenced
  block, `core.fileMode=false` — makes your first full run red for a reason that has nothing to
  do with your repo. Every other shipped script is now invoked through `bash`, so its mode
  decides nothing. Only worth checking if you placed the file by hand; the init script installs
  it 755 and repairs the bit on a re-run.

From a hand-instantiated copy of the 1.x document: there is no mechanical path, because the
scripts described in the old document were specifications rather than code. Treat this as a
fresh adoption — run the harness init script into a scratch directory, then port your existing
STATE, LEDGER and RUNBOOK content into the new layout by hand. Your ledger rows and their
numbering carry over unchanged; nothing in this release renumbers or reformats them.

Set `AMH_VERSION=1.8.0` in `amh.conf` and record the same version in your constitution.

If your constitution or runbook carries the old P3 sentence, reword it by hand — seeds are
yours and never re-synced. Nothing you must *do* changes; the point of the reword is that
your commit-body verdicts and verification disclosures stop contradicting the rule above
them. If any gate in your repo consumes such a sentence, that gate is the thing to delete.
