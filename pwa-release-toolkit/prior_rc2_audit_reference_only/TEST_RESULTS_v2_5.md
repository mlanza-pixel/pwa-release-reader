# PWA Release Toolkit v2.5 RC — Script and Asset Tests

Date: 2026-11-22

## Test scope

All five ORIGINAL batch files were read and examined. This release contains six current batch entry points, each inspected for basic CMD structure and encoding. No Windows CMD interpreter is available in the execution environment. Therefore, **none of the batch entrypoints was actually executed on Windows**. Signing, encoding and deployment commands remain intentionally blocked. The original signing scripts are in `legacy_v2_4_reference_only` as historic reference only.

Python automated test result: **15 passed in 0.08s**

| Area | Test | Result | Detail |
|---|---|---|---|
| content | chapter ID links resolve | PASS | [] |
| content | referenced images exist | PASS | [] |
| content | numbered chapters metadata matches | PASS | 38 |
| content | cookbook checkpoints inserted | PASS | 38 |
| content | reader version updated | PASS |  |
| content | search index consistent | PASS |  |
| javascript | js/app.js syntax | PASS |  |
| javascript | js/search.js syntax | PASS |  |
| javascript | sw.js syntax | PASS |  |
| batch | START_HERE_v2_5.bat encoding | PASS | ASCII CRLF, no BOM expected |
| batch | START_HERE_v2_5.bat basic structure | PASS | No CMD interpreter available |
| batch | bat_files/deploy.bat encoding | PASS | ASCII CRLF, no BOM expected |
| batch | bat_files/deploy.bat basic structure | PASS | No CMD interpreter available |
| batch | bat_files/doctor.bat encoding | PASS | ASCII CRLF, no BOM expected |
| batch | bat_files/doctor.bat basic structure | PASS | No CMD interpreter available |
| batch | bat_files/encode_base64.bat encoding | PASS | ASCII CRLF, no BOM expected |
| batch | bat_files/encode_base64.bat basic structure | PASS | No CMD interpreter available |
| batch | bat_files/generate_android_keystore.bat encoding | PASS | ASCII CRLF, no BOM expected |
| batch | bat_files/generate_android_keystore.bat basic structure | PASS | No CMD interpreter available |
| batch | bat_files/generate_apple_keys.bat encoding | PASS | ASCII CRLF, no BOM expected |
| batch | bat_files/generate_apple_keys.bat basic structure | PASS | No CMD interpreter available |
| batch | legacy_v2_4_reference_only/generate_android_keystore.bat encoding | PASS | ASCII CRLF, no BOM expected |
| batch | legacy_v2_4_reference_only/generate_android_keystore.bat basic structure | PASS | No CMD interpreter available |
| batch | legacy_v2_4_reference_only/generate_apple_keys.bat encoding | PASS | ASCII CRLF, no BOM expected |
| batch | legacy_v2_4_reference_only/generate_apple_keys.bat basic structure | PASS | No CMD interpreter available |
| python | python/pwa_console.py syntax | PASS |  |
| python | tests/test_pwa_console.py syntax | PASS |  |
| python | 15 automated scenarios | PASS | ...............                                                          [100%] 15 passed in 0.08s |
| JSON | content/book.json | PASS |  |
| JSON | manifest.json | PASS |  |
| JSON | pwa-release-toolkit/config_files/capacitor.config.json | PASS |  |
| JSON | pwa-release-toolkit/templates/manifest.json | PASS |  |
| YAML | pwa-release-toolkit/workflow_files/build-android.yml | PASS |  |
| YAML | pwa-release-toolkit/workflow_files/build-ios.yml | PASS |  |

## Windows acceptance test still required

1. Extract the package on Windows 10 or 11 into a folder with spaces in its name.
2. Run START_HERE_v2_5.bat with a temporary toy Capacitor project path. Confirm logs, nonzero failure exit, and no publish action.
3. Run doctor.bat wrapper. Check output and interactive prompt; verify deployment, Base64 and signing scripts explicitly refuse to perform risky actions.
4. Run Python tests on Windows: `python -m pytest -q pwa-release-toolkit/tests` (pytest must be installed for this test).
5. Test iOS and Android workflows separately with non-production credentials and actual supported runners, after fixing bundle identifiers and provisioning.

## Known limitations

- Source checks are not the same as functional browser, Windows, native build, or store approval tests.
- Cookbook checkpoints are a consistent five-step template, not a complete rewriting of every technical instruction or a chapter-specific screenshot for each screen.
- Old v2.4 spreadsheets and macro module are archived; the new dashboard is macro-free.
- The current GitHub Actions workflows are retained as examples and **not verified or authorized for production execution**.
- The PWA cache still requires separate offline-install stress testing.
