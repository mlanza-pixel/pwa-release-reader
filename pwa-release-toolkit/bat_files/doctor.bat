@echo off
title PWA Doctor - Diagnostic Health Check v2.3

REM ============================================================
REM  PWA DOCTOR v2.3 - Bulletproof version
REM
REM  BUG FIXED: npm is a .cmd wrapper, not an .exe. Calling
REM  "npm -v" from inside a .bat file WITHOUT "call" causes
REM  the batch to transfer control to npm.cmd and NEVER RETURN.
REM  This killed the script after check 2.
REM
REM  FIX: Use "call npm -v" for npm commands.
REM  Also use "for /f" to capture version output safely.
REM ============================================================

set RESULTS_FILE=%~dp0doctor_results.txt
set PASS=0
set FAIL=0

echo ================================================ > "%RESULTS_FILE%"
echo   PWA DOCTOR - Diagnostic Health Check v2.3      >> "%RESULTS_FILE%"
echo   Date: %date% at %time%                          >> "%RESULTS_FILE%"
echo   Folder: %CD%                                    >> "%RESULTS_FILE%"
echo ================================================ >> "%RESULTS_FILE%"
echo.                                                  >> "%RESULTS_FILE%"

REM ---- Check 1: Node.js ----
echo [1/6] Checking Node.js... >> "%RESULTS_FILE%"
where node >nul 2>nul
if %ERRORLEVEL% neq 0 goto node_fail

for /f "delims=" %%v in ('node -v 2^>nul') do set NODE_VER=%%v
echo   PASS - Node.js found: %NODE_VER% >> "%RESULTS_FILE%"
echo. >> "%RESULTS_FILE%"
set /a PASS+=1
goto check2

:node_fail
echo   FAIL - Node.js NOT found in PATH >> "%RESULTS_FILE%"
echo     FIX: Reinstall Node.js LTS from nodejs.org >> "%RESULTS_FILE%"
echo     FIX: Check "Add to PATH" during install (Chapter 2 Step 7) >> "%RESULTS_FILE%"
echo     FIX: Close this window, open a NEW one, retry >> "%RESULTS_FILE%"
echo. >> "%RESULTS_FILE%"
set /a FAIL+=1

:check2
REM ---- Check 2: npm ----
REM CRITICAL: npm is a .cmd file, must use "call" or it kills the script!
echo [2/6] Checking npm... >> "%RESULTS_FILE%"
where npm >nul 2>nul
if %ERRORLEVEL% neq 0 goto npm_fail

for /f "delims=" %%v in ('call npm -v 2^>nul') do set NPM_VER=%%v
echo   PASS - npm found: %NPM_VER% >> "%RESULTS_FILE%"
echo. >> "%RESULTS_FILE%"
set /a PASS+=1
goto check3

:npm_fail
echo   FAIL - npm NOT found in PATH >> "%RESULTS_FILE%"
echo     FIX: Reinstall Node.js (npm ships with Node) >> "%RESULTS_FILE%"
echo. >> "%RESULTS_FILE%"
set /a FAIL+=1

:check3
REM ---- Check 3: Git ----
echo [3/6] Checking Git... >> "%RESULTS_FILE%"
where git >nul 2>nul
if %ERRORLEVEL% neq 0 goto git_fail

for /f "delims=" %%v in ('git --version 2^>nul') do set GIT_VER=%%v
echo   PASS - Git found: %GIT_VER% >> "%RESULTS_FILE%"
echo. >> "%RESULTS_FILE%"
set /a PASS+=1
goto check4

:git_fail
echo   FAIL - Git NOT found in PATH >> "%RESULTS_FILE%"
echo     FIX: Reinstall Git for Windows (Chapter 3) >> "%RESULTS_FILE%"
echo     FIX: Choose "Git from command line" in Step 8 >> "%RESULTS_FILE%"
echo. >> "%RESULTS_FILE%"
set /a FAIL+=1

:check4
REM ---- Check 4: OpenSSL ----
echo [4/6] Checking OpenSSL (the secret weapon)... >> "%RESULTS_FILE%"
where openssl >nul 2>nul
if %ERRORLEVEL% neq 0 goto ssl_fail

for /f "delims=" %%v in ('openssl version 2^>nul') do set SSL_VER=%%v
echo   PASS - OpenSSL found: %SSL_VER% >> "%RESULTS_FILE%"
echo. >> "%RESULTS_FILE%"
set /a PASS+=1
goto check5

:ssl_fail
echo   FAIL - OpenSSL NOT found >> "%RESULTS_FILE%"
echo     FIX: Reinstall Git for Windows (Chapter 3) >> "%RESULTS_FILE%"
echo     FIX: In Step 9, choose "Use the OpenSSL library" >> "%RESULTS_FILE%"
echo     FIX: This is CRITICAL - without OpenSSL, Part IV fails >> "%RESULTS_FILE%"
echo. >> "%RESULTS_FILE%"
set /a FAIL+=1

:check5
REM ---- Check 5: Project structure ----
echo [5/6] Checking project structure... >> "%RESULTS_FILE%"
if not exist "package.json" goto pkg_fail

echo   PASS - package.json found >> "%RESULTS_FILE%"
set /a PASS+=1
goto check5b

:pkg_fail
echo   FAIL - package.json NOT found >> "%RESULTS_FILE%"
echo     FIX: You are not in the project folder >> "%RESULTS_FILE%"
echo     FIX: Run this from your project root folder >> "%RESULTS_FILE%"
set /a FAIL+=1

:check5b
if not exist "dist\index.html" goto dist_warn

echo   PASS - dist\index.html found >> "%RESULTS_FILE%"
set /a PASS+=1
goto check6

:dist_warn
echo   WARN - dist\index.html NOT found yet >> "%RESULTS_FILE%"
echo     (OK if you haven't reached Chapter 8 yet) >> "%RESULTS_FILE%"

:check6
echo. >> "%RESULTS_FILE%"
REM ---- Check 6: VS Code ----
echo [6/6] Checking VS Code... >> "%RESULTS_FILE%"
where code >nul 2>nul
if %ERRORLEVEL% neq 0 goto code_fail

echo   PASS - VS Code found in PATH >> "%RESULTS_FILE%"
echo. >> "%RESULTS_FILE%"
set /a PASS+=1
goto summary

:code_fail
echo   FAIL - VS Code NOT in PATH >> "%RESULTS_FILE%"
echo     FIX: Reinstall VS Code (Chapter 4) >> "%RESULTS_FILE%"
echo     FIX: Check "Add to PATH" in Step 7 >> "%RESULTS_FILE%"
echo. >> "%RESULTS_FILE%"
set /a FAIL+=1

:summary
echo ================================================ >> "%RESULTS_FILE%"
echo   DIAGNOSIS: %PASS% passed, %FAIL% failed        >> "%RESULTS_FILE%"
echo ================================================ >> "%RESULTS_FILE%"
echo. >> "%RESULTS_FILE%"

if %FAIL% equ 0 goto all_pass

echo   %FAIL% check(s) FAILED. Read the FIX lines above. >> "%RESULTS_FILE%"
echo   Fix the issues, then double-click doctor.bat again. >> "%RESULTS_FILE%"
echo. >> "%RESULTS_FILE%"
goto show_results

:all_pass
echo   ALL CHECKS PASSED - you are ready for Part II! >> "%RESULTS_FILE%"
echo. >> "%RESULTS_FILE%"
echo   Next step: Read Chapter 6 (Concept Primer) >> "%RESULTS_FILE%"
echo. >> "%RESULTS_FILE%"

:show_results
echo ================================================ >> "%RESULTS_FILE%"
echo   Results saved to: doctor_results.txt            >> "%RESULTS_FILE%"
echo   You can open this file in Notepad anytime.      >> "%RESULTS_FILE%"
echo ================================================ >> "%RESULTS_FILE%"
echo. >> "%RESULTS_FILE%"

REM ---- Display results on screen ----
echo.
type "%RESULTS_FILE%"
echo.

REM ---- Open in Notepad (stays open even if CMD closes) ----
start notepad "%RESULTS_FILE%"

echo ================================================
echo   Results saved to: doctor_results.txt
echo   Notepad should be open with your results.
echo ================================================
echo.
echo Press any key to close this window...
pause >nul
