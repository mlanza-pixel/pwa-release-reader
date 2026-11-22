# RC9 — Excel dashboard creation fix

## What failed
The old builder failed at `Excel.Workbooks.Open` without explaining whether the file was blocked, Excel was busy, or Excel could not read the template. The RC8 launcher also incorrectly displayed RC7.

## New eight-step process
1. Verify extraction and required files.
2. Verify source workbook.
3. Start Excel Desktop.
4. Attempt to open template; if Excel refuses, reconstruct workbook data from `DASHBOARD_FALLBACK_RC9.tsv`. This is a **recovery mode**, and appearance/validation/hyperlink behavior may differ from the original template.
5. Import VBA module (Excel must permit trusted access to the VBA project object model).
6. Add nine buttons beginning in A12, with explanations in B and blank rows between controls.
7. Save `.xlsm` without overwriting an existing one.
8. Log success or the exact failed step.

The builder log is `pwa-release-toolkit/logs/BUILD_MACRO_DASHBOARD_RC9.log`. If you see a VBA access error, use Excel > File > Options > Trust Center > Trust Center Settings > Macro Settings > Trust access to the VBA project object model; enable temporarily and turn it off after building. Only enable macros from trusted sources. If Excel cannot start, close any hanging EXCEL.EXE instances after saving other work.

The first attempt may fail when files are blocked because they were downloaded: right-click the ZIP > Properties > Unblock (if shown), then re-extract. The fallback is designed for cases where Excel rejects the supplied `.xlsx`.

**Windows CMD / Excel COM execution is not verified in this environment.** Confirm button behavior and output workbook content on Windows before labeling this release COMPLETE.
