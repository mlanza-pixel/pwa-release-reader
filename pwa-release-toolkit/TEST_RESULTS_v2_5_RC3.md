# v2.5 RC3 — evidence-based test results

**Source:** uploaded RC2 ZIP, modified locally. **Status:** release candidate, not a certified app publisher.

- 38 numbered chapters, nine appendices, each with guided reading steps.
- HTML link checks: 41 anchor links inspected, 0 bad internal chapter targets.
- Image references: 72 HTML image occurrences inspected, 0 missing local image paths.
- Numbered references: 413 mentions inventoried (valid number is not proof of correct topical reference).
- Packaged tests: see `tests/test_pwa_console.py`; run from toolkit parent with `python -m pytest -q pwa-release-toolkit/tests`.
- Python compile and JS syntax checks will be run before ZIP release. Batch scripts are NOT Windows-runtime-tested.
- GitHub workflow templates intentionally disabled and require project-specific build/signing verification.
- Existing illustrations are instructional; not fresh authenticated browser screenshots.
- Sensitive operations and store uploads are not live-tested. No store credentials provided.

**Known residual risk:** Book's older main prose and some cross-references can still conflict with updated cookbook blocks. The `CHAPTER_REFERENCE_INVENTORY` intentionally marks semantic verification incomplete. Screenshots need real Windows/browser capture and accessibility review.

**Static issues found:** 0.
