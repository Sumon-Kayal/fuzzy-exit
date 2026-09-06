Yep — for a universal changelog format, I’d remove the GitHub-specific/release-specific wording and structure it so the same CHANGELOG.md can continue cleanly into v1.1, v2.0, etc.

Changelog

All notable changes to Fuzzy Exit are documented in this file.

The format is based on "Keep a Changelog" (https://keepachangelog.com/en/1.1.0/), and this project follows "Semantic Versioning" (https://semver.org/).

---

"1.0.0" (https://github.com/Sumon-Kayal/fuzzy-exit/releases/tag/v1.0.0) - 2026-09-07

Added

- Bash integration.
- Zsh integration.
- Linux support.
- macOS support.
- BSD / Unix support.
- Termux / Android support.
- Lightweight fuzzy matching for common "exit" mistypes.
- Shell "command-not-found" integration.
- Reversible and idempotent installation script.
- Reversible and idempotent uninstallation script.
- Unit tests.
- Integration tests.
- Installation and uninstallation tests.
- Independent Python expected-match generator.
- Complete lowercase four-character test corpus ("26^4 = 456,976" combinations).
- Exhaustive corpus validation through CI.

Changed

- Established the Unix-like implementation as the canonical project implementation.
- Runtime matching remains lightweight and does not load generated test corpora.
- Existing commands retain normal shell command resolution priority.

Removed

- Windows-specific implementation.
- Windows executable and build artifacts.
- Windows CMD and PowerShell integration.
- Windows-specific installers and uninstallers.
- WinGet packaging and manifests.
- Other platform-specific Windows release infrastructure.

Security

- Fuzzy Exit does not replace or modify the shell executable.
- The command-not-found integration only processes commands that the shell has already failed to resolve normally.

Compatibility

Supported environments include:

- Linux
- macOS
- BSD systems
- Other compatible Unix-like systems
- Termux on Android
- Bash
- Zsh

Windows is not supported by this release.

Notes

Fuzzy Exit hooks into the shell's command-not-found mechanism. When a command cannot be resolved normally, the fuzzy matcher can recognize common mistypes of "exit".

For example:

exut → exit

---

"Unreleased" (https://github.com/Sumon-Kayal/fuzzy-exit/compare/v1.0.0...HEAD)

Added

Changed

Deprecated

Removed

Fixed

Security

---This is much more reusable: future releases can simply add ## [1.1.0], ## [1.2.0], etc., while the [Unreleased] section stays at the top.
