@echo off
title Encode Credentials to Base64
echo.
echo ================================================
echo   Base64 Encoder for GitHub Secrets (Chapter 21)
echo ================================================
echo.
echo This script encodes your binary credential files to
echo base64 text so they can be pasted into GitHub Secrets.
echo.
echo SECURITY: Base64 is NOT encryption. Delete the output
echo .txt files after pasting into GitHub Secrets.
echo.
pause

echo.
echo [1/4] Encoding distribution.p12...
if exist "distribution.p12" (
    base64 -w 0 distribution.p12 > p12_base64.txt
    echo   OK Created p12_base64.txt
) else (
    echo   SKIP distribution.p12 not found (Chapter 15)
)

echo [2/4] Encoding provisioning profile...
if exist "*.mobileprovision" (
    for %%f in (*.mobileprovision) do (
        base64 -w 0 "%%f" > profile_base64.txt
        echo   OK Created profile_base64.txt from %%f
    )
) else (
    echo   SKIP No .mobileprovision file found (Chapter 16)
)

echo [3/4] Encoding .p8 API key...
if exist "AuthKey_*.p8" (
    for %%f in (AuthKey_*.p8) do (
        cat "%%f" | base64 -w 0 > p8_base64.txt
        echo   OK Created p8_base64.txt from %%f
    )
) else (
    echo   SKIP No AuthKey_*.p8 file found (Chapter 17)
)

echo [4/4] Encoding Android keystore...
if exist "*.jks" (
    for %%f in (*.jks) do (
        base64 -w 0 "%%f" > android_keystore_base64.txt
        echo   OK Created android_keystore_base64.txt from %%f
    )
) else (
    echo   SKIP No .jks file found (Chapter 18)
)

echo.
echo ================================================
echo   NEXT STEPS:
echo ================================================
echo   1. Open each _base64.txt file in Notepad
echo   2. Ctrl+A to select all, Ctrl+C to copy
echo   3. Go to GitHub repo Settings > Secrets > Actions
echo   4. Create new secrets with these names:
echo      BUILD_CERTIFICATE_BASE64         (from p12_base64.txt)
echo      PROVISIONING_PROFILE_BASE64      (from profile_base64.txt)
echo      APP_STORE_CONNECT_PRIVATE_KEY    (from p8_base64.txt)
echo      ANDROID_KEYSTORE_BASE64          (from android_keystore_base64.txt)
echo   5. Also create these text secrets:
echo      P12_PASSWORD                     (your .p12 password)
echo      APP_STORE_CONNECT_KEY_ID         (10-char Key ID)
echo      APP_STORE_CONNECT_ISSUER_ID      (UUID Issuer ID)
echo      ANDROID_KEYSTORE_PASSWORD        (keystore password)
echo      ANDROID_KEY_ALIAS                (key alias)
echo      ANDROID_KEY_PASSWORD             (key password)
echo   6. DELETE all _base64.txt files after pasting!
echo      del *_base64.txt
echo ================================================
echo.
pause
