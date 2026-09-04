#!/usr/bin/env bash
# Fuzzy Exit test suite
#
# Default (fast, ~10s): exhaustively tests every one of the 676 possible
# 4-character strings that start with "ex" (the only strings __fuzzy_exit_match
# can ever accept) against a golden fixture, checks a large deterministic
# sample of the remaining ~456k non-"ex" strings for false positives, and
# runs the specific examples documented in README.md.
#
# --full (~15 min): also calls the real matcher on every single one of the
# 456,976 four-character strings in fixtures/all_4_character_combinations.txt,
# with no sampling. Not run in default CI; see the weekly workflow.
#
# SPDX-License-Identifier: GPL-3.0-or-later
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
FIXTURES="$SCRIPT_DIR/fixtures"
FULL_MODE=0
[ "${1:-}" = "--full" ] && FULL_MODE=1

# shellcheck source=../fuzzy-exit.sh
source "$REPO_ROOT/fuzzy-exit.sh"

pass=0
fail=0
failures=()

record() {
    if [ "$1" = "ok" ]; then
        pass=$((pass + 1))
    else
        fail=$((fail + 1))
        failures+=("$2")
    fi
}

check() {
    local word="$1" expect="$2" got
    if __fuzzy_exit_match "$word"; then got=match; else got=nomatch; fi
    if [ "$got" = "$expect" ]; then
        record ok
    else
        record fail "check '$word': expected $expect, got $got"
    fi
}

echo "== Documented examples (README.md) =="
for w in exit exut exii exiy extt exir exis exti; do check "$w" match; done
for w in wxit ex e; do check "$w" nomatch; done
echo "  ${pass} ok so far"

echo "== 5-char 'one extra character' rule, incl. the exist/English-word edge case =="
# exxit is the documented example. exist and exits fit the same structural
# rule (drop one character and you get "exit") even though they're ordinary
# words rather than typos - see tests/README.md for why this is expected,
# not a bug.
for w in exxit exiit exitt exist exits; do check "$w" match; done
for w in exile exact exert expat exalt; do check "$w" nomatch; done

echo "== exit_all_permutations.txt (24 anagrams of e,x,i,t) =="
# Only "exit" and "exti" start with "ex"; every other anagram must be
# rejected by the anchor rule even though it uses the same four letters.
while IFS= read -r word; do
    [ -z "$word" ] && continue
    case "$word" in
        exit | exti) check "$word" match ;;
        *) check "$word" nomatch ;;
    esac
done < "$FIXTURES/exit_all_permutations.txt"

echo "== Exhaustive check: every 4-char string starting with 'ex' (676 total) =="
# This is the entire decision boundary for 4-char input: __fuzzy_exit_match's
# own anchor check rejects anything not starting with "ex" before it looks at
# anything else, so this covers 100% of what a 4-char string could match on.
ex_candidates="$SCRIPT_DIR/.ex_candidates.tmp"
actual_matches="$SCRIPT_DIR/.actual_matches.tmp"
trap 'rm -f "$ex_candidates" "$actual_matches"' EXIT
grep '^ex' "$FIXTURES/all_4_character_combinations.txt" > "$ex_candidates"

candidate_count=$(wc -l < "$ex_candidates")
if [ "$candidate_count" -ne 676 ]; then
    record fail "expected 676 'ex'-prefixed 4-char strings in the fixture, found $candidate_count"
fi

: > "$actual_matches"
while IFS= read -r word; do
    __fuzzy_exit_match "$word" && printf '%s\n' "$word" >> "$actual_matches"
done < "$ex_candidates"
sort -o "$actual_matches" "$actual_matches"

if diff -q "$actual_matches" "$FIXTURES/expected_matches.txt" > /dev/null 2>&1; then
    record ok
    echo "  all 676 candidates classified exactly as expected (52 matches)"
else
    record fail "matcher output differs from tests/fixtures/expected_matches.txt - see diff below"
    diff "$actual_matches" "$FIXTURES/expected_matches.txt" || true
fi

echo "== Safety invariant: nothing outside the 'ex' prefix ever matches =="
total_lines=$(wc -l < "$FIXTURES/all_4_character_combinations.txt")
non_ex_count=$((total_lines - candidate_count))
echo "  ($total_lines total 4-char strings, $non_ex_count start with something other than 'ex')"

if [ "$FULL_MODE" -eq 1 ]; then
    echo "  --full: invoking the real matcher on all $non_ex_count of them (this takes a while)..."
    unexpected=0
    while IFS= read -r word; do
        case "$word" in
            ex??) continue ;; # already covered exhaustively above
        esac
        if __fuzzy_exit_match "$word"; then
            unexpected=$((unexpected + 1))
            echo "  UNEXPECTED MATCH: $word"
        fi
    done < "$FIXTURES/all_4_character_combinations.txt"
    if [ "$unexpected" -eq 0 ]; then
        record ok
        echo "  confirmed: zero false positives across the full corpus"
    else
        record fail "$unexpected non-'ex' string(s) matched; see above"
    fi
else
    # Deterministic stride sample (~3,330 words spread across the whole
    # corpus) so this is fast, reproducible, and needs nothing beyond awk.
    sample="$SCRIPT_DIR/.nonex_sample.tmp"
    trap 'rm -f "$ex_candidates" "$actual_matches" "$sample"' EXIT
    awk '!/^ex/ && NR % 137 == 0' "$FIXTURES/all_4_character_combinations.txt" > "$sample"
    sample_count=$(wc -l < "$sample")
    unexpected=0
    while IFS= read -r word; do
        __fuzzy_exit_match "$word" && { unexpected=$((unexpected + 1)); echo "  UNEXPECTED MATCH: $word"; }
    done < "$sample"
    if [ "$unexpected" -eq 0 ]; then
        record ok
        echo "  sampled $sample_count of $non_ex_count non-'ex' strings, zero false positives (run with --full to check all of them)"
    else
        record fail "$unexpected/$sample_count sampled non-'ex' string(s) matched; see above"
    fi
fi

echo ""
echo "== Results: $pass passed, $fail failed =="
if [ "$fail" -gt 0 ]; then
    printf '  - %s\n' "${failures[@]}"
    exit 1
fi
exit 0
