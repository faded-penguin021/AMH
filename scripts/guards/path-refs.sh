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

fails=0
checked=0
listed=0
scanned=0

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
	case $f in
	harness/dist/* | harness/templates/* | harness/src/* | docs/plans/*) continue ;;
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
			printf 'broken link in %s: [..](%s)\n' "$f" "$target"
			fails=$((fails + 1))
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
			# shellcheck disable=SC2016 # literal backticks: the message quotes the citation
			# back in the same markdown form the prose used. No expansion wanted.
			printf 'nonexistent path cited in %s: `%s`\n' "$f" "$target"
			fails=$((fails + 1))
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
			# shellcheck disable=SC2016 # literal backticks: the message quotes the citation
			# back in the same markdown form the prose used. No expansion wanted.
			printf 'no file by that name anywhere in the tree, cited in %s: `%s`\n' "$f" "$target"
			fails=$((fails + 1))
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

[ "$fails" -eq 0 ] || exit 1
printf '%s path reference(s) resolve across %d file(s)\n' "$checked" "$scanned"
