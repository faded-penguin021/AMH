#!/usr/bin/env bash
# Repo-local guard: the first-class agent adapters stay complete across their
# source templates, reference-instance copies, installer actions and legislation.

set -uo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." || exit 1

fails=0
note() {
	printf '%s\n' "$1"
	fails=$((fails + 1))
}

# source template | installed/reference path. All adapter wiring is legislation, so
# each installed path must be explicit in both RULE_FILES values; the Codex rules file
# and Claude settings additionally carry the permission rails themselves.
ADAPTERS=(
	'harness/templates/configs/claude-settings.json|.claude/settings.json'
	'harness/templates/configs/codex-config.toml|.codex/config.toml'
	'harness/templates/configs/codex-amh.rules|.codex/rules/amh.rules'
	'harness/templates/configs/codex-agents/amh-rule-reviewer.toml|.codex/agents/amh-rule-reviewer.toml'
)

conf_value() { # conf_value <key> <config>
	sed -n "s/^$1='\([^']*\)'/\1/p" "$2" | head -1
}

reference_rules=$(conf_value RULE_FILES amh.conf)
adopter_rules=$(conf_value RULE_FILES harness/templates/amh.conf.example)

# The session banner reports adapter presence from this list, which makes it a SIXTH place
# the set is written down and therefore a sixth place it can drift. It is checked in both
# directions: a missing entry silently stops reporting an adapter, and a stale entry reports
# `unknown` forever for a file nobody ships any more — and `unknown` is the honest word for
# "this repo declares none", so the wrong one here reads as a fact rather than a typo.
#
# Checked ONLY in the reference instance. The shipped example ships this key empty on
# purpose (an adopter declares their own adapters, and most have none on day one), so
# requiring the set there would fail every correct adopter config.
banner_adapters=$(conf_value ADAPTER_FILES amh.conf)

# The installer's action for each adapter is its entry in amh-init.sh's KEEP_CONFIGS — the ONE
# list both its install loop and its scan of what a run will write read, so an adapter missing
# there is neither installed nor rendered. An unparseable list is said out loud: every entry
# below would then read as missing, which is true, but not why.
keep_configs=$(sed -n "s/^KEEP_CONFIGS='\([^']*\)'$/\1/p" scripts/amh-init.sh)
[ -n "$keep_configs" ] ||
	note "scripts/amh-init.sh carries no KEEP_CONFIGS list this guard can read — no adapter install action was checked"
if [ -z "$banner_adapters" ]; then
	note "amh.conf ADAPTER_FILES is empty or unset — the banner reports no adapter at all, which is indistinguishable from a repo that ships none"
fi

for declaration in "${ADAPTERS[@]}"; do
	IFS='|' read -r source destination <<<"$declaration"
	[ -f "$source" ] || note "adapter source missing: $source"
	[ -f "$destination" ] || note "adapter reference-instance path missing: $destination"

	case " $keep_configs " in
	*" ${source#harness/templates/}:$destination "*) ;;
	*) note "adapter install action missing: $source -> $destination" ;;
	esac

	case " $reference_rules " in
	*" $destination "*) ;;
	*) note "reference RULE_FILES does not cover adapter path: $destination" ;;
	esac
	case " $adopter_rules " in
	*" $destination "*) ;;
	*) note "adopter RULE_FILES does not cover adapter path: $destination" ;;
	esac
	case " $banner_adapters " in
	*" $destination "*) ;;
	*) note "amh.conf ADAPTER_FILES does not list adapter path: $destination — the session banner will not report it" ;;
	esac
done

# The other direction: an entry naming a file this repo does not ship. The banner would call
# it `unknown`, which reads as "this repo declares no adapter" rather than "this list is stale".
#
# The allowed set is DERIVED from ADAPTERS above, never written out again here. A literal list
# at this point would be a seventh copy of the set inside the guard whose whole job is stopping
# the set from being copied — and the two loops would then disagree by construction: adding a
# fourth adapter correctly everywhere would make the forward loop REQUIRE the path and this loop
# reject it, in the same run.
known=''
for declaration in "${ADAPTERS[@]}"; do
	known="$known ${declaration#*|} "
done
set -f
for listed in $banner_adapters; do
	case " $known " in
	*" $listed "*) ;;
	*) note "amh.conf ADAPTER_FILES names '$listed', which is not in the first-class adapter set" ;;
	esac
done
set +f

# Inline Codex hooks deliberately add no adapter path, but their two delivery points can
# still drift together into a config that exists and does nothing. Pin one hook per event,
# the exact shell matcher, and the agent-neutral shipped script each hook invokes.
codex_config=harness/templates/configs/codex-config.toml
[ "$(grep -cFx '[[hooks.SessionStart]]' "$codex_config")" -eq 1 ] ||
	note "Codex adapter must contain exactly one SessionStart hook"
[ "$(grep -cFx '[[hooks.PreToolUse]]' "$codex_config")" -eq 1 ] ||
	note "Codex adapter must contain exactly one PreToolUse hook"
[ "$(grep -cF 'matcher = "startup|resume|clear|compact"' "$codex_config")" -eq 1 ] ||
	note "Codex SessionStart hook matcher is missing or duplicated"
[ "$(grep -cF 'matcher = "^Bash$"' "$codex_config")" -eq 1 ] ||
	note "Codex Bash PreToolUse matcher is missing or duplicated"
session_hook=$(sed -n '/^\[\[hooks.SessionStart\]\]$/,/^$/p' "$codex_config")
pretool_hook=$(sed -n '/^\[\[hooks.PreToolUse\]\]$/,/^$/p' "$codex_config")
if [ "$(printf '%s\n' "$session_hook" | grep -cF 'scripts/session-start.sh')" -ne 1 ] ||
	printf '%s\n' "$session_hook" | grep -qF 'scripts/command-guard.sh'; then
	note "Codex SessionStart hook must invoke only the shipped agent-neutral session-start.sh"
fi
if [ "$(printf '%s\n' "$pretool_hook" | grep -cF 'scripts/command-guard.sh')" -ne 1 ] ||
	printf '%s\n' "$pretool_hook" | grep -qF 'scripts/session-start.sh'; then
	note "Codex PreToolUse hook must invoke only the shipped agent-neutral command-guard.sh"
fi

# The Claude adapter pins the interpreter each hook runs under. That pin is a HAND step for
# adopters, and until this check nothing anywhere reported its absence: an unpinned hook still
# exists and still matches, and where the agent's Git-bash discovery fails it hands a bare `.sh`
# to the Windows file association, which runs it DETACHED under a windowed launcher and reports
# rc=0 with zero bytes. The work lands where nobody is listening while the caller reads a verdict
# it never got — so for a guard hook that denies with a non-zero exit, a block silently becomes
# an allow (DD-008, DD-013).
#
# Both ways of getting the pin wrong are equally quiet, which is why this insists on the exact
# literal rather than on the key alone: a misspelled KEY is stripped and the entry survives
# UNPINNED, while a recognised key with an invalid VALUE fails the schema's enum and drops the
# whole hook entry, so a typo here removes a rail outright (DD-011).
#
# Structural by necessity — no JSON parser is in the dependency floor — so the pin test reads
# lines and can only speak for entries written in the shipped one-key-per-line layout. That makes
# the POPULATION count the load-bearing half: it is taken layout-independently and reconciled
# against what the line matcher actually consumed, because the dangerous shape is not a file this
# guard cannot read at all (loud) but one it can read PARTLY — three tidy entries and a fourth,
# hand-written or reformatted by the adopter applying this very step, that the matcher never sees
# and therefore never reports. An entry it cannot read is UNVERIFIED, never passed.
claude_files=0
claude_hooks=0
for declaration in "${ADAPTERS[@]}"; do
	case $declaration in
	*claude-settings.json*) ;;
	*) continue ;;
	esac
	for settings in "${declaration%|*}" "${declaration#*|}"; do
		# Its absence is already reported by the loop above; do not say it twice.
		[ -f "$settings" ] || continue
		claude_files=$((claude_files + 1))
		# Occurrences, not matching lines: a minified entry can carry several on one line, and
		# counting lines there would undercount the population and hide the difference below.
		# A `grep` that dies yields 0 and lands in the checked-NOTHING branch, never in a pass.
		total=$(grep -o '"type"[[:space:]]*:[[:space:]]*"command"' "$settings" | wc -l | tr -d ' ')
		shaped=$(grep -c '^[[:space:]]*"type": "command",$' "$settings")
		# `pending` still set at EOF is an entry that opened and never got its next line — a
		# truncated file. Counted as unpinned rather than silently dropped.
		unpinned=$(awk '
			/^[[:space:]]*"type": "command",$/ { pending = 1; next }
			pending { if ($0 !~ /^[[:space:]]*"shell": "bash",$/) bad++; pending = 0 }
			END { if (pending) bad++; print bad + 0 }
		' "$settings")
		if [ "$total" -eq 0 ]; then
			note "$settings: checked NOTHING — not one \"type\": \"command\" entry found at any layout. Either this adapter declares no hooks at all or this guard has stopped reading the file it checks, and from a green run those look identical"
		elif [ "$shaped" -ne "$total" ]; then
			note "$settings: checked NOTHING for $((total - shaped)) of $total command hook entry(ies) — they are not in the one-key-per-line layout this guard can read, so their pin is UNVERIFIED, not present. Re-indent them to one key per line, or teach this guard the new layout; never assume the unread ones are fine"
		elif [ "$unpinned" -ne 0 ]; then
			note "$settings: $unpinned of $total command hook(s) are not followed by the exact line \"shell\": \"bash\" — an unpinned hook can be handed to the Windows file association, which runs it detached and reports rc=0, turning a guard's deny into an allow (DD-008); a misspelled key leaves the entry unpinned, an invalid value drops the entry outright (DD-011)"
		else
			claude_hooks=$((claude_hooks + total))
		fi
	done
done
if [ "$claude_files" -eq 0 ]; then
	note "checked NOTHING for the Claude shell pin — no Claude adapter file was reached at all. The set above no longer names one, so this check iterated zero times while reporting nothing"
fi

# The PostToolUse output-redaction hook is the SECOND hand-applied Claude step, and DD-013's
# durable half applies to it verbatim: a rail whose installation is manual needs a check for its
# ABSENCE. Nothing else reports this one. The hook is fail-open at the host by design — a
# replacement that misses the tool's schema, and a host with no python3, both leave the original
# output standing — so a tree with the wiring deleted behaves identically to a tree with no
# credential in its output, and no run of the ladder or of the hook's own self-test can tell them
# apart. That is the same invisibility the shell pin had.
#
# Structural, like the pin test above and for the same reason: no JSON parser is in the
# dependency floor. It reads the PostToolUse group as a line range and looks for the shipped
# script and its all-tools matcher inside it, so a command placed under some OTHER event does not
# satisfy this — and a file whose layout the range cannot find is reported as unread rather than
# passed.
POST_HOOK_SCRIPT=scripts/redact-tool-output.sh
# The literal every Claude hook command opens with — `bash` and the quoted project root — as written
# in the JSON file. See the anchoring check below for why nothing else is accepted.
# shellcheck disable=SC2016 # the placeholder is a literal in the file; Claude Code expands it
CLAUDE_ROOT='"bash \"${CLAUDE_PROJECT_DIR}\"/'
claude_post=0
for declaration in "${ADAPTERS[@]}"; do
	case $declaration in
	*claude-settings.json*) ;;
	*) continue ;;
	esac
	for settings in "${declaration%|*}" "${declaration#*|}"; do
		[ -f "$settings" ] || continue
		group=$(sed -n '/^[[:space:]]*"PostToolUse": \[$/,/^[[:space:]]*\],$/p' "$settings")
		if [ -z "$group" ]; then
			note "$settings: no \"PostToolUse\" group found at the layout this guard reads, so post-execution output redaction is either absent or written in a shape nothing here checked. Either way it is UNVERIFIED, not present — and a deleted redaction hook looks exactly like output with no credential in it (DD-013's lesson, DD-016 for this rail)"
			continue
		fi
		# Every matcher KEY at any layout, and the ones at the one-key-per-line layout this guard
		# reads, the same total-versus-shaped pair the pin check uses: a `"matcher" : "Write"` or
		# a minified group would otherwise go uncounted while a canonical "*" elsewhere vouched.
		matchers=$(printf '%s\n' "$group" | grep -c '^[[:space:]]*"matcher":')
		matcher_keys=$(printf '%s\n' "$group" | grep -o '"matcher"[[:space:]]*:' | wc -l | tr -d ' ')
		if [ "$(printf '%s\n' "$group" | grep -cF "\"command\": $CLAUDE_ROOT$POST_HOOK_SCRIPT\"")" -ne 1 ]; then
			note "$settings: the \"PostToolUse\" group does not invoke $POST_HOOK_SCRIPT exactly once — the group exists and the rail it is supposed to wire does not run"
		elif ! printf '%s\n' "$group" | grep -qF '"shell": "bash",'; then
			note "$settings: the \"PostToolUse\" hook carries no \"shell\": \"bash\" pin. The pin loop above counts entries across the whole file, so it cannot say WHICH entry is unpinned; this says it for the one entry whose failure is silent in both directions"
		# Coverage is the third silent failure. A matcher narrowed to `Write` still runs the
		# rail, still passes its self-test and still satisfies both checks above, while Bash and
		# Read output — where a credential actually surfaces — reaches the model unfiltered. The
		# Codex check below already demands its explicit all-tools matcher; this is the same
		# demand. An array holding more than one matcher is UNVERIFIED rather than read: without
		# a parser, which group's matcher governs the rail is a guess.
		elif [ "$matcher_keys" -gt 1 ] || [ "$matcher_keys" -ne "$matchers" ]; then
			note "$settings: the \"PostToolUse\" array carries $matcher_keys \"matcher\" key(s), $matchers of them one key per line, so which one governs $POST_HOOK_SCRIPT is UNVERIFIED, not all-tools. This guard reads a PostToolUse array holding a single matcher group, one key per line"
		elif ! printf '%s\n' "$group" | grep -qx '[[:space:]]*"matcher": "\*",\{0,1\}'; then
			note "$settings: the \"PostToolUse\" matcher is not the explicit all-tools \"*\", the one spelling this guard vouches for — a narrower matcher leaves every tool it does not name unredacted while the rail still looks wired"
		else
			claude_post=$((claude_post + 1))
		fi
	done
done
if [ "$claude_post" -eq 0 ] && [ "$claude_files" -gt 0 ]; then
	note "checked NOTHING for the Claude PostToolUse redaction hook across $claude_files file(s) — every file either lacked the group or failed above, so no file confirmed the rail"
fi

# Codex now exposes PostToolUse too. Its current contract cannot replace arbitrary results;
# the shared rail instead blocks a result only after redaction and supplies filtered feedback
# (DD-017).
# That semantic difference lives in the script, while this check proves both Codex adapter
# copies actually dispatch it for every tool. TOML is line-oriented here by deliberate local
# convention; an unread layout is UNVERIFIED rather than silently accepted.
codex_post=0
codex_files=0
for declaration in "${ADAPTERS[@]}"; do
	case $declaration in
	*codex-config.toml*) ;;
	*) continue ;;
	esac
	for config in "${declaration%|*}" "${declaration#*|}"; do
		[ -f "$config" ] || continue
		codex_files=$((codex_files + 1))
		group=$(sed -n '/^\[\[hooks\.PostToolUse\]\]$/,/^]$/p' "$config")
		# Counted for the Claude check's reason: a second PostToolUse table with its own ".*"
		# would otherwise vouch for a rail whose own matcher was narrowed (DD-034).
		codex_matchers=$(printf '%s\n' "$group" | grep -o 'matcher[[:space:]]*=' | wc -l | tr -d ' ')
		if [ -z "$group" ]; then
			note "$config: no [[hooks.PostToolUse]] group found at the layout this guard reads, so Codex output redaction is absent or UNVERIFIED"
		elif [ "$codex_matchers" -gt 1 ]; then
			note "$config: the PostToolUse hooks carry $codex_matchers matcher keys, so which one governs $POST_HOOK_SCRIPT is UNVERIFIED, not all-tools. This guard reads a single [[hooks.PostToolUse]] table"
		elif ! printf '%s\n' "$group" | grep -qx 'matcher = "\.\*"'; then
			note "$config: the PostToolUse matcher is not the explicit all-tools regular expression \".*\""
		elif [ "$(printf '%s\n' "$group" | grep -Ec '^[[:space:]]*\{ type = "command", command = ".*scripts/redact-tool-output\.sh.*"[, ]')" -ne 1 ]; then
			note "$config: the [[hooks.PostToolUse]] group does not declare exactly one command hook that invokes $POST_HOOK_SCRIPT"
		else
			codex_post=$((codex_post + 1))
		fi
	done
done
if [ "$codex_files" -eq 0 ]; then
	note "checked NOTHING for the Codex PostToolUse redaction hook — no Codex adapter file was reached"
elif [ "$codex_post" -ne "$codex_files" ]; then
	note "checked NOTHING for $((codex_files - codex_post)) of $codex_files Codex PostToolUse redaction hook(s)"
fi

# The command guard's PreToolUse matcher must name BOTH shell tools. On Windows, wherever Claude
# Code's PowerShell tool is enabled, shell commands are routed through it, and a matcher of
# `Bash` alone leaves the guard wired, self-testing green and never firing — the drive-root
# deletion that earned the PowerShell arm ran exactly there (DD-038, DD-039). Structural, like
# the checks above: the matcher read is the last `"matcher":` line before the guard's own
# command line, so a reordered or reformatted group is reported as unread, not passed.
claude_pre=0
for declaration in "${ADAPTERS[@]}"; do
	case $declaration in
	*claude-settings.json*) ;;
	*) continue ;;
	esac
	for settings in "${declaration%|*}" "${declaration#*|}"; do
		[ -f "$settings" ] || continue
		# The guard's own line is the anchored script followed by the end of the string or by the
		# trailing comment; ` --pre-task` after it is the spawn hook, a different entry.
		pre_matcher=$(GUARD_HOOK="\"command\": ${CLAUDE_ROOT}scripts/command-guard.sh" awk '
			/^[[:space:]]*"matcher":/ { m = $0 }
			{ line = $0; sub(/^[[:space:]]*/, "", line) }
			index(line, ENVIRON["GUARD_HOOK"]) == 1 && substr(line, length(ENVIRON["GUARD_HOOK"]) + 1) ~ /^("|  *#)/ { print m; found++ }
			END { if (found != 1) print "UNREAD " found }
		' "$settings")
		case $pre_matcher in
		*UNREAD*)
			note "$settings: the PreToolUse command-guard hook was not found exactly once at the layout this guard reads, so which tools it fires on is UNVERIFIED"
			;;
		*'"matcher": "Bash|PowerShell",'*) claude_pre=$((claude_pre + 1)) ;;
		*)
			note "$settings: the PreToolUse matcher in front of scripts/command-guard.sh is not \"Bash|PowerShell\" — on Windows the PowerShell tool is the primary shell wherever it is enabled, and a guard that matches Bash alone never fires there (DD-039)"
			;;
		esac
	done
done

# Two failures that let a call through with nothing reported, and the one sentence a Windows
# owner needs when the fix for them refuses everything (DD-040).
#
# Anchoring: Claude Code's hooks documentation says a handler runs in the session's CURRENT
# directory, so a relative `scripts/...` stops resolving the moment the agent runs `cd` into a
# subdirectory. The host counts the missing script as a non-blocking error and runs the call, so
# the command guard went dark for the rest of the session with nothing printed. Every hook command
# must open with `bash` and the quoted project root; a command key outside the one-key-per-line
# layout is counted by the layout-independent total and reported, never passed.
#
# Refusal on failure: each command-guard entry — the shell guard and the spawn speed bump — must
# be EXACTLY the object {type, shell, command, "onFailure": "block"}, under its own matcher, with
# its command line exactly as shipped. Exact, because every looser reading was satisfied by a
# defeated entry: a second `"onFailure": "continue"` key (JSON keeps the last), an added
# `"async": true` (the host ignores `block` on an async hook), `|| true` appended to the command,
# and a deleted or re-matched spawn entry all passed a check that only looked for the line after
# the command. The command's trailing comment is part of the exact line: with `block` set, a host
# where Claude Code finds no Git Bash refuses every shell call and spawn, the refusal quotes the
# hook's command, and that comment is the only AMH text the owner reads there.
claude_anchor_files=0
GUARD_TAIL=' # On Windows AMH requires Git Bash: install Git for Windows, or AMH is not usable",'
for declaration in "${ADAPTERS[@]}"; do
	case $declaration in
	*claude-settings.json*) ;;
	*) continue ;;
	esac
	for settings in "${declaration%|*}" "${declaration#*|}"; do
		[ -f "$settings" ] || continue
		read -r keys anchored < <(HOOK_ROOT="\"command\": $CLAUDE_ROOT" awk '
			{ keys += gsub(/"command"[[:space:]]*:/, "&") }
			{ line = $0; sub(/^[[:space:]]*/, "", line) }
			index(line, ENVIRON["HOOK_ROOT"]) == 1 { anchored++ }
			END { print keys + 0, anchored + 0 }
		' "$settings")
		if [ "${keys:-0}" -eq 0 ]; then
			note "$settings: checked NOTHING for hook anchoring — not one \"command\" key found at any layout"
			continue
		fi
		if [ "$anchored" -ne "$keys" ]; then
			note "$settings: $((keys - anchored)) of $keys hook command(s) do not open with bash and the quoted project root \"\${CLAUDE_PROJECT_DIR}\"/ at the layout this guard reads. Claude Code runs a hook in the session's current directory, so a relative path stops resolving after any \`cd\`, and the missing script is a non-blocking error: the call runs unjudged (DD-040)"
		fi
		entry_fails=0
		for entry in 'shell guard;Bash|PowerShell;' 'spawn speed bump;Task; --pre-task'; do
			IFS=';' read -r label matcher arg <<<"$entry"
			verdict=$(EXPECT="\"command\": ${CLAUDE_ROOT}scripts/command-guard.sh$arg$GUARD_TAIL" \
				MATCHER="\"matcher\": \"$matcher\"," awk '
				{ n++; line = $0; sub(/^[[:space:]]*/, "", line); L[n] = line }
				/^[[:space:]]*"matcher":/ { m = line }
				/^[[:space:]]*"[A-Z][A-Za-z]*": \[$/ { ev = line }
				line == ENVIRON["EXPECT"] { hits++; k = n; km = m; kev = ev }
				END {
					if (hits != 1) { print "MISSING " hits + 0; exit }
					if (kev != "\"PreToolUse\": [") { print "EVENT"; exit }
					if (km != ENVIRON["MATCHER"]) { print "MATCHER"; exit }
					if (L[k - 3] != "{" || L[k - 2] != "\"type\": \"command\"," ||
						L[k - 1] != "\"shell\": \"bash\"," || L[k + 1] != "\"onFailure\": \"block\"" ||
						L[k + 2] !~ /^}/) { print "SHAPE"; exit }
					print "OK"
				}
			' "$settings")
			case $verdict in
			OK) ;;
			MISSING*)
				note "$settings: the PreToolUse $label entry was not found exactly once (found ${verdict#MISSING }) as its exact shipped command line, Windows comment included. A missing entry, a changed or appended command such as \`|| true\`, and a dropped comment all land here; the comment is what a Windows host without Git Bash shows the owner when every call is refused (DD-040)"
				entry_fails=1
				;;
			EVENT)
				note "$settings: the $label entry does not sit under \"PreToolUse\" — under any other event it runs after the command or never, and blocks nothing (DD-070)"
				entry_fails=1
				;;
			MATCHER)
				note "$settings: the PreToolUse $label entry does not sit under \"matcher\": \"$matcher\" — under any other matcher it never fires (DD-040)"
				entry_fails=1
				;;
			*)
				note "$settings: the PreToolUse $label entry is not exactly {\"type\": \"command\", \"shell\": \"bash\", its command, \"onFailure\": \"block\"}. A missing or relaxed onFailure, a duplicate key (JSON keeps the last) or an added async key all let a guard that crashes, exits 1, times out or cannot start pass the call (DD-040)"
				entry_fails=1
				;;
			esac
		done
		# The PostToolUse check above reads its group from the key, so it has the event already.
		# The bootstrap is the one hook nothing else ties to an event: under another event it
		# runs at the wrong moment or never, and the session starts with no pre-push rail.
		session_event=$(EXPECT="\"command\": ${CLAUDE_ROOT}scripts/session-start.sh\"" awk '
			{ line = $0; sub(/^[[:space:]]*/, "", line) }
			/^[[:space:]]*"[A-Z][A-Za-z]*": \[$/ { ev = line }
			line == ENVIRON["EXPECT"] { hits++; kev = ev }
			END { if (hits != 1) print "MISSING " hits + 0; else print kev }
		' "$settings")
		case $session_event in
		'"SessionStart": [') ;;
		MISSING*)
			note "$settings: the session bootstrap hook was not found exactly once (found ${session_event#MISSING }) as its exact shipped command line (DD-070)"
			entry_fails=1
			;;
		*)
			note "$settings: the session bootstrap hook does not sit under \"SessionStart\" — under any other event it runs at the wrong moment or never (DD-070)"
			entry_fails=1
			;;
		esac
		# Each event key once, counted at any layout: JSON keeps the LAST of two keys, so a second,
		# empty array under the same event governs while every line-based read above still vouches.
		for event in PreToolUse PostToolUse SessionStart; do
			event_keys=$(grep -o "\"$event\"[[:space:]]*:" "$settings" | wc -l | tr -d ' ')
			if [ "$event_keys" -ne 1 ]; then
				note "$settings: $event_keys \"$event\" key(s) found, so which array governs is UNVERIFIED — JSON keeps the last of two, and an empty one leaves every hook under this event wired and never run (DD-070)"
				entry_fails=1
			fi
		done
		[ "$entry_fails" -eq 1 ] || [ "$anchored" -ne "$keys" ] || claude_anchor_files=$((claude_anchor_files + 1))
	done
done

# The file-editing tools' rail on the git pre-push hook. The command guard judges shell commands,
# never an editing tool, so this entry is the only layer between those tools and the hook that
# guards an agent's pushes, and a deleted entry looks exactly like a session that never tried to
# edit it — DD-013's lesson once more (DD-051). It does not load under `--restricted`, which
# ignores the project's settings file unless `--settings` names it; there the host's own rule,
# that only a person or the configured permission handler approves a write to git files, stands
# in for it (DD-053). The exact spelling, because the near misses are silent:
# `Write(...)` and `NotebookEdit(...)` path rules are accepted by the host and never match, and a
# single leading `/` anchors at the project, which misses a linked worktree's hooks in the main
# checkout's `.git`. Read inside the `"deny"` array, one entry per line, so the same string under
# `"allow"` or `"ask"` does not vouch for it.
HOOK_FILE_DENY='"Edit(//**/.git/hooks/**)"'
claude_hookfile=0
for declaration in "${ADAPTERS[@]}"; do
	case $declaration in
	*claude-settings.json*) ;;
	*) continue ;;
	esac
	for settings in "${declaration%|*}" "${declaration#*|}"; do
		[ -f "$settings" ] || continue
		deny=$(sed -n '/^[[:space:]]*"deny": \[$/,/^[[:space:]]*\]/p' "$settings")
		# Counted at any layout, for the PostToolUse check's reason: JSON keeps the LAST of two
		# keys, so a second, empty `"deny"` after the first is the array that governs, while the
		# range above would still read the first and vouch for it.
		deny_keys=$(grep -o '"deny"[[:space:]]*:' "$settings" | wc -l | tr -d ' ')
		if [ "$deny_keys" -ne 1 ]; then
			note "$settings: $deny_keys \"deny\" key(s) found, so which array governs is UNVERIFIED, and the file-editing tools' rail on the git pre-push hook with it. This guard reads one \"deny\" array, one entry per line (DD-051)"
		elif [ -z "$deny" ]; then
			note "$settings: no \"deny\" array found at the layout this guard reads (one entry per line), so the file-editing tools' rail on the git pre-push hook is UNVERIFIED, not present (DD-051)"
		elif ! printf '%s\n' "$deny" | HOOK_FILE_DENY=$HOOK_FILE_DENY awk '
			{ line = $0; sub(/^[[:space:]]*/, "", line); sub(/,$/, "", line) }
			line == ENVIRON["HOOK_FILE_DENY"] { found = 1 }
			END { exit !found }
		'; then
			note "$settings: permissions.deny does not carry $HOOK_FILE_DENY — without it the file-editing tools can rewrite or empty the git pre-push hook, which the command guard never sees them touch. A \`Write(...)\` path rule never matches, and a single leading \`/\` misses a linked worktree's hooks (DD-051)"
		else
			claude_hookfile=$((claude_hookfile + 1))
		fi
		# The root-anchored spellings of the /proc rails: a single leading slash in a settings file
		# does not name the filesystem root, so without these the rail may reach nothing (DD-070).
		if [ "$deny_keys" -eq 1 ] && [ -n "$deny" ]; then
			for rule in '"Read(//proc/*/environ)"' '"Read(//proc/**/environ)"'; do
				printf '%s\n' "$deny" | sed 's/^[[:space:]]*//; s/,$//' | grep -qxF -- "$rule" && continue
				note "$settings: permissions.deny does not carry $rule — a single leading slash does not name the filesystem root, so the /proc rail may never reach /proc (DD-070)"
			done
		fi
	done
done

# The machine-mode template (DD-063). It is a user-level fragment that no installer writes and that
# no ladder in any repository can see once it is installed, so this is the one place its wiring is
# checked. Its single hook must be EXACTLY the shipped entry. `--machine` matters most: without it
# the owner installs the full project guard for every session on the machine, AMH's push rails and
# the one-time state shared across projects included. Its deny array must carry every `Read(...)`
# credential rail the Claude adapter template carries, read from that template rather than written
# out a second time here, plus the Edit rail on the installed guard. The layout rules are the pin
# check's: an entry this guard cannot read is reported, never passed.
MACHINE_TEMPLATE=harness/templates/configs/claude-machine-settings.json
# shellcheck disable=SC2016 # `$HOME` is a literal in the file; the hook's own bash expands it
MACHINE_HOOK='"command": "bash \"$HOME/.claude/hooks/amh-command-guard.sh\" --machine # AMH machine mode. On Windows it requires Git Bash: install Git for Windows",'
MACHINE_SELF_DENY='"Edit(~/.claude/hooks/amh-command-guard.sh)"'
# The adapter template's two denials of a command that prints a stored credential by design.
MACHINE_BASH_RAILS='"Bash(gh auth token:*)"
"Bash(git credential fill:*)"'
if [ ! -f "$MACHINE_TEMPLATE" ]; then
	note "machine-mode template missing: $MACHINE_TEMPLATE"
else
	machine_hooks=$(grep -o '"type"[[:space:]]*:[[:space:]]*"command"' "$MACHINE_TEMPLATE" | wc -l | tr -d ' ')
	if [ "$machine_hooks" -ne 1 ]; then
		note "$MACHINE_TEMPLATE: $machine_hooks command hook(s) found at any layout, where the machine-mode fragment ships exactly one — a hook added there runs in every session on the machine, beside no project for a project-relative path to resolve against (DD-063)"
	fi
	# The EVENT the hook sits under is read too: the same exact entry under `"PostToolUse"` runs
	# after the command it was meant to stop. The last capitalised key opening an array before
	# the command line is the event; `"hooks"` and `"deny"` are lower-case and never match.
	verdict=$(EXPECT="$MACHINE_HOOK" awk '
		{ n++; line = $0; sub(/^[[:space:]]*/, "", line); L[n] = line }
		/^[[:space:]]*"matcher":/ { m = line }
		/^[[:space:]]*"[A-Z][A-Za-z]*": \[$/ { ev = line }
		line == ENVIRON["EXPECT"] { hits++; k = n; km = m; kev = ev }
		END {
			if (hits != 1) { print "MISSING " hits + 0; exit }
			if (kev != "\"PreToolUse\": [") { print "EVENT"; exit }
			if (km != "\"matcher\": \"Bash|PowerShell\",") { print "MATCHER"; exit }
			if (L[k - 3] != "{" || L[k - 2] != "\"type\": \"command\"," ||
				L[k - 1] != "\"shell\": \"bash\"," || L[k + 1] != "\"onFailure\": \"block\"" ||
				L[k + 2] !~ /^}/) { print "SHAPE"; exit }
			print "OK"
		}
	' "$MACHINE_TEMPLATE")
	case $verdict in
	OK) ;;
	MISSING*)
		note "$MACHINE_TEMPLATE: the machine-mode hook was not found exactly once (found ${verdict#MISSING }) as its exact shipped command line. A command without --machine installs the full project guard machine-wide, AMH's push rails and cross-project one-time state included (DD-063)"
		;;
	EVENT)
		note "$MACHINE_TEMPLATE: the machine-mode hook does not sit under \"PreToolUse\" — under any other event it runs after the command or never, and blocks nothing (DD-063)"
		;;
	MATCHER)
		note "$MACHINE_TEMPLATE: the machine-mode hook does not sit under \"matcher\": \"Bash|PowerShell\" — on Windows the PowerShell tool is the primary shell wherever it is enabled (DD-039)"
		;;
	*)
		note "$MACHINE_TEMPLATE: the machine-mode hook is not exactly {\"type\": \"command\", \"shell\": \"bash\", its command, \"onFailure\": \"block\"} — an unpinned or fail-open entry lets a guard that cannot run pass every call unjudged (DD-040)"
		;;
	esac
	machine_event_keys=$(grep -o '"PreToolUse"[[:space:]]*:' "$MACHINE_TEMPLATE" | wc -l | tr -d ' ')
	if [ "$machine_event_keys" -ne 1 ]; then
		note "$MACHINE_TEMPLATE: $machine_event_keys \"PreToolUse\" key(s) found, so which array governs is UNVERIFIED — JSON keeps the last of two, and an empty one leaves the machine-mode hook wired and never run (DD-070)"
	fi
	# One "deny" key, for the reason the pre-push hook check above counts them: JSON keeps the LAST
	# of two, so the range below would read an array that does not govern.
	machine_deny_keys=$(grep -o '"deny"[[:space:]]*:' "$MACHINE_TEMPLATE" | wc -l | tr -d ' ')
	machine_deny=$(sed -n '/^[[:space:]]*"deny": \[$/,/^[[:space:]]*\]/p' "$MACHINE_TEMPLATE" | sed 's/^[[:space:]]*//; s/,$//')
	# And the key the array sits under: a deny list outside `"permissions"` denies nothing.
	machine_deny_parent=$(awk '
		{ line = $0; sub(/^[[:space:]]*/, "", line) }
		line == "\"deny\": [" { print prev; exit }
		line != "" { prev = line }
	' "$MACHINE_TEMPLATE")
	if [ "$machine_deny_parent" != '"permissions": {' ]; then
		note "$MACHINE_TEMPLATE: the \"deny\" array does not open directly inside \"permissions\" at the layout this guard reads, so the machine-mode deny rails are UNVERIFIED, not present"
	fi
	while IFS= read -r rule; do
		printf '%s\n' "$machine_deny" | grep -qxF -- "$rule" && continue
		note "$MACHINE_TEMPLATE: permissions.deny lacks $rule, one of the adapter's two denials of a command that prints a stored credential by design"
	done <<<"$MACHINE_BASH_RAILS"
	adapter_reads=$(sed -n '/^[[:space:]]*"deny": \[$/,/^[[:space:]]*\]/p' harness/templates/configs/claude-settings.json |
		sed 's/^[[:space:]]*//; s/,$//' | grep '^"Read(')
	if [ "$machine_deny_keys" -ne 1 ] || [ -z "$machine_deny" ]; then
		note "$MACHINE_TEMPLATE: $machine_deny_keys \"deny\" key(s), and the array read at the one-entry-per-line layout is ${machine_deny:+not }empty, so the machine-mode deny rails are UNVERIFIED, not present"
	elif [ -z "$adapter_reads" ]; then
		note "checked NOTHING for the machine-mode credential rails — no \"Read(...)\" entry found in the Claude adapter template's deny array at the layout this guard reads"
	else
		while IFS= read -r rule; do
			printf '%s\n' "$machine_deny" | grep -qxF -- "$rule" && continue
			note "$MACHINE_TEMPLATE: permissions.deny lacks $rule, which the Claude adapter template carries — the file-reading tool is a path the command guard never sees, in every session the fragment covers"
		done <<<"$adapter_reads"
	fi
	if ! printf '%s\n' "$machine_deny" | grep -qxF -- "$MACHINE_SELF_DENY"; then
		note "$MACHINE_TEMPLATE: permissions.deny lacks $MACHINE_SELF_DENY — the file-editing tools could rewrite the guard every session runs under, which the guard never sees them touch (DD-051)"
	fi
fi

# The host sandboxes (DD-079). CONFIGURATION VALIDATION, NOT RUNTIME ATTESTATION: everything below
# reads the shipped files and nothing else, so a pass says what those files ask for, never that a
# sandbox started, enforced anything, or is the configuration a session actually resolves. A local
# settings file, a user or managed one, `--settings` and a missing bubblewrap all change that
# without touching a byte read here, and no probe of a live session is evidence this guard holds.
#
# Claude Code: the project file asks for EXACTLY the shipped sandbox, and nothing that widens it.
# Every key the host accepts under `sandbox` either loosens it or changes what the owner decided,
# and each is silent: `enabled: false` turns it off, `allowUnsandboxedCommands: true` reopens the
# retry outside it, `autoAllowBashIfSandboxed: true` approves a command for being sandboxed, and
# `excludedCommands`, `filesystem`, `network` and the weaker-isolation and socket switches widen
# what a sandboxed command reaches. `failIfUnavailable: true` tightens on paper and stops Claude
# Code starting on native Windows, which the owner chose not to do (DD-078). A misspelled key is
# ignored by the host, so it reads as configured while meaning nothing.
#
# Permission rules feed the sandbox too, so a byte-exact block is not enough: an `Edit(...)` or
# `Write(...)` allow rule grants sandboxed writes, a `Read(...)` allow can reopen a denied read,
# a `WebFetch(...)` allow adds a domain, `additionalDirectories` adds working directories and
# `defaultMode` decides who approves — `bypassPermissions` approves everything unasked. The shipped
# file sets none of them, and this refuses each.
#
# Read with a tokenizer, not by lines, because the earlier line reading passed configurations the
# host loads differently: a block indented like a top-level key while nested under `permissions`,
# and a key spelled with a JSON escape (`"\u0073andbox"`), which decodes to a second `sandbox` that
# JSON lets govern. The tokenizer follows strings, escapes and nesting and prints every key's path
# and every scalar's raw text, so scope, order, layout and CRLF stop mattering. The path joins keys
# with \034, a control character no JSON string may hold raw, because a dot would let the literal
# key "sandbox.enabled" pose as nesting. It decodes nothing, so an escaped KEY is refused outright,
# and so is an escaped allow value, which would decode to a rule refused in plain spelling; no AMH
# entry needs either. A file it cannot follow to a balanced end, and a scanner that fails, are
# UNVERIFIED, never passed.
# shellcheck disable=SC2016 # an awk program, not shell
JSON_PATHS='
function path(   s, j) { s = ""; for (j = 1; j <= d; j++) s = s (j > 1 ? "\034" : "") k[j]; return s }
function scalar() { if (tok != "") { print "VAL\t" path() "\t" tok; tok = "" } }
{
	sub(/\r$/, "")
	n = length($0)
	for (i = 1; i <= n; i++) {
		c = substr($0, i, 1)
		if (ins) {
			if (esc) { esc = 0; s = s c; continue }
			if (c == "\\") { esc = 1; bs = 1; s = s c; continue }
			if (c != "\"") { s = s c; continue }
			ins = 0
			if (t[d] == "o" && want) { k[d] = s; want = 0; print "KEY\t" path() "\t" bs }
			else print "VAL\t" path() "\t\"" s "\"\t" bs
			continue
		}
		if (c == " " || c == "\t") { scalar(); continue }
		if (c == "\"") { scalar(); ins = 1; s = ""; bs = 0; continue }
		if (c == "{") { d++; t[d] = "o"; k[d] = ""; want = 1; continue }
		if (c == "[") { d++; t[d] = "a"; k[d] = "[]"; continue }
		if (c == "}" || c == "]") { scalar(); d--; if (d < 0) bad = 1; continue }
		if (c == ",") { scalar(); if (t[d] == "o") want = 1; continue }
		if (c == ":") { scalar(); continue }
		tok = tok c
	}
	scalar()
}
END { if (ins || d != 0 || bad) print "BROKEN" }
'
claude_sandbox=0
for declaration in "${ADAPTERS[@]}"; do
	case $declaration in
	*claude-settings.json*) ;;
	*) continue ;;
	esac
	for settings in "${declaration%|*}" "${declaration#*|}"; do
		[ -f "$settings" ] || continue
		findings=$(awk "$JSON_PATHS" "$settings" | awk -F'\t' '
			$1 == "BROKEN" { broken = 1 }
			$1 == "KEY" { keys++ }
			function shown(p) { gsub(/\034/, ".", p); return p }
			$1 == "KEY" && $3 == 1 { print "ESCAPED\t" shown($2) }
			$1 == "KEY" && $2 == "sandbox" { top++ }
			$1 == "KEY" && index($2, "sandbox\034") == 1 { kids++ }
			$1 == "VAL" && index($2, "sandbox\034") == 1 { v[$2] = $3 }
			$1 == "KEY" && ($2 == "permissions\034additionalDirectories" || $2 == "permissions\034defaultMode") { print "WIDEN\t" shown($2) }
			$1 == "VAL" && $2 == "permissions\034allow\034[]" && $3 ~ /^"(Edit|Write|Read|WebFetch)(\(|"$)/ { t = $3; sub(/^"/, "", t); sub(/[("].*/, "", t); print "ALLOW\t" t }
			$1 == "VAL" && $2 == "permissions\034allow\034[]" && $4 == 1 { print "ESCVAL" }
			END {
				if (broken) print "BROKEN"
				else if (keys == 0) print "EMPTY"
				else if (top != 1) print "COUNT\t" top + 0
				else if (kids != 3 || v["sandbox\034enabled"] != "true" ||
					v["sandbox\034allowUnsandboxedCommands"] != "false" ||
					v["sandbox\034autoAllowBashIfSandboxed"] != "false") print "SHAPE"
				print "DONE"
			}
		')
		# Both scanners must SUCCEED and the consumer must reach its last line: a scanner that dies
		# prints nothing, and nothing is exactly what a clean file prints (DC-002's fail-closed rule).
		scan_rc=$?
		if [ "$scan_rc" -ne 0 ] || [ "${findings##*$'\n'}" != DONE ]; then
			note "$settings: the sandbox scanner failed (exit $scan_rc) or stopped before its end, so the sandbox configuration is UNVERIFIED, not present (DD-079)"
			continue
		fi
		findings=${findings%DONE}
		if [ -z "$findings" ]; then
			claude_sandbox=$((claude_sandbox + 1))
			continue
		fi
		while IFS=$'\t' read -r kind detail; do
			case $kind in
			'') ;;
			BROKEN) note "$settings: the sandbox check could not follow this file to a balanced end — an unclosed string, object or array — so the sandbox configuration is UNVERIFIED, not present (DD-079)" ;;
			EMPTY) note "$settings: checked NOTHING for the sandbox — the tokenizer read not one key, so this guard either reads an empty file or has stopped reading the one it checks (DD-079)" ;;
			ESCAPED) note "$settings: the key $detail is written with a JSON escape. This guard decodes nothing, and \"\\u0073andbox\" is a second \"sandbox\" that JSON lets govern, so an escaped key is refused outright; no AMH key needs one (DD-079)" ;;
			COUNT) note "$settings: $detail top-level \"sandbox\" key(s), where the adapter ships exactly one — none leaves the host sandbox off, a block nested under another key turns nothing on, and with two JSON keeps the last (DD-079)" ;;
			SHAPE) note "$settings: the \"sandbox\" block is not exactly {\"enabled\": true, \"allowUnsandboxedCommands\": false, \"autoAllowBashIfSandboxed\": false}. Every other key loosens it, approves commands for being sandboxed, reopens the unsandboxed retry, or — failIfUnavailable — stops Claude Code starting on native Windows; a misspelled key is ignored by the host and reads as configured (DD-079)" ;;
			WIDEN) note "$settings: sets $detail, which the shipped adapter never sets — additionalDirectories adds working directories, and defaultMode decides who approves, bypassPermissions approving everything unasked (DD-079)" ;;
			ESCVAL) note "$settings: permissions.allow carries an allow value written with a JSON escape. This guard decodes nothing, and \"\\u0052ead(//**)\" is the Read rule a plain spelling would be refused for, so an escaped allow value is refused outright (DD-079)" ;;
			ALLOW) note "$settings: permissions.allow carries a $detail rule, and permission rules feed the sandbox: an Edit or Write allow grants sandboxed writes, a Read allow can reopen a denied read, a WebFetch allow adds a domain. The shipped adapter allows only Bash commands (DD-079)" ;;
			esac
		done <<<"$findings"
	done
done

# Codex: AMH relies on Codex's default sandbox and pins none of it, because a pinned key could
# override the user's own policy or collide with their `default_permissions` profile (DD-079). So
# the shipped config may hold its three hook tables and nothing else. An allow-list, not a list of
# known loosening keys: `sandbox_mode = "danger-full-access"`, `[sandbox_workspace_write]` with
# `network_access` or `writable_roots`, a `default_permissions` profile, `[permissions.*]` network
# and domain rules (which bind only while a proxy runs, `network.enabled` alone opening direct
# networking), `approval_policy`, `[windows] sandbox` and `[features]` all fail here without being
# named, and so does the key nobody has thought of yet, dotted, quoted or inline. Every line outside
# a comment must be a hook table header, a matcher, the hook list's opening or closing line, or one
# inline command entry. It fails CLOSED on layout: the same hooks written in another TOML spelling
# (CRLF, quoted table names, `matcher="..."`) fail here as they fail the hook checks above, and the
# fix is the shipped spelling, never a wider pattern.
codex_sandbox=0
for declaration in "${ADAPTERS[@]}"; do
	case $declaration in
	*codex-config.toml*) ;;
	*) continue ;;
	esac
	for config in "${declaration%|*}" "${declaration#*|}"; do
		[ -f "$config" ] || continue
		stray=$(awk '
			/^[[:space:]]*(#|$)/ { next }
			/^\[\[hooks\.(SessionStart|PreToolUse|PostToolUse)\]\]$/ { read++; next }
			/^matcher = "[^"]*"$/ || /^hooks = \[$/ || /^\]$/ { read++; next }
			/^  \{ type = "command", command = .*\},$/ { read++; next }
			{ printf "%s%s", (bad ? " " : ""), NR; bad++ }
			END { if (read == 0 && bad == 0) print "EMPTY"; else if (bad) print ""; print "DONE" }
		' "$config")
		# Line NUMBERS only: a rejected line is unknown text, and it could carry a credential.
		scan_rc=$?
		if [ "$scan_rc" -ne 0 ] || [ "${stray##*$'\n'}" != DONE ]; then
			note "$config: the Codex sandbox scanner failed (exit $scan_rc) or stopped before its end, so whether this file sets a sandbox key is UNVERIFIED (DD-079)"
			continue
		fi
		stray=${stray%DONE}
		stray=${stray%$'\n'}
		if [ "$stray" = EMPTY ]; then
			note "$config: checked NOTHING for Codex sandbox keys — not one line was read, so this guard either reads an empty file or has stopped reading the one it checks (DD-079)"
		elif [ -n "$stray" ]; then
			note "$config: carries line(s) outside its three hook tables — AMH relies on Codex's default sandbox and ships no sandbox, permission, network, approval, feature or Windows key, since any of them can loosen it or collide with the user's default_permissions profile (DD-079): line(s) $stray"
		else
			codex_sandbox=$((codex_sandbox + 1))
		fi
	done
done

# The rule reviewer is the one place the adapters DO pin a Codex sandbox: a review agent that can
# write is not the read-only second opinion the Rule-review protocol asks for. Exactly one
# `sandbox_mode` key, and it is read-only. Read as TOML keys, not as text: a mention in a comment
# is not an assignment, and the line `sandbox_mode = "read-only"` inside the multi-line
# `developer_instructions` string is instruction text, not a key. So the reader skips comments,
# follows `"""` and `'''` strings to their end, and then requires every remaining line to be a
# bare key at the left margin. A quoted or escaped key (`"sandbox_mode"`), a dotted key, an
# indented line and a table header are refused rather than read, since each can carry a second
# sandbox_mode this reader would not see.
reviewer_sandbox=0
for declaration in "${ADAPTERS[@]}"; do
	case $declaration in
	*amh-rule-reviewer.toml*) ;;
	*) continue ;;
	esac
	for agent in "${declaration%|*}" "${declaration#*|}"; do
		[ -f "$agent" ] || continue
		# A multi-line string opens only where a VALUE begins with its delimiter: a triple quote inside
		# an ordinary string, `description = "x '''"`, opens nothing, and treating it as an opening hid
		# the real assignments after it. A string still open at the end is refused, never read past.
		scan=$(awk '
			function opens(v,   q) {
				q = substr(v, 1, 3)
				if (q != "\"\"\"" && q != "'"'''"'") return ""
				# A string that opens and closes on the same line leaves nothing open.
				return (index(substr(v, 4), q) ? "" : q)
			}
			{ sub(/\r$/, "") }
			ml != "" { if (index($0, ml)) ml = ""; next }
			/^[[:space:]]*(#|$)/ { next }
			!/^[A-Za-z0-9_-]+[[:space:]]*=/ { unread++; next }
			{
				key = $0; sub(/[[:space:]]*=.*/, "", key)
				val = $0; sub(/^[^=]*=[[:space:]]*/, "", val)
				if (key == "sandbox_mode") {
					modes++
					if (val ~ /^("read-only"|'"'read-only'"')([[:space:]]*#.*)?$/) pinned++
				}
				ml = opens(val)
			}
			END { print modes + 0, pinned + 0, unread + 0, (ml != "" ? 1 : 0) }
		' "$agent")
		scan_rc=$?
		if [ "$scan_rc" -ne 0 ] || ! [[ $scan =~ ^[0-9]+\ [0-9]+\ [0-9]+\ [01]$ ]]; then
			note "$agent: the reviewer sandbox scanner failed (exit $scan_rc) or printed no verdict, so the reviewer's sandbox_mode is UNVERIFIED, not read-only (DD-079)"
			continue
		fi
		read -r modes pinned unread open <<<"$scan"
		if [ "$open" -ne 0 ]; then
			note "$agent: a multi-line string opens and never closes, so everything after its opening is UNVERIFIED — a second sandbox_mode could sit there unread (DD-079)"
		elif [ "$unread" -ne 0 ]; then
			note "$agent: $unread line(s) are not a bare top-level key, a comment or the body of a multi-line string — a table header, an indented, dotted, quoted or escaped key — so whether a second sandbox_mode sits there is UNVERIFIED. This guard reads a reviewer made of bare top-level keys (DD-079)"
		elif [ "$modes" -ne 1 ] || [ "$pinned" -ne 1 ]; then
			note "$agent: the reviewer must carry exactly one sandbox_mode key, and it read-only — found $modes such key(s), $pinned of them read-only. A reviewer that can write is not a read-only second opinion (DD-079)"
		else
			reviewer_sandbox=$((reviewer_sandbox + 1))
		fi
	done
done

[ "$fails" -eq 0 ] || exit 1
printf 'first-class adapter set is complete across sources, reference paths, installation and legislation; %s Claude command hook(s) across %s file(s) pin shell=bash, %s file(s) anchor every Claude hook at the project root and refuse calls when a command guard fails, %s Claude command guard(s) match Bash|PowerShell, %s Claude and %s Codex adapter(s) wire the PostToolUse redaction rail for every tool, %s Claude file(s) deny the editing tools the git pre-push hook, the machine-mode template carries its exact hook and every adapter credential Read rail, and as configuration validation, not runtime attestation, %s Claude file(s) request exactly the shipped sandbox block, %s Codex file(s) set no key outside their hook tables, and %s reviewer file(s) pin sandbox_mode read-only\n' "$claude_hooks" "$claude_files" "$claude_anchor_files" "$claude_pre" "$claude_post" "$codex_post" "$claude_hookfile" "$claude_sandbox" "$codex_sandbox" "$reviewer_sandbox"
