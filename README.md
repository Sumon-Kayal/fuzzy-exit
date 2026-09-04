# Fuzzy Exit

[![CI](https://github.com/Sumon-Kayal/fuzzy-exit/actions/workflows/ci.yml/badge.svg)](https://github.com/Sumon-Kayal/fuzzy-exit/actions/workflows/ci.yml)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)

Fuzzy Exit is a tiny shell enhancement that treats common mistypes of "exit" as "exit" itself.

For people who live in the terminal and type commands at ridiculous speed, this:

`exut`

can mean exactly the same thing as:

`exit`

## Features

- ⚡ Fast and lightweight
- 🐧 Designed for Linux and other Unix-like systems
- 🐚 Bash and Zsh support using standard command-not-found hooks
- 🧠 Recognizes fuzzy 3–4 character "exit" typos
- 🛡️ Real commands always win
- 🚫 Unrelated typos such as "wxit" remain normal "command not found" errors
- 📦 Simple "curl" installation
- 🧹 Simple uninstall
- 🔒 Does not replace or modify the shell executable
- 📜 GPL-3.0-or-later

## Examples

Instead of correcting yourself:

```
$ exut
bash: exut: command not found

$ exit
```

Fuzzy Exit lets you do:

```
$ exut
```

and the shell closes immediately, as if you typed `exit`.

Other examples may include:

```
exiy
exii
extt
exut
exir
exis
```

while an unrelated typo such as:

```
$ wxit
bash: wxit: command not found
```

continues to behave normally.

## Real Commands Always Win

Fuzzy Exit only gets involved after the shell has failed to find the command.

Therefore, if a real executable exists — `expr`, `exim`, `exif` — Fuzzy Exit does not turn it into "exit". The basic priority is:

```
Real command
    ↓
Normal execution

Unknown command
    ↓
Fuzzy Exit checks it
    ↓
Looks like an exit typo?
    ├── Yes → exit
    └── No  → normal command-not-found
```

This is an important safety property of the project.

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

Currently targeted:

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

Fuzzy Exit follows a few strict principles:

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

- `exit_all_permutations.txt` — all 24 unique permutations of `exit`.
- `all_4_character_combinations.txt` — all 456,976 lowercase four-character combinations.

These corpora are provided as development/reference data. The runtime matcher does not load them.

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
The merged release includes **52 unique commands** from the supplied command list, including the `ex??` and `3x??` variants. They are recorded explicitly in `fuzzy-exit/word_lists/exit_all_permutations.txt`.
