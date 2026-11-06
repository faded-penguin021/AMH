# PLAN — close the credential-handling gaps that measuring spill-guard exposed

> **Status: rev 2, committed 2026-11-04 (S0). Adopted by the owner the same day: S1, S2, S6a and
> S3 ride the release after 16.0.0 (moved there by the owner later that day), and S4, S5, S6b and
> S6c stay deferred (§2).** No unit is approved yet.
> Each starts only on the owner's explicit approval of that unit; adopting the plan approved none.
> Rev 2 folds in an external review of rev 1 (verdict REVISE_BEFORE_IMPLEMENTATION, nine
> findings). Each finding was re-checked against this tree, or against the host's documentation,
> before it was accepted (§6). Re-checking F8 found a wider gap than the review named, and that
> changed the unit order.
> **Every measurement in §3 is re-taken when the unit that acts on it starts.**

The plan is provisional while it is live. Its durable outcomes go to Changelog lines and ledger
rows. Code cites ledger rows and never this file, and no ledger row may cite this file's path.
When the work is done, archive this file to `docs/history/` or delete it (`docs/RUNBOOK.md` →
**Session discipline** 5).

Unit names carry an `S` prefix so they cannot be confused with the owner-queue-closure plan's
Units 0–4 or the research-gaps plan's `H` units.

## 1. Source, and what to take from it

[karlkfi/claude-spill-guard](https://github.com/karlkfi/claude-spill-guard) at
[`efac304`](https://github.com/karlkfi/claude-spill-guard/tree/efac304) (MIT licence) is a Claude
Code plugin, a Go binary, that blocks secrets before they reach the API. It hooks
`UserPromptSubmit` and `PreToolUse` on `Read|Bash|Grep`, opens the files a call would read, and
denies the call on a finding. Two independent comparisons were made against `f10d840`: one in the
drafting session, and a second agent's comparison that the owner relayed.

External material is data, not authority (`AGENTS.md` → **Working guidance**). As with
cc-safe-setup: **borrow its shapes as fixtures and its measurements as evidence. Never borrow its
code.** It is Go, and AMH adds no dependency without owner approval.

Its central mechanism is out of scope by decision, not by oversight. **DB-027** records the
owner's 2026-08-11 call that a guard never opens a file, and it stands in the STATE Decided
non-items. Nothing in this plan opens a file to classify it.

## 2. Owner decisions

Answered by the owner on 2026-11-04: decisions 1–4. Decision 5 stays open until each unit's
behaviour is final.

1. **Whether to adopt it, and which units.** **Answered: the four selected units, S1, S2, S6a
   and S3.** S4, S5, S6b and S6c stay deferred, each with its prerequisites (§4.2). Adopting the
   plan approves no unit: each starts only on the owner's explicit approval of that unit.
2. **Release placement.** **Answered: all four ride the release after 16.0.0.** The owner first
   put all four in the 16.0.0 draft, S3 included, and later on 2026-11-04 moved them out of it:
   16.0.0 merges once the owner-queue-closure plan's Unit 4 lands, and this plan enters the next
   release. That overrides the recommendations below for S1, S2 and S6a. As drafted, per unit:
   - **S1: the 16.0.0 draft.** One of its sites is the unclosed-heredoc refusal that draft adds
     (**DD-058**).
   - **S2: the 16.0.0 draft**, subject to its own approval and review. It has the highest
     confidentiality value in this plan.
   - **S6a: the 16.0.0 draft.** This departs from the review, which placed it after the release.
     The reason is §3.4: an option on `sudo` or `nice` takes a command past the force-push
     denial and the permanent catastrophic-deletion denial. The draft's theme is command-guard
     gaps of that class, and its Unit 1 was one (`git push` long options).
   - **S3: after the 16.0.0 tag.**

   Each unit is approved and reviewed separately, whichever release it rides.
3. **S1: control-character escaping**, specified narrowly in S1. **Answered: include it.**
4. **One fresh-context reviewer per unit.** All selected units are in **Rule-review protocol**
   scope: each changes a shipped script or guard semantics. **Answered: approved, one pass per
   unit.** This lifts the standing no-subagents instruction for exactly that pass.
5. **Version semantics** stay provisional until each unit's final behavioural change is known
   (**Session discipline** 7(c)).

## 3. What was measured

**Method, for every local reproduction (2026-11-04, `f10d840`):**
- Every token was synthetic and generated at runtime. None was stored or printed; only verdicts,
  counts and fragment lengths were recorded.
- Guard and filter processes executed; the candidate commands did not.
- Guard shapes went to `scripts/command-guard.sh --command` with fresh advisory-state files per
  shape. Each was run twice, so that **DENY** (refused both times), **ADV** (refused once, then
  allowed) and **ALLOW** could be told apart.
- Redaction shapes went through `scripts/redact.sh` on stdin.

**External measurements** come from spill-guard's own design document, are labelled as such, and
were not reproduced here.

### 3.1 Refusals that repeat their operand (local)

| Shape | Verdict | Token in the refusal |
|---|---|---|
| a reader on `<token>/.git-credentials` | DENY | whole |
| a reader on `<token>/id_rsa` | DENY | whole |
| a reader on `<token>/.env` | DENY | whole, in the reason given on the rerun |
| an unclosed heredoc whose delimiter contains the token | DENY | see the sweep below |
| a force push of a token-named branch; a push with the token in a remote URL; `printenv <token>` | DENY | no |

The heredoc refusal prints `${HEREDOC_OPEN_DELIM:0:40}` (`scripts/command-guard.sh` line 5521),
so it truncates *before* anything downstream could filter it. Sweep: a delimiter is N benign
characters followed by a 20-character AWS-shaped token. The refusal is then passed through
`redact.sh`, which is what a final-emission filter would do. The table gives the longest run of
token characters left afterwards:

| Benign prefix N | Token chars in the raw refusal | After `redact.sh` |
|---|---|---|
| 0, 10, 20 | 20 | marker printed; no fragment longer than 2 |
| 24 | 16 | **no marker; 16 characters left** |
| 30 | 10 | **no marker; 10 characters left** |
| 36 | 4 | no marker; 4 characters left (the public `AKIA` prefix) |

The 2-character residue in the first row is noise: two-letter runs such as `EO` occur in the
refusal's own prose. Scope of the problem: 61 of the guard's 93 `*_REASON=` assignments
interpolate a variable, and that delimiter is the only truncation inside an assignment.
Truncation upstream of the assignments is not yet inventoried.

**Severity.** A command string is model-composed, so its bytes had already crossed to the API
when the model emitted the call. The refusal adds a diagnostic copy, not a first disclosure. The
copy lands in the transcript, in a human's terminal and in CI logs, and PostToolUse redaction
never sees it, because a denied call has no tool result.

### 3.2 Private-key bodies under a line prefix (local)

The `private_key_body` stage (`KEY_BLOCK_BODY` in `scripts/redact.sh`) redacts only lines that
are entirely base64. Body lines left in the clear, of 5:

| Context | Left |
|---|---|
| plain; `+` diff lines; one-space diff context; 4-space indent; RFC 1421 encrypted headers | 0 |
| `-` diff lines (`git log -p` of a commit that removes a key) | 5 |
| `grep -rn` output (`path:N:`) and `grep -r` output (`path:`) | 5 |
| `cat -n` / `nl` output | 5 |

In every leaking row the header still prints `[REDACTED:private_key_block]`. That is a marker
claiming redaction over a live value, the failure **DB-027** is named after, in shapes its
fixtures never reached. `+` passes only because it is a base64 character. spill-guard fixtures
these shapes (`testdata/corpus/planted/private-key-block-in-*`).

### 3.3 Token shapes passed through unchanged (local)

- AWS `ABIA` and `ACCA` followed by 16 characters.
- Slack `xoxe-`.
- An OpenAI-shaped key whose body carries `-` or `_` outside the three named prefixes, with the
  `T3BlbkFJ` marker.

The `AKIA` and `xoxb-` controls were redacted. None of these families has yet been checked
against primary vendor documentation (S3, F5).

### 3.4 Wrapper options defeat the rails beneath them (local)

| Shape | Verdict | Same command, bare |
|---|---|---|
| `sudo -u root git push --force origin main` | ALLOW | DENY |
| `nice -n 5 git push --force origin main` | ALLOW | DENY (`nice git push …`) |
| `sudo -u root rm -rf /`, `nice -n 5 rm -rf /` | ALLOW | DENY |
| `nice -n 5 rm -rf ~`, `sudo -u root rm -rf "$HOME"` | ALLOW | DENY (`rm -rf ~`) |
| `nice -n 5 git clean -fdx`, `sudo -u root git reset --hard "$REF"` | ALLOW, no advisory | ADV |
| `nice -n 5 printenv`, `sudo -E printenv` | ALLOW | DENY |
| `nice -n 5 cat .env`, `sudo -u root cat .env` (after the `.env` advisory) | ALLOW | DENY |

The guard header's WRAPPERS bullet says that `sudo` and `nice` are stripped, and does not say
that an option defeats the strip. The git pre-push rail still judges a push's refs, however git
was invoked; nothing stands behind the deletion rail.

Also measured, and deferred to S6b and S6c: `timeout 5`, `stdbuf -o0` and `setsid` before
`cat .env` are ALLOWED; so are `cat kubeconfig` and `cat prod.kubeconfig`.

### 3.5 Hook surfaces (host documentation, fetched 2026-11-04; and external)

From Claude Code's hooks reference:
- A blocked prompt never reaches Claude, and the `reason` (or exit-2 stderr) is "Not added to
  context".
- By default the block message ends with `Original prompt:` and the submitted text, and that
  message is written to the session transcript on disk.
- `hookSpecificOutput.suppressOriginalPrompt: true` leaves the text out of the block message
  only. The text can still appear in the transcript and in prompt history. The reference states
  no minimum version for the field.
- `UserPromptSubmit` also fires on turns Claude Code starts on its own.
- Pasted content arrives expanded, inside `<pasted_content>` wrapper lines.
- Plain-text stdout on exit 0 is **added to Claude's context**.
- The default command-hook timeout is lowered to 30 s for this event.

External (spill-guard, Claude Code 2.1.238, darwin/arm64, not reproduced):
- `@path` in a prompt splices the file with only `UserPromptSubmit` firing.
- In a transcript study to 2026-09-04, `!` bash-mode entries carried no `tool_use`, so no
  `PreToolUse` or `PostToolUse` hook could have judged them. Whether `UserPromptSubmit` fired
  for them was left unsettled.

### 3.6 The output hook's stand-downs (local, read from the source)

`redact-tool-output.sh` stands down silently in three different kinds of situation:
- **Nothing to judge:** a payload that is not a `PostToolUse` event, or one with no string
  leaves.
- **Coverage lost:** a parse failure, the size, leaf and depth ceilings, the deadline, a shape
  mismatch, a missing python3.
- **NUL bytes:** any NUL byte in a leaf (line 200).

Only the last two kinds lose protection. A NUL stand-down does not establish UTF-16. **Not
verified:** how the host hands a hook UTF-16 output. Separately, `redact.sh` does not recognise
an AWS-shaped token encoded as UTF-16LE, UTF-16BE or UTF-16 with a BOM (local).

## 4. The units

Every code unit follows `docs/RUNBOOK.md` → **Change a shipped script**:
- the template first, `bash -n`, copy down, `scripts/build-manifest.sh`;
- a `--self-test` fixture shown to FAIL against the old script;
- the **Rule-review protocol** and the full `scripts/ladder.sh`;
- a STATE Changelog line and checklist tick, and a ledger row for a durable bug class or a rail
  change.

Fixture tokens are built at runtime, as `redact.sh`'s self-test already builds them.

Execution order: **S0 → S1 → S2 → S6a → S3**, all in the release after 16.0.0. Each is a separate unit
with its own approval and review. Neither S4 nor S5 is a prerequisite for any of them.

### 4.1 Selected

#### S0 — commit this plan (administrative)

Commit this file with an Owner-queue item: "decide whether to adopt the spill-guard plan and each
decision in its §2". It approves no unit, and the per-unit approval rule stands.

#### S1 — refusal text does not repeat a supported credential shape (defect)

**The guarantee, scoped.** No shape `redact.sh` recognises, and no fragment of one, survives into
either output stream of a refusal or warning. No claim is made about credentials outside those
shapes; a regex filter cannot establish one.

**Sanitize whole values before any lossy step (F1).**
- At unit start, inventory every dynamic value in a reason: the 61 interpolating assignments, and
  any truncation or windowing upstream of them.
- Pass each value whole through the shared class list *before* truncation or any other lossy
  formatting. The heredoc delimiter is the measured case.
- A value too long to process whole within a stated bound is omitted, and the reason prints
  fixed text in its place.
- The heredoc refusal keeps its delimiter. Showing the word the guard read is that diagnostic's
  purpose.
- Elsewhere, an operand that adds nothing is dropped in favour of fixed text.

**A final emission filter, as defence in depth.** It runs at every print site: hook block/warn
(lines 5696, 5699), pre-push (5774), the spawn advisory (8625, fixed text today), and the
`--command` and `--powershell` arms (8656–8667). It runs only when there is a reason to print;
an allowed call that prints nothing never invokes it.

**Atomic fallback (F2).** The emission contract is:
1. capture the filter's stdout, bounded;
2. capture its stderr, and never forward it;
3. on success, emit the sanitized text;
4. on any failure (filter missing, non-zero exit, output over the bound), discard everything
   captured and emit a fixed diagnostic chosen by a trusted rule identifier;
5. in every case keep the original verdict, exit status and output channel.

Fixtures cover a missing filter, a non-zero exit after partial output, and failure under the
script's own `set -uo pipefail`. They exercise the hook entry point, the CLI and the git
pre-push entry point separately, because their exit semantics differ: git aborts a push on any
non-zero exit.

**Control-character escaping (owner decision 3).**
- Applied to dynamic values only, after credential detection, so escaping cannot split a token
  out of a pattern's reach.
- A dynamic newline or tab renders as a visible `\n` or `\t`; the diagnostic's own formatting
  newlines are untouched.
- Other C0 bytes and DEL render as `\xHH`.
- The bidi embedding, override and isolate controls (U+202A–U+202E, U+2066–U+2069) render as
  `\u{…}`, matched as their UTF-8 byte sequences because the guard runs with byte semantics.

**Tests (F3).** Three independent controls replace rev 1's universal marker requirement:
1. **Each refusal case** asserts its expected verdict and its stable diagnostic text, and that
   no prohibited fragment appears in either stream. A fragment is any run of 6 or more characters
   of the token's generated part; the measured prose noise is 2. Removing an unneeded operand
   passes this control by design.
2. **A sanitizer control:** a complete supported token, passed through the emission path,
   produces its class marker.
3. **A harness control:** output deliberately left unfiltered is caught by the leakage
   assertion. This proves that assertion can fail.

Marker assertions apply only where the contract keeps a sanitized operand, such as the heredoc
delimiter. Placement fixtures sweep the token across the truncation boundary as §3.1 did, and
include the longest open-ended families (`github_pat_`, the JWT shape).

**Acceptance.** Every §3.1 row shows no fragment, all three controls are green, and the existing
self-test matrix is otherwise unchanged.

#### S2 — private-key bodies under a line prefix (defect; highest confidentiality value)

**The accepted prefix grammar, explicit (F4).** A body line may carry, in this order and at most
one of each:
1. a grep location: `PATH:`, `PATH:N:` or `PATH-N-` (context lines), or a bare `N:` / `N-`,
   where `PATH` is one or more characters other than whitespace and `:`, and `N` is digits;
2. a line number: spaces, digits, then a tab (`cat -n`, `nl`);
3. a diff marker: exactly one `-`, `+` or space;
4. indentation: whitespace.

Nothing else. In particular there is no "anything before the final colon" rule. Windows drive
paths (`C:\…:N:`) fall outside item 1, and that is named as residue, not hidden.

**Kept as they are.**
- The BEGIN/END range anchor: git SHAs and sha256 lines are pure base64, and a bare pattern would
  redact every one.
- The sed delimiter invariant: no `|` or `&` in the pattern. If the grammar needs alternation,
  this one stage gets its own delimiter.
- An END marker is already matched as a substring, so a prefixed END closes the range. A
  fixture pins that.

**Fixtures, with independently built oracles.** Each fixture generates its body lines and
writes its expected output itself, never by applying the new pattern. It asserts that every
body line is gone and every non-body line is unchanged. Required cases:
- every prefix family above, including grep context lines and indentation;
- short final body lines and `=` / `==` padding, with no invented minimum length;
- several blocks in one stream; a block with no END; a prefixed END; and unrelated text after
  END, which survives;
- a realistic diff carrying a removed block and an added block together;
- clean controls inside and outside an open range: `key: value`, `host:port`,
  `file.go:12: error`, a git SHA and a sha256 manifest line.

**Residue, documented narrowly.** After an unmatched header, a later line that is a grep
location followed by one unbroken base64-alphabet word is redacted. This is the existing
unmatched-header residue extended by the grammar's prefixes, and nothing wider. Successful
redaction of complete blocks does not license suppression elsewhere in the stream.

**Acceptance.**
- The five leaking shapes of §3.2 redact 5 of 5, and fail against the old script.
- Every fixture above passes.
- The ladder's own secret scan stays green on this tree. That is necessary and not sufficient,
  because the tree may hold none of these shapes.

#### S6a — options on the wrappers the guard already peels (defect)

**Scope.** Only wrappers the guard already strips, and only their option grammar: `sudo`, `nice`
and `time` first, with `command`, `builtin`, `exec` and `nohup` inventoried at unit start. No new
wrapper families (S6b), and no new file names (S6c).

**Grammar.** Specify each wrapper's options from its manual: which take a value, attached or
separate, and which run nothing (`sudo -l`, `sudo -v`, `command -v`). spill-guard's wrapper
table (`internal/readers/wrappers.go`) is a source of shapes to test, not of code.

**Fixtures.**
- Attached and separate values (`-uroot`, `-u root`, `--user=root`, `--user root`).
- `--`; nested wrappers (`sudo -u x nice -n 5 rm -rf ~`); missing values (a usage error that runs
  nothing, which fails open as `env` already does).
- Absolute executable paths (`/usr/bin/sudo -u root`).
- Benign arguments that resemble blocked commands (`sudo -u rm ls`, where `rm` is the user).
- **Every rail that walks wrappers**: secret-file reads, environment dumps, push, the
  destructive advisory, the catastrophic-target denial, the interpreter advisory and the
  data-plane tier. Each row of §3.4 must reach its bare verdict.

**Docs.** Correct the WRAPPERS bullet to say exactly what is peeled, and list the unsupported
forms precisely.

#### S3 — four token shapes (rule widening)

- **Vendor verification first (F5).** Check each family against primary vendor documentation
  before calling it a current credential format. AWS publishes its identifier prefixes and Slack
  its token types. If no primary source documents the OpenAI marker, record it as observed
  rather than documented, and leave including it to the owner.
- **Ordering (F5).** The marker-anchored OpenAI row goes ahead of the generic `sk-` row and of
  any row that could consume a prefix of the new token and leave its suffix in the clear.
  Overlap fixtures build a new-family token with a substring that would trigger an existing row
  on its own, and assert complete removal.
- **One shared vocabulary.** `redact.sh`'s pattern list stays the only list. S1 reuses it, and
  so would S5.
- **Fixtures.**
  - complete removal; overlength inputs, under the open-ended `{n,}` policy; adjacent
    punctuation;
  - clean near-matches: one character short, the prefix with no separator, and `ACCA` as an
    acronym in prose. `ACCA` is named as residue in the header, the way `ASIA` already is.

### 4.2 Deferred, each with prerequisites

#### S4 — record when the output hook does not look (deferred)

Useful observability, but it adds persistent state and closes no disclosure path. Before it is
reconsidered, the design must settle each of the following (F6):

- **States.** `not_applicable` (another event), `no_string_content` (no leaves) and
  `coverage_failure` (everything else in §3.6). Only the third is lost protection.
- **Limits, stated in the report's own text.**
  - A hook that never starts writes nothing, and neither does one the host times out or kills,
    or one whose log write fails.
  - A NUL count establishes NUL-bearing responses, not UTF-16 origin.
  - Zero records establishes neither coverage nor that the hook ran.
- **Data hygiene.** The tool name is mapped to a trusted constant or `unknown`, never recorded
  raw, because it is payload data. No payload byte and no path is recorded.
- **Storage.**
  - A private directory and mode 0600; refuse symlinks.
  - Concurrent appenders: one write per record, each under the atomic-append size.
  - Rotation and a reset path, a retention bound, and a stated scope (per uid and checkout,
    cumulative until reset).
- **Independence.** A reporting failure never changes a tool's result.
- **Wording.** "Reporting reads it; no acceptance or permission decision depends on it." The
  ladder and `--skip-report` do read it. **DA-024** stays satisfied because no decision does.

#### S5 — the prompt surface (deferred implementation)

A useful new surface, but rev 1 understated what the host echoes and what a blocking false
positive costs. Prerequisites (F7):

**Host contract, measured on each supported version.** Use the documented JSON block with
`hookSpecificOutput.suppressOriginalPrompt: true` (§3.5), and observe on a real host whether it
is honoured. Measure these separately:
- that the prompt is blocked;
- what the block message shows;
- what persists locally, in the transcript and in prompt history.

Suppression is not removal from disk, and the unit must not claim it is. Also decide how a
blocking hook treats turns the host starts on its own, and how it treats `<pasted_content>`
wrapper lines.

**Precision for blocking.** Under S5 a false positive tolerable in redaction becomes a rejected
request. Before approval, run the class list over ordinary prompts that discuss:
- credential formats;
- redaction markers;
- URLs with userinfo;
- a PEM header quoted as a question ("why does my file start with `-----BEGIN … PRIVATE
  KEY-----`?").

Report the block rate.

**Detection.** Count markers against `redact.sh --baseline`, as the output hook does
(**DD-016**), never raw input/output inequality.

**Output discipline.** Never print the prompt, or a filtered prompt, on stdout: on exit 0 the
host adds stdout to Claude's context. A fixed, class-only reason needs no dynamic sanitizing, so
it does not depend on S1's emitter.

**Failure.** No `onFailure: block`: a prompt hook that cannot start would refuse every prompt.
Any skip record covers only failures that code which actually started can observe, and S4 is
optional for S5.

**`@path` and `!` mode.**
- A probe of whether `Read(...)` deny rails stop an `@` mention is scoped to the spellings,
  versions and hosts it tested. One `@.env` probe does not establish that every attachment path
  honours every rail.
- The `!`-mode note in the limits prose is version-scoped: what spill-guard's study observed
  (§3.5), and that none of AMH's verified surfaces (the PreToolUse guard, the PostToolUse
  redaction, the pre-push rail) was established to see such an entry.

#### S6b — new wrapper families (deferred)

`timeout`, `stdbuf`, `setsid`, `ionice` and the rest of spill-guard's table. This widens a rail
rather than repairing an advertised one; it reopens after S6a, on evidence.

#### S6c — kubeconfig file names (deferred)

A kubeconfig that authenticates through an exec or OIDC plugin holds no token, so a blanket
name denial needs precision evidence first. Rev 1 supplied none.

## 5. Considered and not planned

- **Opening files to scan content before a read**: refused by **DB-027**. spill-guard is
  evidence in both directions, per its own design document: it sees `id_rsa.bak` and
  `deploy_key`, which AMH cannot see by name. But in one measured week, 94% of its blocks were
  inputs it could not resolve, after which it stopped blocking them. Reopen only with new
  evidence, on the owner's call.
- **Resolving variables, globs, loops and substitutions** for secret-file reads
  (`F=.env; cat "$F"`, `cat .e*`): the guard's design rule targets mistakes, not evasion. Reopen
  on an incident.
- **An override hatch** like `SPILL_GUARD_OVERRIDE=reason cmd`: that is a self-attestation
  satisfying a guard, which an `AGENTS.md` hard boundary forbids.
- **Allowing the careful `env` forms** (`env | cut -d= -f1`, `printenv PATH`): spill-guard
  argues that blocking them teaches carelessness, and AMH blocks them. This is a policy
  disagreement for the owner to reopen if wanted, not a gap.
- **Steering recursive grep through a filter**: it costs a turn per grep, and output redaction
  already sees grep output on a successful call. Reopen on an incident, or on S4's records if S4
  is built.
- **PII rules, entropy floors and placeholder allowlists**: precision matters to a blocking
  scanner. Over-redacting AWS's documentation example costs a redaction tool almost nothing. If
  S5 is built, its precision check is the place to revisit placeholders.
- **UTF-16 decoding in `redact.sh`**: there is no evidence yet that the host hands a hook UTF-16
  bytes (§3.6).

## 6. Review of rev 1 and how rev 2 answers it

| Finding | Re-checked | Outcome in rev 2 |
|---|---|---|
| F1 (HIGH): S1 filters after truncation | Reproduced. Wider than reported: 16 of 20 characters survive at prefix 24 (§3.1) | Values sanitized whole before lossy steps; bounded omission; final filter kept; guarantee scoped to supported shapes; fragment-based assertions |
| F2 (HIGH): non-atomic fallback | Accepted as a design requirement | Five-step emission contract; per-entry-point fixtures |
| F3 (MEDIUM): universal marker requirement rejects valid fixes | Accepted | Three independent controls; markers only where an operand is kept |
| F4 (HIGH): "ladder green" is not S2 acceptance | Accepted | Explicit grammar; independent oracles; full fixture list; residue narrowed |
| F5 (MEDIUM): S3 ordering and token extent | Accepted | Ordering rule; overlap fixtures; vendor verification first |
| F6 (MEDIUM): S4's records overclaim | Confirmed from the source: not every stand-down is lost coverage (§3.6) | Deferred, with the redesign as prerequisites; wording corrected |
| F7 (HIGH): S5 host semantics and precision | Confirmed from the hooks reference (§3.5); `suppressOriginalPrompt` exists, with no stated minimum version | Deferred; host contract, precision and failure-scope prerequisites; `@path` and `!` claims scoped |
| F8 (MEDIUM): S6 mixes expansions | Confirmed, and wider: the option gap defeats the push, catastrophic-deletion, destructive, dump and secret rails (§3.4) | Split into S6a, S6b and S6c; S6a raised in the order and recommended for 16.0.0 (departs from the review) |
| F9 (LOW): provenance and scope language | Accepted | Method wording corrected; external measurements labelled; S1 severity kept as duplication; no unit described as adopted; versions provisional |

## 7. Not verified

- How the host hands a hook UTF-16 output (§3.6).
- Whether `suppressOriginalPrompt` is honoured on any supported Claude Code version (§3.5).
- Whether `Read(...)` deny rails apply to an `@` mention, on any spelling or version.
- Every external measurement in §3.5, and spill-guard's 94% coverage-block figure.
- Truncation upstream of the 61 interpolating reason assignments (§3.1).
