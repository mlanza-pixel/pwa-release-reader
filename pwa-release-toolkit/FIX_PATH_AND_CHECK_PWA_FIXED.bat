@echo off
setlocal EnableExtensions DisableDelayedExpansion
cd /d "%~dp0"
set "LOGDIR=%~dp0logs"
if not exist "%LOGDIR%" mkdir "%LOGDIR%" 2>nul
if not exist "%LOGDIR%" set "LOGDIR=%TEMP%"
set "LOG=%LOGDIR%\PATH_REPAIR_latest.log"
>"%LOG%" echo PWA TOOL PATH REPAIR - STARTED %DATE% %TIME%
call :say ===============================================================
call :say  PWA TOOL REPAIR - OpenSSL / Java / keytool / project files
call :say ===============================================================
call :say Log: "%LOG%"
call :say This changes only your USER PATH if a tool is already installed.
call :say Existing PATH entries will not be deleted.
call :blank
set "FIXES=0"
set "WARNINGS=0"
set "ERRORS=0"

call :say [1/6] Looking for OpenSSL...
set "OPENSSL_EXE="
for /f "delims=" %%F in ('where openssl.exe 2^>nul') do if not defined OPENSSL_EXE set "OPENSSL_EXE=%%F"
if not defined OPENSSL_EXE if exist "%ProgramFiles%\Git\mingw64\bin\openssl.exe" set "OPENSSL_EXE=%ProgramFiles%\Git\mingw64\bin\openssl.exe"
if not defined OPENSSL_EXE if exist "%ProgramFiles%\Git\usr\bin\openssl.exe" set "OPENSSL_EXE=%ProgramFiles%\Git\usr\bin\openssl.exe"
if not defined OPENSSL_EXE if exist "%ProgramFiles%\OpenSSL-Win64\bin\openssl.exe" set "OPENSSL_EXE=%ProgramFiles%\OpenSSL-Win64\bin\openssl.exe"
if not defined OPENSSL_EXE if exist "%ProgramFiles(x86)%\OpenSSL-Win32\bin\openssl.exe" set "OPENSSL_EXE=%ProgramFiles(x86)%\OpenSSL-Win32\bin\openssl.exe"
if not defined OPENSSL_EXE goto no_openssl
for %%F in ("%OPENSSL_EXE%") do set "ADD_DIR=%%~dpF"
call :add_to_path
"%OPENSSL_EXE%" version >>"%LOG%" 2>&1
if errorlevel 1 (call :warn "OpenSSL was found but did not run; check the log.") else call :say [PASS] OpenSSL works: "%OPENSSL_EXE%"
goto openssl_done
:no_openssl
call :warn "OpenSSL not found. Install Git for Windows or OpenSSL; no PATH entry was invented."
:openssl_done
call :blank

call :say [2/6] Looking for Java JDK (includes keytool)...
set "JDK_BIN="
set "JAVA_EXE="
set "KEYTOOL_EXE="
rem Prefer a full JDK (both executables), not a Java runtime-only shim.
for /d %%D in ("%ProgramFiles%\Eclipse Adoptium\jdk-*" "%ProgramFiles%\Java\jdk-*" "%ProgramFiles%\Microsoft\jdk-*" "%ProgramFiles%\Amazon Corretto\jdk*" "%ProgramFiles%\Zulu\zulu*") do if exist "%%~fD\bin\java.exe" if exist "%%~fD\bin\keytool.exe" if not defined JDK_BIN set "JDK_BIN=%%~fD\bin"
if not defined JDK_BIN if defined JAVA_HOME if exist "%JAVA_HOME%\bin\java.exe" if exist "%JAVA_HOME%\bin\keytool.exe" set "JDK_BIN=%JAVA_HOME%\bin"
if not defined JDK_BIN (
  for /f "delims=" %%F in ('where keytool.exe 2^>nul') do if not defined JDK_BIN for %%G in ("%%F") do if exist "%%~dpGjava.exe" set "JDK_BIN=%%~dpG"
)
if not defined JDK_BIN goto no_java
set "JAVA_EXE=%JDK_BIN%\java.exe"
set "KEYTOOL_EXE=%JDK_BIN%\keytool.exe"
set "ADD_DIR=%JDK_BIN%"
call :add_to_path
"%JAVA_EXE%" -version >>"%LOG%" 2>&1
if errorlevel 1 (call :warn "Java was found but would not run.") else call :say [PASS] Java works: "%JAVA_EXE%"
"%KEYTOOL_EXE%" -help >>"%LOG%" 2>&1
if errorlevel 1 (call :warn "keytool was found but would not run.") else call :say [PASS] keytool works: "%KEYTOOL_EXE%"
goto java_done
:no_java
call :warn "A complete Java JDK was not found in common locations or on PATH."
call :say Download a Windows JDK (Java + keytool) from: https://adoptium.net/
:java_done
call :blank

call :say [3/6] Checking common build tools...
where python.exe >nul 2>&1
if errorlevel 1 (call :warn "Python not found on PATH") else (for /f "delims=" %%F in ('where python.exe 2^>nul') do if not defined PYTHON_EXE set "PYTHON_EXE=%%F")
if defined PYTHON_EXE call :say [PASS] Python: "%PYTHON_EXE%"
where node.exe >nul 2>&1
if errorlevel 1 (call :warn "Node.js not found on PATH") else call :say [PASS] Node.js available
where npm.cmd >nul 2>&1
if errorlevel 1 (call :warn "npm not found on PATH") else call :say [PASS] npm available
where git.exe >nul 2>&1
if errorlevel 1 (call :warn "Git not found on PATH") else call :say [PASS] Git available
call :blank

call :say [4/6] Confirming commands can run in THIS window...
where openssl.exe >>"%LOG%" 2>&1
if errorlevel 1 (call :warn "openssl is still not on this window's PATH") else call :say [PASS] openssl is on PATH
where java.exe >>"%LOG%" 2>&1
if errorlevel 1 (call :warn "java is still not on this window's PATH") else call :say [PASS] java is on PATH
where keytool.exe >>"%LOG%" 2>&1
if errorlevel 1 (call :warn "keytool is still not on this window's PATH") else call :say [PASS] keytool is on PATH
call :blank

call :say [5/6] Optional PWA project file checks
call :say Enter the folder of YOUR APP (the folder containing package.json).
call :say Do not select the reader/toolkit ZIP folder unless that is your actual app.
set "PROJECT="
set /p "PROJECT=Project folder (or press ENTER to skip): "
if not defined PROJECT goto project_skipped
if "%PROJECT:~0,1%"=="\"" set "PROJECT=%PROJECT:~1,-1%"
if not exist "%PROJECT%\" goto project_missing
call :say Project folder: "%PROJECT%"
if exist "%PROJECT%\package.json" (call :say [PASS] package.json) else call :warn "Missing package.json - select the application root, not the toolkit folder"
if exist "%PROJECT%\dist\index.html" (call :say [PASS] dist\index.html) else call :warn "Missing dist\index.html - the web build may not have been run"
if exist "%PROJECT%\.gitignore" (call :say [PASS] .gitignore) else call :warn "Missing .gitignore - protect signing keys before using git add"
if exist "%PROJECT%\capacitor.config.ts" goto cap_present
if exist "%PROJECT%\capacitor.config.js" goto cap_present
if exist "%PROJECT%\capacitor.config.json" goto cap_present
call :warn "Missing capacitor.config.ts/.js/.json - Capacitor may not be configured"
goto cap_done
:cap_present
call :say [PASS] Capacitor configuration found
:cap_done
if exist "%PROJECT%\.git\" (call :say [PASS] Git repository initialized) else call :warn "No .git directory at selected project root"
goto project_done
:project_missing
call :warn "Selected project folder was not found; check the pasted path"
goto project_done
:project_skipped
call :say [SKIP] Project file checks skipped
:project_done
call :blank

call :say [6/6] Finished
call :say PATH folders newly added: %FIXES%
call :say Warnings: %WARNINGS%
call :say Log file: "%LOG%"
call :say NOTE: Close and reopen Excel and Command Prompt for the new USER PATH.
call :say NOTE: No software was installed. Missing JDKs must be installed separately.
call :say NOTE: This script does NOT build, sign, or publish an app.
call :blank
pause
exit /b 0

:add_to_path
rem Only PowerShell changes the USER PATH. Windows system PATH is untouched.
if not defined ADD_DIR exit /b 0
if "%ADD_DIR:~-1%"=="\" set "ADD_DIR=%ADD_DIR:~0,-1%"
if not exist "%ADD_DIR%\" (call :warn "PATH candidate folder does not exist" & exit /b 1)
where powershell.exe >nul 2>&1
if errorlevel 1 (call :warn "PowerShell missing; cannot safely persist PATH" & exit /b 1)
set "PATH_ACTION="
for /f "delims=" %%R in ('powershell.exe -NoProfile -NonInteractive -Command "$d=$env:ADD_DIR; $old=[Environment]::GetEnvironmentVariable('Path','User'); if($null -eq $old){$old=''}; $items=@($old -split ';'); if($items -contains $d){'ALREADY'}else{ $new=($old.TrimEnd(';')+';'+$d).TrimStart(';'); [Environment]::SetEnvironmentVariable('Path',$new,'User'); 'ADDED' }" 2^>nul') do set "PATH_ACTION=%%R"
if "%PATH_ACTION%"=="ADDED" (
  set /a FIXES+=1 >nul
  call :say [FIXED] Added "%ADD_DIR%" to USER PATH
) else if "%PATH_ACTION%"=="ALREADY" (
  call :say [INFO] Folder is already in USER PATH: "%ADD_DIR%"
) else (
  call :warn "Could not update user PATH; see Windows Environment Variables"
)
rem Make new folder available to checks in this current CMD session too.
set "PATH=%PATH%;%ADD_DIR%"
exit /b 0

:warn
set /a WARNINGS+=1 >nul
call :say [WARN] %~1
exit /b 0

:say
echo(%*
>>"%LOG%" echo(%*
exit /b 0

:blank
echo(
>>"%LOG%" echo(
exit /b 0
