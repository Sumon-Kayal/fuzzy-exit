# Fuzzy Exit

[![CI](https://github.com/Sumon-Kayal/fuzzy-exit/actions/workflows/ci.yml/badge.svg)](https://github.com/Sumon-Kayal/fuzzy-exit/actions/workflows/ci.yml)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)

Fuzzy Exit is a tiny shell enhancement that treats common mistypes of "exit" as "exit" itself.

For people who live in the terminal and type commands at ridiculous speed, this:

`exut`

can mean exactly the same thing as:

`exit`

## Features

- ⚡ **Fast and lightweight**
- 🐧 Designed for **Linux and other Unix-like systems**
- 🐚 Supports **Bash and Zsh** using standard `command-not-found` hooks
- 🧠 Recognizes fuzzy **3–4 character `exit` typos**
- 🛡️ **Real commands always win**
- 🚫 Unrelated typos such as `wxit` remain normal `command not found` errors
- 📦 Simple **`curl` installation**
- 🧹 Simple **uninstallation**
- 🔒 Does **not** replace or modify the shell executable
- 📜 Licensed under **GPL-3.0-or-later**

## Examples

## 🚀 How It Works

```
$ exut
bash: exut: command not found

$ exit
```

With Fuzzy Exit installed:

```
$ exut
```

and the shell closes immediately, as if you typed `exit`.

Common recognized variants may include:

```
exiy
exii
extt
exut
exir
exis
3xit
```

An unrelated command remains untouched:

```
$ wxit
bash: wxit: command not found
```

## 🛡️ Real Commands Always Win

## Real Commands Always Win

That means an existing executable always takes priority.

Therefore, if a real executable exists — `expr`, `exim`, `exif` — Fuzzy Exit does not turn it into "exit". The basic priority is:

```
Real command
    │
    ▼
Normal execution

Unknown command
    │
    ▼
Fuzzy Exit checks it
    ↓
Looks like an exit typo?
    ├── Yes → exit
    └── No  → normal command-not-found
```

---

## Installation

The intended installation method is:

```bash
curl -fsSL https://raw.githubusercontent.com/Sumon-Kayal/fuzzy-exit/main/install.sh | bash
```

The installer:

1. Detects the operating environment.
2. Detects Bash or Zsh.
3. Downloads the Fuzzy Exit implementation.
4. Installs it under `$XDG_CONFIG_HOME/fuzzy-exit` (defaulting to `~/.config/fuzzy-exit`).
5. Adds a small integration block to the appropriate shell startup file.
6. Avoids adding the integration twice.
7. Creates a timestamped backup before modifying an existing startup file.

After installation, reload your shell:

```bash
source ~/.bashrc      # or, for Zsh:
source ~/.zshrc
```

Then try an exit typo: `exut`

## Uninstallation

Run:

```bash
curl -fsSL https://raw.githubusercontent.com/Sumon-Kayal/fuzzy-exit/main/uninstall.sh | bash
```

The uninstaller removes `~/.config/fuzzy-exit/` and removes the Fuzzy Exit integration from `~/.bashrc` and `~/.zshrc`. Existing startup-file backups are preserved.

## Supported Shells

Fuzzy Exit currently targets:

- Bash (via `command_not_found_handle` hook)
- Zsh (via `command_not_found_handler` hook)

The project is intended for Unix-like environments including Linux, macOS, FreeBSD, OpenBSD, NetBSD, and other compatible Unix-like systems.

## Windows

Fuzzy Exit only supports Bash/Zsh on Unix-like systems and does not run on native Windows shells.

- Running the installer inside a Bash-like layer on Windows (`MINGW*`/`MSYS*`/`CYGWIN*`, e.g. Git Bash) stops immediately, without touching shell configuration:

  ```
  Fuzzy Exit: Unsupported OS: Windows. Fuzzy Exit only supports Bash/Zsh on Linux, macOS, and other Unix-like systems.
  ```

- `install.bat` (cmd.exe) and `install.ps1` (PowerShell) are provided as native stubs. Running either one prints the same "Unsupported OS" message and exits non-zero, rather than failing with a generic "not recognized" error.

WSL and other Unix-compatible environments are unaffected, since they provide a genuine Unix-like shell environment.

## Why?

Because humans type faster than they proofread. When you're working in a terminal, these are easy mistakes:

```
exit → exut
exit → exii
exit → exiy
exit → extt
```

Fuzzy Exit simply says:

> «You meant "exit". We knew.»

## Design Philosophy

Fuzzy Exit follows a few strict principles.

1. **Stay tiny** — it should solve one problem and solve it quickly.
2. **Never intercept real commands** — an installed executable always takes priority.
3. **Don't modify the shell itself** — Fuzzy Exit operates through shell integration rather than replacing Bash, Zsh, or the terminal emulator.
4. **Keep unrelated commands untouched** — for example, `wxit` is not an exit typo because it does not begin with the expected "ex" anchor, so it remains a normal command-not-found error.
5. **Installation should be reversible** — the installer adds a clearly marked block, and the uninstaller removes that block without deleting unrelated shell configuration.

## Repository Layout

```
fuzzy-exit/
├── fuzzy-exit.sh
├── install.sh
├── install.bat
├── install.ps1
├── uninstall.sh
├── README.md
├── LICENSE
├── .gitignore
├── .github/
│   └── workflows/
│       ├── ci.yml
│       └── full-corpus.yml
└── tests/
    ├── README.md
    ├── run_tests.sh
    ├── install_uninstall_test.sh
    ├── generate_expected_matches.py
    └── fixtures/
        ├── all_4_character_combinations.txt
        ├── exit_all_permutations.txt
        └── expected_matches.txt
```

## Word Lists

The repository also includes generated word-combination corpora under `word_lists/`:

- `exit_all_permutations.txt` — all 24 unique permutations of `exit`, plus an explicit supplied command set of additional supported typos (see below).
- `all_4_character_combinations.txt` — all 456,976 lowercase four-character combinations.

The runtime matcher (`fuzzy-exit.sh`) doesn't load these files directly - its rules are written out as plain character checks. `tests/run_tests.sh` does read `exit_all_permutations.txt`, to assert the matcher accepts every word in the explicit command set below and to exclude those same words when it scans `all_4_character_combinations.txt` for unexpected matches.

## Security Considerations

The installer modifies shell startup configuration, so it should only be downloaded from a trusted source. For maximum transparency, users can inspect the installer before running it:

```bash
curl -fsSL https://raw.githubusercontent.com/Sumon-Kayal/fuzzy-exit/main/install.sh
```

Likewise, the main implementation can be inspected directly before installation. Never pipe an installer into a shell if you do not trust its source.

## License

Fuzzy Exit is free software distributed under the GNU General Public License v3.0 or later (GPL-3.0-or-later).

Copyright © 2026 Sumon Kayal.

## Project

**Fuzzy Exit** — https://github.com/Sumon-Kayal/fuzzy-exit

---

*The idea in one line:* `exut` → `exit`

Fuzzy Exit — because "exut" obviously meant "exit".

### Explicit command set
Beyond the 24-anagram set above, the supplied command list also covers four one-substitution variants of `exit` — a wrong "i" or "x" slot (`ex?t`, `e?it`), and their `3`-for-`e` counterparts (`3x?t`, `3?it`, since `3` sits directly above `e` on a QWERTY row) — 125 unique commands in total. They're recorded explicitly in `word_lists/exit_all_permutations.txt` and enforced by `tests/run_tests.sh`.
