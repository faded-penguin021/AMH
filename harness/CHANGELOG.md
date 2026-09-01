# Harness changelog

Versions are `MAJOR.MINOR.PATCH`, and the number is a promise about **your** workload as an
adopter, not about how much prose moved:

- **MAJOR** — a binding rule changed. Adopting repos must act; the Upgrading notes say how.
- **MINOR** — additive. New principles, guards or templates you may take or leave.
- **PATCH** — clarifications and fixes with no action required.

Each entry's **Upgrading** section is the complete list of what an adopter must do to move
from the previous version. Scripts are copied; seeds are yours, so seed changes appear here
as hand-applied notes. Full procedure: [`docs/UPGRADING.md`](../docs/UPGRADING.md).

## 10.4.2 — 2026-09-01

- **Shipped-integrity mismatches now diagnose Git line-ending conversion.** For each mismatched
  tracked file, the integrity rung asks Git for its authoritative worktree EOL report. A CRLF
  worktree gets targeted guidance that line-ending conversion may have changed the byte-bound
  artifact; ordinary content mismatches retain the existing edited-file explanation.
- **The CRLF path gives an actionable order of operations.** It tells the adopter to retain or
  restore the harness-provided `.gitattributes`, re-normalize and re-check out the affected
  files, and only then rerun initialization or the ladder. This avoids restoring LF bytes into
  a checkout that immediately converts them back to CRLF and repeats the same failure.

### Upgrading

No action required. Copy the 10.4.2 shipped scripts and manifest through the normal harness
upgrade procedure; the additional diagnostic activates only when a manifest mismatch coincides
with Git reporting a CRLF worktree.

## 10.4.1 — 2026-09-01

- **No shipped script changed.** This release exists because the repository's own working memory
  had to record that 10.4.0 shipped, and a release number is how this repository dates a change
  to anything it publishes.
- **What it records.** 10.4.0 merged as a squash whose default message concatenated every commit
  body on the branch, poison token included, so GitHub Actions skipped that push: the tagged
  release commit has no CI run and cannot be given one. The rung had said in as many words that a
  squash would fold the token onto the default branch; what nothing modelled is that the merge
  dialog composes a new message from those bodies and that box is editable, where deleting one
  line would have cost nothing.

- **One correction to 10.4.0's own Upgrading note, from evidence it did not have.** That note
  said the shipped scripts alone stop the false findings on a CRLF worktree and that
  `.gitattributes` closes the rest. True on Windows, and misleading everywhere else: the first
  CI run on a genuinely CRLF adopter tree shows that **macOS and Linux bash will not execute a
  CRLF script at all** — `set: pipefail\r: invalid option name`, and the ladder dies before its
  first rung. Git Bash tolerates the CR and gets far enough to report the damage, which is why
  the original bug report carried 533 findings rather than a dead shell. So on macOS or Linux
  the seed is not the part that makes a CRLF checkout tidy, it is the part that makes it run.

### Upgrading

No action required, and nothing here changes a shipped artifact: the diff is `docs/STATE.md`,
two ledger rows, this repository's own CI workflow, and the version copies. If you are on
10.4.0 you are current in everything but the number.

If you took 10.4.0's advice to skip `.gitattributes` because your worktree looked fine, re-read
the correction above before deciding that on macOS or Linux.

## 10.4.0 — 2026-08-27

- **The destructive rail grew a data-plane tier.** `supabase db reset`, `prisma migrate reset`,
  `prisma db push --accept-data-loss|--force-reset`, `rails`/`rake` `db:drop|db:reset|
  db:schema:load`, `dropdb`, and `psql -c` whose statement STARTS with `DROP DATABASE`,
  `DROP SCHEMA` or `TRUNCATE` now get the same one-time advisory `rm -rf` gets — reached through
  a bare invocation or one package runner (`npx`, `pnpx`, `bunx`, and `npm`/`pnpm`/`yarn`/`bun`
  with or without `exec`/`dlx`/`run`/`run-script`/`x`), since nobody types a bare `prisma`.
- **The runner strip widens the filesystem arms too.** It runs before the whole dispatch, so
  `npx rm -rf x` and `pnpm exec git clean -fdx` are now advised where they used to be commands
  named `npx` and `pnpm` that no arm recognised. The deletion is just as real for being run
  through a runner.
- **Its advisory asks a different question, because it has to.** For a path the guard can name
  the hazard and ask for an expansion. A database reset names no target at all — it is resolved
  from a linked project, a config file found from the working directory, or `$DATABASE_URL`, so
  the production and local spellings are byte-identical. The advisory says exactly that and asks
  the agent to print the resolved target before rerunning; the path-shaped paragraphs are
  suppressed for these verbs, because "if that variable is empty the command addresses an
  absolute path" is false of a database and a rail that is confidently wrong teaches an agent to
  skim the next one.
- **The rail does not become the disclosure.** A data-plane command can carry a role password in
  a `--db-url`, and signatures are written to a state file and printed by `--advisory-report`, so
  value-bearing flags contribute their NAME only and a bare operand contributes itself only when
  it cannot be a connection string. A fixture builds a credential-shaped URL at runtime and fails
  if any part of the value reaches either place.
- **What it buys, stated in the header.** It cannot tell production from local and never will.
  A cleared advisory means the command was made deliberate, never that it was made safe — and
  the tools knowingly outside the list (`alembic`, `manage.py flush`, `redis-cli`, `mysql -e`,
  `mongosh`, `psql -f`) are named there rather than left to be discovered.
- **The tier then grew by what reported incidents earn, and by nothing else.** `npm run db:push`
  — the command an agent ran against a production database during a stated code freeze, in the
  most widely reported incident of this kind — was in the knowingly-absent list on the grounds
  that "the verb is not in the command text". Half of that was wrong: the SCRIPT NAME is in the
  text. A short list of names that say what they do (`db:push`, `db:reset`, `db:drop`, `db:wipe`,
  `db:nuke`, `db:schema:load`, `schema:load`, `migrate:reset`, `db:migrate:reset`,
  `migrate:fresh`, `migrate:refresh`) is now advised, matched WHOLE, and `npm` joins the runner
  strip so `npm run`, `npm run-script` and `npm exec` resolve like their `pnpm`/`yarn`/`bun`
  equivalents. `drizzle-kit push` — the tool that name conventionally runs — is advised too, where
  bare `prisma db push` still is not: prisma's push prompts by default, and drizzle's
  confirmation is reported failing in its 1.0 beta. The same search found a second uncovered
  shape in a tool the tier already had an arm for: any `prisma migrate` subcommand carrying
  `--shadow-database-url`, which prisma RESETS before replaying — a reported incident pointed it
  at production and lost 22 tables.
- **The script arm judges a name, and its advisory says so.** The script body is a line in
  the package manifest and no guard here opens a file to classify a command, so a harmless `db:push` is
  advised anyway and a script that drops the database under a name like `seed` is not advised at
  all. That paragraph is part of the advisory text rather than a comment, so a cleared prompt
  cannot read as a judgement about the script.
- **An escaped quote no longer voids the rails downstream of it.** All six character
  walkers read the `\"` in a double-quoted word as the CLOSING quote, so every operator after it
  looked unquoted and the scanners were handed a command line the shell never runs. The effect
  was fail-OPEN on the oldest rails in the file: `echo "say \"hi\"" && git push --force origin
  main` was allowed, and so were `rm -rf`, `cat .env` and `printenv` behind the same shape. All
  six walkers now apply bash's rule — a backslash escapes the next character inside double
  quotes, and inside single quotes there are no escapes — which `expands_secret_var` had modelled
  correctly since it was written. Every one of the six sites carries a fixture that fails without
  it, including the heredoc scanner, whose case took the `<<` INSIDE the quoted word to reach.
- **The secret scan and the manifest parse stopped failing on a Windows checkout.** The scan is a
  redact-then-`cmp`, so it was only ever sound if `redact.sh` were the identity function on
  credential-free input — and `redact.sh` is built out of `sed`, which is not byte-transparent
  everywhere. The MSYS2 sed shipped with Git for Windows rewrites CRLF to LF even for a script
  that matches nothing, so on a checkout made with Git's own installer default
  (`core.autocrlf=true`) every text file differed from its own filtered stream: 529 false
  findings in one reported run, the harness's own shipped scripts included, plus `redact.sh`
  failing its self-test against its own bytes.
- **`redact.sh --baseline` is the new mode that makes the comparison honest.** It runs the same
  two `sed` stages with no substitutions, so it carries whatever the platform does to line
  endings and no redaction at all. The scan compares against that — only for a file that already
  differed, so a transparent platform pays for no extra process — and what survives is redaction
  and nothing else. The baseline has to earn standing in for the file: the rung requires it to
  reproduce that file's own bytes apart from carriage returns, and refuses the file otherwise.
  Without that, a `sed` that truncated its output would truncate both streams alike, the two
  would agree, and the rung would report a green over bytes nobody read. A missing `--baseline`
  is refused the same way, for the same reason: a scan that cannot establish its baseline has
  checked nothing, and nothing is not clean.
- **The shipped-script integrity rung stopped reporting present files as deleted.** A CRLF
  `scripts/MANIFEST.sha256` gives every parsed filename a trailing CR, and because the hash field
  comes first the 64-character corruption check never fired — so the rung blamed the tree for
  five scripts that were on disk and told the reader to re-run the init script to restore them.
  The parse strips the CR; a filename cannot contain one.
- **`st_untouched` compares bytes now.** The self-test assertion that ordinary output "passes
  through byte-identical" compared through `$(...)`, which strips trailing newlines from both
  sides, so it structurally could not fail on a mangled line ending — the one class it names. It
  uses `cmp` against the baseline, with a CRLF case beside it. Both are parity checks between
  the filter and its baseline, and they say so: a platform that mangles line endings mangles
  both streams identically, so what these can catch is a filter stage the baseline does not
  have. The Windows defect itself is demonstrated by the ladder's fixture, under a `sed` shim.
- **A `.gitattributes` seed keeps the class from arising**, pinning the files AMH installs and
  reads byte-for-byte to LF endings. Narrow by design: what the rest of your tree does with line
  endings stays yours. It is not optional dressing on a Windows checkout, and the two halves it
  is carrying alone are named rather than left to be discovered: the integrity rung compares a
  file against a hash the harness published for its LF bytes, so a CRLF shipped script reports
  as edited (a truer sentence than the "deleted" it used to get, but still red); and `amh.conf`
  is sourced by bash, where a trailing CR joins the value and a numeric threshold stops being
  numeric. Neither is fixable in the rungs without making them measure something other than the
  bytes they exist to measure.
- **A font file stopped being read as a citation, for the same reason and one version lower.**
  The citation rung greps every scanned file for row ids; a binary file whose bytes happen to
  match makes grep print `Binary file <path> matches` instead of the match, and which stream
  that notice goes to is version-dependent — stderr on grep >= 3.5, which the rung already
  discarded, but STDOUT on <= 3.4, and Git for Windows ships 3.0. There it was captured as a
  citation token no ledger row can resolve, so a Windows checkout failed the rung naming two
  `.ttf` fonts. `-I` settles it in every version — a binary file is not a citation site — and it
  is the same flag the secret scan already uses to answer the same question. Found by the
  adopter tree that filed the CRLF report, running this train on a real Git-for-Windows clone.
- **The Windows secret scan is about twice the CPU it was, by design.** The `--baseline`
  subtraction runs only for a file that already differed from its filtered stream, so an LF tree
  pays nothing — but on a CRLF worktree every text file differs, so every file takes the slow
  path. Measured on the reporting tree: 4m20s of CPU before, 9m06s after. Renormalising does not
  relieve it beyond the harness's own files, because the `.gitattributes` seed is deliberately
  narrow and the rest of your tree stays whatever it was. This is the cost of measuring the
  filter instead of assuming it; it is not a regression to report.
- **What a search for reported incidents did NOT find stays out.** `alembic downgrade base`,
  `manage.py flush`, `redis-cli flushall`, `mysql -e`, `mongosh --eval` and `drizzle-kit drop`
  have no public report of destroying data in an agent's hands, so resemblance alone does not
  admit them. Neither does the largest incident no verb list can hold: a production volume and
  its backups deleted by a `curl` GraphQL mutation carrying a found token, which is an API
  surface rather than a command word.
- **A `printf | grep -q` that closes the pipe made two rungs fail OPEN, and both are fixed.** In
  `command-guard.sh`'s `extract_command`, the fallback used where `python3` is absent matched the
  hook payload with `printf '%s' "$payload" | grep -qE ...`. `grep -q` exits at its first match; a
  writer with bytes still pending takes EPIPE; the file runs under `pipefail`, so a SUCCESSFUL
  match became a failed pipeline and `|| return 0` stood the rail down on a Bash command nobody
  inspected. `ladder.sh`'s poison-token rung had the same shape and left a token in the newest
  commit unreported. Both are here-strings now, whose writer is not a pipeline member and so never
  reaches `PIPESTATUS`; the `| head -1` beside the first is gone for the same reason. Reaching it
  takes input that is BOTH multi-line and past the pipe buffer — size alone does not do it,
  because grep cannot match until it holds a whole line — which is why it went unseen: the rail
  is only exposed where `python3` is missing, and commit messages had to reach ~64 KB.
- **A ledger row may no longer cite a plan's path, because two rules that each looked right made
  a plan undeletable.** Permanent memory is immutable; the plan tier is archive-or-delete; a path
  guard requires a cited path to exist. A row citing `docs/plans/<file>` satisfies all three and
  makes them contradict: the plan can never move or go, and the contradiction only surfaces when
  someone tries, long after the row is beyond repair. Recorded in the principles as prose, since
  the shipped ladder has no ledger guard to carry it — the reference repository enforces it on
  NEW rows in its own `ledger-append-only.sh`. Committed rows are exempt of necessity: a check
  reaching them would fail permanently on the row that motivated the rule, which is the same trap
  one layer up. A plan already pinned by a committed row is retained in place.

### Upgrading

Copy `command-guard.sh` AND `ladder.sh` from `harness/templates/scripts/` over your local copies
and re-run your manifest generator, as for any shipped-script change. No configuration key changes. Expect one
extra prompt the first time a session runs a database reset command, per verb and per named
target; a rerun of the same command proceeds, exactly as with the filesystem tier. Also expect
`rm -rf` and `git clean -fd` run through a package runner to start being advised, which they
were not before — `npm exec` included, since `npm` is now stripped like `npx`. If your
repository has a package script on the name list whose body is harmless, it is advised once per
session all the same: the guard reads the name, never the script. Expect one more class of
command to start being judged that was silently passing before: anything on a line that also
carries a `\"` inside double quotes, which until now closed the quote early and hid whatever
followed it from every rail. It cuts BOTH ways and the loosening half is worth knowing: prose
carrying an escaped quote stops being mistaken for a command, so `echo "a \" | rm -rf x | b"` and
`grep -q "x \" < .env" f` go quiet, and an unterminated line such as `echo "a\" && git push
--force` is now allowed rather than blocked — malformed input fails open by design. If you key any
CI check or transcript review on this guard's output, expect both directions to move.

The plan-citation rule is prose in the principles and a seed-runbook line; no shipped guard
enforces it, so it binds by review. If you took the seed runbook, hand-apply the new sentences in
session discipline 5, and check your own ledger for a row that already names a plan path — if one
exists, retain that plan where it is and record the retention in the plan file itself, rather
than attempting an archive that a path-existence guard will reject.

The same copy pass covers `ladder.sh`, `redact.sh` and `test-ladder-guards.sh` — the manifest
instruction above already covers all of them. `ladder.sh` and `redact.sh` must move
**together**: a new ladder beside an old `redact.sh` finds no `--baseline` to compare against,
and it will refuse to scan and say so rather than pass your tree quietly.

**Copy every script `MANIFEST.sha256` names, not only the ones this entry changed.** The
integrity rung compares your `scripts/` against the hashes published in the manifest you just
copied, so any script left behind at an older version reports as edited and the rung stays red —
`session-start.sh` above all, which no entry in this train changed but which changed in 10.2.0 —
a release an adopter coming from 9.1.0 skipped. One followed the list literally and finished with
a red integrity rung for exactly that reason; the list, not their tree, was wrong.

One expectation to set for Windows, since nothing above implies it: **the secret scan costs
roughly twice the CPU on a CRLF worktree** (4m20s → 9m06s, measured), because every file that
differs from its filtered stream takes the baseline path and on a CRLF tree every file differs.
Renormalising covers what the seed pins — the harness's files and, through `*.sh`, your own shell
scripts — and nothing else, so on a tree of any other language the cost is durable rather than
transitional. On an LF checkout nothing differs and nothing extra runs.

Seeds are yours, so the new `.gitattributes` is a hand-applied note: copy
`harness/templates/seed/.gitattributes` into your repository root if you have no such file, or
add its lines to the one you have. It governs future checkouts only — a worktree that is already
CRLF stays that way until you renormalise it (`git add --renormalize .`) or clone again. **On
Windows it is part of the fix, not a nicety.** The scripts alone stop the false credential
findings and the false "deleted script" verdicts; they do not make a CRLF worktree green,
because a CRLF shipped script does not hash to the hash published for its LF bytes and a CRLF
`amh.conf` sources with a CR inside every value. If you are on Linux or macOS, or your checkout
is already LF, nothing here asks anything of you.

## 10.3.1 — 2026-08-27

- **The README now starts with the failures AMH relieves.** The opening explains cross-session
  memory, mechanical verification and command guardrails in familiar terms, and puts the Quick
  Start before the detailed architecture and fit discussion.
- **The limits remain explicit.** The shorter introduction describes the rails as risk
  reduction rather than a security sandbox, and the detailed mechanism and scope sections are
  retained after the adoption path.

### Upgrading

No action required. This release changes only the source repository's presentation of the
existing adoption path.

## 10.3.0 — 2026-08-27

- **The seed ledger preamble and `amh.conf.example` stopped contradicting each other.** The seed
  said `**Rows are immutable — never edit one in place.**` and offered a correction only as a new
  row plus an appended pointer, while the shipped config's citation-collision note told you to "drop
  the marker, never the row" when an exclusion strands a `[cited]` row — an in-place edit of a
  committed row, which the seed had just forbidden. Both files ship, so every adopter received
  both instructions about the same edit.
- **The seed now names the marker as the one exception**, because that is which of the two was
  incomplete: the ladder's citation rung has always required the marker to track the citation
  set in both directions, so syncing it in place was already mandatory and the immutability
  rule was simply silent about it. The `[cited]` section says so at the point of use, and both
  files now carry the same warning — an append-only guard of your own must permit the marker in
  BOTH directions, or it will refuse the very edit the rung demands.
- **This repository ran into that exact contradiction first**, which is what produced the fix:
  its own append-only guard refuses the removal, so the un-cite stalls until the row is
  re-cited or the removal is committed past the red rung. That guard is repo-local and no
  adopter inherits it, but both halves of the prose reached them.
- **The same carve-out landed in this repository's own five rule-bearing places**, not the seed
  alone — the constitution, the runbook, the state file and all four volume preambles carried
  the flat sentence too, and a reference instance that ships a correction it has not taken is
  the defect twice. The review pass is what counted them; no guard reaches preamble prose
  (**DC-021**).

**Why MINOR — the owner's call, 2026-08-27, over a drafted PATCH.** The session argued PATCH and
the reasoning is worth keeping because it is half right: no binding rule changed, the shipped
scripts are byte-identical, the manifest's hash lines are unchanged (only its version header
moved), and the rule the seed now states completely is the rule the ladder was already enforcing
— so 10.2.0's governing test, that PATCH does not survive an Upgrading section telling an adopter
to do something, is arguably survived here, since neither item below is a NEW obligation. What
the owner weighed heavier is the other definition: the seed template gains a carve-out and a
caution it did not carry, and template prose an adopter may take or leave is what MINOR names.
The number a reader can act on beats the number a reader has to reconstruct an argument for, and
between two defensible numbers the larger one costs an adopter a closer look and nothing else
(**DC-020**, **DC-021**, **DC-022**).

### Upgrading

No new obligation. Two things to look at, both pre-existing:

1. If your ledger preamble still carries the seed's immutability wording, you may hand-apply the
   carve-out and the `[cited]` paragraph's closing sentences. Seeds are yours; the rule is
   unchanged either way. The manifest's version header moved with this release, so copy the
   regenerated manifest if you want it to match your `AMH_VERSION`.
2. If you wrote your own append-only guard over your ledger, check that it permits ` [cited]`
   to be added AND dropped. One that permits only the addition will refuse the removal the
   citation rung demands — which it demanded at 10.2.0 too, so such a guard is already
   contradicting your ladder rather than newly contradicting it.

## 10.2.0 — 2026-08-26

- **`env` is judged by whether it was handed a command, not by whether an option follows it.**
  The command rail strips `env` as a transparent prefix, and it decided which `env` was a
  prefix by looking at one word: anything starting with `-` meant a dump. So
  `env -u AMH_REMOTE bash scripts/session-start.sh` — a command that unsets one name and
  prints nothing — was refused with a reason asserting it dumped the environment. POSIX
  spells the real distinction: `env [-i] [name=value]... [utility [argument...]]` prints the
  environment when, and only when, no utility operand follows. The rail now walks `env`'s own
  options and assignments and asks that question instead.
- **The false positive was in this repository's own shipped fixture suite**, which runs that
  exact spelling to test the bootstrap. It escaped because the suite runs it in a subshell
  rather than through the hook — a rail's false positive can be invisible to the very suite
  that exercises the rail. The spelling is now pinned as an allow case.
- **Two commands changed the other way, and both were holes.** `env FOO=1` is blocked: with no
  utility it prints the environment with one name added, which is the dump the rail exists to
  stop, and the old arm let it through because its dump signal was a leading `-` rather than
  an absent utility. And `env -u FOO cat .env` was blocked as an `env` dump and is now blocked
  as the `.env` read it is — which it would not have been at all had the option walk not
  swallowed `-u`'s argument, since `FOO` would have become the command word.
- **Long options are matched by ABBREVIATION, which is how `getopt_long` matches them.** This
  was the review pass's blocker and it was a genuine hole, not a rough edge: the first draft
  of the walk matched `--unset` and `--chdir` only, so `env --u FOO cat .env` had `--u` read
  as a plain flag, `FOO` promoted to the command word, and the read behind it went unjudged —
  while `env --unset FOO cat .env`, the same command three characters longer, blocked.
  `env --u FOO printenv` defeated the dump arm itself. 10.1.1 blocked every one of these, so
  shipping the draft would have opened a hole the release was cutting to close.
- **The option walk's edges are enumerated in the guard header rather than summarised.** The
  options taking a SEPARATE argument are a list, not a category — `-u`, `-C`, `-P`, `-a` and
  abbreviations of `--unset`, `--chdir`, `--argv0` — so an `env` carrying one this list does
  not model would have `env -X VALUE cat .env` judge `VALUE` and miss the read. `env -S 'cat
  .env'` and `--split-string=` hide the utility inside a string this guard cannot split and
  get past exactly as `bash -c` does. A missing option argument (`env -u`) is a usage error
  that runs nothing and fails OPEN, the direction every rail here fails on odd input.
  `--help` and `--version` print their own text and are not dumps; `--list-signal-handling`
  prints the handling AND the environment, so it stays one.
- **`env` with no command stays blocked in every remaining spelling**, `env -i` included — but
  the reason no longer claims a leak it cannot make. `env -i` and `env -` print an EMPTIED
  environment and expose nothing; the block reason now says they are stopped with the rest
  rather than carved out, because carving them out would put the option walk in the business
  of ruling which dumps come back harmless. 28 self-test rows: 13 fail against 10.1.1, 6 fail
  if the short-cluster argument-swallowing branch alone is neutered, and 7 fail if the
  abbreviation match is narrowed to exact spellings.

**Why MINOR** — 10.1.0 is the governing precedent and it points here: it rated itself MINOR
for "a shipped rail's verdict changes for a real class of commands", and this changes verdicts
in both directions for real classes. PATCH was drafted first and does not survive its own
Upgrading section — item 3 below tells an adopter to do something, and PATCH promises they
need not. MAJOR is out on its own definition rather than by preference: it requires that a
binding rule changed, and none did. P17, the constitution, the seed and every adopter
obligation are byte-identical; the commands newly blocked were already forbidden by the rule
the rail enforces, and the commands newly allowed never violated it. That leaves PATCH-vs-MINOR,
which is not the ambiguous major-vs-minor call `CONTRIBUTING.md` reserves for the owner, and
MINOR is the honest side of it: guard coverage grew (**DC-019**).

### Upgrading

1. Copy the shipped scripts and regenerated manifest.
2. If any of your tooling worked around the old refusal — spelling `env -u FOO cmd` as
   `FOO= cmd`, or dropping the hook for it — you can drop the workaround.
3. If you run a bare `env FOO=1` or `env --u NAME` anywhere, it is now blocked, and that is
   the one thing in this release that can cost you work. Both print the environment. Give
   `env` the command it was meant to prefix and the guard judges that command instead.

## 10.1.1 — 2026-08-25

- **The session bootstrap now clears the `.resumed` sibling it had been leaving behind.** The
  command guard writes a state file for every advisory category and, for the two that keep one —
  destructive and subagent — a `.resumed` ledger of what a session went ahead with; and
  `session-start.sh`'s cleanup pattern stopped at the repository slug, so it deleted the state
  and never the sibling. Both reports built on that file therefore spanned every session that
  shared the container.
- **The `--advisory-report` half is the one that mattered.** A deletion advised and then
  ABANDONED in this session printed nothing at all whenever the same command text had been
  resumed in an earlier one — and printing nothing is exactly what compliance looks like.
  Reproduced end to end: with the old bootstrap the report came back empty, with the new one
  it names the abandoned command. `--spawn-report` was the visible symptom: it counted spawns
  from sessions long gone.
- **The pattern was NOT widened to `<slug>*`, and the reason is worth keeping.** That would
  have reached the sibling, and it also reaches a neighbouring repository — `/home/user/AMH*`
  matches `/home/user/AMH-fork`. The "wide is safe" argument this function already carries
  holds for the state file, where an early rearm costs one extra prompt, and INVERTS for
  `.resumed`, where erasing another repository's copy destroys the record of what its sessions
  did. The two names are enumerated instead, and the comment says a new sibling suffix in the
  guard needs a new entry here.
- **Two shipped fixtures, both in hook mode**, because the guard writes `.resumed` only on the
  hook path and no `--command` fixture can see any of this.

### Upgrading

1. Copy the shipped scripts and regenerated manifest. Nothing else is required.
2. Your existing `/tmp/amh-command-guard-*-advisory-*.resumed` files are stale from before this
   fix; the first bootstrap after upgrading removes those belonging to your repository — there
   may be two, one destructive and one subagent. Until then, treat a `--spawn-report` count as
   spanning sessions.

## 10.1.0 — 2026-08-25

- **The push rail stops checking the branch NAMESPACE, and checks the push instead.** Since
  7.0.0 `git push` had to name one ref under `<BRANCH_PREFIX>/`, and that rail blocked a
  correctly assigned `claude/<codename>` branch in this repository. P13 tells the `--pre-push`
  rail to "carry NO branch-prefix check: the harness assigns session branch names the
  repository may not itself prefix, so a prefix rail here rejects the very branches it exists
  to protect", and **DA-022** had already declined a prefix guard on that same reasoning
  before 7.0.0 built one for `git push` anyway. The two rails in one script have contradicted
  each other ever since, both self-tests green.
- **What the rail denies now is what it can actually read.** The default branch in each of the
  three spellings git resolves to it (`main`, `heads/main`, `refs/heads/main`, on either side
  of a colon); force; deletion (`--delete` and the `:branch` refspec alike); an explicit
  `refs/tags/` push; the two unresolvable destinations `HEAD` and `@`; and a second ref. Each
  is a fact of the command in front of it. "Is this branch name the one the repository
  sanctions" is not: the rail cannot tell a name the harness assigned from one the agent
  invented, and P13's answer when a rail asks for something it cannot see is to change what it
  asks for.
- **The coverage this loses is enumerated, not summarised.** The namespace test had been
  stopping several things as a side effect of stopping everything unfamiliar. Three survive as
  accepted misses, listed in the guard's own "what this guard does NOT catch" block: one
  explicitly named off-convention branch (`git push -u origin work` — a real incident from a
  real session, and why 7.0.0 built the check), a tag named without the `refs/` prefix
  (`git push origin v1`, `tags/v1`), and malformed refspecs, which fail open like every odd
  command. Only the first is new policy; the tag case is covered instead by the `--pre-push`
  rail, which sees git's resolved ref and therefore catches every spelling.
- **Tagging gained a rail it never had.** Both rails now deny a tag push outright, because
  release and tag actions are owner steps in the constitution and were previously stopped only
  by the namespace test, by accident. The flag rail reads `refs/tags/…` only; the git-native
  `--pre-push` rail catches the bare and `tags/…` spellings too.
- **A fixture that had never tested its own comment was found by the removal.** `st_blocked
  "git push -u origin <default>tenance"`, commented as the check that a branch merely
  CONTAINING the default branch name is not the default branch, was denied by the namespace
  test before the default-branch patterns were ever consulted about the substring. It is now
  an allow case, and the block direction is pinned separately. That is the durable half: a
  fixture can pass for the wrong reason for as long as a broader check sits upstream of it.

**Why MINOR and not MAJOR** — 7.0.0 shipped this same rail as a MAJOR with an Upgrading step
("rename or recreate in-flight branches"), so symmetry argues for MAJOR here. It does not
hold: the number promises an adopter's workload, and the two directions are not symmetric.
7.0.0 made branches un-pushable, which is work. This makes nothing un-pushable — measured, not
asserted: 844 push spellings were run through both versions and no command allowed at 10.0.1
is denied at 10.1.0. No rule an adopter follows becomes wrong, and the naming discipline is
unchanged and still binding in their constitution. Nothing to do is the MINOR/PATCH bar, and a
shipped rail's verdict changing for a real class of commands is more than the "clarification or
fix" PATCH covers. Read the honest objection too: MINOR's definition is *additive*, and
removing guard behaviour fits MINOR by its consequence column rather than its meaning column.
`CONTRIBUTING.md` routes an ambiguous major-vs-minor call to the Owner queue rather than
letting a session settle it; this one was settled by the session under a standing owner mandate
to decide rather than queue, and it is the owner's to overturn before the tag is cut
(**DC-017**).

### Upgrading

1. Copy the shipped scripts and regenerated manifest.
2. Nothing is required of you. But if you were relying on the rail to hold your branch naming,
   note that it no longer does: an agent that pushes one explicitly named off-convention branch
   is now stopped by your constitution and your reviewer, not by a block. Check that your
   constitution still carries the clause — in the shipped seed it reads "Develop and push
   **only** on your session's assigned `{{BRANCH_PREFIX}}/<codename>` branch", which in your
   instantiated copy has your own prefix substituted in.
3. If your harness assigns branch names outside your `BRANCH_PREFIX`, this release is the one
   that stops blocking them, and you can drop any local workaround you cut for that.
4. If your adopted constitution left `{{TAGGING_RULE}}` unfilled, fill it now. Tag pushes were
   being stopped by the namespace test as a side effect; they are stopped by a real rail from
   this release, but the prose that says *why* is yours to write.

## 10.0.1 — 2026-08-25

- **The citation rung's collision with your own constants is documented where the keys are.**
  A constant of yours wearing the ledger-id shape — a capital D, any run of capitals, a
  hyphen, digits — is read as a citation and fails the rung with "no such ledger row" for an
  id nobody ever cited. The shipped `amh.conf.example` now names the class beside
  `CITATION_SCAN_PATHS` and `CITATION_EXCLUDE`, gives a locating command that honours both
  keys, and states what each of the three ways out actually costs.
- **Two of those costs were undocumented, and are why the note exists.** Excluding the file
  drops the WHOLE file from the scan, so a row whose last citation lived there goes
  stale-marker red the moment you exclude it. Emptying `CITATION_SCAN_PATHS` empties the
  citation set, which turns EVERY `[cited]` row into a stale marker at once — so "just turn
  the rung off" is a ledger-wide edit, not a one-line one. Each needs a second step nobody
  had written down.
- **No behaviour changed, and the note is careful about whose fault your red is.** The rung,
  the pattern and both keys are byte-identical to 10.0.0. But the class splits in two and the
  note says so: a one-capital constant collided before 8.0.0 as well, while a multi-capital
  one is a genuine 8.0.0 regression — that release widened the pattern from at most one
  capital to any run of them, which can redden a tree on a file nobody touched. That break
  was recorded at the time and is why 8.0.0 was rated MAJOR; telling an adopter it was always
  their standing cost would have been false.
- **A `LEDGER_PREFIX` key stays refused** — on relocation, not on immutability. Any prefix
  can collide with an adopter's own vocabulary exactly as this one did, so it moves the
  collision into your taxonomy instead of removing it.

**Why PATCH and not MINOR** — the harder half of the call, since this does add 50-odd lines to
a template, and MINOR covers "templates you may take or leave". The operative test is whether
skipping it changes a verdict, and 6.0.1 is the precedent: prose added to a seed preamble and
to the config template beside a key, no threshold, guard, fixture or exit code touched, shipped
as PATCH because the clarification was optional and changed no result. This is that shape. No
key, rule, default or behaviour moved; an adopter who ignores this release gets the same ladder
verdicts they get today. It is worth a release number at all only because the installer KEEPS
an existing `amh.conf`, so template wording never reaches an established adopter except through
the step below.

### Upgrading

1. Nothing is required. If you want the note in your own `amh.conf`, copy the comment block
   that follows `CITATION_EXCLUDE` in `harness/templates/amh.conf.example`. It changes no
   value, and an adopter who never meets the collision can skip it.
2. No shipped script changed in this release. If you re-copy the scripts anyway, take
   `MANIFEST.sha256` from the same release — its header carries the version, so a manifest
   and scripts from different releases report drift that is not there.

## 10.0.0 — 2026-08-25

- **Ledger rows are immutable, and a correction is a new row plus a pointer.** Every volume
  preamble said "if an entry conflicts with the current code, trust the code and **correct**
  the entry." Nothing ever honoured that: `ledger-append-only.sh` rejects any edit to a
  committed row. The prose claimed an affordance the enforcement denied — the D-010 class —
  and it was hit for real while recording DC-011. The promise is gone; in its place, a
  correction is what it should always have been: write the new row, append one pointer line to
  the old one, mutate nothing.
- **Two pointer verbs, and the distinction is linguistic on purpose.** `Superseded by D-NNN.`
  says the whole row is replaced. `Corrected by D-NNN.` says one detail went stale under a
  principle that still stands. Mechanically they are the same append; the difference is only
  what the word tells a future reader, and the guard checks the FORM and cannot check which
  verb is honest. That half is the reviewer's, and saying so is the point — a guard that
  appeared to police the distinction would be a self-report dressed as a gate.
- **Why the second verb exists.** DB-014 is the case: its principle (a destructive rail is a
  category-scoped speed bump) still stands, and only its sentence enumerating `rm -rf` and
  `git clean -f -d` went stale. DC-011 says in its own words that it *extends* DB-014's
  category — it does not carry DB-014's rule. `Superseded by DC-011.` would have sent a reader
  to a row that does not contain what they came for. DB-014 now carries `Corrected by DC-011.`
- **Known limit, deliberately unbuilt:** a row carries at most one pointer, ever, so a
  corrected row cannot later gain a supersession line. Nothing has hit that; when something
  does, it earns the change.

**Why MAJOR** (owner-confirmed, 2026-08-25)**:** the append-only guard is repo-local and is
**not** among the five shipped scripts, so an adopter has no mechanism forbidding an in-place
correction, and their seed preamble told them to make one. Deleting that clause makes a
practice they may be following today wrong, which is CONTRIBUTING.md's own MAJOR test. An
adopter who never edited a row in place is unaffected and need do nothing.

### Upgrading

1. Replace **two** sentences in your `docs/LEDGER.md` preamble — and in **every** rolled volume
   — with the wording in `harness/templates/seed/docs/LEDGER.md`: the ground-truth sentence,
   and the one under "Search before appending" that says the old row "gets a correction
   pointer" (it means the `Superseded by` one, and now reads as the wrong verb). Do every volume: the
   5.0.0 cap change already left three preambles contradicting the guard once.
2. Add the same carve-out wherever your **constitution and your runbook** state the ground-truth
   rule — both usually do; the seed's are in `harness/templates/seed/AGENTS.md` and
   `harness/templates/seed/docs/RUNBOOK.md`. Without it, "trust the code and correct the doc" and
   "never edit a row" contradict each other, since the ledger is a doc.
3. If you have an append-only guard, teach it the two pointer forms. The regex in
   `scripts/guards/ledger-append-only.sh` is a working example, not a shipped artifact — if you
   have no such guard, all of this is prose only for you, and worth saying so out loud.
4. Rows you corrected in place in the past stay as they are. Nothing here asks you to rewrite
   history, and this release is the reason not to start.

## 9.2.0 — 2026-08-25

- **Working memory stops paying for its own rules.** The length-guard preamble that governed
  `docs/STATE.md` now lives in `docs/RUNBOOK.md` under a new **Working-memory compression**
  section, and the Owner-queue preamble's test rules fold into **Session discipline** 7. Both
  files keep a pointer, and `doc-navigation.sh` now checks the pointers as well as the
  headings. What changed is not the rules but where they are charged: 2,499 bytes of them were
  spending a 9,216-byte compression floor that exists to evict volatile content, and could not
  be compressed to make room, because folding a live rule is repeal.
- **P2 states where a capped tier's rules belong.** Relocating them to the operational doc the
  tier's guard output already points at is not repeal: it is read on demand and reachable from
  the constitution's disclosure list. The ledger and the archive stay forbidden destinations —
  a live rule in retrieval storage binds nothing. Guard the pointer left behind as well as the
  destination heading; checking only the heading leaves the pointer deletable in silence, which
  is a hole this release found and closed in its own guard. Each relocation remains the owner's
  call, because the pointer is weaker than a rule sitting in the file being edited.
- **The seed state file drops 6,045 → 2,564 bytes.** Its two preambles were 4,859 of those
  6,045 before an adopter had written a line; the compression rules moved into the seed runbook.

Additive: no previously-permitted workflow becomes forbidden, and an adopter who changes
nothing keeps a working repository — every copied `ladder.sh` has enforced both floor units
since 8.0.0. MINOR rather than MAJOR. Two seed clauses did move, and neither is a relocation:
the seed said the floor "counts SENTENCES, not bytes", which had been false since 8.0.0 and is
now corrected to bytes AND sentences; and the seed gained "a typo fix above the cap is allowed
and still owes the pass", which its own guard has never enforced either way.

### Upgrading

Seeds are yours, so this arrives as a hand-applied note rather than a file you re-sync:

1. Copy the **Working-memory compression** section from
   `harness/templates/seed/docs/RUNBOOK.md` into your `docs/RUNBOOK.md`, placing it after
   **Acceptance ladder**. It carries every clause your `docs/STATE.md` length-guard preamble
   carried, plus the two named above — read the floor sentence before you copy it, since your
   preamble may still describe the pre-8.0.0 single-unit floor.
2. Replace that preamble in your `docs/STATE.md` with the three-line pointer from
   `harness/templates/seed/docs/STATE.md`, and trim your Owner-queue preamble the same way —
   the wording is in the same file.
3. If your ladder has a documentation-navigation guard, give it a row for the new heading AND
   one for the pointer left behind in `docs/STATE.md`. Checking only the heading leaves the
   pointer deletable in silence, which is the hole this release closed in its own guard.
   Without such a guard the pointer is prose only — say so rather than implying a check.
4. Optional, and worth measuring first: anything else permanent in your state file (a project
   blurb duplicating your constitution, a decided-non-items index) is spending the same budget.
   Keep whatever your guards read — this repository had to keep one version sentence a lockstep
   guard greps for.

No script, config key or guard semantic changed, so there is nothing to copy under `scripts/`.

## 9.1.0 — 2026-08-20

- **Git now invokes an independent publication rail.** `command-guard.sh --pre-push` rejects
  pushes targeting the default branch, branch deletions and non-fast-forward updates by outcome;
  `session-start.sh` installs its wrapper without clobbering foreign hooks or `core.hooksPath`.
- **Destructive advisories retain parameter expansions and cover risky Git tree mutations.**
  Unquoted and nested `${...}` no longer collapse to a shared target, and variable/whole-tree
  forms of `git rm`, `worktree`, `reset`, `checkout`, `switch` and `restore` receive the same
  deliberate speed bump as destructive filesystem commands without advising ordinary literals.
- **Claude's adapter can put the existing sequential-subagent rule at the spawn boundary.** Its
  `Task` hook maps to the agent-neutral `--pre-task` entry point, which advises every spawn,
  rearms after the deliberate rerun and reports only how many proceeded — never concurrency.
- **The adopter upgrade command no longer needs GNU version sort.** POSIX Awk selects the latest
  strict `amh-vMAJOR.MINOR.PATCH` tag numerically.

These are additive rails and corrections: no previously-permitted workflow becomes forbidden by
the binding rules, so this is MINOR rather than MAJOR.

### Upgrading

1. Copy the whole `harness/templates/scripts/` directory into `scripts/`, including the manifest,
   and keep the shipped scripts executable.
2. Run `scripts/session-start.sh`. Where no foreign pre-push hook or `core.hooksPath` owns the
   lifecycle, it installs the Git-native wrapper; otherwise follow its message to chain
   `scripts/command-guard.sh --pre-push` manually if you want this additive rail.
3. If you use Claude Code and want the per-spawn speed bump, copy the `Task` matcher block from
   `harness/templates/configs/claude-settings.json` into your owned `.claude/settings.json`.
   Other hosts may map their spawn event to `scripts/command-guard.sh --pre-task`.
4. No new `amh.conf` keys ship. Record `AMH_VERSION=9.1.0` and update the version named by your
   constitution after the copied scripts and any chosen adapter wiring are in place.

## 9.0.0 — 2026-08-17

- **The seed CI-triage playbook no longer claims that local-green/CI-red can only be an
  environment difference.** A downstream guard discovered files through `git ls-files`, so a
  new file was invisible during the local ladder and visible in CI after staging. The same
  script can receive different commit, index and worktree inputs; the playbook now says to
  reproduce the exact tree state CI checked and to stage new files before verification when
  discovery is index-dependent. MAJOR because an adopter following the existing binding triage
  procedure must replace it; PATCH cannot carry a required hand edit under this changelog's
  version semantics.
- **The version lockstep guard now rejects an unversioned top changelog entry.** The first
  draft of this patch called itself a PATCH in its PR impact and added an `Unreleased` entry,
  but left all five hand-maintained version copies at the already-published release; the guard
  skipped that heading, found the older numeric entry below it, and passed. The top entry must
  now name `harness/VERSION`, so that specific omission fails before review or push.

### Upgrading

Replace the **When CI fails (workflow vs code)** paragraph in your `docs/RUNBOOK.md` with the
wording from `harness/templates/seed/docs/RUNBOOK.md`.

## 8.0.0 — 2026-08-15

- **The constitution now says that it states the system as currently built — and where history
  goes instead.** The harness bounds working memory (byte band, hysteresis, landing check) and
  permanent memory (line cap, rollover, row cap), and left the most-read file in the tree
  unbounded: the constitution, the one document an agent reads in full on every turn. Adopting
  repos accrete history in it. One instance grew a "this version is user-sanctioned in full"
  paragraph for every upgrade it took, so the oldest content in the file every session loads
  was also the least useful. That instance reported it here on 2026-08-15 and its tree is not
  ours, so this sentence is the whole of the evidence — no row, fixture or artifact in this
  repository attests to it, which is worth knowing before the rule is cited as incident-backed. The seed constitution now says what it is: current rules, current
  inventory, current sanctioned configuration, with supersession history, adoption narratives
  and per-version records going to `docs/LEDGER.md` and a pointer line in the `docs/STATE.md`
  changelog. MAJOR because a repo that has been recording upgrade history in its constitution
  is now doing something its constitution forbids; the relocation is Upgrading step 11.
- **The bound is on kind, not bytes: no `CONSTITUTION_WARN_KB` ships.** Considered and refused
  in the same unit, because a cap here would import the Goodhart problem 5.0.0 and 6.0.1 were
  cut to fix. The defect a cap catches is size and this defect is kind — a constitution can be
  long and wholly current, or short and half history — so the number cannot see the thing it
  would be pointed at. Worse, over a file that is *all* live legislation the cheapest way under
  a cap is to shave a rule, which is precisely the reflex the state file's landing check and
  the ledger's maximum-not-a-target wording exist to break: a cap that invites shaving the
  paragraph rather than moving the content is worse than the prose. The precedent is 6.0.0's
  relocation of the size-rung description out of `docs/STATE.md` (**DB-029**) and its test —
  ask which of a bounded file's bytes the bound is *for* — applied one tier up. What stands in
  for the number is a reader, and the seed says exactly what that is worth: `RULE_FILES` names
  the constitution, so a diff to it raises the ladder's legislation advisory — a WARN that
  blocks nothing, is skipped in CI, and reads only the uncommitted diff. Reviewer attention is
  the enforcement; the warning only says the protocol applies. The rule also carries its own
  limit, because without it the routing is a hole: only what records the past may leave, and a
  rule that still binds stays whatever its age — relocating a live rule into retrieval storage
  is repeal with a forwarding address. No threshold, guard, fixture or exit code changed; P2's
  memory-tier table now states the constitution's discipline rather than calling it "small by
  construction" and leaving it unbounded in fact.

- **The working-memory and ledger rungs no longer print their thresholds on a green verdict.**
  Reported from an
  instance that committed both halves of the same Goodhart failure in one session: told to
  compress `docs/STATE.md` to the floor it shaved clauses across a dozen edits and landed seven
  bytes under, restructuring nothing; and it drafted two ledger rows at 828 and ~805 characters
  and trimmed them to just fit, where a 300-byte row stating the lesson tersely was the better
  artifact and never occurred to it. That instance had hand-copied 6.0.1's "the cap is a maximum,
  not a target" into its own preamble in the same session. Another clause was therefore not the
  fix: the prose is read by the same context that then optimizes toward whatever number is in
  front of it. So the number is gone from where it does no work. `guard_state_size`'s plain `ok`
  reports the size and no caps; its landing `ok` reports how many bytes **clear of the floor**
  the pass landed instead of naming the floor — the same fact without the pull toward the limit.
  Headroom is a measurement, not a score: a state file gutted to stubs prints a large one and
  passes, which is why the length-guard rule (fold whole stages, never shave) is still what
  governs the pass. The new-row rung reports each row's own length rather than the cap it cleared.
  The ledger cap rung drops the `lines/cap` form for a bare line count. Every warn and fail still
  quotes the threshold it turns on, because a rejection has to say what it rejected against — as
  do two green lines that genuinely turn on one: the small-edit `ok` naming `STATE_EDIT_DELTA_BYTES`,
  and the boot banner's size-against-soft-cap line, which is read before a session writes and is
  left deliberately alone. Fixtured in the only shape that can pin an anti-anchor: `expect_pass_not_saying`,
  three fixtures that fail the moment a threshold returns to a green line (**DB-040**).
- **Every cap an agent writes toward is now bounded in two units, and a draft satisfies both.**
  The 8.0.0 anchor removal above did not stop the reflex it was cut for: drafting a row in this
  repository still went 874 bytes → 797 against an 800-byte cap, because a session measures its
  own draft against a cap it reads from `amh.conf` — no change to what a rung PRINTS can reach an
  anchor the session builds itself. Bytes are continuous, so a byte target can always be
  approached by shaving words, which removes no content. The obvious repair, counting sentences
  instead, fails in the mirror image: rewriting `. T` to `; t` across a file collapses the count
  while freeing nothing, measured at 85 → 41 sentences and zero bytes on this repository's own
  state file. **Every single measure has a cheap satisfier, so the aim-points now carry two.**
  `STATE_COMPRESS_TO_SENTENCES` joins `STATE_COMPRESS_TO_KB` and a landing must clear both;
  `LEDGER_ROW_SENTENCE_CAP` becomes the new-row working limit with `LEDGER_ROW_CHAR_CAP` beneath
  it as a backstop against runaway sentences, its default raised from 800 to 2000 after measuring
  that the longest sentence-compliant row in this repository is ~1450 bytes. Bytes still stand
  alone where nobody aims: `STATE_WARN_KB` and `STATE_HARD_KB` say WHEN to compress, and
  `STATE_EDIT_DELTA_BYTES` classifies a shrink already made. The counter is deliberately lenient
  — a terminator ends a sentence only when what follows starts another one, `e.g.`/`i.e.` are
  folded away, and headings and list fragments count as nothing — because a phantom sentence
  would red-line honest prose, and a rule that rejects correct work gets deleted rather than
  obeyed; it fails loudly rather than returning a blank when awk cannot produce a number. Ten
  fixtures fail against the previous script, and the two that matter are the cheap moves
  themselves: a landing that keeps every sentence while dropping 93% of its bytes, and one that
  collapses the sentence count while freeing none. **What this does NOT claim** is that the pair
  cannot be gamed — a rewrite that removes the wrong content passes both, no guard can see it,
  and fold-whole-stages remains prose. MAJOR: one config key is added, one changes default, and
  the rule they enforce changes shape.
- **The inverted-gradient warning was considered and not built.** The same report proposed
  warning when a row or a compression pass lands in the top decile below the cap, making hugging
  the limit the costly move. Declined for now, on the reporter's own weighting: it invents a
  second threshold to hug, and P3/P20 say a guard accretes after a real incident rather than
  ahead of one. Removing the anchor is the cheaper intervention and is what shipped; the
  behaviour then survived it, and the answer was the unit change above rather than this warning
  — which needed no new threshold and left the second-number objection standing.
- **Redirections are removed before the command guard judges any word — fixing both a false
  denial and a silent bypass.** `git push -u origin session/x 2>&1` and `… >/dev/null` were
  BLOCKED with a reason, "this push names another branch or leaves the ref implicit", that was
  false of both: redirection words survived into the word list the refspec counter reads. The
  mandatory review pass then found the same class running the other way, and worse. A
  redirection between a command and its subcommand made `git >/dev/null push origin <default>`,
  `git >/dev/null push --force …` and `git 2>err.log push --mirror origin` return **allowed**,
  because the loop looking for the `push` subcommand stopped at the redirection; one before the
  command word hid the command from every rail, so `>/dev/null printenv` passed too. Both are
  as old as those rails. A quote-aware strip now runs before any word is judged, so position no
  longer matters, and quoting is respected in the direction that counts: a literal `'2>'`
  argument is a word bash really passes, not syntax, and the word behind it is still judged.
  Thirteen new fixtures, each demonstrated to fail against a broken implementation rather than
  merely to pass against this one. **One accepted miss is documented rather than fixed**: an
  fd-duplicating redirection placed BEFORE the operands (`git 2>&1 push --mirror origin`)
  splits the segment at the `&` and hides what follows. It predates this change, it is now in
  the guard header's "does NOT catch" block, and closing it means changing the segment splitter
  every scanner is built on.

- **An unparsed command is now blocked, not allowed.** Eighteen shipped self-test fixtures —
  every private-key case and the write-destination forms — failed on stock macOS Bash 3.2 and
  passed on a re-run at the same commit, with the guard byte-identical to a green `main` run
  and the Linux ladder green throughout. The scanners reached their word list through a process
  substitution, and an empty read took the "no words to judge" branch, which ALLOWED the
  command: the rail could report a clean read of text it never parsed. The mechanism is
  inferred and not proven — no macOS host was available — so read the repair on its merits and
  not as a closed case. Two changes. The parsers (`split_segments`, `split_words`,
  `redirect_targets`, `strip_redirections`) now fill arrays in-process instead of piping
  through a subshell; 7.0.2 removed a process pipeline on the same platform for a different
  symptom whose cause was also never established, which makes this the same shape of
  intermittency rather than the same bug. And `parse_produced_nothing` makes the discriminator
  explicit: non-blank text that parses to nothing is a defect in the guard and blocks with a
  reason saying so, while a genuinely blank segment (all redirection, once stripped) still
  passes. Against the current parsers that arm is unreachable — every non-blank string yields
  at least one word and one segment — so it is a tripwire for the next transport, not a fix in
  its own right, and two fixtures blind a parser to pin the wiring rather than the predicate. The header's "fail OPEN on malformed input" rule now says what it always meant — it
  is about a malformed command from you, not a licence for this script to call an unread
  command clean (**DC-002**).

- **The destructive advisory asks for a spelling that removes the hazard, and an abandoned
  advisory now leaves a trace.** The rail blocks a destructive command once so the session
  spends a turn on the check, and its text names two moves that are not compliance. A session
  took the second: blocked on `rm -rf $d`, it renamed the directory, dropped the deletion, and
  cleared the prompt without ever checking anything. Wording had already been tried once against
  that move, so this release changes the layer instead. The advisory now asks for the guarded
  spelling — `rm -rf -- "${S:?}/base"` — because the shell aborts on an unset or empty `S`,
  which means a session that types it mechanically still gets that much. Read the bound
  exactly: it closes the unset-or-empty case and nothing else, so a set-but-wrong variable —
  `S=/` above all, which makes the same command `rm -rf /base` again — still reaches the
  filesystem, and the advisory now asks for the guarded spelling IN ADDITION to printing the
  expansion rather than instead of it. For that to be usable the
  signature folds `${d}` and `${d:?}` onto `$d`, so the rewrite the rail just asked for counts
  as the rerun rather than arming a second prompt; the SUBSTITUTING forms `${d:-x}` and
  `${d:+x}` deliberately do not fold, because they can address a path the bare variable never
  would. Separately, the rail records whether an advised command was ever re-attempted, and
  `scripts/ladder.sh` prints the ones that were not as a `note` line. That line is not a verdict:
  it touches no counter, changes no exit code, and nothing may read it as evidence that a check
  happened or did not — it reports only what the rail can observe, which is that a prompt fired
  and the command never came back (**DC-004**).
- **A hole this found rather than closed.** `split_segments` treats `{` and `}` as segment
  operators, so an unquoted `rm -rf ${d}/build` is cut before any scanner sees it and records
  its target as the bare `$` — which every other unquoted-brace deletion also records, so they
  clear each other's advisory. Quoting records the real target and the advisory recommends the
  quoted spelling. It is in the guard header's does-NOT-catch block with the fd-duplication miss
  it shares a root with, and closing both is a change to the splitter every scanner is built on.

### Upgrading

1. **Add two `amh.conf` keys; keep the ones you have.** `STATE_COMPRESS_TO_KB` stays exactly as
   it is. Add `STATE_COMPRESS_TO_SENTENCES` beside it — a landing must now clear both — choosing
   a count that bites at about the same place as your byte floor at your file's rough
   bytes-per-sentence, or one of the two is decorative (this repository uses 9 KB and 50
   sentences at ~170 bytes each). Add `LEDGER_ROW_SENTENCE_CAP`, 6 shipped, set at the top of the
   shape your rows already have rather than out of reach — if it never binds it teaches nothing.
   Then re-set `LEDGER_ROW_CHAR_CAP` as a backstop with real headroom over your longest
   sentence-compliant row (2000 shipped, up from 800); leaving it at a value your rows already
   crowd makes it a second number to hug. Leave a key out and the shipped default applies.
   `scripts/amh-init.sh` gains `--compress-to-sentences` beside `--compress-to-kb`, and
   `{{COMPRESS_TO_SENTENCES}}` beside `{{COMPRESS_TO_KB}}`.
2. Copy the shipped scripts and the regenerated manifest. `command-guard.sh`, `ladder.sh` and
   `test-ladder-guards.sh` changed — green verdicts no longer print thresholds, and three new
   fixtures pin that. **`command-guard.sh` changed in a way that changes verdicts** — take it
   before the others if you take nothing else: pushes that redirect their output are no longer
   denied, and commands that hid behind a redirection (`git >/dev/null push --force …`,
   `>/dev/null printenv`) are no longer allowed. No threshold, config key or exit code changed.
3. **Two verdict changes and one new CLI mode in `command-guard.sh`.** The signature now folds
   `${d}` and `${d:?}` onto `$d`, so `rm -rf "${d:?}/x"` after `rm -rf $d/x` exits 0 where 7.x
   exited 2 — that is the point, not a regression. `--advisory-report` is a new argument, which
   matters if you wrap the guard's argument surface. Nothing else that passed before is denied
   now.
4. **Expect one new block reason, and treat it as a bug report about the guard.** If
   `command-guard.sh` ever says it could not parse your command, nothing was judged — the
   command is denied on that basis alone, and re-running will not clear it. Your way through is
   to report it with the command text and, if you are stuck, run outside the hooked agent;
   do not edit the arm away. No previously allowed command becomes denied by this change on a
   working parser: verified differentially against 7.0.2's guard over ~1350 command strings,
   with zero verdict or message differences.
5. **If you wrapped or forked the parsers, their calling convention changed.**
   `split_segments`, `split_words`, `redirect_targets` and `strip_redirections` used to write
   to stdout; they now fill `SEGMENTS`, `SPLIT_WORDS`, `REDIRECT_TARGETS` and `STRIPPED` and
   print nothing. A local `for w in $(split_words "$x")` now yields an empty list — which on a
   pre-8.0.0 code path meant ALLOW, this release's own failure reintroduced in your tree.
6. **Expect a `note` line after an abandoned destructive advisory, and a new sentence in the
   advisory itself.** The note names deletions the rail prompted on that never came back. It is
   informational: no counter, no exit code, nothing to fix. If you keep a local copy of the
   advisory text, take the guarded-spelling sentence with it — that sentence is the change, not
   the note.
7. **Expect your green ladder output to read differently**, and do not treat it as information
   lost. `8 KB (soft cap 14 KB, hard 16 KB)` becomes `8 KB, within the band`; a completed
   compression landing reports how far clear of the floor it landed in both units; the ledger rung
   lists each new row's sentence count rather than its byte length. Read a threshold from `amh.conf`, which is
   where it was authoritative all along.
8. **Seed prose — the ladder description and the two memory-file preambles, hand-applied, and
   they move together.** If you carry the descriptive paragraphs, take all of them or none:
   `docs/RUNBOOK.md` → **Acceptance ladder** (what the size rung prints, what it deliberately
   does not, and that the floor is now a sentence count while the caps are byte sizes), your
   `docs/STATE.md` length-guard preamble (the floor counts sentences, which is what makes
   "a ceiling, not a target" hold without depending on restraint), and your ledger volume
   preambles (the working limit is `LEDGER_ROW_SENTENCE_CAP`; `LEDGER_ROW_CHAR_CAP` is a
   backstop, and the "ladder prints both live values" sentence is no longer true of a green
   run). Copy the wording from `harness/templates/seed/docs/STATE.md` and
   `harness/templates/seed/docs/LEDGER.md`. Leaving the old wording in place leaves your docs
   describing output your ladder no longer produces, and a rule in a unit it no longer uses.
9. **Seed prose — the constitution rule, hand-applied.** Copy the two-paragraph blockquote from
   `harness/templates/seed/AGENTS.md` — it sits directly under the long-term-memory paragraph —
   into your own constitution, adjusting the file names if your tree spells them differently.
10. **Confirm your constitution is in `RULE_FILES`** in your `amh.conf` before you rely on the
   advisory that step 12 leans on. `amh.conf` is yours forever and was installed once, so a repo
   that pruned the list — or predates its constitution being in it — has no advisory at all,
   and nothing else will tell you.
11. **Then relocate what your constitution has already accreted.** Read it for content that
   records the past rather than states the present: rules kept "for context" after they stopped
   binding, adoption and upgrade narratives, and any per-version paragraph recording that a
   version was reviewed or sanctioned. Each becomes one dated ledger row — what was sanctioned,
   by whom, when — appended to your live volume, plus **one** pointer line in the
   `docs/STATE.md` changelog for the migration as a whole, not one per paragraph moved; a
   byte-capped file should not absorb ten lines for one cleanup. Then delete the paragraphs.
   **A rule that still binds stays, whatever its age**, and this is the half to get right: a
   live rule moved into the ledger is repealed, not tidied — retrieval storage is grepped, not
   read, so nothing will apply it again. This is a move of history, not a compression pass:
   nothing here licenses shortening a live rule, and if you find yourself rewording one to save
   space you are doing the thing the second bullet above refused to build a cap for. Relocation
   is legislation — take the review protocol, and treat a bulk pass as an owner decision.
12. **What this does to your tripwire — read it before step 11 worries you.** An in-file "this
   version is sanctioned in full" paragraph was never what let a reviewer tell a sanctioned
   upgrade from an injected edit: it lives inside the very file an injection would edit, so
   anything able to add a rule is able to add its own sanction for it, and nothing consumes it
   anyway. (It was legal prose — the ban on attestations is on *machinery*, not on a sentence a
   human may disbelieve — so this is an argument about accretion and provenance, not about a
   rule you broke.) What actually discriminates is unchanged by this release: the `RULE_FILES`
   warning on the diff and the review protocol behind it. What step 11 leaves behind is strictly
   better on the axis that matters here — a dated row in an append-only file whose ordering a
   guard checks against `HEAD`, rather than a paragraph in a file where an edit fails nothing.
   State the trade honestly to yourself, though: the ledger is deliberately **not** in
   `RULE_FILES`, so the records move to a file the advisory does not watch. Better provenance,
   less review surface. Keep exactly one current-state line naming the adopted version — you
   already have it, and step 7 of `docs/UPGRADING.md` is what keeps it true; what goes is the
   paragraph per version.

## 7.0.2 — 2026-08-15

- **Destructive-advisory signatures stay inside Bash.** The 7.0.1 release-tag verification
  produced signature-collision symptoms across all eight distinct-target fixtures under stock
  macOS Bash 3.2. Target sorting and joining no longer cross the implicated process pipeline;
  reversed-order coverage pins the canonical target-set behavior too.

### Upgrading

1. Copy the shipped scripts and regenerated manifest. No configuration or seed changes are
   required.

## 7.0.1 — 2026-08-15

- **The stock macOS toolchain is supported.** The initializer no longer passes GNU-only `--`
  to BSD `chmod`, cleans its temporary file if a mode change fails, and the redactor now parses
  under macOS's Bash 3.2 and uses a sed range program accepted by both BSD and GNU sed.
- **The fixture suites no longer require GNU `sed -i`.** Disposable fixture edits use a
  portable temporary-file helper, and the repository verification driver no longer requires
  Bash 4's `mapfile`. Citation-row extraction also uses the BSD/GNU-common extended-regex
  spelling rather than GNU-only basic-regex quantifiers.
- **The supported toolchain floor is explicit.** The README names stock macOS, GNU/Linux,
  and Windows Git Bash next to Quick Start, including the Bash floor and the unsupported native
  Windows shells.
- **The supported environments are exercised in CI.** Linux retains the full acceptance ladder;
  stock macOS Bash 3.2 and Windows Git Bash run the shipped guards and a fresh installer smoke
  test with ShellCheck installed for each host. Reusable release verification waits for the
  Linux ladder and both portability jobs.

### Upgrading

1. Copy the shipped scripts and regenerated manifest. No GNU-tool installation or PATH override
   is needed on macOS; Windows adopters run AMH through Git Bash.

## 7.0.0 — 2026-08-13

- **The push rail now enforces the configured session namespace.** A real Codex session pushed
  a generic `work` branch even though `BRANCH_PREFIX=session`; prohibiting only the default
  branch left the positive naming rule as prose. `git push` must now name exactly one explicit
  ref under `<BRANCH_PREFIX>/<codename>` rather than relying on the current branch implicitly.
- **PR-template use is now binding in the adopter constitution.** A real PR was created with an
  invented body despite `.github/pull_request_template.md`. This stays prose rather than a rail:
  `gh` rejects combining `--template` with `--body-file` in non-interactive use, and a gate over
  either flag would block a valid filled template or accept an untouched one. Dedicated forge
  tools also bypass Bash hooks, so the action-point instruction is the honest cross-agent layer.
- **Branch-train PR descriptions must cover the whole train.** The PR for this release initially
  described only its final delivery-rail unit even though its diff also carried the lifecycle
  hooks, project reviewer, bearer-fixture guard, and earlier prose change. The adopter
  constitution now requires the PR body to describe the entire base-to-head diff, including
  earlier units and not only commits from the current session.

### Upgrading

1. Copy the shipped scripts and regenerated manifest.
2. This is a major release because pushes that previously reached non-default, non-session
   branches are now blocked. Rename or recreate in-flight branches under the configured
   `BRANCH_PREFIX` before pushing.
3. No Stop hook is added in this unit. Codex Stop hooks can request another model turn, but a
   hook cannot reliably infer that an arbitrary response is the final delivery message. A
   completion-only Owner-queue reminder needs a non-self-reported trigger before it can become
   a gate; until then SessionStart and the constitution remain the honest layers.

## 6.1.0 — 2026-08-13

- **Codex now runs the agent-neutral lifecycle rails.** The repository config wires one
  synchronous `SessionStart` hook to `scripts/session-start.sh` and one Bash `PreToolUse` hook
  to `scripts/command-guard.sh`, resolving the repository root before either call and bounding
  both runtimes. `.codex/rules/amh.rules` remains the static lower layer. Codex can block the
  shell call, but cannot currently suppress or rewrite tool output, so no `PostToolUse`
  redaction hook is claimed or installed. Codex-shaped payload fixtures pin the documented
  `tool_input.command` path, Bash dispatch, blocking reason, allowed case and fail-open cases.

- **Codex adopters can select a project-scoped AMH rule reviewer.** The custom-agent profile
  performs the runbook's existing fresh-context review classes over the real uncommitted diff,
  rule sources, and fixtures. It is read-only by both sandbox configuration and instruction,
  does not pin a model or reasoning effort, and produces human-readable findings that no gate
  may treat as an attestation. The initializer installs it only inside the repository's Codex
  adapter tree, and adapter-set coverage keeps its template, reference copy, installer action,
  `RULE_FILES`, and `ADAPTER_FILES` synchronized.

### Upgrading

1. Copy the shipped scripts. `command-guard.sh` and `test-ladder-guards.sh` changed for Codex
   payload dispatch and its regression coverage; the other shipped scripts are unchanged.
2. **Existing Codex adopters, hand-applied:** copy
   `harness/templates/configs/codex-agents/amh-rule-reviewer.toml` to
   `.codex/agents/amh-rule-reviewer.toml`. The initializer preserves adopter-owned adapter
   files on re-runs, so it will not replace a file already present at that path.
3. **Existing Codex adopters, hand-applied:** existing adopters own `.codex/config.toml`; copy
   or merge the `SessionStart` and `PreToolUse` hook tables from
   `harness/templates/configs/codex-config.toml` manually. Start Codex in a trusted project,
   open `/hooks`, review the exact hook definitions, and trust them before expecting the hooks
   to run. Keep `.codex/rules/amh.rules` as the static lower layer.

## 6.0.1 — 2026-08-13

- **The ledger row cap is now named as a maximum, not a target.** The old seed correctly said
  rows may be shorter than `LEDGER_ROW_CHAR_CAP`, but left the familiar threshold reflex open:
  draft a long narrative, then shave it until the guard passes. The ledger preamble and config
  template now say to write the durable lesson at its natural size, even far below the cap, and
  never trim a draft toward the limit. No threshold, guard, fixture or exit code changed.

### Upgrading

1. Copy the shipped scripts. No shipped `.sh` file changed; from 6.0.0 this updates only the
   manifest's release-version header.
2. **Seed prose, hand-applied and recommended.** Copy the maximum-not-target wording from
   `harness/templates/seed/docs/LEDGER.md` into each ledger volume's preamble. If you maintain a
   commented config template, make the same point beside `LEDGER_ROW_CHAR_CAP`. Skipping this
   optional clarification changes no verdict, which is why 6.0.1 is a PATCH.

## 6.0.0 — 2026-08-11

- **The secret-file rails covered `.env` and stopped there; they now reach private keys, and
  `.pem`/`.key` get a speed bump rather than a block.** The question that started it was
  whether `.pem`, `.key` and `id_rsa` belonged in the safeguard. They do not belong in the
  same tier, and the reason is what the guard was already built on: a block reason must be
  true of the file it names. `id_rsa` and its siblings (`id_dsa`, `id_ecdsa`, `id_ed25519`,
  the `_sk` variants) have an empty benign population — nothing else is called that — so they
  join `.env` and `/proc/<pid>/environ` in the block tier, across every path that reaches a
  file: the reader list, `<` redirection, and `cp`/`mv`/`install`/`dd` sources. The `.pub` half
  is excluded by construction rather than by a carve-out — the list matches exact literals, so
  the public key falls through — because blocking `cat id_rsa.pub` would give a credential
  reason to a command that exposes nothing. `.pem` and `.key` are
  container extensions rather than secret markers — `fullchain.pem` and a CA bundle are public
  by design — so they get the one-time advisory that `.env` already had: blocked once with an
  explanation, allowed on the rerun. Its pattern requires the extension to end the word, since
  `Object.keys(x)` and `jq '.keys[]'` are ordinary program text. That excludes the plural only:
  a singular `jq -r '.key'` still spends the bump, which is fixtured as a decision rather than
  left to be discovered, and costs one rerun because this tier denies nothing.
- **What earned the change beyond the question.** `redact.sh`'s `private_key_block` class
  matches the `-----BEGIN … PRIVATE KEY-----` header **line**, and the substitution is
  line-oriented, so the base64 body prints in the clear. For key material the read-side rail is
  not one of three layers — it is the only mechanical one, which is the opposite of the
  situation for tokens, where the prefix classes catch a great deal of what leaks. That is what
  earned the block tier for `id_rsa`, and it is why the next bullet exists: the finding was
  shipped as a known gap and closed in the following unit rather than left as a comment.
- **And the redactor became a real second layer for key material.** The finding above was left
  standing for one commit and then fixed on the owner's call: `private_key_block` is a per-line
  class, and a private key's value is the base64 body under the header, so the filter printed
  `[REDACTED:private_key_block]` and then the whole key. A `private_key_body` stage now runs
  before the token substitutions, anchored as a range between the `BEGIN` and `END` markers, and
  inside that range it replaces lines that are wholly base64 — any length, optional padding,
  nothing else on the line. Both bounds are load-bearing and both are fixtured: without the
  anchor a 64-character manifest hash redacts, and without the shape restriction an unterminated
  header swallows every line after it, which is what a truncated log and a repository full of
  prose about key handling both look like. There is deliberately no LENGTH floor. The first
  version had one, at 32 characters, justified by a comment nobody checked against a key: real
  RSA-2048 bodies end in a 20- to 28-character line, so every key would have printed its tail
  under a marker saying it had been handled. Inside the anchor there is no benign base64
  population to protect, so the floor bought nothing and cost the tail. Two residues are named
  and fixtured rather than implied away: after an unmatched header a lone alphanumeric word is
  redacted, and a key embedded in a JSON or logfmt line is not reached at all, because its body
  shares a line with other text.
- **Adapters moved with the guard.** The Claude deny rails gain `Read()` entries for the six
  key stems (bare and nested), and the Codex rules gain a reader prefix rule for the same six
  stems (bare and `./`) — the spellings each layer can actually express, with the `.pub` half absent
  from both on purpose. Neither layer denies `.pem` or `.key`, and the rules file says so in a
  comment, because a silent omission and a decision look identical six months later.
- **The length-guard preamble is compressed, in the seed and in this repository's own state
  file.** That preamble is legislation living inside working memory, so its bytes are charged to
  the very budget it rations: at the compression floor it was spending a fifth of the file on
  rules about how to spend the file. About 15% of the seed's copy is gone, all of it
  restatement — the same idea said twice, or a justification the cited row already carries — so
  each rule, citation and caveat survives exactly once. No rule was dropped: every clause up
  there was bought by an incident with a ledger row behind it, and shaving one to make the
  paragraph shorter is precisely the move the paragraph forbids for the file below it. The
  review pass is why that last sentence is true rather than merely intended: a first cut of this
  repository's own copy took out the two clauses release **5.2.1** existed to add — which numbers
  the size rung prints, and why a printed one is never a value to copy back — and they are
  restored, so
  the saving there is a much smaller 10%. No threshold, guard, fixture or exit code changed;
  `guard_state_size` and `guard_state_structure` are untouched.
- **And the description of the ladder's output left working memory entirely.** Compressing that
  preamble hit a floor the review made visible: a quarter of this repository's copy and an eighth
  of the seed's was never a rule, but an account of which thresholds `guard_state_size` prints
  and why a printed number must never be quoted back into prose — the subject of release 5.2.1,
  and the part that must not be shortened. Relocating it is not compression: `docs/STATE.md`'s
  preamble forbids cutting text into another file, and now carries the exception in writing.
  Owner call: it belongs under `docs/RUNBOOK.md` → **Acceptance ladder**, which no byte cap
  governs. The seed and this instance both move it there and leave a pointer where it stood, so
  the rules stay in the file the guard measures and the description stops competing with an
  adopter's actual session memory. Measured across both units, the seed's preamble is 20% smaller
  than it was at 5.2.1 (4084 → 3271 bytes) and this repository's 16% (1699 → 1420) — less than a
  first pass appeared to buy, because what looked compressible was mostly the part that had to be
  preserved verbatim or moved intact. Still no threshold, guard, fixture or exit code changed.
- **The destructive-command advisory rearms per TARGET, not per category.** A downstream
  session was blocked on `rm -rf "$S/base"`, renamed the target so the `rm` was not needed, and
  described it accurately: "I routed around the trigger to save a turn." Three defects behind
  that, all now fixed. (a) The state was one marker file per category, so the first `rm -rf` of
  a session — typically a scratch directory — spent the rail for every later deletion on any
  path. The file now holds one signature per operand set AS WRITTEN — the command text, not a
  resolved path, which the advisory now states outright rather than leaving a reader to assume
  the guard expands anything: rerunning the SAME deletion proceeds,
  which is what "rerun to proceed" has always meant, and a deletion aimed somewhere new is
  advised on its own. The `dotenv` and `keymaterial` rearms are untouched; this rail diverges
  because for a deletion the target IS the risk. (b) The advisory never named the failure mode
  it exists for. It now detects an operand that begins with a plain variable reference and
  contains a `/` — `rm -rf "$S/base"` is `rm -rf /base` when `S` is empty — and asks for the
  non-empty check, saying why the guard cannot make it (it sees the command before the shell
  expands it). Command substitutions, defaulted expansions like `${S:-/tmp}` and the always-set
  `HOME`/`PWD`/`TMPDIR`/`ROOT` are excluded: none has the empty case, and a rail that fires its
  loudest paragraph on the commonest safe spelling is one an agent learns to skim. Those, and a
  variable anywhere else in a path, get the weaker form of the same request. (c) The old text
  suggested "moving the path set to a temporary directory", which is the sidestep that was
  taken. It is gone, and the advisory now says outright that renaming or relocating the target
  to avoid the deletion is not compliance, nor is rerunning without having looked. Advisory
  prose is the entire intervention on this rail — nothing downstream consumes it — so the
  clauses are pinned by fixtures in BOTH directions: what the advisory must say, and what it must
  not claim. Each new behaviour was checked against a mutant that removes it, including the
  parser rewrite and the signature's quoting; operands are `%q`-quoted and prefixed with the
  command kind, so `rm -rf "a b"` and `rm -rf a b` are different deletions and `git clean -fdx`
  cannot be cleared by an `rm` whose operand spells a sentinel.
- **Accepted, and fixtured so it is a decision rather than a surprise:** a one-word grep
  PATTERN is indistinguishable from a path once quotes are stripped, so `grep -rn "id_rsa"
  docs/` is blocked — exactly as `grep -rn ".env" docs/` has always been. The fix would be a
  change to `split_words` covering both names at once, not a carve-out for this one.

### Upgrading

1. **Copy the shipped scripts.** `scripts/command-guard.sh` and `scripts/redact.sh` changed. The
   manifest ships beside them. If you pipe tool output through the filter, expect a new
   `private_key_body` marker in it; `redact.sh --classes` now names that class.
2. **Expect three new blocks.** Reading, redirecting from, or copying a file named `id_rsa`,
   `id_dsa`, `id_ecdsa`, `id_ecdsa_sk`, `id_ed25519` or `id_ed25519_sk` is now denied outright.
   If a session task legitimately needs one — a deploy step, an SSH fixture — point the tool at
   the path instead of reading the file, use the `.pub` half, or take it to the Owner queue as
   a narrower evidence contract. This is the MAJOR: a command that worked yesterday stops.
3. **Expect one new speed bump.** The first command in a session naming a `.pem` or `.key` file
   is blocked once with an explanation and allowed on the rerun, the same shape `.env` has had
   since 4.1.0. Nothing is permanently denied.
4. **Adapter rails, hand-applied.** If you run the Claude or Codex adapter, copy the new deny
   entries from `harness/templates/configs/claude-settings.json` and
   `harness/templates/configs/codex-amh.rules`. Skipping this leaves the pre-execution guard
   working and the static net one layer thinner.
5. **Seed prose, hand-applied, optional — two files that move together.** `docs/STATE.md`'s
   length-guard preamble is ~20% shorter, and the paragraph describing what the size rung prints
   now lives in `docs/RUNBOOK.md` under **Acceptance ladder**. No rule, threshold or guard
   behaviour changed. If you take it, take both halves: copy the new preamble from
   `harness/templates/seed/docs/STATE.md` and the new paragraph from
   `harness/templates/seed/docs/RUNBOOK.md`, or you will delete a description you have nowhere
   else. Skipping the pair entirely costs nothing.
6. **Expect the `rm -rf` speed bump more than once per session.** It used to fire on the first
   destructive command and stay quiet afterwards; it now fires once per distinct target set.
   Rerunning the same command still proceeds immediately, so no command is newly denied — but a
   session that deletes several different path sets will see several advisories. That is the
   point of the change, not a regression. `DESTRUCTIVE_ADVISORY_STATE` still overrides the state
   path; its contents are now one signature per line rather than an empty marker, so a stale
   file from an older version simply advises once more per target.

## 5.2.1 — 2026-08-10

- **The seed `docs/STATE.md` length-guard preamble described the ladder's output wrongly, and
  the sentence is corrected.** 5.1.0 stopped the preamble restating configured numbers and told
  the reader to get them from `amh.conf` — right, and it added one inference too many: the
  ladder "names the soft and hard caps when it passes and the compression floor only when it
  warns or fails, so the floor is the one value a healthy tree never prints." The floor is not.
  `guard_state_size`'s landing branch prints it on the `ok` line that confirms a completed
  compression landing (`crossed below the soft cap and landed at N bytes, at or under the
  M-byte floor`), so a run in which every rung is green prints the floor — the shipped fixture
  `state_landing_good` builds exactly that case. The claim was wrong in the direction that
  matters: an agent that believes a green ladder never names the floor, and then sees it named,
  has been handed a reason to doubt a passing run or to go looking for a defect that is not
  there. The preamble now says which numbers the ladder prints and that they are derived from
  the config rather than copied out of it — the landing line reports bytes where the key is in
  KB — and drops the inference. Nothing else in the paragraph changes: the rule against
  restating thresholds as numbers stands, and it is the reason the sentence existed. No guard,
  threshold, fixture, template mechanism or exit code changed — this is prose only.

### Upgrading

1. Copy the shipped scripts. No shipped script changed in this entry, so this is a no-op unless
   you are also crossing an earlier version.
2. **Seed prose, hand-applied, recommended.** If you adopted at 5.1.0 or 5.2.0 you copied the
   sentence above into your own `docs/STATE.md` length-guard preamble. Search it for "never
   prints" — or for any claim that a passing ladder does not name the compression floor — and
   replace it with the corrected wording in `harness/templates/seed/docs/STATE.md`. Nothing you
   do today becomes wrong if you skip this; what you lose by skipping it is the ability to read
   your own guard's output at face value.
3. Nothing else. No configuration key, threshold or script behaviour moved.

## 5.2.0 — 2026-08-10

- **The seed `docs/STATE.md` length-guard preamble now says what the ladder does NOT check.**
  The preamble enumerated the machine-checked properties and stopped there, so a reader who
  finished it had an accurate list of what is enforced and no statement anywhere that the list
  was complete. Everything after it — grow freely to the soft cap, no trimming below that line,
  fold whole stages rather than shaving clauses — reads in the same voice and is prose only. The
  gap is not hypothetical: an adopting instance ran a voluntary deep compression on a STATE file
  that was *already under* the soft cap, got a plain `ok` size line, and reported the landing
  check as holed. It is not holed. The landing check is only ever reached by a file that started
  above the cap, which is deliberate and is what keeps an ordinary edit — deleting one resolved
  Owner-queue item — from being failed as an unfinished compression pass. But that half of the
  size guard is then silent, and silence in a tool that speaks on every other rung reads as
  approval. The preamble now closes its enumeration explicitly — and the enumeration itself
  gained the repeated-heading and non-empty-body checks it had been missing — names the sub-cap
  case, and says why reaching for a threshold to cover it is the wrong repair. The closure is
  written as a claim about two named functions in `scripts/ladder.sh` rather than a timeless
  "and nothing else", because the script upgrades independently of a seed the adopter owns. No
  guard, threshold, fixture or exit code changed.

### Upgrading

1. Copy the shipped scripts. No shipped script changed in this entry, so this is a no-op unless
   you are also crossing an earlier version.
2. **Seed prose, hand-applied and recommended.** If your `docs/STATE.md` length-guard preamble
   lists what the ladder machine-checks, check the list is complete — repeated headings and
   non-empty section bodies are easy to omit — then add the paragraph closing it and the one
   saying the landing check never runs below the soft cap. Copy the wording from
   `harness/templates/seed/docs/STATE.md`. Worth doing even though nothing breaks without it:
   what it prevents is an agent treating a green ladder as a verdict on an edit the ladder never
   examined.
3. Nothing here changes a verdict. A tree that was green stays green.

## 5.1.0 — 2026-08-10

- **Seed prose names configuration thresholds by key instead of restating them as numbers.**
  The seed `docs/STATE.md` preamble carried `{{WARN_KB}}` / `{{COMPRESS_TO_KB}}` /
  `{{HARD_KB}}` and the seed `docs/LEDGER.md` and `AGENTS.md` carried `{{LINE_CAP}}`. Each was
  substituted once at init and then sat in the adopter's prose with nothing binding it to
  `amh.conf` — the drift class 5.0.0 demonstrated, where three volume preambles kept stating a
  cap the guard had stopped honouring. The prose now names `STATE_WARN_KB`,
  `STATE_COMPRESS_TO_KB`, `STATE_HARD_KB`, `LEDGER_LINE_CAP` and `LEDGER_ROW_CHAR_CAP` and says
  why it does not repeat their values. No guard, threshold or exit code changed; the four
  placeholders are still used by `amh.conf.example` and still documented.

- **The seed constitution and seed runbook gained the coverage-before-absence rule.** Before
  reporting that something does not exist or never happened, establish that the command you ran
  could have seen it. It is the failure class this project has recorded most often, and none of
  what it had — ledger rows, a conformance fixture, a line in the session banner — was
  something an adopting repository receives. Prose-only, and stated as prose-only: the defect
  is the generalisation drawn from a command's output, which no pre-execution rail can observe.

### Upgrading

1. Copy the shipped scripts. No shipped script changed in this entry, so this is a no-op unless
   you are also crossing an earlier version.
2. **Seed prose, hand-applied and optional.** If your `docs/STATE.md` or ledger preambles state
   a cap as a number, replace the number with the `amh.conf` key that holds it. Nothing checks
   preamble prose against your config, which is the whole reason: the number can only ever be
   right by someone remembering to edit it. Your existing numbers keep working until a
   threshold moves.
3. **Seed prose, hand-applied and recommended.** Add the coverage-before-absence rule to your
   constitution and to your runbook's session discipline. Copy the wording from
   `harness/templates/seed/AGENTS.md` and `harness/templates/seed/docs/RUNBOOK.md`.
4. Nothing here changes a verdict. A tree that was green stays green.

## 5.0.0 — 2026-08-09

- **The default `LEDGER_ROW_CHAR_CAP` drops from 2000 to 800.** The cap exists to keep a
  ledger row a durable lesson rather than a debugging narrative, and 2000 was not applying
  that pressure: of the six rows this repository has written since the guard landed, the
  longest is 1657 bytes, so the cap never once bound. 800 is deliberately below all six — the
  median is 1377 — because the intent is that a row should be about half the length these
  are, not that the longest tail should be trimmed. Expect it to bite immediately; that is
  the point, and it is why this is a MAJOR.

  The guard logic is unchanged. Only the shipped default and this repository's configured
  value move, and rows already committed at `HEAD` remain exempt, so no history is rewritten
  or retroactively failed.

### Upgrading

1. Copy the shipped scripts.
2. **You inherit the new default only if your `amh.conf` omits `LEDGER_ROW_CHAR_CAP`.**
   `scripts/ladder.sh` assigns its built-in defaults first and sources `amh.conf` afterwards,
   so a key you set wins and your `amh.conf` is never overwritten. If you omit the key, want
   the old behaviour, and do not want to think about it again, set `LEDGER_ROW_CHAR_CAP=2000`
   explicitly — that is the whole of the MAJOR for you.
3. **Check your ledger preamble.** If it states the cap as a number in prose, that number is
   now wrong; nothing checks preamble text against `amh.conf`, so an agent reading it will
   write rows the ladder then rejects. This repository states it in three volume preambles and
   updated all three.
4. Nothing already committed changes verdict. The first row you write after upgrading is the
   one that will feel it.
5. New adopters: `harness/templates/amh.conf.example` now ships 800 explicitly, so a fresh
   `amh.conf` carries the value rather than inheriting it.

## 4.2.0 — 2026-08-09

- **Repo-local guards can warn.** `scripts/guards/*.sh` had two verdicts; there are now three.
  Exit 0 passes, exit 2 whose output begins `WARN ` warns — it lands in the ladder's warning
  count and verdict line without turning the run red — and any other non-zero still fails. The
  marker is required because bash exits 2 on a syntax error, so a guard that stopped parsing
  is still reported as broken rather than as a mild opinion. Reach for the warning when a rule
  is usually right but may have a legitimate exception nobody has enumerated: failing closed on
  one of those teaches people to delete the guard instead of reading it.

- **The session bootstrap rearms every one-time advisory, not just `.env`.** 4.1.0 shipped a
  shared advisory mechanism with two categories but a rearm written for one: the
  destructive-command advisory stayed spent for the lifetime of a long-running container
  instead of for one session. `scripts/session-start.sh` now clears every advisory state file
  belonging to the repository, and forces globbing on for that expansion so a `set -f` or
  `GLOBIGNORE` in your `amh.conf` cannot switch the rearm off in silence. The advisory texts
  are unchanged: only the `.env` one states the session scope in words.

### Upgrading

1. Copy the shipped scripts. The advisory texts are unchanged.
2. **Check whether any repo-local guard of yours already exits 2**, and if so whether its first
   line of output begins `WARN `. Reclassification is mechanical — exit code plus output
   prefix, never intent — so such a guard stops failing your ladder and starts warning on it.
   `grep -rn 'exit 2' scripts/guards/` finds them; nothing else in this release can change a
   verdict you have today.

## 4.1.0 — 2026-08-05

- **Destructive filesystem commands get a one-time advisory.** Recursive forced removal and
  forced directory cleaning now pause once with safer alternatives and proceed through the
  normal rails when intentionally rerun. The advisory mechanism is shared with the existing
  `.env` speed bump, while shell-aware parsing keeps command-shaped prose out of scope.

- **The command guard has a one-time `.env` advisory.** The first command text in a session
  that mentions `.env` is blocked with a diagnostic explaining why credential-file access is
  dangerous and how to proceed if the match is a false positive. The advisory deliberately
  rearms at session start and then stays spent for the rest of that session, so broad
  interpreter snippets get one salient warning while the existing precise secret-file rails
  remain responsible for definite reader commands.

- **Runtime restatement is named as a guard design principle.** Diagnostics should restate only
  the narrow, incident-earned behavioural rules whose failure is likely and expensive, naming
  why the tempting action is dangerous and the safe next move without implying coverage the
  guard does not have.

### Upgrading

1. Copy the shipped scripts if you want the new `.env` and destructive-command advisories. No
   adopter action is required for the principle clarification.

## 4.0.0 — 2026-08-04

Three externally-authored RFCs were entered as data, adjudicated claim by claim, and mostly
refused; what survived is here. No shipped script was added, no artifact format was introduced,
no dependency was taken, and no exit code changed.

- **The ladder says green OF WHAT.** All five verdict lines now name the commit they verified
  and whether the tree that was verified IS that commit — `HEAD <sha>, worktree clean`, or a
  count of uncommitted paths and a sentence saying in those words that the verified tree is not
  that commit. The ladder verifies the WORKING tree (the secret and citation scans read
  untracked files), so a green run rendered as a bare sha was a claim about something nobody
  checked. Four states are distinguished, because two of them read exactly like "clean" if they
  are collapsed: no repository, git refusing to answer, an unborn HEAD, and a real commit. The
  probe reads the same sources the guards read rather than `git status`, which honours a
  configuration key that let a tree print a guard failure on untracked content and
  `worktree clean` in the same run. Only the count of paths is printed, never their names.

- **The session banner reports a runtime inventory.** Two new `amh.conf` keys —
  `REQUIRED_TOOLS` and `ADAPTER_FILES` — are probed at session start and printed. Tools are
  `observed` or `unavailable`; adapter files are `configured` or `unknown`, **never** observed
  and never unavailable, because a file's presence is a request for an integration and not
  evidence a hook ever fired. Nothing reads these states: they are output for a human, and the
  adapter-set guard reads the LIST, never a state. Tools are probed with `type -P`, not
  `command -v`, which resolves builtins and functions — the first version of this reported the
  script's own helper function as an installed tool.

- **What was refused, recorded because a refusal is as durable as an acceptance.** A runtime
  capability manifest and the script to write it; lifecycle-hook probing (no marker can name its
  caller); runtime profiles; a versioned JSON run receipt and its status tool (forgeable, and a
  flat enum cannot express a verdict space where WARN deliberately outranks `skip`); CI receipt
  artifacts. Each refusal has a stated argument in this repository's ledger rather than in a
  changelog bullet.

- **A behavioural conformance lab, which you do not receive.** `conformance/` is repo-local and
  is not installed into an adopting repository — the installer copies only from
  `harness/templates/`, and the end-to-end installation test now asserts the absence rather than
  leaving it structural. It exists because a few of this harness's rules are prose that no guard
  can ever reach: anything checking whether a session "verified" something consumes the session's
  own say-so, which is the attestation shape the constitution bans. Two scenarios, seeded on
  recorded failures. **It demonstrates that its evaluators are deterministic and
  mutation-sensitive, and nothing whatever about how any agent behaves** — that sentence travels
  with every mention of it, including this one.

- **The ledger's volume scheme no longer ends at Z, and "which file is live" is computed.**
  The row pattern is `D[A-Z]*-[0-9]+` rather than `D[A-Z]?-[0-9]+`, so a `DAA-` row is seen by
  the cap rung and by the citation guard instead of matching nothing in both at once; the
  rollover failure NAMES the next volume, file name and row prefix, as an odometer over A–Z
  with carry (`Z`→`AA`, `AZ`→`BA`, `ZZ`→`AAA`) rather than a table whose last entry was the
  bug. The same carry rule decides which volume is live: the volumes are a **chain** walked
  from the base volume and the walk stops at the first missing link, replacing "the last file
  the shell globbed" — which was the shell's collation order, not volume age, and pinned the
  live volume at Z. Membership is reachability rather than spelling, so no name-shaped rule can
  promote a file that belongs to no chain; anything volume-shaped the walk does not reach is
  named in a warning, and a missing base volume fails rather than reporting `no ledger yet`.
  Row scanning follows the same chain, so the cap rung and the citation guard can no longer
  disagree about what a volume is.

- **Citations are matched as whole words.** Unanchored, the wider row pattern matches inside
  longer words and reports ids that appear nowhere in the tree; whole-word matching also closes
  the same trap one letter down, where an `XL-003` in a file read as a citation to `L-003`.
  That one had shipped.

### Upgrading

1. **Copy the shipped scripts** — the whole directory, manifest included. The ladder's new
   verdict line and the session banner's inventory come with them, and neither changes an exit
   code or the meaning of any existing line. The volume-scheme change does move guard verdicts,
   in three directions worth checking before you copy:

   - **The citation pattern now admits any number of capitals between the `D` and the hyphen**,
     as a whole word. A standalone token of that shape inside `CITATION_SCAN_PATHS` — `DEBUG-2`
     and the like — now reads as a citation to a row you do not have and fails the ladder on a
     file nobody touched. Check with `grep -rwoE 'D[A-Z][A-Z][A-Z]*-[0-9]+' <your scan paths>`;
     note the two-or-more-capitals spelling, since one capital is an ordinary `DA-` citation
     that still resolves. The fix is a rename or a `CITATION_EXCLUDE` entry, never widening the
     exclusion to the whole tree.
   - **A volume the chain cannot reach stops being live.** If you named a continuation volume
     anything other than the base name plus `_A`, `_B`, … — LEDGER_part2.md, LEDGER_v2.md —
     it was the live volume under the old glob rule and is now unreachable: the rung warns and
     names it, and measures the last volume the chain does reach. Rename it into the scheme.
   - **A ledger with continuation volumes but no base volume now fails** instead of reporting
     `no ledger yet`, which was a skip that read like a pass.

2. **Add the two new `amh.conf` keys**, both space-separated lists:

   - `REQUIRED_TOOLS` — the commands your ladder needs on PATH. List a tool your CI installs but
     your laptop does not, if you have one; being told it is `unavailable` locally is the point.
   - `ADAPTER_FILES` — the agent-adapter files your repository ships.

   Leaving either empty is a supported answer: the corresponding banner line simply does not
   appear. Copy the commentary from `harness/templates/amh.conf.example`, which explains what
   each state does and does not assert — the distinction is the reason the keys exist, and a
   value without it invites the states to be read as evidence.

3. **One seed change, hand-applied.** `harness/templates/seed/docs/LEDGER.md`'s rollover
   paragraph ended in an open-ended ellipsis (_B.md/DB-001, …), which is the spelling that
   invited a scheme with no rule past Z. Your copy is yours, so apply it by hand: the suffix
   advances by carry without limit, the ladder prints the next volume's name for you, and the
   volumes are a chain walked from the base file — a volume the walk cannot reach is not a
   volume, however well it is named. Nothing else moved: no other binding rule, and no guard
   verdict beyond the three named in step 1 changed for a tree that was green before.

## 3.0.0 — 2026-08-02

One binding rule changed — a completed plan may now be retired into the archive instead of
deleted — which is what makes this a MAJOR. Around it: a second first-class agent adapter, an
agent-neutral branch namespace, and the hardening the external-review plan owed. Two rails now
state what they do **not** cover, which is the part of this release most worth reading. (The
reference instance's own constitution was also compacted to a ~110-line entry context, but that
is a change to this repository, not to anything you receive: the shipped seed constitution
gained the hookless-rail rule and the guard-limits pointer, so it grew.)

- **BREAKING — completed plans may be retained in the archive.** P2 now names a completed plan
  as a document that can be retired whole. Session discipline moves a completed plan worth
  retaining from `docs/plans/` to `docs/history/` when that optional tier exists, rather than
  requiring every plan to be deleted. Durable outcomes still go to the ledger and changelog,
  and implementation artifacts still cite ledger rows rather than archived plans.

- **The plan lifecycle is internally consistent across live operational prose.** The shipped
  plan-orphan advisory now coaches the archive-or-delete completion step, its scaffold describes
  that behavior, and this repository's active plan retires whole into the archive instead of
  following its stale deletion-only instruction. Advisory verdict behavior is unchanged.

- **P11 now names its full citation scope.** The principle says code and workflow comments,
  and describes the configured implementation paths the citation guard actually scans, rather
  than narrowing the machine-checked half to code alone. The guard diagnostics and rule-review
  checklist use the same scope. No enforcement behavior or adopter action changes.

- **Codex is a first-class adapter.** `harness/templates/configs/codex-config.toml` and
  `codex-amh.rules` ship, and the initializer installs them. The adapter is honest about its
  original layers: at that release Codex exposed no repository-local lifecycle hooks, so the
  config pointed at `.codex/rules/amh.rules`, where its static command-policy layer was wired.
  Codex lifecycle support added in 6.1.0 supersedes that historical capability statement while
  retaining the rules file as the lower layer.

- **The adoption brief's placeholder sweep covers the adapter directories.** `AMH-ADOPT.md` now
  greps `.claude/` and `.codex/` alongside the docs, which is load-bearing for this release:
  `codex-amh.rules` carries `{{DEFAULT_BRANCH}}` slots in a deny rail, and an unfilled slot
  there would previously have passed the sweep unnoticed. The README also states that a green
  ladder is necessary but not sufficient for adoption — it is a mechanical gate, not proof the
  hand-done obligations were met. Fresh installs only; the brief is never re-issued.

- **The session-branch namespace is agent-neutral.** `amh-init.sh` now defaults
  `BRANCH_PREFIX` to `session` rather than a vendor name; `--branch-prefix` still takes any
  value. Existing repositories are unaffected — the value lives in your `amh.conf`.

- **The ledger is stated to be retrieval storage.** Nothing had ever said a session may read a
  whole ledger volume, and nothing had said it may not. P2 gains the corollary: disk is
  addressed, not scanned — a citation is a seek to one row, and reading a volume whole loads
  the disk into the context window. The cap rung now prints the live volume's size in KB
  beside its line count, because the cap counts lines while the cost it stands for is bytes,
  and a proxy that drifts should show you the drift. Reporting only: no new threshold, no new
  key, nothing new that can fail.

- **`command-guard.sh` states what it does NOT catch.** A consolidated block in its header:
  interpreters outside its enumerated reader list (`python3 -c "open('.env')"` above all),
  the wrappers it does *not* strip — `xargs`, `timeout`, `ssh`, `bash -c` — as distinct from
  the ones it does (`sudo`, `nohup`, `nice`, `time`, `env FOO=1`, all of which ARE judged),
  `eval`-constructed and encoded commands, heredocs, and window truncation. Comment-only: no
  scanner changed. Read a green check as "no mistake this scanner recognises", never as proof
  a command was safe.

- **An agent with no pre-execution hook has no command rail at all.** Now stated in the
  constitution and the seed rather than left to be inferred. No check enforces it, and the
  prose says why: telling a hook invocation from a manual one requires vendor-specific
  environment variables the harness will not assume.

- **The seed ledger's `[cited]` marker description was wrong and is corrected.** It called the
  marker "machine-managed … verified derived state, never hand-tracked". Nothing syncs it: you
  write it, the ladder verifies it in both directions. The live volumes had already been
  corrected; the seed was still shipping the superseded claim.

### Upgrading

1. **Copy the shipped scripts** — the whole directory, manifest included.

2. **Decide about the archive tier, because the plan rule changed.** If you keep
   `docs/history/`, a completed plan worth retaining now moves there whole instead of being
   deleted; update whatever your constitution or runbook says about finishing a plan. If you
   have no archive tier, nothing changes: you still delete completed plans. This is the one
   item that can make something you are doing today wrong.

   **Your `docs/history/README.md` needs editing too, and it is a seed file, so nothing will
   do it for you.** Its intake list — "a frozen prior-era design doc, a specification
   superseded outright, a reference for a subsystem that no longer exists" — does not admit a
   completed plan, so following this item without editing it leaves your archive rules
   forbidding exactly what the new rule directs. Add the completed plan to the list, and add
   the caveat that goes with it: an archived plan is cold context, **not** permanent memory and
   **not** a valid implementation citation — durable outcomes still belong in ledger rows and
   changelog lines. Copy the wording from `harness/templates/seed/docs/history/README.md`.

3. **If your agent is Codex**, copy `harness/templates/configs/codex-config.toml` to
   `.codex/config.toml` and `codex-amh.rules` to `.codex/rules/amh.rules`, and add both paths
   to `RULE_FILES` in `amh.conf`. Substitute the placeholders as `harness/PLACEHOLDERS.md`
   describes.

4. **Hand-apply the seed changes you want** (seeds are yours and never re-synced). Four seed
   files changed in this release; the archive README is item 2 above, and the other three are:

   - **`AGENTS.md` — take this one.** Two additions, and they are the release's substance
     rather than polish: the rule that **an agent with no pre-execution hook has no command
     rail at all** (`scripts/command-guard.sh` is then a script nobody calls, and your
     constitution is the only layer), and the pointer from Secret hygiene to the guard's
     *what this guard does NOT catch* block. Skipping this leaves your constitution implying
     a rail that a hookless harness does not have.
   - **`docs/LEDGER.md` header** — the `[cited]` marker is machine-CHECKED, not
     machine-managed: you write it, the ladder verifies it, nothing syncs it. Plus the
     retrieval-storage paragraph: the ledger is grepped and cited, never read whole.
   - **`docs/RUNBOOK.md`** — the rule-review checklist's citation-scope wording, to match P11.

5. **Expect the ledger cap rung to say more**, not a new failure and not a new line: its
   existing line now carries a size in KB beside the line count. If your live volume's size
   surprises you, that is the point of it.

6. **No new `amh.conf` keys in this release.** The key-set diff in `docs/UPGRADING.md` step 5
   will print nothing; run it anyway, since it also catches keys you skipped in earlier
   upgrades.

## 2.1.1 — 2026-07-27

Guard fail messages now coach toward deep-folding instead of just naming the floor, and the
seed template preamble explicitly addresses the short-first-pass pattern. The README Quick
Start prompt primes the agent for the profile question before it reaches AMH-ADOPT.md.

- **Guard fail messages name compression techniques.** Branch 1 and Branch 3 in
  `guard_state_size()` now say "Fold more completed stages into single Changelog lines or move
  content to the ledger — do not micro-trim" instead of "Go to the floor or leave the file
  alone." Guard logic is unchanged.

- **Seed template preamble addresses the short-first-pass pattern.** "If the pass lands short,
  fold MORE completed stages — do not micro-trim toward the floor."

- **Quick Start prompt primes the profile question.** The paste-into-your-agent block now
  includes "It will ask you which installation profile to use — present the options and wait
  for my answer before proceeding."

### Upgrading

**No action required.** Copy the shipped scripts as usual. The guard message and seed template
changes reach new instantiations only; existing adopters' STATE.md preambles are their own.

## 2.1.0 — 2026-07-27

The session banner learns to say whether the release your version file names has actually been
cut, and the Owner queue learns that its items are claims rather than facts.

**Nothing here requires action.** Both new config keys default to empty, which switches the new
line off, so an `amh.conf` written before this version behaves exactly as it did. The rule
change is prose in a seed, which means it reaches new adopters only — see Upgrading.

- **A release-window line in `session-start.sh`.** Set `VERSION_FILE` and `RELEASE_TAG_PREFIX`
  in `amh.conf` and every session's banner reports whether the tag your version file implies
  exists: in the clone first, then on `origin`. It distinguishes three verdicts across four
  branches — present (in the clone, or on origin and not yet fetched), absent, and
  **could-not-ask** (no git, no repo, no remote, network down) — because a check that reports
  "I could not reach the remote" as "the tag is not there" manufactures a fact at the moment it
  knows least. `RELEASE_TAG_PREFIX` must be non-empty, so a project whose tags are bare version
  numbers cannot use the line as shipped. The remote probe is bounded by `timeout` where that exists and by
  `GIT_TERMINAL_PROMPT=0` always: a boot sequence that blocks on a credential prompt is worse
  than one that says it could not look.

  The interval it exists for is the one between merging a version bump and cutting the tag. In
  that window your release docs — an install command naming a tag above all — are false, and
  nothing else in the harness can see it: a version-consistency guard compares strings inside
  the tree, and a release workflow keyed on a tag runs after the tag exists. **The line reports;
  it enforces nothing**, and it cannot: whether the release *should* be cut is not a fact about
  the repository.

- **Owner-queue items are tested before they are restated.** An item is written at the moment of
  maximum knowledge and read at the moment of minimum, so a session that copies one forward is
  not being neutral — it is telling you the item is still true. Items whose truth is observable
  now carry a `Check:` command, and the protocol says to run it and read its **output** against
  the stated resolution (not its exit status — a check written to detect the unresolved
  condition exits 0 exactly when the item is still open). Items nothing can check say so and
  name who settles them, and are restated as *unverified* rather than as pending.

  **`Check:` is deliberately not a required field.** An item that must carry one will get one,
  and "the owner says so" is a check the way a checkbox is evidence — a queue full of those
  reads as verified while asserting nothing. Its absence is information: it means nothing but a
  human settles that item. Nothing consumes a session's claim to have checked, and nothing may.

- **`docs/UPGRADING.md` opens with a block you paste into your coding agent**, the counterpart
  to the README's Quick Start. It resolves the newest release tag rather than naming a version,
  so it cannot go stale between releases, and it states the boundaries the prose already set:
  clone a tag and never a branch, copy the whole scripts directory, never overwrite a file you
  own, never re-issue `AMH-ADOPT.md`, and fix a finding rather than weakening a guard.

### Upgrading

This is the complete list for 2.0.0 → 2.1.0. All of it is optional.

- **Copy the shipped scripts as usual** — `cp .../harness/templates/scripts/* scripts/`,
  including `MANIFEST.sha256`, then re-run your ladder. Nothing else is required, and if you
  stop here the banner is byte-for-byte what it was.

- **To switch the release line on, add two keys to `amh.conf`** (it is yours, so this is a hand
  edit the harness cannot do for you):

  ```sh
  VERSION_FILE=VERSION          # the file holding your release version
  RELEASE_TAG_PREFIX=v          # so 1.4.0 in that file means the tag v1.4.0
  ```

  Both must be set: with one set and the other empty the banner tells you so rather than staying
  silent, because half-configuration is a typo and silence would render it identically to the
  adopter who deliberately set neither. Leave both empty if you do not tag releases.

- **Record the version**: set `AMH_VERSION=2.1.0` in `amh.conf` and update the version line in
  your constitution. Nothing checks this for you and nothing goes red if you skip it — which is
  precisely why it is easy to lose. `docs/UPGRADING.md` opens by comparing those two against
  `harness/VERSION` to work out where you are, so a tree running 2.1.0 scripts while recording
  2.0.0 misreports its own position at the *next* upgrade.

- **The queue-testing rule reaches new adopters only, and this is the one thing worth knowing.**
  It lives in the seed constitution, seed runbook and seed state file — and seeds are copied once
  at init and owned by you forever, so upgrading will never touch your copies. If you want the
  rule, hand-add it: the short form is "test a queue item before restating it; items whose truth
  is observable carry the command that settles them; `Check:` is never a required field." The
  bundle's P9 has the full text.

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
