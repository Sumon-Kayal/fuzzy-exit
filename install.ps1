# Fuzzy Exit Windows PowerShell installer entry point
# SPDX-License-Identifier: GPL-3.0-or-later

$ErrorActionPreference = 'Stop'

function Get-WindowsBuildInfo {
    $cv = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
    [pscustomobject]@{
        ProductName = [string]$cv.ProductName
        Build = [int]$cv.CurrentBuildNumber
    }
}

$info = Get-WindowsBuildInfo
$is10 = $info.ProductName -like '*Windows 10*'
$is11 = $info.ProductName -like '*Windows 11*'
if (-not $is10 -and -not $is11) { throw "Fuzzy Exit: Unsupported Windows edition: $($info.ProductName)" }
if (($is10 -and $info.Build -lt 19045) -or ($is11 -and $info.Build -lt 22621)) {
    throw "Fuzzy Exit: Windows 10 22H2 (build 19045) or Windows 11 22H2 (build 22621) or newer is required. Detected $($info.ProductName), build $($info.Build)."
}

$exeName = switch ($env:PROCESSOR_ARCHITECTURE) {
    'ARM64' { 'FuzzyExit-1.0-arm64.exe' }
    'AMD64' { 'FuzzyExit-1.0-x64.exe' }
    'x86'   { 'FuzzyExit-1.0-x86.exe' }
    default { 'FuzzyExit-1.0-x64.exe' }
}
$exe = Join-Path $PSScriptRoot "windows\$exeName"
if (-not (Test-Path $exe)) { $exe = Join-Path $PSScriptRoot $exeName }
if (-not (Test-Path $exe)) { throw "Fuzzy Exit: $exeName was not found beside this installer." }

& $exe install
exit $LASTEXITCODE
