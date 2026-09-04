#!/usr/bin/env bash
# Exercises install.sh and uninstall.sh end-to-end against a throwaway HOME,
# checking the specific claims made in README.md: idempotent install, a
# timestamped backup on first modification, and a clean, reversible removal.
#
# Uses FUZZY_EXIT_LOCAL_SCRIPT so this runs offline and tests the *local*
# fuzzy-exit.sh, not whatever currently happens to be published on main.
#
# SPDX-License-Identifier: GPL-3.0-or-later
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

pass=0
fail=0
failures=()

ok()   { pass=$((pass + 1)); }
bad()  { fail=$((fail + 1)); failures+=("$1"); echo "  FAIL: $1"; }

assert_exists()     { [ -e "$1" ] && ok || bad "expected to exist: $1"; }
assert_not_exists()  { [ ! -e "$1" ] && ok || bad "expected to NOT exist: $1"; }
assert_contains()   { grep -qF -- "$2" "$1" 2>/dev/null && ok || bad "expected $1 to contain: $2"; }
assert_count()      {
    local file="$1" needle="$2" expect="$3" got
    got=$(grep -cF -- "$needle" "$file" 2>/dev/null || true)
    [ "$got" = "$expect" ] && ok || bad "expected '$needle' to appear $expect time(s) in $file, found $got"
}

TMP_HOME="$(mktemp -d)"
cleanup() { rm -rf "$TMP_HOME"; }
trap cleanup EXIT

export HOME="$TMP_HOME"
export SHELL="/bin/bash"
export XDG_CONFIG_HOME="$TMP_HOME/.config"
export FUZZY_EXIT_LOCAL_SCRIPT="$REPO_ROOT/fuzzy-exit.sh"
unset BASHRC ZDOTDIR

RC_FILE="$TMP_HOME/.bashrc"
INSTALLED_SCRIPT="$TMP_HOME/.config/fuzzy-exit/fuzzy-exit.sh"
BEGIN_MARKER="# >>> fuzzy-exit >>>"
INSTALL_OUTPUT="$TMP_HOME/install_out.txt"
INITIAL_RC_CONTENT="# pre-existing bashrc content"

printf '%s\n' "$INITIAL_RC_CONTENT" > "$RC_FILE"

echo "== First install =="
if bash "$REPO_ROOT/install.sh" > "$INSTALL_OUTPUT" 2>&1; then ok; else bad "install.sh exited non-zero on first run"; fi
assert_exists "$INSTALLED_SCRIPT"
assert_contains "$INSTALLED_SCRIPT" "__fuzzy_exit_match"
assert_contains "$RC_FILE" "$BEGIN_MARKER"
assert_count "$RC_FILE" "$BEGIN_MARKER" 1
first_backup=$(find "$TMP_HOME" -maxdepth 1 -name '.bashrc.fuzzy-exit.bak.*' -print -quit)
if [ -n "$first_backup" ] && printf '%s\n' "$INITIAL_RC_CONTENT" | cmp -s - "$first_backup"; then
    ok
else
    bad "first-install backup did not preserve the original rc file content"
fi

echo "== Installed script actually works when sourced =="
( source "$INSTALLED_SCRIPT" && __fuzzy_exit_match "exut" ) && ok || bad "sourced installed script did not match a known typo"

echo "== Second install is idempotent (no duplicate marker block) =="
if bash "$REPO_ROOT/install.sh" > /dev/null 2>&1; then ok; else bad "install.sh exited non-zero on second run"; fi
assert_count "$RC_FILE" "$BEGIN_MARKER" 1

echo "== Backup was created before the rc file was first modified =="
backup_count=$(find "$TMP_HOME" -maxdepth 1 -name '.bashrc.fuzzy-exit.bak.*' | wc -l)
[ "$backup_count" -ge 1 ] && ok || bad "expected at least one .bashrc.fuzzy-exit.bak.* file, found $backup_count"

echo "== Uninstall removes the install dir and the rc block, keeps backups =="
if bash "$REPO_ROOT/uninstall.sh" > /tmp/uninstall_out.txt 2>&1; then ok; else bad "uninstall.sh exited non-zero"; fi
assert_not_exists "$TMP_HOME/.config/fuzzy-exit"
if [ -f "$RC_FILE" ]; then
    if grep -qF "$BEGIN_MARKER" "$RC_FILE"; then
        bad "marker block still present in $RC_FILE after uninstall"
    else
        ok
    fi
fi
backup_count_after=$(find "$TMP_HOME" -maxdepth 1 -name '.bashrc.fuzzy-exit.bak.*' | wc -l)
[ "$backup_count_after" -ge "$backup_count" ] && ok || bad "backups were removed by uninstall, expected them preserved"

echo "== Windows-like uname is rejected, not silently accepted =="
fake_bin="$(mktemp -d)"
cat > "$fake_bin/uname" <<'EOF'
#!/usr/bin/env bash
echo "MINGW64_NT-10.0-19045"
EOF
chmod +x "$fake_bin/uname"
if PATH="$fake_bin:$PATH" bash "$REPO_ROOT/install.sh" > /tmp/fuzzy_exit_win_out.txt 2>&1; then
    bad "install.sh should exit non-zero when uname reports a Windows-like environment"
else
    ok
fi
assert_contains /tmp/fuzzy_exit_win_out.txt "Unsupported OS"
rm -rf "$fake_bin" /tmp/fuzzy_exit_win_out.txt

echo ""
echo "== Results: $pass passed, $fail failed =="
if [ "$fail" -gt 0 ]; then
    printf '  - %s\n' "${failures[@]}"
    exit 1
fi
exit 0
