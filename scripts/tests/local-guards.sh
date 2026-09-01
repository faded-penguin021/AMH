#!/usr/bin/env bash
# Fixture suite for this repo's OWN guards (scripts/guards/*.sh).
#
# The shipped fixture suite (scripts/test-ladder-guards.sh) is byte-compared against
# its template, so repo-local fixtures cannot live there — putting them there would
# contaminate the repo-agnostic artifact, which is the thing copy-drift.sh exists to
# prevent. They live here instead, run from scripts/verify.sh, which is the ladder's
# repo-owned extension point.
#
# Until this file existed, every repo-local guard shipped untested while the
# constitution demanded a fixture for each — the rule was unsatisfiable as written.
#
# Method: snapshot the working tree into a throwaway git repo, break exactly one
# thing, and assert the guard's verdict. Never mutate the real tree — a suite that
# leaves the repo dirty when interrupted is worse than no suite.

set -uo pipefail

sed_in_place() { # <sed-expression> <file>
	local expression=$1 file=$2 tmp="${2}.amh-sed.$$"
	sed "$expression" "$file" >"$tmp" || {
		rm -f "$tmp"
		return 1
	}
	cat "$tmp" >"$file" && rm -f "$tmp"
}

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

export GIT_AUTHOR_NAME=amh-test GIT_AUTHOR_EMAIL=amh@test.invalid
export GIT_COMMITTER_NAME=amh-test GIT_COMMITTER_EMAIL=amh@test.invalid

PASSED=0
FAILED=0
EXPECT_PATH_PREFIX=

snapshot() { # snapshot <name> -> prints the path
	local d="$WORK/$1"
	mkdir -p "$d"
	(cd "$ROOT" && git ls-files -co --exclude-standard -z | tar -cf - --null -T -) |
		(cd "$d" && tar -xf -)
	(
		cd "$d" || exit 1
		git init -q .
		git add -A
		git commit -qm snapshot
	)
	printf '%s' "$d"
}

# Three verdicts, matching the ladder's repo-local contract: pass is exit 0, warn is exit 2
# whose output BEGINS with `WARN ` (anything else at exit 2 is a broken guard, which the
# ladder reports as a failure and so does this helper), and fail is any other non-zero exit.
# `fail` deliberately does not accept a marked warning: the ladder stays green on one, so a
# fixture that took it for a failure would assert the opposite of what an adopter sees.
is_marked_warn() { # is_marked_warn <rc> <output>
	[ "$1" -eq 2 ] && [ "$2" != "${2#WARN }" ]
}

expect() { # expect <pass|fail|warn> <name> <dir> <guard> [message-substring]
	local want=$1 name=$2 dir=$3 guard=$4 want_msg=${5:-}
	local out rc
	# EXPECT_PATH_PREFIX prepends one directory to PATH for a single case. It is how a guard's
	# reaction to a TOOL that misbehaves can be tested at all: a tree can be posed into yielding
	# an EMPTY listing, never a truncated one, so the shim has to sit on PATH. Empty for every
	# other case, and `${x:+}` keeps that safe under `set -u`.
	# shellcheck disable=SC2086  # $guard may carry arguments, e.g. "x.sh --tag v1"
	out=$(cd "$dir" && PATH="${EXPECT_PATH_PREFIX:+$EXPECT_PATH_PREFIX:}$PATH" bash scripts/guards/$guard 2>&1)
	rc=$?
	if [ "$want" = pass ] && [ "$rc" -ne 0 ]; then
		FAILED=$((FAILED + 1))
		printf '  FAIL %s — expected pass, got %d\n%s\n' "$name" "$rc" "$out" >&2
	elif [ "$want" = warn ] && ! is_marked_warn "$rc" "$out"; then
		FAILED=$((FAILED + 1))
		printf '  FAIL %s — expected a WARN-marked exit 2, got %d\n%s\n' "$name" "$rc" "$out" >&2
	elif [ "$want" = fail ] && { [ "$rc" -eq 0 ] || is_marked_warn "$rc" "$out"; }; then
		FAILED=$((FAILED + 1))
		printf '  FAIL %s — expected failure, guard did not fail (exit %d)\n%s\n' "$name" "$rc" "$out" >&2
	elif [ -n "$want_msg" ] && ! printf '%s' "$out" | grep -qF "$want_msg"; then
		FAILED=$((FAILED + 1))
		printf '  FAIL %s — verdict right but message never mentioned %s\n%s\n' "$name" "$want_msg" "$out" >&2
	else
		PASSED=$((PASSED + 1))
	fi
}

printf 'repo-local guard fixtures\n'

base=$(snapshot base)
expect pass "copy-drift: clean tree" "$base" copy-drift.sh
expect pass "dist-drift: clean tree" "$base" dist-drift.sh
expect pass "placeholder-integrity: clean tree" "$base" placeholder-integrity.sh
expect pass "version-lockstep: clean tree" "$base" version-lockstep.sh
expect pass "path-refs: clean tree" "$base" path-refs.sh
expect pass "manifest-drift: clean tree" "$base" manifest-drift.sh
expect pass "adapter-set: clean tree" "$base" adapter-set.sh
expect pass "doc-navigation: clean tree" "$base" doc-navigation.sh
expect pass "config-schema: clean tree" "$base" config-schema.sh
expect pass "ledger-append-only: clean tree" "$base" ledger-append-only.sh
expect pass "shipped-citations: clean tree" "$base" shipped-citations.sh
expect pass "bearer-fixture-construction: current template" "$base" bearer-fixture-construction.sh

# --- bearer-fixture-construction --------------------------------------------
d=$(snapshot bearer_fixture_plain_alnum)
# shellcheck disable=SC2016  # mutate literal command substitutions in the fixture source.
sed_in_place 's/$(rand_upper 8)$(rand_alnum 32)/$(rand_alnum 40)/' \
	"$d/harness/templates/scripts/redact.sh"
expect fail "bearer-fixture-construction: unrestricted token cannot replace the guaranteed prefix" "$d" \
	bearer-fixture-construction.sh "D-024's fixture satisfied the production predicate only probabilistically"

d=$(snapshot bearer_fixture_reordered)
# shellcheck disable=SC2016  # mutate literal command substitutions in the fixture source.
sed_in_place 's/$(rand_upper 8)$(rand_alnum 32)/$(rand_alnum 32)$(rand_upper 8)/' \
	"$d/harness/templates/scripts/redact.sh"
expect fail "bearer-fixture-construction: guaranteed prefix cannot follow the unrestricted tail" "$d" \
	bearer-fixture-construction.sh "prefix-before-tail construction"

d=$(snapshot bearer_fixture_decoy)
# shellcheck disable=SC2016  # mutate literal command substitutions in the fixture source.
sed_in_place 's/"$(rand_upper 8)$(rand_alnum 32)")"/"$(rand_alnum 40)")" "$(rand_upper 8)$(rand_alnum 32)"/' \
	"$d/harness/templates/scripts/redact.sh"
expect fail "bearer-fixture-construction: a surplus argument cannot decoy the guard" "$d" \
	bearer-fixture-construction.sh "prefix-before-tail construction"

d=$(snapshot bearer_fixture_absent)
sed_in_place '/st_redacted bearer_header/d' "$d/harness/templates/scripts/redact.sh"
expect fail "bearer-fixture-construction: missing fixture checks nothing" "$d" \
	bearer-fixture-construction.sh "checked NOTHING"

d=$(snapshot bearer_fixture_duplicated)
duplicate=$(sed -n '/st_redacted bearer_header/p' "$d/harness/templates/scripts/redact.sh")
printf '%s\n' "$duplicate" >>"$d/harness/templates/scripts/redact.sh"
expect fail "bearer-fixture-construction: duplicate fixture is not accepted by first match" "$d" \
	bearer-fixture-construction.sh "expected exactly one"


# --- ledger-append-only -------------------------------------------------------
d=$(snapshot ledger_append_only_delete)
awk 'BEGIN { drop = 0 } /^- D-001 / { drop = 1 } /^- D-002 / { drop = 0 } !drop { print }' \
	"$d/docs/LEDGER.md" >"$d/docs/LEDGER.md.new" && mv "$d/docs/LEDGER.md.new" "$d/docs/LEDGER.md"
expect fail "ledger-append-only: a committed row cannot be deleted" "$d" \
	ledger-append-only.sh "D-001 existed at HEAD but is missing"

d=$(snapshot ledger_append_only_staged_delete)
awk 'BEGIN { drop = 0 } /^- D-001 / { drop = 1 } /^- D-002 / { drop = 0 } !drop { print }' \
	"$d/docs/LEDGER.md" >"$d/docs/LEDGER.md.new" && mv "$d/docs/LEDGER.md.new" "$d/docs/LEDGER.md"
(cd "$d" && git add docs/LEDGER.md)
expect fail "ledger-append-only: a staged committed-row deletion cannot bypass the guard" "$d" \
	ledger-append-only.sh "D-001 existed at HEAD but is missing"

d=$(snapshot ledger_append_only_rewrite)
sed '0,/This repository is both the harness/s//This repository WAS both the harness/' \
	"$d/docs/LEDGER.md" >"$d/docs/LEDGER.md.new" && mv "$d/docs/LEDGER.md.new" "$d/docs/LEDGER.md"
expect fail "ledger-append-only: a committed row cannot be rewritten" "$d" \
	ledger-append-only.sh "D-001 existed at HEAD and was edited"

d=$(snapshot ledger_append_only_superseded)
awk '/^- D-002 / && !done { print "  Superseded by DB-999."; done = 1 } { print }' \
	"$d/docs/LEDGER.md" >"$d/docs/LEDGER.md.new" && mv "$d/docs/LEDGER.md.new" "$d/docs/LEDGER.md"
expect pass "ledger-append-only: strict superseded pointer is allowed" "$d" ledger-append-only.sh

# The second pointer verb (owner, 2026-08-25). `Corrected by` is for the DB-014 shape: one
# detail stale under a principle that still stands, where supersession would misdirect the
# reader. The guard checks the FORM only — these fixtures pin the form, and nothing pins the
# choice of verb, which is reviewer territory by construction.
d=$(snapshot ledger_append_only_corrected)
awk '/^- D-002 / && !done { print "  Corrected by DB-999."; done = 1 } { print }' \
	"$d/docs/LEDGER.md" >"$d/docs/LEDGER.md.new" && mv "$d/docs/LEDGER.md.new" "$d/docs/LEDGER.md"
expect pass "ledger-append-only: strict corrected pointer is allowed" "$d" ledger-append-only.sh

d=$(snapshot ledger_append_only_corrected_and_cited)
awk '/^- D-004: / { sub(":", " [cited]:") } /^- D-005/ { print "  Corrected by DB-999." } { print }' \
	"$d/docs/LEDGER.md" >"$d/docs/LEDGER.md.new" && mv "$d/docs/LEDGER.md.new" "$d/docs/LEDGER.md"
expect pass "ledger-append-only: cited marker and strict corrected pointer may be added together" "$d" ledger-append-only.sh

d=$(snapshot ledger_append_only_corrected_not_last)
awk '/^- D-002 / && !done { print "  Corrected by DB-999."; print "  trailing prose after the pointer."; done = 1 } { print }' \
	"$d/docs/LEDGER.md" >"$d/docs/LEDGER.md.new" && mv "$d/docs/LEDGER.md.new" "$d/docs/LEDGER.md"
expect fail "ledger-append-only: a corrected pointer that is not the final line is a rewrite" "$d" \
	ledger-append-only.sh "existed at HEAD and was edited"

d=$(snapshot ledger_append_only_corrected_plus_prose)
awk '/^- D-002 / && !done { print "  Corrected by DB-999."; done = 1 } { sub(/harness/, "HARNESS"); print }' \
	"$d/docs/LEDGER.md" >"$d/docs/LEDGER.md.new" && mv "$d/docs/LEDGER.md.new" "$d/docs/LEDGER.md"
expect fail "ledger-append-only: a corrected pointer cannot smuggle a prose edit alongside it" "$d" \
	ledger-append-only.sh "existed at HEAD and was edited"

# The one-pointer limit, at the shape that used to evade it: the base row's pointer is not its
# last line, so a `tail -n 1` check saw no pointer and let the row gain a second one.
d=$(snapshot ledger_append_only_second_pointer_midrow)
awk '/^- D-002 / && !done { print "  Superseded by DB-998."; print "  prose keeping the pointer off the end."; done = 1 } { print }' \
	"$d/docs/LEDGER.md" >"$d/docs/LEDGER.md.new" && mv "$d/docs/LEDGER.md.new" "$d/docs/LEDGER.md"
(cd "$d" && git add -A && git commit -qm "row whose pointer is not last")
# Same anchor as above on purpose: both appends land at the end of the SAME row, which is what
# makes this a second pointer rather than a first one on a neighbour.
awk '/^- D-002 / && !done { print "  Corrected by DB-999."; done = 1 } { print }' \
	"$d/docs/LEDGER.md" >"$d/docs/LEDGER.md.new" && mv "$d/docs/LEDGER.md.new" "$d/docs/LEDGER.md"
expect fail "ledger-append-only: a row already carrying a mid-row pointer cannot gain a second" "$d" \
	ledger-append-only.sh "existed at HEAD and was edited"

d=$(snapshot ledger_append_only_corrected_malformed)
awk '/^- D-002 / && !done { print "  Corrected by DB-999"; done = 1 } { print }' \
	"$d/docs/LEDGER.md" >"$d/docs/LEDGER.md.new" && mv "$d/docs/LEDGER.md.new" "$d/docs/LEDGER.md"
expect fail "ledger-append-only: a corrected pointer missing its period is a rewrite" "$d" \
	ledger-append-only.sh "existed at HEAD and was edited"

d=$(snapshot ledger_append_only_cited)
sed '0,/^- D-004: /s//- D-004 [cited]: /' \
	"$d/docs/LEDGER.md" >"$d/docs/LEDGER.md.new" && mv "$d/docs/LEDGER.md.new" "$d/docs/LEDGER.md"
expect pass "ledger-append-only: cited marker addition is allowed" "$d" ledger-append-only.sh

d=$(snapshot ledger_append_only_cited_and_superseded)
awk '/^- D-004: / { sub(":", " [cited]:") } /^- D-005/ { print "  Superseded by DB-999." } { print }' \
	"$d/docs/LEDGER.md" >"$d/docs/LEDGER.md.new" && mv "$d/docs/LEDGER.md.new" "$d/docs/LEDGER.md"
expect pass "ledger-append-only: cited marker and strict superseded pointer may be added together" "$d" ledger-append-only.sh

d=$(snapshot ledger_append_only_cited_after_committed_supersession)
awk '/^- D-005/ { print "  Superseded by DB-998." } { print }' \
	"$d/docs/LEDGER.md" >"$d/docs/LEDGER.md.new" && mv "$d/docs/LEDGER.md.new" "$d/docs/LEDGER.md"
(cd "$d" && git add docs/LEDGER.md && git commit -qm superseded-history)
sed '0,/^- D-004: /s//- D-004 [cited]: /' \
	"$d/docs/LEDGER.md" >"$d/docs/LEDGER.md.new" && mv "$d/docs/LEDGER.md.new" "$d/docs/LEDGER.md"
expect pass "ledger-append-only: cited marker may be added while preserving a committed pointer" "$d" ledger-append-only.sh

d=$(snapshot ledger_append_only_second_supersession)
awk '/^- D-005/ { print "  Superseded by DB-998." } { print }' \
	"$d/docs/LEDGER.md" >"$d/docs/LEDGER.md.new" && mv "$d/docs/LEDGER.md.new" "$d/docs/LEDGER.md"
(cd "$d" && git add docs/LEDGER.md && git commit -qm superseded-history)
awk '/^- D-005/ { print "  Superseded by DB-999." } { print }' \
	"$d/docs/LEDGER.md" >"$d/docs/LEDGER.md.new" && mv "$d/docs/LEDGER.md.new" "$d/docs/LEDGER.md"
expect fail "ledger-append-only: a committed supersession pointer cannot gain a second pointer" "$d" \
	ledger-append-only.sh "D-004 existed at HEAD and was edited"

d=$(snapshot ledger_append_only_cited_removal)
sed '0,/^- D-001 \[cited\]: /s//- D-001: /' \
	"$d/docs/LEDGER.md" >"$d/docs/LEDGER.md.new" && mv "$d/docs/LEDGER.md.new" "$d/docs/LEDGER.md"
expect fail "ledger-append-only: cited marker removal is still a rewrite" "$d" \
	ledger-append-only.sh "D-001 existed at HEAD and was edited"

d=$(snapshot ledger_append_only_new_row_draft)
cat >>"$d/docs/LEDGER_C.md" <<'ROW'
- DC-999: **Draft row can be rewritten before commit.** First draft.
ROW
expect pass "ledger-append-only: new uncommitted rows are draft-editable" "$d" ledger-append-only.sh


d=$(snapshot ledger_append_only_new_row_under_cap)
sed_in_place 's/^LEDGER_ROW_CHAR_CAP=.*/LEDGER_ROW_CHAR_CAP=120/' "$d/amh.conf"
cat >>"$d/docs/LEDGER_C.md" <<'ROW'
- DC-999: **Short new row passes.** Small enough.
ROW
expect pass "ledger-append-only: a concise new row under the byte-counted character cap passes" "$d" ledger-append-only.sh

d=$(snapshot ledger_append_only_new_row_over_cap)
sed_in_place 's/^LEDGER_ROW_CHAR_CAP=.*/LEDGER_ROW_CHAR_CAP=80/' "$d/amh.conf"
python3 - "$d/docs/LEDGER_C.md" <<'PYROW'
from pathlib import Path
import sys
Path(sys.argv[1]).write_text(Path(sys.argv[1]).read_text() + "- DC-999: **Long new row fails.** " + ("x" * 120) + "\n")
PYROW
expect fail "ledger-append-only: a new row over the byte-counted character cap fails" "$d" \
	ledger-append-only.sh "over LEDGER_ROW_CHAR_CAP=80"

d=$(snapshot ledger_append_only_committed_over_cap_exempt)
sed_in_place 's/^LEDGER_ROW_CHAR_CAP=.*/LEDGER_ROW_CHAR_CAP=80/' "$d/amh.conf"
python3 - "$d/docs/LEDGER_C.md" <<'PYROW'
from pathlib import Path
import sys
Path(sys.argv[1]).write_text(Path(sys.argv[1]).read_text() + "- DC-999: **Committed long row is historical.** " + ("x" * 120) + "\n")
PYROW
(cd "$d" && git add amh.conf docs/LEDGER_C.md && git commit -qm over-cap-history)
expect pass "ledger-append-only: an already committed over-cap row is historical and exempt" "$d" ledger-append-only.sh

d=$(snapshot ledger_append_only_superseded_over_cap_existing_row)
sed_in_place 's/^LEDGER_ROW_CHAR_CAP=.*/LEDGER_ROW_CHAR_CAP=10/' "$d/amh.conf"
awk '/^- D-002 / && !done { print "  Superseded by DB-999."; done = 1 } { print }' \
	"$d/docs/LEDGER.md" >"$d/docs/LEDGER.md.new" && mv "$d/docs/LEDGER.md.new" "$d/docs/LEDGER.md"
expect pass "ledger-append-only: sanctioned supersession metadata ignores the new-row cap" "$d" ledger-append-only.sh

d=$(snapshot ledger_append_only_cited_over_cap_existing_row)
sed_in_place 's/^LEDGER_ROW_CHAR_CAP=.*/LEDGER_ROW_CHAR_CAP=10/' "$d/amh.conf"
sed '0,/^- D-004: /s//- D-004 [cited]: /' \
	"$d/docs/LEDGER.md" >"$d/docs/LEDGER.md.new" && mv "$d/docs/LEDGER.md.new" "$d/docs/LEDGER.md"
expect pass "ledger-append-only: sanctioned cited metadata ignores the new-row cap" "$d" ledger-append-only.sh

# A new row filed outside the live volume: warn, never fail. DB-015 reached the default
# branch this way, and its citation dangles by the prefix rule while grep still finds it.
d=$(snapshot ledger_append_only_new_row_wrong_volume)
cat >>"$d/docs/LEDGER.md" <<'ROW'
- D-999: **New row in a closed volume.** It resolves nowhere its prefix promises.
ROW
expect warn "ledger-append-only: a new row outside the live volume warns" "$d" \
	ledger-append-only.sh "live volume is docs/LEDGER_C.md"

# ...and the live volume itself is silent, or the warning would fire on every ordinary
# append and be worth nothing inside a month.
d=$(snapshot ledger_append_only_new_row_live_volume)
cat >>"$d/docs/LEDGER_C.md" <<'ROW'
- DC-999: **New row in the live volume.** Exactly where it belongs.
ROW
expect pass "ledger-append-only: a new row in the live volume is silent" "$d" ledger-append-only.sh

# The other half of the DB-015 class, and the half DB-015 itself is: the row sits in the live
# volume, so the check above is silent, but its prefix names a different file — which is where
# a reader following the preamble's rule will look for it, and not find it.
d=$(snapshot ledger_append_only_new_row_wrong_prefix)
cat >>"$d/docs/LEDGER_C.md" <<'ROW'
- D-999: **Live volume, wrong prefix.** A D- id does not resolve in volume C.
ROW
expect warn "ledger-append-only: a new row whose prefix names another volume warns" "$d" \
	ledger-append-only.sh "its prefix names docs/LEDGER.md"

# The metadata transitions the owner asked to keep working: an existing row in a CLOSED
# volume may still gain `[cited]` and a supersession or correction pointer without tripping the warning,
# because neither makes it a new row.
d=$(snapshot ledger_append_only_closed_volume_metadata)
sed '0,/^- D-004: /s//- D-004 [cited]: /' \
	"$d/docs/LEDGER.md" >"$d/docs/LEDGER.md.new" && mv "$d/docs/LEDGER.md.new" "$d/docs/LEDGER.md"
awk '/^- D-002 / && !done { print "  Superseded by DB-014."; done = 1 } { print }' \
	"$d/docs/LEDGER.md" >"$d/docs/LEDGER.md.new" && mv "$d/docs/LEDGER.md.new" "$d/docs/LEDGER.md"
expect pass "ledger-append-only: cited and supersession edits in a closed volume stay silent" "$d" \
	ledger-append-only.sh

# --- shipped-citations --------------------------------------------------------
# A real ledger citation in something we ship is green everywhere in THIS repo — the row
# exists, the citation rung asks for its [cited] marker, and the marker gets added — while
# handing an adopter a promise their ledger cannot keep. That is the whole reason this guard
# exists, and the reason no other rung can stand in for it.
d=$(snapshot shipped_citations_real_citation)
printf '# see D-020 for why\n' >>"$d/harness/templates/scripts/ladder.sh"
expect fail "shipped-citations: a real citation in a shipped rail fails" "$d" \
	shipped-citations.sh "cites D-020"

# Multi-letter volumes must be caught here too, or an id the adopter's citation rung would
# resolve slips through the guard that is supposed to stop it leaving the repo.
d=$(snapshot shipped_citations_multiletter)
printf '# see DA-001 for why\n' >>"$d/harness/templates/scripts/command-guard.sh"
expect fail "shipped-citations: a multi-letter citation is caught too" "$d" \
	shipped-citations.sh "cites DA-001"

# Scope is by DESTINATION, not by extension or by one directory. All three of these land in a
# path the adopter's citation scan reads by default, and the first version of this guard saw
# only the first: a citation in the other two turned a fresh adopter's very first ladder run
# red while every rung here stayed green.
d=$(snapshot shipped_citations_seed_script)
printf '# see D-020 for why\n' >>"$d/harness/templates/seed/scripts/verify.sh"
expect fail "shipped-citations: a seed script installed into scripts/ is in scope" "$d" \
	shipped-citations.sh "cites D-020"

d=$(snapshot shipped_citations_ci_workflow)
printf '# see D-020 for why\n' >>"$d/harness/templates/configs/ci.yml"
expect fail "shipped-citations: the CI workflow installed into .github/ is in scope" "$d" \
	shipped-citations.sh "cites D-020"

d=$(snapshot shipped_citations_non_sh)
printf '# see D-020 for why\n' >>"$d/harness/templates/scripts/MANIFEST.sha256"
expect fail "shipped-citations: a shipped file that is not a *.sh is in scope" "$d" \
	shipped-citations.sh "cites D-020"

# A token that matches the citation pattern but names no row of ours is a different defect
# with a different fix. Telling its author to write it hyphen-free would be nonsense; the
# recorded remedy is a rename or a CITATION_EXCLUDE entry, never a wider pattern.
d=$(snapshot shipped_citations_collision)
printf '# a DEBUG-2 token, not a citation\n' >>"$d/harness/templates/scripts/ladder.sh"
expect fail "shipped-citations: a non-ledger token gets the rename-or-exclude remedy" "$d" \
	shipped-citations.sh "rename the token or add a CITATION_EXCLUDE entry"

# The unread form is the documented fix, so it must actually pass — a guard that rejected the
# alternative it recommends would leave no legal way to reference the reasoning at all.
d=$(snapshot shipped_citations_unread_form)
printf '# see AMH ledger row D020 for why\n' >>"$d/harness/templates/scripts/ladder.sh"
expect pass "shipped-citations: the hyphen-free form is accepted" "$d" shipped-citations.sh

# The shipped fixture suite is exempt on purpose: its ids are fixture material and the
# CITATION_EXCLUDE default in the shipped amh.conf.example keeps that file out of the citation
# scan of any adopter whose config carries the key.
d=$(snapshot shipped_citations_fixture_suite_exempt)
printf '# see DA-001 for why\n' >>"$d/harness/templates/scripts/test-ladder-guards.sh"
expect pass "shipped-citations: the fixture suite's own ids are exempt" "$d" shipped-citations.sh

# An entry the glob matched but nothing can read is named, never skipped: the totals below
# make an affirmative claim about what was checked, and a dropped file makes that claim false.
d=$(snapshot shipped_citations_unreadable)
ln -s /nonexistent "$d/harness/templates/scripts/dangling.sh"
expect fail "shipped-citations: an unreadable shipped file is named, not dropped" "$d" \
	shipped-citations.sh "could not check it"

# A shipped file grep cannot read as text is refused for the same reason, and this one needs no
# shim to reproduce: on grep >= 3.5 — the version on CI — a binary file exits 0 with its notice
# on stderr and an EMPTY stdout, so it used to be counted as scanned and reported as citing
# nothing. `-I` would have made that permanent rather than fixed it (AMH ledger row DC032).
d=$(snapshot shipped_citations_binary)
printf '#!/usr/bin/env bash\000 DB-999 \000\n' >"$d/harness/templates/scripts/blob.sh"
expect fail "shipped-citations: a binary shipped file is refused, not counted as scanned" "$d" \
	shipped-citations.sh "did NOT scan it"

# ...and an EMPTY shipped file is NOT that case: it was read successfully and cites nothing, so
# the binary arm above must not swallow it. `grep -qI .` answers 1 for both, which is why the
# arm tests `-s` first.
d=$(snapshot shipped_citations_empty)
: >"$d/harness/templates/scripts/empty.sh"
expect pass "shipped-citations: an empty shipped file is scanned, not called binary" "$d" \
	shipped-citations.sh

# Scanning nothing is a failure, not a sweep — and the two empty states have different fixes,
# so they say different things.
d=$(snapshot shipped_citations_scanned_nothing)
rm -rf "$d/harness/templates/scripts" "$d/harness/templates/seed/scripts" \
	"$d/harness/templates/configs/ci.yml"
expect fail "shipped-citations: matching no shipped file fails rather than passing" "$d" \
	shipped-citations.sh "matched no file"

d=$(snapshot shipped_citations_all_excluded)
rm -rf "$d/harness/templates/seed/scripts" "$d/harness/templates/configs/ci.yml"
find "$d/harness/templates/scripts" -type f ! -name test-ladder-guards.sh -delete
expect fail "shipped-citations: an entirely excluded shipped set fails rather than passing" "$d" \
	shipped-citations.sh "were excluded or unreadable"

# --- config-schema ------------------------------------------------------------
d=$(snapshot config_schema_missing)
grep -v '^PLAN_DIR=' "$d/amh.conf" >"$d/t" && mv "$d/t" "$d/amh.conf"
expect fail "config-schema: a template key absent from amh.conf" "$d" config-schema.sh "PLAN_DIR"

d=$(snapshot config_schema_new_template_key)
printf 'BRAND_NEW_KEY=x\n' >>"$d/harness/templates/amh.conf.example"
expect fail "config-schema: a key added to the template but not the instance" "$d" \
	config-schema.sh "BRAND_NEW_KEY"

# Extras are legal BY DESIGN: AUTHOR_EMAIL_ALLOW is opt-in and deliberately absent from
# the example. A guard that failed on extras would fail this repo for using a feature
# correctly, so the one-directional shape is pinned here rather than left to the header.
d=$(snapshot config_schema_extra_key)
printf 'AN_EXTRA_LOCAL_KEY=1\n' >>"$d/amh.conf"
expect pass "config-schema: extra instance keys are legal" "$d" config-schema.sh

# A key named only in the example's prose or comments is documentation, not contract.
d=$(snapshot config_schema_comment_key)
printf '# COMMENTED_OUT_KEY=x\n' >>"$d/harness/templates/amh.conf.example"
expect pass "config-schema: a commented key in the example is not a requirement" "$d" config-schema.sh

d=$(snapshot doc_navigation_missing)
sed_in_place 's/^## Acceptance ladder$/## Verification ladder/' "$d/docs/RUNBOOK.md"
expect fail "doc-navigation: a binding heading was renamed" "$d" doc-navigation.sh "missing navigation heading"

d=$(snapshot doc_navigation_duplicate)
printf '\n## Acceptance ladder\n' >>"$d/docs/RUNBOOK.md"
expect fail "doc-navigation: a binding heading was duplicated" "$d" doc-navigation.sh "duplicate navigation heading"

d=$(snapshot doc_navigation_pointer_missing)
sed_in_place 's/^- Verification and locally unverifiable coverage:/- Local verification:/' "$d/AGENTS.md"
expect fail "doc-navigation: a binding constitution pointer was renamed" "$d" doc-navigation.sh "missing navigation pointer"

d=$(snapshot doc_navigation_session_pointer_missing)
sed_in_place '/^- Session execution, checkpoints, recovery, and owner forks:/d' "$d/AGENTS.md"
sed_in_place 's/Follow \*\*Session discipline\*\* every/Follow the runbook every/' "$d/AGENTS.md"
expect fail "doc-navigation: Session discipline routing was removed" "$d" doc-navigation.sh "missing navigation pointer"

# The state file's rule preambles moved into the runbook and left pointers behind. DB-029
# recorded the first such pointer as prose only; these two fixtures are why the second and
# third are not. Deleting either line is an edit the size and structure rungs cannot see.
d=$(snapshot doc_navigation_state_pointer_missing)
sed_in_place '/Working-memory compression\*\*, and they bind whether or not you follow/d' "$d/docs/STATE.md"
expect fail "doc-navigation: the state file's compression-rule pointer was deleted" "$d" doc-navigation.sh "missing navigation pointer in docs/STATE.md"

d=$(snapshot doc_navigation_state_queue_pointer_missing)
sed_in_place '/final chat message must:/d' "$d/docs/STATE.md"
expect fail "doc-navigation: the Owner-queue pointer into Session discipline was deleted" "$d" doc-navigation.sh "missing navigation pointer in docs/STATE.md"

d=$(snapshot drift_script)
printf '# local edit\n' >>"$d/scripts/redact.sh"
expect fail "copy-drift: an edited shipped script" "$d" copy-drift.sh "drift:"

d=$(snapshot drift_missing)
rm "$d/scripts/session-start.sh"
expect fail "copy-drift: a shipped script not installed" "$d" copy-drift.sh "not installed here"

# The manifest is a shipped artifact that is not a *.sh file, and the copy-drift glob used to
# stop at the extension. That gap is not cosmetic: this repo's copy of the manifest could
# drift from the one adopters receive while the guard's own line said the shipped set was
# identical.
d=$(snapshot drift_manifest_copy)
printf '# a local edit\n' >>"$d/scripts/MANIFEST.sha256"
expect fail "copy-drift: an edited shipped file that is not a script" "$d" copy-drift.sh "drift:"

# The failure that reaches an adopter rather than us: a shipped script edited without
# regenerating the manifest publishes hashes for bytes nobody has. Their next upgrade then
# reports every script the harness sent them as locally edited.
d=$(snapshot drift_manifest_stale)
printf '\n# an upstream change\n' >>"$d/harness/templates/scripts/session-start.sh"
expect fail "manifest-drift: a shipped script changed without a rebuild" "$d" manifest-drift.sh "stale or hand-edited"

d=$(snapshot drift_manifest_edited)
sed_in_place 's/^[0-9a-f]\{64\}/0000000000000000000000000000000000000000000000000000000000000000/' \
	"$d/harness/templates/scripts/MANIFEST.sha256"
expect fail "manifest-drift: a hand-edited manifest" "$d" manifest-drift.sh "stale or hand-edited"

d=$(snapshot drift_manifest_gone)
rm "$d/harness/templates/scripts/MANIFEST.sha256"
expect fail "manifest-drift: no manifest at all" "$d" manifest-drift.sh "has not been built"

# The adapter set is declared in the guard rather than inferred from whichever files happen
# to remain. These Codex mutations prove that each independent delivery layer is live:
# reference path, installer action, and both legislation values. Removing a whole adapter
# cannot make the expected set shrink along with it.
d=$(snapshot adapter_codex_path_gone)
rm "$d/.codex/config.toml"
expect fail "adapter-set: a Codex reference path was removed" "$d" adapter-set.sh ".codex/config.toml"

d=$(snapshot adapter_codex_reviewer_path_gone)
rm "$d/.codex/agents/amh-rule-reviewer.toml"
expect fail "adapter-set: the Codex reviewer reference path was removed" "$d" adapter-set.sh ".codex/agents/amh-rule-reviewer.toml"

d=$(snapshot adapter_codex_install_gone)
sed_in_place '\|codex-config.toml.*\.codex/config.toml|d' "$d/scripts/amh-init.sh"
expect fail "adapter-set: a Codex install action was removed" "$d" adapter-set.sh "install action missing"

d=$(snapshot adapter_codex_legislation_gone)
sed_in_place 's/ \.codex\/config\.toml//' "$d/harness/templates/amh.conf.example"
expect fail "adapter-set: a Codex legislation entry was removed" "$d" adapter-set.sh "adopter RULE_FILES"

d=$(snapshot adapter_codex_reference_legislation_gone)
sed_in_place 's/ \.codex\/config\.toml//' "$d/amh.conf"
expect fail "adapter-set: a Codex reference legislation entry was removed" "$d" adapter-set.sh "reference RULE_FILES"

d=$(snapshot adapter_codex_session_hook_gone)
sed_in_place '/\[\[hooks.SessionStart\]\]/,/^$/d' "$d/harness/templates/configs/codex-config.toml"
expect fail "adapter-set: Codex has exactly one SessionStart hook" "$d" adapter-set.sh "exactly one SessionStart"

d=$(snapshot adapter_codex_bash_hook_duplicated)
cat "$d/harness/templates/configs/codex-config.toml" >>"$d/harness/templates/configs/codex-config.toml.copy"
sed -n '/\[\[hooks.PreToolUse\]\]/,$p' "$d/harness/templates/configs/codex-config.toml.copy" >>"$d/harness/templates/configs/codex-config.toml"
expect fail "adapter-set: Codex has exactly one Bash PreToolUse hook" "$d" adapter-set.sh "exactly one PreToolUse"

d=$(snapshot adapter_codex_agent_neutral_script_gone)
sed_in_place 's|scripts/command-guard\.sh|scripts/codex-command-guard.sh|' "$d/harness/templates/configs/codex-config.toml"
expect fail "adapter-set: Codex invokes the shipped agent-neutral command guard" "$d" adapter-set.sh "agent-neutral command-guard.sh"

# ADAPTER_FILES is the sixth place the set is written down — the session banner reports from
# it — so it drifts like any other. All three mutations below are silent without the guard:
# the banner simply stops mentioning an adapter, or mentions one nobody ships, and `unknown`
# is the honest word for "this repo declares none", so a stale entry reads as a fact.
d=$(snapshot adapter_banner_entry_gone)
sed_in_place "s|^ADAPTER_FILES='\.claude/settings\.json |ADAPTER_FILES='|" "$d/amh.conf"
expect fail "adapter-set: an adapter dropped from the banner list" "$d" adapter-set.sh "does not list adapter path"

d=$(snapshot adapter_banner_empty)
sed_in_place "s|^ADAPTER_FILES=.*|ADAPTER_FILES=''|" "$d/amh.conf"
expect fail "adapter-set: an empty banner list reports no adapter at all" "$d" adapter-set.sh "empty or unset"

d=$(snapshot adapter_banner_stale_entry)
sed_in_place "s|^ADAPTER_FILES='|ADAPTER_FILES='.zed/settings.json |" "$d/amh.conf"
expect fail "adapter-set: the banner lists a file outside the adapter set" "$d" adapter-set.sh "not in the first-class adapter set"

d=$(snapshot drift_dist)
printf 'hand edit\n' >>"$d/harness/dist/AMH.md"
expect fail "dist-drift: a hand-edited bundle" "$d" dist-drift.sh "stale or hand-edited"

d=$(snapshot drift_src)
printf '\nnew prose\n' >>"$d/harness/src/40-adaptation.md"
expect fail "dist-drift: sources changed without a rebuild" "$d" dist-drift.sh "stale or hand-edited"

d=$(snapshot ph_undocumented)
# Assembled at runtime: a stored placeholder literal would make this file fail the
# guard it is testing (the D-004 class — fixtures must never be stored literals).
printf '{{%s}}\n' TOTALLY_NEW_KNOB >>"$d/harness/templates/seed/CLAUDE.md"
expect fail "placeholders: undocumented" "$d" placeholder-integrity.sh "not documented"

d=$(snapshot ph_unfilled)
printf '{{%s}}\n' PROJECT_NAME >>"$d/docs/STATE.md"
expect fail "placeholders: left unfilled in a live file" "$d" placeholder-integrity.sh "unfilled placeholder"

# A BINARY live file whose bytes happen to match, under a grep that reports it the way GNU grep
# <= 3.4 does — which is what Git for Windows ships (3.0). The notice goes to STDOUT there, so
# the inner pass reads `Binary file <path> matches` as a token that is neither `{{PLACEHOLDER}}`
# nor `{{X}}` and this guard fails naming a file no human can fill. Same class as the ladder's
# citation rung, fixed the same way and for the same reason (AMH ledger row DC031).
#
# The shim is what makes the case exist on this host at all: on grep >= 3.5 the notice is on
# stderr, which both passes already discard, so the fixture would pass against the unfixed
# guard. It relocates that one line and leaves everything else — including the exit status —
# alone.
grep_stdout_notice_shim() { # <name> -> prints a directory to prepend to PATH
	local name=$1
	local dir="$WORK/shim-$name" real
	real=$(command -v grep) || return 1
	[ -n "$real" ] || return 1
	mkdir -p "$dir"
	cat >"$dir/grep" <<SHIM
#!/usr/bin/env bash
# A failed mktemp would abort the redirection and real grep would never run, which every
# caller reads as "no match" — a silent skip inside the tool a fixture uses to prove a
# guard does not silently skip.
err=\$(mktemp) || exit 2
"$real" "\$@" 2>"\$err"
rc=\$?
while IFS= read -r line; do
	case \$line in
	*': binary file matches')
		name=\${line#*: }
		printf 'Binary file %s matches\n' "\${name%: binary file matches}"
		;;
	*) printf '%s\n' "\$line" >&2 ;;
	esac
done <"\$err"
rm -f "\$err"
exit \$rc
SHIM
	chmod +x "$dir/grep"
	printf '%s' "$dir"
}

d=$(snapshot ph_binary_notice)
printf 'GDEF\000 {{%s}} \000glyf\n' PROJECT_NAME >"$d/docs/logo.ttf"
EXPECT_PATH_PREFIX=$(grep_stdout_notice_shim ph_binary) || EXPECT_PATH_PREFIX=
expect pass "placeholders: a binary file is not an unfilled placeholder" "$d" placeholder-integrity.sh
EXPECT_PATH_PREFIX=

# The same notice reaching the TEMPLATES pass, which is a different grep in the same guard and
# was missed by the first draft of this fix: there the notice survives `sed 's/[{}]//g'` and is
# reported as a placeholder name `harness/PLACEHOLDERS.md` does not document.
d=$(snapshot ph_binary_template)
printf 'GDEF\000 {{%s}} \000glyf\n' PROJECT_NAME >"$d/harness/templates/seed/logo.ttf"
EXPECT_PATH_PREFIX=$(grep_stdout_notice_shim ph_binary_tpl) || EXPECT_PATH_PREFIX=
expect pass "placeholders: a binary template asset is not an undocumented placeholder" "$d" \
	placeholder-integrity.sh
EXPECT_PATH_PREFIX=

d=$(snapshot ver_bump)
printf '1.9.0\n' >"$d/harness/VERSION"
expect fail "version-lockstep: VERSION bumped alone" "$d" version-lockstep.sh "harness/VERSION says 1.9.0"

d=$(snapshot ver_unreleased)
sed_in_place '1a\
\
## Unreleased' "$d/harness/CHANGELOG.md"
expect fail "version-lockstep: an Unreleased entry cannot hide a missing version bump" "$d" version-lockstep.sh "changelog top entry is 'Unreleased'"

d=$(snapshot ver_conf)
sed_in_place 's/^AMH_VERSION=.*/AMH_VERSION=1.7.0/' "$d/amh.conf"
expect fail "version-lockstep: amh.conf drifted" "$d" version-lockstep.sh "amh.conf"

d=$(snapshot ver_tag)
expect fail "version-lockstep: a tag that does not match" "$d" "version-lockstep.sh --tag amh-v9.9.9" "does not match"

# The README's quickstart pins a release tag, so it is a fifth hand-written copy. Two arms,
# because they fail for different reasons and one message would leave the other untested: a
# tag naming the WRONG version, and a quickstart with no pin at all — which is the state the
# README was in before this check existed, and the one a careless edit returns it to.
# The expected substring is the DRIFT verdict, not the label. `README quickstart tag` prefixes
# every message check() can emit, so asserting it would be satisfied by an implementation that
# cannot tell a drifted pin from a missing one — a review pass built exactly that and both arms
# still passed.
d=$(snapshot ver_readme)
sed_in_place 's/--branch amh-v[0-9][0-9.]*/--branch amh-v0.1.0/' "$d/README.md"
expect fail "version-lockstep: README pins the wrong release tag" "$d" version-lockstep.sh "README.md says 0.1.0"

d=$(snapshot ver_readme_gone)
sed_in_place 's/--branch amh-v[0-9][0-9.]*//' "$d/README.md"
expect fail "version-lockstep: README quickstart lost its pin" "$d" version-lockstep.sh "no version found"

# --against-latest-tag. Each fixture PINS both halves of the comparison — the version it writes
# into all six version-bearing places, and the tag list it creates — because the first draft
# pinned neither. It derived a tag from the live `harness/VERSION` and hard-coded `amh-v10.2.0`
# opposite it, so both arms passed by coincidence of the number the tree happened to carry that
# afternoon; a review pass reproduced the suite going red on the next PATCH release. A fixture
# whose meaning moves with an unrelated file is not a fixture.
version_fixture() { # version_fixture <name> <version> <tag>... -> prints the snapshot path
	local name=$1 version=$2 d t
	shift 2
	d=$(snapshot "$name")
	printf '%s\n' "$version" >"$d/harness/VERSION"
	sed_in_place "s/Adopted harness version: \*\*AMH [0-9][0-9.]*\*\*/Adopted harness version: **AMH $version**/" "$d/AGENTS.md"
	sed_in_place "s/Adopted harness version: \*\*AMH [0-9][0-9.]*\*\*/Adopted harness version: **AMH $version**/" "$d/docs/STATE.md"
	sed_in_place "s/^AMH_VERSION=[0-9][0-9.]*/AMH_VERSION=$version/" "$d/amh.conf"
	sed_in_place "s/--branch amh-v[0-9][0-9.]*/--branch amh-v$version/" "$d/README.md"
	# The changelog's TOP entry only, which is the one the lockstep reads; a blanket substitution
	# would rewrite every historical heading to the same number.
	awk -v v="$version" '!done && sub(/^## [0-9][0-9.]*/, "## " v) { done = 1 } { print }' \
		"$d/harness/CHANGELOG.md" >"$d/harness/CHANGELOG.md.new" &&
		cat "$d/harness/CHANGELOG.md.new" >"$d/harness/CHANGELOG.md" &&
		rm -f "$d/harness/CHANGELOG.md.new"
	for t in "$@"; do
		# A tag that silently failed to be created turns an arm into a different test — the
		# no-tags one — which still passes for the wrong reason. Say so instead.
		git -C "$d" tag "$t" || {
			FAILED=$((FAILED + 1))
			printf '  FAIL %s — could not create fixture tag %s\n' "$name" "$t" >&2
		}
	done
	printf '%s' "$d"
}

# The three ACCEPT arms, one per bump size. Without all three a guard accepting only MINOR passes
# the whole suite: the review pass mutated `"$major" | "$minor" | "$patch")` down to `"$minor")`
# and got 119 passed, 0 failed, because 10.3.0-from-10.2.0 was the only accepted shape any
# fixture exercised. The first PATCH release would then have gone red with nothing to catch it.
d=$(version_fixture ver_tag_major 11.0.0 amh-v10.2.0)
expect pass "version-lockstep: --against-latest-tag accepts a MAJOR bump" "$d" \
	"version-lockstep.sh --against-latest-tag"

d=$(version_fixture ver_tag_patch 10.2.1 amh-v10.2.0)
expect pass "version-lockstep: --against-latest-tag accepts a PATCH bump" "$d" \
	"version-lockstep.sh --against-latest-tag"

# The MINOR arm carries the lexical-sort trap: `git tag -l` sorts as text, so amh-v9.1.0 comes
# AFTER amh-v10.2.0. A guard taking the list's last entry would validate every PR against a tag
# two majors stale while printing a green line. Mutating the numeric comparison to take the
# lexical last reddens exactly this arm, which is what makes it worth its runtime.
d=$(version_fixture ver_tag_minor 10.3.0 amh-v9.1.0 amh-v10.2.0)
expect pass "version-lockstep: --against-latest-tag accepts a MINOR bump and ignores the lexical last" "$d" \
	"version-lockstep.sh --against-latest-tag"

d=$(version_fixture ver_tag_same 10.2.0 amh-v10.2.0)
expect fail "version-lockstep: --against-latest-tag rejects the tag's own version" "$d" \
	"version-lockstep.sh --against-latest-tag" "already released"

d=$(version_fixture ver_tag_stale 10.3.0 amh-v9.0.0)
expect fail "version-lockstep: --against-latest-tag rejects a version several bumps out" "$d" \
	"version-lockstep.sh --against-latest-tag" "not one bump above"

# No tags at all must FAIL, never pass: "there is nothing to compare against" and "the version
# is fine" are the two states a green line here would render identically.
d=$(snapshot ver_tag_none)
expect fail "version-lockstep: --against-latest-tag with no tags says it compared NOTHING" "$d" \
	"version-lockstep.sh --against-latest-tag" "compared NOTHING"

d=$(snapshot refs_broken)
printf '\nSee [the plan](docs/NOTHING_HERE.md).\n' >>"$d/docs/RUNBOOK.md"
expect fail "path-refs: a broken relative link" "$d" path-refs.sh "broken link"

d=$(snapshot refs_backtick)
# shellcheck disable=SC2016 # the backticks are the fixture: path-refs.sh only sees a
# citation inside a markdown code span, so expanding them would delete what is on trial.
printf '\nRun `scripts/does-not-exist.sh` first.\n' >>"$d/docs/RUNBOOK.md"
expect fail "path-refs: a cited path that does not exist" "$d" path-refs.sh "nonexistent path"

# A file name with a space: `for f in $files` word-splits it away, and the guard then
# prints a resolved count and a green line for a file it never opened.
d=$(snapshot refs_spacey)
# shellcheck disable=SC2016 # literal backticks: same fixture form as above.
printf 'See `docs/NOTHING_HERE.md` for the details.\n' >"$d/notes with space.md"
expect fail "path-refs: a bad ref in a file name with a space" "$d" path-refs.sh "nonexistent path"

# The docs/plans exclusion is a hole by design (a plan may name what it has not built).
# It is bounded to that directory and asserted here so the boundary is a tested one.
d=$(snapshot refs_plans_excluded)
mkdir -p "$d/docs/plans"
# shellcheck disable=SC2016 # literal backticks: same fixture form as above.
printf 'Build `scripts/does-not-exist.sh` next.\n' >"$d/docs/plans/future.md"
expect pass "path-refs: a plan may name a path it has not built yet" "$d" path-refs.sh

# A bare filename with no slash. The backtick pattern required an embedded slash, so a
# repo-ROOT file could not match it and a citation to one could never fail — which is how
# CONTRIBUTING.md stayed cited five times while absent, inside the guard admitted to close
# that incident.
d=$(snapshot refs_bare_missing)
# shellcheck disable=SC2016 # literal backticks: same fixture form as above.
printf '\nRead `NOTHING_HERE.md` first.\n' >>"$d/docs/RUNBOOK.md"
expect fail "path-refs: a cited bare filename that exists nowhere" "$d" path-refs.sh "no file by that name"

# The other half, and the reason bare names resolve by BASENAME rather than from the repo
# root: the prose says `STATE.md`, never `docs/STATE.md`. A root-relative test would call
# that broken, and a guard that cries wolf on the house style gets ignored — which is why
# the root-relative widening was rejected at 24 hits for 2 true positives.
d=$(snapshot refs_bare_subdir)
# shellcheck disable=SC2016 # literal backticks: same fixture form as above.
printf '\nRead `STATE.md` first.\n' >>"$d/docs/RUNBOOK.md"
expect pass "path-refs: a bare filename resolves from a subdirectory" "$d" path-refs.sh

# The match must be WHOLE-LINE. Dropping `-x` left every fixture above green while
# `TATE.md` and `adder.sh` resolved as substrings of real basenames — a citation to a
# file that does not exist, reported as resolving, which is the entire failure this
# section was added to stop.
d=$(snapshot refs_bare_substring)
# shellcheck disable=SC2016 # literal backticks: same fixture form as above.
printf '\nRead `TATE.md` first.\n' >>"$d/docs/RUNBOOK.md"
expect fail "path-refs: a bare name that is only a substring of a real file" "$d" path-refs.sh "no file by that name"

# `git ls-files` answers from the index, so a file removed with plain `rm` is still listed.
# Resolving against that made a citation to a deleted file read as resolving.
# `amh.conf` rather than a `.md` file: deleting one of the scanned documents would also
# trip sections (a) and (b), so the fixture could pass without section (c) working.
d=$(snapshot refs_bare_deleted)
rm "$d/amh.conf"
expect fail "path-refs: a bare name whose file was deleted but is still in the index" "$d" path-refs.sh "no file by that name"

# The hollow states, where the guard's own listing tells it nothing and the answer used to be
# indistinguishable from a verdict about the prose. SIX behaviours, six cases below, because a
# suite that covers four of them reads exactly like one that covers all six (DC-025): the tree
# listing failing (i, iv) and coming back empty (ii); the markdown listing failing (v) and
# coming back empty (iii); every listed file being excluded after the fact (vi); and the `if
# [ -e ]` in the basename loop that keeps a deleted last-sorted path from posing as a failed
# listing (vii). Each asserts the DISCRIMINATING sentence, never the shared `checked NOTHING`,
# which every one of them would satisfy.
#
# Note which hollow state a uniformly failing listing lands on: the GREEN one. Both calls fail,
# the loop never runs, and the guard used to print `0 path reference(s) resolve`. The false
# failure that started this — a real run reporting `session-start.sh`, a file that exists, as
# cited nowhere — needs the tree listing to come back short while the markdown one succeeds.
#
# A tree of nothing but the guard itself, for the cases that need a listing this repo's
# snapshot can never produce. Built rather than snapshotted: `git ls-files -c` reports tracked
# files whatever the excludes say, so an empty listing is unreachable from a committed tree.
guard_only_tree() { # guard_only_tree <name> -> prints the path
	local d="$WORK/$1"
	mkdir -p "$d/scripts/guards"
	cp "$ROOT/scripts/guards/path-refs.sh" "$d/scripts/guards/path-refs.sh"
	(cd "$d" && git init -q .)
	printf '%s' "$d"
}

# A `git` that dies part way through ONE listing: plausible output already emitted, then a
# non-zero exit. No tree can be posed into that — a tree yields an empty listing or a complete
# one — so the status checks are reachable only through a shim, and without one they are the
# arms that survive deletion untouched while the emptiness checks cover for them. `which` picks
# the listing, so each status check is demonstrated on its own.
git_dying_shim() { # git_dying_shim <name> <tree|md> -> prints a directory to prepend to PATH
	# Split, not one `local` list: `dir="$WORK/shim-$name"` would expand `$name` before the
	# same statement assigned it, which is D-006 and explodes under `set -u`.
	local name=$1 which=$2
	local dir="$WORK/shim-$name" real pattern
	real=$(command -v git)
	case $which in
	tree) pattern='ls-files' ;;
	md) pattern="'*.md'" ;;
	esac
	mkdir -p "$dir"
	cat >"$dir/git" <<SHIM
#!/usr/bin/env bash
for a in "\$@"; do
	case \$a in
	$pattern) printf 'AGENTS.md\0'; exit 128 ;;
	esac
done
exec $real "\$@"
SHIM
	chmod +x "$dir/git"
	printf '%s' "$dir"
}

# (i) The tree listing FAILS outright. A truncated index is the failure git actually reports —
#     exit 128 with nothing on stdout — and it cannot be satisfied by an enclosing repository
#     the way a deleted `.git` could.
d=$(snapshot refs_listing_failed)
printf 'garbage' >"$d/.git/index"
expect fail "path-refs: a failed tree listing is not a clean sweep" "$d" path-refs.sh \
	"the tree listing FAILED (exit 128)"

# (ii) The tree listing SUCCEEDS and is empty: no tracked file, and the working tree excluded.
#      `.git/info/exclude` rather than a `.gitignore` only to keep the tree file-free — a
#      `.gitignore` matching `*` excludes itself too and yields the same empty listing.
d=$(guard_only_tree refs_listing_empty)
printf '*\n' >"$d/.git/info/exclude"
expect fail "path-refs: a tree listing that came back empty is not a clean sweep" "$d" path-refs.sh \
	"the tree listing named no file at all"

# (iii) The tree listing is fine and the MARKDOWN listing is empty — the case the check on
#       `basenames` alone would never reach, and the one that made the guard print a green
#       count over a scan of no documents at all.
d=$(guard_only_tree refs_no_markdown)
(cd "$d" && git add -A && git commit -qm no-markdown)
expect fail "path-refs: a tree with no markdown in it is not a clean sweep" "$d" path-refs.sh \
	"the markdown listing named no file at all"

# (iv) The tree listing fails AFTER emitting a plausible path, so `basenames` is non-empty and
#      only the status check can catch it. Delete `[ "$rc" -eq 0 ] || listing_failed tree` and
#      this is the case that reddens; (i) is not, because an empty listing catches that one.
d=$(snapshot refs_tree_status)
EXPECT_PATH_PREFIX=$(git_dying_shim tree_status tree)
expect fail "path-refs: a tree listing that dies mid-stream is not a clean sweep" "$d" path-refs.sh \
	"the tree listing FAILED (exit 128)"
EXPECT_PATH_PREFIX=

# (v) The same for the markdown listing: the tree call is let through, so the file is non-empty
#     and its `-s` test passes. Only the markdown status check is left to catch it.
d=$(snapshot refs_md_status)
EXPECT_PATH_PREFIX=$(git_dying_shim md_status md)
expect fail "path-refs: a markdown listing that dies mid-stream is not a clean sweep" "$d" path-refs.sh \
	"the markdown listing FAILED (exit 128)"
EXPECT_PATH_PREFIX=

# (vi) A listing that is non-empty and wholly excluded. `shipped-citations.sh` refuses this
#      AFTER its exclusions for the reason it states — a renamed directory looks exactly like a
#      clean sweep — and this guard refused it only before them, so a tree whose every markdown
#      file sits under `harness/templates/` scanned nothing and reported green.
d=$(guard_only_tree refs_all_excluded)
mkdir -p "$d/harness/templates"
# shellcheck disable=SC2016 # literal backticks: same fixture form as above.
printf 'See `docs/NOTHING_HERE.md`.\n' >"$d/harness/templates/adopter.md"
(cd "$d" && git add -A && git commit -qm excluded-only)
expect fail "path-refs: a listing whose every file is excluded is not a clean sweep" "$d" path-refs.sh \
	"are outside the scan"

# (vii) The `if [ -e "$p" ]` in the basename loop, which the tree status check turned into
#       load-bearing code: under `pipefail` the older `[ -e "$p" ] && printf` form returns the
#       TEST's status, so a last-sorted path that no longer exists reported the whole listing as
#       failed — a false alarm that also swallows whatever real finding the run had. The file is
#       constructed rather than borrowed from the tree, because a fixture that depends on which
#       real file happens to sort last stops testing this, silently, the day another one does.
d=$(snapshot refs_last_path_deleted)
printf 'x\n' >"$d/zzz-last-in-listing.txt"
(cd "$d" && git add zzz-last-in-listing.txt && git commit -qm zzz)
rm "$d/zzz-last-in-listing.txt"
expect pass "path-refs: a deleted last-sorted path is not a failed listing" "$d" path-refs.sh

# (viii) The bare-name lookup must not be a PIPE. `grep -q` exits on its first match, and a
#        writer with bytes still pending then takes EPIPE; under `pipefail` that turns a
#        successful match into a non-zero pipeline, and the guard reports a file that exists
#        as cited nowhere. It reached CI as a macOS run failing on `AGENTS.md` while every
#        Linux run of the same commit stayed green (DC-034).
#
#        This case is SIZE-BUILT rather than shim-built, and the size is the whole trick: a
#        single write into a pipe that has room never notices the reader leaving, so the
#        real tree's ~1 KB basename list cannot reproduce this on a host with a 64 KB pipe
#        buffer no matter how the fixture is posed. Padding the listing past that buffer
#        forces the writer to block, which is what lets `grep -q` exit first. The cited name
#        sorts to the very front so the match happens as early as possible, leaving the most
#        pending. Against the piped form this case fails; against the here-string it passes,
#        and the padding is what makes that difference exist at all on this platform.
#
#        The padding is `*.txt` and NOT `*.md`, because only the BASENAME listing has to be
#        long: the markdown loop opens and greps every file it is given, so `*.md` padding
#        bought the identical verdict while dragging 800 empty documents through two greps
#        apiece — 10.9s against 0.13s, which was 23% of this whole suite. Measured both ways
#        against both forms of the lookup before the change: `*.txt` still fails against the
#        piped form, which is the only property the padding owes.
#
#        The pass verdict carries a message substring, because a bare `expect pass` here goes
#        vacuous in silence: if the padding ever stops clearing the pipe buffer the case is
#        green against both forms and says nothing. The substring pins what the guard
#        actually resolved — one citation across the two markdown files, the pad excluded —
#        so a fixture that stopped exercising the lookup fails instead of passing quietly.
d=$(guard_only_tree refs_early_match_long_listing)
mkdir -p "$d/pad"
i=0
while [ "$i" -lt 800 ]; do
	: >"$d/pad/$(printf 'p%0100d' "$i").txt"
	i=$((i + 1))
done
: >"$d/AAA-first-in-listing.md"
# shellcheck disable=SC2016 # the backticks are the fixture: the guard reads a markdown
# code span, so single quotes are required here.
printf 'cites `AAA-first-in-listing.md`\n' >"$d/doc.md"
expect pass "path-refs: an early match on a long listing is not a missing file" "$d" path-refs.sh \
	'1 path reference(s) resolve across 2 file(s)'

# --- scripts/bootstrap.sh ----------------------------------------------------
# Not a guard, so it gets its own runner rather than `expect`. It is repo-local for the
# same reason the guards above are: session-start.sh is the shipped, agent-neutral boot
# sequence, and this is the hook it leaves for whatever toolchain the repo happens to
# need. That makes this file its only possible fixture home.
#
# Every case here runs OFFLINE, by construction. The download goes through a `file://`
# URL at a tarball this suite builds, and the binary inside it is a five-line shell
# script — not a copy of the real shellcheck, which would make the fixtures depend on
# the very tool bootstrap.sh exists to install (D-024: a fixture must satisfy its
# predicate by construction, never usually).

# A PATH with no shellcheck on it. Without one, CI — which apt-installs shellcheck to
# /usr/bin — would take bootstrap's already-present fast path in every case below and the
# download half would be tested by nothing, green.
#
# It is CONSTRUCTED, one directory of symlinks to the tools bootstrap.sh actually uses,
# and never `shellcheck`. The obvious form is to subtract instead — walk $PATH and drop
# any directory holding a shellcheck — and it is wrong for a reason worth recording: on
# CI that deletes /usr/bin, and /bin with it (a symlink to usr/bin), so the surviving
# PATH has no bash, curl, tar, git or grep and every case here dies at exit 127. It
# passes on a machine where shellcheck happens to live somewhere uninteresting, which is
# not a property of the fixture at all — it is a property of the box.
bs_shim() { # bs_shim <dir> <tool>... — a directory holding exactly these tools
	local dir=$1 t p
	shift
	mkdir -p "$dir"
	for t in "$@"; do
		p=$(command -v "$t" 2>/dev/null) || continue
		[ -n "$p" ] && ln -sf "$p" "$dir/$t"
	done
}
BS_PATH="$WORK/bs_shim"
bs_shim "$BS_PATH" bash sh env curl tar xz mktemp find grep sed chmod cp mv rm mkdir dirname cat git
# The same set minus curl. `curl` is NOT in the harness's baseline toolchain (AGENTS.md
# names bash, git and coreutils), so bootstrap.sh treats its absence as a supported,
# non-fatal outcome — and that branch deserves a fixture more than it deserves an
# assumption.
BS_PATH_NOCURL="$WORK/bs_shim_nocurl"
bs_shim "$BS_PATH_NOCURL" bash sh env tar xz mktemp find grep sed chmod cp mv rm mkdir dirname cat git

bs_tarball() { # bs_tarball <absolute-out.tar.xz> <script-body>
	local out=$1 body=$2 t
	t=$(mktemp -d) || return 1
	mkdir -p "$t/shellcheck-stable"
	printf '%s' "$body" >"$t/shellcheck-stable/shellcheck"
	chmod +x "$t/shellcheck-stable/shellcheck"
	(cd "$t" && tar -cJf "$out" shellcheck-stable)
	rm -rf "$t"
}

BS_OUT=''
BS_RC=0
bs_env_run() { # bs_env_run <repo-dir> <home> <url> <path> [VAR=VAL...]
	local d=$1 home=$2 url=$3 path=$4
	shift 4
	BS_OUT=$(env HOME="$home" PATH="$path" AMH_SHELLCHECK_URL="$url" "$@" bash "$d/scripts/bootstrap.sh" 2>&1)
	BS_RC=$?
}
bs_run() { bs_env_run "$1" "$2" "$3" "$BS_PATH"; }

bs_expect() { # bs_expect <pass|fail> <name> <message-substring>
	local want=$1 name=$2 want_msg=$3
	if [ "$want" = pass ] && [ "$BS_RC" -ne 0 ]; then
		FAILED=$((FAILED + 1))
		printf '  FAIL %s — expected exit 0, got %d\n%s\n' "$name" "$BS_RC" "$BS_OUT" >&2
	elif [ "$want" = fail ] && [ "$BS_RC" -eq 0 ]; then
		FAILED=$((FAILED + 1))
		printf '  FAIL %s — expected a non-zero exit, got 0\n%s\n' "$name" "$BS_OUT" >&2
	elif ! printf '%s' "$BS_OUT" | grep -qF "$want_msg"; then
		FAILED=$((FAILED + 1))
		printf '  FAIL %s — verdict right but the output never mentioned %s\n%s\n' "$name" "$want_msg" "$BS_OUT" >&2
	else
		PASSED=$((PASSED + 1))
	fi
}

bs_check() { # bs_check <name> <description> <test-expression...>
	local name=$1
	shift
	if "$@"; then
		PASSED=$((PASSED + 1))
	else
		FAILED=$((FAILED + 1))
		printf '  FAIL %s\n' "$name" >&2
	fi
}

d=$(snapshot bootstrap)
# shellcheck disable=SC2016 # scoped to this one call: the body is a script this suite
# WRITES, so `$1` must survive into the file and be expanded by the fixture binary when
# bootstrap.sh runs it — expanding it here would delete what is on trial.
bs_tarball "$d/good.tar.xz" '#!/bin/sh
[ "$1" = --version ] && printf "version: 0.0.0-fixture\n"
exit 0
'
# The silent-skip class in its purest form: a "binary" that installs, runs and exits 0
# while being nothing at all. `command -v` is satisfied, an exit-status check is
# satisfied, and the ladder's lint rung would print skip forever.
bs_tarball "$d/mute.tar.xz" '#!/bin/sh
exit 0
'

# The install cases need curl, and curl is outside the baseline toolchain. Gated rather
# than assumed — and gated LOUDLY, with the count of what was skipped, because a suite
# that quietly runs four fewer cases on some machines is the same defect as a guard that
# quietly checks nothing. The curl-free branch below runs either way.
if [ -e "$BS_PATH/curl" ]; then
	h="$WORK/bs_home_ok"
	mkdir -p "$h"
	bs_run "$d" "$h" "file://$d/good.tar.xz"
	bs_expect pass "bootstrap: a good download installs shellcheck" "installed at"
	bs_check "bootstrap: the installed binary is the one later runs resolve" \
		test -x "$h/.local/bin/shellcheck"
	bs_check "bootstrap: the PATH block reaches the shells the session opens" \
		grep -qF 'AMH toolchain bootstrap' "$h/.bashrc"

	# Second run against a URL that cannot resolve: passing PROVES no download was
	# attempted, which is what "idempotent and fast when shellcheck is already present"
	# means operationally. The marker count proves the ~/.bashrc block is written once,
	# not once per session — a container that boots twenty sessions must not end with
	# twenty blocks.
	bs_run "$d" "$h" "file://$d/does-not-exist.tar.xz"
	bs_expect pass "bootstrap: a second run downloads nothing" "already installed"
	bs_check "bootstrap: the PATH block is appended exactly once" \
		test "$(grep -c 'AMH toolchain bootstrap' "$h/.bashrc")" = 1

	h="$WORK/bs_home_mute"
	mkdir -p "$h"
	bs_run "$d" "$h" "file://$d/mute.tar.xz"
	bs_expect fail "bootstrap: a binary that exits 0 without being shellcheck is rejected" "install FAILED"
	bs_check "bootstrap: a rejected binary is not left behind for the next run to trust" \
		test ! -e "$h/.local/bin/shellcheck"

	h="$WORK/bs_home_nonet"
	mkdir -p "$h"
	bs_run "$d" "$h" "file://$d/no-such-file.tar.xz"
	bs_expect fail "bootstrap: an unfetchable URL is loud" "install FAILED"
else
	printf '  SKIP 6 bootstrap install case(s): curl is not on this machine, and the install path cannot run without it\n' >&2
fi

# manifest-drift with no hashing tool on PATH. The shim above holds a fixed tool list and
# never a hasher, so this is the one condition under which the guard's rebuild cannot happen —
# and it must say THAT rather than reporting a stale manifest, which is what a diff against a
# generator that produced nothing looks like. Placed here because BS_PATH is built above.
out=$(cd "$base" && env PATH="$BS_PATH" bash scripts/guards/manifest-drift.sh 2>&1)
rc=$?
if [ "$rc" -ne 0 ] && printf '%s' "$out" | grep -qF 'this guard checked NOTHING'; then
	PASSED=$((PASSED + 1))
else
	FAILED=$((FAILED + 1))
	printf '  FAIL manifest-drift: a missing hasher is named, not reported as drift — rc=%s\n%s\n' "$rc" "$out" >&2
fi

# config-schema with no `comm` on PATH — the same hollow-green shape, and the one its own
# review found: with the comparison unable to run, the difference is empty and the guard
# would otherwise print an affirmative line claiming 22 keys were checked. The shim's fixed
# tool list has no `comm`, so this is the condition, not a simulation of it.
out=$(cd "$base" && env PATH="$BS_PATH" bash scripts/guards/config-schema.sh 2>&1)
rc=$?
if [ "$rc" -ne 0 ] && printf '%s' "$out" | grep -qF 'checked NOTHING'; then
	PASSED=$((PASSED + 1))
else
	FAILED=$((FAILED + 1))
	printf '  FAIL config-schema: a missing comm is named, not reported as agreement — rc=%s\n%s\n' "$rc" "$out" >&2
fi

# An example file that yields no keys at all. Emptied, renamed, or restyled so the pattern
# stops matching, it compares nothing against nothing and calls it agreement — the exact
# zero-extraction case version-lockstep.sh already refuses.
d=$(snapshot config_schema_empty_example)
: >"$d/harness/templates/amh.conf.example"
expect fail "config-schema: an example with no keys is a broken guard, not a pass" "$d" \
	config-schema.sh "the guard pattern and the file have diverged"

h="$WORK/bs_home_nocurl"
mkdir -p "$h"
bs_env_run "$d" "$h" "file://$d/good.tar.xz" "$BS_PATH_NOCURL"
bs_expect fail "bootstrap: no curl is a loud, non-fatal outcome" "curl is not available"

# --- the P14 warm-up ---------------------------------------------------------
# Uncovered entirely until these: `snapshot` creates no remote, so every case above takes
# warm_up's early return and replacing the whole function with `:` left the suite green.
# Each case here installs a working fixture shellcheck into $HOME first, so bootstrap
# takes the fast path and the warm-up is the only thing under test.
bs_ready_home() { # bs_ready_home <home>
	mkdir -p "$1/.local/bin"
	# shellcheck disable=SC2016 # scoped to this printf: `$1` belongs to the script being
	# written, not to this function.
	printf '%s\n' '#!/bin/sh' '[ "$1" = --version ] && printf "version: 0.0.0-fixture\n"' 'exit 0' \
		>"$1/.local/bin/shellcheck"
	chmod +x "$1/.local/bin/shellcheck"
}

h="$WORK/bs_home_warm_noremote"
bs_ready_home "$h"
bs_run "$d" "$h" "file://$d/good.tar.xz"
bs_expect pass "warm-up: a repo with no origin says so instead of going quiet" "no 'origin' remote"

# A bare remote on the local filesystem, so the fetch is real but never touches a network.
bs_remote="$WORK/bs_remote.git"
git init -q --bare "$bs_remote"
dw=$(snapshot bootstrap_warm)
bs_branch=$(sed -n 's/^DEFAULT_BRANCH=//p' "$dw/amh.conf")
(
	cd "$dw" || exit 1
	git remote add origin "$bs_remote"
	git push -q origin "HEAD:refs/heads/$bs_branch"
	# The push creates the tracking ref; delete it, so its REAPPEARANCE is the evidence
	# that the warm-up ran rather than something the fixture set up itself.
	git update-ref -d "refs/remotes/origin/$bs_branch" 2>/dev/null
)

bs_no_ref() { # bs_no_ref <dir> <ref>
	! (cd "$1" && git rev-parse --verify --quiet "$2" >/dev/null 2>&1)
}

# A bounded WAIT, not a probabilistic predicate — the distinction D-024 turns on. The
# remote is a bare repository on this filesystem holding one commit, so the only thing
# being waited for is a `git fetch` process starting and exiting; there is no draw, no
# distribution and no tail. The ceiling exists so a hung fetch fails LOUDLY instead of
# hanging the suite, and it is three orders of magnitude past what a local fetch costs.
bs_await_ref() { # bs_await_ref <dir> <ref>
	local i=0
	while [ "$i" -lt 600 ]; do
		(cd "$1" && git rev-parse --verify --quiet "$2" >/dev/null 2>&1) && return 0
		sleep 0.1
		i=$((i + 1))
	done
	return 1
}

# An unwritable log directory. The first draft opened the log inside the background job's
# redirection, so this case printed a line announcing a fetch that had never started.
h="$WORK/bs_home_warm_nolog"
bs_ready_home "$h"
bs_env_run "$dw" "$h" "file://$d/good.tar.xz" "$BS_PATH" TMPDIR="$WORK/no/such/dir"
bs_expect pass "warm-up: an unwritable log is reported, not papered over" "was NOT started"
bs_check "warm-up: and no fetch is claimed when none was started" \
	bs_no_ref "$dw" "refs/remotes/origin/$bs_branch"

h="$WORK/bs_home_warm_ok"
bs_ready_home "$h"
bs_env_run "$dw" "$h" "file://$d/good.tar.xz" "$BS_PATH"
bs_expect pass "warm-up: an origin remote is fetched in the background" "in the background"
bs_check "warm-up: and the ref the poison-token guard needs actually lands" \
	bs_await_ref "$dw" "refs/remotes/origin/$bs_branch"

printf '\n%d passed, %d failed\n' "$PASSED" "$FAILED"
[ "$FAILED" -eq 0 ]
