# DEVIATIONS & DISCOVERIES LEDGER — volume B (DB-001…)

> **Append-only registry — NEVER archived, compressed or truncated.** This is volume B,
> opened when `docs/LEDGER_A.md` reached its 800-line cap at row DA-026. Rows in the previous
> volumes are never moved or renumbered, and a citation's prefix names its file: `D-NNN`
> resolves in `docs/LEDGER.md`, `DA-NNN` in `docs/LEDGER_A.md`, `DB-NNN` here. Code and docs
> cite entries as bare IDs and those citations must always resolve; no entry is ever deleted
> or summarised away. Note the asymmetry: citations from **code and workflows** are
> machine-checked (`CITATION_SCAN_PATHS`), citations from **prose are not checked at all** —
> docs are deliberately out of scan scope, because prose mentions IDs without citing them. A
> dangling ID in a doc will not fail the build; that one is on the reviewer. Append new
> entries at the bottom, one continuous sequence. Code and fixtures are ground truth: if an
> entry conflicts with the current code, trust the code and **correct** the entry — never
> delete it.
>
> **This file is RETRIEVAL storage: grep it and cite it, never read it whole.** A `DB-NNN`
> citation resolves to one row, and one row is what you read. A volume at its cap is tens of
> kilobytes of prose whose overwhelming majority is irrelevant to any given session, so
> reading it end to end spends a context budget better spent on the code you came to change —
> and the ladder's cap rung prints this volume's size in KB beside its line count for exactly
> that reason (**DA-022**), because it is the live one. Closed volumes are never measured.
> Nothing in the harness has ever asked for a whole-volume read; this sentence exists because
> nothing forbade one either.
>
> **Search before appending.** Grep ALL volumes for the topic first; extend or cite an
> existing row rather than append a near-duplicate. A row that supersedes an older one says
> so ("supersedes DA-NNN") and the old row gets a correction pointer, never deletion.
>
> **File cap & rollover.** This file holds at most **800 lines** (the cap bounds LINES, not
> rows — it is read cost that is being bounded, and the number stays in lockstep with
> `LEDGER_LINE_CAP` in `amh.conf`). The final row may finish past the cap, but no row may
> ever *start* past it: when this file stands over the cap, create LEDGER_C.md (this file's
> name with a _C suffix) with the same header discipline, numbering from **DC-001**. It is
> named without backticks on purpose — a name in backticks is a citation, and the path-refs
> guard resolves citations against the real tree. The exact spelling matters: the ladder
> globs for it, so a volume named any other way is invisible to the line-cap and citation
> guards.
>
> **As the code stands TODAY the scheme is single-letter and stops at Z, and DAA- is the one
> spelling that fails silently in both directions at once.** Verified against the code, not
> assumed: the row pattern both the cap rung and the citation guard use is `D[A-Z]?-[0-9]+`,
> which admits at most one letter, so a `DAA-001` row matches nothing — invisible to the cap
> check, and its citations resolve to no row in either direction, with every rung green. And
> `live_ledger()` takes the LAST glob match, whose order is the shell's collation rather than
> volume age: under C and C.UTF-8, LEDGER_AA.md lands between LEDGER_A.md and LEDGER_B.md, and
> under a locale that ignores punctuation at the primary level it sorts before LEDGER_A.md.
> Both orderings are wrong in the same way — the live volume stays Z — which is why the fix
> below replaces the assumption rather than picking a locale.
>
> **The owner approved the durable fix on 2026-08-04; it is unit U5, not yet built.** Unbounded
> shortlex: the row pattern widens to `D[A-Z]*-[0-9]+`, `live_ledger()` orders volumes by
> suffix LENGTH then alphabetically, and the next volume's name is COMPUTED by base-26 carry
> (Z→AA, AZ→BA, ZZ→AAA) rather than looked up — a table is the thing that has a last entry, a
> carry rule is not. Until that lands, do not invent DAA-: twenty-four volumes of headroom
> remain, and widening the pattern is a guard-semantics change owing its own rule-review pass.
> Owed with it: the shipped seed preamble at `harness/templates/seed/docs/LEDGER.md` still
> describes the sequence with an open-ended ellipsis, which invites exactly the spelling this
> paragraph refuses, and adopters read that file rather than this one.
>
> **`[cited]` marker (machine-CHECKED — you write it, the ladder verifies it).** A row cited
> from the ladder's scan scope carries ` [cited]` after its number. The ladder checks it in
> BOTH directions — cited-but-unmarked and marked-but-uncited each fail the build — but it
> never edits this file: nothing syncs the marker for you. The marker warns you that code
> resolves here before you lean on or reword a row. Known Goodhart path, unguarded: the
> cheapest way to strip a protected row's marker is to delete the code comment citing it,
> which the guard then *requires*. If you find yourself doing that, you are removing the
> warning rather than heeding it. **One carve-out, and only one:** a citation inside a
> SHIPPED script is not a citation at all in the tree that receives it — those rows are ours
> and can never exist in an adopter's ledger — so removing one is correcting a false promise,
> not evading a warning. The reasoning prose stays and the row is named in a form the guard
> does not read (`AMH ledger row DBNNN`). Anywhere else, the sentence above binds.

- DB-001: **The ladder now names its subject — which commit, and whether the tree it just
  verified IS that commit.** This is the whole surviving deliverable of RFC2 (**DA-025**),
  built as one `printf` argument on five verdict lines that already existed: no new artifact,
  no new flag, no new vocabulary, no new shipped script, and no change to any exit code. The
  refused alternative was a versioned JSON receipt under an ignored `.amh/receipts/`; what
  replaced it is the shape **DA-022**(d) already settled on for the ledger's byte count —
  adopt the intent, report the fact in output the tool already prints, invent nothing to hold
  it.
  **(a) The dirty case is the reason the line exists, and it is not a word appended to the
  clean one.** The ladder verifies the WORKING TREE — the secret scan and the citation scan
  both read untracked files — so a green run rendered as `HEAD <sha>` while the tree differs
  from that commit is a claim about something nobody verified. The dirty rendering therefore
  states the count of uncommitted paths and says in those words that the verified tree is not
  that commit. A design that printed the sha and appended "(dirty)" would satisfy the RFC's
  criterion and still mislead the reader it was written for.
  **(b) Four states, because two of them read exactly like "clean" if they are collapsed.**
  No repository at all; git present but refusing to answer; an unborn HEAD; and a real
  commit. `git status --porcelain` printing nothing is INDISTINGUISHABLE from a clean tree, so
  its exit status is read and an unusable answer is reported as UNKNOWN — **D-019**'s rule
  (the switched-off state must be louder than the passing one) applied to a verdict annotation
  rather than to a guard. `git rev-parse --short HEAD` on an unborn HEAD yields the empty
  string, which is the same shape a naive implementation would print as a commit.
  **(c) The probe is NOT `git status --porcelain`, and the blocking pass is what established
  that it must not be.** `status` honours `status.showUntrackedFiles`, settable in `.git/config`
  or a user-level `~/.gitconfig`; `git ls-files -co --exclude-standard` — what the secret scan
  and the citation scan actually read — does not. With that key set to `no` the reviewer built a
  tree where the ladder printed `FAIL credential-shaped string in UNTRACKED-SECRET.txt` and
  `worktree clean` on the same run: the guard failing on content the verdict attributed to a
  commit not containing it, reachable by one command that edits no tracked file, appears in no
  diff and trips no guard. That is DA-001(c)'s "green button" shape, and it would have shipped.
  The probe is therefore built from the same sources the guards read. Residue, stated rather
  than papered over: `git update-index --assume-unchanged` hides a modified tracked file from
  `diff` and `status` alike and still reads as clean — a deliberate act on one path, which no
  probe built from git's plumbing escapes.
  **(d) `.gitignore` is honoured, and that is load-bearing rather than incidental.** Counting
  ignored files would render every adopter with a build directory permanently dirty, which
  trains the reader to skip the clause and kills the distinction the line exists to make — warn
  fatigue, one layer down from where the harness usually meets it. It also inherits **DA-024**(c)
  in full: an ignored directory is simultaneously unscanned by `guard_secret_shapes` AND counted
  clean here. Consistent, and worth knowing before anyone gitignores something interesting.
  **(e) Only the count is printed, never the paths.** A verdict line is not where a filename
  belongs, and the guard-diagnostic rule this repository already follows — report *where*, not
  *what* — has an analogue here: the number is the fact a reader needs, and the names are the
  tree's business. `--no-renames`, because the count claims PATHS and rename detection collapses
  a moved file into one entry.
  **(f) The pass also found that the fixtures asserted the wrong thing, which is the finding
  most worth carrying forward.** All five originally used bare-substring helpers, so they
  established "the string appears somewhere in the output" — and the reviewer demonstrated it by
  moving the subject out of the verdict lines and into an `ok` line inside the guard section
  with the suite still at 99/0. That is **D-027**(a) a third time, in the fix for the defect
  D-027(a) records, and `expect_pass_saying`'s own docstring already spelled out the discipline
  its callers skipped. The suite now extracts the verdict line and asserts on THAT, with a
  checked-NOTHING branch for a run that printed no verdict at all. Two of the five verdict lines
  were additionally unreachable through the suite by construction — `run()` always passes
  `--guards-only`, so nothing could reach either `✗ ladder red` — which is D-020's shape, and a
  full-ladder runner now covers them.
  **(g) The P3 line, stated for this artifact because the plan requires it per artifact.**
  Nothing consumes this string. It is not parsed, no exit code varies with it, no agent
  decision procedure takes it as input, and no rendering of it can make a red run look green —
  it is appended identically to the green and the red verdicts. Those are the three conditions
  **DA-025**(c) set for a record that has not become a consumed artifact, and the moment a
  guard, CI step or merge gate branches on this sentence it has failed all three.

- DB-002: **The session banner reports a runtime inventory — and the probe that seemed obviously
  right reported the script's own helper function as an installed tool.** RFC1's surviving
  residue (**DA-024**) ships: `REQUIRED_TOOLS` and `ADAPTER_FILES` in `amh.conf`, probed and
  printed at session start, writing no file and adding no shipped script. Tools are `observed` or
  `unavailable`; adapter files are `configured` or `unknown`, never `observed` and never
  `unavailable`. Eleven fixtures, ten of which fail against the pre-change tree.
  **(a) `command -v` is not a PATH probe, and the difference is the whole warrant for
  `observed`.** It resolves builtins, functions and aliases first, so `REQUIRED_TOOLS='say'`
  reported `session-start.sh`'s own output helper — defined 180 lines above the probe — as an
  installed tool, and `printf` read `observed` on a machine holding no binaries at all.
  `observed` means "a probe ran and the answer is a fact about this ENVIRONMENT"; a builtin makes
  it a fact about this bash. The design was scrupulous that `unknown` is never translated into
  `unavailable`; nobody had guarded the symmetric hazard, a non-fact becoming `observed`. Fixed
  to `type -P` with a fixture pinning the function case. Generalise: when a vocabulary's value
  comes from a probe, test the probe against a case whose answer you already know — the RFC that
  proposed this vocabulary said exactly that about diagnostics and it applied to its own residue.
  **(b) A guard that hardcodes the set it exists to keep from being copied.** `adapter-set.sh`
  gained a reverse check whose allowed list was written out literally instead of derived from the
  `ADAPTERS` array five lines above. Adding a fourth adapter correctly — array, installer, both
  `RULE_FILES`, `ADAPTER_FILES`, both files shipped — would make the forward loop REQUIRE the
  path and the reverse loop reject it, in the same run, with a message that is not a false
  positive but factually false. Now derived. The rule: a guard against duplication may hold
  exactly one copy of what it checks.
  **(c) Vendor names reached a shipped script for the first time, inside the diff whose stated
  rationale is that they do not.** The new fixtures used `.claude/settings.json` and
  `.codex/config.toml` as test data in `test-ladder-guards.sh`, which every adopter installs and
  runs — while `session-start.sh` three files away cites P14 for taking both lists from config so
  it names no vendor. Verified: all four shipped scripts contained zero vendor references before
  this change. Renamed to neutral placeholders. Shipped CONFIG templates may name adapters, since
  the installer installs those files; shipped SCRIPTS are the boundary, and it was intact until
  this diff nearly broke it.
  **(d) An assertion that cannot fail is not a fixture.** Every new assertion used a prefix
  `grep -qF`, so a mutation deleting the trailing-separator strip left the suite fully green. Now
  exact-line. This is D-020's shape in the fixtures added to satisfy D-020.
  **(e) One claim in the review was wrong, and replay caught it.** It reported the Decided
  non-items debt from DA-024(d) as still owed by this unit; **DB-001** discharged it in U1, and
  the section carries five such citations. The rest of that finding — that this diff owed a
  changelog line and a ledger row — was correct and is this row.
