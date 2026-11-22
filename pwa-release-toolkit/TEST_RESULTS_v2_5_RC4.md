# PWA Release Toolkit v2.5 RC4 — Test Evidence

## Executed in the Linux test environment

- 15 existing Python unit tests: **PASS**.
- A temporary project diagnostic: emitted individual check lines, `logs/progress.txt`, `logs/checks.tsv` and `logs/last_doctor.json`: **PASS**. The artificial project intentionally lacked some prerequisites and produced FAIL correctly.
- Safe `prepare` on an isolated temporary project: created `.gitignore`, wrote a final progress marker and Excel-friendly TSV: **PASS**.
- Excel `.xlsx` internal ZIP integrity and seven expected worksheets: **PASS**.
- VBA public macro procedure names, builder button bindings, workbook status import row alignment, project path cells, and progress/result CLI arguments: **PASS (static)**.
- All active Windows `.bat` entrypoints: no UTF-8 BOM, no NUL bytes, and recognized `@echo off` opening: **PASS (static)**.
- Book navigation IDs and existing local image references: verified structurally with a local checker.

## NOT executed / NOT certified

- No Windows Excel COM / VBScript / VBA runtime was available, so `BUILD_MACRO_DASHBOARD.bat`, `BUILD_MACRO_DASHBOARD.vbs`, the generated `.xlsm`, and Excel action buttons remain **UNVERIFIED on Windows**.
- Mac/iOS codesigning, Android signing, GitHub Actions production CI and Apple/Google submissions remain **BLOCKED** until actual account, device, billing and build testing.
- The `.xlsm` is intentionally generated on the user's Windows machine, instead of shipping an unverifiable precompiled VBA binary. `PWA_Release_Toolkit_v2.5.xlsx` is the manual dashboard fallback.

## Smoke test on Windows

1. Extract the entire archive and double-click `BUILD_MACRO_DASHBOARD.bat`.
2. Check that `PWA_Release_Toolkit_v2.5_RC4.xlsm` is created and its five buttons are visible.
3. Select a disposable PWA project folder (no real keys). Run Doctor; check Dashboard B6–B9, Checks rows 3+, `logs/progress.txt`, `logs/checks.tsv`, `logs/last_doctor.json` and `logs/last_console.txt`.
4. Use Prepare Safety on the disposable project; verify `.gitignore` is created or amended and other files remain untouched.
5. Test paths with spaces and non-ASCII characters, a missing Python installation, and an intentionally invalid project folder.
6. Close and reopen the `.xlsm`; confirm manual statuses and evidence remain saved, and Check results refresh correctly.
7. Do not activate cloud build, signing or store submission until separately reviewed and authorized.
