#!/usr/bin/env bash
# Guard committed ledger rows against deletion or history-rewriting edits.
#
# Baseline is HEAD, deliberately: rows created in the current uncommitted unit are draft
# material until commit, but any row already committed at HEAD must remain present and
# byte-identical except for the two sanctioned metadata additions: adding `[cited]` to
# the row header and appending a strict standalone supersession pointer. Rows absent from
# HEAD are new rows and are length-checked before commit. The configured cap is named
# LEDGER_ROW_CHAR_CAP for the human rule, but the implementation deliberately counts
# bytes under LC_ALL=C: that is locale-stable across POSIX shells and matches the
# harness's existing byte-oriented size checks. ASCII text therefore counts as one byte per
# character; non-ASCII UTF-8 counts by encoded bytes, not Unicode scalar values. See DB-012.

set -uo pipefail

LEDGER_DIR=docs
LEDGER_BASENAME=LEDGER
LEDGER_ROW_CHAR_CAP=0
# shellcheck source=/dev/null
[ -f amh.conf ] && . ./amh.conf
SUPERSEDED_RE='^[[:space:]]*Superseded by D[A-Z]*-[0-9]+[.]$'

fail() { printf '%s\n' "$*"; exit 1; }

# The ladder's repo-local warn channel: exit 2 with `WARN ` as the first thing printed.
# One line, because the ladder prints it as the warn text verbatim.
warn_exit() { printf 'WARN %s\n' "$*"; exit 2; }

next_suffix() { # next_suffix <suffix>; empty input means A
	local s=${1:-} i c prefix last n
	if [ -z "$s" ]; then
		printf 'A'
		return
	fi
	i=$((${#s} - 1))
	c=${s:$i:1}
	prefix=${s:0:$i}
	if [ "$c" = Z ]; then
		printf '%sA' "$(next_suffix "$prefix")"
	else
		printf -v n '%d' "'$c"
		printf -v last '\\%03o' $((n + 1))
		# shellcheck disable=SC2059 # last is an octal escape produced above.
		printf '%s' "$prefix$(printf "$last")"
	fi
}

ledger_path() { # ledger_path <suffix>
	if [ -z "$1" ]; then
		printf '%s/%s.md' "$LEDGER_DIR" "$LEDGER_BASENAME"
	else
		printf '%s/%s_%s.md' "$LEDGER_DIR" "$LEDGER_BASENAME" "$1"
	fi
}

materialize_head_chain() { # materialize_head_chain <out-dir>
	local out=$1 suffix='' path next
	while :; do
		path=$(ledger_path "$suffix")
		if ! git cat-file -e "HEAD:$path" 2>/dev/null; then
			[ -n "$suffix" ] && break
			fail "ledger append-only: $path is absent from HEAD"
		fi
		mkdir -p "$out/$(dirname "$path")"
		git show "HEAD:$path" >"$out/$path" || exit 1
		next=$(next_suffix "$suffix")
		suffix=$next
	done
}

worktree_chain_paths() { # prints each worktree volume path, in chain order, live volume last
	local suffix='' path
	while :; do
		path=$(ledger_path "$suffix")
		[ -f "$path" ] || break
		printf '%s\n' "$path"
		suffix=$(next_suffix "$suffix")
	done
}

volume_named_by_prefix() { # volume_named_by_prefix <id>; DB-NNN -> docs/LEDGER_B.md, D-NNN -> docs/LEDGER.md
	local id=$1 suffix
	suffix=${id%%-*}   # D, DA, DB…
	suffix=${suffix#D} # '', A, B…
	ledger_path "$suffix"
}

volume_holding() { # volume_holding <id>; prints the first chain volume whose text carries the row
	local id=$1 path
	while IFS= read -r path; do
		LC_ALL=C grep -Eq "^- $id( \[cited\])?: " "$path" && { printf '%s' "$path"; return 0; }
	done < <(worktree_chain_paths)
	return 1
}

copy_worktree_chain() { # copy_worktree_chain <out-dir>
	local out=$1 suffix='' path next
	while :; do
		path=$(ledger_path "$suffix")
		if [ ! -f "$path" ]; then
			[ -n "$suffix" ] && break
			fail "ledger append-only: $path is absent from the working tree"
		fi
		mkdir -p "$out/$(dirname "$path")"
		cp "$path" "$out/$path" || exit 1
		next=$(next_suffix "$suffix")
		suffix=$next
	done
}

extract_rows() { # extract_rows <tree-dir> <rows-dir>
	local tree=$1 rows=$2 suffix='' path next
	mkdir -p "$rows"
	while :; do
		path=$(ledger_path "$suffix")
		[ -f "$tree/$path" ] || { [ -n "$suffix" ] && break; fail "ledger append-only: $path missing while extracting rows"; }
		awk -v out="$rows" '
			function flush(    file, n) {
				if (id == "") return
				n = count
				while (n > 1 && lines[n] == "") n--
				file = out "/" id
				for (i = 1; i <= n; i++) print lines[i] >file
				close(file)
				delete lines
				count = 0
			}
			/^- D[A-Z]*-[0-9]+( \[cited\])?: / {
				flush()
				id = $2
				sub(/ \[cited\]:$/, "", id)
				sub(/:$/, "", id)
				lines[++count] = $0
				next
			}
			id != "" { lines[++count] = $0 }
			END { flush() }
		' "$tree/$path" || exit 1
		next=$(next_suffix "$suffix")
		suffix=$next
	done
}


validate_row_cap() { # validate_row_cap <row-file> <id>
	local row=$1 id=$2 count
	case ${LEDGER_ROW_CHAR_CAP:-0} in
		''|*[!0-9]*) fail "ledger append-only: LEDGER_ROW_CHAR_CAP must be a non-negative integer, got '${LEDGER_ROW_CHAR_CAP:-}'" ;;
	esac
	[ "${LEDGER_ROW_CHAR_CAP:-0}" -gt 0 ] || return 0
	# Locale-stable character policy: count bytes with LC_ALL=C. For this Markdown ledger's
	# normal ASCII prose that is one byte per character; UTF-8 non-ASCII text is charged by
	# encoded bytes so the same row has the same verdict on every host locale.
	count=$(LC_ALL=C wc -c <"$row") || exit 1
	count=${count//[[:space:]]/}
	if [ "$count" -gt "$LEDGER_ROW_CHAR_CAP" ]; then
		fail "ledger append-only: $id is a new ledger row with $count byte-counted character(s), over LEDGER_ROW_CHAR_CAP=$LEDGER_ROW_CHAR_CAP — keep the durable lesson concise; historical committed rows and sanctioned metadata-only additions are exempt"
	fi
}

allowed_metadata_only() { # allowed_metadata_only <base-row> <current-row>
	local base=$1 current=$2 trimmed without_pointer base_cited=0
	# Normalize only the two sanctioned, additive metadata transitions before comparing:
	# an uncited header may gain `[cited]`, and one strict supersession sentence may be
	# appended. Removing `[cited]`, changing prose, or altering an existing pointer remains
	# a rewrite because normalization is deliberately one-way from current back to HEAD.
	trimmed=$(mktemp "$TMPDIR/ledger-row.XXXXXX") || exit 1
	cp "$current" "$trimmed" || { rm -f "$trimmed"; return 1; }
	LC_ALL=C sed -n '1{/^- D[A-Z]*-[0-9][0-9]* \[cited\]: /q0};q1' "$base" && base_cited=1
	if [ "$base_cited" -eq 0 ]; then
		LC_ALL=C sed '1s/^\(- D[A-Z]*-[0-9][0-9]*\) \[cited\]: /\1: /' "$trimmed" >"$trimmed.normalized" || exit 1
		mv "$trimmed.normalized" "$trimmed" || exit 1
	fi
	if cmp -s "$base" "$trimmed"; then
		rm -f "$trimmed"
		return 0
	fi
	# A baseline that already ends in a pointer cannot gain a second one. The comparison
	# above still permits that row to gain `[cited]` while preserving its committed pointer.
	LC_ALL=C tail -n 1 "$base" | LC_ALL=C grep -Eq "$SUPERSEDED_RE" && { rm -f "$trimmed"; return 1; }
	without_pointer=$(mktemp "$TMPDIR/ledger-row.XXXXXX") || exit 1
	awk -v re="$SUPERSEDED_RE" '
		{ lines[NR] = $0 }
		END {
			if (NR == 0 || lines[NR] !~ re) exit 1
			for (i = 1; i < NR; i++) print lines[i]
		}
	' "$trimmed" >"$without_pointer" || { rm -f "$trimmed" "$without_pointer"; return 1; }
	cmp -s "$base" "$without_pointer"
	local rc=$?
	rm -f "$trimmed" "$without_pointer"
	return "$rc"
}

if ! git rev-parse --verify -q HEAD >/dev/null; then
	printf 'ledger append-only: no HEAD commit yet; nothing to compare\n'
	exit 0
fi

if ! git diff --name-only HEAD -- "$LEDGER_DIR" | awk -v base="$LEDGER_BASENAME" '
	$0 == "docs/" base ".md" { found = 1 }
	$0 ~ "^docs/" base "_[A-Z]+[.]md$" { found = 1 }
	END { exit found ? 0 : 1 }
'; then
	printf 'no committed ledger rows changed against HEAD'
	exit 0
fi

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT
materialize_head_chain "$TMPDIR/head-tree"
copy_worktree_chain "$TMPDIR/work-tree"
extract_rows "$TMPDIR/head-tree" "$TMPDIR/head-rows"
extract_rows "$TMPDIR/work-tree" "$TMPDIR/work-rows"

checked=0
for base_row in "$TMPDIR"/head-rows/D*-*; do
	[ -e "$base_row" ] || fail 'ledger append-only: checked nothing in HEAD ledger rows'
	id=${base_row##*/}
	current_row="$TMPDIR/work-rows/$id"
	checked=$((checked + 1))
	if [ ! -f "$current_row" ]; then
		fail "ledger append-only: $id existed at HEAD but is missing from the working tree"
	fi
	if ! cmp -s "$base_row" "$current_row" && ! allowed_metadata_only "$base_row" "$current_row"; then
		fail "ledger append-only: $id existed at HEAD and was edited; only adding '[cited]' to its header and/or appending 'Superseded by D-NNN.' as a standalone final line is allowed"
	fi
done

live_volume=$(worktree_chain_paths | tail -n 1)

new_checked=0
misfiled=''
for current_row in "$TMPDIR"/work-rows/D*-*; do
	[ -e "$current_row" ] || continue
	id=${current_row##*/}
	[ -f "$TMPDIR/head-rows/$id" ] && continue
	new_checked=$((new_checked + 1))
	validate_row_cap "$current_row" "$id"
	# Two independent ways a new row can be filed wrong, and DB-015 is the second one, not
	# the first — a fact worth stating because checking only the obvious half would leave the
	# motivating incident uncovered while the prose claimed otherwise:
	#
	#   (a) it is not in the LIVE volume — the last one the chain walk reaches. New rows go
	#       at the end of the chain; a row appended to a closed volume is easy to miss because
	#       grep still finds it and every rung stays green.
	#   (b) its ID PREFIX names a different volume than the file it sits in. `DB-` resolves in
	#       LEDGER_B.md by the preambles' own rule, so a `D-` row in LEDGER_B.md dangles for a
	#       reader following that rule even though the file is the live one — and (a) alone is
	#       silent about it.
	#
	# Reported together because the fix is the same move and a session that hears one and not
	# the other will make the second mistake correcting the first.
	if ! home=$(volume_holding "$id"); then
		# Not reachable while the row extractor and this locator share a header pattern; if
		# they ever diverge, say so rather than skipping a row in silence — a `continue` here
		# would make the check hollow exactly when it stopped working.
		fail "ledger append-only: $id was extracted as a row but no volume in the chain carries its header — the extractor and the volume locator have diverged"
	fi
	expected=$(volume_named_by_prefix "$id")
	if [ "$home" != "$live_volume" ]; then
		misfiled="$misfiled $id(in $home, live volume is $live_volume)"
	elif [ "$home" != "$expected" ]; then
		misfiled="$misfiled $id(in $home, its prefix names $expected)"
	fi
done

# WARN, deliberately, and NOT a failure a later session should "tighten". There may be a
# genuine reason to append outside the live volume that nobody has enumerated yet (owner,
# 2026-08-09), and a rail that fails closed on an unenumerated legitimate case is one an
# adopter switches off rather than reads. The append-only rules above stay hard failures:
# this one is about WHERE a new row was filed, not whether history was rewritten.
if [ -n "$misfiled" ]; then
	warn_exit "ledger append-only: new row(s) filed where a reader following the ledger's own rules will not look —${misfiled}. New rows belong at the end of the live volume, and a D<prefix>-NNN id resolves in the volume its prefix names. Move the row, or say in the commit why this one belongs where it is. Adding [cited] or a supersession pointer to an existing row anywhere in the chain is unaffected. Checked $checked committed and $new_checked new row(s) against HEAD."
fi

printf 'checked %d committed ledger row(s) and %d new ledger row(s) against HEAD' "$checked" "$new_checked"
