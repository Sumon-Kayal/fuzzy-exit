@echo off
setlocal EnableExtensions
REM Fuzzy Exit Windows installer entry point
REM SPDX-License-Identifier: GPL-3.0-or-later

REM Windows 10 22H2 = build 19045. Windows 11 22H2 = build 22621.
for /f "tokens=2,*" %%A in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v ProductName 2^>nul ^| findstr /I "ProductName"') do set "PRODUCT=%%B"
for /f "tokens=2,*" %%A in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v CurrentBuildNumber 2^>nul ^| findstr /I "CurrentBuildNumber"') do set "BUILD=%%B"
if not defined PRODUCT (
  echo Fuzzy Exit: Could not detect the Windows edition.
  exit /b 1
)
if not defined BUILD (
  echo Fuzzy Exit: Could not detect the Windows build.
  exit /b 1
)

echo %PRODUCT% | findstr /I /C:"Windows 10" >nul
if not errorlevel 1 (
  if %BUILD% LSS 19045 (
    echo Fuzzy Exit: Windows 10 22H2 or newer is required. Detected build %BUILD%.
    exit /b 1
  )
  goto RUN
)

echo %PRODUCT% | findstr /I /C:"Windows 11" >nul
if not errorlevel 1 (
  if %BUILD% LSS 22621 (
    echo Fuzzy Exit: Windows 11 22H2 or newer is required. Detected build %BUILD%.
    exit /b 1
  )
  goto RUN
)

echo Fuzzy Exit: Unsupported Windows edition: %PRODUCT%
exit /b 1

:RUN
set "ARCH=%PROCESSOR_ARCHITECTURE%"
if /I "%ARCH%"=="ARM64" set "EXE_NAME=FuzzyExit-1.0-arm64.exe"
if /I "%ARCH%"=="AMD64" set "EXE_NAME=FuzzyExit-1.0-x64.exe"
if /I "%ARCH%"=="x86" set "EXE_NAME=FuzzyExit-1.0-x86.exe"
if not defined EXE_NAME set "EXE_NAME=FuzzyExit-1.0-x64.exe"
if exist "%~dp0windows\%EXE_NAME%" (
  "%~dp0windows\%EXE_NAME%" install
  exit /b %ERRORLEVEL%
)
if exist "%~dp0%EXE_NAME%" (
  "%~dp0%EXE_NAME%" install
  exit /b %ERRORLEVEL%
)
echo Fuzzy Exit: %EXE_NAME% was not found beside this installer.
exit /b 1
