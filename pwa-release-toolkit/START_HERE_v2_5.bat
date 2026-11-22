@echo off
setlocal
cd /d "%~dp0"
echo ======================================================
echo PWA RELEASE TOOLKIT v2.5 RC5 - BEGINNER START
echo ======================================================
echo Step 1 - Check Python
where python >nul 2>nul
if errorlevel 1 (echo FAIL: Python is missing from PATH. Install Python 3 and restart this window. & pause & exit /b 2)
set "PROJECT=%~1"
if "%PROJECT%"=="" set /p "PROJECT=Step 2 - Enter your PWA PROJECT folder path: "
if "%PROJECT%"=="" (echo CANCELLED: No project selected. & pause & exit /b 2)
if not exist "logs" mkdir "logs"
echo Step 3 - Running checks; each step will be shown below.
python -u "python\pwa_console.py" doctor --project "%PROJECT%" --output "logs\last_doctor.json" --progress "logs\progress.txt" --status-tsv "logs\checks.tsv" --console-log "logs\last_console.txt"
set "RESULT=%ERRORLEVEL%"
echo ------------------------------------------------------
echo Results: logs\checks.tsv and logs\last_doctor.json
echo Exit status: %RESULT% ^(0 = no FAIL, 1 = FAIL found, 2 = setup error^)
pause
exit /b %RESULT%
