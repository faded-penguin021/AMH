# Harness changelog

Versions are `MAJOR.MINOR.PATCH`, and the number is a promise about **your** workload as an
adopter, not about how much prose moved:

- **MAJOR** — a binding rule changed. Adopting repos must act; the Upgrading notes say how.
- **MINOR** — additive. New principles, guards or templates you may take or leave.
- **PATCH** — clarifications and fixes with no action required.

Each entry's **Upgrading** section is the complete list of what an adopter must do to move
from the previous version. Scripts are copied; seeds are yours, so seed changes appear here
as hand-applied notes. Full procedure: [`docs/UPGRADING.md`](../docs/UPGRADING.md).

## 2.0.0 — 2026-07-27

Adoption becomes agent work, installs become sized, and the shipped scripts start carrying
proof that they are still the bytes we shipped.

**Two things here require action from an existing adopter**, which is what makes this a MAJOR:
the archive tier's rule changed and the old wording permitted something the new wording
forbids; and the new integrity rung turns a deliberate local patch on a shipped script — a
state `docs/UPGRADING.md` documents as legitimate — from silent into red, until you take the
documented step. The rest is additive, and ignoring it costs you nothing.

- **BREAKING — the archive's intake was wrong for the harness's whole life.** P2's table said
  the archive is "consult, never extend", which described it as read-only while saying nothing
  about what may enter it, and the surrounding prose told you to put "spent narrative in cold
  storage". Both are now corrected: a compression pass **folds** working memory in place — the
  durable content leaves as a ledger row and a changelog line points at it — and the archive
  receives only documents retired **whole**, never the residue of a compression pass and never
  another tier's live file. Retiring `docs/STATE.md` into the archive and starting a fresh one
  satisfied every word of the old text while evading the cap that forces the fold and moving
  the Owner queue out of the one file the protocol guarantees gets read.
- **`amh-init.sh --profile light|standard|full`**, defaulting to `light`. The profile selects
  which seed prose is installed and nothing else: the shipped scripts are byte-identical at
  every profile, no profile disables a guard, and nothing a script reads records the choice —
  the ladder's rungs activate on artifact presence, so a smaller install degrades to a green
  ladder that names what it did not check. (The profile name is written once into
  `AMH-ADOPT.md`, for the agent reading it; that file is prose, it is yours, and it is deleted
  when adoption finishes. Nothing machine-readable holds the choice, so nothing can branch on
  it.) Escalating is a re-run with a larger profile.
- **`AMH-ADOPT.md`, an adoption brief addressed to your coding agent**, written on a fresh
  install only. It has the agent ask you which profile you want, fill the `{{PLACEHOLDER}}`
  slots from your repository, write your real commands into `scripts/verify.sh`, drive the
  ladder green, and delete the brief. It carries no checklist and nothing consumes a word of
  it: acceptance is the ladder.
- **A shipped-script integrity rung.** `scripts/MANIFEST.sha256` is generated at release and
  installed beside the scripts it hashes; the ladder compares the two and fails on a mismatch,
  naming the file and the three places a local change actually belongs. A missing manifest
  **warns** on every run rather than failing — deleting it is also the supported way to live
  with a deliberate local patch, so it must not be the quietest line the ladder prints. An
  empty manifest, or one not covering `scripts/ladder.sh`, fails.
- **`docs/history/` ships as a seed** for the first time, under `full`. P2 has described four
  memory tiers since 1.x while the templates carried three, so no adopter has ever received
  the archive tier.
- **The session banner names what the default branch's log is not**, under a `branch-train`
  merge mode only: history there is squashed, so the memory tiers are the record.
- `amh.conf.example` adds itself to `RULE_FILES`, with the reasoning in the file: a scope list
  that excludes the file defining the scope list is not a scope list.

### Upgrading

This is the complete list for 1.8.0 → 2.0.0.

- **Stop relocating compressed narrative into `docs/history/`, and never rotate your state
  file into it.** This is the binding change, and **nothing enforces it** — no guard reads the
  archive, and none is proposed, because "has this document stopped being live?" is exactly the
  self-assessment the harness refuses to build machinery on. If you have already moved
  compression residue there, you do not have to move it back: leave it, and fold in place from
  now on. If you have rotated a state file there, move the Owner queue back into the live
  `docs/STATE.md` — that is the part that actually broke. The 1.x seed constitution never
  carried P2's memory-tier table, so there is probably nothing in your tree to reword; if you
  copied the table out of the bundle by hand, that copy is the one to fix.
- **Copy the whole shipped-scripts directory, not just `*.sh`:**
  `cp /path/to/AMH/harness/templates/scripts/* scripts/`. `MANIFEST.sha256` is new and must
  land beside the scripts, or your ladder reports every one of them as locally edited. If you
  skip it entirely the rung warns on every run instead — true, and deliberately not quiet.
- **If you have edited a shipped script, that rung will now say so.** Undo the edit and move it
  to `amh.conf`, a `scripts/guards/*.sh`, or `scripts/verify.sh`. If you are keeping the patch
  on purpose, delete `scripts/MANIFEST.sha256` and accept the warning — that is the supported
  way to hold a local patch, and `docs/UPGRADING.md` states exactly what it does and does not
  bound.
- **Add `amh.conf` to your own `RULE_FILES`.** `amh.conf` is yours forever, so this one is a
  hand-applied edit; without it, an agent can raise `STATE_HARD_KB` or blank `POISON_TOKENS`
  without tripping the legislation tripwire.
- **Nothing to do for `--profile` or `AMH-ADOPT.md`.** The profile decides a fresh install's
  seed prose; a bare `amh-init.sh <target>` re-run against an adopted tree keeps every file you
  already have whatever profile it names. The brief is issued on fresh installs only and is
  never re-issued. If you want the new archive seed, `--profile full` adds it.
- **Optional seed wording**, if you keep your runbook close to the seed: its self-adaptation
  paragraph now says "consult the ledger — and `docs/history/` if this repo has an archive",
  because not every profile installs one.
- **`MERGE_MODE` in `amh.conf`** gates the new banner line. Every tree instantiated by
  `amh-init.sh` already has the key; if you wrote your `amh.conf` by hand and it is absent, the
  script defaults it and simply prints nothing extra.
- Set `AMH_VERSION=2.0.0` in `amh.conf` and record the same version in your constitution.

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
