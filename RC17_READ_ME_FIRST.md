# RC17 — Sentence-by-sentence editorial pass

This edition revises the RC16 source manuscript to reduce repeated paragraphs, repair awkward wording, add task-specific context, and make the remaining limitations explicit. No files in your original RC16 ZIP were modified.

## Start here

Open `index.html` from a local web server or a static host. The book text is in `content/book.json`. For offline experimentation, use the separate `pwa-release-toolkit/starter-pwa` tutorial rather than altering your existing app.

## Findings and records

- `RC17_SENTENCE_REVIEW_INVENTORY.csv` records 5,609 sentence-like units scanned from RC16, including flags for long, absolute/version, credential, and action language. **Machine-aided coverage is not independent verification of every claim.**
- `RC17_SENTENCE_CHANGES.csv` records the before/after editorial operations.
- `RC17_CHAPTER_BY_CHAPTER_REVIEW.csv` shows revised word counts and changes section by section.
- `RC17_EDITORIAL_REPORT.md` describes priorities, results, and limitations.

## Important difference between book and toolkit versions

The book edition is RC17. The Excel dashboard and its Windows BAT/VBS builder are inherited and may still create an RC13-named macro workbook. Chapters 39 and 41 explain this mismatch; **do not assume that updating the book tested or upgraded the Excel scripts**.

## Testing boundary

Python tests and JavaScript syntax checks run in the authoring environment. Actual Windows Excel VBA execution, native app signing, cloud builds, and store submission have not been verified in this edition.
