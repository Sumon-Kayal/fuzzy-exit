#!/usr/bin/env bash
set -euo pipefail

# Fuzzy Exit uninstaller
# SPDX-License-Identifier: GPL-3.0-or-later

INSTALL_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/fuzzy-exit"
SCRIPT_FILE="${INSTALL_DIR}/fuzzy-exit.sh"

say() { printf '%s\n' "$*"; }
die() { printf 'Fuzzy Exit: %s\n' "$*" >&2; exit 1; }

[ -n "${HOME:-}" ] || die "HOME is not set."

marker_begin="# >>> fuzzy-exit >>>"
marker_end="# <<< fuzzy-exit <<<"

remove_from_rc() {
    local rc_file="$1"
    [ -f "$rc_file" ] || return 0

    local tmp
    tmp="$(mktemp)"

    awk -v begin="$marker_begin" -v end="$marker_end" '
        $0 == begin {
            if (skip == 1) {
                print "Fuzzy Exit: nested or duplicate marker_begin found in " FILENAME > "/dev/stderr"
                exit 1
            }
            skip = 1
            next
        }
        $0 == end {
            if (skip == 0) {
                print "Fuzzy Exit: marker_end found without matching marker_begin in " FILENAME > "/dev/stderr"
                exit 1
            }
            skip = 0
            next
        }
        !skip { print }
        END {
            if (skip == 1) {
                print "Fuzzy Exit: unclosed marker_begin found in " FILENAME > "/dev/stderr"
                exit 1
            }
        }
    ' "$rc_file" > "$tmp" || { rm -f "$tmp"; die "Malformed Fuzzy Exit marker block in $rc_file"; }

    if ! cmp -s "$rc_file" "$tmp"; then
        cp -p "$rc_file" "${rc_file}.fuzzy-exit.bak.$(date +%Y%m%d%H%M%S)"
        cat "$tmp" > "$rc_file"
        say "Removed Fuzzy Exit from $rc_file"
    fi

    rm -f "$tmp"
}

remove_from_rc "${BASHRC:-$HOME/.bashrc}"
remove_from_rc "${ZDOTDIR:-$HOME}/.zshrc"

if [ -d "$INSTALL_DIR" ]; then
    rm -rf "$INSTALL_DIR"
    say "Removed $INSTALL_DIR"
else
    say "Fuzzy Exit installation directory was already absent."
fi

say
say "Fuzzy Exit has been uninstalled."
say "Restart your shell, or source the modified startup file."
