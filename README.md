# Fuzzy Exit

Fuzzy Exit provides a small, fast way to exit the current shell/session using the
`fuzzy-exit` command and shell integrations.

## Version

**1.0**

## Platform support

### Windows

Fuzzy Exit 1.0 supports:

- Windows 10 **22H2 or newer**
- Windows 11 **22H2 or newer**
- Command Prompt (CMD)
- Windows PowerShell
- PowerShell 7+
- x64, ARM64, and x86 Windows

The Windows launcher/installers check the Windows version before making
installation changes. Windows 10 builds below **19045** and Windows 11 builds
below **22621** are rejected because they are older than 22H2.

### Unix-like systems

The project also retains its existing shell support for supported Unix-like
environments, including Bash/Zsh integrations where provided by the project.

## Windows installation

Use the installer matching your preferred shell:

```text
windows/install.bat
windows/install.ps1
```

The native Windows executables are:

```text
windows/FuzzyExit-1.0-x64.exe
windows/FuzzyExit-1.0-arm64.exe
windows/FuzzyExit-1.0-x86.exe
```

The installer uses the appropriate executable for the detected native Windows
architecture.

## CMD

After installation, open a new Command Prompt and run:

```cmd
fuzzy-exit
```

## PowerShell

After installation, open a new PowerShell session and run:

```powershell
fuzzy-exit
```

This works with both Windows PowerShell and PowerShell 7+ when their profiles
are configured by the installer.

## Windows version policy

Fuzzy Exit intentionally stops installation on unsupported Windows versions.

| Windows version | Minimum build | Status |
|---|---:|---|
| Windows 10 22H2 | 19045 | Supported |
| Windows 11 22H2 | 22621 | Supported |
| Windows 10 older than 22H2 | < 19045 | Rejected |
| Windows 11 older than 22H2 | < 22621 | Rejected |

## WinGet

The package identifier is:

```text
Somon.FuzzyExit
```

Once the package is published in the Windows Package Manager community
repository, it can be installed with:

```powershell
winget install --id Somon.FuzzyExit -e
```

Including a WinGet manifest in this repository does **not** by itself publish the
package. Publication requires submission and acceptance by the WinGet
community repository.

## GitHub releases

Tagged releases are built by:

```text
.github/workflows/release.yml
```

The release workflow:

- builds Windows x64, ARM64, and x86 binaries
- creates a temporary self-signed SHA-256 code-signing certificate
- signs the release executables
- verifies the signatures
- publishes the public certificate
- calculates hashes from the signed binaries
- generates release/WinGet metadata
- publishes the release artifacts

The private signing key is kept on the GitHub Actions runner and is not
published.

### Important: self-signed certificate

The release binaries are self-signed. This provides cryptographic integrity and
allows users to verify that a binary was signed by the published certificate,
but it does **not** make the certificate automatically trusted by Windows like
a certificate issued by a public code-signing CA.

## Project layout

```text
.
├── .github/
│   └── workflows/
│       └── release.yml
├── windows/
│   ├── FuzzyExit-1.0-x64.exe
│   ├── FuzzyExit-1.0-arm64.exe
│   ├── FuzzyExit-1.0-x86.exe
│   ├── install.bat
│   ├── install.ps1
│   ├── uninstall.bat
│   └── uninstall.ps1
├── CHANGELOG.md
└── README.md
```

## License

See the project's license file for licensing terms.
