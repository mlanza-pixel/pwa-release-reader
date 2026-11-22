# PWA Release Toolkit v2.5 RC8 — Excel Layout Corrections

Open the `pwa-release-toolkit` folder, double-click `BUILD_MACRO_DASHBOARD.bat`, and open the newly generated `PWA_Release_Toolkit_v2.5_RC8.xlsm` file in desktop Microsoft Excel. The supplied `.xlsx` file is the template, **not** the macro-enabled control panel.

- A10: empty (removed confusing blue box)
- A11: `BUTTON`; B11: `ACTION / EXPECTED RESULT`
- Macro buttons: A12, A14, A16, A18, A20, A22, A24, A26, A28
- Descriptions: column B on the same row
- One blank row after each button; log reference starts on row 31
- The Manual Log field is renamed to **What you completed / evidence or notes**. Enter the task and what confirmed it, such as `Account created; confirmation email received`, or a screenshot filename. Never enter passwords, private keys, or tokens.
- Provider URLs in the workbook are clickable `HYPERLINK()` formulas. On the GitHub Upload sheet, enter your repository URL in B7, then use the link in F7.

**Do not reuse an older RC7 `.xlsm`**: its already-built shapes retain the previous layout. Rebuild a fresh RC8 `.xlsm` from the supplied template.

Validation: checked the exported workbook's row positions, nine button-to-VBA mappings, hyperlinks, blank spacer rows, and builder encoding. Rendering of shapes and execution of VBA in desktop Windows Excel still require an actual Windows test.


**RC9 Excel builder:** use `BUILD_MACRO_DASHBOARD.bat`; see `BUILDER_FIX_RC9_READ_ME.md`.
