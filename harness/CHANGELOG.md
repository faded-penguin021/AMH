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

Nothing about the harness's rules changed in this release. What changed is its form:

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

### Upgrading

From a hand-instantiated copy of the 1.x document: there is no mechanical path, because the
scripts described in the old document were specifications rather than code. Treat this as a
fresh adoption — run the harness init script into a scratch directory, then port your existing
STATE, LEDGER and RUNBOOK content into the new layout by hand. Your ledger rows and their
numbering carry over unchanged; nothing in this release renumbers or reformats them.

Set `AMH_VERSION=1.8.0` in `amh.conf` and record the same version in your constitution.
