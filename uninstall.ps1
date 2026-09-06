$exe = Join-Path $env:LOCALAPPDATA 'FuzzyExit\fuzzy-exit.exe'
if (Test-Path $exe) {
    & $exe uninstall
    exit $LASTEXITCODE
}
Write-Host 'Fuzzy Exit is not installed.'
