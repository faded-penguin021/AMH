#!/usr/bin/env bash
# Guard committed ledger rows against deletion or history-rewriting edits.
#
# Baseline is HEAD, deliberately: rows created in the current uncommitted unit are draft
# material until commit, but any row already committed at HEAD must remain present and
# byte-identical except for a strict standalone supersession pointer.

set -uo pipefail

LEDGER_DIR=docs
LEDGER_BASENAME=LEDGER
SUPERSEDED_RE='^[[:space:]]*Superseded by D[A-Z]*-[0-9]+[.]$'

fail() { printf '%s\n' "$*"; exit 1; }

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

allowed_superseded_only() { # allowed_superseded_only <base-row> <current-row>
	local base=$1 current=$2 trimmed
	# The only permitted edit to an existing row is appending one standalone strict sentence.
	trimmed=$(mktemp "$TMPDIR/ledger-row.XXXXXX") || exit 1
	awk -v re="$SUPERSEDED_RE" '
		{ lines[NR] = $0 }
		END {
			if (NR == 0 || lines[NR] !~ re) exit 1
			for (i = 1; i < NR; i++) print lines[i]
		}
	' "$current" >"$trimmed" || { rm -f "$trimmed"; return 1; }
	cmp -s "$base" "$trimmed"
	local rc=$?
	rm -f "$trimmed"
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
	if ! cmp -s "$base_row" "$current_row" && ! allowed_superseded_only "$base_row" "$current_row"; then
		fail "ledger append-only: $id existed at HEAD and was edited; only appending 'Superseded by D-NNN.' as a standalone final line is allowed"
	fi
done

printf 'checked %d committed ledger row(s) against HEAD' "$checked"
