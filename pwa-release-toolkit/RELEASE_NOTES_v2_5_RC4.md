# RC4 — Macro Excel Dashboard + Live Python Diagnostics

- New Windows `BUILD_MACRO_DASHBOARD.bat` + `BUILD_MACRO_DASHBOARD.vbs` generate a true macro-enabled Excel `.xlsm` using locally installed Microsoft Excel.
- VBA source: `vba/PWA_Dashboard_v2_5_RC4.bas` with **Choose Project**, **Run Doctor**, **Prepare Safety**, **Refresh Results**, **Open Instructions**.
- Rebuilt `PWA_Release_Toolkit_v2.5.xlsx` with Dashboard, Checks, Steps, Manual Log, Links, Chapter Progress (38 chapters and 9 appendices), and Help.
- Python console `2.5.0-RC4` now reports each check; JSON/TSV/progress/log files can be used independent of Excel. New --progress, --status-tsv, --console-log command-line options.
- `START_HERE_v2_5.bat` now shows progress in its own window and writes result logs.
- Existing signing, credential-processing, deployment scripts and native workflows stay blocked intentionally.
- `content/book.json`, reader HTML, service worker and manifest version strings bumped to RC4.

**Release status:** RC / Development. Windows COM/VBA execution and native store delivery have not been tested. Read `TEST_RESULTS_v2_5_RC4.md`.
