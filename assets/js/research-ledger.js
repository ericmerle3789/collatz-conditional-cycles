/**
 * research-ledger.js
 *
 * Renders the Research Ledger page from assets/data/research-ledger.json.
 * Three-Key validated 2026-04-30 (OLD3 + NEW4 + ChatGPT 5.5 Q14+Q15).
 *
 * INTEGRATION WITH main.js i18n:
 *   - Generates Pattern B HTML: <span lang="fr">…</span><span lang="en">…</span>
 *   - main.js applyLang() automatically toggles via el.hidden
 *   - This script does NOT manage language state directly
 *
 * Sections rendered:
 *   §II  visualTimelineContainer  — vertical SVG-like timeline (dots + dates + titles)
 *   §III auditsContainer          — detailed audit/correction event cards
 *   §IV  ongoingContainer         — ongoing studies cards
 *   §V   fullLedgerContainer      — full filterable ledger (Milestones only ON by default)
 *
 * Filters apply to §V only.
 */

(function() {
  'use strict';

  const STATE = {
    data: null,
    filters: { family: 'all', status: 'all', milestonesOnly: true }
  };

  // 6 simplified families (Q15 raffinement #1)
  function familyOf(event) {
    const t = event.type || '';
    if (t === 'lean' || t === 'milestone') {
      if (event.claim_scope === 'formal_lean') return 'lean';
      if (event.claim_scope === 'submitted_paper') return 'paper';
      if (event.claim_scope === 'documentation') return 'audit';
      return 'lean';
    }
    if (t === 'audit' || t === 'three-key' || t === 'two-key') return 'audit';
    if (t === 'mea-culpa') return 'mea-culpa';
    if (t === 'paper') return 'paper';
    if (t === 'commit' || t === 'repository' || t === 'tooling') return 'repository';
    if (t === 'study' || t === 'reading' || t === 'cycle') return 'study';
    return 'study';
  }

  // Get bilingual strings from event.title and event.summary
  function getBilingualHTML(field) {
    if (!field) return '';
    const fr = field.fr || field.en || '';
    const en = field.en || field.fr || '';
    return `<span lang="fr">${fr}</span><span lang="en">${en}</span>`;
  }

  // Family labels (Pattern B for badges)
  function familyBadgeHTML(family) {
    const labels = {
      'lean':       { fr: 'Lean / Preuve formelle',     en: 'Lean / Formal proof' },
      'audit':      { fr: 'Audit / Validation',          en: 'Audit / Validation' },
      'mea-culpa':  { fr: 'Correction / Mea culpa',      en: 'Correction / Mea culpa' },
      'paper':      { fr: 'Publication / DOI',           en: 'Publication / DOI' },
      'repository': { fr: 'Repository / Outillage',      en: 'Repository / Tooling' },
      'study':      { fr: 'Étude / Littérature',         en: 'Study / Literature' }
    };
    const l = labels[family] || { fr: family, en: family };
    return `<span class="event-family-badge" data-family="${family}"><span lang="fr">${l.fr}</span><span lang="en">${l.en}</span></span>`;
  }

  // Status labels (Pattern B)
  function statusBadgeHTML(status) {
    const labels = {
      'validated':   { fr: 'Validé',     en: 'Validated' },
      'resolved':    { fr: 'Résolu',     en: 'Resolved' },
      'in-progress': { fr: 'En cours',   en: 'In progress' },
      'submitted':   { fr: 'Soumis',     en: 'Submitted' },
      'to-explore':  { fr: 'À explorer', en: 'To explore' },
      'deferred':    { fr: 'Différé',    en: 'Deferred' },
      'hypothesis':  { fr: 'Hypothèse',  en: 'Hypothesis' },
      'archived':    { fr: 'Archivé',    en: 'Archived' },
      'failed':      { fr: 'Rejeté',     en: 'Failed' }
    };
    const l = labels[status] || { fr: status, en: status };
    return `<span class="event-status-badge" data-status="${status}"><span lang="fr">${l.fr}</span><span lang="en">${l.en}</span></span>`;
  }

  // === VISUAL TIMELINE (§II) ===
  // Vertical: date on left, dot in center, title on right
  function renderVisualTimeline(events) {
    const container = document.getElementById('visualTimelineContainer');
    if (!container) return;

    const sorted = events.slice().sort((a, b) =>
      (b.datetime || b.date).localeCompare(a.datetime || a.date)
    );

    container.innerHTML = sorted.map(e => {
      const family = familyOf(e);
      const milestone = e.milestone === true;
      return `
        <div class="visual-event" data-family="${family}" data-milestone="${milestone}" data-id="${e.id}">
          <div class="visual-event-date">${e.date}</div>
          <div class="visual-event-marker"><div class="visual-event-dot" title="${(e.title?.en || e.id).replace(/"/g, '&quot;')}"></div></div>
          <div class="visual-event-content">
            <div class="visual-event-title">${familyBadgeHTML(family)} ${getBilingualHTML(e.title)}</div>
            <div class="visual-event-subtitle">${statusBadgeHTML(e.status)}${e.claim_scope ? ` · <code>${e.claim_scope}</code>` : ''}</div>
          </div>
        </div>
      `;
    }).join('');

    // Trigger main.js applyLang to hide/show <span lang="..."> spans
    if (typeof window.applyLang === 'function') {
      try { window.applyLang(); } catch (e) { /* main.js wraps applyLang in IIFE; fallback below */ }
    }
    // Fallback: use document.documentElement.lang to hide spans
    syncLangToCurrent(container);
  }

  // Detailed event card (sections III, IV, V)
  function renderEventCard(event) {
    const family = familyOf(event);
    const milestone = event.milestone === true;
    const titleHTML = getBilingualHTML(event.title);
    const summaryHTML = getBilingualHTML(event.summary);

    let claimScopeHTML = '';
    if (event.claim_scope) {
      claimScopeHTML = `<span class="event-claim-scope" title="claim_scope">${event.claim_scope}</span>`;
    }

    let artefactsHTML = '';
    if (event.artefacts && event.artefacts.length > 0) {
      artefactsHTML = '<div class="event-artefacts">' +
        event.artefacts.map(a => {
          const label = a.label || a.kind || 'link';
          return `<a class="event-artefact-link" href="${a.url}" target="_blank" rel="noopener">→ ${label}</a>`;
        }).join('') +
        '</div>';
    }

    let metaSecondary = [];
    if (event.verification_method) metaSecondary.push(`verif: ${event.verification_method}`);
    if (event.evidence_level) metaSecondary.push(`evidence: ${event.evidence_level}`);
    if (event.epistemic_status) metaSecondary.push(`epistemic: ${event.epistemic_status}`);
    if (event.last_verified_at) metaSecondary.push(`last_verified: ${event.last_verified_at}`);
    if (event.severity !== undefined) metaSecondary.push(`severity: ${event.severity}`);
    const metaSecondaryHTML = metaSecondary.length > 0
      ? `<div class="event-meta-secondary">${metaSecondary.join(' · ')}</div>`
      : '';

    return `
      <article class="ledger-event" data-family="${family}" data-status="${event.status}" data-milestone="${milestone}" data-id="${event.id}">
        <div class="event-header">
          <span class="event-date">${event.date}</span>
          ${familyBadgeHTML(family)}
          ${statusBadgeHTML(event.status)}
          ${claimScopeHTML}
        </div>
        <h3 class="event-title">${titleHTML}</h3>
        <div class="event-summary">${summaryHTML}</div>
        ${artefactsHTML}
        ${metaSecondaryHTML}
      </article>
    `;
  }

  // Filter logic for full ledger §V
  function applyFilters(events) {
    return events.filter(e => {
      if (STATE.filters.milestonesOnly && !e.milestone) return false;
      if (STATE.filters.family !== 'all' && familyOf(e) !== STATE.filters.family) return false;
      if (STATE.filters.status !== 'all' && e.status !== STATE.filters.status) return false;
      return true;
    });
  }

  function renderAudits(events) {
    const container = document.getElementById('auditsContainer');
    if (!container) return;
    const audits = events
      .filter(e => familyOf(e) === 'audit' || familyOf(e) === 'mea-culpa')
      .sort((a, b) => (b.datetime || b.date).localeCompare(a.datetime || a.date));
    container.innerHTML = audits.map(renderEventCard).join('') || '<p>—</p>';
    syncLangToCurrent(container);
  }

  function renderOngoing(events) {
    const container = document.getElementById('ongoingContainer');
    if (!container) return;
    const ongoing = events
      .filter(e => e.status === 'in-progress' || e.status === 'to-explore' || e.status === 'hypothesis')
      .sort((a, b) => (b.datetime || b.date).localeCompare(a.datetime || a.date));
    container.innerHTML = ongoing.map(renderEventCard).join('') || '<p>—</p>';
    syncLangToCurrent(container);
  }

  function renderFullLedger(events) {
    const container = document.getElementById('fullLedgerContainer');
    if (!container) return;
    const filtered = applyFilters(events).sort((a, b) =>
      (b.datetime || b.date).localeCompare(a.datetime || a.date)
    );
    container.innerHTML = filtered.map(renderEventCard).join('') ||
      '<p style="color:var(--text-secondary);font-style:italic"><span lang="fr">— aucun événement ne correspond aux filtres —</span><span lang="en">— no events match current filters —</span></p>';

    document.getElementById('filterCountVisible').textContent = filtered.length;
    document.getElementById('filterCountTotal').textContent = events.length;

    syncLangToCurrent(container);
  }

  // Sync newly-rendered <span lang="fr"> / <span lang="en"> visibility to current document.documentElement.lang
  function syncLangToCurrent(scope) {
    const currentLang = document.documentElement.lang || 'en';
    const root = scope || document;
    root.querySelectorAll('[lang="fr"], [lang="en"]').forEach(el => {
      if (el === document.documentElement) return;
      el.hidden = (el.getAttribute('lang') !== currentLang);
    });
  }

  function renderAll() {
    if (!STATE.data) return;
    const events = STATE.data.events || [];
    renderVisualTimeline(events);
    renderAudits(events);
    renderOngoing(events);
    renderFullLedger(events);
  }

  function initFilters() {
    const familyEl = document.getElementById('filterFamily');
    const statusEl = document.getElementById('filterStatus');
    const milestonesEl = document.getElementById('filterMilestonesOnly');

    if (familyEl) familyEl.addEventListener('change', (e) => {
      STATE.filters.family = e.target.value;
      renderFullLedger(STATE.data.events);
    });

    if (statusEl) statusEl.addEventListener('change', (e) => {
      STATE.filters.status = e.target.value;
      renderFullLedger(STATE.data.events);
    });

    if (milestonesEl) milestonesEl.addEventListener('change', (e) => {
      STATE.filters.milestonesOnly = e.target.checked;
      renderFullLedger(STATE.data.events);
    });
  }

  // Listen to language changes from main.js (langBtn click triggers MutationObserver-friendly attribute change)
  function observeLangChange() {
    const observer = new MutationObserver(mutations => {
      for (const m of mutations) {
        if (m.type === 'attributes' && m.attributeName === 'lang') {
          // Re-sync visibility on all our generated content
          syncLangToCurrent();
          break;
        }
      }
    });
    observer.observe(document.documentElement, { attributes: true, attributeFilter: ['lang'] });
  }

  async function init() {
    try {
      const resp = await fetch('../assets/data/research-ledger.json');
      if (!resp.ok) throw new Error(`HTTP ${resp.status}`);
      STATE.data = await resp.json();

      initFilters();
      observeLangChange();
      renderAll();

      console.log(`[research-ledger] loaded ${STATE.data.events.length} events`);
    } catch (err) {
      console.error('[research-ledger] failed:', err);
      const fallback = document.querySelector('main');
      if (fallback) {
        fallback.insertAdjacentHTML('afterbegin',
          `<div style="padding:1rem;background:#7f1d1d;color:#fca5a5;border-radius:6px;margin:1rem 0">
            <strong>Error loading ledger:</strong> ${err.message}
          </div>`
        );
      }
    }
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
