# H2 — what moved out of the constitution, and where

> **Companion to `docs/plans/2026-11-01-harness-research-gaps.md`, unit H2. Done 2026-11-13 on
> input revision `cbbea8f`.** `AGENTS.md` there is byte-identical to H1's input revision
> `9ea4cee`, so the item IDs below are H1's (its §6.1). H1's inventory stays frozen at `9ea4cee`
> and is not redone (the plan's §7.1). The record of the move is this file, the ledger row
> **DD-080** and the STATE changelog line.

## 1. Owner decisions, 2026-11-13

- **§1 item 9, the evidence:** the always-loaded text is too big, and the survey's principle 4
  says to keep it small. No incident; the owner accepted this as the problem H2 answers.
- **§1 item 3, the selection:** move the description (C) and rationale (R) items of A042, A026
  and A003 into a new task-triggered runbook section. Keep every binding (B) item in `AGENTS.md`.
  Leave the seed constitution to H3: at the default light profile an adopter has no
  `docs/RUNBOOK.md` (**DD-075**), so a move there would be unreachable, and H3 decides the layout.
- **§1 item 2, the version:** the whole plan rides the 17.0.0 draft. H2 changes nothing an
  adopter receives (no seed, template or shipped script), so it adds no harness changelog entry.
- **Reviewer:** one blocking `gpt-6-astra -e high` pass, as the owed rule review.

## 2. The mapping

Every moved item keeps its scope. Its destination is a runbook section, and its binding
declaration is the `AGENTS.md` sentence that names that section and says when to read it.
`scripts/guards/doc-navigation.sh` checks each pointer and heading.

| Item | Type | Original scope | Destination | Retrieval trigger and binding declaration |
|---|---|---|---|---|
| A042.2 | C | hook-less agent | **Host rails and what they miss**, "The command rail." | A042.1, now: "Know which rails your own session actually has: read `docs/RUNBOOK.md` → **Host rails and what they miss** before you count on a rail to stop a command, before your first push of a session, when a hook or the host refuses a call, before your first command through a PowerShell tool, before you change an adapter, a hook or a guard, and at the start of a session on Windows or one started with a flag that changes which settings or hooks the host loads." The section's preamble repeats it. |
| A042.3–.5 | C | push | same paragraph | same; "before your first push of a session" |
| A042.7 | C | Claude Code host modes | "Host modes and machine mode." | same; "a flag that changes which settings or hooks the host loads" |
| A042.8 | C | machine mode | same paragraph | same |
| A042.10 | C | PowerShell routing | "PowerShell, and the Claude adapter's hooks." | same; "before your first command through a PowerShell tool" |
| A042.11–.12 | C | the Claude adapter, Windows | same paragraph | same; "when a hook or the host refuses a call", "a session on Windows" |
| A026.4 | C | destructive commands | "The command guard's deletion rails." | A second pointer, in **Hard boundaries** where the item stood: "Before your first bulk deletion of a session — a recursive one, or one made through an interpreter — read which deletions the command guard refuses for good and which buy only an advisory: `docs/RUNBOOK.md` → **Host rails and what they miss**." |
| A026.7 | C | destructive commands | same paragraph | same |
| A003.4–.5 | R, C | an edit of `AGENTS.md` | **Rule-review protocol**, "On the size of the constitution." | A003.3, unchanged: "moving anything out of this file takes the rule-review protocol". Every edit of `AGENTS.md` is a legislation diff, which makes that section a mandatory read. |

Two binding sentences stayed in `AGENTS.md` and changed words:

- A042.1, from "Know which rails your own session actually has." to the pointer above.
- A042.9 named its antecedent, because A042.8 moved: "Installing or refreshing a machine-mode copy of the guard
  (`command-guard.sh --machine`) changes files outside the repository, so it takes the owner's
  explicit yes, never your judgement (**DD-066**)."

Three words changed in moved text, each because the original pointed at `AGENTS.md` from inside it:

- "these rules are the only layer" became "the written rules are the only layer";
- "the CLAUDE.md that points here" became "the CLAUDE.md that points at `AGENTS.md`";
- "No byte cap governs this file" became "No byte cap governs `AGENTS.md`".

## 3. Where the unit departs from the approved selection

- **A003.4–.5 went to the Rule-review protocol, not the new section.** Their trigger is an edit
  of `AGENTS.md`, and that section is what such an edit already makes mandatory. A section about
  host rails would never be read at that moment, and lesson 3 rejects such a destination.
- **A026.3 stayed in `AGENTS.md`.** It is the rationale for a demonstration that stays in the
  hard boundary, and **Add a guard** already gives it in other words ("The demonstration is the
  suite, never the real operation"). A verbatim copy there would duplicate it, and deleting it
  would fail acceptance (a). It is 151 bytes.
- **A042.6 stayed in `AGENTS.md`**, word for word, after the owed review. H1 typed it R, but it
  carries a prohibition: "one vendor's environment variables, which the harness may not assume".
  Every binding item stays, so it stays (§6).

## 4. Acceptance

**(a) Word for word.** `h2-verbatim.py` (§8), run as
`python3 -I h2-verbatim.py <AGENTS.md at cbbea8f> AGENTS.md docs/RUNBOOK.md`, exit 0:

```text
removed sentences: 17
  MOVED, DECLARED SUBSTITUTION -> ## Rule-review protocol (MANDATORY for binding-rule and guard diffs)   [A003.4]
  MOVED VERBATIM -> ## Rule-review protocol (MANDATORY for binding-rule and guard diffs)                 [A003.5]
  MOVED VERBATIM -> ## Host rails and what they miss                                                   [A026.4]
  MOVED VERBATIM -> ## Host rails and what they miss                                                   [A026.7]
  REWORDED IN PLACE (kept in AGENTS.md)                                                                [A042.1]
  MOVED, DECLARED SUBSTITUTION -> ## Host rails and what they miss                                     [A042.2]
  MOVED VERBATIM -> ## Host rails and what they miss                                                   [A042.3]
  MOVED VERBATIM -> ## Host rails and what they miss                                                   [A042.4]
  MOVED VERBATIM -> ## Host rails and what they miss                                                   [A042.5]
  MOVED, DECLARED SUBSTITUTION -> ## Host rails and what they miss                                     [A042.7]
  MOVED VERBATIM -> ## Host rails and what they miss                                                   [A042.8, 1 of 3]
  MOVED VERBATIM -> ## Host rails and what they miss                                                   [A042.8, 2 of 3]
  MOVED VERBATIM -> ## Host rails and what they miss                                                   [A042.8, 3 of 3]
  REWORDED IN PLACE (kept in AGENTS.md)                                                                [A042.9]
  MOVED VERBATIM -> ## Host rails and what they miss                                                   [A042.10]
  MOVED VERBATIM -> ## Host rails and what they miss                                                   [A042.11]
  MOVED VERBATIM -> ## Host rails and what they miss                                                   [A042.12]
sentences added to AGENTS.md: 3
verdict: PASS (0 unplaced)
```

The item IDs in brackets were added here; the script prints each sentence's opening instead.
It was made to fail before it was trusted. Changing "bypasses" to "skips" in one moved
sentence, in a scratch copy of the runbook, gave `FAIL (0 destination matches)` and exit 1.
Deleting the A003 paragraph from a copy gave `FAIL (2 unplaced)`. A first mutation aimed at a
sentence that wraps across a line changed nothing, and was redone on a phrase that does not
wrap. This is textual evidence only.

**(b) Navigation.** The guard gained two pairs, one for each pointer, both resolving to
`## Host rails and what they miss`, and now checks 11. `scripts/tests/local-guards.sh` gained
nine assertions:
- each pointer deleted;
- the heading renamed;
- the heading duplicated;
- each pointer aimed at another section;
- both pointers and the heading removed together, asserting all three diagnostics, so that
  case cannot pass on the heading alone.

Suite: 285 passed, 0 failed. With the guard's two new rows deleted, the suite gave 276 passed
and 9 failed, and the nine failures were exactly these assertions.

**(c) The reading set, reference instance**, in bytes, by `h2-measure.sh` (§8), using H1's
section rule:

| Item | Before | After | Change |
|---|---|---|---|
| `AGENTS.md`, every session, both hosts (Claude Code by `@AGENTS.md`, **DD-077**) | 15,274 | 12,338 | −2,936 |
| RUNBOOK **Session discipline**, every session | 13,586 | 13,586 | 0 |
| RUNBOOK **Rule-review protocol**, on a legislation diff | 9,447 | 9,834 | +387 |
| RUNBOOK **Host rails and what they miss**, on its triggers | — | 3,995 | +3,995 |
| `docs/RUNBOOK.md` whole, available | 61,348 | 65,730 | +4,382 |

The pointers are included, since they are in `AGENTS.md`. Nothing moved into a section every
session reads, so the 2,936 bytes leave what a session reads at its start. A session that pushes
or makes a bulk deletion reads the new section's 3,995 bytes at that point instead, so for such
a session the change is when the bytes are read, not whether. An adopter's contexts did not
change.

**(d)** The full ladder, run on the tree that is committed; the commit body carries its result.

## 5. What these checks cannot show

- **Whether an agent reads the section when a trigger fires.** No artifact records a read, and
  the plan says so for every relocation.
- **A trigger only fires on an action the agent can see itself taking.** A session on a host
  with no pre-execution hook that never relies on a rail, pushes, deletes in bulk or meets a
  refusal has no trigger for A042.2. It loses nothing by not reading, because every rule in
  `AGENTS.md` binds it whatever a rail can see, and the sentence telling it no script can detect
  that state stayed in `AGENTS.md`. Making the section an every-session read would put the bytes
  back.

## 6. The reviews

- **Mid-unit, gpt-6.1-sol `ask` at `-e medium`.** It found no change of meaning in any moved
  sentence or leftover. It named:
  - A042.6's embedded prohibition. The session rejected that finding, wrongly; the owed pass
    upheld it.
  - Actions with no trigger. A push and the first PowerShell command became triggers.
  - Fixture gaps: each pointer was not deleted and misdirected on its own, and the combined
    case asserted one diagnostic. All were added.
- **The owed rule-review pass, gpt-6-astra at `-e high`.** Two P2 findings, both applied:
  - A042.6 moved a binding prohibition, so it stayed.
  - "Before you count on a rail" does not fire before a push or a deletion made without
    relying on one, and the deletion pointer carried no read obligation. The triggers became
    "before your first push of a session" and "before your first bulk deletion of a session".

  It found the other moved items kept their scope, exceptions and force. It replayed both §8
  scripts and all nine fixture assertions. Per the protocol, the corrected tree was checked
  by the ladder, not reviewed again.

## 7. For H3: the seed passages that match what moved

At H1's revision the seed constitution states the same coverage in its own words:
- S007.6–.9: the byte-cap rationale and what stands in for it;
- S043.1, .3–.5, .7 and .9: which layer holds which half of the deletion rule;
- S053.1–.6: the command rail, the pre-push rail and machine mode;
- S054: a failing hook refuses the call, and Git for Windows.

It has no host-mode passage. H2 leaves all of these in place, because at the light profile there
is no runbook to move them to (**DD-075**). Whether and where they move is H3's question.

## 8. Replay

Both scripts read files and write nothing. Run them from a checkout after H2, with the
`cbbea8f` copies saved by `git show cbbea8f:AGENTS.md` and `git show cbbea8f:docs/RUNBOOK.md`.

### `h2-verbatim.py`

```python
# h2-verbatim.py — every sentence H2 removed from AGENTS.md appears word for word at its destination.
# usage: python3 -I h2-verbatim.py <old AGENTS.md> <new AGENTS.md> <new docs/RUNBOOK.md>
import re
import sys

# Deixis repairs: words that named AGENTS.md from inside it, named the same thing from the runbook.
SUBSTITUTIONS = [
    ("these rules are the only layer", "the written rules are the only layer"),
    ("the CLAUDE.md that points here", "the CLAUDE.md that points at `AGENTS.md`"),
    ("No byte cap governs this file", "No byte cap governs `AGENTS.md`"),
]
# Binding sentences kept in AGENTS.md whose wording changed: old opening -> new opening.
REWORDED = [
    ("Know which rails your own session actually has.",
     "Know which rails your own session actually has: read `docs/RUNBOOK.md`"),
    ("Installing or refreshing one changes files outside the repository",
     "Installing or refreshing a machine-mode copy of the guard (`command-guard.sh --machine`)"),
]


def norm(s):
    return re.sub(r"\s+", " ", s).strip()


def blocks(text):
    out, cur = [], []
    for line in text.splitlines():
        if not line.strip() or line.startswith("#") or re.match(r"^\s*(- |\d+\. )", line):
            if cur:
                out.append(norm(" ".join(cur)))
            cur = [] if not line.strip() or line.startswith("#") else [re.sub(r"^\s*(- |\d+\. )", "", line)]
        else:
            cur.append(line)
    if cur:
        out.append(norm(" ".join(cur)))
    return out


def sentences(text):
    out = []
    for b in blocks(text):
        out += [s for s in re.split(r"(?<=\.)\s+(?=[A-Z`*(])", b) if s]
    return out


def sections(text):
    cur, secs = "(preamble)", {}
    for line in text.splitlines():
        if line.startswith("## "):
            cur = line[3:]
        secs.setdefault(cur, []).append(line)
    return {k: norm(" ".join(v)) for k, v in secs.items()}


old, new, rb = (open(p, encoding="utf-8").read() for p in sys.argv[1:4])
old_s, new_s = sentences(old), sentences(new)
removed = [s for s in old_s if s not in new_s]
added = [s for s in new_s if s not in old_s]
new_flat, secs = norm(new), sections(rb)
fails = 0
print(f"removed sentences: {len(removed)}")
for s in removed:
    t = s
    for a, b in SUBSTITUTIONS:
        t = t.replace(a, b)
    hits = [k for k, v in secs.items() if t in v]
    rew = [n for o, n in REWORDED if s.startswith(o)]
    if len(hits) == 1:
        tag = "MOVED VERBATIM" if t == s else "MOVED, DECLARED SUBSTITUTION"
        print(f"  {tag} -> ## {hits[0]}\n    {s[:110]}")
    elif rew and rew[0] in new_flat:
        print(f"  REWORDED IN PLACE (kept in AGENTS.md)\n    {s[:110]}")
    else:
        fails += 1
        print(f"  FAIL ({len(hits)} destination matches)\n    {s[:110]}")
print(f"sentences added to AGENTS.md: {len(added)}")
for s in added:
    print(f"    {s[:110]}")
print("verdict:", "FAIL" if fails else "PASS", f"({fails} unplaced)")
sys.exit(1 if fails else 0)
```

### `h2-measure.sh`

```bash
#!/usr/bin/env bash
# h2-measure.sh — the reference instance's reading set before and after H2, in bytes.
# usage: h2-measure.sh <old AGENTS.md> <old RUNBOOK.md>   (run from the tree after H2)
set -u
oa=$1 orb=$2
section() { awk -v h="## $2" 'index($0, h) == 1 { p = 1; print; next } p && /^## / { exit } p' "$1" | wc -c | tr -d ' '; }
row() { printf '%s\t%s\t%s\t%s\n' "$1" "$2" "$3" "$(($3 - $2))"; }
printf 'item\tbefore\tafter\tdelta\n'
row 'AGENTS.md (every session, both hosts)' "$(wc -c <"$oa")" "$(wc -c <AGENTS.md)"
row 'RUNBOOK Session discipline (every session)' "$(section "$orb" 'Session discipline')" "$(section docs/RUNBOOK.md 'Session discipline')"
row 'RUNBOOK Rule-review protocol (legislation diff)' "$(section "$orb" 'Rule-review protocol')" "$(section docs/RUNBOOK.md 'Rule-review protocol')"
row 'RUNBOOK Host rails and what they miss (its triggers)' 0 "$(section docs/RUNBOOK.md 'Host rails and what they miss')"
row 'RUNBOOK, whole (available)' "$(wc -c <"$orb")" "$(wc -c <docs/RUNBOOK.md)"
```
