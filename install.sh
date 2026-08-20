#!/usr/bin/env bash
set -euo pipefail

# Fuzzy Exit installer
# SPDX-License-Identifier: GPL-3.0-or-later

REPO_URL="https://raw.githubusercontent.com/Sumon-Kayal/fuzzy-exit/main"
INSTALL_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/fuzzy-exit"
SCRIPT_URL="${REPO_URL}/fuzzy-exit.sh"
SCRIPT_FILE="${INSTALL_DIR}/fuzzy-exit.sh"

say() { printf '%s\n' "$*"; }
die() { printf 'Fuzzy Exit: %s\n' "$*" >&2; exit 1; }

[ -n "${HOME:-}" ] || die "HOME is not set."

# Native Windows shells should not be modified.
case "$(uname -s 2>/dev/null || printf unknown)" in
    MINGW*|MSYS*|CYGWIN*)
        say "Fuzzy Exit: Windows environment detected."
        say "Press Alt + F4 to close the terminal."
        exit 0
        ;;
esac

# Fuzzy Exit is intended for Bash/Zsh startup files.
shell_name="$(basename "${SHELL:-}")"
case "$shell_name" in
    bash|zsh) ;;
    *)
        if [ -n "${BASH_VERSION:-}" ]; then
            shell_name=bash
        elif [ -n "${ZSH_VERSION:-}" ]; then
            shell_name=zsh
        else
            die "Unsupported shell: ${shell_name:-unknown}. Use Bash or Zsh."
        fi
        ;;
esac

case "$shell_name" in
    bash) rc_file="${BASHRC:-$HOME/.bashrc}" ;;
    zsh)  rc_file="${ZDOTDIR:-$HOME}/.zshrc" ;;
esac

mkdir -p "$INSTALL_DIR"

tmp_file="$(mktemp)"
trap 'rm -f "$tmp_file"' EXIT

say "Installing Fuzzy Exit for $shell_name..."
if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$SCRIPT_URL" -o "$tmp_file" || die "Could not download $SCRIPT_URL"
elif command -v wget >/dev/null 2>&1; then
    wget -qO "$tmp_file" "$SCRIPT_URL" || die "Could not download $SCRIPT_URL"
else
    die "curl or wget is required."
fi

[ -s "$tmp_file" ] || die "Downloaded Fuzzy Exit script is empty."

# Basic sanity check before installing downloaded code.
grep -q '__fuzzy_exit_match' "$tmp_file" ||
    die "Downloaded file does not look like a Fuzzy Exit script."

install -m 0644 "$tmp_file" "$SCRIPT_FILE"

# Keep a timestamped backup when modifying an existing rc file.
if [ -f "$rc_file" ]; then
    cp -p "$rc_file" "${rc_file}.fuzzy-exit.bak.$(date +%Y%m%d%H%M%S)"
else
    touch "$rc_file"
fi

marker_begin="# >>> fuzzy-exit >>>"
marker_end="# <<< fuzzy-exit <<<"

if ! grep -Fqx "$marker_begin" "$rc_file" 2>/dev/null; then
    {
        printf '\n%s\n' "$marker_begin"
        printf '[ -f "$HOME/.config/fuzzy-exit/fuzzy-exit.sh" ] && . "$HOME/.config/fuzzy-exit/fuzzy-exit.sh"\n'
        printf '%s\n' "$marker_end"
    } >> "$rc_file"
fi

say "Installed: $SCRIPT_FILE"
say "Configured: $rc_file"
say
say "Reload your shell with:"
say "  source \"$rc_file\""
say
say "Then try a typo such as: exut"
