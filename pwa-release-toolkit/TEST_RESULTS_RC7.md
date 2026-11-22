# v2.5 RC7 — Test Report (2026-11-22)

- Python unit tests (existing and new): **20 passed**, **0 failed** (`pytest`)
- Reader structural tests: **6 passed**, **0 failed** (`unittest`)
- JavaScript source syntax: `node --check` **passed** for `js/app.js` and `js/search.js`
- Workbook import: GitHub Upload sheet imported successfully; statuses and fields verified
- Python GitHub-readiness smoke check: tested against the extracted reader, produced JSON/TSV/progress. It found the root `index.html` and did not require `dist/` for this check. No files uploaded.
- GitHub first-upload cookbook added to Chapters 20/21; direct official links included
- VBA code and VBS builder wiring statically verified; **Windows Excel/VBA runtime NOT TESTED**
- GitHub browser upload and account interaction **NOT TESTED**; no account or repo was changed
- Existing native building, signing, publishing and `deploy.bat` still **NOT VERIFIED**
- Security scan is filename / ignore-pattern heuristic: it does not guarantee that a project contains no secrets. Review all files yourself.

Release status: **RC7 — Windows integration pending; not a certified publishing system**.
