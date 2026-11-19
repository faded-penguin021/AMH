#!/usr/bin/env bash
# H4b follow-up: the live sandbox probe, run by the owner in a throwaway box.
#
# Research-gaps plan, §5 H4b, the follow-up bullet of 2026-11-15; evidence DD-079, DD-088 to
# DD-097. This is the LAST run's probe, repaired to the H4b results companion's §4 (DD-098); the
# first run's design is in git history at 7edb27f. It probes the candidate adapter, which since
# DD-095 is the shipped one: no root-anchored //proc deny rule. One run answers:
#   1. whether a sandboxed command gets its own PID namespace and /proc;
#   2. the bwrap argument count against running processes, threads and process churn, at up to
#      AMH_PROBE_SCALE processes, with each launch's outcome: on the candidate (C-shipped), on the
#      candidate with the two //proc rules put back (R-root-rules, the control that shows the
#      growth this version would have), and on the candidate with the machine-mode fragment's deny
#      rules in the user settings (C-machine-user: whether user-level rules reach a project's
#      sandbox, the owner's question of 2026-11-18);
#   3. what Claude Code's Read tool does on /proc/<pid>/environ and /proc/<pid>/task/<tid>/environ,
#      with an ordinary file as the positive control, its own refusal recorded as its own verdict;
#   4. H4b's remaining cells, each with a positive control: an in-tree write, an out-of-tree
#      write, temporary files, git commit, a linked worktree created inside and one created before
#      the session, the command guard's advisory lifecycle, the session bootstrap, a network push
#      to a real remote under three permission modes (and a probe-only variant that allows its
#      host), startup without bwrap, and the full ladder outside the sandbox (the control) and
#      inside it; plus why the old path-refs.sh exited 2 there.
#
# usage:
#   h4b-probe.sh --source <bundle|path|url> --ref <commit> [--old-ref <commit>] [--stage <stage>]
#   h4b-probe.sh --check --source <...> --ref <...>   # everything except Claude; for this repo
#
#   --source   anything `git clone` accepts holding this repository; a bundle made on the host
#              with `git bundle create amh-probe.bundle main session/harness-research-gaps`
#   --ref      the commit to probe, the one carrying this script; in a clone of that bundle
#              the branch is origin/session/harness-research-gaps
#   --old-ref  the commit before DD-089's fix, for the old path-refs.sh (default 4c295c5)
#   --stage    all (default) | no-bwrap-root: the optional last stage, run only after
#              `docker exec -u root <box> apt-get remove -y bubblewrap`
#
# Optional environment, read and never printed:
#   AMH_PROBE_REMOTE      HTTPS URL of a throwaway repository the token may push to
#   AMH_PROBE_TOKEN_FILE  a mode-0600 file holding only that token
#   AMH_PROBE_USERNAME    the HTTPS username to pair with it (default x-access-token)
#   AMH_PROBE_MODEL       default claude-sonnet-5-5
#   AMH_PROBE_OUT         a directory that does not exist yet (default $HOME/amh-h4b-probe-<UTC>)
#   AMH_PROBE_SCALE       processes for the scale cell (default 4500; DD-088 failed at about 4,400)
#   AMH_PROBE_TRIES       attempts for a Claude call that made no tool call (default 3)
#
# What it promises, and how:
#   - It prints no environment. Nothing here runs env, printenv, set or export -p. The only
#     /proc/*/environ read is the canary's, a process started with `env -i` and one variable; the
#     sandboxed open tests use `head -c0`, which reads no byte.
#   - The token reaches git only through a helper script that reads the file, with every value in
#     it shell-quoted; its value is never on a command line, in a log or in this shell's
#     environment.
#   - What enters the send-back folder is redacted by the tree's scripts/redact.sh BEFORE it is
#     shortened, and the package step refuses to build the archive if any 8-character run of the
#     token appears anywhere in that folder.
#   - Claude Code's own stderr is not packaged: only its line count and the lines naming the
#     sandbox, bwrap, seccomp, a namespace or the proxy, redacted and shortened. Raw transcripts
#     and stderr stay in <out>/raw, unpackaged; inspect them before sharing them separately.
#   - Each Claude call is limited to the one tool its cell needs (--tools, where this Claude Code
#     offers it; the log says when it does not), and a cell's verdict counts only when the
#     transcript shows exactly one call of that tool on the expected command or path, with its
#     result. A call that made no tool call at all is retried, up to AMH_PROBE_TRIES attempts,
#     and stays INCONCLUSIVE if none made one: it is never read as a refusal (DD-091).
#   - A verdict about containment counts only when the cell ran sandboxed: in a PID namespace
#     other than this script's AND with sandbox evidence for that call, either a bwrap process
#     seen under it or Claude Code's own <sandbox_violations> block in its tool result (DD-092).
#     Every cell ends with a two-second sleep so a short-lived bwrap is sampled. Anything less is
#     INCONCLUSIVE, never a pass or a refusal.
#   - It deletes nothing but files it created, and signals only processes it started, checked by
#     their command line before each signal. Outside its own folder it changes two things, never
#     under --check: each probe tree is marked trusted in the box user's ~/.claude.json, since
#     Claude Code ignores an untrusted tree's permissions.allow entries; and for the C-machine-user
#     cells only, the machine-mode fragment's permissions.deny entries are merged into the user
#     settings file, which is put back byte for byte (or removed, if there was none) as soon as
#     those cells end and again on exit. Its hooks are NOT merged: they name a guard copy this box
#     does not have, and with onFailure block a missing one refuses every call. Probe branches
#     pushed to the remote are listed, never deleted.

set -uo pipefail

SOURCE='' REF='' OLD_REF=4c295c5 STAGE=all CHECK=false
while [ $# -gt 0 ]; do
	case $1 in
	--source) SOURCE=${2:-} && shift 2 ;;
	--ref) REF=${2:-} && shift 2 ;;
	--old-ref) OLD_REF=${2:-} && shift 2 ;;
	--stage) STAGE=${2:-} && shift 2 ;;
	--check) CHECK=true && shift ;;
	*) printf 'h4b-probe: unknown argument\n' >&2 && exit 64 ;;
	esac
done
if [ -z "$SOURCE" ] || [ -z "$REF" ]; then
	printf 'h4b-probe: --source and --ref are required (see the header)\n' >&2
	exit 64
fi
case $STAGE in all | no-bwrap-root) ;; *) printf 'h4b-probe: --stage is all or no-bwrap-root\n' >&2 && exit 64 ;; esac

TS=$(date -u +%Y%m%dT%H%M%SZ)
MODEL=${AMH_PROBE_MODEL:-claude-sonnet-5-5}
SCALE=${AMH_PROBE_SCALE:-4500}
TRIES=${AMH_PROBE_TRIES:-3}
case $SCALE$TRIES in *[!0-9]*) printf 'h4b-probe: AMH_PROBE_SCALE and AMH_PROBE_TRIES are whole numbers\n' >&2 && exit 64 ;; esac
[ "$TRIES" -ge 1 ] || TRIES=1
OUT=${AMH_PROBE_OUT:-$HOME/amh-h4b-probe-$TS}
# Absolute, because the cells' scripts run from each tree's own directory: a relative OUT made the
# out-of-tree write fail on a missing directory and read as the sandbox refusing it.
case $OUT in /*) ;; *) OUT=$PWD/$OUT ;; esac
# A directory of its own, never an existing one: whatever is under send/ gets packaged.
if [ -e "$OUT" ] || [ -L "$OUT" ]; then
	printf 'h4b-probe: the output directory already exists; name a new one in AMH_PROBE_OUT\n' >&2
	exit 64
fi
mkdir -p "$(dirname -- "$OUT")" && mkdir "$OUT" || exit 1
SEND=$OUT/send RAW=$OUT/raw PRIV=$OUT/private TOOLS=$OUT/tools TREES=$OUT/trees
OUTSIDE=$OUT/outside
LOG=$SEND/probe.log
RESULTS=$SEND/results.tsv
mkdir -p "$SEND/artifacts" "$RAW" "$PRIV" "$TOOLS" "$TREES" "$OUTSIDE" || exit 1
chmod 700 "$OUT" "$PRIV"
: >"$LOG"
printf 'cell\tvariant\tverdict\tdetail\n' >"$RESULTS"

# --- processes this script started, signalled only after checking they are still ours ---------
OWN_PIDS=()
# The three command lines this script starts processes with, and the only ones it signals.
THREADS_PY='import threading, time
for _ in range(9):
    threading.Thread(target=time.sleep, args=(86400,), daemon=True).start()
time.sleep(86400)'
safe_kill() { # safe_kill <pid> : only a sleep, thread or churn load of ours that this user owns
	local p=$1 cmd
	[ -r "/proc/$p/cmdline" ] || return 0
	cmd=$(tr '\000' ' ' <"/proc/$p/cmdline" 2>/dev/null)
	case $cmd in
	'/bin/sleep 86400 ' | "python3 -I -c $THREADS_PY amh-h4b-threads " | "bash $TOOLS/churn.sh ") ;;
	*) return 0 ;;
	esac
	[ "$(stat -c %u "/proc/$p" 2>/dev/null)" = "$(id -u)" ] || return 0
	kill "$p" 2>/dev/null
}
USER_SETTINGS=${CLAUDE_CONFIG_DIR:-$HOME/.claude}/settings.json
USER_SETTINGS_MERGED=false
# The Claude call and its watcher in flight, if any. `timeout` runs in a process group of its own,
# so an interrupt never reaches Claude Code: the probe stops it here, and `timeout` passes the
# TERM on to it, rather than leaving it running unrecorded past the probe's exit.
CUR_CLAUDE='' CUR_WATCHER=''
cleanup() {
	local p
	[ -n "$CUR_WATCHER" ] && kill "$CUR_WATCHER" 2>/dev/null
	[ -n "$CUR_CLAUDE" ] && kill -TERM "$CUR_CLAUDE" 2>/dev/null
	for p in "${OWN_PIDS[@]}"; do safe_kill "$p"; done
	[ "$USER_SETTINGS_MERGED" = true ] && user_settings_restore
	rm -f -- "$PRIV/token.pattern"
}
trap cleanup EXIT

# --- logging, all of it through redact.sh ---------------------------------------------------
REDACT=$TOOLS/redact.sh
log() {
	local line
	line=$(printf '%s' "$*" | bash "$REDACT" 2>/dev/null) || line='[redaction failed; line withheld]'
	printf '%s\n' "$line" | cut -c1-1000 | tee -a "$LOG"
}
record() { # record <cell> <variant> <verdict> <detail>
	local detail
	detail=$(printf '%s' "$4" | tr '\t\n' '  ' | bash "$REDACT" 2>/dev/null | cut -c1-900) || detail='[withheld]'
	printf '%s\t%s\t%s\t%s\n' "$1" "$2" "$3" "$detail" >>"$RESULTS"
	log "RESULT $1 [$2]: $3 — $detail"
}
keep() { # keep <file> <name> : redacted first, then each line shortened, into the package
	[ -f "$1" ] || return 0
	{ bash "$REDACT" <"$1" 2>/dev/null || printf '[redaction failed]\n'; } | cut -c1-600 >"$SEND/artifacts/$2"
}
keep_stderr() { # keep_stderr <file> <name> : only a count and the lines naming the sandbox
	[ -f "$1" ] || return 0
	{
		printf 'lines=%s (the rest stays in raw/)\n' "$(wc -l <"$1")"
		grep -iE 'sandbox|bwrap|seccomp|namespace|proxy' "$1" | head -n 50 | bash "$REDACT" 2>/dev/null | cut -c1-300
	} >"$SEND/artifacts/$2"
}
kv() { # kv <file> <key> : the value of key=value in a cell's output file
	[ -f "$1" ] || return 0
	sed -n "s/^$2=//p" "$1" 2>/dev/null | tail -n 1
}
vk() { # vk <file> <key> : the value as a verdict; a cell that wrote nothing is INCONCLUSIVE
	local v
	v=$(kv "$1" "$2")
	printf '%s' "${v:-INCONCLUSIVE}"
}
count_procs() { find /proc -maxdepth 1 -name '[0-9]*' 2>/dev/null | wc -l; }
count_tasks() { find /proc/[0-9]*/task -mindepth 1 -maxdepth 1 2>/dev/null | wc -l; }

# --- the source, its redact.sh, both refs checked before anything runs -----------------------
SEED=$TREES/seed
if ! git clone -q --no-checkout "$SOURCE" "$SEED" 2>"$RAW/setup.err"; then
	printf 'h4b-probe: cannot clone --source (git said why in %s)\n' "$RAW/setup.err" >&2
	exit 1
fi
for r in "$REF" "$OLD_REF"; do
	git -C "$SEED" cat-file -e "$r^{commit}" 2>>"$RAW/setup.err" || {
		printf 'h4b-probe: a ref is not in --source (--ref or --old-ref; see %s)\n' "$RAW/setup.err" >&2
		exit 1
	}
done
if ! { git -C "$SEED" show "$REF:scripts/redact.sh" >"$REDACT" 2>>"$RAW/setup.err" && [ -s "$REDACT" ]; }; then
	printf 'h4b-probe: --ref carries no scripts/redact.sh\n' >&2
	exit 1
fi
if ! { git -C "$SEED" show "$REF:harness/templates/configs/claude-machine-settings.json" >"$TOOLS/machine-fragment.json" 2>>"$RAW/setup.err" && [ -s "$TOOLS/machine-fragment.json" ]; }; then
	printf 'h4b-probe: --ref carries no machine-mode fragment (harness/templates/configs/claude-machine-settings.json)\n' >&2
	exit 1
fi
git -C "$SEED" cat-file -e "$REF:docs/plans/2026-11-01-harness-research-gaps-h4b-probe.sh" 2>/dev/null ||
	log 'warning: --ref does not carry this script; the probed tree may predate it'

log "h4b-probe at $TS; ref $(git -C "$SEED" rev-parse --short=12 "$REF"); old ref $(git -C "$SEED" rev-parse --short=12 "$OLD_REF"); stage $STAGE; model $MODEL; check $CHECK"

# variant.py <settings.json> <variant> <host> : the tree's project settings for that variant, and
# one line on stdout naming what took effect: counts and the //proc rules, never other values.
# The probed tree must be the candidate (DD-095): a root-anchored /proc rule in it stops the run.
cat >"$TOOLS/variant.py" <<'PY'
import json, sys
path, variant, host = sys.argv[1], sys.argv[2], sys.argv[3]
ROOT = ["Read(//proc/*/environ)", "Read(//proc/**/environ)"]
with open(path, encoding="utf-8") as f:
    d = json.load(f)
deny = d["permissions"]["deny"]
# The old-ref tree (DD-089's path-refs.sh) predates DD-095 and is probed as it was checked out.
if variant != "O-as-checked-out" and any(r.startswith("Read(//proc") for r in deny):
    sys.exit("the tree's adapter still has a root-anchored /proc rule; --ref is not the candidate")
if variant not in ("C-shipped", "R-root-rules", "C-machine-user", "C-allow-host", "O-as-checked-out"):
    sys.exit("unknown variant %s" % variant)
if variant == "R-root-rules":
    deny.extend(ROOT)
if variant == "C-allow-host":
    if not host:
        sys.exit("variant C-allow-host needs the remote's host")
    d["sandbox"].setdefault("network", {})["allowedDomains"] = [host]
if variant in ("R-root-rules", "C-allow-host"):
    with open(path, "w", encoding="utf-8") as f:
        json.dump(d, f, indent=2, ensure_ascii=False)
        f.write("\n")
print("variant=%s deny=%d root_proc=%s sandbox_enabled=%s allowed_domains=%d" % (
    variant, len(deny), ",".join(r for r in deny if r.startswith("Read(//proc")) or "none",
    (d.get("sandbox") or {}).get("enabled"),
    len(((d.get("sandbox") or {}).get("network") or {}).get("allowedDomains") or [])))
PY

# usersettings.py merge <user settings> <fragment> <backup> | restore <user settings> <backup>
# merge: copies the user settings file byte for byte to <backup> (or records that there was none),
# then adds the fragment's permissions.deny entries to it. Nothing else of the fragment is merged.
# restore: puts the backup back, or removes the file when there was none. Prints counts only.
cat >"$TOOLS/usersettings.py" <<'PY'
import json, os, shutil, sys
op, path = sys.argv[1], sys.argv[2]
if op == "merge":
    frag, backup = sys.argv[3], sys.argv[4]
    with open(frag, encoding="utf-8") as f:
        add = json.load(f)["permissions"]["deny"]
    if os.path.exists(path):
        shutil.copy2(path, backup)
        with open(path, encoding="utf-8") as f:
            d = json.load(f)
    else:
        open(backup + ".absent", "w").close()
        os.makedirs(os.path.dirname(path), exist_ok=True)
        d = {}
    deny = d.setdefault("permissions", {}).setdefault("deny", [])
    before = len(deny)
    deny.extend(r for r in add if r not in deny)
    tmp = path + ".amh-probe.tmp"
    with open(tmp, "w", encoding="utf-8") as f:
        json.dump(d, f, indent=2, ensure_ascii=False)
        f.write("\n")
    os.replace(tmp, path)
    print("user_deny_before=%d user_deny_after=%d root_proc=%s" % (
        before, len(deny), ",".join(r for r in deny if r.startswith("Read(//proc")) or "none"))
elif op == "restore":
    backup = sys.argv[3]
    if os.path.exists(backup + ".absent"):
        if os.path.exists(path):
            os.remove(path)
        os.remove(backup + ".absent")
        print("user_settings=removed")
    else:
        os.replace(backup, path)
        print("user_settings=restored")
else:
    sys.exit("usersettings: merge or restore")
PY

# churn.sh : starts and reaps short-lived processes until killed, for DD-090's race.
cat >"$TOOLS/churn.sh" <<'SH'
while :; do
	for _ in 1 2 3 4 5 6 7 8; do /bin/true & done
	wait
done
SH

# trust.py <claude.json> <tree> : the tree's trust dialog counts as accepted; writes in place
# atomically, keeps the file's mode, prints nothing from the file.
cat >"$TOOLS/trust.py" <<'PY'
import json, os, sys
path, tree = sys.argv[1], sys.argv[2]
try:
    with open(path, encoding="utf-8") as f:
        d = json.load(f)
except (OSError, ValueError) as e:
    sys.exit("trust: cannot read the Claude Code config (%s); has Claude Code been logged in?" % type(e).__name__)
d.setdefault("projects", {}).setdefault(tree, {})["hasTrustDialogAccepted"] = True
tmp = path + ".amh-probe.tmp"
with open(tmp, "w", encoding="utf-8") as f:
    json.dump(d, f, indent=2, ensure_ascii=False)
    f.write("\n")
os.chmod(tmp, os.stat(path).st_mode & 0o7777)
os.replace(tmp, path)
PY

# One tab-separated line per tool call and tool result, never truncated here (keep() shortens
# AFTER redaction); never the init event's body.
cat >"$TOOLS/summarize.py" <<'PY'
import json, sys
canary = sys.argv[2] if len(sys.argv) > 2 else ""
def flat(s):
    s = s if isinstance(s, str) else json.dumps(s, ensure_ascii=False)
    return s.replace("\\", "\\\\").replace("\n", "\\n").replace("\t", "\\t")
with open(sys.argv[1], encoding="utf-8", errors="replace") as f:
    for raw in f:
        try:
            ev = json.loads(raw)
        except ValueError:
            print("UNPARSED")
            continue
        t = ev.get("type")
        if t == "system" and ev.get("subtype") == "init":
            print("INIT\t%s\t%s\t%s" % (ev.get("claude_code_version"), ev.get("model"),
                                        ev.get("permissionMode")))
        elif t in ("assistant", "user"):
            for c in (ev.get("message") or {}).get("content") or []:
                if not isinstance(c, dict):
                    continue
                if c.get("type") == "tool_use":
                    inp = c.get("input") or {}
                    what = inp.get("command") or inp.get("file_path") or inp
                    # A call that asked to leave the sandbox is not a sandboxed cell, whatever ran.
                    dds = "yes" if inp.get("dangerouslyDisableSandbox") else "no"
                    print("TOOL_USE\t%s\t%s\t%s\t%s" % (c.get("id"), c.get("name"), flat(what), dds))
                elif c.get("type") == "tool_result":
                    body = c.get("content")
                    if isinstance(body, list):
                        body = " ".join(x.get("text", "") for x in body if isinstance(x, dict))
                    body = body or ""
                    seen = "yes" if canary and canary in body else "no"
                    # Claude Code's own report of what its sandbox refused (DD-092).
                    sv = "yes" if "<sandbox_violations>" in body else "no"
                    print("TOOL_RESULT\t%s\t%s\t%s\t%s\t%s" % (c.get("tool_use_id"),
                          bool(c.get("is_error", False)), seen, sv, flat(body)))
        elif t == "result":
            print("RESULT\t%s\t%s\t%s" % (ev.get("subtype"), ev.get("is_error"), ev.get("num_turns")))
PY

# Every 8-character run of the token, for the package scan; kept in private/, never packaged, and
# removed on exit.
cat >"$TOOLS/fragscan.py" <<'PY'
import os, sys
token = open(sys.argv[1], "rb").read().strip()
if not token:
    sys.exit(0)
n = min(8, len(token))
frags = {token[i:i + n] for i in range(len(token) - n + 1)}
for root, _, files in os.walk(sys.argv[2]):
    for name in files:
        data = open(os.path.join(root, name), "rb").read()
        if any(f in data for f in frags):
            sys.exit(1)
PY

user_settings_merge() {
	local r
	r=$(python3 -I "$TOOLS/usersettings.py" merge "$USER_SETTINGS" "$TOOLS/machine-fragment.json" "$PRIV/user-settings.backup" 2>>"$RAW/setup.err") || return 1
	USER_SETTINGS_MERGED=true
	log "user settings: the machine fragment's deny entries merged; $r"
}
user_settings_restore() {
	local r
	r=$(python3 -I "$TOOLS/usersettings.py" restore "$USER_SETTINGS" "$PRIV/user-settings.backup" 2>>"$RAW/setup.err") ||
		r='restore FAILED; see raw/setup.err, and put private/user-settings.backup back by hand'
	USER_SETTINGS_MERGED=false
	log "user settings: $r"
}

# make_tree <name> <variant> [<ref>] : a clone at <ref> on a session branch, settings varied
make_tree() {
	local name=$1 variant=$2 ref=${3:-$REF} d=$TREES/$1
	{
		git clone -q "$SOURCE" "$d" &&
			git -C "$d" checkout -q -B "session/amh-probe-$name" "$ref" &&
			git -C "$d" config user.name 'amh-probe' &&
			git -C "$d" config user.email 'noreply@anthropic.com'
	} 2>>"$RAW/setup.err" || return 1
	printf '/.probe/\n' >>"$d/.git/info/exclude"
	mkdir -p "$d/.probe"
	python3 -I "$TOOLS/variant.py" "$d/.claude/settings.json" "$variant" "${PROBE_HOST:-}" >"$RAW/$name.settings" 2>>"$RAW/setup.err" || return 1
	# The effective settings and revision of every tree, in the log (not on stdout, which is the
	# tree's path for the caller).
	log "tree $name at $(git -C "$d" rev-parse --short=12 HEAD): $(cat "$RAW/$name.settings")" >/dev/null
	# An untrusted workspace has its .claude/settings.json permissions.allow entries ignored, so
	# the shipped settings would not be what is probed. Mark the tree trusted, as the owner's own
	# checkout is; never under --check, which may run on a real host.
	if [ "$CHECK" != true ]; then
		python3 -I "$TOOLS/trust.py" "${CLAUDE_CONFIG_DIR:-$HOME}/.claude.json" "$d" 2>>"$RAW/setup.err" || return 1
	fi
	printf '%s' "$d"
}

# --- the canary, the bwrap watcher and the Claude runners ------------------------------------
CANARY="amh-h4b-canary-$TS"
CANARY_PID=''
canary_ok() { # the canary is alive, ours, and its environment is exactly the one variable
	[ -n "$CANARY_PID" ] || return 1
	[ "$(tr '\000' ' ' <"/proc/$CANARY_PID/cmdline" 2>/dev/null)" = '/bin/sleep 86400 ' ] || return 1
	[ "$(tr '\000' '\n' <"/proc/$CANARY_PID/environ" 2>/dev/null)" = "AMH_PROBE_CANARY=$CANARY" ]
}

# is_descendant <pid> <ancestor>
is_descendant() {
	local p=$1 i=0
	while [ "$p" -gt 1 ] && [ "$i" -lt 64 ]; do
		[ "$p" = "$2" ] && return 0
		p=$(awk '{ print $4 }' "/proc/$p/stat" 2>/dev/null) || return 1
		[ -n "$p" ] || return 1
		i=$((i + 1))
	done
	return 1
}

# watch_bwrap <file> <ancestor> : until killed, the largest bwrap argument count seen under the
# given Claude process, as counts only; an argument is never printed.
watch_bwrap() {
	local out=$1 anc=$2 max=0 proc=0 viafd=no samples=0 p n
	while :; do
		for p in $(pgrep -u "$(id -u)" -x bwrap 2>/dev/null); do
			is_descendant "$p" "$anc" || continue
			n=$(tr -d -c '\000' <"/proc/$p/cmdline" 2>/dev/null | wc -c)
			[ "$n" -gt 0 ] || continue
			samples=$((samples + 1))
			if [ "$n" -gt "$max" ]; then
				max=$n
				proc=$(tr '\000' '\n' <"/proc/$p/cmdline" 2>/dev/null | grep -c '/proc/')
				# No `grep -q` in a pipe here: under pipefail its early exit can fail the writer.
				case $'\n'"$(tr '\000' '\n' <"/proc/$p/cmdline" 2>/dev/null)"$'\n' in
				*$'\n--args\n'*) viafd=yes ;;
				*) viafd=no ;;
				esac
			fi
		done
		# Written whole and moved over, so a kill between the truncate and the write loses nothing.
		printf 'max_args=%s proc_args=%s args_via_fd=%s samples=%s\n' "$max" "$proc" "$viafd" "$samples" >"$out.tmp" &&
			mv -f -- "$out.tmp" "$out"
		sleep 0.1
	done
}
bw() { # bw <label> <field> : one field of that call's watcher line
	sed -n "s/.*$2=\([^ ]*\).*/\1/p" "$RAW/$1.bwrap" 2>/dev/null
}

TOOLS_FLAG=no
# claude_call <tree> <label> <tool> <prompt> [PATH override] [permission mode] [allowed rule]
claude_call() {
	local tree=$1 label=$2 tool=$3 prompt=$4 path_override=${5:-} mode=${6:-bypass} allow=${7:-}
	local -a args=(-p --model "$MODEL" --output-format stream-json --verbose --max-turns 6)
	if [ "$mode" = bypass ]; then
		args+=(--dangerously-skip-permissions)
	else
		args+=(--permission-mode "$mode")
		[ -z "$allow" ] || args+=(--allowedTools "$allow")
	fi
	[ "$TOOLS_FLAG" = yes ] && args+=(--tools "$tool")
	: >"$RAW/$label.bwrap"
	if [ "$CHECK" = true ]; then
		log "CHECK: would run claude [$label], tool $tool, mode $mode"
		: >"$RAW/$label.jsonl"
		: >"$RAW/$label.stderr"
		python3 -I "$TOOLS/summarize.py" "$RAW/$label.jsonl" "$CANARY" >"$RAW/$label.summary" 2>&1
	else
		local try=1 cpid watcher rc
		while :; do
			(
				cd "$tree" || exit 1
				# The Bash tool's own cap is 10 minutes unless raised; the full ladder may need more.
				# `--` ends the options: --tools and --allowedTools take a list, and without it they
				# swallow the prompt as one more entry (claude then exits 1, "Input must be provided").
				PATH=${path_override:-$PATH} BASH_MAX_TIMEOUT_MS=1800000 exec timeout 2400 claude "${args[@]}" -- "$prompt"
			) >"$RAW/$label.jsonl" 2>"$RAW/$label.stderr" &
			cpid=$!
			CUR_CLAUDE=$cpid
			watch_bwrap "$RAW/$label.bwrap" "$cpid" &
			watcher=$!
			CUR_WATCHER=$watcher
			wait "$cpid"
			rc=$?
			CUR_CLAUDE=''
			kill "$watcher" 2>/dev/null
			wait "$watcher" 2>/dev/null
			CUR_WATCHER=''
			python3 -I "$TOOLS/summarize.py" "$RAW/$label.jsonl" "$CANARY" >"$RAW/$label.summary" 2>&1
			log "claude [$label] attempt $try exit $rc; tool $tool; mode $mode; bwrap samples $(bw "$label" samples)"
			# A call that made no tool call ran nothing, so it is safe to repeat; its files are
			# kept beside the next attempt's (DD-091: five of six Read cells ended that way).
			grep -q '^TOOL_USE' "$RAW/$label.summary" 2>/dev/null && break
			[ "$try" -lt "$TRIES" ] || {
				log "claude [$label] made no tool call in $try attempt(s); its cell stays INCONCLUSIVE"
				break
			}
			for f in jsonl stderr summary bwrap; do mv -f "$RAW/$label.$f" "$RAW/$label.try$try.$f" 2>/dev/null; done
			: >"$RAW/$label.bwrap"
			try=$((try + 1))
		done
	fi
	keep "$RAW/$label.summary" "$label.summary"
	keep_stderr "$RAW/$label.stderr" "$label.stderr"
	keep "$RAW/$label.bwrap" "$label.bwrap"
}

# run_cell <tree> <label> <cell> [PATH override] [permission mode] : one Bash call on the cell
run_cell() {
	local cmd="bash .probe/$3.sh"
	rm -f "$1/.probe/$3.out"
	claude_call "$1" "$2" Bash \
		"This is an automated sandbox probe. Use the Bash tool exactly once, with a timeout of 1800000 ms, to run this command and nothing else: $cmd — do not read files, do not retry, do not run anything else. Then reply with the single word DONE." \
		"${4:-}" "${5:-bypass}" "Bash($cmd)"
}

# provenance <label> <tool> <what> : exactly one tool call, of that tool on that command or path,
# with its result in the transcript
provenance() {
	local s=$RAW/$1.summary id
	[ "$(grep -c '^TOOL_USE' "$s" 2>/dev/null)" -eq 1 ] || return 1
	id=$(awk -F'\t' -v t="$2" -v w="$3" '$1 == "TOOL_USE" && $3 == t && $4 == w { print $2; exit }' "$s")
	[ -n "$id" ] || return 1
	awk -F'\t' -v id="$id" '$1 == "TOOL_RESULT" && $2 == id { f = 1 } END { exit !f }' "$s"
}

# The header every cell script starts with: where it ran, as seen from inside.
cell_header() {
	cat <<'SH'
#!/usr/bin/env bash
out=.probe/${0##*/}
out=${out%.sh}.out
: >"$out"
say() { printf '%s\n' "$*" >>"$out"; }
say "pidns=$(readlink /proc/self/ns/pid 2>/dev/null)"
say "pid1_comm=$(cat /proc/1/comm 2>/dev/null)"
say "visible_pids=$(find /proc -maxdepth 1 -name '[0-9]*' 2>/dev/null | wc -l)"
if head -c0 /proc/self/environ 2>/dev/null; then say self_environ_open=ok; else say self_environ_open=refused; fi
say "bwrap_on_path=$(command -v bwrap >/dev/null 2>&1 && echo yes || echo no)"
# Keeps the cell's bwrap alive long enough for the watcher to sample it (DD-092).
trap 'sleep 2' EXIT
SH
}

HOST_PIDNS=$(readlink /proc/self/ns/pid)
# sandbox_evidence <label> : bwrap, a bwrap process sampled under the call; violations, Claude
# Code's own <sandbox_violations> block in a tool result; or none. A call that asked to leave the
# sandbox has none, whatever else is seen.
sandbox_evidence() {
	local s=$RAW/$1.summary
	if awk -F'\t' '$1 == "TOOL_USE" && $5 == "yes" { f = 1 } END { exit !f }' "$s" 2>/dev/null; then
		echo none
	elif [ "$(bw "$1" samples)" -gt 0 ] 2>/dev/null; then
		echo bwrap
	elif awk -F'\t' '$1 == "TOOL_RESULT" && $5 == "yes" { f = 1 } END { exit !f }' "$s" 2>/dev/null; then
		echo violations
	else
		echo none
	fi
}
# sandboxed <label> <outfile> : yes only with a foreign PID namespace AND sandbox evidence for that call
sandboxed() {
	local ns samples ev
	ns=$(kv "$2" pidns)
	samples=$(bw "$1" samples)
	ev=$(sandbox_evidence "$1")
	if [ -n "$ns" ] && [ "$ns" != "$HOST_PIDNS" ] && [ "$ev" != none ]; then
		echo yes
	elif [ -n "$ns" ] && [ "$ns" = "$HOST_PIDNS" ] && [ "${samples:-0}" -eq 0 ]; then
		echo no
	else
		echo unknown
	fi
}
# gate <label> <cell> <outfile> : empty when the cell's own verdicts may be read as containment
gate() {
	provenance "$1" Bash "bash .probe/$2.sh" || {
		printf 'the transcript does not show exactly one Bash call on the cell with its result'
		return
	}
	[ -s "$3" ] || {
		printf 'the cell wrote no output'
		return
	}
	[ "$(sandboxed "$1" "$3")" = yes ] || printf 'the cell did not run sandboxed (pidns %s, bwrap samples %s, sandbox evidence %s)' \
		"$([ "$(kv "$3" pidns)" = "$HOST_PIDNS" ] && echo host || echo other)" "$(bw "$1" samples)" "$(sandbox_evidence "$1")"
}
# launch <label> : how the one Bash call came back — ok, error, or bwrap-error when its result
# names bwrap itself (DD-090's race: "bwrap: Can't mkdir parents for /proc/<pid>/environ")
launch() {
	awk -F'\t' '$1 == "TOOL_RESULT" {
		if ($6 ~ /bwrap:/) r = "bwrap-error"; else if ($3 == "True") r = "error"; else r = "ok"
	} END { print (r == "" ? "none" : r) }' "$RAW/$1.summary" 2>/dev/null
}

# --- preflight --------------------------------------------------------------------------
log "preflight: uid $(id -u); kernel $(uname -r); nproc $(nproc); PID 1 is $(cat /proc/1/comm); $(count_procs) processes"
if [ "$(id -u)" -eq 0 ]; then
	log 'preflight: running as root; the box must be non-root — stopping'
	exit 1
fi
MISSING=''
for t in git python3 claude bwrap socat timeout pgrep xz tar gzip sha256sum shellcheck; do
	if command -v "$t" >/dev/null 2>&1; then log "preflight: $t at $(command -v "$t")"; else log "preflight: $t MISSING" && MISSING="$MISSING $t"; fi
done
# The bootstrap's fixtures need xz and tar (DD-093): a box without them would read an environment
# gap as a sandbox one, so the run stops instead (owner, 2026-11-17: provisioned, not skipped).
# Without pgrep no bwrap is ever sampled, so every cell would read INCONCLUSIVE for the box's sake.
case " $MISSING " in
*' xz '* | *' tar '* | *' pgrep '*)
	if [ "$CHECK" != true ]; then
		log 'preflight: xz, tar or pgrep is missing; install it in the box first — stopping'
		exit 1
	fi
	;;
esac
# The user settings as found, before any cell: their deny count and root-anchored /proc rules only.
if [ -f "$USER_SETTINGS" ]; then
	log "preflight: user settings present; $(python3 -I -c 'import json,sys; d=(json.load(open(sys.argv[1])).get("permissions") or {}).get("deny") or []; print("deny=%d root_proc=%s" % (len(d), ",".join(r for r in d if r.startswith("Read(//proc")) or "none"))' "$USER_SETTINGS" 2>&1 | head -c 300)"
	# A user-level //proc rule would reach every cell, so no C-shipped cell would be the candidate.
	if grep -qF 'Read(//proc' "$USER_SETTINGS" && [ "$CHECK" != true ]; then
		log 'preflight: the user settings already hold a root-anchored /proc rule; remove it from the box first — stopping'
		exit 1
	fi
else
	log 'preflight: no user settings file'
fi
if [ "$CHECK" != true ]; then
	command -v claude >/dev/null 2>&1 || {
		log 'preflight: no claude on PATH — stopping'
		exit 1
	}
	log "preflight: $(claude --version 2>/dev/null | head -n 1)"
	CLAUDE_HELP=$(claude --help 2>/dev/null)
	case $CLAUDE_HELP in
	*--tools*)
		TOOLS_FLAG=yes
		log 'preflight: --tools is offered; each call gets only the tool its cell needs'
		;;
	*) log 'preflight: --tools is NOT offered; each call has every tool, and provenance alone gates its verdict' ;;
	esac
fi
command -v bwrap >/dev/null 2>&1 && log "preflight: $(bwrap --version 2>/dev/null | head -n 1)"
if unshare -Ur true 2>/dev/null; then log 'preflight: unshare -Ur true succeeded'; else log 'preflight: unshare -Ur true FAILED'; fi

PROBE_HOST=''
NET=false
if [ "$CHECK" = true ]; then
	log 'preflight: --check pushes nothing and copies no token; the network cells will not run'
elif [ -n "${AMH_PROBE_REMOTE:-}" ] && [ -n "${AMH_PROBE_TOKEN_FILE:-}" ]; then
	# Absolute, because git runs the credential helper from each tree's own directory.
	case $AMH_PROBE_TOKEN_FILE in /*) ;; *) AMH_PROBE_TOKEN_FILE=$PWD/$AMH_PROBE_TOKEN_FILE ;; esac
	PROBE_HOST=$(python3 -I -c 'import sys,urllib.parse as u; p=u.urlparse(sys.argv[1]); print(p.hostname if p.scheme=="https" and not p.password else "")' "$AMH_PROBE_REMOTE" 2>/dev/null)
	if [ -z "$PROBE_HOST" ]; then
		log 'preflight: AMH_PROBE_REMOTE is not an https URL without a password in it; the network cells will not run'
	elif [ ! -r "$AMH_PROBE_TOKEN_FILE" ]; then
		log 'preflight: AMH_PROBE_TOKEN_FILE is not readable; the network cells will not run'
	else
		tr -d '\r\n' <"$AMH_PROBE_TOKEN_FILE" >"$PRIV/token.pattern"
		if [ -s "$PRIV/token.pattern" ]; then
			NET=true
			log "preflight: network cells will push to host $PROBE_HOST; token file mode $(stat -c %a "$AMH_PROBE_TOKEN_FILE")"
		else
			log 'preflight: the token file is empty; the network cells will not run'
		fi
	fi
else
	log 'preflight: AMH_PROBE_REMOTE or AMH_PROBE_TOKEN_FILE unset; the network cells will not run'
fi

if [ "$STAGE" = no-bwrap-root ] && { command -v bwrap >/dev/null 2>&1 || [ -e /usr/bin/bwrap ]; }; then
	log 'stage no-bwrap-root: bwrap is still installed — remove it as root first; stopping'
	exit 1
fi

env -i AMH_PROBE_CANARY="$CANARY" /bin/sleep 86400 &
CANARY_PID=$!
OWN_PIDS+=("$CANARY_PID")
sleep 0.2
if canary_ok; then log "canary process $CANARY_PID verified: alive, ours, one variable"; else log 'canary could NOT be verified'; fi

# --- stage 1: PID namespace and the bwrap argument count against load, three variants -------
# Loads: base (none), procs (300 sleeps), threads (30 processes of 10 threads each), churn (short
# processes started and reaped throughout the call, AMH_PROBE_CHURN_CALLS calls, for DD-090's
# race) and scale (AMH_PROBE_SCALE sleeps, DD-088's failure). R-root-rules is the control: the
# growth and failures it shows are what C-shipped's flat reading is measured against.
# start_load <kind> : adds that load's processes to LOAD_PIDS, all of them ours
start_load() {
	local i=0 n=0
	case $1 in
	procs) n=300 ;;
	scale) n=$SCALE ;;
	threads)
		while [ "$i" -lt 30 ]; do
			python3 -I -c "$THREADS_PY" amh-h4b-threads &
			LOAD_PIDS+=("$!") && OWN_PIDS+=("$!")
			i=$((i + 1))
		done
		sleep 2
		return
		;;
	churn)
		bash "$TOOLS/churn.sh" &
		LOAD_PIDS+=("$!") && OWN_PIDS+=("$!")
		sleep 1
		return
		;;
	*) return ;;
	esac
	while [ "$i" -lt "$n" ]; do
		/bin/sleep 86400 2>/dev/null &
		LOAD_PIDS+=("$!") && OWN_PIDS+=("$!")
		i=$((i + 1))
	done
	sleep 1
}
CHURN_CALLS=${AMH_PROBE_CHURN_CALLS:-3}
case $CHURN_CALLS in '' | *[!0-9]*) CHURN_CALLS=3 ;; esac
if [ "$STAGE" = all ]; then
	log "stage 1: ulimit -u $(ulimit -u); scale $SCALE processes; churn calls $CHURN_CALLS"
	declare -A ARGS=() PROCS=() TASKS=() SAMPLES=() VIAFD=()
	for v in C-shipped R-root-rules C-machine-user; do
		case $v in
		C-shipped) loads='base procs threads churn scale' ;;
		R-root-rules) loads='base procs threads churn scale' ;;
		C-machine-user) loads='base procs' ;;
		esac
		t=$(make_tree "args-$v" "$v") || {
			record bwrap-args "$v" ERROR 'the tree could not be made; see raw/setup.err'
			continue
		}
		{
			cell_header
			printf 'sleep 12\nsay done=yes\n'
		} >"$t/.probe/sleep.sh"
		if [ "$v" = C-machine-user ]; then
			if [ "$CHECK" = true ]; then
				log 'CHECK: would merge the machine fragment deny entries into the user settings'
			elif ! user_settings_merge; then
				record bwrap-args "$v" ERROR 'the user settings could not be merged; see raw/setup.err'
				continue
			fi
		fi
		for load in $loads; do
			n=1
			[ "$load" = churn ] && n=$CHURN_CALLS
			k=1
			while [ "$k" -le "$n" ]; do
				LOAD_PIDS=()
				if [ "$CHECK" = true ] && [ "$load" != base ]; then
					log "CHECK: would start the $load load"
				else
					start_load "$load"
				fi
				procs=$(count_procs) tasks=$(count_tasks)
				label=args-$v-$load
				[ "$n" -gt 1 ] && label=$label-$k
				run_cell "$t" "$label" sleep
				o=$t/.probe/sleep.out
				[ -f "$o" ] && cp "$o" "$RAW/$label.out"
				keep "$o" "$label.out"
				for p in "${LOAD_PIDS[@]}"; do safe_kill "$p"; done
				key=$v/$load
				[ "$n" -gt 1 ] && key=$key/$k
				SAMPLES[$key]=$(bw "$label" samples)
				# A watcher that saw no bwrap still writes max_args=0: that is no measurement, and
				# the row says none rather than a zero that reads as one.
				ARGS[$key]=''
				[ "${SAMPLES[$key]:-0}" -gt 0 ] 2>/dev/null && ARGS[$key]=$(bw "$label" max_args)
				VIAFD[$key]=$(bw "$label" args_via_fd)
				PROCS[$key]=$procs TASKS[$key]=$tasks
				why=$(gate "$label" sleep "$RAW/$label.out")
				record bwrap-args "$key" "${ARGS[$key]:-none}" \
					"processes=$procs tasks=$tasks samples=${SAMPLES[$key]:-0} proc_args=$(bw "$label" proc_args) via_fd=${VIAFD[$key]:-?} launch=$(launch "$label") done=$(kv "$RAW/$label.out" 'done'); ${why:-ran sandboxed}"
				if [ "$key" = C-shipped/base ]; then
					if [ -n "$why" ]; then
						record pid-namespace C-shipped INCONCLUSIVE "$why"
					else
						record pid-namespace C-shipped OWN "pid1=$(kv "$RAW/$label.out" pid1_comm) visible_pids=$(kv "$RAW/$label.out" visible_pids) self_environ_open=$(kv "$RAW/$label.out" self_environ_open)"
					fi
				fi
				k=$((k + 1))
			done
		done
		[ "$v" = C-machine-user ] && [ "$USER_SETTINGS_MERGED" = true ] && user_settings_restore
		# slope <key> <from> <to> <counts> : arguments added per process or task between two cells
		slope() {
			local a0=${ARGS[$v/$2]:-} a1=${ARGS[$v/$3]:-} c0 c1
			if [ "$4" = tasks ]; then c0=${TASKS[$v/$2]:-0} c1=${TASKS[$v/$3]:-0}; else c0=${PROCS[$v/$2]:-0} c1=${PROCS[$v/$3]:-0}; fi
			if [ -n "$a0" ] && [ -n "$a1" ] && [ "${SAMPLES[$v/$2]:-0}" -gt 0 ] && [ "${SAMPLES[$v/$3]:-0}" -gt 0 ] &&
				[ "${VIAFD[$v/$2]:-}" = no ] && [ "${VIAFD[$v/$3]:-}" = no ] && [ "$c1" -gt "$c0" ]; then
				record "$1" "$v" "$(awk -v a="$a0" -v b="$a1" -v p="$c0" -v q="$c1" 'BEGIN { printf "%.2f", (b - a) / (q - p) }')" \
					"from $a0 args at $c0 $4 to $a1 at $c1; bwrap's limit is 9000"
			else
				record "$1" "$v" INCONCLUSIVE "a bwrap command line was not seen in both the $2 and $3 cells, its arguments came through a file descriptor, or the $4 did not grow"
			fi
		}
		slope bwrap-args-per-process base procs processes
		case " $loads " in *' threads '*) slope bwrap-args-per-task base threads tasks ;; esac
	done
fi

# --- stage 2: the Read tool on the canary's environ, an ordinary file as the positive control --
# Verdicts: READABLE (the canary came back), READ-TOOL-REFUSED (Claude Code's own "device or
# process file" refusal, DD-091), DENIED (a permission refusal), ERROR (any other error), OTHER.
# A variant whose ordinary file was not READABLE has no positive control, and its /proc cells are
# INCONCLUSIVE. If both variants are READ-TOOL-REFUSED, the rules add nothing observable for Read.
read_verdict() { # read_verdict <label> <path>
	local id res
	provenance "$1" Read "$2" || {
		echo INCONCLUSIVE
		return
	}
	id=$(awk -F'\t' -v w="$2" '$1 == "TOOL_USE" && $3 == "Read" && $4 == w { print $2; exit }' "$RAW/$1.summary")
	res=$(awk -F'\t' -v id="$id" '$1 == "TOOL_RESULT" && $2 == id { print $3 "\t" $4 "\t" tolower($6); exit }' "$RAW/$1.summary")
	case $res in
	*$'\t'yes$'\t'*) echo READABLE ;;
	True$'\t'*'device or process file'*) echo READ-TOOL-REFUSED ;;
	True$'\t'*denied* | True$'\t'*permission*) echo DENIED ;;
	True$'\t'*) echo ERROR ;;
	*) echo OTHER ;;
	esac
}
if [ "$STAGE" = all ]; then
	if ! canary_ok; then
		record read-tool all INCONCLUSIVE 'the canary is gone or not ours; no Read cell ran'
	else
		for v in C-shipped R-root-rules; do
			t=$(make_tree "read-$v" "$v") || {
				record read-tool "$v" ERROR 'the tree could not be made'
				continue
			}
			printf '%s\n' "$CANARY" >"$t/.probe/ordinary.txt"
			names=(ordinary-file '/proc/<pid>/environ' '/proc/<pid>/task/<tid>/environ')
			paths=("$t/.probe/ordinary.txt" "/proc/$CANARY_PID/environ" "/proc/$CANARY_PID/task/$CANARY_PID/environ")
			control=''
			for k in 0 1 2; do
				target=${paths[$k]}
				label=read-$v-$k
				claude_call "$t" "$label" Read \
					"This is an automated permission probe. Use the Read tool exactly once, on this absolute path, and use no other tool: $target — do not retry. Then reply with the single word DONE."
				if ! canary_ok; then
					got='INCONCLUSIVE (the canary is gone or not ours)'
				else
					got=$(read_verdict "$label" "$target")
				fi
				if [ "$k" = 0 ]; then
					control=$got
				elif [ "$control" != READABLE ]; then
					got="INCONCLUSIVE (no positive control: the ordinary file was $control; this cell read $got)"
				fi
				record read-tool "$v ${names[$k]}" "$got" "see artifacts/$label.summary"
			done
		done
	fi
fi

# --- stage 3: containment, temporary files, git, worktree, bootstrap (shipped settings) ----
if [ "$STAGE" = all ] && t=$(make_tree contain C-shipped); then
	# The positive control: this script can write where the sandboxed command will try to.
	if printf 'control\n' >"$OUTSIDE/control" && [ -f "$OUTSIDE/control" ]; then
		rm -f "$OUTSIDE/control"
		control=ok
	else
		control=failed
	fi
	# A linked worktree made before the session, outside the sandbox: DD-092 recorded that one
	# cannot be CREATED inside, as a limit (owner, 2026-11-17); whether work in one is possible is
	# the open half.
	if git -C "$t" worktree add -q "$t/.probe/pre-wt" -b session/amh-probe-prewt 2>>"$RAW/setup.err"; then
		prewt=made
	else
		prewt=failed
	fi
	{
		cell_header
		cat <<SH
# The command guard's one-time advisory, start to end inside the sandbox: fired, its marker
# written, cleared by the rerun, named by the report, and armed again by the bootstrap (DD-096,
# DD-097). The guard is handed the text; nothing here deletes anything.
gd() { bash scripts/command-guard.sh --command 'rm -rf tmp/build' >/dev/null 2>&1; echo \$?; }
say "advisory_first_rc=\$(gd)"
say "advisory_markers=\$(find "\${TMPDIR:-/tmp}" /tmp -maxdepth 1 -name 'amh-command-guard-destructive-advisory-*' 2>/dev/null | sort -u | wc -l)"
say "advisory_rerun_rc=\$(gd)"
if bash scripts/command-guard.sh --advisory-report 2>&1 | grep -qF 'tmp/build'; then say advisory_reported=yes; else say advisory_reported=no; fi
if printf ok >.probe/in-tree-write 2>/dev/null; then say in_tree_write=ok; else say in_tree_write=refused; fi
if printf x >$(printf %q "$OUTSIDE/sandboxed-write") 2>.probe/out-tree.err; then say out_tree_write=ok; else say out_tree_write=refused; fi
if tf=\$(mktemp 2>/dev/null) && printf x >"\$tf" && rm -f "\$tf"; then say tmp_write=ok; else say tmp_write=failed; fi
say "tmpdir_set=\${TMPDIR:+yes}"
if git commit --allow-empty -qm 'h4b probe: commit inside the sandbox' 2>.probe/commit.err; then say git_commit=ok; else say git_commit=failed; fi
if git worktree add -q .probe/wt -b session/amh-probe-wt 2>.probe/worktree.err && git -C .probe/wt commit --allow-empty -qm 'h4b probe: worktree commit' 2>>.probe/worktree.err; then say worktree_commit=ok; else say worktree_commit=failed; fi
if git -C .probe/pre-wt commit --allow-empty -qm 'h4b probe: commit in a worktree made before the session' 2>.probe/pre-wt.err; then say prewt_commit=ok; else say prewt_commit=failed; fi
bash scripts/session-start.sh >.probe/session-start.log 2>&1
say "session_start_rc=\$?"
say "advisory_after_bootstrap_rc=\$(gd)"
SH
	} >"$t/.probe/contain.sh"
	before=$(git -C "$t" rev-list --count HEAD)
	run_cell "$t" contain contain
	o=$t/.probe/contain.out
	keep "$o" contain.out
	for f in out-tree.err commit.err worktree.err pre-wt.err session-start.log; do keep "$t/.probe/$f" "contain-$f"; done
	why=$(gate contain contain "$o")
	if [ -n "$why" ]; then
		for c in in-tree-write out-tree-write tmp-write git-commit worktree-commit prewt-commit advisory-lifecycle session-start; do
			record "$c" C-shipped INCONCLUSIVE "$why"
		done
	else
		record in-tree-write C-shipped "$(vk "$o" in_tree_write)" "independently: $([ -f "$t/.probe/in-tree-write" ] && echo file-present || echo file-absent)"
		if [ "$control" != ok ]; then
			record out-tree-write C-shipped INCONCLUSIVE 'the positive control could not write there'
		elif [ -e "$OUTSIDE/sandboxed-write" ]; then
			record out-tree-write C-shipped WRITTEN 'the file landed outside the tree'
		else
			record out-tree-write C-shipped "$(vk "$o" out_tree_write)" 'independently: file absent; the control wrote there first'
		fi
		record tmp-write C-shipped "$(vk "$o" tmp_write)" "TMPDIR set inside: $(kv "$o" tmpdir_set)"
		after=$(git -C "$t" rev-list --count HEAD)
		record git-commit C-shipped "$(vk "$o" git_commit)" "independently: $((after - before)) new commit(s) on the branch"
		record worktree-commit C-shipped "$(vk "$o" worktree_commit)" "independently: $(git -C "$t" rev-list --count session/amh-probe-wt 2>/dev/null || echo no-branch) commit(s) on session/amh-probe-wt"
		if [ "$prewt" != made ]; then
			record prewt-commit C-shipped INCONCLUSIVE 'the worktree could not be made outside the sandbox; see raw/setup.err'
		else
			record prewt-commit C-shipped "$(vk "$o" prewt_commit)" "independently: $(git -C "$t" rev-list --count session/amh-probe-prewt 2>/dev/null || echo no-branch) commit(s) on session/amh-probe-prewt"
		fi
		a1=$(kv "$o" advisory_first_rc) a2=$(kv "$o" advisory_rerun_rc) a3=$(kv "$o" advisory_after_bootstrap_rc) am=$(kv "$o" advisory_markers) ar=$(kv "$o" advisory_reported)
		if [ "$a1" = 2 ] && [ "$a2" = 0 ] && [ "${am:-0}" -ge 1 ] && [ "$ar" = yes ] && [ "$a3" = 2 ]; then al=WORKS; else al=BROKEN; fi
		record advisory-lifecycle C-shipped "$al" "first rc=${a1:-none}, markers=${am:-none}, rerun rc=${a2:-none}, reported=${ar:-none}, after session-start rc=${a3:-none}; expected 2, >=1, 0, yes, 2"
		record session-start C-shipped "rc=$(vk "$o" session_start_rc)" 'run inside the sandbox; see artifacts/contain-session-start.log'
	fi
elif [ "$STAGE" = all ]; then
	record contain C-shipped ERROR 'the tree could not be made'
fi

# --- stage 4: a network push to a real remote, positive control first --------------------
# Which permission mode the session runs in decides an unlisted host when no strict allowlist is
# set (the H4a companion, §5: allowed with no prompt under bypassPermissions, prompted in
# default, refused in dontAsk), so the shipped settings are pushed under all three, and the
# probe-only allowed-host variant under default. Every push gets its own branch, and whether it
# landed is read back from the remote by this script, not from the cell.
if [ "$STAGE" = all ] && [ "$NET" = true ]; then
	# A helper script, every value in it shell-quoted, so no input becomes code.
	HELPER=$PRIV/credential-helper.sh
	# shellcheck disable=SC2016 # $1 and $(cat ...) are the HELPER's code, expanded when git runs it
	{
		printf '#!/bin/sh\n'
		printf '[ "$1" = get ] || exit 0\n'
		# The token is read as the preflight read it, without CR or LF: a CRLF file would otherwise
		# send a CR in the password and fail every push, control included.
		printf 'printf %s %s "$(tr -d %s <%s)"\n' "'username=%s\\npassword=%s\\n'" \
			"$(printf %q "${AMH_PROBE_USERNAME:-x-access-token}")" "'\\r\\n'" "$(printf %q "$AMH_PROBE_TOKEN_FILE")"
	} >"$HELPER"
	chmod 700 "$HELPER"
	set_remote() { # set_remote <tree> : origin is the probe remote, the token via the helper
		git -C "$1" remote set-url origin "$AMH_PROBE_REMOTE" &&
			git -C "$1" config credential.helper '' &&
			git -C "$1" config --add credential.helper "!$(printf %q "$HELPER")"
	}
	# landed <tree> <branch> : yes, no, or unknown when the read-back itself failed
	landed() {
		git -C "$1" ls-remote --exit-code origin "refs/heads/$2" >/dev/null 2>>"$RAW/net-readback.err"
		case $? in 0) echo yes ;; 2) echo no ;; *) echo unknown ;; esac
	}
	export GIT_TERMINAL_PROMPT=0
	net_control=failed
	if t=$(make_tree net C-shipped) && set_remote "$t"; then
		control_branch="session/amh-probe-$TS-control"
		git -C "$t" branch -q "$control_branch"
		if git -C "$t" push -q origin "$control_branch" >"$RAW/net-control.err" 2>&1 &&
			[ "$(landed "$t" "$control_branch")" = yes ]; then
			record network-push control-outside-sandbox PUSHED "branch $control_branch, read back from the remote"
			net_control=ok
		else
			keep "$RAW/net-control.err" net-control.err
			record network-push control-outside-sandbox FAILED 'see artifacts/net-control.err; every sandboxed push below is INCONCLUSIVE'
		fi
	else
		record network-push control-outside-sandbox ERROR 'the tree or its remote could not be set up'
		t=''
	fi
	for run in C-shipped:bypass C-shipped:default C-shipped:dontAsk C-allow-host:default; do
		[ -n "$t" ] || break
		v=${run%%:*} mode=${run#*:}
		if [ "$v" = C-allow-host ]; then
			if ! { tree=$(make_tree net-allow C-allow-host) && set_remote "$tree"; }; then
				record network-push "$v $mode" ERROR 'the tree could not be made'
				continue
			fi
		else
			tree=$t
		fi
		branch="session/amh-probe-$TS-$v-$mode"
		git -C "$tree" branch -q "$branch"
		{
			cell_header
			cat <<SH
export GIT_TERMINAL_PROMPT=0
git -c credential.helper= ls-remote origin >/dev/null 2>.probe/ls-remote-noauth.err
say "ls_remote_noauth_rc=\$?"
git ls-remote origin >/dev/null 2>.probe/ls-remote.err
say "ls_remote_rc=\$?"
git push -q origin $branch 2>.probe/push.err
say "push_rc=\$?"
SH
		} >"$tree/.probe/net.sh"
		label=net-$v-$mode
		run_cell "$tree" "$label" net '' "$mode"
		[ -f "$tree/.probe/net.out" ] && mv "$tree/.probe/net.out" "$RAW/$label.out"
		o=$RAW/$label.out
		keep "$o" "$label.out"
		for f in ls-remote-noauth.err ls-remote.err push.err; do keep "$tree/.probe/$f" "$label-$f"; done
		why=$(gate "$label" net "$o")
		got=$(landed "$tree" "$branch")
		prc=$(kv "$o" push_rc)
		if [ "$net_control" != ok ]; then
			verdict=INCONCLUSIVE why='the control push failed'
		elif [ -n "$why" ]; then
			verdict=INCONCLUSIVE
		elif [ "$got" = yes ] && [ "$prc" = 0 ]; then
			verdict=REACHED
		elif [ "$got" = no ] && [ -n "$prc" ] && [ "$prc" != 0 ]; then
			verdict=REFUSED
		else
			verdict=INCONCLUSIVE why="push_rc=${prc:-none} and the remote read back $got"
		fi
		record network-push "$v $mode" "$verdict" "${why:+$why; }push_rc=${prc:-none} ls_remote_rc=$(kv "$o" ls_remote_rc) ls_remote_noauth_rc=$(kv "$o" ls_remote_noauth_rc); on the remote: $got"
	done
	keep "$RAW/net-readback.err" net-readback.err
	log "network-push: branches named session/amh-probe-$TS-* may now exist on the remote; this script deletes none of them"
fi

# --- stage 5: the old path-refs.sh, then the full ladder, inside the sandbox --------------
if [ "$STAGE" = all ]; then
	if t=$(make_tree old-path-refs O-as-checked-out "$OLD_REF"); then
		{
			cell_header
			cat <<'SH'
bash scripts/guards/path-refs.sh >.probe/old-path-refs.log 2>&1
say "old_path_refs_rc=$?"
bash -x scripts/guards/path-refs.sh >/dev/null 2>.probe/old-path-refs.trace
say "old_path_refs_traced_rc=$?"
say "loop_md=$(stat -c '%A %F %s' .claude/loop.md 2>&1)"
git status --porcelain --untracked-files=all >.probe/status.txt 2>&1
SH
		} >"$t/.probe/oldrefs.sh"
		run_cell "$t" old-path-refs oldrefs
		o=$t/.probe/oldrefs.out
		keep "$o" old-path-refs.out
		keep "$t/.probe/old-path-refs.log" old-path-refs.log
		keep "$t/.probe/status.txt" old-path-refs-status.txt
		tail -n 200 "$t/.probe/old-path-refs.trace" >"$RAW/old-path-refs.trace.tail" 2>/dev/null
		keep "$RAW/old-path-refs.trace.tail" old-path-refs.trace.tail
		why=$(gate old-path-refs oldrefs "$o")
		record old-path-refs "$OLD_REF" "${why:+INCONCLUSIVE }rc=$(kv "$o" old_path_refs_rc)" "${why:+$why; }.claude/loop.md inside: $(kv "$o" loop_md)"
	else
		record old-path-refs "$OLD_REF" ERROR 'the tree could not be made'
	fi

	# The control: the same ladder, run by this script outside any sandbox, in a tree of its own,
	# so a red inside reads as the sandbox's only where the control is green (DD-093).
	if [ "$CHECK" = true ]; then
		log 'CHECK: would run the full ladder outside the sandbox, as the control'
	elif tc=$(make_tree ladder-control C-shipped); then
		start=$(date +%s)
		(cd "$tc" && bash scripts/ladder.sh) >"$RAW/ladder-control.log" 2>&1
		rc=$?
		keep "$RAW/ladder-control.log" ladder-control.log
		if [ "$rc" = 0 ]; then verdict=GREEN; else verdict=RED; fi
		record full-ladder control-outside-sandbox "$verdict" "ladder_rc=$rc secs=$(($(date +%s) - start)); see artifacts/ladder-control.log"
	else
		record full-ladder control-outside-sandbox ERROR 'the tree could not be made'
	fi
	if t=$(make_tree ladder C-shipped); then
		{
			cell_header
			cat <<'SH'
bash scripts/guards/path-refs.sh >.probe/path-refs.log 2>&1
say "path_refs_rc=$?"
start=$(date +%s)
bash scripts/ladder.sh >.probe/ladder.log 2>&1
say "ladder_rc=$?"
say "ladder_secs=$(( $(date +%s) - start ))"
SH
		} >"$t/.probe/ladder.sh"
		run_cell "$t" ladder ladder
		o=$t/.probe/ladder.out
		keep "$o" ladder.out
		keep "$t/.probe/ladder.log" ladder.log
		keep "$t/.probe/path-refs.log" path-refs.log
		why=$(gate ladder ladder "$o")
		rc=$(kv "$o" ladder_rc)
		if [ -n "$why" ] || [ -z "$rc" ]; then
			verdict=INCONCLUSIVE
		elif [ "$rc" = 0 ]; then verdict=GREEN; else verdict=RED; fi
		record full-ladder C-shipped "$verdict" "${why:+$why; }ladder_rc=${rc:-none} secs=$(kv "$o" ladder_secs) path_refs_rc=$(kv "$o" path_refs_rc); see artifacts/ladder.log"
	else
		record full-ladder C-shipped ERROR 'the tree could not be made'
	fi
fi

# --- stage 6: startup without bwrap --------------------------------------------------------
nobwrap_cell() { # nobwrap_cell <label> [PATH override]
	local t o landed notice=no samples
	t=$(make_tree "$1" C-shipped) || {
		record "$1" C-shipped ERROR 'the tree could not be made'
		return
	}
	{
		cell_header
		printf 'if printf x >%s 2>/dev/null; then say out_tree_write=ok; else say out_tree_write=refused; fi\n' \
			"$(printf %q "$OUTSIDE/$1-write")"
	} >"$t/.probe/nobwrap.sh"
	run_cell "$t" "$1" nobwrap "${2:-}"
	o=$t/.probe/nobwrap.out
	keep "$o" "$1.out"
	samples=$(bw "$1" samples)
	if [ -e "$OUTSIDE/$1-write" ]; then landed=yes; else landed=no; fi
	grep -qi 'sandbox' "$RAW/$1.stderr" 2>/dev/null && notice=yes
	# The line DD-092 saw at 2.1.325, by itself: whether this version still says so.
	if grep -qi 'sandbox disabled' "$RAW/$1.stderr" 2>/dev/null; then notice="$notice (stderr: Sandbox disabled)"; else notice="$notice (stderr: no Sandbox disabled line)"; fi
	awk -F'\t' '$1 == "TOOL_RESULT" && tolower($0) ~ /sandbox/ { f = 1 } END { exit !f }' "$RAW/$1.summary" 2>/dev/null && notice=yes
	if ! provenance "$1" Bash "bash .probe/nobwrap.sh"; then
		record "$1" C-shipped INCONCLUSIVE 'the transcript does not show exactly one Bash call on the cell with its result'
	elif [ ! -s "$o" ]; then
		record "$1" C-shipped INCONCLUSIVE 'the cell wrote no output'
	elif [ "${samples:-0}" -gt 0 ] || [ "$(kv "$o" pidns)" != "$HOST_PIDNS" ]; then
		record "$1" C-shipped INCONCLUSIVE "a bwrap ran under the call (samples ${samples:-0}) or the cell had its own PID namespace: Claude Code found bwrap anyway"
	elif [ "$landed" = yes ]; then
		record "$1" C-shipped UNSANDBOXED "the out-of-tree write landed; the sandbox mentioned in stderr or a tool result: $notice"
	else
		record "$1" C-shipped OTHER "unsandboxed, yet the write did not land; mentioned: $notice"
	fi
}
if [ "$STAGE" = all ]; then
	# A PATH of links to every program on the current PATH except bwrap; absolute entries only,
	# each link to the program's resolved path.
	NB=$OUT/nobwrap-bin
	mkdir -p "$NB"
	IFS=: read -r -a dirs <<<"$PATH"
	for dir in "${dirs[@]}"; do
		case $dir in /*) ;; *) continue ;; esac
		[ -d "$dir" ] || continue
		for exe in "$dir"/*; do
			b=${exe##*/}
			[ "$b" = bwrap ] && continue
			[ -x "$exe" ] && [ ! -e "$NB/$b" ] && ln -s "$(readlink -f "$exe")" "$NB/$b"
		done
	done
	if PATH=$NB command -v bwrap >/dev/null 2>&1; then
		record no-bwrap-path C-shipped ERROR 'bwrap is still reachable on the reduced PATH'
	else
		nobwrap_cell no-bwrap-path "$NB"
	fi
	log 'no-bwrap-path: INCONCLUSIVE means Claude Code finds bwrap without PATH; then run --stage no-bwrap-root'
fi
if [ "$STAGE" = no-bwrap-root ]; then
	nobwrap_cell no-bwrap-root
fi

# --- package ------------------------------------------------------------------------------
if [ -s "$PRIV/token.pattern" ] && ! python3 -I "$TOOLS/fragscan.py" "$PRIV/token.pattern" "$SEND"; then
	log 'package: part of the token appears in the send-back folder — NOT packaged; do not send it'
	exit 1
fi
tar -C "$OUT" -czf "$OUT/send-$TS.tar.gz" send || exit 1
printf '\nSend back %s/send-%s.tar.gz (sha256 %s). The raw transcripts in %s were not packaged.\n' \
	"$OUT" "$TS" "$(sha256sum "$OUT/send-$TS.tar.gz" | cut -c1-16)" "$RAW"
