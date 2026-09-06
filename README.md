# Fuzzy Exit

[![CI](https://github.com/Sumon-Kayal/fuzzy-exit/actions/workflows/ci.yml/badge.svg)](https://github.com/Sumon-Kayal/fuzzy-exit/actions/workflows/ci.yml)
[![Full Corpus](https://github.com/Sumon-Kayal/fuzzy-exit/actions/workflows/full-corpus.yml/badge.svg)](https://github.com/Sumon-Kayal/fuzzy-exit/actions/workflows/full-corpus.yml)
[![Latest Release](https://img.shields.io/github/v/release/Sumon-Kayal/fuzzy-exit?display_name=tag&sort=semver)](https://github.com/Sumon-Kayal/fuzzy-exit/releases)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)

**Fuzzy Exit** is a tiny shell enhancement that treats common mistypes of `exit` as `exit` itself.

When your fingers type:

```text
exut
```

Fuzzy Exit can understand:

```text
exit
```

The project stays deliberately small: it does not replace your shell or terminal, and it only handles a command after the shell has already failed to resolve a real command.

> `exut` → `exit`

## Table of Contents

- [Features](#features)
- [Supported Platforms](#supported-platforms)
- [How It Works](#how-it-works)
- [Examples](#examples)
- [Installation](#installation)
  - [Unix-like systems](#unix-like-systems)
  - [Windows](#windows)
  - [WinGet](#winget)
- [Uninstallation](#uninstallation)
- [Build From Source](#build-from-source)
- [Testing](#testing)
- [Word Lists and Corpus](#word-lists-and-corpus)
- [Design Philosophy](#design-philosophy)
- [Security](#security)
- [Repository Layout](#repository-layout)
- [Releases](#releases)
- [Version](#version)
- [License](#license)

## Features

- ⚡ **Fast and lightweight**
- 🧠 Recognizes fuzzy 3–4 character `exit` typos and selected near-misses
- 🛡️ **Real commands take priority**
- 🚫 Unrelated commands such as `wxit` remain normal command-not-found errors
- 🐚 Bash and Zsh integration on Unix-like systems
- 🪟 Native **Windows 10 and Windows 11 22H2+** support
- 💻 Native **CMD, Windows PowerShell, and PowerShell 7+** support
- 🏗️ Windows **x64, ARM64, and x86** builds
- 📦 WinGet package identifier: `Somon.FuzzyExit`
- 🔧 Install and uninstall helpers
- 🔒 Does not replace or modify the shell executable
- 🧪 Includes deterministic unit, integration, and corpus tests
- 📜 Licensed under **GPL-3.0-or-later**

## Supported Platforms

### Unix-like systems

Fuzzy Exit targets:

- Bash
- Zsh

It is intended for Linux, macOS, BSD, and other compatible Unix-like environments that provide the required shell hooks and standard utilities.

### Windows

Fuzzy Exit 1.0 supports:

- Windows 10 22H2 or newer — build `19045+`
- Windows 11 22H2 or newer — build `22621+`
- Command Prompt (`cmd.exe`)
- Windows PowerShell
- PowerShell 7+

Native Windows binaries are built for:

- `x64`
- `ARM64`
- `x86`

Older Windows releases are intentionally rejected before installation changes are made.

> **WSL note:** WSL is a Unix-like environment, so the Bash/Zsh path applies there rather than the native Windows CMD/PowerShell integration.

## How It Works

Fuzzy Exit does not replace the shell.

On Bash and Zsh, it hooks into the shell's command-not-found mechanism. A command that resolves normally is left alone; only an unknown command reaches the matcher.

```text
Typed command
     │
     ▼
Shell resolves command
     │
     ├── Real command exists ──► run normally
     │
     └── Unknown command
              │
              ▼
        Fuzzy Exit matcher
              │
        ┌─────┴─────┐
        │           │
      exit-like    other
        │           │
        ▼           ▼
      exit     normal command-not-found
```

On native Windows, the project provides dedicated CMD and PowerShell integration rather than attempting to emulate a Unix command-not-found hook.

## Examples

A common typo:

```text
$ exut
```

With Fuzzy Exit installed, the shell exits as though you had typed:

```text
$ exit
```

Some recognized forms include:

```text
exut
exii
exiy
extt
exir
exis
3xit
```

The matcher also includes the complete explicit permutation set where applicable. For example:

```text
eitx
eixt
etix
etxi
exit
exti
...
xtie
```

An unrelated command remains untouched:

```text
$ wxit
bash: wxit: command not found
```

### Real commands always win

Fuzzy Exit is deliberately designed to run only after the shell has already failed to resolve the typed command.

That means a real executable such as:

```text
expr
exif
exim
```

is not intercepted by the Bash/Zsh command-not-found path merely because its name resembles `exit`.

### Windows CMD precedence

CMD integration uses `doskey` macros. A real executable is still handled by Windows normally, but `doskey` has its own macro precedence rules. If a real command and a Fuzzy Exit macro have exactly the same typo name, the CMD-specific macro behavior can differ from the Bash/Zsh command-not-found model.

## Installation

### Unix-like systems

The intended installation method is:

```bash
curl -fsSL https://raw.githubusercontent.com/Sumon-Kayal/fuzzy-exit/main/install.sh | bash
```

The installer:

1. Detects the shell environment.
2. Supports Bash and Zsh.
3. Installs the runtime under `${XDG_CONFIG_HOME:-$HOME/.config}/fuzzy-exit`.
4. Adds a clearly marked integration block to the appropriate startup file.
5. Avoids duplicate integration blocks.
6. Creates a timestamped backup before modifying an existing startup file.

After installation, reload your shell:

```bash
source ~/.bashrc
```

or:

```bash
source ~/.zshrc
```

Then try:

```text
exut
```

For maximum transparency, you can inspect the installer before running it:

```bash
curl -fsSL https://raw.githubusercontent.com/Sumon-Kayal/fuzzy-exit/main/install.sh
```

### Windows

Native Windows installation is provided by:

```text
install.bat
install.ps1
```

Use `install.bat` from Command Prompt, or `install.ps1` from PowerShell.

The installer selects the appropriate native architecture and configures the corresponding shell integration.

Windows support has a hard minimum:

```text
Windows 10 22H2 → build 19045
Windows 11 22H2 → build 22621
```

If an unsupported Windows version is detected, installation stops before making configuration changes.

### WinGet

The package identifier is:

```text
Somon.FuzzyExit
```

After the package has been published to the Windows Package Manager community repository:

```powershell
winget install --id Somon.FuzzyExit -e
```

The repository contains the WinGet manifest at:

```text
winget/S/Somon/FuzzyExit/1.0/Somon.FuzzyExit.yaml
```

Including a manifest in this repository does **not** by itself publish Fuzzy Exit to WinGet. Publication requires submission and acceptance by the WinGet community repository.

## Uninstallation

### Unix-like systems

Run:

```bash
curl -fsSL https://raw.githubusercontent.com/Sumon-Kayal/fuzzy-exit/main/uninstall.sh | bash
```

The uninstaller removes the Fuzzy Exit installation directory and removes its marked integration block from the relevant shell startup files.

Existing startup-file backups are preserved.

### Windows

Use:

```text
uninstall.bat
```

or:

```text
uninstall.ps1
```

depending on the shell you are using.

## Build From Source

### Unix-like systems

The shell implementation is:

```text
fuzzy-exit.sh
```

The project does not require a separate build step for the Bash/Zsh runtime.

### Windows

The native Windows implementation is written in Go:

```text
windows/fuzzy-exit.go
```

The Windows build helper is:

```powershell
./windows/build.ps1
```

It produces:

```text
windows/FuzzyExit-1.0-x64.exe
windows/FuzzyExit-1.0-arm64.exe
windows/FuzzyExit-1.0-x86.exe
```

The GitHub release workflow can also build these binaries automatically.

## Testing

The repository includes unit, integration, and corpus testing.

Run the normal test suite:

```bash
bash tests/run_tests.sh
```

Run installation/uninstallation integration tests:

```bash
bash tests/install_uninstall_test.sh
```

Run the full 4-character corpus:

```bash
bash tests/run_tests.sh --full
```

The regular test run exhaustively checks all `ex??` candidates and deterministically samples the remaining 4-character space. The full corpus mode checks every possible lowercase 4-character string.

The weekly/full-corpus workflow is defined in:

```text
.github/workflows/full-corpus.yml
```

### Independent expected-match generation

The expected match fixture is generated by a separate Python implementation of the matcher:

```bash
python3 tests/generate_expected_matches.py > tests/fixtures/expected_matches.txt
```

This provides a cross-language check against transcription mistakes in the shell implementation.

## Word Lists and Corpus

The repository includes generated corpora under `word_lists/` and matching test fixtures under `tests/fixtures/`.

### `exit_all_permutations.txt`

Contains all **24 unique permutations** of:

```text
exit
```

The repository also records the broader explicit supported command set used by the tests.

### `all_4_character_combinations.txt`

Contains every possible lowercase 4-character combination:

```text
26^4 = 456,976
```

This corpus is used to test the matcher boundary and to make sure unrelated commands remain untouched.

The runtime matcher does **not** load these files directly. Its rules are implemented as character checks in `fuzzy-exit.sh`.

### Matcher behavior worth knowing

The matcher is structural rather than a dictionary lookup. Because of that, some ordinary words can be accepted when they fit the same character rules.

For example:

```text
exist
```

matches the current 5-character fuzzy rule because it can be interpreted as `exit` with one inserted character.

This is intentional behavior of the current algorithm and is covered by the tests.

## Design Philosophy

Fuzzy Exit follows a few simple rules:

1. **Stay tiny** — solve one problem and solve it quickly.
2. **Never intentionally replace real commands** — the Unix integration only runs after normal command resolution fails.
3. **Do not modify the shell executable** — use shell integration instead.
4. **Keep unrelated commands untouched** — `wxit`, for example, remains a normal unknown command.
5. **Make installation reversible** — integration is clearly marked and can be removed without deleting unrelated configuration.
6. **Keep releases reproducible** — Windows release binaries can be built by GitHub Actions rather than requiring developers to commit generated artifacts.

## Security

The installer modifies shell startup configuration, so only use installers obtained from a source you trust.

For transparency, inspect scripts before piping them into a shell:

```bash
curl -fsSL https://raw.githubusercontent.com/Sumon-Kayal/fuzzy-exit/main/install.sh
```

Fuzzy Exit does not replace the shell executable.

### Windows release signing

The GitHub release workflow can create a temporary self-signed code-signing certificate for release binaries, sign the Windows executables, verify the signatures, and publish the public certificate with the release.

A self-signed certificate is **not automatically trusted by Windows** like a certificate issued by a public code-signing CA. Users should verify the published certificate and signature before choosing to trust it.

## Repository Layout

```text
fuzzy-exit/
├── .github/
│   └── workflows/
│       ├── ci.yml
│       ├── full-corpus.yml
│       └── release.yml
│
├── tests/
│   ├── README.md
│   ├── run_tests.sh
│   ├── install_uninstall_test.sh
│   ├── generate_expected_matches.py
│   └── fixtures/
│       ├── all_4_character_combinations.txt
│       ├── exit_all_permutations.txt
│       └── expected_matches.txt
│
├── word_lists/
│   ├── README.txt
│   ├── all_4_character_combinations.txt
│   └── exit_all_permutations.txt
│
├── windows/
│   ├── build.ps1
│   └── fuzzy-exit.go
│
├── winget/
│   └── S/
│       └── Somon/
│           └── FuzzyExit/
│               └── 1.0/
│                   └── Somon.FuzzyExit.yaml
│
├── fuzzy-exit.sh
├── install.sh
├── uninstall.sh
├── install.bat
├── uninstall.bat
├── install.ps1
├── uninstall.ps1
├── CHANGELOG.md
├── LICENSE
├── README.md
└── go.mod
```

## Releases

GitHub releases are automated through:

```text
.github/workflows/release.yml
```

A release workflow can:

1. Build Windows x64, ARM64, and x86 binaries.
2. Run release checks.
3. Create a temporary self-signed SHA-256 code-signing certificate.
4. Sign the Windows executables.
5. Verify the signatures.
6. Generate SHA-256 hashes from the signed binaries.
7. Publish release assets and signing material.
8. Generate release/WinGet metadata.

For source control, generated release binaries do not need to be the source of truth; GitHub Actions can build them from the committed source.

## Version

Current release:

```text
1.0
```

See [`CHANGELOG.md`](CHANGELOG.md) for release history.

## License

Fuzzy Exit is free software distributed under the **GNU General Public License v3.0 or later**.

See [`LICENSE`](LICENSE) for the full license text.

---

**Fuzzy Exit** — because `exut` obviously meant `exit`.
