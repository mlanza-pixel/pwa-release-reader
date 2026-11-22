@echo off
title Generate Android Keystore
echo.
echo ================================================
echo   Android Keystore Generator (Chapter 18)
echo ================================================
echo.
echo This script generates a Java keystore (.jks) for signing
echo your Android .aab bundles for Google Play.
echo.
echo Prerequisite: Java JDK 17+ must be installed.
echo Run doctor.bat to verify Java is available.
echo.
pause

echo.
echo [Step 1] Generating keystore...
echo You will be asked several questions. Answer them honestly.
echo.
echo IMPORTANT: WRITE DOWN the keystore password, key alias,
echo and key password. You will need them for GitHub Secrets.
echo.

set /p KS_NAME="Enter keystore filename (default: my-release-key.jks): "
if "%KS_NAME%"=="" set KS_NAME=my-release-key.jks
set /p KS_ALIAS="Enter key alias (default: my-key-alias): "
if "%KS_ALIAS%"=="" set KS_ALIAS=my-key-alias

keytool -genkeypair -v -keystore %KS_NAME% -keyalg RSA -keysize 2048 -validity 10000 -alias %KS_ALIAS%
if %ERRORLEVEL% neq 0 (
    echo.
    echo [ERROR] Keystore generation failed.
    echo Is Java JDK installed? Run doctor.bat to check.
    pause
    exit /b 1
)

echo.
echo ================================================
echo   SUCCESS! Android keystore created:
echo ================================================
echo   %KS_NAME%
echo   Key alias: %KS_ALIAS%
echo.
echo   WRITE DOWN these 3 things for GitHub Secrets:
echo   1. Keystore password    (ANDROID_KEYSTORE_PASSWORD)
echo   2. Key alias            (ANDROID_KEY_ALIAS = %KS_ALIAS%)
echo   3. Key password         (ANDROID_KEY_PASSWORD)
echo.
echo   IMPORTANT: Back up %KS_NAME% to a USB stick NOW.
echo   If you lose it, you CANNOT update your app on Google Play.
echo ================================================
echo.
pause
