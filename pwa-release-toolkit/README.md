# PWA Release Toolkit v2.5 RC11 — Start Here

1. Extract the complete ZIP. In the `pwa-release-toolkit` folder, run `BUILD_MACRO_DASHBOARD.bat` to create the Excel dashboard. Logs: `logs/BUILD_MACRO_DASHBOARD_RC11.log`.
2. Open the new `.xlsm` only if you trust and are permitted to use macros. The `.xlsx` is a manual checklist fallback.
3. Read **Chapter 39** in the interactive book for each button, **Chapter 40** for PATH repair, **Chapter 41** for PASS/WARN/FAIL and logs, and **Chapter 42** for a PWA with root `index.html` but no `package.json`.
4. Choose your *own app folder*, not this toolkit folder. Run Doctor and read Checks and Run Log before preparing or uploading files.
5. The corrected `FIX_PATH_AND_CHECK_PWA_FIXED.bat` is included. It searches installed OpenSSL/JDK tools and may update **User PATH**, with a log at `logs/PATH_REPAIR_latest.log`.
6. The GitHub browser-upload instructions remain in Chapters 20–21 and `GITHUB_FIRST_UPLOAD_COOKBOOK_RC7.md`. Check safety before manually uploading.

**Not certified:** Actual Windows Excel/VBA, signing, cloud builds, and store publishing. Publishing/legacy signing helpers are intentionally blocked. Do not put keys, passwords or tokens in Excel or Git. `.gitignore` does not remove keys already committed.
