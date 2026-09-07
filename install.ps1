#!/usr/bin/env pwsh
# Fuzzy Exit installer - PowerShell entry point
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Fuzzy Exit only supports Bash/Zsh on Unix-like systems. PowerShell (and
# Windows cmd.exe) cannot run install.sh, so this stub exists to fail with
# a clear message instead of a generic execution error.

Write-Host "Fuzzy Exit: Unsupported OS: Windows."
Write-Host "Fuzzy Exit only supports Bash/Zsh on Linux, macOS, and other Unix-like systems."
Write-Host "See https://github.com/Sumon-Kayal/fuzzy-exit#windows"
exit 1
