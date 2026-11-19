# PLAN — no check flips when `grep -q` closes its pipe early under `pipefail`

> **Status: adopted by the owner on 2026-11-19, with R1 approved (R0 done).** One unit, run by
> the plan runner. **Do not archive or delete this file in R1**: the runner reads R1's done
> marker here to verify the unit. The session that merges the train archives it afterwards.

The plan is provisional while it is live. Its durable outcomes go to a Changelog line and a
ledger row. Code cites the ledger row and never this file, and no ledger row may cite this
file's path.

## 1. What happened, and the owner's decision

The PR #75 CI run on `5df7829` (merged with `main`) went red in the conformance lab self-test:
`FAIL the resolved item left in the queue — wanted exit 1, got 0`. Beside it, the log showed
`conformance/evaluators/01-stale-queue-item.sh: line 245: printf: write error: Broken pipe`.
That line is `printf '%s\n' "$ITEMS" | grep -qxF -- "$RESOLVED_HEAD"` under
`set -uo pipefail`. When `grep -q` matches and exits before the producer has finished writing,
the producer gets `EPIPE`, `pipefail` makes the pipeline fail, and the `if` takes the
"not found" branch. A check answers the opposite of the truth, depending on scheduling. Three
earlier CI runs and the local ladder passed on the same code.

The same shape — a pipe into `grep -q` in a file that sets `pipefail` — occurs about a hundred
times, in shipped scripts too (`ladder.sh`, `redact-tool-output.sh`, `redact.sh`,
`test-ladder-guards.sh`, `session-start.sh`, `command-guard.sh`), in the repo-local guards and
tests, and in `conformance/`.

**Owner decision (2026-11-19): audit every site and fix the ones that can actually race**, in
one unit, before the 17.0.0 tag.

Conventional defaults, which the unit may revisit only with a stated reason:
- Shipped-script fixes fold into the unreleased 17.0.0 entry, and `harness/VERSION` does not
  change. They go through `docs/RUNBOOK.md` → **Change a shipped script**.
- **No item is added to the Owner queue.** A site left alone is recorded with its reason in the
  ledger row.

## 2. The units: R0, R1

### R0 — commit this plan: done 2026-11-19

- **Done:** committed with the owner's decision; `docs/STATE.md` lists it under Live plans.
- **Acceptance:** `scripts/ladder.sh --guards-only` green.

### R1 — audit and fix the `pipefail` + `grep -q` race

1. **Inventory.** List every pipeline whose last stage exits before reading all of its input
   (`grep -q`, `grep -m N`, `head`) in each tracked `*.sh` that sets `pipefail` — in the file,
   or in a function or subshell the site runs in — where the pipeline's status decides
   something (`if`, `&&`, `||`, `!`, a checked `$?`). The ledger row records the count by
   class.
2. **Classify each site.** It can race only if the producer can still be writing when the
   consumer exits: more than one `write()`, which means a builtin `printf`/`echo` of a value
   that can exceed one stdio buffer, or any external command's output. A producer whose input
   is bounded and small by construction (a literal, a single short field) cannot race. Record
   why for each site judged safe. When in doubt, treat it as racy.
3. **Fix each racy site** without changing what the check means:
   - For a variable, use a here-string (`grep -q … <<<"$VAR"`), which works in bash 3.2.
   - For a command, capture its output first and check that the capture succeeded, or use
     `grep -q … < <(cmd)` where the command's own failure is checked separately.
   - Never `|| true` the producer if its failure mattered.
   - Do not touch a `grep -q` whose pipeline status nothing reads.
4. **Fixtures.** Add one deterministic fixture per surface — the shipped suite for shipped
   scripts, `scripts/tests/local-guards.sh` for repo-local guards, `conformance/selftest.sh`
   for the lab. Each feeds input larger than a pipe buffer (more than 64 KiB) with the match on
   its first line, so the old pipeline gets `EPIPE` every time. Show each one red on the old
   code and green on the new. If a timing-independent fixture cannot be built for a surface,
   say so in the ledger row rather than claim coverage.
5. **Record:**
   - one ledger row in the live volume;
   - one `docs/STATE.md` Changelog line;
   - a 17.0.0 changelog line: the shipped checks that could answer wrongly, and that nothing is
     owed by adopters beyond the normal script copy. Extend the Upgrading inventory if a script
     it does not yet list changed.
6. **Reviews and verification:**
   - a Sol review beside the writes;
   - `bash .orch/codex.sh rules` before the commit, because shipped scripts are in
     `RULE_FILES`;
   - the full `scripts/ladder.sh` on the final tree;
   - `conformance/selftest.sh` run three times in a row, all green.
7. Mark R1's heading done here, in the same commit. Do not archive this file (see Status).

**Acceptance:** every racy site is fixed or recorded with a reason; each fixture is shown red
on the old code and green on the new; copies are byte-identical and the manifest regenerated;
the full ladder is green; the rule review has been run and triaged.
