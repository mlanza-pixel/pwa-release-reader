# PWA Release Reader v2.5 RC2 — Reference and script QA

## Results

| Test | Result | Details |
|---|---|---|
| Book JSON parses | PASS | 58 sections |
| All internal chapter links | PASS | 65 refs |
| All referenced illustrations exist | PASS | 34 refs |
| Numbered chapter list | PASS | 38 |
| Specific chapter cookbook exactly once | PASS |  |
| No generic cookbook duplication | PASS |  |
| All chapter cross reference numbers exist | PASS | Total mentions 360 |
| JSON content/book.json | PASS |  |
| JSON manifest.json | PASS |  |
| JSON pwa-release-toolkit/config_files/capacitor.config.json | PASS |  |
| JSON pwa-release-toolkit/templates/manifest.json | PASS |  |
| JS syntax app.js | PASS |  |
| JS syntax search.js | PASS |  |
| JS syntax sw.js | PASS |  |
| PY syntax python/pwa_console.py | PASS |  |
| PY syntax tests/test_pwa_console.py | PASS |  |
| Python unit tests | PASS | ...............                                                          [100%] 15 passed in 0.10s  |
| BAT encoding START_HERE_v2_5.bat | PASS | no BOM/NULL, header present |
| BAT encoding bat_files/deploy.bat | PASS | no BOM/NULL, header present |
| BAT encoding bat_files/doctor.bat | PASS | no BOM/NULL, header present |
| BAT encoding bat_files/encode_base64.bat | PASS | no BOM/NULL, header present |
| BAT encoding bat_files/generate_android_keystore.bat | PASS | no BOM/NULL, header present |
| BAT encoding bat_files/generate_apple_keys.bat | PASS | no BOM/NULL, header present |
| BAT encoding legacy_v2_4_reference_only/generate_android_keystore.bat | PASS | no BOM/NULL, header present |
| BAT encoding legacy_v2_4_reference_only/generate_apple_keys.bat | PASS | no BOM/NULL, header present |
| YAML syntax build-android.yml | PASS |  |
| YAML syntax build-ios.yml | PASS |  |
| Windows CMD runtime (all BAT files) | NOT TESTED | Requires actual Windows CMD VM; static checks alone cannot certify execution |
| Native iOS/Android build | NOT TESTED | Credentials, devices, platform-specific runners unavailable |
| External websites and screenshots | PARTIAL | Primary official references checked via web, not every external link or UI screenshot |

## Reference verification

- Numbered chapters in canonical book: **38**.
- Chapter mentions indexed across reader and toolkit: **360**.
- Book internal navigation: **65 links inspected, 0 unresolved**.
- Corrected text-node references during this pass: **56**.
- Every numbered mention was validated for existence, but **semantic correctness of every mention is not certified**. Review the CSV `CHAPTER_REFERENCE_INVENTORY_v2_5_RC2.csv`.
- All reference corrections listed in `REFERENCE_CORRECTIONS_v2_5.md` are grounded in the actual canonical chapter titles, not old PDF page numbers.

## Outside claims corrected

- Free Apple Personal Team device signing requires Mac/Xcode, not a Windows-only shortcut.
- Google: 12 opted-in testers continuously for 14 days on affected new personal Play accounts.
- Changing `iosScheme` alone does not fix arbitrary CORS problems.
- GitHub Actions free macOS time depends on repository visibility, plan, and billing rules.
- Native assets can be generated with the official @capacitor/assets tool; verify generated output.

## Release-blocking gaps

- Windows CMD batch execution has not been performed. All signing, encoding and deployment scripts remain intentionally blocked.
- Neither iOS nor Android production signing, native builds, app distribution nor store submissions were performed.
- Not every UI screenshot is available in the book: do not mistake schematic mockups for current portal screenshots.
- The chapter-reference inventory includes valid numbers that still require contextual editorial verification.
