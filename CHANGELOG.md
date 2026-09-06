# Changelog

## 1.0 — 2026-09-07

- Added native Windows 10 and Windows 11 support.
- Added CMD and Windows PowerShell / PowerShell 7+ integration.
- Added a hard minimum of Windows 10 22H2 (build 19045) and Windows 11 22H2 (build 22621); unsupported systems exit before installation changes are made.
- Added native Go Windows executables for x64, ARM64, and x86.
- Added WinGet manifest for `Somon.FuzzyExit`.
- Added native Windows install and uninstall entry points.
- Added Windows version/status/version/hash commands.
- Preserved existing Bash/Zsh behavior and Unix test coverage.
- Fixed CMD installer registry parsing so the full Windows product name is detected correctly.
- Added support for reading an existing CMD `AutoRun` value stored as `REG_EXPAND_SZ` without treating it as an error.
- Documented the CMD-specific `doskey` macro precedence limitation when a real command has the same typo name.
