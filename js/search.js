/* ============================================================
   PWA RELEASE FOR DUMMIES — Search Engine
   Lightweight client-side full-text search with:
   - Tokenized matching (every word must match somewhere)
   - Field weighting (title matches rank higher than body)
   - Snippet extraction with highlight
   - Debounced input
   ============================================================ */

(function (global) {
  'use strict';

  // Config
  const MIN_QUERY = 2;          // minimum chars to trigger search
  const MAX_RESULTS = 30;       // hard cap on returned results
  const SNIPPET_PADDING = 60;   // chars before/after match in snippet
  const SNIPPET_LENGTH = 180;   // max snippet length

  // Stop words — ignored in queries
  const STOP_WORDS = new Set([
    'a','an','and','are','as','at','be','by','for','from','has','have','he','in','is','it',
    'its','of','on','or','that','the','this','to','was','were','will','with','you','your',
    'i','we','they','them','our','my','me','do','does','did','can','could','would','should',
    'how','what','when','where','why','who','which','if','then','so','but','not','no','yes',
  ]);

  // State
  let index = null;       // [{ id, title, part, text, tokens: Set, titleTokens: Set }]
  let indexBuilt = false;

  // ---------- Tokenization ----------
  function tokenize(text) {
    if (!text) return [];
    const lower = text.toLowerCase();
    // Split on non-alphanumeric (keep hyphens within words)
    const words = lower.match(/[a-z0-9][a-z0-9\-]+/g) || [];
    return words.filter(w => w.length >= 2 && !STOP_WORDS.has(w));
  }

  // ---------- Build index ----------
  function buildIndex(searchIndexData) {
    if (indexBuilt) return;
    index = searchIndexData.map(entry => ({
      id: entry.id,
      title: entry.title,
      part: entry.part,
      text: entry.text,
      tokens: new Set(tokenize(entry.text)),
      titleTokens: new Set(tokenize(entry.title)),
    }));
    indexBuilt = true;
  }

  // ---------- Search ----------
  function search(query) {
    if (!indexBuilt || !index) return [];
    const queryTokens = tokenize(query);
    if (queryTokens.length === 0) return [];

    const results = [];
    for (const entry of index) {
      let score = 0;
      const matchedTokens = [];

      for (const qt of queryTokens) {
        let tokenMatched = false;

        // Title match (highest weight)
        for (const tt of entry.titleTokens) {
          if (tt.includes(qt) || qt.includes(tt)) {
            score += 10;
            tokenMatched = true;
            break;
          }
        }

        // Body match
        if (!tokenMatched) {
          for (const bt of entry.tokens) {
            if (bt.includes(qt)) {
              score += 1;
              tokenMatched = true;
              break;
            }
          }
        }

        if (tokenMatched) {
          matchedTokens.push(qt);
        } else {
          // Required token did not match — skip this entry
          score = 0;
          break;
        }
      }

      if (score > 0) {
        results.push({
          id: entry.id,
          title: entry.title,
          part: entry.part,
          score,
          snippet: extractSnippet(entry.text, queryTokens),
        });
      }
    }

    // Sort by score (desc), then by title (asc)
    results.sort((a, b) => {
      if (b.score !== a.score) return b.score - a.score;
      return a.title.localeCompare(b.title);
    });

    return results.slice(0, MAX_RESULTS);
  }

  // ---------- Snippet extraction ----------
  function extractSnippet(text, queryTokens) {
    if (!text) return '';
    const lower = text.toLowerCase();

    // Find first match position
    let firstMatch = -1;
    for (const qt of queryTokens) {
      const idx = lower.indexOf(qt);
      if (idx !== -1 && (firstMatch === -1 || idx < firstMatch)) {
        firstMatch = idx;
      }
    }

    if (firstMatch === -1) {
      // No match in body — return start of text
      return text.slice(0, SNIPPET_LENGTH).trim() + '…';
    }

    const start = Math.max(0, firstMatch - SNIPPET_PADDING);
    const end = Math.min(text.length, start + SNIPPET_LENGTH);
    let snippet = text.slice(start, end).trim();

    if (start > 0) snippet = '…' + snippet;
    if (end < text.length) snippet = snippet + '…';

    return highlightTerms(snippet, queryTokens);
  }

  // ---------- Highlight matched terms ----------
  function highlightTerms(text, terms) {
    let result = text;
    // Escape HTML first
    result = result
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;');

    // Highlight each term (longest first to avoid partial overlap)
    const sortedTerms = [...new Set(terms)].sort((a, b) => b.length - a.length);
    for (const term of sortedTerms) {
      const escaped = term.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
      const regex = new RegExp(`(${escaped})`, 'gi');
      result = result.replace(regex, '<mark>$1</mark>');
    }
    return result;
  }

  // ---------- Public API ----------
  global.PWASearch = {
    buildIndex,
    search,
    MIN_QUERY,
  };
})(window);
