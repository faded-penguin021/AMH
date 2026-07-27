#!/usr/bin/env bash
# AMH — instantiate the harness into a target repository.
#
#   scripts/amh-init.sh [options] <target-repo>
#
# Repo-local tooling: this script runs FROM the harness's source of truth and writes INTO
# somebody else's repo. It is not one of the shipped scripts and has no copy under
# harness/templates/ — an adopter never runs it against themselves.
#
# The one idea it encodes is the split that makes later upgrades a copy instead of a merge
# (see docs/UPGRADING.md, which states the same table for humans):
#
#   SHIPPED   scripts/*.sh from harness/templates/scripts/ — parameter-free, they read
#             amh.conf at runtime. Overwritten on every run, because that is what makes
#             an upgrade a copy. Never edit them in an adopting repo.
#   YOURS     the seed prose, amh.conf, the CI workflow, the agent adapter config.
#             Written only when absent. Re-running never clobbers a word an adopter wrote.
#
# That split is also what makes this script idempotent in the way that matters: running it
# twice upgrades the machinery and leaves the judgement alone.
#
# --profile cuts across the YOURS half only, and only at install time. It selects which seed
# prose files land; it is not written into the target tree and no script reads it, so there is
# no "level" anywhere afterwards for a future guard to branch on. The rungs of the shipped
# ladder activate on artifact presence — no ledger means the ledger rung skips and says so —
# which is why a smaller profile degrades to a green ladder rather than a red one. Escalating
# is a re-run with a larger profile: the new seeds are added and, because every seed is
# keep-policy, nothing the adopter wrote is touched.
#
# What it deliberately does NOT do: fill in the {{PLACEHOLDER}}s that only the adopter can
# answer (their invariants, their test commands, their module map). Those are listed at the
# end of the run. A tool that guessed them would produce a constitution that reads as
# finished and says nothing.

set -uo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
TPL="$ROOT/harness/templates"

NL=$'\n'
# ANSI-C quoting, not a single-quoted backslash: the linter reads that as an escape
# attempt (SC1003) and CI fails the lint rung on any output at all. Note the comment
# wording too — a line that STARTS with the linter's name is parsed as a directive.
BS=$'\\'

die() {
	printf 'amh-init: %s\n' "$1" >&2
	exit 1
}

# A missing value silently eats the next word: `--default-branch --dry-run <target>` set the
# branch to `--dry-run` and quietly did NOT enable the dry run. The options with their own
# validation caught it; the three free-form ones had none.
need_value() { # <flag> <value>
	case ${2:-} in
	'' | -*) die "$1 needs a value" ;;
	esac
}

usage() {
	cat <<'USAGE'
usage: scripts/amh-init.sh [options] <target-repo>

  --profile NAME            light | standard | full               (default: light)
  --default-branch NAME     branch agents must never push to      (default: main)
  --branch-prefix NAME      session-branch namespace              (default: claude)
  --merge-mode MODE         branch-per-change | branch-train      (default: branch-per-change)
  --remote-flag NAME        env var marking a remote container    (default: AMH_REMOTE)
  --compress-to-kb N        state-file compression floor          (default: 9)
  --warn-kb N               state-file soft cap                   (default: 14)
  --hard-kb N               state-file hard cap                   (default: 16)
  --line-cap N              lines per ledger volume               (default: 800)
  --citation-paths 'A B'    trees scanned for D-NNN citations     (default: scripts .github)
  -n, --dry-run             report what would be written, write nothing
  -h, --help                this message

Re-running is safe: shipped scripts are overwritten (that is the upgrade path), everything
you own is left untouched.

The profile selects which seed PROSE is installed, and nothing else. The shipped scripts are
byte-identical for every profile, and no profile disables a guard — the ladder's rungs
activate on artifact presence, so a repo without a ledger reports the ledger rung as skipped
rather than failing. Nothing in the target tree records which profile was used: escalating is
`--profile standard <target>`, which adds the missing seeds and, because everything already
present is yours, changes nothing you have written.

  light      constitution, working memory, one verification command
  standard   + the runbook and the append-only ledger
  full       + the frozen archive tier
USAGE
}

PROFILE=light
DEFAULT_BRANCH=main
BRANCH_PREFIX=claude
MERGE_MODE_KEY=branch-per-change
REMOTE_FLAG=AMH_REMOTE
COMPRESS_TO_KB=9
WARN_KB=14
HARD_KB=16
LINE_CAP=800
CITATION_SCAN_PATHS='scripts .github'
DRY_RUN=0
TARGET=''

while [ $# -gt 0 ]; do
	case $1 in
	--profile)
		need_value --profile "${2:-}"
		# shellcheck disable=SC2034 # read indirectly through ${!name} in the
		# INIT_PLACEHOLDERS loop, which shellcheck cannot follow. Scoped to this one
		# assignment: a file-level directive would also hide a genuinely dead variable.
		PROFILE=$2
		shift 2
		;;
	--default-branch)
		need_value --default-branch "${2:-}"
		# shellcheck disable=SC2034 # read indirectly through ${!name} in the
		# INIT_PLACEHOLDERS loop, which shellcheck cannot follow. Scoped to this one
		# assignment: a file-level directive would also hide a genuinely dead variable.
		DEFAULT_BRANCH=$2
		shift 2
		;;
	--branch-prefix)
		need_value --branch-prefix "${2:-}"
		# shellcheck disable=SC2034 # read indirectly through ${!name} in the
		# INIT_PLACEHOLDERS loop, which shellcheck cannot follow. Scoped to this one
		# assignment: a file-level directive would also hide a genuinely dead variable.
		BRANCH_PREFIX=$2
		shift 2
		;;
	--merge-mode)
		need_value --merge-mode "${2:-}"
		MERGE_MODE_KEY=$2
		shift 2
		;;
	--remote-flag)
		need_value --remote-flag "${2:-}"
		REMOTE_FLAG=$2
		shift 2
		;;
	--compress-to-kb)
		need_value --compress-to-kb "${2:-}"
		COMPRESS_TO_KB=$2
		shift 2
		;;
	--warn-kb)
		need_value --warn-kb "${2:-}"
		WARN_KB=$2
		shift 2
		;;
	--hard-kb)
		need_value --hard-kb "${2:-}"
		HARD_KB=$2
		shift 2
		;;
	--line-cap)
		need_value --line-cap "${2:-}"
		LINE_CAP=$2
		shift 2
		;;
	--citation-paths)
		need_value --citation-paths "${2:-}"
		# shellcheck disable=SC2034 # read indirectly through ${!name} in the
		# INIT_PLACEHOLDERS loop, which shellcheck cannot follow. Scoped to this one
		# assignment: a file-level directive would also hide a genuinely dead variable.
		CITATION_SCAN_PATHS=$2
		shift 2
		;;
	-n | --dry-run)
		DRY_RUN=1
		shift
		;;
	-h | --help)
		usage
		exit 0
		;;
	-*) die "unknown option: $1 (try --help)" ;;
	*)
		[ -z "$TARGET" ] || die "more than one target given: $TARGET and $1"
		TARGET=$1
		shift
		;;
	esac
done

[ -n "$TARGET" ] || {
	usage >&2
	exit 2
}
[ -d "$TARGET" ] || die "target is not a directory: $TARGET"
# Every guard and the session bootstrap are git-dependent, so a plain directory succeeds
# here and fails later inside a guard — the exact "fails somewhere else, in a repo whose
# owner has no idea this script chose it" shape the validation below exists to prevent.
git -C "$TARGET" rev-parse --git-dir >/dev/null 2>&1 ||
	die "target is not a git repository: $TARGET (run 'git init' there first)"
[ -d "$TPL" ] || die "cannot find harness/templates — run this from the harness repo"

AMH_VERSION=$(tr -d '[:space:]' <"$ROOT/harness/VERSION" 2>/dev/null) || AMH_VERSION=''
[ -n "$AMH_VERSION" ] || die "cannot read harness/VERSION"

# --- validation -------------------------------------------------------------
#
# Every one of these is a value that would otherwise fail LATER, inside a guard, in a repo
# whose owner has no idea this script chose it.
case $MERGE_MODE_KEY in
branch-per-change | branch-train) ;;
*) die "--merge-mode must be branch-per-change or branch-train, not '$MERGE_MODE_KEY'" ;;
esac

# Validated HERE rather than tolerated and reported later, for the --merge-mode reason: a
# typo'd profile that fell through to "install everything" would hand an adopter more process
# than they asked for and say nothing, and one that fell through to "install nothing" would
# hand them a tree with no constitution.
case $PROFILE in
light) PROFILE_RANK=1 ;;
standard) PROFILE_RANK=2 ;;
full) PROFILE_RANK=3 ;;
*) die "--profile must be light, standard or full, not '$PROFILE'" ;;
esac

# REMOTE_FLAG becomes the NAME of a shell variable the bootstrap reads indirectly. A value
# like AMH-REMOTE is not a shell identifier, so the read fails at runtime and the toolchain
# bootstrap is skipped — quietly, which is the worst way for it to fail. Reject it here.
# (This narrows the blast radius; it does not fix the bootstrap's silent skip, which is a
# separate open finding against session-start.sh.)
case $REMOTE_FLAG in
[A-Za-z_]*) [[ $REMOTE_FLAG =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]] || die "--remote-flag must be a valid shell variable name (letters, digits, underscore; not starting with a digit): '$REMOTE_FLAG'" ;;
*) die "--remote-flag must be a valid shell variable name: '$REMOTE_FLAG'" ;;
esac

for pair in "COMPRESS_TO_KB:$COMPRESS_TO_KB" "WARN_KB:$WARN_KB" "HARD_KB:$HARD_KB" "LINE_CAP:$LINE_CAP"; do
	case ${pair#*:} in
	'' | *[!0-9]*) die "${pair%%:*} must be a whole number, not '${pair#*:}'" ;;
	esac
done
[ "$WARN_KB" -gt "$COMPRESS_TO_KB" ] || die "--warn-kb ($WARN_KB) must exceed --compress-to-kb ($COMPRESS_TO_KB): the band between them IS the debounce"
[ "$HARD_KB" -gt "$WARN_KB" ] || die "--hard-kb ($HARD_KB) must exceed --warn-kb ($WARN_KB)"

# The placeholders this script fills, as DATA rather than ten near-identical sed lines.
# Each name is also the name of a variable set above, which is what makes the table
# self-consistent: adding a placeholder here and forgetting its value is a shell error, not
# a silently unsubstituted file. It also keeps the literal `{{…}}` spellings out of this
# file — they are built at runtime — so the placeholder guard does not have to carve out an
# exemption for the one script whose whole job is filling placeholders in. An exemption
# would have been a standing hole: it would also hide a placeholder this script forgot.
INIT_PLACEHOLDERS='AMH_VERSION PROFILE DEFAULT_BRANCH BRANCH_PREFIX MERGE_MODE_KEY REMOTE_FLAG COMPRESS_TO_KB WARN_KB HARD_KB LINE_CAP CITATION_SCAN_PATHS'

# ...and that table is bound to harness/PLACEHOLDERS.md, whose `init` rows are the same
# set said in prose. Nothing bound them before: they agreed, and a new template
# placeholder documented as `init` but left out of the list above would have been written
# into an adopter's live config unfilled, reported by the run's own summary as something
# THEY had to fill in. Silent divergence between a list and the document describing it is
# the whole failure (D-025).
#
# The check dies rather than warns, and it dies for the HARNESS maintainer, never for an
# adopter — nobody runs this script against their own repo. An empty derived set is a
# mismatch like any other, so the pattern drifting away from the table cannot make the
# check vacuously pass, which is the way a binding like this usually rots.
PLACEHOLDER_DOC="$ROOT/harness/PLACEHOLDERS.md"
[ -f "$PLACEHOLDER_DOC" ] ||
	die "cannot find harness/PLACEHOLDERS.md — the init placeholder list has nothing to check against"
# shellcheck disable=SC2016 # the backticks belong to the sed script: it matches the
# markdown code span in the table's first cell. Expanding them would run the cell text.
doc_init=$(sed -n 's/^| *`\([^`]*\)` *| *init *|.*/\1/p' "$PLACEHOLDER_DOC" | sort)
list_init=$(printf '%s\n' "$INIT_PLACEHOLDERS" | tr ' ' '\n' | sort)
if [ "$doc_init" != "$list_init" ]; then
	printf 'amh-init: INIT_PLACEHOLDERS and the init rows of harness/PLACEHOLDERS.md disagree.\n' >&2
	printf '  only in this script: %s\n' "$(comm -13 <(printf '%s\n' "$doc_init") <(printf '%s\n' "$list_init") | tr '\n' ' ')" >&2
	printf '  only in the document: %s\n' "$(comm -23 <(printf '%s\n' "$doc_init") <(printf '%s\n' "$list_init") | tr '\n' ' ')" >&2
	die 'fix whichever is wrong — a placeholder in one and not the other ships unfilled'
fi

# The substitutions run through sed with `|` as the delimiter, so four characters are
# refused rather than escaped: a silently mangled config is worse than a refusal, and no
# legitimate value here needs any of them.
#
#   |   ends the s|| command, so the rest of the value is read as sed syntax
#   &   is "the whole match" in a replacement, so `a&b` writes the placeholder back in
#       and produces a live file with an unfilled {{...}} in it
#   \   escapes the next character, and \n injects a NEWLINE into amh.conf — a file every
#       shipped script SOURCES at runtime, so that line is executed on every future ladder
#       run of the adopter's repo
#
# All three were silent: exit 0, a broken config, no warning. Checked, not escaped.
SED_ARGS=()
for name in $INIT_PLACEHOLDERS; do
	case ${!name} in
	*'|'* | *'&'* | *"$BS"* | *"$NL"*)
		die "$name may not contain '|', '&', a backslash or a newline: '${!name}'"
		;;
	esac
	SED_ARGS+=(-e "s|{{$name}}|${!name}|g")
done

# --- writing ----------------------------------------------------------------

WROTE=0
KEPT=0
DECLINED=0

# Which profile first installs each seed file. The table is EXHAUSTIVE and unmatched is fatal
# — a new seed file added without a line here would otherwise land silently in whichever
# bucket the catch-all named, for every adopter, with no diagnostic. It dies for the harness
# maintainer, never for an adopter (nobody runs this script against their own repo), and
# scripts/tests/test-init-e2e.sh instantiates the real tree, so the omission fails there
# rather than at somebody's adoption (the D-025 shape).
#
# The ordering is cumulative: `standard` installs everything `light` does, `full` everything
# `standard` does. Nothing records the choice in the target tree — see the usage text.
#
# It reports through a global rather than stdout, deliberately: `die` inside a command
# substitution kills only the subshell, so an unclassified file would print its diagnostic and
# let the run carry on — a fatal check that is not fatal, which is worse than no check. Fatal
# is all it claims: the run aborts wherever the loop had got to, leaving a partly-written
# target. Acceptable because it can only fire for a harness maintainer who added a seed file
# and did not classify it, and the repair is to classify it and re-run.
SEED_RANK=0
seed_min_rank() { # <rel> -> sets SEED_RANK to 1 (light), 2 (standard) or 3 (full)
	case $1 in
	AGENTS.md | CLAUDE.md | docs/STATE.md | scripts/verify.sh) SEED_RANK=1 ;;
	docs/RUNBOOK.md | docs/LEDGER.md) SEED_RANK=2 ;;
	docs/history/README.md) SEED_RANK=3 ;;
	*) die "seed file has no profile classification: $1 (add it to seed_min_rank)" ;;
	esac
}
# Fresh install or upgrade? Decided BEFORE anything is written, because every marker this could
# key off is one this run is about to create.
#
# TWO signals, both required to call a tree already-adopted, because either alone misfires on a
# real first-time adopter. `amh.conf` is a plausible name for an unrelated config file somebody
# already had; `scripts/ladder.sh` alone could be a coincidence in a repo with its own ladder.
# Together they mean the harness has been installed here before. A misfire costs a first-time
# adopter the brief with no diagnostic, so it is worth two tests.
FRESH=1
[ -e "$TARGET/amh.conf" ] && [ -e "$TARGET/scripts/ladder.sh" ] && FRESH=0
# Paths this run installed or kept, for the leftover-placeholder report. Scanning the
# whole target instead would report every Jinja, Handlebars or Go template in the
# adopter's repo — and, run against a harness checkout, its own template tree.
INSTALLED=()

substitute() { # <src> -> stdout, with the init-time placeholders filled in
	sed "${SED_ARGS[@]}" -- "$1"
}

install_file() { # <src> <dest-relative> <overwrite|keep> <mode>
	local src=$1 rel=$2 policy=$3 mode=$4 dest="$TARGET/$2"
	INSTALLED+=("$rel")
	if [ -e "$dest" ] && [ "$policy" = keep ]; then
		# CONTENT is the adopter's; the EXECUTE BIT is not a judgement call. The ladder
		# refuses to run a verification set it cannot execute, so a seed script that lost
		# its mode makes the ladder red — and "re-run init" is the documented recovery,
		# which used to return here without repairing anything.
		if [ "$mode" = 755 ] && [ ! -x "$dest" ] && [ "$DRY_RUN" = 0 ]; then
			chmod "$mode" -- "$dest" || die "cannot chmod $rel"
			printf '   keep   %s (yours — content untouched, execute bit restored)\n' "$rel"
			KEPT=$((KEPT + 1))
			return 0
		fi
		printf '   keep   %s (yours — not overwritten)\n' "$rel"
		KEPT=$((KEPT + 1))
		return 0
	fi
	local verb=write
	[ -e "$dest" ] && verb=update
	if [ "$DRY_RUN" = 1 ]; then
		printf '   %-6s %s (dry run)\n' "$verb" "$rel"
		WROTE=$((WROTE + 1))
		return 0
	fi
	mkdir -p -- "$(dirname -- "$dest")" || die "cannot create $(dirname -- "$rel")"
	# Write to a temporary and rename, because `> "$dest"` truncates BEFORE sed runs: a
	# substitution failure left a zero-byte file and then reported "cannot write", which
	# was false — it had already emptied it. On a re-run that turns an adopter's rail into
	# an empty file. `mv` within the same directory is atomic.
	substitute "$src" >"$dest.amh-init.tmp" || {
		rm -f -- "$dest.amh-init.tmp"
		die "cannot write $rel"
	}
	chmod "$mode" -- "$dest.amh-init.tmp" || die "cannot chmod $rel"
	mv -f -- "$dest.amh-init.tmp" "$dest" || die "cannot install $rel"
	printf '   %-6s %s\n' "$verb" "$rel"
	WROTE=$((WROTE + 1))
}

printf 'amh-init: AMH %s (%s profile) -> %s\n\n' "$AMH_VERSION" "$PROFILE" "$TARGET"
printf ' shipped scripts (overwritten — this is the upgrade path)\n'
for src in "$TPL"/scripts/*.sh; do
	install_file "$src" "scripts/$(basename -- "$src")" overwrite 755
done

printf '\n yours (written only when absent) — %s profile\n' "$PROFILE"
# The seed scripts are executable for the same reason the shipped ones are: the ladder
# refuses to run a verification set it cannot execute, so a seed arriving as 0644 makes an
# adopter's very first full run red for a reason that has nothing to do with their repo.
while IFS= read -r src; do
	rel=${src#"$TPL"/seed/}
	seed_min_rank "$rel"
	# PRESENCE OUTRANKS THE PROFILE, and the order of these two tests is the whole point.
	# docs/UPGRADING.md documents a bare `amh-init.sh <target>` as the upgrade path, and the
	# default is now `light` — so gating first would tell a 1.8.0 adopter who has a runbook and
	# a ledger that those files are "not in the light profile — add it with --profile
	# standard", print a tally counting them as declined, and, silently, drop them from the
	# unfilled-placeholder report while their real {{...}} slots sat there. A file that exists
	# is the adopter's, whatever profile this run names: it falls through to the keep path
	# below, which says so and counts it.
	if [ "$SEED_RANK" -gt "$PROFILE_RANK" ] && [ ! -e "$TARGET/$rel" ]; then
		# Named, not silently omitted: an adopter must be able to see what they did not get
		# and the command that would give it to them. A file that is simply absent teaches
		# nothing, and the profile is recorded nowhere else in their tree.
		needs=full
		[ "$SEED_RANK" = 2 ] && needs=standard
		printf '   skip   %s (not in the %s profile — add it with --profile %s)\n' \
			"$rel" "$PROFILE" "$needs"
		DECLINED=$((DECLINED + 1))
		continue
	fi
	case $rel in
	scripts/*) install_file "$src" "$rel" keep 755 ;;
	*) install_file "$src" "$rel" keep 644 ;;
	esac
done < <(find "$TPL/seed" -type f | sort)

install_file "$TPL/amh.conf.example" amh.conf keep 644
install_file "$TPL/configs/ci.yml" .github/workflows/ci.yml keep 644
install_file "$TPL/configs/claude-settings.json" .claude/settings.json keep 644

# The adoption brief: the work this tool cannot do, addressed to the agent that can.
#
# FRESH INSTALLS ONLY, and that condition is the whole design. The brief ends by telling the
# agent to delete it, so `keep` alone would resurrect it on the next upgrade run — handing a
# finished adopter a document telling them to adopt a harness they have run for a year.
#
# `keep` is still the policy rather than `overwrite`, and it is NOT redundant with the gate
# even though a re-run can never be fresh: an adopter who ran init, kept notes in the brief,
# and then deleted `amh.conf` or `scripts/ladder.sh` reaches this line fresh again, and their
# annotated brief survives. The narrow case is the point — the wide one is handled above.
if [ "$FRESH" = 1 ]; then
	install_file "$TPL/AMH-ADOPT.md" AMH-ADOPT.md keep 644
else
	# Counted as a keep, not printed outside the tally: a line the summary does not account
	# for reads as something that went wrong.
	printf '   skip   %s\n' 'AMH-ADOPT.md (already adopted — the one-time brief is not re-issued)'
	KEPT=$((KEPT + 1))
fi

printf '\n %d written, %d kept, %d not in the %s profile\n' "$WROTE" "$KEPT" "$DECLINED" "$PROFILE"

# --- what is left for a human ----------------------------------------------
#
# Reported, never guessed. The remaining placeholders are the repo's invariants, test
# commands and module map: a tool that invented them would hand back a constitution that
# looks complete and asserts nothing, which is the one outcome worse than a blank one.
printf '\n Left for you:\n'
if [ "$DRY_RUN" = 1 ]; then
	printf '   (dry run — nothing written, so nothing to fill in yet)\n'
	exit 0
fi
# Mirrors scripts/guards/placeholder-integrity.sh: {{PLACEHOLDER}} and {{X}} are the
# metasyntactic words prose uses for a slot in general, and the guard exempts them. A
# report that lists them tells an adopter to fill in something the guard says is not a
# slot, and the first thing they learn about the harness is that it contradicts itself.
remaining=''
for rel in ${INSTALLED[@]+"${INSTALLED[@]}"}; do
	f="$TARGET/$rel"
	[ -f "$f" ] || continue
	if grep -ohE '\{\{[A-Z_][A-Z0-9_]*\}\}' "$f" 2>/dev/null |
		grep -qvE '^\{\{(PLACEHOLDER|X)\}\}$'; then
		remaining="$remaining$rel$NL"
	fi
done
remaining=$(printf '%s' "$remaining" | sort -u)
if [ -n "$remaining" ]; then
	# Indented through sed, not `printf '   %s\n'`: the list is one multi-line string, and
	# printf's format is re-applied per ARGUMENT, not per line, so only the first file
	# would have been indented.
	printf '%s\n' "$remaining" | sed 's/^/   /'
	# Says where the doc is FROM THE ADOPTER'S POSITION — their tree has no harness/ — and
	# does not claim a guard they were not given. The placeholder guard is repo-local to the
	# harness; a fresh instantiation ships no guards at all, so a leftover placeholder fails
	# nothing in the tree this text is being printed about. Claiming otherwise is the reason
	# nobody would then check by hand.
	printf '\n   Search for {{ and fill each one in. Each slot is documented in\n'
	printf '   harness/PLACEHOLDERS.md in THIS checkout (%s).\n' "$ROOT"
	printf '   Nothing in your repo checks these — grep for {{ before you call it done.\n'
else
	printf '   no placeholders remain\n'
fi
printf '\n   Then: scripts/ladder.sh\n'
