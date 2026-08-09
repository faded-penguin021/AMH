#!/usr/bin/env bash
# Repo-local guard: nothing we ship into an adopter's citation-scan paths may carry a real
# ledger citation.
#
# The ledger preambles' carve-out: a citation inside a shipped artifact is not a citation at all
# in the tree that receives it. These rows are this repository's and can never exist in an
# adopter's ledger, so a hyphenated row id in something we hand out is a promise to resolve
# something that will not be there. The reasoning prose stays; the row is named in a form the
# citation scan does not read — `AMH ledger row DB016`, no hyphen.
#
# Why this needs a guard rather than reviewer attention: the failure is invisible from inside
# THIS repository and lands in someone else's. Here the row exists, the ladder's citation rung
# asks for a `[cited]` marker, the marker gets added, and everything is green. In an adopter's
# tree the same file cites an id their ledger has never heard of, their citation rung fails, and
# the file it names is one they are told never to edit (DB-018, DB-019). The unhyphenated
# form belongs only in what we ship; this guard is repo-local, so its citations are real.
#
# SCOPE IS BY DESTINATION, not by file extension, and the first version got this wrong in the
# way that mattered: it scanned `harness/templates/scripts/*.sh` and called that "any shipped
# script", while `amh-init.sh` also installs the seed scripts into the adopter's `scripts/` and
# `configs/ci.yml` into their `.github/workflows/` — both inside the default
# `CITATION_SCAN_PATHS`. A citation in either passed this guard and turned a fresh adopter's
# very first ladder run red, which is the exact failure the guard exists to stop. `copy-drift.sh`
# had already learned the same lesson over the same directory, one glob's worth of narrowness.
#
# Out of scope, deliberately: the seed ledger's placeholder first row, which is the adopter's own
# row rather than a citation of ours, and the prose seeds and bundle, where an id appears as an
# illustration of the citation FORM and which land in `docs/`, outside the default scan paths.
#
# Note the trap this file fell into on its first run: an id written here as an EXAMPLE is a
# citation too, because this guard lives inside the citation scan. Say the shape in words.

set -uo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." || exit 1

# Each entry is a glob over things this repository installs into a path the adopter's citation
# scan reads by default (`scripts` and `.github`). Add a line here whenever amh-init.sh learns
# to install something new into either.
SCAN_GLOBS='harness/templates/scripts/* harness/templates/seed/scripts/* harness/templates/configs/ci.yml'
# The shipped fixture suite is the one file whose ledger ids are legitimate: they are fixture
# material — it synthesizes a ledger containing them — and the `CITATION_EXCLUDE` default in the
# shipped `harness/templates/amh.conf.example` keeps that file out of the citation scan of any
# adopter whose amh.conf carries the key. (An adopter whose amh.conf predates the key does NOT
# get the exclusion; that gap is real and is not this guard's to close.) Excluded here for the
# same reason it is excluded there: if that config default changes, this exclusion is wrong and
# so is the one in amh.conf. Both files carry a pointer back to this one.
EXCLUDE_BASENAMES='test-ladder-guards.sh'

LEDGER_DIR=docs
LEDGER_BASENAME=LEDGER
# shellcheck source=/dev/null
[ -f amh.conf ] && . ./amh.conf

# Does this id name a row that actually exists here? This picks the WORDING of the diagnostic
# and never the verdict — both branches fail — so it deliberately globs the volume files rather
# than reimplementing the ladder's chain walk. A volume-shaped file the walk cannot reach would
# make this say "row" where the ladder says "no such row"; that costs one misleading sentence in
# a message, never a wrong pass or a wrong failure.
resolves_in_ledger() { # resolves_in_ledger <id>
	local id=$1 v
	for v in "$LEDGER_DIR/$LEDGER_BASENAME".md "$LEDGER_DIR/$LEDGER_BASENAME"_*.md; do
		[ -f "$v" ] || continue
		LC_ALL=C grep -qE "^- $id( \[cited\])?: " "$v" && return 0
	done
	return 1
}

fails=0
matched=0
scanned=0
excluded=0

# `set -f` for the glob list below: the entries are split on whitespace on purpose, but an
# unquoted expansion also globs, and an entry is itself a pattern that must expand exactly once,
# where it is used.
set -f
for pattern in $SCAN_GLOBS; do
	set +f
	for f in $pattern; do
		# `-e` is false for an unmatched glob (bash leaves the pattern itself) AND for a broken
		# symlink, so `-L` is tested too. Anything the glob matched is COUNTED and, if it cannot
		# be read, named: `[ -f ]` alone silently drops a broken symlink or a directory called
		# `x.sh`, and the totals then make an affirmative false claim about what was checked.
		[ -e "$f" ] || [ -L "$f" ] || continue
		matched=$((matched + 1))
		base=${f##*/}
		skip=0
		for ex in $EXCLUDE_BASENAMES; do
			[ "$base" = "$ex" ] && skip=1
		done
		if [ "$skip" -eq 1 ]; then
			excluded=$((excluded + 1))
			continue
		fi
		if [ ! -f "$f" ] || [ ! -r "$f" ]; then
			printf '%s matched the shipped set but is not a readable regular file — this guard could not check it\n' "$f"
			fails=$((fails + 1))
			continue
		fi
		# Whole-word, and the same unbounded volume pattern the ladder's citation rung uses, so a
		# multi-letter id cannot slip past this while being caught there.
		hits=$(LC_ALL=C grep -nowE 'D[A-Z]*-[0-9]+' "$f")
		rc=$?
		# grep exits 1 for "no match" and 2+ for trouble — an unreadable file, a bad option on a
		# host whose grep is not GNU, no grep at all. Trouble read as "no citations" is the hollow
		# extraction this guard would otherwise report as a clean sweep.
		if [ "$rc" -gt 1 ]; then
			printf 'the citation scan of %s failed (grep exit %d) — this guard checked NOTHING there\n' "$f" "$rc"
			fails=$((fails + 1))
			continue
		fi
		scanned=$((scanned + 1))
		[ -n "$hits" ] || continue
		while IFS=: read -r line id; do
			[ -n "$line" ] || continue
			if resolves_in_ledger "$id"; then
				printf '%s:%s cites %s — a shipped artifact must name the row as "AMH ledger row %s" instead; that form is prose the citation scan does not read, and it makes no promise an adopter cannot keep\n' \
					"$f" "$line" "$id" "${id/-/}"
			else
				# The collision class the harness has already met once: a token like a debug
				# label is not a ledger id, but the citation pattern cannot tell. The recorded
				# remedy is a rename or a CITATION_EXCLUDE entry — never widening the pattern,
				# here or in the ladder.
				printf '%s:%s contains %s, which is not a row in this ledger but matches the citation pattern the adopter ladder uses — rename the token or add a CITATION_EXCLUDE entry; do not widen the pattern\n' \
					"$f" "$line" "$id"
			fi
			fails=$((fails + 1))
		done <<<"$hits"
	done
	set -f
done
set +f

# A guard that scanned nothing must say so rather than pass: a renamed directory, a changed
# layout or a glob that matched no file all look exactly like a clean sweep from the outside.
# The two empty states are distinguished, because "everything was excluded" and "there was
# nothing there" have different fixes.
if [ "$scanned" -eq 0 ]; then
	if [ "$matched" -gt 0 ]; then
		printf 'shipped-citations: all %d shipped file(s) were excluded or unreadable — this guard checked NOTHING\n' "$matched"
	else
		printf 'shipped-citations: the shipped globs matched no file — this guard checked NOTHING\n'
	fi
	exit 1
fi

[ "$fails" -eq 0 ] || exit 1
printf '%d shipped file(s) carry no real ledger citation (%d excluded)\n' "$scanned" "$excluded"
