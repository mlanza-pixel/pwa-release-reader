@echo off
title Generate Apple Signing Keys
echo.
echo ================================================
echo   Apple Signing Key Generator (Chapter 13-15)
echo ================================================
echo.
echo This script generates:
echo   1. RSA private key (ios_distribution.key)
echo   2. Certificate Signing Request (request.certSigningRequest)
echo   3. Converts .cer to .pem (after you download from Apple)
echo   4. Bundles into .p12 lockbox (after you download .cer)
echo.
echo You need Git Bash installed (Chapter 3) with OpenSSL.
echo.
pause

echo.
echo [Step 1] Generating 2048-bit RSA private key...
echo Enter a strong password when prompted. WRITE IT DOWN.
echo This becomes your P12_PASSWORD GitHub Secret.
echo.
openssl genrsa -out ios_distribution.key 2048
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Key generation failed. Is OpenSSL installed?
    echo Run doctor.bat to check.
    pause
    exit /b 1
)
echo.
echo [OK] Private key created: ios_distribution.key
echo IMPORTANT: Back this up to a USB stick NOW.
echo.

echo [Step 2] Generating Certificate Signing Request (CSR)...
echo You will be asked for your email, name, and country.
echo Use the SAME email as your Apple Developer account.
echo.
set /p CSR_EMAIL="Enter your Apple ID email: "
set /p CSR_NAME="Enter your full legal name: "
set /p CSR_COUNTRY="Enter 2-letter country code (e.g., US, GB, CA): "

openssl req -new -key ios_distribution.key -out request.certSigningRequest -subj "/emailAddress=%CSR_EMAIL%/CN=%CSR_NAME%/C=%CSR_COUNTRY%"
if %ERRORLEVEL% neq 0 (
    echo [ERROR] CSR generation failed. Check your input.
    pause
    exit /b 1
)
echo.
echo [OK] CSR created: request.certSigningRequest
echo.

echo [Step 3] Upload the CSR to Apple Developer Portal.
echo Go to: developer.apple.com/account/resources/certificates/list
echo Click "+" button, choose "Apple Distribution", upload request.certSigningRequest
echo Download the resulting distribution.cer file.
echo Place it in this same folder.
echo.
pause

if not exist "distribution.cer" (
    echo [ERROR] distribution.cer not found in current folder.
    echo Download it from Apple Developer Portal first.
    pause
    exit /b 1
)

echo.
echo [Step 4] Converting .cer from DER to PEM format...
openssl x509 -in distribution.cer -inform DER -out distribution.pem -outform PEM
echo [OK] Converted to: distribution.pem
echo.

echo [Step 5] Bundling into .p12 lockbox...
echo Enter a strong password for the .p12 file. WRITE IT DOWN.
echo This is your P12_PASSWORD.
echo.
set /p P12_PASS="Enter .p12 password: "
openssl pkcs12 -export -inkey ios_distribution.key -in distribution.pem -out distribution.p12 -passout pass:%P12_PASS%
if %ERRORLEVEL% neq 0 (
    echo [ERROR] .p12 creation failed.
    pause
    exit /b 1
)

echo.
echo ================================================
echo   SUCCESS! Apple signing files created:
echo ================================================
echo   ios_distribution.key       (PRIVATE - keep secret!)
echo   request.certSigningRequest (used, can delete)
echo   distribution.cer           (from Apple)
echo   distribution.pem           (intermediate, can delete)
echo   distribution.p12           (PASSWORD-PROTECTED LOCKBOX)
echo.
echo   Next: Follow Chapter 16 (Provisioning Profile)
echo   Then: Follow Chapter 17 (API Key)
echo   Then: Follow Chapter 21 (Base64 + GitHub Secrets)
echo ================================================
echo.
pause
