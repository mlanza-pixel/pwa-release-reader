/* ============================================================
   PWA RELEASE FOR DUMMIES — Service Worker
   Caches the app shell + content for offline use.
   Strategy:
   - On install: precache core shell (HTML, CSS, JS, manifest, icons)
   - On fetch: cache-first for static assets, network-first for content
   - On activate: clean up old caches
   ============================================================ */

const VERSION = 'v2.0.0';
const CACHE_SHELL = `pwa-reader-shell-${VERSION}`;
const CACHE_CONTENT = `pwa-reader-content-${VERSION}`;

// Core shell — must work offline
const SHELL_ASSETS = [
  './',
  './index.html',
  './manifest.json',
  './css/styles.css',
  './js/app.js',
  './js/search.js',
  './icons/icon-192.png',
  './icons/icon-512.png',
  './icons/icon-192-maskable.png',
  './icons/icon-512-maskable.png',
];

// ---------- Install: precache shell ----------
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_SHELL).then(cache => {
      // Use addAll with tolerant fallback (don't fail install if one asset fails)
      return Promise.all(
        SHELL_ASSETS.map(url =>
          cache.add(url).catch(err => {
            console.warn('Failed to cache', url, err);
          })
        )
      );
    })
  );
  self.skipWaiting();
});

// ---------- Activate: clean old caches ----------
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then(keys => {
      return Promise.all(
        keys
          .filter(key => key !== CACHE_SHELL && key !== CACHE_CONTENT)
          .map(key => caches.delete(key))
      );
    })
  );
  self.clients.claim();
});

// ---------- Fetch: cache-first for shell, network-first for content ----------
self.addEventListener('fetch', (event) => {
  const req = event.request;

  // Only handle GET
  if (req.method !== 'GET') return;

  const url = new URL(req.url);

  // Skip cross-origin
  if (url.origin !== self.location.origin) return;

  // Skip chrome-extension and non-http(s)
  if (!url.protocol.startsWith('http')) return;

  // Content JSON and images — network-first, fall back to cache
  if (url.pathname.endsWith('book.json') || url.pathname.includes('/images/')) {
    event.respondWith(
      fetch(req)
        .then(res => {
          // Cache a copy
          const clone = res.clone();
          caches.open(CACHE_CONTENT).then(cache => cache.put(req, clone)).catch(() => {});
          return res;
        })
        .catch(() => caches.match(req).then(r => r || new Response('Offline', { status: 503 })))
    );
    return;
  }

  // Everything else — cache-first
  event.respondWith(
    caches.match(req).then(cached => {
      if (cached) return cached;
      return fetch(req)
        .then(res => {
          // Cache successful responses
          if (res.ok && res.type === 'basic') {
            const clone = res.clone();
            caches.open(CACHE_SHELL).then(cache => cache.put(req, clone)).catch(() => {});
          }
          return res;
        })
        .catch(() => {
          // For navigation requests, fall back to cached index.html
          if (req.mode === 'navigate') {
            return caches.match('./index.html');
          }
          return new Response('Offline', { status: 503 });
        });
    })
  );
});

// ---------- Message: skipWaiting ----------
self.addEventListener('message', (event) => {
  if (event.data === 'SKIP_WAITING') self.skipWaiting();
});
