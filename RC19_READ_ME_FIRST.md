# RC19 — Opening Lessons Rewrite and Visual Roadmap

Baseline: RC18 checkpoint, November 23, 2026. This release changes the **reader manuscript**, opening page, search data, and reader version labels. It does **not** certify the inherited RC13-era Excel builder or Windows publishing scripts.

## Major edits

- Replaced the vague Start Here 2 title with **Turn Your Working Website into a PWA**; its subtitle is **Add a Manifest and an Offline Helper** (not a repeated title).
- Added three distinct introductory paragraphs using a cake/bakery analogy to Start Here 1, Start Here 2, Start Here 3, and Chapter 1.
- Rebuilt the eight-picture introduction to explicitly connect pictures 1–4 to the first two lessons, pictures 5–6 to testing/GitHub, and pictures 7–8 to optional phone and store processes.
- Rewrote Start Here 2 with precise filename, Windows Notepad, manifest, icon, HTML and optional service-worker instructions.
- Rewrote Start Here 3 as an end-to-end Windows recipe: local server, browser inspection, offline test, secure GitHub account/repository, browser upload, verification, optional Pages publishing, and Excel notes.
- Replaced incorrect historic introductory claims that a cloud Mac was automatically free and no Mac-related limitations existed.
- Rebuilt the book search index and internal TOC labels while preserving stable chapter IDs so prior links continue working.

## Technical source checks (November 23, 2026)

- https://web.dev/learn/pwa/getting-started
- https://developer.mozilla.org/en-US/docs/Web/Progressive_web_apps/Guides/Making_PWAs_installable
- https://developer.chrome.com/blog/devtools-tips-18
- https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site

## Intentional boundaries

The example manifest and service-worker registration code are teaching samples for a small static site. Existing frameworks and workers must be checked before changing them. No files are automatically uploaded to GitHub. The full browser workflow, Excel VBA macros, native builds and actual store submission have not been executed in this release.
