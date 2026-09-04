#!/usr/bin/env python3
"""
Regenerates tests/fixtures/expected_matches.txt: the golden set of every
4-character lowercase string that __fuzzy_exit_match (fuzzy-exit.sh) should
accept.

This is a DEV-TIME provenance tool, not a test-suite dependency. run_tests.sh
is pure bash and never invokes this file. It exists so the "52" in the golden
fixture isn't a mystery number: it's independently reasoned out here, in a
different language than the implementation, and cross-checked in run_tests.sh
by exhaustively running the real fuzzy-exit.sh against every one of the 676
possible 4-character strings that start with "ex" and diffing the result
against this file.

Only re-run this if fuzzy-exit.sh's matching rules intentionally change:

    python3 tests/generate_expected_matches.py > tests/fixtures/expected_matches.txt

SPDX-License-Identifier: GPL-3.0-or-later
"""
import itertools


def fuzzy_exit_match(word: str) -> bool:
    """Mirrors the rules in __fuzzy_exit_match (fuzzy-exit.sh), reimplemented
    independently rather than transliterated line-for-line."""
    lc = word.lower()
    if lc == "exit":
        return True
    if not (lc.startswith("ex") and len(lc) > 2):
        return False  # anchor: must start with "ex"

    suf = lc[2:]
    n = len(suf)

    if n == 1:
        # one char short, e.g. "exi", "ext"
        return suf in ("i", "t")

    if n == 2:
        # same length as "it", e.g. "exut", "exii", "exiy", "extt", "exti"
        c1, c2 = suf[0], suf[1]
        return suf in ("it", "ti") or c1 == "i" or c2 == "t"

    if n == 3:
        # one char too many, e.g. "exxit"
        c1, c2, c3 = suf[0], suf[1], suf[2]
        return "it" in (c2 + c3, c1 + c3, c1 + c2)

    return False


def main() -> None:
    matches = sorted(
        "".join(combo)
        for combo in itertools.product("abcdefghijklmnopqrstuvwxyz", repeat=4)
        if fuzzy_exit_match("".join(combo))
    )
    for word in matches:
        print(word)


if __name__ == "__main__":
    main()
