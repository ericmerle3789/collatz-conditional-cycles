/**
 * research-ledger.js
 *
 * Renders the Research Ledger page from assets/data/research-ledger.json.
 * Three-Key validated 2026-04-30 (OLD3 + NEW4 + ChatGPT 5.5 Q14+Q15).
 *
 * Sections (Q15-revised order):
 *  1. Status snapshot (compact)
 *  2. Milestone timeline
 *  3. Audit & Corrections
 *  4. Ongoing studies
 *  5. Full ledger (filterable, deferred after narratives)
 *  6. External references (static HTML)
 *
 * Q15 garde-fous:
 *  - No "prestige page" tone
 *  - Strict separation: AI audit / Lean / JAR / mathematical truth
 *  - Visual density limited by default (Milestones only toggle ON)
 */

(function() {
  'use strict';

  const STATE = {
    data: null,
    lang: 'fr',
    filters: { family: 'all', status: 'all', milestonesOnly: true }
  };

  const FAMILY_LABELS = {
    fr: {
      lean: 'Lean / Preuve formelle',
      audit: 'Audit / Validation',
      'mea-culpa': 'Correction / Mea culpa',
      paper: 'Publication / DOI',
      repository: 'Repository / Outillage',
      study: 'Étude / Littérature'
    },
    en: {
      lean: 'Lean / Formal proof',
      audit: 'Audit / Validation',
      'mea-culpa': 'Correction / Mea culpa',
      paper: 'Publication / DOI',
      repository: 'Repository / Tooling',
      study: 'Study / Literature'
    }
  };

  const STATUS_LABELS = {
    fr: {
      validated: 'Validé',
      resolved: 'Résolu',
      'in-progress': 'En cours',
      submitted: 'Soumis',
      'to-explore': 'À explorer',
      deferred: 'Différé',
      hypothesis: 'Hypothèse',
      archived: 'Archivé',
      failed: 'Rejeté'
    },
    en: {
      validated: 'Validated',
      resolved: 'Resolved',
      'in-progress': 'In progress',
      submitted: 'Submitted',
      'to-explore': 'To explore',
      deferred: 'Deferred',
      hypothesis: 'Hypothesis',
      archived: 'Archived',
      failed: 'Failed'
    }
  };

  // Map raw type → 6 simplified families (Q15 raffinement #1)
  function familyOf(event) {
    const t = event.type || '';
    if (t === 'lean' || t === 'milestone') {
      // Milestone is FLAG, look at subtype/claim_scope to infer family
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

  // Render single event card
  function renderEvent(event) {
    const family = familyOf(event);
    const lang = STATE.lang;
    const title = (event.title && event.title[lang]) || event.title?.en || event.title?.fr || event.id;
    const summary = (event.summary && event.summary[lang]) || event.summary?.en || event.summary?.fr || '';
    const familyLabel = FAMILY_LABELS[lang][family] || family;
    const statusLabel = STATUS_LABELS[lang][event.status] || event.status;
    const milestone = event.milestone === true;

    let artefactsHTML = '';
    if (event.artefacts && event.artefacts.length > 0) {
      artefactsHTML = '<div class="event-artefacts">' +
        event.artefacts.map(a => {
          const label = a.label || a.kind || 'link';
          return `<a class="event-artefact-link" href="${a.url}" target="_blank" rel="noopener">→ ${label}</a>`;
        }).join('') +
        '</div>';
    }

    let claimScopeHTML = '';
    if (event.claim_scope) {
      claimScopeHTML = `<span class="event-claim-scope" title="claim_scope">${event.claim_scope}</span>`;
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
          <span class="event-family-badge">${familyLabel}</span>
          <span class="event-status-badge" data-status="${event.status}">${statusLabel}</span>
          ${claimScopeHTML}
        </div>
        <h3 class="event-title">${title}</h3>
        <p class="event-summary">${summary}</p>
        ${artefactsHTML}
        ${metaSecondaryHTML}
      </article>
    `;
  }

  // Filter logic
  function applyFilters(events) {
    return events.filter(e => {
      if (STATE.filters.milestonesOnly && !e.milestone) return false;
      if (STATE.filters.family !== 'all' && familyOf(e) !== STATE.filters.family) return false;
      if (STATE.filters.status !== 'all' && e.status !== STATE.filters.status) return false;
      return true;
    });
  }

  // Render Section 1 — Status snapshot (5 cards)
  function renderStatusSnapshot(events) {
    const container = document.getElementById('statusSnapshotContainer');
    if (!container) return;

    // Pick 5 cards by category
    const lastMilestone = events
      .filter(e => e.milestone === true && e.status === 'validated')
      .sort((a, b) => (b.datetime || b.date).localeCompare(a.datetime || a.date))[0];

    const lastPaper = events
      .filter(e => e.type === 'paper')
      .sort((a, b) => b.date.localeCompare(a.date))[0];

    const lastLean = events
      .filter(e => (e.lean && e.lean.checked) || familyOf(e) === 'lean')
      .filter(e => e.status === 'validated')
      .sort((a, b) => (b.datetime || b.date).localeCompare(a.datetime || a.date))[0];

    const lastAudit = events
      .filter(e => familyOf(e) === 'audit' && (e.status === 'resolved' || e.status === 'validated'))
      .sort((a, b) => (b.datetime || b.date).localeCompare(a.datetime || a.date))[0];

    const ongoingStudies = events
      .filter(e => e.status === 'in-progress' && (familyOf(e) === 'study' || familyOf(e) === 'lean'))
      .length;

    const lang = STATE.lang;
    const cards = [];
    if (lastMilestone) cards.push(renderEvent(lastMilestone));
    if (lastPaper) cards.push(renderEvent(lastPaper));
    if (lastLean && lastLean.id !== lastMilestone?.id) cards.push(renderEvent(lastLean));
    if (lastAudit) cards.push(renderEvent(lastAudit));

    container.innerHTML = cards.join('');
  }

  // Render Section 2 — Milestone timeline (chronological desc)
  function renderMilestones(events) {
    const container = document.getElementById('milestoneTimelineContainer');
    if (!container) return;
    const milestones = events
      .filter(e => e.milestone === true)
      .sort((a, b) => (b.datetime || b.date).localeCompare(a.datetime || a.date));
    container.innerHTML = milestones.map(renderEvent).join('') ||
      '<p style="color:var(--text-secondary);font-style:italic">—</p>';
  }

  // Render Section 3 — Audit & Corrections
  function renderAudits(events) {
    const container = document.getElementById('auditsContainer');
    if (!container) return;
    const audits = events
      .filter(e => familyOf(e) === 'audit' || familyOf(e) === 'mea-culpa')
      .sort((a, b) => (b.datetime || b.date).localeCompare(a.datetime || a.date));
    container.innerHTML = audits.map(renderEvent).join('') ||
      '<p style="color:var(--text-secondary);font-style:italic">—</p>';
  }

  // Render Section 4 — Ongoing studies
  function renderOngoing(events) {
    const container = document.getElementById('ongoingContainer');
    if (!container) return;
    const ongoing = events
      .filter(e => e.status === 'in-progress' || e.status === 'to-explore' || e.status === 'hypothesis')
      .sort((a, b) => (b.datetime || b.date).localeCompare(a.datetime || a.date));
    container.innerHTML = ongoing.map(renderEvent).join('') ||
      '<p style="color:var(--text-secondary);font-style:italic">—</p>';
  }

  // Render Section 5 — Full ledger (with filters)
  function renderFullLedger(events) {
    const container = document.getElementById('fullLedgerContainer');
    if (!container) return;
    const filtered = applyFilters(events)
      .sort((a, b) => (b.datetime || b.date).localeCompare(a.datetime || a.date));
    container.innerHTML = filtered.map(renderEvent).join('') ||
      '<p style="color:var(--text-secondary);font-style:italic">— no events match current filters —</p>';

    // Update counters
    document.getElementById('filterCountVisible').textContent = filtered.length;
    const totalEl = document.getElementById('filterCountTotal');
    const totalElEN = document.getElementById('filterCountTotalEN');
    if (totalEl) totalEl.textContent = events.length;
    if (totalElEN) totalElEN.textContent = events.length;
  }

  // Render all sections
  function renderAll() {
    if (!STATE.data) return;
    const events = STATE.data.events || [];
    renderStatusSnapshot(events);
    renderMilestones(events);
    renderAudits(events);
    renderOngoing(events);
    renderFullLedger(events);
  }

  // Initialize filters
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

  // Initialize lang switcher
  function initLangSwitcher() {
    document.querySelectorAll('.lang-toggle button').forEach(btn => {
      btn.addEventListener('click', () => {
        const lang = btn.dataset.lang;
        STATE.lang = lang;
        document.documentElement.lang = lang;
        renderAll();
      });
    });
  }

  // Load data + render
  async function init() {
    try {
      const resp = await fetch('../assets/data/research-ledger.json');
      if (!resp.ok) throw new Error(`HTTP ${resp.status}`);
      STATE.data = await resp.json();

      // Detect lang from URL or html element
      const urlLang = new URLSearchParams(window.location.search).get('lang');
      if (urlLang === 'fr') {
        STATE.lang = 'fr';
        document.documentElement.lang = 'fr';
      } else {
        STATE.lang = document.documentElement.lang || 'en';
      }

      initFilters();
      initLangSwitcher();
      renderAll();

      // Update stats (counts already in HTML; could refresh from data here if needed)
      console.log(`[research-ledger] loaded ${STATE.data.events.length} events`);
    } catch (err) {
      console.error('[research-ledger] failed to load:', err);
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
