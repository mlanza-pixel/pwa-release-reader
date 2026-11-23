# Toolkit v2.5 RC5 — start without technical experience

**What it does:** The Excel dashboard and a Python checker show whether your Windows computer and PWA project have important prerequisites. It does **not** sign or publish phone apps.

## Start in Windows

1. Extract the entire ZIP to `Documents\PWA Release Toolkit` (or another folder you can find).
2. Double-click `pwa-release-toolkit\BUILD_MACRO_DASHBOARD.bat`. This calls desktop Microsoft Excel to create `PWA_Release_Toolkit_v2.5_RC5.xlsm` in the same folder. A successful Windows build has **not** been verified by us.
3. If you trust the inspected local macros, open the generated workbook. Otherwise open the included `.xlsx` for manual tracking.
4. Read the **Read This First** sheet, then the **Dashboard** sheet.
5. Click **Choose Project** and select **YOUR app folder**, normally the one containing `package.json`. Do not select the toolkit folder.
6. Click **Run Doctor**. The window and Excel show progress. Click **Refresh Results** if needed and read the Checks tab.
7. If `.gitignore` is missing, inspect the safety changes before clicking **Prepare Safety**. This changes your project's `.gitignore` only; it does not upload anything.
8. Open the book and do Chapters 1 through 38 in order. After each chapter, mark the actual result in **Chapter Progress**. Write account confirmations, dates, problems, or screenshots in **Manual Log**, but never passwords or signing keys.

## Troubleshooting

- If the `.xlsm` cannot be generated, you may lack desktop Excel or the necessary VBA project trust permission. Do not weaken organization security settings to bypass a policy; use the `.xlsx` and `START_HERE_v2_5.bat`.
- If Python is missing, install from https://www.python.org/downloads/windows/ , reopen Excel, and rerun.
- For errors see `logs\last_console.txt`, `logs\progress.txt`, `logs\checks.tsv`, and `logs\last_doctor.json` after a diagnostic run.
- A `PASS` is only for that individual check. `WARN` means review. `FAIL` means a prerequisite failed. None represents publishing approval.

## Important official sites

- https://nodejs.org/en/download
- https://git-scm.com/downloads/win
- https://capacitorjs.com/docs
- https://developer.apple.com/account/
- https://appstoreconnect.apple.com/
- https://play.google.com/console/
- https://support.google.com/googleplay/android-developer/answer/14151465
- https://docs.github.com/en/billing/concepts/product-billing/github-actions

## Not supported in this RC

- Running signing/encoding/deploy BATs in production
- Enabling the bundled GitHub Actions templates for app release
- Automatic password/key submission or Apple/Google store publishing
- Claiming a browser preview substitutes for testing on real devices
