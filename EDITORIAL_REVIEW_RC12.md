# RC12: Chapter-by-chapter friendly-language review

This revision uses the actual RC11 source as its basis. The primary reading path was rewritten to be plainspoken, calm, and step-by-step. Technical terms receive short explanations where relevant. The preexisting long-form text remains in `docs/archive/RC11_original_book.json` for comparison, **not** as current verified instructions.

**Scope qualification:** This is a major editorial rewrite of the primary reading path, not independent live verification of every historical technical statement, installation screen, or external store rule. Windows Excel/VBA and app-store publication still need real testing.

| Chapter | Topic | Before: visible text chars | After: text chars | Steps kept | Picture |
|---|---|---:|---:|---:|---|
| 1 | Chapter 1 — Concept Primer: What We Are Actually Building | 15289 | 2078 | 4 | Yes |
| 2 | Chapter 2 — Installing Node.js LTS (The Factory Engine) | 10174 | 2150 | 4 | Yes |
| 3 | Chapter 3 — Installing Git for Windows & OpenSSL (The Key Forger) | 11642 | 2190 | 4 | Yes |
| 4 | Chapter 4 — Installing Visual Studio Code (The Drafting Workbench) | 8955 | 1906 | 4 | Yes |
| 5 | Chapter 5 — The Verification Taste Test | 21229 | 2457 | 4 | Yes |
| 6 | Chapter 6 — Concept Primer: How Capacitor Wraps a PWA | 8346 | 2118 | 4 | Yes |
| 7 | Chapter 7 — Creating Your Project Folder & Installing Capacitor | 13402 | 2471 | 4 | Yes |
| 8 | Chapter 8 — Dropping Your PWA Files Into the dist Folder | 15544 | 2362 | 4 | Yes |
| 9 | Chapter 9 — The CORS Trap & capacitor.config.json Fix | 13886 | 2142 | 4 | Yes |
| 10 | Chapter 10 — Free iPhone Testing with Apple Personal Team (Before You Pay $99) | 10938 | 2125 | 4 | Yes |
| 11 | Chapter 11 — Creating Your Apple Developer Account ($99/year) | 11653 | 1993 | 4 | Yes |
| 12 | Chapter 12 — Creating Your Google Play Developer Account ($25 one-time) | 13293 | 1975 | 4 | Yes |
| 13 | Chapter 13 — Concept Primer: Why App Signing Exists | 8566 | 1977 | 4 | Yes |
| 14 | Chapter 14 — Forging Your 2048-bit RSA Private Key & CSR | 11254 | 2163 | 4 | Yes |
| 15 | Chapter 15 — Exchanging Your CSR for an Apple Distribution Certificate | 10437 | 1987 | 4 | Yes |
| 16 | Chapter 16 — Merging Into a Password-Protected .p12 Lockbox | 10833 | 2125 | 4 | Yes |
| 17 | Chapter 17 — Registering Your App ID & Downloading the Provisioning Profile | 11270 | 1919 | 4 | Yes |
| 18 | Chapter 18 — Creating the App Store Connect API Key (.p8) | 11924 | 1946 | 4 | Yes |
| 19 | Chapter 19 — Forging Your Android Keystore (.jks) for Google Play | 14095 | 2419 | 4 | Yes |
| 20 | Chapter 20 — Creating Your GitHub Account & Repository | 13459 | 2182 | 5 | Yes |
| 21 | Chapter 21 — Pushing Your Local Project to GitHub | 18262 | 3187 | 7 | Yes |
| 22 | Chapter 22 — Converting Binary Credentials to Base64 Text | 14124 | 2006 | 4 | Yes |
| 23 | Chapter 23 — The deploy.bat One-Click Desktop Engine | 12909 | 2142 | 4 | Yes |
| 24 | Chapter 24 — The Complete iOS Build Workflow YAML | 15174 | 2124 | 4 | Yes |
| 25 | Chapter 25 — The Complete Android Build Workflow YAML | 10881 | 2071 | 4 | Yes |
| 26 | Chapter 26 — Creating a Google Cloud Service Account for Play Uploads | 10749 | 1977 | 4 | Yes |
| 27 | Chapter 27 — Triggering and Watching Your First Cloud Build | 9518 | 2108 | 4 | Yes |
| 28 | Chapter 28 — Tier 1: Local Browser Emulation | 10507 | 1863 | 4 | Yes |
| 29 | Chapter 29 — Tier 2: Capacitor Bridge Audit | 7141 | 1960 | 4 | Yes |
| 30 | Chapter 30 — Tier 3: Android Studio Emulator on Windows | 9550 | 1935 | 4 | Yes |
| 31 | Chapter 31 — Tier 4: Apple TestFlight on a Real iPhone | 9159 | 1965 | 4 | Yes |
| 32 | Chapter 32 — Tier 5: Google Play Internal Testing | 7612 | 1846 | 4 | Yes |
| 33 | Chapter 33 — Capturing App Store Screenshots on Windows | 8618 | 1930 | 4 | Yes |
| 34 | Chapter 34 — The Privacy Policy Template | 10819 | 1973 | 4 | Yes |
| 35 | Chapter 35 — Apple App Store Connect Submission Protocol | 11279 | 1925 | 4 | Yes |
| 36 | Chapter 36 — Google Play Console Submission Protocol | 10249 | 1968 | 4 | Yes |
| 37 | Chapter 37 — After Approval: Updates, Pricing, and Maintenance | 8201 | 1895 | 4 | Yes |
| 38 | Chapter 38 — The 12-Tester Testing Requirement Demystified | 17097 | 2245 | 4 | Yes |
| 39 | Chapter 39 — Your Excel Control Panel: First Run | 3364 | 3104 | 8 | Yes |
| 40 | Chapter 40 — Fixing Missing Windows Tools Safely | 2681 | 3017 | 7 | Yes |
| 41 | Chapter 41 — Reading Doctor Results and Permanent Run Logs | 3087 | 2940 | 7 | Yes |
| 42 | Chapter 42 — From Working Website to Prepared Phone Project | 3391 | 3601 | 8 | Yes |

## Why the rewrite is easier to follow

- One chapter, one guided task; no second copy of the same steps hidden under a long reference section.
- Technical terms are explained beside the relevant actions.
- Each chapter includes a success check, a calm troubleshooting message and what to record in Excel.
- The distinction between an ordinary website and a configured Capacitor project is explicit.
- The PATH repair and Excel Run Log use the actual lessons from Windows testing.
- Existing pictures remain labeled as teaching illustrations, not current screenshots.

## Remaining release blockers

- Windows Excel macro builder/button execution needs a real Windows test.
- Apple/Google/GitHub interface and policy changes need live checks before publishing.
- The existing native build/sign/deploy scripts remain unverified and must not be presented as automatic store publishing.
- Illustrations need a later image-specific quality check against real software screens.
