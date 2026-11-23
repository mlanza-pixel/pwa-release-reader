# RC20 Test Record — November 23, 2026

## Automated checks performed

- **27 / 27 Python toolkit regression tests passed** (`python -m pytest -q tests`).
- **Reader source checker passed:** all 67 reader entries, chapter links, icon paths, and referenced image files checked; no missing local files or broken internal chapter links identified.
- **JavaScript syntax:** `node --check js/app.js` and `node --check sw.js` both passed.
- **42 numbered chapters preserved**, nine appendices inherited.
- **Two new explanatory illustrations** included and explicitly identified as illustrative, not live screenshots.

## Runtime tests not completed

- Local HTTP smoke-test attempted against `127.0.0.1:8765`. The sandbox refused the connection (`Errno 111`), so no HTTP status or real browser navigation was verified.
- Playwright Python installed, but Chromium executable is absent; launch failed. Therefore no live Chromium interaction, installability, mobile viewport, or service-worker offline check was completed.
- Windows Excel macro/VBScript/batch execution **not tested**. RC13 internal Excel builder names are inherited deliberately.
- No signed native iOS/Android artifact was built. Store publication and real screenshot compliance remain untested.

## Editorial boundaries

The eight-picture introduction is now a compact responsive clickable grid, not eight full-width images. The general lesson always comes before the app-specific case study. Eight important numbered chapters received focused Reader pilot examples; the other chapters retain inherited illustrations and text. This is **not** a claim of 100–130 new chapter screenshots or full app-store certification.
