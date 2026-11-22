# PWA Release Toolkit v2.5 RC4 — Excel Control Panel

## What to do on Windows

1. Extract the **entire** ZIP into a normal folder such as `Documents\PWA Toolkit`. Do not run files from inside a ZIP.
2. Open `BUILD_MACRO_DASHBOARD.bat`. It calls Windows Script Host and desktop Microsoft Excel to import the VBA module and save `PWA_Release_Toolkit_v2.5_RC4.xlsm`.
3. If it says **Trust access to the VBA project object model**, in Excel go to **File → Options → Trust Center → Trust Center Settings → Macro Settings** and enable that setting only while running the builder. Turn it back off afterwards. Your organization may prohibit the setting.
4. Open the resulting `.xlsm` in desktop Excel. **Only enable macros if you trust this local package**. In environments that block VBA, the workbook remains a manual tracker and `START_HERE_v2_5.bat` can run diagnostics separately.
5. Click **Choose Project** and select the PWA app's own root folder (containing `package.json`). Click **Run Doctor**. The status line changes as Python completes checks. Review the `Checks` worksheet.
6. If the doctor flags missing `.gitignore` rules, click **Prepare Safety**, confirm the change, and rerun **Run Doctor**.
7. Manually record account signups, payments, uploads, signing, device tests, and approvals in `Manual Log`. No publishing is automatic.

## What is automated

- `python/pwa_console.py` runs safe, read-only tool checks and project-file diagnostics. The optional `prepare` command adds missing `.gitignore` patterns only after explicit confirmation.
- Progress is written to `logs/progress.txt` as each check completes; complete console output is written to `logs/last_console.txt`; `logs/last_doctor.json` is machine readable and `logs/checks.tsv` imports directly into Excel.
- Excel buttons are created by the VBS builder and call the VBA module. The VBA controller waits for the Python process and updates Dashboard and Checks. Manual fields are never overwritten.

## What is deliberately NOT automated

- Apple Developer enrollment or account login, App Store Connect approval, Xcode signing, secrets upload, Google Play enrollment or testing, production deployment, store submission, or cloud build approval.
- The supplied build workflow templates and legacy signing/deploy batch scripts remain blocked pending Windows/native verification. Do not treat diagnostic PASS as approval to publish.

## Help if something fails

- No `.xlsm`: Microsoft Excel Desktop or the VBA project object model trust setting may be unavailable. Use the `.xlsx` manual dashboard and run `START_HERE_v2_5.bat` instead.
- `Python not found`: install Python 3 for Windows and reopen Excel. Type `python --version` in Command Prompt.
- No result imported: check `logs/last_console.txt` then `logs/progress.txt`; rerun doctor using `START_HERE_v2_5.bat`.
- A `FAIL` means a prerequisite did not pass, not that your files were deleted.

## Status meaning

**PASS:** individual check passed. **WARN:** review required; workflow may be incomplete. **FAIL:** prerequisite missing. **RUNNING:** still checking. **NEEDS ATTENTION:** Python reported failure; inspect log. **MANUAL:** requires a human to complete and mark evidence in Excel. **BLOCKED:** no automated store-release operation provided.

## Important links

- Python: https://www.python.org/downloads/windows/
- Node.js: https://nodejs.org/en/download
- Git for Windows: https://git-scm.com/download/win
- GitHub: https://github.com/
- GitHub Actions: https://docs.github.com/en/actions
- Apple Developer: https://developer.apple.com/account/
- App Store Connect: https://appstoreconnect.apple.com/
- Google Play Console: https://play.google.com/console/
- Google Play testing: https://support.google.com/googleplay/android-developer/answer/14151465
- Capacitor: https://capacitorjs.com/docs
