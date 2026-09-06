$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root
$env:CGO_ENABLED = '0'
$env:GOOS = 'windows'
foreach ($arch in @('amd64','arm64','386')) {
    $env:GOARCH = $arch
    $name = switch ($arch) { 'amd64' { 'x64' } 'arm64' { 'arm64' } '386' { 'x86' } }
    & go build -trimpath -ldflags='-s -w' -o "windows/FuzzyExit-1.0-$name.exe" ./windows
    if ($LASTEXITCODE) { exit $LASTEXITCODE }
}
exit 0
