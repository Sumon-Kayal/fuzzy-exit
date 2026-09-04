#!/usr/bin/env bash
# Fuzzy Exit
# Treats near-miss typos of "exit" as exit, in bash and zsh.
# https://github.com/Sumon-Kayal/fuzzy-exit
#
# Copyright (C) 2026 Sumon Kayal
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Real commands always win: this only ever runs after your shell has
# already looked for the typed command everywhere (builtins, functions,
# aliases, $PATH) and failed to find it. If a real command exists, it
# runs normally and Fuzzy Exit never sees it.

__fuzzy_exit_match() {
    local lc suf n c1 c2 c3

    lc=$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')

    if [ "$lc" = "exit" ]; then
        return 0
    fi

    # Anchor: must start with "ex". This is what keeps an unrelated
    # near-miss like "wxit" (wrong first letter) from being swallowed -
    # only the tail end of the word is allowed to be the typo.
    case "$lc" in
        ex?*) : ;;
        *) return 1 ;;
    esac

    suf="${lc#ex}"
    n=${#suf}

    if [ "$n" -eq 1 ]; then
        # one character short, e.g. "exi", "ext"
        if [ "$suf" = "i" ] || [ "$suf" = "t" ]; then
            return 0
        fi
    elif [ "$n" -eq 2 ]; then
        # same length as "it", e.g. "exut", "exii", "exiy", "extt"
        c1="${suf:0:1}"
        c2="${suf:1:1}"
        if [ "$suf" = "it" ] || [ "$suf" = "ti" ] || [ "$c1" = "i" ] || [ "$c2" = "t" ]; then
            return 0
        fi
    elif [ "$n" -eq 3 ]; then
        # one character too many, e.g. "exxit"
        c1="${suf:0:1}"
        c2="${suf:1:1}"
        c3="${suf:2:1}"
        if [ "$c2$c3" = "it" ] || [ "$c1$c3" = "it" ] || [ "$c1$c2" = "it" ]; then
            return 0
        fi
    fi

    return 1
}

if [ -n "${BASH_VERSION:-}" ]; then
    command_not_found_handle() {
        if __fuzzy_exit_match "$1"; then
            exit
        fi
        printf 'bash: %s: command not found\n' "$1" >&2
        return 127
    }
fi

if [ -n "${ZSH_VERSION:-}" ]; then
    command_not_found_handler() {
        if __fuzzy_exit_match "$1"; then
            exit
        fi
        printf 'zsh: command not found: %s\n' "$1" >&2
        return 127
    }
fi
