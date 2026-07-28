# Placeholders

Every `{{NAME}}` appearing anywhere under `harness/templates/` must be listed here, and
`scripts/guards/placeholder-integrity.sh` fails the ladder if one is not. The point is
narrow: an undocumented placeholder is one an adopter ships to production unfilled.

Two kinds:

- **Substituted at init** — the harness init script fills these in automatically from the
  answers it collects. They appear in `configs/` and `amh.conf.example`, which are JSON,
  YAML and shell-config files that cannot read `amh.conf` at runtime.
- **Filled in by you** — everything in `seed/`. These are prose scaffolds; no tool can guess
  what your repo's invariants are. Search for `{{` after instantiating.

| Placeholder | Kind | What it is |
|---|---|---|
| `PLACEHOLDER` | meta | The generic word, used in prose when talking about placeholders in general. Never substituted. |
| `AMH_VERSION` | init | The harness version being adopted, e.g. `1.8.0`. Record it: process drift is diagnosable only if the version that shaped the process is written down. |
| `PROFILE` | init | Which seed prose the install included: `light`, `standard` or `full`. Substituted into the adoption brief so the adopting agent knows what it is looking at — and nowhere else, because the brief is deleted when adoption finishes and nothing in the tree may branch on a level. |
| `DEFAULT_BRANCH` | init | The branch agents must never push to, e.g. `main`. |
| `BRANCH_PREFIX` | init | Namespace for session branches, default `session` → `session/<codename>`; `--branch-prefix` may select another value. |
| `MERGE_MODE_KEY` | init | `branch-per-change` or `branch-train`. |
| `MERGE_MODE` | you | The prose sentence in the constitution describing the chosen merge mode and what it obliges. |
| `REMOTE_FLAG` | init | Environment variable that marks a remote container, e.g. `AMH_REMOTE`. The bootstrap runs toolchain setup only when it is `1`. |
| `COMPRESS_TO_KB` | init | The state file's compression floor. |
| `WARN_KB` | init | The state file's soft cap. Must exceed the floor by many sessions of growth — the band IS the debounce. |
| `HARD_KB` | init | The state file's hard cap. Leave one long session of margin above the soft cap. |
| `LINE_CAP` | init | Line cap per ledger file, after which the next volume opens. |
| `CITATION_SCAN_PATHS` | init | Source trees scanned for `D-NNN` citations. Code and workflows only. |
| `TOOLCHAIN_SETUP_STEPS` | you | CI steps installing language runtimes, caches and linters before the ladder runs. |
| `PROJECT_NAME` | you | Repository name, for the constitution's title. |
| `PROJECT_DESCRIPTION` | you | One paragraph: what it is, what it is built with, and its lifecycle stage ("shipped v1.0; work is now maintenance"). |
| `REFERENCE_SYSTEM` | you | Where reference or spec artifacts live and the safe way to read them, if reading them wholesale is a context hazard. Delete the line if there is no reference system. |
| `IMMUTABLE_FIXTURES` | you | What outranks every document alongside the code, e.g. "golden test vectors". |
| `BOOTSTRAP_STEP` | you | Protocol step 1, e.g. "Run `scripts/session-start.sh` if your harness has no session-start hook." |
| `INDIVIDUAL_TEST_BUILD_LINT_COMMANDS` | you | One command per line with a one-phrase comment each. |
| `VERIFICATION_LIMITS` | you | What canNOT be verified locally, e.g. "no emulator here — on-device behaviour is owner-verified via the Owner queue". |
| `MODULE_MAP` | you | One bullet per module or layer: what lives there and the invariant that protects it. |
| `SEMANTIC_FIDELITY_RULE` | you | For porting or parity work: "reference semantics win over taste — port behaviour exactly, including its oddities; modernise the *how*, never the *what*." Delete if not porting. |
| `PROVENANCE_SOURCE` | you | The label used in provenance comments naming the source artifact, e.g. `SPEC` or `V1`. |
| `FIXTURE_IMMUTABILITY_RULE` | you | "Golden fixtures are immutable; production code conforms to THEM. Changing one requires proof the fixture was wrong plus a STATE entry." |
| `TOOLCHAIN_FLOOR` | you | Minimum supported versions; no legacy branches below them. |
| `INVARIANT_SHORTLIST` | you | Three to eight bullets: the invariants agents are most likely to violate. Each cites its ledger row. |
| `TAGGING_RULE` | you | Usually "Tagging and releasing stay owner steps." |
| `FIVE_LINE_SUMMARY` | you | Enough that a fresh session needs no other orientation doc. |
| `WHAT_IS_SHIPPED` | you | The state file's "Current state" body. |
| `DATE` | you | A date stamp, `YYYY-MM-DD`. |
| `QUESTION` / `DOC_PATH` | you | Rows of the runbook's reference-doc index. |
| `CHANGE_TYPE` | you | A recurring change type getting its own playbook: bug fix, feature, dependency bump, release cut. |
| `UNTESTED_GLUE_AREAS` | you | The code your test suite structurally cannot see — where the adversarial review pass is mandatory. |
| `BUG_CLASS` | you | One entry on the adversarial checklist, each a real shipped bug with its ledger citation. Never generic advice. |
| `DOMAIN_GUARDS` | you | Repo-specific machine-checkable release rules, e.g. a store changelog length cap (mind the unit: "500 characters" is codepoints, and `wc -c` overcounts multibyte text). |
