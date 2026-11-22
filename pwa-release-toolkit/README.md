# PWA Release Toolkit v2.3

> **Companion file set for "PWA Release for Dummies — Windows Edition v2.3"**

## Files Included

### 📊 PWA_Release_Toolkit_v2.3.xlsx (Main File — Open This First)

This is your master reference spreadsheet. It has 3 sheets:

| Sheet | What It Contains |
|---|---|
| **Command Guide** | 31 rows — one per action across all chapters. Click any 📂 link in the "Template File" column to OPEN that file directly. Type "X" in the Done column as you complete each step. |
| **File Index** | All 14 template files. Click any file name to open it. |
| **GitHub Secrets** | All 11 GitHub Secrets with exact names, source files, and how to get each value. |

**How to use the clickable links:** Click any cell that shows "📂 filename" — Excel will open that file in its default application (Notepad for .bat/.txt/.yml, your browser for .json/.md, etc.).

### 📝 PWA_Toolkit_Macros.bas (Optional — For Excel Power Users)

If you want **clickable buttons** in Excel that RUN .bat scripts and OPEN files with one click (instead of just hyperlinks), you can add VBA macros to the .xlsx:

1. Open `PWA_Release_Toolkit_v2.3.xlsx` in Excel
2. Press `Alt+F11` to open the VBA editor
3. Click `File > Import File...`
4. Select `PWA_Toolkit_Macros.bas` (in this same folder)
5. Close the VBA editor
6. Save the file as `PWA_Release_Toolkit_v2.3.xlsm` (File > Save As > Excel Macro-Enabled Workbook)
7. Now you have buttons! The macros let you run scripts directly from Excel.

### 📁 bat_files/ — Double-Click Scripts

| File | What It Does | Chapter |
|---|---|---|
| `doctor.bat` | Diagnostic health check — checks Node, npm, Git, OpenSSL, VS Code. Saves results to `doctor_results.txt` and opens it in Notepad. | Ch 5 |
| `deploy.bat` | One-click deploy — syncs Capacitor, commits, pushes to GitHub. Checks push success. | Ch 22 |
| `generate_apple_keys.bat` | Generates RSA private key, CSR, converts .cer→.pem, bundles into .p12. | Ch 13-15 |
| `generate_android_keystore.bat` | Generates Java keystore (.jks) for Android signing. | Ch 18 |
| `encode_base64.bat` | Encodes all credential files to base64 text for GitHub Secrets. | Ch 21 |

### 📁 config_files/ — Configuration Templates

| File | What It Is | Chapter |
|---|---|---|
| `capacitor.config.json` | Capacitor config with CORS fix (iosScheme: ionic). Replace appId and appName. | Ch 9 |
| `.gitignore` | Prevents signing keys from being committed. **Critical for security.** | Ch 20 |

### 📁 workflow_files/ — GitHub Actions YAML

| File | What It Does | Chapter |
|---|---|---|
| `build-ios.yml` | iOS build workflow with CocoaPods caching. | Ch 23 |
| `build-android.yml` | Android build workflow with Gradle caching. | Ch 24 |

### 📁 templates/ — PWA Templates

| File | What It Is | Chapter |
|---|---|---|
| `PRIVACY.md` | Privacy policy template for GitHub Pages. | Ch 33 |
| `manifest.json` | PWA manifest template. | Ch 8 |
| `sw.js` | Service worker template for offline caching. | Ch 8 |

### 📁 text_files/ — Printable Checklists

| File | What It Is | Chapter |
|---|---|---|
| `github_secrets_checklist.txt` | All 11 GitHub Secrets — tick off each as you add it. | Ch 21 |
| `preflight_checklist.txt` | Pre-submission verification with page numbers. | Appx E |

## Quick Start

1. **Unzip everything to:** `C:\my_apps\pwa_release\`
2. **Open:** `PWA_Release_Toolkit_v2.3.xlsx` in Excel
3. **Follow the "Command Guide" sheet** row by row:
   - Read the "What You Do" column for plain-English instructions
   - Click 📂 links in the "Template File" column to open files
   - Copy template files into your project as needed
   - Type "X" in the "Done?" column when each step is complete
4. **Double-click .bat files** in the `bat_files/` folder to run scripts

## Directory Structure

```
C:\my_apps\pwa_release\
├── PWA_Release_Toolkit_v2.3.xlsx    ← Open this first!
├── PWA_Toolkit_Macros.bas           ← Optional: for Excel buttons
├── README.md                         ← This file
├── bat_files\
│   ├── doctor.bat                    ← Double-click to diagnose
│   ├── deploy.bat                    ← Double-click to deploy
│   ├── generate_apple_keys.bat
│   ├── generate_android_keystore.bat
│   └── encode_base64.bat
├── config_files\
│   ├── capacitor.config.json
│   └── .gitignore
├── workflow_files\
│   ├── build-ios.yml
│   └── build-android.yml
├── templates\
│   ├── PRIVACY.md
│   ├── manifest.json
│   └── sw.js
└── text_files\
    ├── github_secrets_checklist.txt
    └── preflight_checklist.txt
```

## Important Notes

1. **The .xlsx links are relative** — they work when the .xlsx is in the root directory and the subfolders are alongside it. Don't move the .xlsx without the subfolders.

2. **Copy files into your project as needed** — Don't run scripts from the toolkit folders directly. Copy `deploy.bat`, `doctor.bat`, `.gitignore`, `capacitor.config.json`, and the workflow YAMLs into your actual project folder.

3. **Replace placeholders** — Always replace `com.example.myapp` with your Bundle ID, `My PWA App` with your app name, `YOUR_USERNAME` with your GitHub username, and `[your email]` with your real email.

4. **Security** — The `.gitignore` template is critical. It prevents your private keys from being committed to GitHub. Never remove the `*.key`, `*.p12`, `*.p8`, `*.jks` entries.

5. **Base64 is NOT encryption** — Delete all `*_base64.txt` files immediately after pasting into GitHub Secrets.

---

*Generated by Z.ai — Companion to "PWA Release for Dummies — Windows Edition v2.3"*

### 📁 google_templates/ — Spreadsheet Templates

| File | What It Is | Chapter |
|---|---|---|
| `Tester_and_Submission_Tracker.xlsx` | 3-sheet workbook: (1) Tester Tracker — track your 12 Google testers with opt-in dates and Day 14 targets, (2) Community Directory — clickable links to all testing communities from Appendix I, (3) Submission Tracker — track both Apple and Google submission steps side-by-side | Ch 37, Appx I |

## Do You Need a Similar Community Directory for Apple?

**No — Apple does NOT have a minimum tester requirement.** You can submit to the App Store with zero beta testers. However, we recommend testing with 2-3 people via TestFlight for 1-2 days to catch obvious bugs.

Apple testing communities are included in **Appendix I** alongside the Google communities, with TestFlight-specific resources like r/betaTesters and r/iOSProgramming. The Tester_and_Submission_Tracker.xlsx also includes an Apple column in the Submission Tracker sheet so you can track both stores side-by-side.

The key difference:
- **Google:** 12 testers for 14 days = REQUIRED before production (personal accounts after Nov 2023)
- **Apple:** 0 testers required, but 2-3 recommended for catching bugs before review
