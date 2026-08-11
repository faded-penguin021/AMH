# Harness changelog

Versions are `MAJOR.MINOR.PATCH`, and the number is a promise about **your** workload as an
adopter, not about how much prose moved:

- **MAJOR** — a binding rule changed. Adopting repos must act; the Upgrading notes say how.
- **MINOR** — additive. New principles, guards or templates you may take or leave.
- **PATCH** — clarifications and fixes with no action required.

Each entry's **Upgrading** section is the complete list of what an adopter must do to move
from the previous version. Scripts are copied; seeds are yours, so seed changes appear here
as hand-applied notes. Full procedure: [`docs/UPGRADING.md`](../docs/UPGRADING.md).

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
  the size rung prints, and that they are derived rather than copied — and they are restored, so
  the saving there is a much smaller 10%. No threshold, guard, fixture or exit code changed;
  `guard_state_size` and `guard_state_structure` are untouched.
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
5. **Seed prose, hand-applied, optional.** `docs/STATE.md`'s length-guard preamble is shorter
   and says the same things — no rule, threshold or guard behaviour changed, so copying the new
   wording from `harness/templates/seed/docs/STATE.md` buys back bytes in your working-memory
   budget and nothing else, and skipping it costs nothing.

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
  own layers: Codex exposes no repository-local session-start, pre-shell or output-filter hook,
  so the config says plainly that it does not run `session-start.sh`, `command-guard.sh` or
  `redact.sh`, and points at `.codex/rules/amh.rules`, where the command-policy layer it does
  support is wired. The config file itself carries no settings — it exists to state which
  layers are absent. An adapter that claimed otherwise would be worse than none.

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
