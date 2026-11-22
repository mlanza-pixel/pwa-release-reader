@echo off
title PWA Mobile Cloud Deployer v2.3
echo.
echo [1/5] Auditing project directory and tools...
echo.

if not exist "package.json" (
    echo [ERROR] package.json missing! You are not in the project root.
    echo Current directory: %CD%
    pause
    exit /b 1
)

if not exist "dist\index.html" (
    echo [ERROR] dist\index.html missing! Your PWA files are not in the dist folder.
    pause
    exit /b 1
)

echo [OK] Project structure looks good.
echo.
echo [2/5] Synchronizing web assets with Capacitor native containers...
echo.

call npx cap sync
if %ERRORLEVEL% neq 0 (
    echo [ERROR] npx cap sync failed. See errors above.
    pause
    exit /b 1
)

echo.
echo [3/5] Capturing commit snapshot...
echo.

set /p COMMIT_MSG="Enter commit description (Press Enter for auto-date): "
if "%COMMIT_MSG%"=="" set COMMIT_MSG=Auto-deploy build on %date% at %time%

echo.
echo [4/5] Staging files and creating local commit...
echo.

git add .
git commit -m "%COMMIT_MSG%"

echo.
echo [5/5] Pushing payload to GitHub repository...
echo.

git push origin main
if %ERRORLEVEL% neq 0 (
    echo.
    echo [ERROR] git push FAILED! Payload was NOT delivered.
    echo.
    echo Common causes:
    echo   1. Authentication failed - your PAT may have expired.
    echo      Fix: github.com/settings/tokens, regenerate with No expiration
    echo   2. Rejected non-fast-forward - run git pull origin main --rebase
    echo   3. Network error - check internet connection.
    echo.
    echo The cloud build was NOT triggered. Fix the issue and retry.
    echo.
    pause
    exit /b 1
)

echo.
echo [SUCCESS] Payload delivered! Cloud Mac runner booted on GitHub Actions.
echo.
echo Open https://github.com/YOUR_USERNAME/YOUR_REPO/actions to watch the build.
echo.
pause
