# Fuzzy Exit

[![CI](https://github.com/Sumon-Kayal/fuzzy-exit/actions/workflows/ci.yml/badge.svg)](https://github.com/Sumon-Kayal/fuzzy-exit/actions/workflows/ci.yml)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)

**Fuzzy Exit** is a tiny shell enhancement that recognizes common mistypes of `exit` and treats them as `exit` itself.

For people who live in the terminal and type commands at ridiculous speed, this:

```text
exut
```

can mean exactly the same thing as:

```text
exit
```

---

## ✨ Features

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

---

## 🚀 How It Works

Normally, a mistyped command produces an error:

```console
$ exut
bash: exut: command not found

$ exit
```

With Fuzzy Exit installed:

```console
$ exut
```

The shell recognizes the typo and exits immediately.

### Examples

Common recognized variants may include:

```text
exiy
exii
extt
exut
exir
exis
```

An unrelated command remains untouched:

```console
$ wxit
bash: wxit: command not found
```

---

## 🛡️ Real Commands Always Win

Fuzzy Exit only runs **after the shell has failed to find a command**.

That means an existing executable always takes priority.

For example, commands such as:

```text
expr
exim
exif
```

are executed normally and are **not** interpreted as `exit`.

The basic flow is:

```text
Real command
    │
    ▼
Normal execution

Unknown command
    │
    ▼
Fuzzy Exit checks it
    │
    ├── Looks like an exit typo ──► exit
    │
    └── Otherwise ────────────────► normal command-not-found
```

This is a core safety property of the project.

---

## 📦 Installation

The intended installation method is:

```bash
curl -fsSL https://raw.githubusercontent.com/Sumon-Kayal/fuzzy-exit/main/install.sh | bash
```

The installer:

1. Detects the operating environment.
2. Detects Bash or Zsh.
3. Downloads the Fuzzy Exit implementation.
4. Installs it under `$XDG_CONFIG_HOME/fuzzy-exit`.
5. Falls back to `~/.config/fuzzy-exit` when `XDG_CONFIG_HOME` is not set.
6. Adds a small integration block to the appropriate shell startup file.
7. Avoids adding the integration more than once.
8. Creates a timestamped backup before modifying an existing startup file.

### Reload Your Shell

After installation, reload your shell:

```bash
source ~/.bashrc
```

For Zsh:

```bash
source ~/.zshrc
```

Then try:

```bash
exut
```

---

## 🧹 Uninstallation

Run:

```bash
curl -fsSL https://raw.githubusercontent.com/Sumon-Kayal/fuzzy-exit/main/uninstall.sh | bash
```

The uninstaller:

- Removes `~/.config/fuzzy-exit/`
- Removes the Fuzzy Exit integration from `~/.bashrc`
- Removes the Fuzzy Exit integration from `~/.zshrc`
- Preserves existing startup-file backups

---

## 🐚 Supported Shells

Fuzzy Exit currently targets:

- **Bash** — via `command_not_found_handle`
- **Zsh** — via `command_not_found_handler`

The project is intended for Unix-like environments, including:

- Linux
- macOS
- FreeBSD
- OpenBSD
- NetBSD
- Other compatible Unix-like systems

---

## 🪟 Windows

Fuzzy Exit does **not** support native Windows shells.

It only supports Bash/Zsh in Unix-like environments.

### Git Bash, MSYS2, MINGW, and Cygwin

Running the installer inside a Bash-like Windows environment such as:

- Git Bash
- MSYS/MSYS2
- MINGW
- Cygwin

causes the installer to stop immediately without modifying shell configuration.

It reports:

```text
Fuzzy Exit: Unsupported OS: Windows. Fuzzy Exit only supports Bash/Zsh on Linux, macOS, and other Unix-like systems.
```

### Native Windows Stubs

The repository also provides:

```text
install.bat
install.ps1
```

These are native Windows stubs. Running either one prints the same unsupported-OS message and exits non-zero instead of producing a generic "not recognized" error.

### WSL

WSL and other genuine Unix-compatible environments are unaffected because they provide a Unix-like shell environment.

---

## 🧠 Why?

Because humans type faster than they proofread.

When you're working in a terminal, mistakes like these are easy to make:

```text
exit → exut
exit → exii
exit → exiy
exit → extt
```

Fuzzy Exit simply says:

> **“You meant `exit`. We knew.”**

---

## 🎯 Design Philosophy

Fuzzy Exit follows a few strict principles.

### 1. Stay Tiny

It should solve one problem and solve it quickly.

### 2. Never Intercept Real Commands

If an executable exists, normal command execution always takes priority.

### 3. Don't Modify the Shell

Fuzzy Exit works through shell integration rather than replacing or modifying Bash, Zsh, or the terminal emulator.

### 4. Keep Unrelated Commands Untouched

For example:

```text
wxit
```

is not treated as an `exit` typo because it does not satisfy the expected `ex` anchor. It remains a normal command-not-found error.

### 5. Keep Installation Reversible

The installer adds a clearly marked integration block, while the uninstaller removes only that block and leaves unrelated shell configuration intact.

---

## 📚 Repository Layout

```text
fuzzy-exit/
├── fuzzy-exit.sh
├── install.sh
├── install.bat
├── install.ps1
├── uninstall.sh
├── README.md
├── LICENSE
├── .gitignore
│
├── .github/
│   └── workflows/
│       ├── ci.yml
│       └── full-corpus.yml
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
└── word_lists/
    ├── exit_all_permutations.txt
    └── all_4_character_combinations.txt
```

---

## 🔤 Word Lists

The repository includes generated word-combination corpora under `word_lists/`.

### `exit_all_permutations.txt`

Contains all **24 unique permutations** of:

```text
exit
```

### `all_4_character_combinations.txt`

Contains all **456,976 lowercase four-character combinations**.

These files are provided as development and reference data.

The runtime matcher does **not** load either corpus.

---

## ✅ Explicit Command Set

The merged release contains **52 unique commands** from the supplied command set, including the `ex??` and `3x??` variants.

They are recorded explicitly in:

```text
fuzzy-exit/word_lists/exit_all_permutations.txt
```

---

## 🔐 Security Considerations

The installer modifies shell startup configuration, so it should only be downloaded from a source you trust.

For maximum transparency, inspect the installer before running it:

```bash
curl -fsSL https://raw.githubusercontent.com/Sumon-Kayal/fuzzy-exit/main/install.sh
```

Likewise, the main implementation can be inspected directly before installation.

> **Never pipe an installer into a shell if you do not trust its source.**

---

## 📜 License

Fuzzy Exit is free software distributed under the:

**GNU General Public License v3.0 or later (GPL-3.0-or-later)**

Copyright © 2026 Sumon Kayal.

See [LICENSE](LICENSE) for the full license text.

---

## 🔗 Project

**Fuzzy Exit**

https://github.com/Sumon-Kayal/fuzzy-exit

---

## 💡 In One Line

```text
exut → exit
```

**Fuzzy Exit — because `exut` obviously meant `exit`.**
