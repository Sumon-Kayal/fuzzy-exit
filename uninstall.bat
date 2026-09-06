@echo off
setlocal
set "EXE=%LOCALAPPDATA%\FuzzyExit\fuzzy-exit.exe"
if exist "%EXE%" (
  "%EXE%" uninstall
  exit /b %ERRORLEVEL%
)
echo Fuzzy Exit is not installed.
exit /b 0
