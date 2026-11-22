# START HERE — v2.5 RC3 (Windows cookbook)

## What this package really does

The reader explains how a PWA can become native app packages. The **Excel dashboard is a checklist**, not a magic native compiler. The **Python doctor checks your project and prepares a safer `.gitignore`**. Apple signing, Android signing, TestFlight, Play Console and publication require accounts, credentials and external runners, and still need real testing.

## Recipe 1: Unzip and find your own app

1. Right-click the ZIP in File Explorer and choose **Extract All**.
2. Open the extracted folder. Do not run scripts while they are still inside the ZIP viewer.
3. Open `pwa-release-toolkit/PWA_Release_Toolkit_v2.5.xlsx` and leave it visible as your progress list.
4. Open the folder for **your app**, the one containing `package.json`. The book itself is not the app you are publishing.
5. In File Explorer, click the address bar and copy that project-folder path.

**Check:** The folder you copied contains `package.json` and the expected built web assets. If it doesn't, stop here.

## Recipe 2: Run a check — no publishing

1. Open `pwa-release-toolkit` in File Explorer.
2. Drag your **app folder** onto `START_HERE_v2_5.bat`; or double-click and paste the path when prompted.
3. Read the result: **PASS** means one check succeeded, **WARN** means review, **FAIL** means you cannot continue with that step.
4. Look in `pwa-release-toolkit/logs/last_doctor.json`. It reports checks and does not transmit secrets.
5. Copy any failure message into the Excel dashboard; do not copy passwords or private keys.

**Check:** You have a timestamped report and know which required tools are missing.

## Recipe 3: Protect files before uploading anywhere

1. Use Command Prompt in the `pwa-release-toolkit` folder.
2. Run `python python\pwa_console.py prepare --project "C:\YOUR\APP\FOLDER"` with YOUR path substituted.
3. Open your app folder and confirm `.gitignore` contains `*.p8`, `*.p12`, `*.jks`, `*.key`, `*.mobileprovision`.
4. **Important:** `.gitignore` does not untrack files already committed. Inspect `git status` and `git ls-files` for any secrets already tracked; remediate those with a knowledgeable helper before pushing.

**Check:** No secret file is staged or appears in Git history.

## Recipe 4: Native setup and publishing — gated

1. Read Chapters 7–9 for the Capacitor wrapper.
2. Use **Chapter 20** for GitHub setup and **Chapter 22** for repository secrets; do not mix up the chapter numbers.
3. Read Chapters 24 and 25 to customize iOS and Android workflows. The examples are **not production-tested**.
4. Test on genuine devices and use the official store portals to verify each submission status.
5. Do not run the deliberately blocked legacy signing/deploy batch files as though they were finished tools.

**Check:** Actual builds are verified by GitHub Actions and device tests—not merely by a green Excel cell.

## Why buttons are blocked

The historical scripts do not yet have verified Windows CMD execution, isolated dummy-key tests, or real signing credentials. The block prevents publishing credentials accidentally. This release is an RC, not certified store-publishing software.

## Common problems

| What you see | What it means | What to do |
|---|---|---|
| `python is not recognized` | Python not on PATH | Install Python and reopen Command Prompt |
| `package.json missing` | Wrong folder, or no JS project | Browse to your actual app project |
| `dist/index.html missing` | App has not been built | Follow the app's documented web build step |
| `App ID invalid` | Placeholder or malformed package ID | Set a unique real reverse-DNS identifier |
| `Secrets present` | A signing file exists in the project | Verify ignore and git tracking before any upload |
| `[BLOCKED]` in BAT | Safety gate is working | Do not circumvent it; complete Windows tests |

## Official links reviewed on November 22, 2026

- Apple free development: https://developer.apple.com/help/account/basics/about-your-developer-account/
- Google testing: https://support.google.com/googleplay/android-developer/answer/14151465
- Capacitor CORS: https://ionicframework.com/docs/troubleshooting/cors
- Capacitor icon generation: https://github.com/ionic-team/capacitor-assets
- GitHub Actions billing: https://docs.github.com/en/actions/concepts/billing-and-usage
