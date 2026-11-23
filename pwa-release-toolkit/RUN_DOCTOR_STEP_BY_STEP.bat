@echo off
setlocal EnableExtensions DisableDelayedExpansion
cd /d "%~dp0"
if not exist "logs" mkdir "logs" 2>nul
set "LOG=%~dp0logs\startup_doctor.log"
set "EXIT=%~dp0logs\exit_code.txt"
set "STATE=%~dp0logs\run_state.txt"
set "PROJECT=%~1"
set "MODE=%~2"
if "%MODE%"=="" set "MODE=doctor"
>>"%LOG%" echo ===== New run %DATE% %TIME% =====
>>"%LOG%" echo PWA Toolkit v2.5 RC13 - Run Doctor startup
>"%STATE%" echo 1/7 - Starting Windows launcher
if exist "%EXIT%" del /q "%EXIT%" >nul 2>nul
echo.
echo ==============================================================
echo PWA RELEASE TOOLKIT v2.5 RC13 - STEP BY STEP CHECK
echo ==============================================================
echo Your startup log: "%LOG%"
echo Your Python log: "%~dp0logs\last_console.txt"
echo.
echo [1/7] Checking toolkit folder and logs...
>>"%LOG%" echo [1/7] Toolkit location checked
if not exist "%~dp0python\pwa_console.py" (
  call :fail 2 "Missing python\pwa_console.py. Extract the complete ZIP."
  goto :end
)
>"%STATE%" echo 2/7 - Checking project folder
echo [2/7] Checking selected project folder...
if not defined PROJECT (
  call :fail 2 "No project selected. Use Choose Project in Excel."
  goto :end
)
if not exist "%PROJECT%\" (
  call :fail 2 "The selected project folder does not exist."
  goto :end
)
>>"%LOG%" echo [2/7] Project folder exists
>"%STATE%" echo 3/7 - Locating Python
echo [3/7] Looking for Python...
set "PYTHON_CMD=python"
where python >nul 2>nul
if errorlevel 1 (
  where py >nul 2>nul
  if errorlevel 1 (
    call :fail 2 "Python not found. Install Python 3, reopen Excel, and retry."
    goto :end
  )
  set "PYTHON_CMD=py -3"
)
>>"%LOG%" echo [3/7] Python command: %PYTHON_CMD%
>"%STATE%" echo 4/7 - Checking Python runtime
echo [4/7] Checking Python runtime...
%PYTHON_CMD% -c "import sys; assert sys.version_info.major == 3; print(sys.version)" >>"%LOG%" 2>&1
if errorlevel 1 (
  call :fail 2 "Python could not start. Read startup_doctor.log."
  goto :end
)
>"%STATE%" echo 5/7 - Checking Python console
echo [5/7] Checking toolkit Python console...
%PYTHON_CMD% "%~dp0python\pwa_console.py" --help >>"%LOG%" 2>&1
if errorlevel 1 (
  call :fail 2 "Python console failed to load. Read startup_doctor.log."
  goto :end
)
>"%STATE%" echo 6/7 - Running %MODE% checks
echo [6/7] Running %MODE% checks. Each result should appear below...
>>"%LOG%" echo [6/7] Python checks started
%PYTHON_CMD% -u "%~dp0python\pwa_console.py" %MODE% --project "%PROJECT%" --output "%~dp0logs\last_doctor.json" --progress "%~dp0logs\progress.txt" --status-tsv "%~dp0logs\checks.tsv" --console-log "%~dp0logs\last_console.txt" --history-dir "%~dp0logs"
set "RC=%ERRORLEVEL%"
>>"%LOG%" echo [6/7] Python exit code: %RC%
>"%STATE%" echo 7/7 - Completed, check results
if "%RC%"=="0" (echo [7/7] Finished - see Checks sheet for PASS and WARN.) else (echo [7/7] Attention needed - Python exited with code %RC%.)
>>"%LOG%" echo [7/7] Finish, return code %RC%
>"%EXIT%" echo %RC%
goto :end
:fail
set "RC=%~1"
echo ERROR: %~2
>>"%LOG%" echo ERROR: %~2
>"%STATE%" echo FAILED - %~2
>"%EXIT%" echo %RC%
exit /b 0
:end
if not defined RC set "RC=2"
echo.
echo Startup log: "%LOG%"
echo Python log: "%~dp0logs\last_console.txt"
echo Check output: "%~dp0logs\checks.tsv"
exit /b %RC%
