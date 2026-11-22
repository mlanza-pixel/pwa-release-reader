# PWA Release Toolkit v2.5 RC3 — Start Here (Windows)

## What the files do

- `START_HERE_v2_5.bat`: Opens the local health check for **your own app project**. Drag your app project folder onto this file, or enter the path when asked.
- `python/pwa_console.py`: Reads the project, checks installed tools and safe setup, saves `logs/last_doctor.json`. Uses Python's standard library only. Does **not** build, sign, upload, or commit anything.
- `PWA_Release_Toolkit_v2.5.xlsx`: Dashboard showing exactly what needs doing; update the status cells yourself after each step.
- `bat_files/`: Legacy helper scripts; `deploy.bat` is **intentionally blocked** until signing/CI workflows have been tested on Windows and actual store accounts.

## Cookbook: first run

1. Extract the entire ZIP to a normal folder (for example, Documents\PWA Toolkit 2.5). Do not run it inside the ZIP.
2. Install Python 3, then close and reopen File Explorer and Command Prompt.
3. Find the separate folder containing your app's `package.json` (not the reader's directory).
4. Drag that project folder onto `START_HERE_v2_5.bat`; if drag-and-drop is awkward, double-click and enter the project path.
5. Read the PASS / WARN / FAIL lines. Open `logs/last_doctor.json` for the saved results.
6. To create a credential-safe `.gitignore`, run `python python/pwa_console.py prepare --project "C:\path\to\your-app"` from the toolkit folder. This adds patterns to an existing ignore file without deleting it.
7. Open `PWA_Release_Toolkit_v2.5.xlsx`, then work downward through the Dashboard sheet. Do not mark signing or publishing steps complete unless you verified their results.

## Important safety

Never put `.p8`, `.p12`, `.jks`, private keys, passwords, or base64 credential exports into Git. `.gitignore` does not remove credentials that were already committed. If credentials were pushed, revoke/rotate them before continuing. Base64 is encoding, not encryption.

## What is NOT automated

Store approvals, paid accounts, account verification, provisioning-profile choices, App Store/Play identifiers, signing, submission, and actual review. They require manual decisions and live testing. No Windows CMD execution is available in this development environment, so batch files are statically checked here but **not Windows-runtime-certified**.


## v2.5 RC3 chapter alignment

Open `CHAPTER_BY_CHAPTER_REVIEW_v2_5_RC3.md` and the **Chapter Progress** worksheet. Each chapter now records its own required action, evidence and trouble condition. Chapters 23–25 describe blocked or unverified automation, not supported one-click publishing.
