// Fuzzy Exit Windows support.
// SPDX-License-Identifier: GPL-3.0-or-later
package main

import (
	"crypto/sha256"
	"encoding/hex"
	"errors"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"runtime"
	"strings"
	"syscall"
	"unsafe"
)

const (
	version          = "1.0"
	appDirName       = "FuzzyExit"
	appExeName       = "fuzzy-exit.exe"
	macroFileName    = "fuzzy-exit.cmdkeys"
	psFileName       = "FuzzyExit.ps1"
	markerBegin      = "# >>> fuzzy-exit >>>"
	markerEnd        = "# <<< fuzzy-exit <<<"
	hkeyCurrentUser  = 0x80000001
	hkeyLocalMachine = 0x80000002
	keyRead          = 0x20019
	keyWrite         = 0x20006
	regSz            = 1
)

type osVersionInfoEx struct {
	OSVersionInfoSize uint32
	MajorVersion      uint32
	MinorVersion      uint32
	BuildNumber       uint32
	PlatformId        uint32
	CSDVersion        [128]uint16
	ServicePackMajor  uint16
	ServicePackMinor  uint16
	SuiteMask         uint16
	ProductType       byte
	Reserved          byte
}

var (
	advapi32         = syscall.NewLazyDLL("advapi32.dll")
	ntdll            = syscall.NewLazyDLL("ntdll.dll")
	regOpenKeyExW    = advapi32.NewProc("RegOpenKeyExW")
	regCreateKeyExW  = advapi32.NewProc("RegCreateKeyExW")
	regQueryValueExW = advapi32.NewProc("RegQueryValueExW")
	regSetValueExW   = advapi32.NewProc("RegSetValueExW")
	regCloseKey      = advapi32.NewProc("RegCloseKey")
	regDeleteKeyW    = advapi32.NewProc("RegDeleteKeyW")
	rtlGetVersion    = ntdll.NewProc("RtlGetVersion")
)

type hkey uintptr

func utf16(s string) *uint16 { p, _ := syscall.UTF16PtrFromString(s); return p }

func regReadString(root uintptr, subkey, name string) (string, uint32, error) {
	var k hkey
	r, _, _ := regOpenKeyExW.Call(root, uintptr(unsafe.Pointer(utf16(subkey))), 0, keyRead, uintptr(unsafe.Pointer(&k)))
	if r != 0 {
		return "", 0, syscall.Errno(r)
	}
	defer regCloseKey.Call(uintptr(k))

	var typ uint32
	var size uint32
	r, _, _ = regQueryValueExW.Call(uintptr(k), uintptr(unsafe.Pointer(utf16(name))), 0, uintptr(unsafe.Pointer(&typ)), 0, uintptr(unsafe.Pointer(&size)))
	if r != 0 {
		return "", 0, syscall.Errno(r)
	}
	if (typ != regSz && typ != 2) || size == 0 {
		return "", 0, errors.New("registry value is not a string")
	}
	buf := make([]uint16, (size+1)/2)
	r, _, _ = regQueryValueExW.Call(uintptr(k), uintptr(unsafe.Pointer(utf16(name))), 0, uintptr(unsafe.Pointer(&typ)), uintptr(unsafe.Pointer(&buf[0])), uintptr(unsafe.Pointer(&size)))
	if r != 0 {
		return "", 0, syscall.Errno(r)
	}
	return syscall.UTF16ToString(buf), typ, nil
}

func regWriteString(root uintptr, subkey, name, value string) error {
	var k hkey
	var disposition uint32
	r, _, _ := regCreateKeyExW.Call(root, uintptr(unsafe.Pointer(utf16(subkey))), 0, 0, 0, keyWrite, 0, uintptr(unsafe.Pointer(&k)), uintptr(unsafe.Pointer(&disposition)))
	if r != 0 {
		return syscall.Errno(r)
	}
	defer regCloseKey.Call(uintptr(k))
	data, err := syscall.UTF16FromString(value)
	if err != nil {
		return err
	}
	r, _, _ = regSetValueExW.Call(uintptr(k), uintptr(unsafe.Pointer(utf16(name))), 0, regSz, uintptr(unsafe.Pointer(&data[0])), uintptr(len(data)*2))
	if r != 0 {
		return syscall.Errno(r)
	}
	return nil
}

func regDeleteKey(root uintptr, subkey string) error {
	r, _, _ := regDeleteKeyW.Call(root, uintptr(unsafe.Pointer(utf16(subkey))))
	if r != 0 {
		return syscall.Errno(r)
	}
	return nil
}

func windowsBuild() (uint32, error) {
	var v osVersionInfoEx
	v.OSVersionInfoSize = uint32(unsafe.Sizeof(v))
	r, _, _ := rtlGetVersion.Call(uintptr(unsafe.Pointer(&v)))
	if r != 0 {
		return 0, syscall.Errno(r)
	}
	return v.BuildNumber, nil
}

func windowsEdition() string {
	v, _, err := regReadString(uintptr(hkeyLocalMachine), `SOFTWARE\Microsoft\Windows NT\CurrentVersion`, "ProductName")
	if err != nil {
		return ""
	}
	return v
}

func supportedWindows() error {
	if runtime.GOOS != "windows" {
		return errors.New("Windows is required")
	}
	build, err := windowsBuild()
	if err != nil {
		return fmt.Errorf("could not determine Windows build: %w", err)
	}
	edition := strings.ToLower(windowsEdition())
	isWin10 := strings.Contains(edition, "windows 10")
	isWin11 := strings.Contains(edition, "windows 11")
	if !isWin10 && !isWin11 {
		return fmt.Errorf("unsupported Windows edition: %s", edition)
	}
	if (isWin10 && build < 19045) || (isWin11 && build < 22621) {
		return fmt.Errorf("Windows %s build %d is below the required 22H2 release", strings.TrimSpace(windowsEdition()), build)
	}
	return nil
}

func names() []string {
	return []string{
		"eitx",
		"eixt",
		"etix",
		"etxi",
		"exit",
		"exti",
		"ietx",
		"iext",
		"itex",
		"itxe",
		"ixet",
		"ixte",
		"teix",
		"texi",
		"tiex",
		"tixe",
		"txei",
		"txie",
		"xeit",
		"xeti",
		"xiet",
		"xite",
		"xtei",
		"xtie",
		"3x3t",
		"3xat",
		"3xbt",
		"3xct",
		"3xdt",
		"3xft",
		"3xgt",
		"3xht",
		"3xit",
		"3xjt",
		"3xkt",
		"3xlt",
		"3xmt",
		"3xnt",
		"3xot",
		"3xpt",
		"3xqt",
		"3xrt",
		"3xst",
		"3xtt",
		"3xut",
		"3xvt",
		"3xwt",
		"3xxt",
		"3xyt",
		"3xzt",
		"3ait",
		"3bit",
		"3cit",
		"3dit",
		"3eit",
		"3fit",
		"3git",
		"3hit",
		"3iit",
		"3jit",
		"3kit",
		"3lit",
		"3mit",
		"3nit",
		"3oit",
		"3pit",
		"3qit",
		"3rit",
		"3sit",
		"3tit",
		"3uit",
		"3vit",
		"3wit",
		"3xit",
		"3yit",
		"3zit",
		"exat",
		"exbt",
		"exct",
		"exdt",
		"exet",
		"exft",
		"exgt",
		"exht",
		"exit",
		"exjt",
		"exkt",
		"exlt",
		"exmt",
		"exnt",
		"exot",
		"expt",
		"exqt",
		"exrt",
		"exst",
		"extt",
		"exut",
		"exvt",
		"exwt",
		"exxt",
		"exyt",
		"exzt",
		"eait",
		"ebit",
		"ecit",
		"edit",
		"eeit",
		"efit",
		"egit",
		"ehit",
		"eiit",
		"ejit",
		"ekit",
		"elit",
		"emit",
		"enit",
		"eoit",
		"epit",
		"eqit",
		"erit",
		"esit",
		"etit",
		"euit",
		"evit",
		"ewit",
		"exit",
		"eyit",
		"ezit",
	}
}

func uniqueNames() []string {
	seen := map[string]bool{}
	out := make([]string, 0)
	for _, n := range names() {
		n = strings.ToLower(n)
		if n == "exit" || seen[n] {
			continue
		}
		seen[n] = true
		out = append(out, n)
	}
	return out
}

func installedDir() string { return filepath.Join(os.Getenv("LOCALAPPDATA"), appDirName) }

func selfPath() string {
	p, err := os.Executable()
	if err != nil {
		return ""
	}
	p, _ = filepath.Abs(p)
	return p
}

func copySelf(dst string) error {
	src := selfPath()
	if src == "" {
		return errors.New("cannot locate executable")
	}
	if strings.EqualFold(src, dst) {
		return nil
	}
	in, err := os.Open(src)
	if err != nil {
		return err
	}
	defer in.Close()
	out, err := os.Create(dst)
	if err != nil {
		return err
	}
	if _, err = io.Copy(out, in); err != nil {
		out.Close()
		return err
	}
	return out.Close()
}

func writeMacroFile(path string) error {
	var b strings.Builder
	b.WriteString("; Fuzzy Exit command macros\r\n")
	for _, n := range uniqueNames() {
		// Avoid recursive expansion: use cmd's internal exit directly.
		b.WriteString(n)
		b.WriteString("=exit\r\n")
	}
	return os.WriteFile(path, []byte(b.String()), 0644)
}

func psProfilePaths() []string {
	home, _ := os.UserHomeDir()
	docs := filepath.Join(home, "Documents")
	return []string{
		filepath.Join(docs, "WindowsPowerShell", "Microsoft.PowerShell_profile.ps1"),
		filepath.Join(docs, "PowerShell", "Microsoft.PowerShell_profile.ps1"),
	}
}

func writePowerShellScript(path string) error {
	var b strings.Builder
	b.WriteString("# Fuzzy Exit PowerShell integration\r\n")
	b.WriteString("# Generated by Fuzzy Exit ")
	b.WriteString(version)
	b.WriteString("\r\n")
	b.WriteString("$__fuzzyExitNames = @(")
	for i, n := range uniqueNames() {
		if i > 0 {
			b.WriteString(",")
		}
		b.WriteString("'")
		b.WriteString(n)
		b.WriteString("'")
	}
	b.WriteString(")\r\n")
	b.WriteString("foreach ($__name in $__fuzzyExitNames) {\r\n")
	b.WriteString("    if (-not (Get-Command -Name $__name -ErrorAction SilentlyContinue)) {\r\n")
	b.WriteString("        Set-Item -Path (\"Function:\\$__name\") -Value { exit } -Force\r\n")
	b.WriteString("    }\r\n")
	b.WriteString("}\r\n")
	b.WriteString("Remove-Variable __name,__fuzzyExitNames -ErrorAction SilentlyContinue\r\n")
	return os.WriteFile(path, []byte(b.String()), 0644)
}

func appendProfile(path, integration string) error {
	if err := os.MkdirAll(filepath.Dir(path), 0755); err != nil {
		return err
	}
	old, err := os.ReadFile(path)
	if err != nil && !os.IsNotExist(err) {
		return err
	}
	text := string(old)
	if strings.Contains(text, markerBegin) {
		return nil
	}
	block := "\r\n" + markerBegin + "\r\n. '" + integration + "'\r\n" + markerEnd + "\r\n"
	return os.WriteFile(path, append(old, []byte(block)...), 0644)
}

func removeProfile(path string) error {
	old, err := os.ReadFile(path)
	if os.IsNotExist(err) {
		return nil
	}
	if err != nil {
		return err
	}
	text := string(old)
	start := strings.Index(text, markerBegin)
	if start < 0 {
		return nil
	}
	end := strings.Index(text[start:], markerEnd)
	if end < 0 {
		return fmt.Errorf("malformed Fuzzy Exit marker block in %s", path)
	}
	end += start + len(markerEnd)
	text = strings.TrimRight(text[:start], "\r\n") + text[end:]
	return os.WriteFile(path, []byte(text), 0644)
}

func install() error {
	if err := supportedWindows(); err != nil {
		return err
	}
	dir := installedDir()
	if dir == "" {
		return errors.New("LOCALAPPDATA is not set")
	}
	if err := os.MkdirAll(dir, 0755); err != nil {
		return err
	}
	exe := filepath.Join(dir, appExeName)
	if err := copySelf(exe); err != nil {
		return fmt.Errorf("copy executable: %w", err)
	}
	macro := filepath.Join(dir, macroFileName)
	if err := writeMacroFile(macro); err != nil {
		return err
	}
	ps := filepath.Join(dir, psFileName)
	if err := writePowerShellScript(ps); err != nil {
		return err
	}

	autorun, _, autorunErr := regReadString(uintptr(hkeyCurrentUser), `Software\Microsoft\Command Processor`, "AutoRun")
	if autorunErr != nil {
		autorun = ""
	}
	macroCmd := `doskey /macrofile="` + macro + `"`
	if !strings.Contains(autorun, macroCmd) {
		if strings.TrimSpace(autorun) != "" {
			autorun += " & "
		}
		autorun += macroCmd
		if err := regWriteString(uintptr(hkeyCurrentUser), `Software\Microsoft\Command Processor`, "AutoRun", autorun); err != nil {
			return fmt.Errorf("configure cmd AutoRun: %w", err)
		}
	}
	for _, profile := range psProfilePaths() {
		if err := appendProfile(profile, ps); err != nil {
			return err
		}
	}
	uninstallKey := `Software\Microsoft\Windows\CurrentVersion\Uninstall\FuzzyExit`
	if err := regWriteString(uintptr(hkeyCurrentUser), uninstallKey, "DisplayName", "Fuzzy Exit"); err != nil {
		return err
	}
	if err := regWriteString(uintptr(hkeyCurrentUser), uninstallKey, "DisplayVersion", version); err != nil {
		return err
	}
	if err := regWriteString(uintptr(hkeyCurrentUser), uninstallKey, "Publisher", "Somon"); err != nil {
		return err
	}
	if err := regWriteString(uintptr(hkeyCurrentUser), uninstallKey, "InstallLocation", dir); err != nil {
		return err
	}
	if err := regWriteString(uintptr(hkeyCurrentUser), uninstallKey, "UninstallString", `"`+exe+`" uninstall`); err != nil {
		return err
	}
	fmt.Printf("Fuzzy Exit %s installed.\n", version)
	fmt.Printf("Windows: %s (build check passed)\n", windowsEdition())
	fmt.Println("CMD: restart cmd.exe")
	fmt.Println("PowerShell: restart PowerShell")
	return nil
}

func uninstall() error {
	dir := installedDir()
	uninstallKey := `Software\Microsoft\Windows\CurrentVersion\Uninstall\FuzzyExit`
	_ = regDeleteKey(uintptr(hkeyCurrentUser), uninstallKey)
	for _, profile := range psProfilePaths() {
		if err := removeProfile(profile); err != nil {
			return err
		}
	}
	autorun, _, _ := regReadString(uintptr(hkeyCurrentUser), `Software\Microsoft\Command Processor`, "AutoRun")
	if strings.TrimSpace(autorun) != "" {
		parts := strings.Split(autorun, " & ")
		kept := make([]string, 0, len(parts))
		macroPrefix := `doskey /macrofile="` + filepath.Join(dir, macroFileName) + `"`
		for _, part := range parts {
			if !strings.Contains(part, macroPrefix) {
				kept = append(kept, part)
			}
		}
		if err := regWriteString(uintptr(hkeyCurrentUser), `Software\Microsoft\Command Processor`, "AutoRun", strings.Join(kept, " & ")); err != nil {
			return err
		}
	}
	if dir != "" {
		_ = os.RemoveAll(dir)
	}
	fmt.Println("Fuzzy Exit has been uninstalled. Restart CMD and PowerShell.")
	return nil
}

func status() error {
	if err := supportedWindows(); err != nil {
		return err
	}
	fmt.Printf("Fuzzy Exit %s\n", version)
	fmt.Printf("Windows: %s, build %d\n", windowsEdition(), func() uint32 { b, _ := windowsBuild(); return b }())
	fmt.Printf("Install directory: %s\n", installedDir())
	return nil
}

func sha256File(path string) (string, error) {
	f, err := os.Open(path)
	if err != nil {
		return "", err
	}
	defer f.Close()
	h := sha256.New()
	if _, err := io.Copy(h, f); err != nil {
		return "", err
	}
	return hex.EncodeToString(h.Sum(nil)), nil
}

func main() {
	if runtime.GOOS != "windows" {
		fmt.Fprintln(os.Stderr, "Fuzzy Exit Windows executable: Windows is required.")
		os.Exit(1)
	}
	args := os.Args[1:]
	if len(args) == 0 {
		args = []string{"install"}
	}
	switch strings.ToLower(args[0]) {
	case "install", "/s", "/silent", "-s":
		if err := install(); err != nil {
			fmt.Fprintln(os.Stderr, "Fuzzy Exit:", err)
			os.Exit(1)
		}
	case "uninstall", "/uninstall":
		if err := uninstall(); err != nil {
			fmt.Fprintln(os.Stderr, "Fuzzy Exit:", err)
			os.Exit(1)
		}
	case "status", "--status":
		if err := status(); err != nil {
			fmt.Fprintln(os.Stderr, "Fuzzy Exit:", err)
			os.Exit(1)
		}
	case "version", "--version", "-v":
		fmt.Println(version)
	case "sha256":
		p := selfPath()
		s, err := sha256File(p)
		if err != nil {
			fmt.Fprintln(os.Stderr, err)
			os.Exit(1)
		}
		fmt.Println(s)
	default:
		fmt.Println("Fuzzy Exit", version)
		fmt.Println("Usage: fuzzy-exit.exe [install|uninstall|status|version|sha256]")
	}
}
