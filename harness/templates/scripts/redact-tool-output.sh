#!/usr/bin/env bash
# AMH — post-execution tool-output redaction (P17), for agents that can rewrite a tool
# result before the context window sees it.
#
# Reads one PostToolUse hook payload (JSON) on stdin. Walks the STRING leaves of the
# payload's `tool_response`, runs each through `redact.sh` beside this script, and — only
# if a leaf actually gained a `[REDACTED:` marker — prints a hook response that replaces
# the tool result the agent is about to read:
#
#   {"hookSpecificOutput":{"hookEventName":"PostToolUse","updatedToolOutput": <same shape>}}
#
# Usage:
#   redact-tool-output.sh              hook mode: payload on stdin, response on stdout
#   redact-tool-output.sh --self-test  fixture matrix (tokens generated at runtime)
#
# Shipped by the Agentic Maintenance Harness. Repo-agnostic: do not edit locally.
#
# --- WHAT THIS IS, AND WHAT IT IS NOT ---------------------------------------------------
#
# It narrows a window. It is not containment, and four bounds say why:
#
# 1. The value was already produced. The command ran, the file was read, and the bytes exist
#    in the tool's own execution, in the session transcript on disk, and in whatever
#    telemetry the host keeps. This layer changes what the MODEL reads, nothing else.
# 2. The host contract is fail-OPEN by design. A replacement that does not match the tool's
#    own response schema is a non-blocking error and the ORIGINAL output is used. So is a
#    non-zero exit here. Every uncertain path in this script therefore prints nothing and
#    exits 0, which lands in exactly the same place: the unmodified result.
# 3. It sees successful tool calls only, per the host's PostToolUse contract. The
#    credential printed by a command that FAILED is the common leak and may never reach
#    this script at all. Prevention stays with the pre-execution command guard.
# 4. It catches the shapes `redact.sh` enumerates and no more. A private token with no
#    recognisable prefix, a random password, a database credential: this sees none of them.
#    Deliberately NOT a second vocabulary — one filter, one class list, one place to fix.
#
# The rule ("never print a credential's value, prefix, suffix, length or hash") and the
# permission deny rails are the other two layers, and they are the ones that hold.
#
# --- WHY THE LEAVES, AND NOT THE SERIALISED JSON ----------------------------------------
#
# Filtering the serialised `tool_response` text would be one line and would be WRONG, in a
# way that reads as handled:
#
#   `redact.sh` redacts a private key in two stages. A line-range stage replaces the
#   base64 BODY between the BEGIN and END markers; a per-line stage then replaces the
#   BEGIN marker itself. In serialised JSON the whole key sits inside one string literal
#   with its newlines written as two-character `\n` escapes, so there are no lines for the
#   range stage to open on — and the marker stage still fires. The result is
#   `[REDACTED:private_key_block]` printed directly above the key, in the clear.
#
# A marker over a live value is worse than no class at all, because it reads as handled
# (P17 says this about the same filter). So the leaf is DECODED to real text first, which
# is what `redact.sh` was written against, and re-encoded afterwards by the JSON writer.
#
# Structure is preserved by construction rather than by hope: the parsed object is rebuilt
# with string leaves replaced in place. Numbers stay numbers, booleans stay booleans, null
# stays null, array lengths and object keys are untouched. Nothing here reconstructs what a
# tool's response "should" look like — this script does not know, and a guess that misses
# the schema is silently discarded by the host (bound 2 above).
#
# OBJECT KEYS ARE NOT FILTERED. A key is a field name in the tool's schema; rewriting one
# renames a field, which is a different result rather than a redacted one. A credential
# used as a key survives this layer, and the rule is what covers it.
#
# --- INTERPRETER ------------------------------------------------------------------------
#
# `python3` when present, and NOTHING when it is absent — the same optional-tool handling
# `command-guard.sh` already uses to read a hook payload, for the same reason: the harness
# targets bash, git and coreutils, and a JSON reader is not in that floor. Absent python3,
# this prints nothing and the agent sees the unmodified output, which is precisely the
# state every adapter was in before this script existed. It is not a regression and it is
# not announced by this script either: a hook's stderr on a zero exit goes to the host's debug
# log and nowhere a reader looks. What reports it is the session banner's tool line, and only
# where `REQUIRED_TOOLS` in `amh.conf` names `python3` — the shipped example ships that key
# EMPTY, so an adopter who wants the report adds the name. Saying "the banner reports it"
# without that clause was false in this repository until the name was added, which is the
# enforcement-asymmetry class: prose implying a report nothing produces.
#
# A bash fallback was considered and refused. `command-guard.sh` can afford one because it
# extracts a single documented string from a flat object and fails open on anything else.
# Here the input is an ARBITRARY nested response from an arbitrary tool, including tools
# this harness has never heard of, and a half-parser over that does not fail open — it
# emits a document that parses and says something else.

set -uo pipefail

HERE=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd) || exit 0
REDACT="$HERE/redact.sh"

# Bytes we are willing to hold and filter in one call. Past this the script stands down
# rather than growing unbounded work inside a hook the user is waiting on. The stand-down
# direction is the host's own (bound 2): unmodified output.
MAX_BYTES=$((8 * 1024 * 1024))
# String leaves we are willing to filter, one subprocess each. Past this the script stands
# down for the same reason as the byte ceiling: bounded work inside a hook, and the
# stand-down direction is the host's own — unmodified output.
MAX_LEAVES=512

# The whole program, as one heredoc, so the quoting story is "bash never interpolates into
# this" rather than a per-line judgement call. Everything it needs arrives in argv.
read -r -d '' WALKER <<'PY' || true
import json, os, subprocess, sys, time

redact = sys.argv[1]
max_bytes, max_leaves = int(sys.argv[2]), int(sys.argv[3])

def stand_down(why=""):
    # Print NOTHING. The host then uses the original tool output, which is the safe
    # direction for every case that reaches here: we did not manage to look.
    if why:
        sys.stderr.write("redact-tool-output: %s\n" % why)
    sys.exit(0)

try:
    payload = json.load(sys.stdin)
except Exception:
    stand_down()
if not isinstance(payload, dict):
    stand_down()
if payload.get("hook_event_name") != "PostToolUse":
    stand_down()
if "tool_response" not in payload:
    stand_down()

response = payload["tool_response"]

# Collect every string leaf in document order. Depth is capped because a pathological
# document should stand down, not raise. Nothing is rebuilt yet: the rebuild below walks
# the ORIGINAL again in the same order, so the two traversals agree by construction rather
# than by a placeholder that a real JSON null could be mistaken for.
leaves = []
def collect(node, depth=0):
    if depth > 64:
        raise ValueError("nesting too deep")
    if isinstance(node, str):
        leaves.append(node)
    elif isinstance(node, list):
        for v in node:
            collect(v, depth + 1)
    elif isinstance(node, dict):
        for v in node.values():
            collect(v, depth + 1)

try:
    collect(response)
except Exception:
    stand_down()

if not leaves:
    stand_down()
if sum(len(s.encode("utf-8", "surrogatepass")) for s in leaves) > max_bytes:
    stand_down("tool_response is larger than this hook will filter; output left unmodified")
if any("\0" in s for s in leaves):
    # `sed` and NUL bytes do not have one portable story. Do not find out inside a rail.
    stand_down("tool_response contains a NUL byte; output left unmodified")

# ONE `redact.sh` invocation PER LEAF, and the reason is not tidiness.
#
# `redact.sh`'s private-key stage is a sed line RANGE: it opens on a line matching the BEGIN
# marker and closes on one matching END. Batching the leaves into a single stream — the first
# shape this script had — let an unterminated BEGIN in one leaf hold that range open across
# every LATER leaf, where `KEY_BLOCK_BODY` matches any all-base64 line: ordinary single words
# and most slash-only paths. A review measured it: a Read response came back with `filePath`
# replaced by `[REDACTED:private_key_body]`, and the marker rule below did NOT catch it,
# because the corrupting change genuinely adds a marker. Per-leaf is what makes each leaf's
# range state its own, and a filter with ANY cross-line state makes batching wrong by
# construction rather than by accident.
#
# Bounded because per-leaf means one subprocess per leaf: a leaf ceiling and a wall-clock
# deadline, both standing down rather than growing unbounded work inside a hook a user is
# waiting on.
if len(leaves) > max_leaves:
    stand_down("tool_response has more string leaves than this hook will filter; output left unmodified")

def filter_leaf(leaf):
    # A trailing marker line of our own, so the exact bytes come back. Every record ends in a
    # newline before the marker, which is what makes `sed` appending a final newline to a
    # stream that lacked one — which it does — invisible here. The marker is generated per
    # call: a stored one would be a constant an input could carry, and 128 random bits cannot
    # be guessed by output produced before this process started.
    mark = "AMH-REDACT-" + os.urandom(16).hex()
    sep = "\n" + mark + "\n"
    try:
        done = subprocess.run(
            ["bash", redact],
            input=(leaf + sep).encode("utf-8", "surrogatepass"),
            stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, timeout=30,
        )
    except Exception:
        return None
    if done.returncode != 0:
        return None
    try:
        text = done.stdout.decode("utf-8", "surrogatepass")
    except Exception:
        # Not valid UTF-8 coming back is "I did not manage to look", not "nothing to redact".
        return None
    parts = text.split(sep)
    # One record, one separator, and an empty tail after it. Anything else means the filter
    # moved bytes we cannot account for, and an unaccountable rewrite of a tool result is not
    # something to publish.
    if len(parts) != 2 or parts[1] != "":
        return None
    return parts[0]

# The rule that decides whether a changed leaf is accepted: it must have gained a redaction
# marker, counted rather than merely present. `redact.sh` documents that its own stages are
# not byte-transparent on every platform — the GNU sed shipped with Git for Windows rewrites
# CRLF to LF for a script that matches nothing — so "the bytes differ" is NOT evidence of
# redaction, and taking a differing-but-unmarked leaf would let this hook quietly rewrite line
# endings inside a tool result. A CONTAINS test was the first shape and had a hole a review
# measured: a leaf that already carried the literal `[REDACTED:` — common in real output here,
# since this filter's own results and this repository's prose both contain it — was accepted on
# any byte change at all. Counting closes that: strictly more markers than before, or no deal.
MARKER = "[REDACTED:"
deadline = time.monotonic() + 30.0
out, changed = [], False
for original in leaves:
    if time.monotonic() > deadline:
        stand_down("filtering ran past this hook's deadline; output left unmodified")
    new = filter_leaf(original)
    if new is not None and new != original and new.count(MARKER) > original.count(MARKER):
        out.append(new)
        changed = True
    else:
        out.append(original)

if not changed:
    stand_down()

# Driven by the ORIGINAL node's type, never by a placeholder written into the string
# slots: a placeholder of None is indistinguishable from a JSON null already in the
# response, so a document carrying one would consume a filtered leaf and shift every
# later one — the model then reads one field's text under another field's name.
it = iter(out)
def merge(original, depth=0):
    if depth > 64:
        raise ValueError("nesting too deep")
    if isinstance(original, str):
        return next(it)
    if isinstance(original, list):
        return [merge(v, depth + 1) for v in original]
    if isinstance(original, dict):
        return dict((k, merge(v, depth + 1)) for k, v in original.items())
    return original

try:
    updated = merge(response)
    leftover = next(it, "!")
except Exception:
    stand_down()
if leftover != "!":
    stand_down("leaf accounting disagreed with the response shape")

body = {
    "hookSpecificOutput": {
        "hookEventName": "PostToolUse",
        "updatedToolOutput": updated,
        "systemMessage": "AMH redacted one or more known credential shapes from this tool result before it reached the context. The unredacted value still exists where the tool produced it.",
    }
}
# Serialised FIRST, then written once. Encoding inside the write would let a failure land
# after a partial document is already on stdout, which contradicts this script's own promise
# that an uncertain path prints nothing.
try:
    rendered = json.dumps(body)
except Exception:
    stand_down()
sys.stdout.write(rendered)
PY

run_hook() {
	command -v python3 >/dev/null 2>&1 || exit 0
	[ -f "$REDACT" ] || exit 0
	# stderr is NOT discarded. The host ignores a zero-exit hook's stderr except in its debug
	# log, and that log is the only place a stand-down reason can be read at all — swallowing
	# it made "I did not manage to look" and "nothing to redact" the same observation.
	python3 -c "$WALKER" "$REDACT" "$MAX_BYTES" "$MAX_LEAVES" || exit 0
	exit 0
}

# --- self-test --------------------------------------------------------------------------
#
# Every secret-shaped fixture is GENERATED here and never stored: a literal in this file
# would make the file fail the repository's own secret scan, and the scan would be right
# (AMH ledger row D004).

st_fails=0
st_pass() { printf '  ok   %s\n' "$1"; }
st_fail() {
	printf '  FAIL %s\n' "$1"
	printf '       %s\n' "$2"
	st_fails=$((st_fails + 1))
}

rand_upper() { # <length>
	local n=$1 pool=''
	while [ "${#pool}" -lt "$n" ]; do
		pool=$pool$(head -c 512 /dev/urandom | LC_ALL=C tr -dc 'A-Z0-9')
	done
	printf '%s' "${pool:0:n}"
}
rand_b64() { # <length>
	local n=$1 pool=''
	while [ "${#pool}" -lt "$n" ]; do
		pool=$pool$(head -c 512 /dev/urandom | LC_ALL=C tr -dc 'A-Za-z0-9')
	done
	printf '%s' "${pool:0:n}"
}

# Build a payload from a JSON tool_response literal handed in on argv, so the test says
# what shape it is testing rather than hiding it behind a builder.
st_payload() { # <tool_response JSON>
	printf '{"hook_event_name":"PostToolUse","tool_name":"Bash","tool_input":{},"tool_response":%s}' "$1"
}

st_run() { # <payload> -> stdout of the hook
	printf '%s' "$1" | python3 -c "$WALKER" "$REDACT" "$MAX_BYTES" "$MAX_LEAVES" 2>/dev/null
}

# Extract a field with python3 rather than grep: this suite is about JSON shape, and a
# grep over a JSON document cannot tell a value from a key that happens to spell it.
st_jq() { # <json> <python expression over `d`>
	printf '%s' "$1" | python3 -c 'import json,sys
d = json.load(sys.stdin)
sys.stdout.write(str(eval(sys.argv[1])))' "$2" 2>/dev/null
}

st_silent() { # <label> <payload> — a payload this hook must not answer
	local out
	out=$(st_run "$2")
	if [ -z "$out" ]; then st_pass "$1"; else st_fail "$1" "expected no output, got: ${out:0:160}"; fi
}

self_test() {
	printf 'redact-tool-output.sh self-test\n'
	if ! command -v python3 >/dev/null 2>&1; then
		printf '  SKIP no python3 on PATH — this hook stands down entirely on this host,\n'
		printf '       which is the documented absent-interpreter state, not a pass.\n'
		return 0
	fi
	if [ ! -f "$REDACT" ]; then
		printf '  FAIL redact.sh is not beside this script (%s) — nothing to filter with\n' "$REDACT"
		return 1
	fi

	local tok out shape body priv dash

	# 1. A known shape inside a nested response is redacted, and the response SHAPE is
	#    unchanged — the criterion that actually matters, because a replacement that does
	#    not match the tool's schema is discarded by the host and this rail becomes a
	#    no-op that reads as wired.
	tok="AKIA$(rand_upper 16)"
	out=$(st_run "$(st_payload "$(printf '{"stdout":"downloading as %s\\n","stderr":"","interrupted":false,"exitCode":0,"tags":["a","b"]}' "$tok")")")
	if [ -z "$out" ]; then
		st_fail 'redacts a known shape' 'the hook produced no output at all'
	elif printf '%s' "$out" | grep -qF "$tok"; then
		st_fail 'redacts a known shape' 'the generated token survived into the hook response'
	elif ! printf '%s' "$out" | grep -qF '[REDACTED:aws_access_key_id]'; then
		st_fail 'redacts a known shape' 'no redaction marker in the hook response'
	else
		st_pass 'redacts a known shape'
	fi

	if [ -n "$out" ]; then
		shape=$(st_jq "$out" 'd["hookSpecificOutput"]["hookEventName"]')
		if [ "$shape" = PostToolUse ]; then
			st_pass 'declares hookEventName PostToolUse'
		else
			st_fail 'declares hookEventName PostToolUse' "got: $shape"
		fi

		# Scalar types survive. A hook that stringified `false` or `0` would still look
		# redacted and would hand the model a different result.
		shape=$(st_jq "$out" '[type(d["hookSpecificOutput"]["updatedToolOutput"]["interrupted"]).__name__, type(d["hookSpecificOutput"]["updatedToolOutput"]["exitCode"]).__name__, len(d["hookSpecificOutput"]["updatedToolOutput"]["tags"]), sorted(d["hookSpecificOutput"]["updatedToolOutput"].keys())]')
		if [ "$shape" = "['bool', 'int', 2, ['exitCode', 'interrupted', 'stderr', 'stdout', 'tags']]" ]; then
			st_pass 'preserves the native result shape (types, keys, array length)'
		else
			st_fail 'preserves the native result shape (types, keys, array length)' "got: $shape"
		fi
	fi

	# 2. The defect this script exists to avoid. A private key inside ONE JSON string is
	#    the shape that a filter run over the SERIALISED response marks and leaves in the
	#    clear. Assert the BODY is gone, not merely that a marker appeared.
	body=$(rand_b64 64)
	# The markers are ASSEMBLED, never written out. A literal one in this file would be
	# rewritten by the repository's own secret scan — which runs `redact.sh` over every
	# tracked file and calls any changed byte a credential — and the scan would be right to.
	dash=$(printf '%s' '-----')
	priv=$(printf -- '%sBEGIN RSA PRIVATE KEY%s\\n%s\\n%sEND RSA PRIVATE KEY%s' "$dash" "$dash" "$body" "$dash" "$dash")
	out=$(st_run "$(st_payload "$(printf '{"stdout":"%s\\n","stderr":""}' "$priv")")")
	if [ -z "$out" ]; then
		st_fail 'redacts a private key body carried in one JSON string' 'the hook produced no output at all'
	elif printf '%s' "$out" | grep -qF "$body"; then
		st_fail 'redacts a private key body carried in one JSON string' \
			'the base64 body survived — the marker was replaced over a live value'
	elif ! printf '%s' "$out" | grep -qF '[REDACTED:private_key_body]'; then
		st_fail 'redacts a private key body carried in one JSON string' 'no body marker in the response'
	else
		st_pass 'redacts a private key body carried in one JSON string'
	fi

	# 3. A bare-string tool_response is a shape too, and it must stay a string.
	tok="AKIA$(rand_upper 16)"
	out=$(st_run "$(st_payload "$(printf '"token %s here"' "$tok")")")
	shape=$(st_jq "$out" 'type(d["hookSpecificOutput"]["updatedToolOutput"]).__name__')
	if [ "$shape" = str ] && ! printf '%s' "$out" | grep -qF "$tok"; then
		st_pass 'a string tool_response stays a string'
	else
		st_fail 'a string tool_response stays a string' "type: $shape"
	fi

	# 4. A real JSON null must not consume a filtered leaf. This is the placeholder
	#    collision the rebuild walks the ORIGINAL to avoid; without that, every leaf after
	#    the null shifts by one and the model reads one field's text under another's name.
	tok="AKIA$(rand_upper 16)"
	out=$(st_run "$(st_payload "$(printf '{"a":null,"b":"%s","c":"tail"}' "$tok")")")
	shape=$(st_jq "$out" '[d["hookSpecificOutput"]["updatedToolOutput"]["a"], d["hookSpecificOutput"]["updatedToolOutput"]["c"]]')
	if [ "$shape" = "[None, 'tail']" ]; then
		st_pass 'a JSON null does not shift the leaf accounting'
	else
		st_fail 'a JSON null does not shift the leaf accounting' "got: $shape"
	fi

	# 5–8. Every stand-down path answers with nothing, which is what leaves the original
	#      tool output in place. A hook that answered here would be rewriting a result on
	#      the strength of a payload it did not understand.
	st_silent 'says nothing about output with no known shape in it' \
		"$(st_payload '{"stdout":"all tests passed\n","stderr":""}')"
	st_silent 'says nothing about a non-PostToolUse payload' \
		'{"hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"ls"}}'
	st_silent 'says nothing about a payload with no tool_response' \
		'{"hook_event_name":"PostToolUse","tool_name":"Bash","tool_input":{}}'
	st_silent 'says nothing about malformed JSON' '{"hook_event_name":'
	st_silent 'says nothing about an empty payload' ''

	# 9. Cross-leaf contamination. `redact.sh`'s key stage is a sed line RANGE, so an
	#    unterminated BEGIN marker in one leaf held it open across every later leaf when the
	#    leaves went through as one stream — and `KEY_BLOCK_BODY` matches any all-base64 line,
	#    which ordinary words and slash-only paths are. The marker rule cannot catch it: the
	#    corrupting change genuinely adds a marker. This fixture fails against any batched
	#    implementation and is the reason filtering is per leaf.
	body=$(rand_b64 48)
	out=$(st_run "$(st_payload "$(printf '{"stdout":"%sBEGIN RSA PRIVATE KEY%s","stderr":"hello\\nworld\\n","path":"/home/user/scratch","token":"%s"}' "$dash" "$dash" "$body")")")
	if [ -z "$out" ]; then
		st_fail 'one leaf cannot redact another leaf' 'the hook produced no output at all'
	elif ! printf '%s' "$out" | grep -qF 'hello' ||
		! printf '%s' "$out" | grep -qF '/home/user/scratch' ||
		! printf '%s' "$out" | grep -qF "$body"; then
		st_fail 'one leaf cannot redact another leaf' \
			"a later leaf was rewritten by an earlier leaf's open range: ${out:0:200}"
	else
		st_pass 'one leaf cannot redact another leaf'
	fi

	# 10. The marker rule COUNTS markers rather than testing for one. A leaf that already
	#     carries the literal text — common here, since this filter's own output and this
	#     repository's prose both contain it — must not be accepted on a byte change that
	#     redacted nothing. Exercised against a stub filter that only strips CR, which is
	#     exactly what `redact.sh` documents its sed doing on a Windows checkout, so this
	#     fixture fails on a platform-independent substitute for a platform-specific defect.
	st_stub_case() { # <label> <leaf JSON string literal> — expects silence
		local label=$1 leaf=$2 tmp stub_out
		tmp=$(mktemp -d) || return 1
		cp -- "$0" "$tmp/hook.sh" || { rm -rf -- "$tmp"; return 1; }
		# A filter that substitutes NOTHING and only removes CR. Any acceptance here is the
		# hook publishing a line-ending rewrite as a redaction.
		printf '#!/usr/bin/env bash\nexec tr -d "\\r"\n' >"$tmp/redact.sh"
		chmod 755 "$tmp/hook.sh" "$tmp/redact.sh"
		stub_out=$(printf '%s' "$(st_payload "{\"stdout\":$leaf}")" | bash "$tmp/hook.sh" 2>/dev/null)
		rm -rf -- "$tmp"
		if [ -z "$stub_out" ]; then
			st_pass "$label"
		else
			st_fail "$label" "a filter that redacted nothing was published as a redaction: ${stub_out:0:200}"
		fi
	}
	st_stub_case 'a substitution-free filter is never published as a redaction' '"first\r\nsecond\r\n"'
	st_stub_case 'a leaf that ALREADY carries the marker text is counted, not merely matched' \
		'"[REDACTED:aws_access_key_id]\r\nsecond\r\n"'

	# 11. Both ceilings stand down rather than growing unbounded work, and nesting past the
	#     depth cap stands down rather than raising. Each is a path the matrix would otherwise
	#     never enter, so a regression in any of them would be invisible.
	st_silent 'stands down past the leaf ceiling' \
		"$(st_payload "$(python3 -c 'import json;print(json.dumps(["x"] * 600))')")"
	st_silent 'stands down past the depth cap' \
		"$(st_payload "$(python3 -c 'import json
d = "leaf"
for _ in range(80):
    d = [d]
print(json.dumps(d))')")"

	# 12. Line endings alone are not a redaction on THIS platform either — a weaker check than
	#     case 10, kept because it runs against the real `redact.sh` rather than a stub.
	out=$(st_run "$(st_payload "$(printf '{"stdout":"first\\r\\nsecond\\r\\n"}')")")
	if [ -z "$out" ]; then
		st_pass 'a CRLF-only difference is not accepted as a redaction'
	else
		st_fail 'a CRLF-only difference is not accepted as a redaction' "the hook rewrote a leaf with no marker: ${out:0:160}"
	fi

	if [ "$st_fails" -eq 0 ]; then
		printf 'redact-tool-output.sh self-test: all checks passed\n'
		return 0
	fi
	printf 'redact-tool-output.sh self-test: %s check(s) failed\n' "$st_fails"
	return 1
}

case ${1-} in
--self-test) self_test ;;
'') run_hook ;;
*)
	printf 'usage: %s [--self-test]\n' "$0" >&2
	exit 2
	;;
esac
