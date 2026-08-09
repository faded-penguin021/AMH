#!/usr/bin/env bash
# Repo-local guard: a shipped script must not carry a real ledger citation.
#
# The ledger preambles' carve-out: a citation inside a SHIPPED script is not a citation at all
# in the tree that receives it. These rows are this repository's and can never exist in an
# adopter's ledger, so a hyphenated row id in a rail we hand out is a promise to resolve
# something that will not be there. The reasoning prose stays; the row is named in a form the
# citation scan does not read — `AMH ledger row DB016`, no hyphen.
#
# Why this needs a guard rather than reviewer attention: the failure is invisible from inside
# THIS repository and lands in someone else's. Here the row exists, the ladder's citation rung
# asks for a `[cited]` marker, the marker gets added, and everything is green. In an adopter's
# tree the same file cites an id their ledger has never heard of, their citation rung fails, and
# the file it names is one they are told never to edit. Every other rung in this repo would
# report that state as fine (DB-018).
#
# Scope is the shipped SCRIPTS, which is what the carve-out is about. Two things deliberately
# out of scope: the seed ledger's placeholder first row, which is the adopter's own row rather
# than a citation of ours, and the harness prose bundle, where an id appears as an illustration
# of the citation FORM.
#
# Note the trap this file fell into on its first run: an id written here as an EXAMPLE is a
# citation too, because this guard lives inside the citation scan. Say the shape in words.

set -uo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." || exit 1

SHIPPED_DIR=harness/templates/scripts
# The shipped fixture suite is the one file whose ledger ids are legitimate: they are fixture
# material — it synthesizes a ledger containing them — and the shipped `CITATION_EXCLUDE`
# default keeps that file out of every adopter's citation scan, so nothing there ever resolves
# against a real ledger. Excluded here for the same reason it is excluded there; if that config
# default ever changes, this exclusion is wrong and so is the one in amh.conf.
EXCLUDE_BASENAMES='test-ladder-guards.sh'

fails=0
scanned=0

for f in "$SHIPPED_DIR"/*.sh; do
	[ -f "$f" ] || continue
	base=${f##*/}
	skip=0
	for ex in $EXCLUDE_BASENAMES; do
		[ "$base" = "$ex" ] && skip=1
	done
	[ "$skip" -eq 1 ] && continue
	scanned=$((scanned + 1))
	# Whole-word, and the same unbounded volume pattern the ladder's citation rung uses, so a
	# multi-letter id cannot slip past this while being caught there.
	while IFS=: read -r line id; do
		[ -n "$line" ] || continue
		printf '%s:%s cites %s — a shipped script must name the row as "AMH ledger row %s" instead; that form is prose the citation scan does not read, and it makes no promise an adopter cannot keep\n' \
			"$f" "$line" "$id" "${id/-/}"
		fails=$((fails + 1))
	done < <(LC_ALL=C grep -nowE 'D[A-Z]*-[0-9]+' "$f")
done

# A guard that scanned nothing must say so rather than pass: a renamed directory, a changed
# layout or a glob that matched no file all look exactly like a clean sweep from the outside.
if [ "$scanned" -eq 0 ]; then
	printf 'shipped-citations: found no shipped scripts under %s — this guard checked NOTHING\n' "$SHIPPED_DIR"
	exit 1
fi

[ "$fails" -eq 0 ] || exit 1
printf '%d shipped script(s) carry no real ledger citation' "$scanned"
