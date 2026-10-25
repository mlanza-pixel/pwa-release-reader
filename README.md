# PWA Release for Dummies — Interactive Reader PWA

A highly visual, professional, installable Progressive Web App version of the **PWA Release for Dummies (Windows Edition v2.0)** book — a 271-page novice guide that takes a complete beginner from raw PWA web files all the way to published apps on both Apple App Store and Google Play, without ever needing a Mac.

## Features

- **📖 Full book content** — 28 chapters across 7 parts + 8 appendices, all rendered as responsive HTML
- **🔍 Full-text search** — every chapter indexed, with snippet extraction and term highlighting. Press `/` anywhere to focus search
- **🧭 Sidebar TOC** — collapsible table of contents grouped by Part, with active-chapter highlighting
- **🎨 25 visual diagrams** — 10 professional flow diagrams + 15 annotated UI mockups
- **🌙 Dark mode** — automatic (follows system) with manual override, persisted to localStorage
- **📊 Reading progress bar** — see how far through each chapter you are
- **⌨️ Keyboard shortcuts** — `/` search, `←/→` prev/next chapter, `t` theme, `m` menu, `?` help, `g h` go home
- **📱 Installable** — add to home screen on iOS/Android, install as desktop app on Chrome/Edge
- **🔄 Offline support** — service worker caches the entire book for offline reading
- **🖨️ Print-friendly** — clean print stylesheet, save any chapter as PDF
- **♿ Accessible** — semantic HTML, ARIA labels, keyboard navigable

## Quick Start

### Option A: Run locally (recommended for first try)

You need a static file server (opening `index.html` directly in browser will fail due to CORS restrictions on fetching `book.json`).

```bash
# Python 3 (built-in)
cd pwa-release-reader
python3 -m http.server 8080

# OR Node.js
npx serve .

# OR PHP
php -S localhost:8080
```

Then open `http://localhost:8080` in your browser.

### Option B: Deploy to GitHub Pages (free hosting)

1. Create a new GitHub repository (e.g., `pwa-release-reader`)
2. Upload all files in this folder to the repo (drag-drop works for <100 files; use `git push` for more)
3. In your repo: **Settings → Pages → Source → main branch → / (root)** → Save
4. Wait 1–2 minutes. Your PWA is live at `https://yourusername.github.io/pwa-release-reader/`

### Option C: Deploy to Netlify / Vercel / Cloudflare Pages

1. Drag-drop this folder onto [app.netlify.com/drop](https://app.netlify.com/drop) for instant hosting
2. Or connect your GitHub repo to Netlify/Vercel/Cloudflare Pages for auto-deploy on every push

## Project Structure

```
pwa-release-reader/
├── index.html              ← Main reader UI (sidebar + search + content)
├── manifest.json           ← PWA manifest (installable)
├── sw.js                   ← Service worker (offline caching)
├── README.md               ← This file
├── css/
│   └── styles.css          ← Professional DK Eyewitness theme (light + dark)
├── js/
│   ├── app.js              ← Main app logic (routing, theme, search wiring)
│   └── search.js           ← Client-side full-text search engine
├── content/
│   └── book.json           ← All 28 chapters + cover + TOC as structured JSON
├── images/                 ← 25 high-res PNGs
│   ├── 01_bakery_analogy.png  through  10_testing_ladder.png   (10 diagrams)
│   └── m01_nodejs_path.png    through  m15_play_dashboard.png   (15 mockups)
└── icons/                  ← PWA icons (192, 512, maskable variants)
    ├── icon-192.png
    ├── icon-512.png
    ├── icon-192-maskable.png
    └── icon-512-maskable.png
```

## Keyboard Shortcuts

| Key | Action |
|---|---|
| `/` | Focus search box |
| `Esc` | Close search / overlay |
| `←` | Previous chapter |
| `→` | Next chapter |
| `t` | Toggle dark / light theme |
| `m` | Toggle sidebar (mobile) |
| `?` | Show keyboard shortcuts help |
| `g` `h` | Go to cover / home |

## Browser Support

- ✅ Chrome / Edge 90+ (full PWA install)
- ✅ Firefox 88+ (PWA without install prompt; everything else works)
- ✅ Safari 14+ (full PWA install on iOS; macOS Safari 17+ for install)
- ✅ Samsung Internet
- ⚠️ Internet Explorer — not supported

## Customizing the Content

The book content lives in `content/book.json`. To regenerate it from the source manuscript:

1. Get the latest `manuscript.md` from the source repo
2. Run the build script:
   ```bash
   python3 scripts/build_pwa_content_json.py
   ```
3. The script writes a fresh `content/book.json` (the PWA picks it up on next reload)

## License

The book content (text + diagrams) is © 2025 Z.ai. The reader PWA code is MIT-licensed — feel free to fork and adapt for your own books.

## Credits

- Book content: Z.ai
- Reader UI: Z.ai
- Fonts: Inter (Google Fonts), Noto Serif (Google Fonts), JetBrains Mono (Google Fonts)
- Inspired by: DK Eyewitness Travel Guides visual language
