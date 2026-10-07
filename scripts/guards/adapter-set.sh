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
		if [ "$(printf '%s\n' "$group" | grep -cF "\"command\": \"$POST_HOOK_SCRIPT\"")" -ne 1 ]; then
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
		pre_matcher=$(awk '
			/^[[:space:]]*"matcher":/ { m = $0 }
			/^[[:space:]]*"command": "scripts\/command-guard\.sh"$/ { print m; found++ }
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

[ "$fails" -eq 0 ] || exit 1
printf 'first-class adapter set is complete across sources, reference paths, installation and legislation; %s Claude command hook(s) across %s file(s) pin shell=bash, %s Claude command guard(s) match Bash|PowerShell, %s Claude and %s Codex adapter(s) wire the PostToolUse redaction rail for every tool\n' "$claude_hooks" "$claude_files" "$claude_pre" "$claude_post" "$codex_post"
