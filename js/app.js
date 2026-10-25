/* ============================================================
   PWA RELEASE FOR DUMMIES — Main App Logic
   Handles:
   - Loading book.json
   - Building the TOC sidebar
   - Hash-based routing (chapter navigation)
   - Search dropdown wiring
   - Theme (light/dark) with persistence
   - Reading progress bar
   - Back-to-top button
   - Keyboard shortcuts
   - PWA install prompt
   - Service worker registration
   ============================================================ */

(function () {
  'use strict';

  // ---------- State ----------
  let book = null;
  let chapterIndex = {};   // id -> chapter object
  let chapterOrder = [];   // ordered array of chapter ids (excluding dividers)
  let currentChapterId = null;
  let searchDebounceTimer = null;
  let deferredInstallPrompt = null;
  let activeSearchResultIndex = -1;

  // ---------- DOM ----------
  const $ = (sel) => document.querySelector(sel);
  const $$ = (sel) => Array.from(document.querySelectorAll(sel));

  const dom = {
    loading: $('#loading'),
    reader: $('#reader'),
    breadcrumb: $('#chapterBreadcrumb'),
    title: $('#chapterTitle'),
    content: $('#chapterContent'),
    nav: $('#chapterNav'),
    tocNav: $('#tocNav'),
    sidebar: $('#sidebar'),
    sidebarBackdrop: $('#sidebarBackdrop'),
    menuToggle: $('#menuToggle'),
    searchInput: $('#searchInput'),
    searchClear: $('#searchClear'),
    searchResults: $('#searchResults'),
    searchResultsList: $('#searchResultsList'),
    searchResultsCount: $('#searchResultsCount'),
    themeToggle: $('#themeToggle'),
    installBtn: $('#installBtn'),
    printBtn: $('#printBtn'),
    progressBar: $('#progressBar'),
    backToTop: $('#backToTop'),
    metaChapters: $('#metaChapters'),
    metaAppendices: $('#metaAppendices'),
    metaDiagrams: $('#metaDiagrams'),
    metaReadingTime: $('#metaReadingTime'),
    metaEdition: $('#metaEdition'),
    shortcutsOverlay: $('#shortcutsOverlay'),
    shortcutsClose: $('#shortcutsClose'),
    // Print dialog
    printOverlay: $('#printOverlay'),
    printClose: $('#printClose'),
    printCancel: $('#printCancel'),
    printConfirm: $('#printConfirm'),
    printCurrentTitle: $('#printCurrentTitle'),
    printTotalChapters: $('#printTotalChapters'),
    printRangeRow: $('#printRangeRow'),
    printFrom: $('#printFrom'),
    printTo: $('#printTo'),
    printIncludeCover: $('#printIncludeCover'),
    printIncludeToc: $('#printIncludeToc'),
    printDarkMode: $('#printDarkMode'),
  };

  // ---------- Init ----------
  async function init() {
    try {
      // Load theme first (avoid flash of wrong theme)
      loadTheme();

      // Register service worker
      if ('serviceWorker' in navigator) {
        navigator.serviceWorker.register('sw.js').catch(err => {
          console.warn('SW registration failed:', err);
        });
      }

      // Listen for install prompt — Chrome fires this once per page load
      // when the PWA meets installability criteria. We DO call
      // preventDefault() so the browser doesn't show its own banner
      // (which can be jarring), and instead we show our own install
      // button in the topbar. Clicking the button calls .prompt() to
      // trigger the install flow.
      //
      // The console warning "beforeinstallpromptevent.preventDefault()
      // called" is expected and harmless — it's just Chrome reminding
      // us that we now control when to show the prompt.
      window.addEventListener('beforeinstallprompt', (e) => {
        e.preventDefault();
        deferredInstallPrompt = e;
        dom.installBtn.style.display = 'inline-flex';
      });

      // Also handle the case where the app is already installed — hide
      // the install button entirely.
      window.addEventListener('appinstalled', () => {
        dom.installBtn.style.display = 'none';
        deferredInstallPrompt = null;
      });

      // Load book data
      const res = await fetch('content/book.json');
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      book = await res.json();

      // Build chapter index and order
      book.chapters.forEach(ch => {
        chapterIndex[ch.id] = ch;
        if (!ch.is_divider) chapterOrder.push(ch.id);
      });

      // Update meta — pull accurate values from book.metadata
      const m = book.metadata;
      dom.metaChapters.textContent = m.numberedChapters;
      dom.metaAppendices.textContent = m.appendices;
      // Diagrams = flow diagrams + UI mockups + comic panels (combined "visuals" count)
      dom.metaDiagrams.textContent = `${m.diagrams + m.mockups + (m.comicPanels || 0)}`;
      dom.metaReadingTime.textContent = m.readingTime;
      dom.metaEdition.textContent = m.edition.replace('Windows Edition ', '');

      // Build sidebar TOC
      buildSidebar();

      // Wire up events
      wireEvents();

      // Route to initial hash
      hideLoading();
      route();
    } catch (err) {
      console.error('Init failed:', err);
      dom.loading.innerHTML = `
        <div style="color:var(--red);font-weight:600;margin-bottom:8px;">Failed to load book</div>
        <div style="font-size:13px;color:var(--text-muted);">${err.message}</div>
        <div style="font-size:12px;color:var(--text-muted);margin-top:16px;">
          Make sure you are running this from a web server (e.g., <code>python3 -m http.server</code>),
          not opening the file directly.
        </div>
      `;
    }
  }

  // ---------- Build sidebar TOC ----------
  function buildSidebar() {
    const html = [];
    let currentPart = null;

    for (const ch of book.chapters) {
      if (ch.is_divider) {
        // Close previous part group if open
        if (currentPart !== null) html.push('</div>');
        currentPart = ch.id;
        html.push(`<div class="toc-part" data-part="${ch.id}">`);
        // Make the part header clickable too — its content (which may
        // include embedded diagrams like the 5-Tier Testing Ladder) is
        // now accessible via the showChapter() function.
        html.push(`
          <a href="#/${ch.id}" class="toc-part-header" title="${escapeHtml(ch.title)}">
            <span class="toc-part-tag">${getPartTag(ch.title)}</span>
            <span>${getPartName(ch.title)}</span>
          </a>
        `);
      } else {
        html.push(`
          <a href="#/${ch.id}" class="toc-chapter" data-chapter="${ch.id}" title="${escapeHtml(ch.title)}">
            ${escapeHtml(ch.title)}
          </a>
        `);
      }
    }
    if (currentPart !== null) html.push('</div>');

    dom.tocNav.innerHTML = html.join('');
  }

  function getPartTag(title) {
    // "PART I — Equipping the Windows Armory" → "I"
    const m = title.match(/^PART\s+([IVX]+)/i);
    return m ? m[1] : '•';
  }

  function getPartName(title) {
    // "PART I — Equipping the Windows Armory" → "Equipping the Windows Armory"
    return title.replace(/^PART\s+[IVX]+\s*[—–-]\s*/i, '');
  }

  // ---------- Routing ----------
  function route() {
    const hash = location.hash.slice(1); // remove #
    let target = hash.startsWith('/') ? hash.slice(1) : hash;
    if (!target) target = 'cover';

    if (target === 'cover') {
      showCover();
    } else if (chapterIndex[target]) {
      showChapter(target);
    } else {
      // Unknown hash → show cover
      showCover();
    }
  }

  // ---------- Force-reload cover (bypass service worker cache) ----------
  // Triggered when user clicks "Cover & Welcome" button in sidebar.
  // This solves the "stuck on old cached version" problem by:
  //   1. Telling the service worker to skip waiting (activate new SW immediately)
  //   2. Clearing all caches
  //   3. Unregistering the service worker
  //   4. Forcing a hard reload that bypasses cache
  async function forceReloadCover() {
    setCoverButtonReloading(true);

    try {
      // 1. Tell all service workers to skip waiting
      if ('serviceWorker' in navigator) {
        const regs = await navigator.serviceWorker.getRegistrations();
        for (const reg of regs) {
          // Send skipWaiting message
          if (reg.waiting) {
            reg.waiting.postMessage('SKIP_WAITING');
          }
          // Then unregister
          await reg.unregister();
        }
      }

      // 2. Clear ALL caches (this includes book.json, images, everything)
      if ('caches' in window) {
        const keys = await caches.keys();
        await Promise.all(keys.map(k => caches.delete(k)));
      }

      // 3. Force reload to cover, bypassing cache
      // The location.reload(true) is deprecated; modern way is to use
      // location.replace with a cache-busting query param.
      const url = new URL(location.href);
      url.hash = ''; // go to cover
      url.searchParams.set('_cb', Date.now().toString()); // cache-busting param
      location.replace(url.toString());

      // After reload, remove the cache-busting param so URL stays clean
      // (history.replaceState runs after the new page loads)
      setTimeout(() => {
        const clean = new URL(location.href);
        clean.searchParams.delete('_cb');
        history.replaceState(null, '', clean.toString());
      }, 1500);
    } catch (err) {
      console.error('Force reload failed:', err);
      // Fallback: just navigate to cover
      location.hash = '';
      setTimeout(scrollToTop, 100);
      setCoverButtonReloading(false);
    }
  }

  function setCoverButtonReloading(loading) {
    const btn = document.querySelector('.toc-link-cover');
    if (!btn) return;
    if (loading) {
      btn.classList.add('reloading');
      btn.disabled = true;
    } else {
      btn.classList.remove('reloading');
      btn.disabled = false;
    }
  }

  function showCover() {
    currentChapterId = 'cover';
    dom.breadcrumb.innerHTML = `<a href="#/cover">Home</a>`;
    dom.title.textContent = '';

    // Build a proper book cover hero, then the existing cover content,
    // then the TOC. The hero mimics the PDF cover page (navy gradient with
    // amber accents, big title, subtitle, edition badge).
    const m = book.metadata;
    const heroHtml = `
      <div class="book-cover-hero">
        <div class="book-cover-spine"></div>
        <div class="book-cover-content">
          <div class="book-cover-edition">${escapeHtml(m.edition)}</div>
          <h1 class="book-cover-title">${escapeHtml(m.title)}</h1>
          <div class="book-cover-subtitle">${escapeHtml(m.subtitle)}</div>
          <div class="book-cover-tagline">Zero-Mac Hybrid Architecture</div>
          <div class="book-cover-tagline-sub">No Mac Required · No Prior Experience Assumed</div>
          <div class="book-cover-divider"></div>
          <div class="book-cover-stats">
            <div class="book-cover-stat">
              <div class="book-cover-stat-num">${m.numberedChapters}</div>
              <div class="book-cover-stat-label">Chapters</div>
            </div>
            <div class="book-cover-stat">
              <div class="book-cover-stat-num">${m.appendices}</div>
              <div class="book-cover-stat-label">Appendices</div>
            </div>
            <div class="book-cover-stat">
              <div class="book-cover-stat-num">${m.diagrams + m.mockups + (m.comicPanels || 0)}</div>
              <div class="book-cover-stat-label">Visuals</div>
            </div>
            <div class="book-cover-stat">
              <div class="book-cover-stat-num">${m.readingTime}</div>
              <div class="book-cover-stat-label">Reading Time</div>
            </div>
          </div>
          <div class="book-cover-divider"></div>
          <div class="book-cover-author">By ${escapeHtml(m.author)}</div>
          <div class="book-cover-updated">Last updated: ${escapeHtml(m.lastUpdated)}</div>
        </div>
      </div>
      <div class="book-cover-intro">
        <p>This book takes a complete beginner — someone who has never used a command line, never compiled an app, never opened a Git repository — and walks them keystroke-by-keystroke from a folder of PWA web files (index.html, CSS, JavaScript) all the way to published, signed, store-approved apps on both the Apple App Store and Google Play.</p>
        <p>You will use only a standard Windows 10 or Windows 11 PC. <strong>No Mac. No Xcode. No paid Apple Developer hardware.</strong> The cloud Mac is rented for free by GitHub, the cryptographic signing keys are forged with the OpenSSL library that ships inside Git for Windows, and every screen you need to click is described in the same detail a cooking recipe describes how to crack an egg.</p>
        <p style="font-style:italic; text-align:center; font-size:1.1em; margin-top:1.5em;"><strong>If you can follow a recipe, you can ship an app.</strong></p>
      </div>
    `;

    dom.content.innerHTML = heroHtml + '<h2>Table of Contents</h2>' + book.toc_html;
    dom.nav.innerHTML = buildChapterNav(null, chapterOrder[0]);
    updateActiveToc('cover');
    scrollToTop();
    document.title = `${m.title} — ${m.edition}`;
  }

  function showChapter(id) {
    const ch = chapterIndex[id];
    if (!ch) return;
    currentChapterId = id;

    dom.breadcrumb.innerHTML = `
      <a href="#/cover">Home</a> &nbsp;›&nbsp;
      <span>${escapeHtml(ch.part)}</span>
    `;
    dom.title.textContent = ch.title;
    dom.content.innerHTML = ch.html;
    dom.nav.innerHTML = buildChapterNav(getPrevChapter(id), getNextChapter(id));
    updateActiveToc(id);
    scrollToTop();
    document.title = `${ch.title} — ${book.metadata.title}`;

    // Lazy-load images
    lazyLoadImages();
  }

  function getPrevChapter(id) {
    const idx = chapterOrder.indexOf(id);
    if (idx <= 0) return null;
    return chapterOrder[idx - 1];
  }

  function getNextChapter(id) {
    const idx = chapterOrder.indexOf(id);
    if (idx === -1 || idx >= chapterOrder.length - 1) return null;
    return chapterOrder[idx + 1];
  }

  function buildChapterNav(prevId, nextId) {
    const parts = [];
    if (prevId) {
      const prev = chapterIndex[prevId];
      parts.push(`
        <a href="#/${prevId}" class="chapter-nav-btn prev">
          <span class="chapter-nav-label">← Previous</span>
          <span class="chapter-nav-title">${escapeHtml(prev.title)}</span>
        </a>
      `);
    } else {
      parts.push(`<a href="#/cover" class="chapter-nav-btn prev">
        <span class="chapter-nav-label">← Back</span>
        <span class="chapter-nav-title">Cover & Welcome</span>
      </a>`);
    }
    if (nextId) {
      const next = chapterIndex[nextId];
      parts.push(`
        <a href="#/${nextId}" class="chapter-nav-btn next">
          <span class="chapter-nav-label">Next →</span>
          <span class="chapter-nav-title">${escapeHtml(next.title)}</span>
        </a>
      `);
    }
    return parts.join('');
  }

  function updateActiveToc(id) {
    $$('.toc-chapter, .toc-link-cover, .toc-part-header').forEach(el => el.classList.remove('active'));
    if (id === 'cover') {
      const coverLink = document.querySelector('.toc-link-cover');
      if (coverLink) coverLink.classList.add('active');
    } else {
      const link = document.querySelector(`.toc-chapter[data-chapter="${id}"], a.toc-part-header[href="#/${id}"]`);
      if (link) link.classList.add('active');
    }
  }

  // ---------- Lazy load images ----------
  function lazyLoadImages() {
    const imgs = dom.content.querySelectorAll('img');
    if (!('IntersectionObserver' in window)) {
      // Fallback: load all
      imgs.forEach(img => { if (img.dataset.src) img.src = img.dataset.src; });
      return;
    }
    const observer = new IntersectionObserver((entries, obs) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          const img = entry.target;
          if (img.dataset.src) {
            img.src = img.dataset.src;
            delete img.dataset.src;
          }
          obs.unobserve(img);
        }
      });
    }, { rootMargin: '200px' });
    imgs.forEach(img => {
      if (!img.src && img.dataset.src) observer.observe(img);
    });
  }

  // ---------- Search ----------
  function wireSearch() {
    let searchIndex = null;

    // Build search index lazily on first focus
    dom.searchInput.addEventListener('focus', () => {
      if (!searchIndex) {
        searchIndex = book.search_index;
        PWASearch.buildIndex(searchIndex);
      }
    });

    dom.searchInput.addEventListener('input', (e) => {
      const query = e.target.value.trim();
      if (query.length === 0) {
        clearSearch();
        return;
      }
      dom.searchClear.style.display = 'inline-flex';
      // Debounce
      clearTimeout(searchDebounceTimer);
      searchDebounceTimer = setTimeout(() => {
        if (!searchIndex) {
          searchIndex = book.search_index;
          PWASearch.buildIndex(searchIndex);
        }
        runSearch(query);
      }, 150);
    });

    dom.searchInput.addEventListener('keydown', (e) => {
      if (e.key === 'Escape') {
        clearSearch();
        dom.searchInput.blur();
      } else if (e.key === 'ArrowDown') {
        e.preventDefault();
        moveActiveResult(1);
      } else if (e.key === 'ArrowUp') {
        e.preventDefault();
        moveActiveResult(-1);
      } else if (e.key === 'Enter') {
        e.preventDefault();
        const items = dom.searchResultsList.querySelectorAll('.search-result-item');
        if (items.length > 0) {
          const idx = activeSearchResultIndex >= 0 ? activeSearchResultIndex : 0;
          items[idx].click();
        }
      }
    });

    dom.searchClear.addEventListener('click', () => {
      dom.searchInput.value = '';
      clearSearch();
      dom.searchInput.focus();
    });

    // Click outside to close
    document.addEventListener('click', (e) => {
      if (!e.target.closest('.search-wrap')) {
        dom.searchResults.style.display = 'none';
      }
    });
  }

  function runSearch(query) {
    if (query.length < PWASearch.MIN_QUERY) {
      dom.searchResults.style.display = 'none';
      return;
    }
    const results = PWASearch.search(query);
    activeSearchResultIndex = -1;

    if (results.length === 0) {
      dom.searchResultsCount.textContent = '0 results';
      dom.searchResultsList.innerHTML = `
        <div class="search-empty">
          No results for "<strong>${escapeHtml(query)}</strong>"<br>
          <span style="font-size:11px;color:var(--text-faint);margin-top:6px;display:inline-block;">
            Try simpler terms or check spelling
          </span>
        </div>
      `;
      dom.searchResults.style.display = 'flex';
      return;
    }

    dom.searchResultsCount.textContent = `${results.length} ${results.length === 1 ? 'result' : 'results'}`;
    dom.searchResultsList.innerHTML = results.map((r, i) => `
      <button class="search-result-item" data-index="${i}" data-chapter="${r.id}">
        <div class="search-result-part">${escapeHtml(r.part)}</div>
        <div class="search-result-title">${escapeHtml(r.title)}</div>
        <div class="search-result-snippet">${r.snippet}</div>
      </button>
    `).join('');

    // Wire click handlers
    dom.searchResultsList.querySelectorAll('.search-result-item').forEach(item => {
      item.addEventListener('click', () => {
        const chapterId = item.dataset.chapter;
        clearSearch();
        location.hash = `/${chapterId}`;
        // Scroll to top of content
        setTimeout(scrollToTop, 100);
      });
      item.addEventListener('mouseenter', () => {
        activeSearchResultIndex = parseInt(item.dataset.index, 10);
        updateActiveResult();
      });
    });

    dom.searchResults.style.display = 'flex';
  }

  function moveActiveResult(delta) {
    const items = dom.searchResultsList.querySelectorAll('.search-result-item');
    if (items.length === 0) return;
    activeSearchResultIndex = (activeSearchResultIndex + delta + items.length) % items.length;
    updateActiveResult();
    items[activeSearchResultIndex].scrollIntoView({ block: 'nearest' });
  }

  function updateActiveResult() {
    dom.searchResultsList.querySelectorAll('.search-result-item').forEach((item, i) => {
      item.classList.toggle('active', i === activeSearchResultIndex);
    });
  }

  function clearSearch() {
    dom.searchInput.value = '';
    dom.searchResults.style.display = 'none';
    dom.searchClear.style.display = 'none';
    activeSearchResultIndex = -1;
  }

  // ---------- Theme ----------
  function loadTheme() {
    const saved = localStorage.getItem('pwa-reader-theme');
    if (saved === 'dark' || (!saved && window.matchMedia('(prefers-color-scheme: dark)').matches)) {
      document.documentElement.setAttribute('data-theme', 'dark');
    } else {
      document.documentElement.removeAttribute('data-theme');
    }
  }

  function toggleTheme() {
    const isDark = document.documentElement.getAttribute('data-theme') === 'dark';
    if (isDark) {
      document.documentElement.removeAttribute('data-theme');
      localStorage.setItem('pwa-reader-theme', 'light');
    } else {
      document.documentElement.setAttribute('data-theme', 'dark');
      localStorage.setItem('pwa-reader-theme', 'dark');
    }
  }

  // ---------- Sidebar (mobile) ----------
  function toggleSidebar() {
    dom.sidebar.classList.toggle('open');
    dom.sidebarBackdrop.classList.toggle('show');
  }

  function closeSidebar() {
    dom.sidebar.classList.remove('open');
    dom.sidebarBackdrop.classList.remove('show');
  }

  // ---------- Progress + Back-to-top ----------
  function updateScrollState() {
    // Progress bar
    const scrollTop = window.scrollY;
    const docHeight = document.documentElement.scrollHeight - window.innerHeight;
    const progress = docHeight > 0 ? (scrollTop / docHeight) * 100 : 0;
    dom.progressBar.style.width = `${Math.min(100, progress)}%`;

    // Back to top
    if (scrollTop > 600) {
      dom.backToTop.classList.add('show');
    } else {
      dom.backToTop.classList.remove('show');
    }
  }

  function scrollToTop() {
    window.scrollTo({ top: 0, behavior: 'auto' });
  }

  // ---------- Hide loading ----------
  function hideLoading() {
    dom.loading.style.display = 'none';
    dom.reader.style.display = 'block';
  }

  // ---------- Utilities ----------
  function escapeHtml(s) {
    return String(s).replace(/[&<>"']/g, c => ({
      '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;'
    }[c]));
  }

  // ---------- Keyboard shortcuts ----------
  function handleKeydown(e) {
    // Ignore if typing in input (except for / and Escape)
    const inInput = e.target.tagName === 'INPUT' || e.target.tagName === 'TEXTAREA';

    if (e.key === '/' && !inInput) {
      e.preventDefault();
      dom.searchInput.focus();
      return;
    }
    if (e.key === 'Escape') {
      if (dom.shortcutsOverlay.style.display !== 'none') {
        dom.shortcutsOverlay.style.display = 'none';
      } else if (dom.searchResults.style.display !== 'none') {
        clearSearch();
        dom.searchInput.blur();
      }
      return;
    }
    if (inInput) return;

    if (e.key === 'ArrowLeft') {
      // Previous chapter
      const prevBtn = document.querySelector('.chapter-nav-btn.prev');
      if (prevBtn) prevBtn.click();
    } else if (e.key === 'ArrowRight') {
      // Next chapter
      const nextBtn = document.querySelector('.chapter-nav-btn.next');
      if (nextBtn) nextBtn.click();
    } else if (e.key === 't' || e.key === 'T') {
      toggleTheme();
    } else if (e.key === 'm' || e.key === 'M') {
      toggleSidebar();
    } else if (e.key === '?' || e.key === 'Shift_?') {
      dom.shortcutsOverlay.style.display = 'flex';
    } else if (e.key === 'g') {
      // g then h → go home
      const handler = (e2) => {
        if (e2.key === 'h' || e2.key === 'H') {
          location.hash = '/cover';
          scrollToTop();
        }
        document.removeEventListener('keydown', handler);
      };
      document.addEventListener('keydown', handler);
      setTimeout(() => document.removeEventListener('keydown', handler), 1000);
    }
  }

  // ---------- Print dialog ----------
  function openPrintDialog() {
    // Populate the current chapter title
    if (currentChapterId === 'cover') {
      dom.printCurrentTitle.textContent = 'Cover & Welcome page';
    } else if (chapterIndex[currentChapterId]) {
      dom.printCurrentTitle.textContent = chapterIndex[currentChapterId].title;
    } else {
      dom.printCurrentTitle.textContent = '— unknown —';
    }
    dom.printTotalChapters.textContent = book.metadata.numberedChapters + book.metadata.appendices;

    // Populate the chapter range dropdowns (all non-divider chapters + appendices)
    const options = [];
    options.push('<option value="cover">Cover & Welcome</option>');
    for (const ch of book.chapters) {
      if (ch.is_divider) continue;
      options.push(`<option value="${ch.id}">${escapeHtml(ch.title)}</option>`);
    }
    dom.printFrom.innerHTML = options.join('');
    dom.printTo.innerHTML = options.join('');
    // Default: first chapter to last
    const nonDividers = book.chapters.filter(c => !c.is_divider);
    if (nonDividers.length > 0) {
      dom.printFrom.value = nonDividers[0].id;
      dom.printTo.value = nonDividers[nonDividers.length - 1].id;
    }

    dom.printOverlay.style.display = 'flex';
  }

  function wirePrintDialog() {
    dom.printClose.addEventListener('click', closePrintDialog);
    dom.printCancel.addEventListener('click', closePrintDialog);
    dom.printOverlay.addEventListener('click', (e) => {
      if (e.target === dom.printOverlay) closePrintDialog();
    });

    // Show/hide the range row when "range" radio is selected
    document.querySelectorAll('input[name="printScope"]').forEach(radio => {
      radio.addEventListener('change', () => {
        const isRange = document.querySelector('input[name="printScope"][value="range"]').checked;
        dom.printRangeRow.style.display = isRange ? 'flex' : 'none';
      });
    });

    dom.printConfirm.addEventListener('click', performPrint);
  }

  function closePrintDialog() {
    dom.printOverlay.style.display = 'none';
  }

  function performPrint() {
    const scope = document.querySelector('input[name="printScope"]:checked').value;
    const includeCover = dom.printIncludeCover.checked;
    const includeToc = dom.printIncludeToc.checked;
    const useDarkMode = dom.printDarkMode.checked;

    // Build the list of chapters to print
    let chaptersToPrint = [];
    if (scope === 'current') {
      if (currentChapterId === 'cover') {
        // Print just the cover
        chaptersToPrint = [];
      } else if (chapterIndex[currentChapterId]) {
        chaptersToPrint = [chapterIndex[currentChapterId]];
      }
    } else if (scope === 'all') {
      chaptersToPrint = book.chapters.filter(c => !c.is_divider);
    } else if (scope === 'range') {
      const fromId = dom.printFrom.value;
      const toId = dom.printTo.value;
      const nonDividers = book.chapters.filter(c => !c.is_divider);
      const fromIdx = nonDividers.findIndex(c => c.id === fromId);
      const toIdx = nonDividers.findIndex(c => c.id === toId);
      if (fromIdx === -1 || toIdx === -1) {
        alert('Please select valid From and To chapters.');
        return;
      }
      const start = Math.min(fromIdx, toIdx);
      const end = Math.max(fromIdx, toIdx);
      chaptersToPrint = nonDividers.slice(start, end + 1);
    }

    // Build the print HTML
    let printHtml = '<!DOCTYPE html><html><head><meta charset="UTF-8">';
    printHtml += '<title>PWA Release for Dummies — Print</title>';
    printHtml += '<style>';
    // Inline the CSS (simplified print styles)
    printHtml += `
      * { box-sizing: border-box; margin: 0; padding: 0; }
      body {
        font-family: 'Noto Serif', Georgia, serif;
        font-size: 11pt;
        line-height: 1.55;
        color: #1A1A1A;
        background: #FFFFFF;
        ${useDarkMode ? 'background: #1A1A1A; color: #E5E7EB;' : ''}
      }
      h1 {
        font-family: 'Noto Serif', Georgia, serif;
        font-size: 22pt;
        font-weight: 900;
        color: ${useDarkMode ? '#FFD580' : '#1B3A5C'};
        border-bottom: 3px solid #D97706;
        padding-bottom: 6pt;
        margin: 24pt 0 12pt;
        page-break-before: always;
      }
      h1:first-of-type { page-break-before: avoid; }
      h2 { font-size: 16pt; color: ${useDarkMode ? '#FFD580' : '#1B3A5C'}; margin: 18pt 0 8pt; }
      h3 { font-size: 13pt; color: ${useDarkMode ? '#FFD580' : '#1B3A5C'}; margin: 14pt 0 6pt; }
      p { margin: 0 0 8pt; }
      ul, ol { margin: 0 0 8pt; padding-left: 22pt; }
      li { margin-bottom: 3pt; }
      pre {
        background: ${useDarkMode ? '#1E293B' : '#F5F5F0'};
        border: 1px solid #DDD;
        border-left: 4px solid #1B3A5C;
        padding: 8pt 10pt;
        font-family: 'Consolas', monospace;
        font-size: 9pt;
        white-space: pre-wrap;
        margin: 8pt 0;
      }
      code {
        font-family: 'Consolas', monospace;
        font-size: 9pt;
        background: ${useDarkMode ? '#1E293B' : '#F5F5F0'};
        padding: 1pt 3pt;
      }
      pre code { background: transparent; padding: 0; }
      table { width: 100%; border-collapse: collapse; margin: 10pt 0; font-size: 9.5pt; }
      th { background: #1B3A5C; color: #FFF; padding: 6pt 8pt; text-align: left; }
      td { padding: 5pt 8pt; border: 1px solid #DDD; vertical-align: top; }
      tr:nth-child(even) td { background: ${useDarkMode ? '#1E293B' : '#FAF7F0'}; }
      .why-box, .howto-box, .error-box, .novice-note {
        border-radius: 6pt; padding: 10pt 14pt; margin: 10pt 0;
        border-width: 1pt 1pt 1pt 4pt; border-style: solid;
        page-break-inside: avoid;
      }
      .why-box { background: #FFF8E1; border-color: #D97706; }
      .howto-box { background: #EFF6FF; border-color: #1B3A5C; }
      .error-box { background: #FEF2F2; border-color: #B91C1C; }
      .novice-note { background: #F0FDF4; border-color: #047857; }
      .figure-container { text-align: center; margin: 14pt 0; page-break-inside: avoid; }
      .figure-container img { max-width: 100%; height: auto; border: 1px solid #DDD; }
      .figure-caption { font-size: 9pt; color: #6B7280; font-style: italic; margin-top: 6pt; }
      .cover {
        background: linear-gradient(135deg, #1B3A5C 0%, #102538 100%);
        color: #FFFFFF; padding: 80pt 40pt; text-align: center;
        border-radius: 12pt; margin-bottom: 30pt; page-break-after: always;
      }
      .cover h1 { color: #FFFFFF; border: none; font-size: 32pt; page-break-before: avoid; }
      .cover h3 { color: #FFD580; font-style: italic; }
      .cover p { color: rgba(255,255,255,0.9); font-size: 11pt; }
      blockquote {
        background: #FFF8E1; border-left: 4pt solid #D97706;
        padding: 8pt 14pt; margin: 10pt 0; font-style: italic;
      }
      @page { margin: 18mm 16mm; }
    `;
    printHtml += '</style></head><body>';

    // Add cover page
    if (includeCover) {
      printHtml += `<div class="cover">${book.cover_html}</div>`;
    }

    // Add TOC
    if (includeToc) {
      printHtml += `<h1>Table of Contents</h1>${book.toc_html}`;
    }

    // Add each chapter
    for (const ch of chaptersToPrint) {
      printHtml += `<h1>${escapeHtml(ch.title)}</h1>`;
      printHtml += ch.html;
    }

    printHtml += '</body></html>';

    // Open in a new window and trigger print
    const printWindow = window.open('', '_blank');
    if (!printWindow) {
      alert('Please allow pop-ups to use the print feature.');
      return;
    }
    printWindow.document.write(printHtml);
    printWindow.document.close();
    // Wait for images to load before printing
    printWindow.onload = () => {
      setTimeout(() => {
        printWindow.print();
        // Don't auto-close — user may want to save as PDF first
      }, 500);
    };

    closePrintDialog();
  }

  // ---------- Wire events ----------
  function wireEvents() {
    // Routing
    window.addEventListener('hashchange', route);

    // Search
    wireSearch();

    // Theme toggle
    dom.themeToggle.addEventListener('click', toggleTheme);

    // Menu toggle (mobile)
    dom.menuToggle.addEventListener('click', toggleSidebar);
    dom.sidebarBackdrop.addEventListener('click', closeSidebar);

    // Cover & Welcome button — force-reload and clear cache so user always
    // sees the latest version. This solves "I'm stuck on old content" issues
    // without the user needing to know how to clear their browser cache.
    const coverBtn = document.querySelector('.toc-link-cover');
    if (coverBtn) {
      coverBtn.addEventListener('click', (e) => {
        e.preventDefault();
        forceReloadCover();
      });
    }

    // Print
    dom.printBtn.addEventListener('click', openPrintDialog);

    // Print dialog events
    wirePrintDialog();

    // Install
    dom.installBtn.addEventListener('click', async () => {
      if (!deferredInstallPrompt) return;
      deferredInstallPrompt.prompt();
      const { outcome } = await deferredInstallPrompt.userChoice;
      if (outcome === 'accepted') {
        dom.installBtn.style.display = 'none';
      }
      deferredInstallPrompt = null;
    });

    // Back to top
    dom.backToTop.addEventListener('click', () => {
      window.scrollTo({ top: 0, behavior: 'smooth' });
    });

    // Scroll
    window.addEventListener('scroll', updateScrollState, { passive: true });

    // Keyboard
    document.addEventListener('keydown', handleKeydown);

    // Close sidebar on chapter click (mobile)
    dom.tocNav.addEventListener('click', (e) => {
      if (e.target.classList.contains('toc-chapter') && window.innerWidth <= 768) {
        closeSidebar();
      }
    });

    // Shortcuts overlay close
    dom.shortcutsOverlay.addEventListener('click', () => {
      dom.shortcutsOverlay.style.display = 'none';
    });
    dom.shortcutsClose.addEventListener('click', () => {
      dom.shortcutsOverlay.style.display = 'none';
    });
  }

  // ---------- Boot ----------
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
