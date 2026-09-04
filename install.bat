@echo off
REM Fuzzy Exit installer - Windows cmd.exe entry point
REM SPDX-License-Identifier: GPL-3.0-or-later
REM
REM Fuzzy Exit only supports Bash/Zsh on Unix-like systems. cmd.exe cannot
REM run install.sh, so this stub exists to fail with a clear message
REM instead of Windows' generic "is not recognized" error.

echo Fuzzy Exit: Unsupported OS: Windows.
echo Fuzzy Exit only supports Bash/Zsh on Linux, macOS, and other Unix-like systems.
echo See https://github.com/Sumon-Kayal/fuzzy-exit#windows
exit /b 1
