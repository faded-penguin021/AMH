#!/usr/bin/env bash
# Repo-local guard: repo-relative paths named in prose actually exist.
#
# Admitted under AMH P20's incident bar, which requires a claim to have DRIFTED before
# it earns a guard. It has, three times, in one review: docs cited scripts/amh-init.sh,
# CONTRIBUTING.md and a version-lockstep guard that did not exist, and playbook 5 was
# unfollowable because of it. That also overturns the "no markdown link checker"
# decided non-item, which rested on "no broken link has cost anything yet".
#
# Deliberately narrow. It checks CODE — whether a path exists — never prose meaning,
# and it never touches the network. It is a tripwire for the drift class that already
# bit us, not a documentation test framework.

set -uo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." || exit 1

# Default matches scripts/ladder.sh's; amh.conf overrides it below. Only the baseline ref is
# read from configuration — this guard resolves paths, and a second knob would be a second
# thing to keep in step.
DEFAULT_BRANCH=main
# shellcheck source=/dev/null
[ -f amh.conf ] && . ./amh.conf

fails=0
checked=0
listed=0
scanned=0
historical_ledger_paths=0
unclassified=0
unclassified_detail=''

# A ledger ROW is immutable; the file it names is not. Those are different objects, and
# conflating them is what made a completed plan undeletable (DC-039, DD-003): the row's text
# cannot follow a rename, so a guard that demands the cited path exist FOREVER converts one
# immutable sentence into a permanent retention rule for another tier's file.
#
# The rule this implements instead: a ledger path must resolve in the tree in which the ROW IS
# AUTHORED, and after that it is history. Three verdicts, and the third exists because the
# second and third are genuinely different states:
#
#   0 — established immutable reference. The row predates the target's move or deletion; the
#       missing target is historical ledger-path drift and is counted, not failed.
#   1 — the reference must resolve. Either the row is part of the current change (a NEW
#       citation, which must resolve in the resulting tree), or the row is committed but its
#       target was ALREADY ABSENT when the row was introduced — invalid at authoring, and no
#       amount of age makes it valid. That second case is why this does not merely search for
#       any old commit in which the pathname existed.
#   3 — unclassifiable. Reachable history cannot show which commit introduced the row and the
#       configured default-branch baseline does not carry it either. Reported as an explicit
#       WARN: "I could not look" is not "I looked and it was fine", and it is not a newly
#       broken path either (DC-002's direction rule).
#
# Deliberately ledger-ROW-only. Ordinary documentation is editable and must follow a target
# when it moves, and so must a ledger volume's PREAMBLE, which is editable legislation rather
# than an immutable row — an occurrence outside any row therefore takes verdict 1.

# Every path this guard resolves is either a repo-root path or a bare basename, so the
# existence test at a historical commit needs both modes.
target_exists_at() { # target_exists_at <commit> <path|basename> <target>
	local names
	case $2 in
	path) git cat-file -e "$1:$3" 2>/dev/null ;;
	basename)
		# quotePath off for the same reason the tree listing below turns it off: a non-ASCII
		# path would arrive as a quoted C-string and leave a stray `"` on the basename.
		names=$(git -c core.quotePath=false ls-tree -r --name-only "$1" 2>/dev/null | sed 's#.*/##')
		# A here-string, never `printf | grep -q`: an early-exiting reader on a pipeline makes
		# a SUCCESSFUL match read as failure under `pipefail` (DC-034, corrected by DC-035).
		grep -qxF -- "$3" <<<"$names"
		;;
	*) return 1 ;;
	esac
}

# One row's text, sliced out of a whole volume: its header line through the line before the next
# row header. Same slicing `rows_containing` does on the worktree, so the two agree about where a
# row ends.
row_block() { # row_block <volume-text> <row-id>
	id=$2 awk '
		/^- D[A-Z]*-[0-9]+( \[cited\])?: / {
			hdr = $2
			sub(/:$/, "", hdr)
			inrow = (hdr == ENVIRON["id"])
		}
		inrow
	' <<<"$1"
}

# Whether <ref> carries the reference token INSIDE the named row. Scoped to the row, never to the
# volume: a token that merely appears somewhere else in the same file says nothing about this row,
# and matching volume-wide would let a citation freshly inserted into an old immutable row inherit
# that row's authoring date whenever any other row already carried the same path. An empty block
# means the row is not in <ref> at all, which is the "part of the current change" answer.
row_in_ref() { # row_in_ref <ref> <ledger-file> <row-id> <reference-token>
	local blob block
	blob=$(git show "$1:$2" 2>/dev/null) || return 1
	[ -n "$blob" ] || return 1
	block=$(row_block "$blob" "$3")
	[ -n "$block" ] || return 1
	grep -qF -- "$4" <<<"$block"
}

classify_row() { # classify_row <ledger-file> <row-id> <path|basename> <target> <reference-token>
	local f=$1 id=$2 mode=$3 target=$4 tok=$5 intros intro parents
	# Not committed yet, or the token is not in the committed row: the citation belongs to the
	# current change and must resolve in the resulting tree.
	row_in_ref HEAD "$f" "$id" "$tok" || return 1
	# The commit that introduced the row. The search string is `- <id>` WITHOUT the colon, so the
	# count is unchanged by the later commit that adds ` [cited]` to the header and that commit is
	# never reported; `--reverse` and the FIRST line are what pick the introduction out of any
	# other commit the pickaxe does report, such as a volume-wide rewrite. The row identifiers in
	# this ledger are fixed-width, so `- <id>` cannot be a prefix of a longer identifier's header;
	# a ledger that renumbered or widened its ids would need a stricter pattern here.
	#
	# Read into a variable and split, never `| head -1`: an early-exiting reader is the
	# fail-open pipeline shape this repository has already been bitten by twice.
	intros=$(git log --reverse --format=%H -S"- $id" -- "$f" 2>/dev/null)
	intro=${intros%%$'\n'*}
	# A PARENTLESS introducing commit is an import boundary, not an authoring event, and it does
	# not settle the question. Two things produce one and they are indistinguishable from here: a
	# shallow clone's boundary commit is grafted to look parentless, so every file in it reads as
	# "added here" and the pickaxe names it for a row it did not introduce; and a synthetic root
	# commit (a squash import, a throwaway fixture repo) contains a row whose authoring tree was
	# never recorded. Answering from either would be inventing the answer, so the search falls
	# through to the baseline and, failing that, to verdict 3.
	if [ -n "$intro" ]; then
		parents=$(git rev-list --parents -n 1 "$intro" 2>/dev/null)
		parents=${parents#"$intro"}
		parents=${parents// /}
		[ -n "$parents" ] || intro=''
	fi
	if [ -n "$intro" ]; then
		target_exists_at "$intro" "$mode" "$target" && return 0
		return 1
	fi
	# No usable history. A row already carried by the configured default-branch baseline is
	# established immutable history by the only evidence left — and this arm is a FALLBACK, never
	# the first question, because it is strictly weaker than the history test above.
	#
	# `baseline_is_informative` is what keeps it from being weaker than nothing. Where the
	# baseline resolves to the SAME COMMIT as HEAD — a shallow clone of the default branch, CI on
	# main, a fixture repo whose only branch is main — "the row is in the baseline" degrades to
	# "the row is committed", which is already true of every row that reaches here. Returning an
	# exemption on that would print a never-valid citation as a settled historical drift, which is
	# the one thing verdict 3 exists to prevent: "I could not look" reported as author-time proof.
	[ "$baseline_is_informative" = true ] &&
		row_in_ref "$baseline" "$f" "$id" "$tok" && return 0
	return 3
}

# The row identifiers whose text carries <token>, one per line; `-` for an occurrence that
# falls outside every row, which is the volume's editable preamble.
rows_containing() { # rows_containing <ledger-file> <reference-token>
	tok=$2 awk '
		/^- D[A-Z]*-[0-9]+( \[cited\])?: / { id = $2; sub(/:$/, "", id) }
		index($0, ENVIRON["tok"]) > 0 { print (id == "" ? "-" : id) }
	' "$1" | sort -u
}

classify_ledger_reference() { # classify_ledger_reference <markdown-file> <path|basename> <target> <reference-token>
	local f=$1 mode=$2 target=$3 tok=$4 ids id verdict worst=0 seen=0
	case $f in docs/LEDGER*.md) ;; *) return 1 ;; esac
	git rev-parse --verify -q HEAD >/dev/null 2>&1 || return 1
	ids=$(rows_containing "$f" "$tok")
	[ -n "$ids" ] || return 1
	while IFS= read -r id; do
		[ -n "$id" ] || continue
		# An occurrence in the preamble: editable legislation, no exemption, and one is
		# enough to disqualify the whole reference.
		[ "$id" = '-' ] && return 1
		seen=1
		verdict=0
		classify_row "$f" "$id" "$mode" "$target" "$tok" || verdict=$?
		[ "$verdict" -eq 1 ] && return 1
		[ "$verdict" -eq 3 ] && worst=3
	done <<<"$ids"
	[ "$seen" -eq 1 ] || return 1
	return "$worst"
}

# The default-branch baseline, remote-tracking copy first: a session branch has the remote ref,
# and a checkout that only has the local branch still answers the same question.
baseline=''
baseline_is_informative=false
for ref in "refs/remotes/origin/$DEFAULT_BRANCH" "refs/heads/$DEFAULT_BRANCH"; do
	if git rev-parse --verify -q "$ref^{commit}" >/dev/null 2>&1; then
		baseline=$ref
		break
	fi
done
if [ -n "$baseline" ]; then
	baseline_commit=$(git rev-parse --verify -q "$baseline^{commit}" 2>/dev/null)
	head_commit=$(git rev-parse --verify -q 'HEAD^{commit}' 2>/dev/null)
	# Both must resolve AND differ. Equal means the baseline carries no information this checkout
	# does not already have; empty means one of them did not resolve, and an unread ref is not a
	# baseline either.
	[ -n "$baseline_commit" ] && [ -n "$head_commit" ] &&
		[ "$baseline_commit" != "$head_commit" ] && baseline_is_informative=true
fi

# Three states, three sentences, because the WARN line has to say which one it hit: a reader who
# cannot tell "there is no baseline" from "the baseline is this very commit" cannot tell whether
# fetching one would help.
if [ -z "$baseline" ]; then
	baseline_description="default-branch ($DEFAULT_BRANCH, no such ref here)"
elif [ "$baseline_is_informative" = true ]; then
	baseline_description="$baseline"
else
	baseline_description="$baseline (which is this very commit, so it carries no information)"
fi

# Both listings this guard takes come from `git ls-files`, and neither could tell a listing
# that FAILED from a tree with nothing to say. The two hollow states are opposite failures:
# an empty `basenames` reports every bare citation in section (c) as cited nowhere, while an
# empty file list prints a green count over a scan that never happened — DC-002's own shape, a
# list read through a process substitution whose empty read took the "nothing to object to"
# branch. Which is which matters, and reading the symptom back to front is easy: a listing
# that fails UNIFORMLY lands on the GREEN state, because the markdown loop then never runs.
# The false failure — one run reported `session-start.sh`, a file that exists, as cited
# nowhere — needs the tree listing to come back short while the markdown one still succeeds.
#
# So the exit STATUS is checked and not only the emptiness: git dying part way through leaves
# plausible output behind, and only the status says it did. On the tree branch that status is
# the whole pipeline's rightmost non-zero — a failing `sort` renders identically — so the
# message attributes it to nothing, having established no cause. What none of this reaches is
# a short listing git completed and reported success for; that residue stays in the queue.
#
# Two messages rather than one: "it failed" and "it found nothing" have different fixes, and a
# status of 0 printed beside the word FAILED would describe the second as the first.
listing_failed() { # listing_failed <which> <exit-status>
	printf 'path-refs: the %s listing FAILED (exit %s) — this guard checked NOTHING\n' "$1" "$2"
	exit 1
}
listing_empty() { # listing_empty <which>
	printf 'path-refs: the %s listing named no file at all — this guard checked NOTHING\n' "$1"
	exit 1
}

# Every tracked/untracked file's BASENAME, for section (c). Computed once: the check runs
# per citation, and re-listing the tree for each would be quadratic in a docs set that only
# grows.
#
# `[ -e ]` per path, because `git ls-files` answers from the INDEX. A file deleted with
# plain `rm` is still listed, so without this the guard's own headline incident — five
# citations to a missing CONTRIBUTING.md — passes green, and the only signal is `grep`
# complaining on stderr while the rung prints ok. A guard whose failure is quieter than its
# pass is the D-019 shape.
#
# NUL-separated with quotePath off: `git ls-files` renders a non-ASCII path as a quoted
# C-string, which would leave a stray `"` on the basename.
basenames=$(git -c core.quotePath=false ls-files -co --exclude-standard -z |
	while IFS= read -r -d '' p; do
		# An `if` rather than `[ -e "$p" ] && printf`: under `pipefail` the loop's status is
		# its last command's, so a final path that no longer exists would report the listing
		# as failed and make the check below a false alarm of its own.
		if [ -e "$p" ]; then printf '%s\n' "${p##*/}"; fi
	done | sort -u)
rc=$?
[ "$rc" -eq 0 ] || listing_failed tree "$rc"
[ -n "$basenames" ] || listing_empty tree

# The markdown listing goes through a file rather than a process substitution, for the same
# reason: `done < <(git ls-files ...)` discards the status, so a listing that failed reads as
# a tree with no documents in it and the guard prints its green count over nothing. Here the
# status IS git's own, the command being alone in the pipeline.
md_files=$(mktemp) || {
	printf 'path-refs: no temporary file could be created — this guard checked NOTHING\n'
	exit 1
}
trap 'rm -f "$md_files"' EXIT
git ls-files -co --exclude-standard -z '*.md' >"$md_files"
rc=$?
[ "$rc" -eq 0 ] || listing_failed markdown "$rc"
[ -s "$md_files" ] || listing_empty markdown

# harness/dist is generated (dist-drift owns it); harness/templates and harness/src
# describe an ADOPTER's tree, where the paths are meant to resolve there, not here.
#
# NUL-separated: `for f in $files` word-splits the list, so a file whose name contains
# a space is skipped in silence and the guard still prints a count and a green line.
# scripts/ladder.sh forbids exactly this in the secret scan ("a scan with a silent hole
# is worse than no scan"), and the harness prose calls it a blocker-class hole.
while IFS= read -r -d '' f; do
	listed=$((listed + 1))
	# docs/plans/ describes an INTENDED tree the same way harness/templates describes an
	# adopter's: a plan that may not name a file it has not built yet is the normal case,
	# not drift. What a plan actually delivered is settled by the ladder against the real
	# tree, never by this guard.
	#
	# docs/history/ is the mirror of that, and it is excluded for the mirrored reason (owner,
	# 2026-09-02, DD-005): an archived document describes a tree that no longer exists. The
	# archive is frozen — `docs/history/README.md` and AMH P2 both say never edit what is in it —
	# so scanning it builds DD-004's trap one tier down: a path named in a frozen file that later
	# moves turns the tree red, and the only repair is to edit a file the rules forbid editing.
	# The alternative considered and declined was dropping the frozen rule so history could follow
	# renames; the archive's whole point is that it does not change.
	case $f in
	harness/dist/* | harness/templates/* | harness/src/* | docs/plans/* | docs/history/*) continue ;;
	esac
	scanned=$((scanned + 1))
	dir=$(dirname "$f")

	# (a) Markdown links with a relative target: [text](path). Skip URLs, anchors and
	#     mailto. Strip any #fragment. Resolved relative to the linking file.
	while IFS= read -r target; do
		[ -n "$target" ] || continue
		case $target in
		http*://* | '#'* | mailto:* | /*) continue ;;
		*'{{'* | *'<'* | *'*'*) continue ;;
		esac
		target=${target%%#*}
		[ -n "$target" ] || continue
		checked=$((checked + 1))
		if [ ! -e "$dir/$target" ]; then
			repo_target=$(realpath -m --relative-to=. "$dir/$target")
			verdict=0
			classify_ledger_reference "$f" path "$repo_target" "]($target)" || verdict=$?
			case $verdict in
			0) historical_ledger_paths=$((historical_ledger_paths + 1)) ;;
			3)
				unclassified=$((unclassified + 1))
				unclassified_detail="$unclassified_detail $f:[..]($target)"
				;;
			*)
				printf 'broken link in %s: [..](%s)\n' "$f" "$target"
				fails=$((fails + 1))
				;;
			esac
		fi
	done < <(grep -oE '\]\([^)]+\)' "$f" | sed 's/^](//; s/)$//')

	# (b) Backticked paths that look like real repo paths: contain a slash, end in a
	#     known extension, and carry no glob, placeholder or shell expansion. Resolved
	#     from the repo root, which is how prose here names files.
	#
	# The extraction is hoisted out of the loop so its SC2016 waiver covers ONE command.
	# A directive cannot sit before `done < <(...)` (SC1123), and putting it on the whole
	# `while` silenced SC2016 for the entire body — a waiver that wide stops being a
	# waiver and becomes a blind spot.
	# shellcheck disable=SC2016 # backticks are the pattern's own syntax: this matches
	# markdown code spans literally, so single quotes are required, not a slip.
	backticked=$(grep -oE '`[A-Za-z0-9_./-]+/[A-Za-z0-9_./-]+\.(md|sh|json|yml|yaml|conf)`' "$f" | tr -d '`' | sort -u)
	while IFS= read -r target; do
		[ -n "$target" ] || continue
		case $target in
		*'*'* | *'{{'* | *'$'* | *'<'* | /* | http*) continue ;;
		esac
		checked=$((checked + 1))
		if [ ! -e "$target" ]; then
			verdict=0
			classify_ledger_reference "$f" path "$target" "\`$target\`" || verdict=$?
			case $verdict in
			0) historical_ledger_paths=$((historical_ledger_paths + 1)) ;;
			3)
				unclassified=$((unclassified + 1))
				unclassified_detail="$unclassified_detail $f:\`$target\`"
				;;
			*)
				# shellcheck disable=SC2016 # literal backticks: the message quotes the citation
				# back in the same markdown form the prose used. No expansion wanted.
				printf 'nonexistent path cited in %s: `%s`\n' "$f" "$target"
				fails=$((fails + 1))
				;;
			esac
		fi
	done <<<"$backticked"

	# (c) Backticked BARE filenames: `CONTRIBUTING.md`, `ladder.sh`, `ci.yml`. Pattern (b)
	#     requires an embedded slash, so a repo-ROOT file could never match it — and that
	#     is not a theoretical gap. `CONTRIBUTING.md` was cited five times, listed in
	#     RULE_FILES, and did not exist, while this guard reported every reference
	#     resolving; the guard was admitted to close that exact incident and was blind to
	#     half of it.
	#
	#     Resolved by BASENAME anywhere in the tree, NOT as a path from the repo root.
	#     That distinction is the whole design. Widening (b) to bare filenames resolved
	#     from the root was tried and rejected at 24 hits for 2 true positives, because
	#     `STATE.md` and `ci.yml` are simply how the prose refers to `docs/STATE.md` and
	#     `.github/workflows/ci.yml` — a guard that reports those as broken teaches
	#     everyone to skim past it, which costs more than the drift it catches.
	#
	#     The residue this accepts: a name that is deliberately hypothetical (a future
	#     ledger volume) or historical (a path being quoted BECAUSE it was wrong) reads
	#     as a citation. There is no way to tell those apart mechanically, so the prose
	#     stops code-spanning them — a name in backticks is a citation, and a name that
	#     is not a citation should not be in backticks.
	#
	# Hoisted out of the loop so the SC2016 waiver covers this ONE command; a directive
	# cannot sit before `done < <(...)`, and putting it on the `while` silences SC2016
	# for the entire body (D-021).
	# shellcheck disable=SC2016 # backticks are the pattern's own syntax: this matches
	# markdown code spans literally, so single quotes are required, not a slip.
	bare=$(grep -oE '`[A-Za-z0-9_.-]+\.(md|sh|json|yml|yaml|conf)`' "$f" | tr -d '`' | sort -u)
	while IFS= read -r target; do
		[ -n "$target" ] || continue
		checked=$((checked + 1))
		# A here-string, NOT `printf ... | grep -q`, and the difference is a false FAILURE
		# rather than a style preference. `grep -q` exits the moment it matches; if the
		# writer still has bytes pending, its next write lands on a closed pipe and bash's
		# printf builtin returns non-zero with `write error: Broken pipe`. This file runs
		# under `pipefail`, which promotes that to the pipeline's status — so a SUCCESSFUL
		# match reads as a failure and the guard reports a file that exists as cited
		# nowhere. Whether the write is split at all is the platform's business: a
		# single write into a pipe with room never notices the reader leaving, so this
		# repository's ~1 KB basename list is safe on a host that writes it in one go and
		# is not on one that does not. It reached CI as `path-refs.sh` failing on
		# `AGENTS.md` on macOS while every Linux run stayed green. The here-string works
		# because its writer is NOT a pipeline member: nothing it does reaches
		# `PIPESTATUS`, so `pipefail` has nothing to promote. Bash backs one with a
		# temporary file only ABOVE the pipe-buffer size — below that it is a pipe too —
		# so "a file rather than a pipe" would be a reason that fails exactly where the
		# defect lives, and a reader on bash >= 5.1 could wrongly think the fix void
		# (DC-034, corrected by DC-035).
		if ! grep -qxF -- "$target" <<<"$basenames"; then
			# The same three verdicts as (a) and (b). A bare name resolves by BASENAME, so the
			# historical existence test at the row's introducing commit has to ask the same
			# question of that commit's tree rather than of one path.
			verdict=0
			classify_ledger_reference "$f" basename "$target" "\`$target\`" || verdict=$?
			case $verdict in
			0) historical_ledger_paths=$((historical_ledger_paths + 1)) ;;
			3)
				unclassified=$((unclassified + 1))
				unclassified_detail="$unclassified_detail $f:\`$target\`"
				;;
			*)
				# shellcheck disable=SC2016 # literal backticks: the message quotes the citation
				# back in the same markdown form the prose used. No expansion wanted.
				printf 'no file by that name anywhere in the tree, cited in %s: `%s`\n' "$f" "$target"
				fails=$((fails + 1))
				;;
			esac
		fi
	done <<<"$bare"
done <"$md_files"

# The listing was non-empty and every file in it was excluded, so nothing was read after all.
# `shipped-citations.sh` refuses this state AFTER its exclusions rather than before, and the
# reason it gives is this one: a renamed directory or a changed layout looks exactly like a
# clean sweep from outside. Counting CITATIONS instead would be wrong — a document that cites
# nothing legitimately resolves zero — so what is counted is files that survived the `case`.
if [ "$scanned" -eq 0 ]; then
	printf 'path-refs: all %d markdown file(s) listed are outside the scan — this guard checked NOTHING\n' "$listed"
	exit 1
fi

if [ "$fails" -ne 0 ]; then
	# Named even on the red path: an unclassified reference is not one of the failures above,
	# and letting it disappear behind them would report a state nobody looked at as settled.
	[ "$unclassified" -eq 0 ] ||
		printf 'path-refs: %d further committed ledger reference(s) could NOT be classified —%s\n' \
			"$unclassified" "$unclassified_detail"
	exit 1
fi

# WARN, not a failure and not a pass. The reference is committed, its target is gone, and this
# checkout carries neither the history that would show the row's authoring tree nor a
# default-branch baseline carrying the row. Failing closed would redden a clean tree on a
# property of the CHECKOUT; passing would report "I did not manage to look" as author-time
# proof. The warn text is one line, and it is the first thing this guard prints — the ladder
# reads the merged output's first line as the warning verbatim.
if [ "$unclassified" -gt 0 ]; then
	printf 'WARN path-refs: %d committed ledger reference(s) whose target is missing could NOT be classified from this checkout —%s. Neither reachable history nor the %s baseline shows the commit that introduced the citing row, so whether the path resolved when the row was authored is UNKNOWN, not proven either way. A full-history checkout (CI uses fetch-depth 0) answers it; %d other path reference(s) resolved across %d file(s), with %d historical ledger path drift exemption(s).\n' \
		"$unclassified" "$unclassified_detail" "$baseline_description" \
		"$checked" "$scanned" "$historical_ledger_paths"
	exit 2
fi

printf '%s path reference(s) resolve across %d file(s); %d historical ledger path drift exemption(s)\n' "$checked" "$scanned" "$historical_ledger_paths"
