@echo off
setlocal
cd /d "%~dp0"
echo PWA Toolkit 2.5 RC5 - Build Excel Macro Dashboard
echo This will use Microsoft Excel Desktop to create a local .xlsm workbook.
where cscript.exe >nul 2>nul
if errorlevel 1 (echo ERROR: Windows Script Host is required. & pause & exit /b 2)
cscript.exe //nologo "BUILD_MACRO_DASHBOARD.vbs"
set "RESULT=%ERRORLEVEL%"
if not "%RESULT%"=="0" echo Open README_RC5.md for troubleshooting.
pause
exit /b %RESULT%
