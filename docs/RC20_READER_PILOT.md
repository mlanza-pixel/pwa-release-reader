# PWA Release Reader — real-world pilot (RC20)

This is the actual practice website for the book. It is a static HTML/CSS/JavaScript PWA, not yet a certified native App Store or Play Store application.

## What is in the source

- `index.html`: entry page and manifest link.
- `manifest.json`: install metadata and icons.
- `sw.js`: service-worker caching logic.
- `content/book.json`: chapters and text, fetched by the app.
- `js/app.js` and `js/search.js`: navigation and search.
- `css/styles.css`, `images/`, `icons/`: style and media.

## Beginner-safe test recipe

1. Extract the ZIP; preserve the original. Make a second practice copy.
2. In File Explorer open the folder containing `index.html`, click the address bar, type `cmd`, press Enter.
3. Type `python -m http.server 8000`, then visit `http://localhost:8000/` in Chrome or Edge.
4. Test home, two chapters, search, TOC links, illustrations, and a narrow phone-sized window.
5. Inspect the manifest and service worker using browser developer tools.
6. Load and visit several chapters online; then go offline, reload a visited chapter, and open a never-visited chapter. Note both separately.
7. Stop the server with Ctrl+C. Keep evidence with browser version, date, device, screenshot, and pass/fail.

## Important source finding

The service worker precaches the shell, but chapter JSON is fetched and stored during browsing, not in the initial installation shell asset list. Do not mark a brand-new installation as fully offline without an actual controlled offline test. Browser installation and native-device checks are not established merely by inspecting files.

## Apple/Google release gate

- Apple App Review 4.2 minimum functionality: risk for a simple book or website wrapper. Add meaningful interactive value and verify on iPhone/iPad before submission.
- Google Play: store screenshots must reflect the actual app, not teaching mockups. Check current targets, resizable layouts, and testing rules.
- For both: test navigation, back behavior, offline, privacy/data handling, icons, touch targets, text scaling, orientation, and real device screenshots.
- This package does not generate or certify signed `.ipa` / `.aab` output.

Official sources (checked November 23, 2026):
https://developer.apple.com/app-store/review/guidelines/
https://developer.apple.com/design/human-interface-guidelines/
https://support.google.com/googleplay/android-developer/answer/9866151
https://developer.android.com/blog/posts/google-play-adaptive-quality-standards
https://capacitorjs.com/docs/getting-started
