@echo off
setlocal EnableExtensions
cd /d "%~dp0"
if not exist "logs" mkdir "logs"
echo ==============================================================
echo PWA Toolkit 2.5 RC13 - Build Excel Macro Dashboard
echo ==============================================================
echo Each of 8 steps is logged in logs\BUILD_MACRO_DASHBOARD_RC13.log.
echo Source: "%CD%\PWA_Release_Toolkit_v2.5.xlsx"
echo If source Excel refuses to open, the builder uses packaged recovery data.
echo.
if not exist "PWA_Release_Toolkit_v2.5.xlsx" (
 echo ERROR: Source workbook missing. Extract the entire ZIP.
 pause
 exit /b 2
)
if not exist "DASHBOARD_FALLBACK_RC13.tsv" (
 echo ERROR: Recovery file missing. Extract the entire ZIP.
 pause
 exit /b 2
)
where cscript.exe >nul 2>nul
if errorlevel 1 (
 echo ERROR: Windows Script Host is unavailable.
 pause
 exit /b 2
)
cscript.exe //nologo "%~dp0BUILD_MACRO_DASHBOARD.vbs"
set "RESULT=%ERRORLEVEL%"
echo.
if not "%RESULT%"=="0" (
 echo FAILED with exit code %RESULT%.
 echo Open "logs\BUILD_MACRO_DASHBOARD_RC13.log" for the exact failed step.
 echo For blocked downloaded files: right-click ZIP, Properties, Unblock, then extract again.
) else (
 echo SUCCESS. Open PWA_Release_Toolkit_v2.5_RC13.xlsm
)
pause
exit /b %RESULT%
