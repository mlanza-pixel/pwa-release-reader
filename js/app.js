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

      // Listen for install prompt
      window.addEventListener('beforeinstallprompt', (e) => {
        e.preventDefault();
        deferredInstallPrompt = e;
        dom.installBtn.style.display = 'inline-flex';
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
      // Diagrams = flow diagrams + UI mockups (combined "visuals" count)
      dom.metaDiagrams.textContent = `${m.diagrams + m.mockups}`;
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

  function showCover() {
    currentChapterId = 'cover';
    dom.breadcrumb.innerHTML = `<a href="#/cover">Home</a>`;
    dom.title.textContent = book.metadata.title;
    dom.content.innerHTML = book.cover_html + '<h2>Table of Contents</h2>' + book.toc_html;
    dom.nav.innerHTML = buildChapterNav(null, chapterOrder[0]);
    updateActiveToc('cover');
    scrollToTop();
    document.title = `${book.metadata.title} — ${book.metadata.edition}`;
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

    // Print
    dom.printBtn.addEventListener('click', () => window.print());

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
