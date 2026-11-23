# New in v2.5 RC11: Part VIII — The Windows Toolkit Cookbook

**Four additional chapters** extend the book from 38 to 42 numbered chapters, with nine appendices unchanged. They are placed together in Part VIII rather than renumbering 38 earlier chapters, which would break references.

- Chapter 39: Excel dashboard, buttons, and manual approvals.
- Chapter 40: PATH repair for OpenSSL, Java, and keytool, including the corrected repair BAT.
- Chapter 41: PASS/WARN/FAIL, history, and exact log filenames.
- Chapter 42: Selecting a normal PWA, package.json, Capacitor configuration, and staging webDir safely.

Read these before your first Windows toolkit session. Earlier chapters 1, 3, 5, 7, 8, 19, 20, 21, and 23 link directly to the relevant lessons. The path-repair batch file was added to this package. It has been statically checked here but not executed in Windows for RC11. Windows Excel/VBA and native publishing remain unverified. Never enter secrets in Excel.

## Starting with Excel

Extract the complete ZIP, then open `pwa-release-toolkit` and run `BUILD_MACRO_DASHBOARD.bat`. Look for `PWA_Release_Toolkit_v2.5_RC11.xlsm`. If it fails, inspect `logs/BUILD_MACRO_DASHBOARD_RC11.log`. Do not reuse older macro workbooks. The `.xlsx` provides a manual alternative.

## What is NOT included

A tested one-click Prepare My App or app-store publishing workflow is not included. Chapter 42 explains the safe preparation requirements; do not mistake instructions for an already implemented button.
