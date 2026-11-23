# Excel Dashboard Layout — v2.5 RC8

## Dashboard
- Row 10: blank spacing (removed the intrusive blue box).
- Row 11: A11 `BUTTON`; B11 `ACTION / EXPECTED RESULT`.
- Buttons: A12, A14, A16, A18, A20, A22, A24, A26, A28.
- Matching descriptions: column B on the same row.
- Rows 13, 15, 17, 19, 21, 23, 25, 27, 29 are blank spacing rows.
- Log locations start at row 31.

## Manual Log
The old `What you did / screen` heading meant "record the action you completed and the evidence you saw." It is now `What you completed / evidence or notes`. Examples: `Account created`, `Confirmation email received`, `Screenshot saved as github-upload.png`. Do not record passwords, private keys, certificates, tokens or sensitive account IDs.

## Clickable links
Static provider URLs in the Excel workbook are stored as HYPERLINK formulas, including the Links and Manual Log sheets. Enter your repository URL on GitHub Upload!B7; use the `Open your repository` link in F7.

## Testing limits
The workbook structure and VBA button-to-procedure names were checked programmatically. Runtime execution of the VBScript builder, Excel shapes, macro clicks and text rendering must still be tested on Windows Excel.
