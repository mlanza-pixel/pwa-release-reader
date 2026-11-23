# RC11 — Permanent Run Log and Dashboard Summary

## What the uploaded logs proved
- The RC9 Excel builder initially failed to open the XLSX but recovered from packaged fallback data, imported VBA, placed buttons, and saved the XLSM successfully.
- Doctor ran before Prepare Safety. Prepare Safety overwrote the *latest* console and checks TSV, hiding the earlier Doctor output.
- The Doctor JSON independently retained **9 PASS, 0 WARN, 5 FAIL**, including 8 passing tool checks. Five project-structure checks failed for the selected toolkit folder, which is not an initialized native project.
- Prepare Safety passed and created a protective `.gitignore` in the user-selected folder. **Review that selected folder before using it as an app project.**

## New behavior
Every invocation of `pwa_console.py` with `--history-dir logs` archives its individual logs to `logs/runs/<timestamp>_<mode>/`, and appends one row to `logs/run_history.tsv` with PASS/WARN/FAIL and exit status. No previous archived run is overwritten. `last_console.txt`, `last_doctor.json`, and `checks.tsv` remain convenience files for the most recent run only.

The Excel Dashboard shows latest PASS/WARN/FAIL counts in C6, D6, E6. Click **10. View Run Log** to see run history in A:I, and the latest Python, startup, Excel-launch and builder logs in column K. **Refresh Results** updates the summary and Log tab. The Run Log tab does not replace your manually entered notes.

## Windows verification still required
- Build RC11 workbook under Excel Desktop with `BUILD_MACRO_DASHBOARD.bat`, and click Run Doctor, Prepare Safety, Refresh Results, and View Run Log.
- Verify the new tenth button fits at A30 and no text or shapes overlap.
- Verify history appears after two sequential runs and that archived first-run output survives the second.
- Source XLSX may still require the existing recovery fallback on Windows; rebuilding on Windows is not certified here.
