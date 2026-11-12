@echo off
setlocal EnableExtensions
if not defined SystemRoot set "SystemRoot=C:\Windows"
set "PATH=%SystemRoot%\System32;%SystemRoot%;%SystemRoot%\System32\WindowsPowerShell\v1.0;%PATH%"
set "PS=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
if not exist "%PS%" set "PS=%SystemRoot%\Sysnative\WindowsPowerShell\v1.0\powershell.exe"
if not exist "%PS%" (
  echo CHYBA: Neni nalezen Windows PowerShell.
  pause
  exit /b 1
)
"%PS%" -NoProfile -ExecutionPolicy Bypass -File "%~dp0EXPORT_INSTALLED_APK_OBB_TO_XAPK.ps1"
set "RC=%ERRORLEVEL%"
echo.
pause
exit /b %RC%
