# RC18 correction and test report

- Original source: RC17
- Active sentence-like units inventoried: 4012
- Direct and pattern replacement records: 15
- Total matched replacements: 15
- Status counts: {'NO_FACT_CHECK_PERFORMED': 3717, 'SOURCE_REVIEW_REQUIRED': 77, 'SOURCE_CANDIDATE_NOT_CERTIFIED': 218}
- Chapters (not counting dividers): 58

This release corrects selected source-backed, high-risk claims in legacy appendices. It is not a complete manual verification of every sentence. The Windows Excel builder and native release automation remain unverified.

## Structural tests
- Broken chapter references: 0
- Missing image paths: 0
- JS syntax: [('app.js', 0, ''), ('search.js', 0, ''), ('sw.js', 0, '')]
- Existing Python test files found: 3

## Regression run after targeted patches
- Python unit tests: 27 passed (including the updated edition check).
- Additional correction patterns matched: 8; occurrences: 14.
- Old published deployment instructions now include clearer blocked-script warnings; still require future manual script audit.

- Final active sentence-like inventory: 4022; status totals {'NO_FACT_CHECK_PERFORMED': 3566, 'SOURCE_CANDIDATE_NOT_CERTIFIED': 366, 'SOURCE_REVIEW_REQUIRED': 90}.
