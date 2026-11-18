# H4b follow-up — the owner-box probe run of 2026-11-15, and what the last run must hold

Companion to `2026-11-01-harness-research-gaps.md` §5 H4b, its follow-up bullet. Evidence rows:
**DD-090** to **DD-093**. This file records one run and the plan for the next; it decides
nothing, and the decisions it needs are in `docs/STATE.md` → Owner queue, the H4b item.

## 1. The run

- Run `20261115T183650Z`, the probe script `2026-11-01-harness-research-gaps-h4b-probe.sh` at
  `7edb27f`, old ref `4c295c5`, stage `all`, by the owner's host session in a throwaway
  container: ubuntu:24.04, uid 1001, `--init`, `seccomp=unconfined`, WSL2 kernel
  6.18.33.2, 8 CPUs; Claude Code 2.1.325, model claude-sonnet-5-5, bubblewrap 0.9.0,
  `unshare -Ur true` succeeding, network cells pushing to github.com.
- An earlier attempt the same day, `20261115T183135Z` at `dfde9d1`, produced no evidence: the
  prompt was read as one more `--tools` entry, and the probe trees were untrusted, so their
  `permissions.allow` entries were ignored. `7edb27f` fixed both.
- The send-back archive, `send-20261115T183650Z.tar.gz`, 103 entries, sha256
  `7fb8ad270467f6d09c1f818d658b940de847a89bc8091f2855fa90f3a67bfe9b`, was read by this session
  on 2026-11-15 outside any repository; it is not committed. The host session reported no
  token fragment in it, and the token has since been revoked by the owner. When read, it sat in
  the dev container at /home/claude/h4b-results, the owner its custodian; §3.1 keeps the lines
  §3 rests on, so a session without the archive can still check them. The unpackaged raw
  transcripts stayed in the box, which the owner's teardown removes.

## 2. The results table, as the probe wrote it

The verdicts are the probe's own; §3 says where reading the artifacts changes one.

| cell | variant | verdict | detail |
|---|---|---|---|
| bwrap-args | V0-shipped/base | 419 | processes=8 samples=68 proc_args=57 via_fd=no; ran sandboxed |
| pid-namespace | V0-shipped | OWN | pid1=3 visible_pids=6 self_environ_open=ok |
| bwrap-args | V0-shipped/load | 2210 | processes=308 samples=66 proc_args=654 via_fd=no; ran sandboxed |
| bwrap-args-per-process | V0-shipped | 5.97 | from 419 args at 8 processes to 2210 at 308; bwrap's limit is 9000 |
| bwrap-args | V1-no-doublestar/base | 308 | processes=8 samples=68 proc_args=15 via_fd=no; ran sandboxed |
| bwrap-args | V1-no-doublestar/load | 1205 | processes=308 samples=62 proc_args=314 via_fd=no; ran sandboxed |
| bwrap-args-per-process | V1-no-doublestar | 2.99 | from 308 args at 8 processes to 1205 at 308; bwrap's limit is 9000 |
| bwrap-args | V2-no-root-proc/base | 275 | processes=8 samples=66 proc_args=4 via_fd=no; ran sandboxed |
| bwrap-args | V2-no-root-proc/load | 275 | processes=308 samples=62 proc_args=4 via_fd=no; ran sandboxed |
| bwrap-args-per-process | V2-no-root-proc | 0.00 | from 275 args at 8 processes to 275 at 308; bwrap's limit is 9000 |
| bwrap-args | V3-no-proc/base | 275 | processes=8 samples=68 proc_args=4 via_fd=no; ran sandboxed |
| bwrap-args | V3-no-proc/load | 275 | processes=308 samples=62 proc_args=4 via_fd=no; ran sandboxed |
| bwrap-args-per-process | V3-no-proc | 0.00 | from 275 args at 8 processes to 275 at 308; bwrap's limit is 9000 |
| read-tool | V2-no-root-proc /proc/<pid>/environ | ERROR | see artifacts/read-V2-no-root-proc-0.summary |
| read-tool | V2-no-root-proc /proc/<pid>/task/<tid>/environ | INCONCLUSIVE | see artifacts/read-V2-no-root-proc-1.summary |
| read-tool | V0-shipped /proc/<pid>/environ | INCONCLUSIVE | see artifacts/read-V0-shipped-0.summary |
| read-tool | V0-shipped /proc/<pid>/task/<tid>/environ | INCONCLUSIVE | see artifacts/read-V0-shipped-1.summary |
| read-tool | V1-no-doublestar /proc/<pid>/environ | INCONCLUSIVE | see artifacts/read-V1-no-doublestar-0.summary |
| read-tool | V1-no-doublestar /proc/<pid>/task/<tid>/environ | INCONCLUSIVE | see artifacts/read-V1-no-doublestar-1.summary |
| in-tree-write | V0-shipped | ok | independently: file-present |
| out-tree-write | V0-shipped | refused | independently: file absent; the control wrote there first |
| tmp-write | V0-shipped | ok | TMPDIR set inside: yes |
| git-commit | V0-shipped | ok | independently: 1 new commit(s) on the branch |
| worktree-commit | V0-shipped | failed | independently: 70 commit(s) on session/amh-probe-wt |
| session-start | V0-shipped | rc=0 | run inside the sandbox; see artifacts/contain-session-start.log |
| network-push | control-outside-sandbox | PUSHED | branch session/amh-probe-20261115T183650Z-control, read back from the remote |
| network-push | V0-shipped bypass | REACHED | push_rc=0 ls_remote_rc=0 ls_remote_noauth_rc=128; on the remote: yes |
| network-push | V0-shipped default | INCONCLUSIVE | the cell did not run sandboxed (pidns other, bwrap samples 0); push_rc=128 ls_remote_rc=128 ls_remote_noauth_rc=128; on the remote: no |
| network-push | V0-shipped dontAsk | INCONCLUSIVE | the cell did not run sandboxed (pidns other, bwrap samples 0); push_rc=128 ls_remote_rc=128 ls_remote_noauth_rc=128; on the remote: no |
| network-push | V0-allow-host default | INCONCLUSIVE | the cell wrote no output; push_rc=none ls_remote_rc= ls_remote_noauth_rc=; on the remote: no |
| old-path-refs | 4c295c5 | rc=0 | .claude/loop.md inside: crw-rw-rw- character special file 0 |
| full-ladder | V0-shipped | RED | ladder_rc=1 secs=850 path_refs_rc=0; see artifacts/ladder.log |
| no-bwrap-path | V0-shipped | UNSANDBOXED | the out-of-tree write landed; the sandbox mentioned in stderr or a tool result: yes |

## 3. What the artifacts add to the table

- **The `//proc` cost (DD-090).** Per running process, V0 (shipped) adds 5.97 bwrap
  arguments, V1 (drop `Read(//proc/**/environ)`) 2.99, V2 (drop both `//proc` rules) and V3
  (also the single-slash pair) none. Extrapolated linearly past the 308 measured, bwrap's 9000
  binds V0 from about 1,440 processes and V1 from about 2,900, on single-threaded `sleep` load; DD-088 measured 17 to 20 per process
  in real sessions, a difference not explained (per-thread `task/<tid>` expansion is a guess).
  The `V0-allow-host` cell, shipped rules, failed: `bwrap: Can't mkdir parents for
  /proc/35554/environ: No such file or directory`, a process gone between expansion and mount.
- **The Read tool (DD-091).** Five of six cells made no tool call. The sixth, V2 on
  `/proc/<pid>/environ`, was refused by Claude Code itself: "this path names a device or process
  file that this tool does not read". The probe labels any error-valued Read result ERROR. V2
  is its positive control: a V0 or V1 refusal counts as the deny rules' only when V2 read the
  path, so while Read refuses `/proc` by itself this design cannot attribute a refusal to the
  rules at all. One observation, one version, one path.
- **Containment (DD-092).** The default and dontAsk network transcripts show
  `deny network-outbound github.com:443 (user denied)` from the sandbox; the probe's
  INCONCLUSIVE stands as its verdict, because its sandboxed check saw no bwrap sample, and the
  transcript reading is recorded beside it, not over it. Worktree: `fatal: could not create
  directory of '.git/worktrees/wt': Read-only file system`. Without `bwrap` on `PATH`, Claude
  Code printed `Sandbox disabled ... Commands will run WITHOUT sandboxing` on stderr.
- **The ladder (DD-093).** 48 verification-set failures, none of them `path-refs.sh`, from four
  causes: `scripts/verify.sh` line 28 writes `/tmp/amh-parse.$$` (46); the command guard's
  advisory markers are built under `/tmp` (`advisory_state_file`, which `session-start.sh`
  clears from the same `/tmp` glob); the no-hasher fixture in `test-ladder-guards.sh` runs
  under `env -i`, so `mktemp -d` falls back to `/tmp`; three bootstrap fixtures, on a missing
  `xz` in the box and `tar: ...: Cannot mknod` on shell rc files. No ladder ran outside the
  sandbox in the box. The ladder's last line counts 22 uncommitted paths, and the old
  `path-refs.sh` cell's status lists them: the placeholders the sandbox puts in the tree for
  what it hides (`.bashrc`, `.zshrc`, `.gitconfig`, `.mcp.json`, a dozen under `.claude/`, and
  more), so the `mknod` failures are plausibly a tar of those devices, a sandbox effect, not
  the box's; that is inference.

### 3.1 The lines §3 rests on, verbatim from the archive

```
ladder.log:  ok    path-refs.sh — 349 path reference(s) resolve across 22 file(s); 1 historical ledger path drift exemption(s); 1 untracked file(s) could not be read and were not scanned: .claude/loop.md
ladder.log: scripts/verify.sh: line 28: /tmp/amh-parse.16923: Read-only file system
ladder.log:        expected exit 0, got 1 mktemp: failed to create directory via template '/tmp/tmp.XXXXXXXXXX': Read-only file system
ladder.log: /bin/sh: 1: xz: not found
ladder.log: tar: .bash_profile: Cannot mknod: Operation not permitted
ladder.log:    verification set: 48 failure(s)
ladder.log: ✗ ladder red (verification set failed) — HEAD 7edb27f + 22 uncommitted path(s) — the tree just verified is NOT that commit
contain-worktree.err: fatal: could not create directory of '.git/worktrees/wt': Read-only file system
read-V2-no-root-proc-0.summary: TOOL_RESULT ... True no <tool_use_error>Cannot read '/proc/15941/environ': this path names a device or process file that this tool does not read.</tool_use_error>
net-V0-shipped-default.summary: TOOL_RESULT ... False no <sandbox_violations>\ndeny network-outbound github.com:443 (user denied) ...
net-V0-allow-host-default.summary: TOOL_RESULT ... True no Exit code 1\nbwrap: Can't mkdir parents for /proc/35554/environ: No such file or directory
no-bwrap-path.stderr: ⚠ Sandbox disabled: sandbox is enabled but dependencies are missing: bubblewrap (bwrap) not installed ...
no-bwrap-path.stderr:   Commands will run WITHOUT sandboxing. Network and filesystem restrictions will NOT be enforced.
```

## 4. The last run

The owner said on 2026-11-15 that the next owner-box run is the last. What it cannot settle
ships unverified, and by H4b acceptance (g) its containment claim is withheld, not merely
disclosed; an unresolved DD-088 blocker ships 17.0.0 with the sandbox block off. The WSL2
Windows-program cell is outside a Linux container, so it stays unverified unless the owner
names a WSL2 session for it.
Before it, on the owner's answers to the H4b item: the `//proc` candidate in the adapter and its
template; the ladder fixes of DD-093 as their own unit; the probe repaired. A gpt-6-astra
`-e medium` consultation on 2026-11-15 (run `20261115T200845Z-advisor-h4b-proc-fix`, advisory)
proposed this content, which this session adopts as the draft:

1. **Probe repairs first:** count a cell as sandboxed from the transcript's own sandbox evidence
   as well as bwrap samples, so a short-lived bwrap is not missed; keep a no-call cell
   INCONCLUSIVE, and retry it, rather than reading it; record the Read tool's own refusal as its
   own verdict, not ERROR.
2. **The candidate, not V0,** in every cell: the ladder, allow-host, network and containment
   cells all ran the shipped rules in this run.
3. **Preflight:** the effective settings and revision, and `xz` and the bootstrap's other needs
   installed, so an environment gap is not read as a sandbox one; the ladder fixes must also
   survive the sandbox's placeholder devices in the tree (§3, DD-093).
4. **The full ladder twice,** outside the sandbox first as the control, then inside it.
5. **The `//proc` sweep on the candidate:** process count, multi-threaded processes and process
   churn, with launch outcomes, so both DD-088's scale failure and DD-090's race are retested.
6. **Read calls** on a canary's `/proc/<pid>/environ` and `task/<tid>/environ`, with an
   ordinary file as the positive control. Since DD-091's refusal came from the Read tool itself,
   with no `//proc` rule loaded, the probe must record that refusal as its own verdict and
   stop requiring V2 to read the path; whether the rules then add anything for Read is a
   question this run can only answer as "nothing observable".
7. **Containment again:** namespace isolation, in-tree and out-of-tree writes, `TMPDIR`, git
   commit, operations in a linked worktree created before the session, and the command guard's
   advisory lifecycle (written, reported, rearmed by `session-start.sh`) inside the sandbox.
8. **Network:** the control push, then all three permission modes and the allow-host variant.
9. **Without `bwrap`:** the stderr line and the write outcome.

Acceptance (f), the retained old adapter and the Upgrading step, stays with a session here
after the adapter change, as the follow-up bullet already says.

On 2026-11-18 the probe script was repaired to items 1 to 9 above (DD-098). Item 2 needed no
variant of its own: since DD-095 the shipped adapter is the candidate, and the probe now refuses a
tree that still carries a root-anchored `/proc` rule. It adds two things the list did not name: the
sweep's control, the candidate with both `//proc` rules put back, so a flat count is read against
the growth this Claude Code version shows; and the owner's question of 2026-11-18, whether the
machine-mode fragment's `//proc` rules reach a project's sandbox from the user settings.
