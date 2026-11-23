# Your first PWA — friendly practice project

This is a **separate example**, not a replacement for your real website. It has a home page, a manifest, two valid PNG icons, and a small optional offline helper. It does not contain passwords, signing keys, Capacitor, or app-store submissions.

## How to test it on Windows

1. Make sure Python is available. Open File Explorer and find this `starter-pwa` folder.
2. Click File Explorer's address bar, type `cmd`, and press Enter.
3. Type `python -m http.server 8000` and press Enter. Keep that window open.
4. In Chrome or Edge open `http://localhost:8000/`.
5. Click the button and check that it works.
6. Press F12; find **Application > Manifest** and **Service Workers** (browser menus may vary).
7. Once it has loaded online, try the browser's offline simulation and refresh. The home page should show again. Some browser extensions or cache settings can affect tests; try a fresh profile if needed.
8. Return to the Command Prompt and press Ctrl+C to stop the server.

## What each file does

- `index.html`: Your page, including the manifest link and service worker registration.
- `manifest.webmanifest`: How your site looks as an installed app.
- `sw.js`: A small, same-origin cache that enables offline fallback for this example page.
- `icons/`: Two basic example app icons; replace with your own artwork when adapting.

## Adapting to a real site

Back up your original first. If it already has `sw.js` or a manifest, **do not overwrite it**. Adapt the paths and the icon names to match your own file structure; ask for a code review if you are unsure. Never cache sensitive user data or APIs without a deliberate privacy and update strategy. A service worker is not required for installability in every browser. Always test over HTTPS or localhost, not by double-clicking `index.html` as a file.

## Beginner prompt you can copy

> I have an existing website with index.html. Please tell me which files you need to inspect before adding a web manifest and optional offline service worker. Preserve my layout, make a backup first, and do not overwrite existing PWA files. Give me step-by-step Windows testing instructions for localhost and HTTPS and identify any files that should not be uploaded to GitHub.

Further reading: https://developer.mozilla.org/en-US/docs/Web/Progressive_web_apps/Guides/Making_PWAs_installable
