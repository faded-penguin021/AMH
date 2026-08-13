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
if [ -z "$banner_adapters" ]; then
	note "amh.conf ADAPTER_FILES is empty or unset — the banner reports no adapter at all, which is indistinguishable from a repo that ships none"
fi

for declaration in "${ADAPTERS[@]}"; do
	IFS='|' read -r source destination <<<"$declaration"
	[ -f "$source" ] || note "adapter source missing: $source"
	[ -f "$destination" ] || note "adapter reference-instance path missing: $destination"

	install="install_file \"\$TPL/${source#harness/templates/}\" $destination keep 644"
	grep -qFx -- "$install" scripts/amh-init.sh ||
		note "adapter install action missing: $source -> $destination"

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

[ "$fails" -eq 0 ] || exit 1
printf 'first-class adapter set is complete across sources, reference paths, installation and legislation\n'
