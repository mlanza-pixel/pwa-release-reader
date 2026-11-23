@echo off
setlocal
cd /d "%~dp0"
if not exist "logs" mkdir "logs" 2>nul
set "PROJECT=%~1"
if "%PROJECT%"=="" set /p "PROJECT=Enter your PWA project folder path: "
call "%~dp0RUN_DOCTOR_STEP_BY_STEP.bat" "%PROJECT%" doctor
set "RESULT=%ERRORLEVEL%"
echo.
echo Logs saved in: "%~dp0logs"
pause
exit /b %RESULT%
