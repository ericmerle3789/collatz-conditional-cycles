/* ==========================================================================
   Cartographie Collatz — Application principale
   - i18n FR/EN complet
   - Mermaid, Chart.js, modal, filtres
   - Analytics GoatCounter (privacy-friendly)
   ========================================================================== */

(function() {
  'use strict';

  // ========== ÉTAT GLOBAL ==========
  const STATE = {
    lang: localStorage.getItem('collatz-lang') ||
          (navigator.language.startsWith('en') ? 'en' : 'fr'),
    data: null,
    statusFilter: 'all'
  };

  const t = {
    fr: {
      navAccueil: "Accueil",
      navPistes: "Pistes",
      navHypotheses: "Hypothèses",
      navTests: "Tests",
      navMeaCulpa: "Mea culpa",
      navEquipe: "Équipe",
      navCommunaute: "Communauté",
      langBtn: "EN",
      print: "Imprimer",
      backTop: "Haut",
      heroEyebrow: "Cartographie scientifique · Pré-publication",
      heroTitle: 'Une enquête sur les <em>cycles non triviaux</em> conjecturés de la suite de Collatz, formalisée en Lean 4.',
      heroLede: "Trente-cinq pistes mathématiques, trois axiomes piliers, une famille d'hypothèses ouvertes — organisées autour d'une obstruction diophantienne unique : <em>l'inégalité de verrou</em> reliant le nombre d'étapes impaires au nombre d'étapes paires d'un cycle hypothétique.",
      keyStat1Label: "Borne inf. |Λ|",
      keyStat1Desc: "Salikhov 2007 inconditionnel",
      keyStat2Label: "Requis pour cycle",
      keyStat2Desc: "Hercher 2023 conditional Baker",
      keyStat3Label: "Lemme du verrou",
      keyStat3Desc: "Product-Bound Impossibility",
      keyStat4Label: "Pistes étudiées",
      keyStat4Desc: "Région I + II + III",
      lockTitle: "Le verrou Λ_{S,k}",
      lockText: "Quatorze des quinze paradigmes mathématiques investigués retombent sur la même obstruction diophantienne :",
      lockFooter: "Théorème implicite (Cobham 1969 + δ8 lemma) : les bases 2 et 3 sont multiplicativement indépendantes ; toute formalisation de \"cycle Collatz\" qui évite la transcendance log_2 3 tombe dans une logique trop pauvre, ou bien retombe sur la pleine arithmétique indécidable.",
      pistesTitle: "Vingt-huit voies d'attaque",
      pistesIntro: "Catalogue exhaustif des approches mathématiques pour la non-existence des cycles non triviaux Collatz. Cliquez sur une ligne pour voir les détails.",
      searchPlaceholder: "Rechercher une piste, une référence, un auteur…",
      filterAll: "Toutes",
      filterCds: "Culs-de-sac",
      filterPartiel: "Partielles",
      filterInconnu: "Inconnues",
      filterPrometteur: "Prometteuses",
      filterAxiome: "Axiomes",
      colId: "ID",
      colName: "Nom",
      colRegion: "Région",
      colStatus: "Statut",
      colTest4: "4-test",
      colLean: "Lean",
      colSource: "Source",
      hypothesesTitle: "Trois hypothèses sur la sortie",
      hypothesesIntro: "Évolution des probabilités estimées au fil des cycles d'investigation (Cycle 0 → Cycle 2). La hausse de C reflète la convergence cumulative des paradigmes vers Λ_{S,k}.",
      testsTitle: "Tests REQ-MATH-NNN exécutés",
      testsIntro: "Chaque assertion mathématique est validée par script dans le sandbox tests_math/, conformément au PROTOCOLE ARES (Règle 1 : zéro calcul mental).",
      meaCulpaTitle: "Vingt-trois mea culpa publics",
      meaCulpaIntro: "La discipline antifragile demande que chaque erreur détectée soit documentée publiquement avec sévérité 0-10 et règle extraite. Sans cela, le pattern multi-cerveau humain-IA répète indéfiniment les mêmes hallucinations.",
      teamTitle: "Équipe",
      teamIntro: "Ce projet est conduit par un chercheur indépendant en collaboration avec des systèmes d'IA, sous protocole de vérification rigoureux (PROTOCOLE ARES v2).",
      communityTitle: "Communauté Collatz",
      communityIntro: "Ressources et collaborations existantes autour de la conjecture de Collatz (vérifiées 2026-04-29).",
      footerText: "Site produit avec PROTOCOLE ARES v2 (Sandbox · Two-Key Rule · REQ-MATH hash)",
      footerLicense: "Contenu CC-BY-SA 4.0 · Code Lean MIT · Document vivant",
      modalRegion: "Région",
      modalStatus: "Statut",
      modalTest4: "Filtre 4-test",
      modalLean: "Lemme Lean",
      modalRef: "Référence",
      modalWhy: "Pourquoi cette piste est-elle dans cet état ?",
      noResult: "Aucune piste ne correspond à la recherche."
    },
    en: {
      navAccueil: "Home",
      navPistes: "Approaches",
      navHypotheses: "Hypotheses",
      navTests: "Tests",
      navMeaCulpa: "Mea culpa",
      navEquipe: "Team",
      navCommunaute: "Community",
      langBtn: "FR",
      print: "Print",
      backTop: "Top",
      heroEyebrow: "Scientific cartography · Pre-publication",
      heroTitle: 'A survey of conjectural <em>non-trivial cycles</em> in the Collatz sequence, formalized in Lean 4.',
      heroLede: "Thirty-five mathematical approaches, three pillar axioms, a family of open hypotheses — organized around a single diophantine obstruction: <em>the lock inequality</em> connecting the count of odd steps to the count of even steps in a hypothetical cycle.",
      keyStat1Label: "Lower bound |Λ|",
      keyStat1Desc: "Salikhov 2007 unconditional",
      keyStat2Label: "Required for cycle",
      keyStat2Desc: "Hercher 2023 conditional on Baker",
      keyStat3Label: "Lock lemma",
      keyStat3Desc: "Product-Bound Impossibility",
      keyStat4Label: "Approaches studied",
      keyStat4Desc: "Region I + II + III",
      lockTitle: "The Λ_{S,k} lock",
      lockText: "Fourteen out of fifteen investigated mathematical paradigms reduce to the same diophantine obstruction:",
      lockFooter: "Implicit theorem (Cobham 1969 + δ8 lemma): bases 2 and 3 are multiplicatively independent ; any formalization of \"Collatz cycle\" that avoids the transcendence of log_2 3 falls into a logic too weak, or back into undecidable full arithmetic.",
      pistesTitle: "Twenty-eight attack vectors",
      pistesIntro: "Comprehensive catalog of mathematical approaches to the non-existence of non-trivial Collatz cycles. Click a row for details.",
      searchPlaceholder: "Search by name, reference, or author…",
      filterAll: "All",
      filterCds: "Dead ends",
      filterPartiel: "Partial",
      filterInconnu: "Unexplored",
      filterPrometteur: "Promising",
      filterAxiome: "Axioms",
      colId: "ID",
      colName: "Name",
      colRegion: "Region",
      colStatus: "Status",
      colTest4: "4-test",
      colLean: "Lean",
      colSource: "Source",
      hypothesesTitle: "Three hypotheses on the exit",
      hypothesesIntro: "Evolution of estimated probabilities across investigation cycles (Cycle 0 → Cycle 2). The rise of C reflects cumulative convergence of paradigms onto Λ_{S,k}.",
      testsTitle: "Executed REQ-MATH-NNN tests",
      testsIntro: "Every mathematical claim is validated by a script in the tests_math/ sandbox, in accordance with PROTOCOLE ARES (Rule 1: no mental arithmetic).",
      meaCulpaTitle: "Twenty-three public mea culpa",
      meaCulpaIntro: "Antifragile discipline requires every detected error be documented publicly with severity 0-10 and an extracted rule. Without this, the human-AI multi-brain pattern repeats the same hallucinations indefinitely.",
      teamTitle: "Team",
      teamIntro: "This project is led by an independent researcher in collaboration with AI systems, under a rigorous verification protocol (PROTOCOLE ARES v2).",
      communityTitle: "Collatz community",
      communityIntro: "Existing resources and collaborations around the Collatz conjecture (verified 2026-04-29).",
      footerText: "Site produced with PROTOCOLE ARES v2 (Sandbox · Two-Key Rule · REQ-MATH hash)",
      footerLicense: "Content CC-BY-SA 4.0 · Lean code MIT · Living document",
      modalRegion: "Region",
      modalStatus: "Status",
      modalTest4: "4-test filter",
      modalLean: "Lean lemma",
      modalRef: "Reference",
      modalWhy: "Why is this approach in that state?",
      noResult: "No approach matches the search."
    }
  };

  const STATUS_LABELS = {
    fr: {
      cds: "Cul-de-sac",
      partiel: "Partielle",
      inconnu: "Inconnue",
      prouve: "Prouvée",
      prometteur: "Prometteuse",
      axiome: "Axiome"
    },
    en: {
      cds: "Dead end",
      partiel: "Partial",
      inconnu: "Unexplored",
      prouve: "Proven",
      prometteur: "Promising",
      axiome: "Axiom"
    }
  };

  const REGION_LABELS = {
    fr: { I: "I — Arithmétique", II: "II — Hors-domaine", III: "III — Méta" },
    en: { I: "I — Arithmetic", II: "II — Out-of-domain", III: "III — Meta" }
  };

  // ========== I18N ==========
  function applyLang() {
    const dict = t[STATE.lang];
    document.documentElement.lang = STATE.lang;

    // Toutes les chaînes data-i18n
    document.querySelectorAll('[data-i18n]').forEach(el => {
      const key = el.getAttribute('data-i18n');
      if (dict[key]) {
        el.innerHTML = dict[key];
      }
    });

    // Placeholders
    document.querySelectorAll('[data-i18n-placeholder]').forEach(el => {
      const key = el.getAttribute('data-i18n-placeholder');
      if (dict[key]) el.setAttribute('placeholder', dict[key]);
    });

    // Bouton lang
    const langBtn = document.getElementById('langBtn');
    if (langBtn) langBtn.textContent = dict.langBtn;

    // Re-render dynamique (tableau, etc.)
    if (STATE.data) {
      renderTable();
      renderTests();
      renderMeaCulpa();
      renderHypothesesChart();
    }

    // Re-render KaTeX si chargé
    if (window.renderMathInElement) {
      window.renderMathInElement(document.body, {
        delimiters: [
          { left: '$$', right: '$$', display: true },
          { left: '$', right: '$', display: false }
        ]
      });
    }
  }

  function toggleLang() {
    STATE.lang = STATE.lang === 'fr' ? 'en' : 'fr';
    localStorage.setItem('collatz-lang', STATE.lang);
    applyLang();
  }

  // ========== TABLE PISTES ==========
  function renderTable() {
    const tbody = document.querySelector('#pistesTable tbody');
    if (!tbody || !STATE.data) return;

    const search = (document.getElementById('searchInput')?.value || '').toLowerCase();
    const dict = STATE.lang;
    const statusDict = STATUS_LABELS[dict];
    const regionDict = REGION_LABELS[dict];

    tbody.innerHTML = '';
    let visibleCount = 0;

    STATE.data.pistes.forEach(p => {
      const localized = p[dict];
      const text = (p.id + ' ' + (localized?.name || '') + ' ' + (localized?.why || '') + ' ' + (p.ref || '')).toLowerCase();
      const matchSearch = !search || text.includes(search);
      const matchStatus = STATE.statusFilter === 'all' || p.status === STATE.statusFilter;

      if (!matchSearch || !matchStatus) return;
      visibleCount++;

      const tr = document.createElement('tr');
      tr.dataset.pisteId = p.id;
      tr.innerHTML = `
        <td><strong>${p.id}</strong></td>
        <td>${localized?.name || ''}</td>
        <td class="text-muted small">${regionDict[p.region] || p.region}</td>
        <td><span class="badge ${p.status}">${statusDict[p.status] || p.status}</span></td>
        <td class="mono small">${p.test4 || '—'}</td>
        <td>${p.lean ? '<code>' + p.lean + '</code>' : '<span class="text-muted">—</span>'}</td>
        <td>${p.leanFile ? `<a href="https://github.com/ericmerle3789/collatz-conditional-cycles/blob/main/${p.leanFile}" target="_blank" rel="noopener" class="small">.lean ↗</a>` : (p.ref ? '<span class="text-muted small">' + p.ref.substring(0, 40) + (p.ref.length > 40 ? '…' : '') + '</span>' : '<span class="text-muted">—</span>')}</td>
      `;
      tr.addEventListener('click', () => openPisteModal(p));
      tbody.appendChild(tr);
    });

    if (visibleCount === 0) {
      tbody.innerHTML = `<tr><td colspan="7" class="text-muted" style="text-align:center; padding: 2rem;">${t[dict].noResult}</td></tr>`;
    }
  }

  function setStatusFilter(status, btn) {
    STATE.statusFilter = status;
    document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
    btn.classList.add('active');
    renderTable();
  }

  // ========== MODAL ==========
  function openPisteModal(piste) {
    const dict = STATE.lang;
    const localized = piste[dict];
    const tx = t[dict];
    const statusDict = STATUS_LABELS[dict];
    const regionDict = REGION_LABELS[dict];

    document.getElementById('modalTitle').textContent = `${piste.id} — ${localized?.name || ''}`;

    const meta = [];
    meta.push(`<dt>${tx.modalRegion}</dt><dd>${regionDict[piste.region] || piste.region}</dd>`);
    meta.push(`<dt>${tx.modalStatus}</dt><dd><span class="badge ${piste.status}">${statusDict[piste.status]}</span>${piste.severity ? ' <span class="text-muted small">(sev ' + piste.severity + ')</span>' : ''}</dd>`);
    if (piste.test4) meta.push(`<dt>${tx.modalTest4}</dt><dd class="mono">${piste.test4}</dd>`);
    if (piste.lean) meta.push(`<dt>${tx.modalLean}</dt><dd><code>${piste.lean}</code></dd>`);
    if (piste.ref) meta.push(`<dt>${tx.modalRef}</dt><dd>${piste.ref}</dd>`);

    let content = `<dl class="modal-meta">${meta.join('')}</dl>`;
    content += `<h4 style="font-family: var(--serif); font-size: 1.05rem; margin: 1.2rem 0 0.5rem; color: var(--text-primary);">${tx.modalWhy}</h4>`;
    content += `<p style="color: var(--text-secondary);">${localized?.why || ''}</p>`;

    if (piste.leanFile) {
      content += `<p style="margin-top: 1.5rem;"><a href="https://github.com/ericmerle3789/collatz-conditional-cycles/blob/main/${piste.leanFile}" target="_blank" rel="noopener" style="color: var(--accent); text-decoration: none; border-bottom: 1px solid var(--accent);">↗ ${piste.leanFile}</a></p>`;
    }

    document.getElementById('modalContent').innerHTML = content;
    document.getElementById('pisteModal').classList.add('active');
  }

  function closeModal() {
    document.getElementById('pisteModal').classList.remove('active');
  }

  // ========== TESTS REQ-MATH ==========
  function renderTests() {
    const grid = document.getElementById('testsGrid');
    if (!grid || !STATE.data) return;
    const dict = STATE.lang;
    grid.innerHTML = '';

    STATE.data.tests.forEach(test => {
      const localized = test[dict];
      const isWarning = test.exit !== 0;
      const div = document.createElement('div');
      div.className = 'test-card' + (isWarning ? ' warning' : '');
      div.innerHTML = `
        <div class="test-id">${test.id} ${isWarning ? '⚠' : '✓'}</div>
        <div class="test-title">${localized.title}</div>
        <div class="test-desc">${localized.result}</div>
        <div class="test-file">${test.file}</div>
      `;
      grid.appendChild(div);
    });
  }

  // ========== MEA CULPA ==========
  function renderMeaCulpa() {
    const container = document.getElementById('meaCulpaGrid');
    if (!container) return;
    const dict = STATE.lang;

    const items = dict === 'fr' ? [
      { id: '#3', sev: '9', title: 'R76b naming « at_min »', rule: "Naming reflète le claim exact, pas l'intention." },
      { id: '#11', sev: '10', title: 'Conjecture BHV+lacunaire', rule: 'Tester R72 (Steiner identity) avant tout commit.' },
      { id: '#13', sev: '7.5', title: 'Wu 2003 sans lecture obstruction-I', rule: 'Lire paper/v2/05-obstruction-I AVANT proposer Baker/Wu.' },
      { id: '#14', sev: '—', title: 'Bibliographie ≠ étude propre', rule: 'Ne jamais citer une référence sans vérification directe.' },
      { id: '#16', sev: '—', title: 'Sur-affirmation sans tags épistémiques', rule: 'Tags [VÉRIFIÉ]/[PARTIEL]/[SPÉCULATIF]/[INCONNU] obligatoires.' },
      { id: '#19', sev: '8', title: 'Hiérarchie Wu vs Salikhov inversée', rule: 'Tester numériquement les bornes (script Python).' },
      { id: '#20', sev: '10', title: 'Formule log|ρ| nuancée', rule: 'Test SymPy obligatoire pour toute formule mathématique.' },
      { id: '#22', sev: '8', title: 'Sous-estimation δ8 lemma', rule: 'Tester toute combinaison Baker+CF+Khinchin contre δ8/δ8\'.' },
      { id: '#23', sev: '9', title: '3 références inventées', rule: 'Vérifier toute référence par grep direct sur references.bib.' }
    ] : [
      { id: '#3', sev: '9', title: 'R76b naming "at_min"', rule: 'Naming reflects the exact claim, not the intent.' },
      { id: '#11', sev: '10', title: 'BHV+lacunary conjecture', rule: 'Test R72 (Steiner identity) before any commit.' },
      { id: '#13', sev: '7.5', title: 'Wu 2003 without reading obstruction-I', rule: 'Read paper/v2/05-obstruction-I BEFORE proposing Baker/Wu.' },
      { id: '#14', sev: '—', title: 'Bibliography ≠ proper study', rule: 'Never cite a reference without direct verification.' },
      { id: '#16', sev: '—', title: 'Over-assertion without epistemic tags', rule: 'Mandatory tags [VERIFIED]/[PARTIAL]/[SPECULATIVE]/[UNKNOWN].' },
      { id: '#19', sev: '8', title: 'Inverted Wu vs Salikhov hierarchy', rule: 'Numerically test all bounds (Python script).' },
      { id: '#20', sev: '10', title: 'log|ρ| formula nuanced', rule: 'Mandatory SymPy test for any mathematical formula.' },
      { id: '#22', sev: '8', title: 'Underestimating δ8 lemma', rule: "Test any Baker+CF+Khinchin combination against δ8/δ8'." },
      { id: '#23', sev: '9', title: '3 fabricated references', rule: 'Verify every reference via direct grep on references.bib.' }
    ];

    container.innerHTML = items.map(it => `
      <div class="mc-item">
        <div><span class="id">${it.id}</span><span class="severity">${dict === 'fr' ? 'sévérité' : 'severity'} ${it.sev}</span></div>
        <div class="title">${it.title}</div>
        <div class="rule">${it.rule}</div>
      </div>
    `).join('');
  }

  // ========== CHART.JS HYPOTHÈSES ==========
  let hypothesesChartInstance = null;

  function renderHypothesesChart() {
    const ctx = document.getElementById('hypothesesChart');
    if (!ctx || !STATE.data || !window.Chart) return;
    if (hypothesesChartInstance) hypothesesChartInstance.destroy();

    const evolution = STATE.data.hypotheses_evolution;
    const labels = evolution[`labels_${STATE.lang}`];

    hypothesesChartInstance = new Chart(ctx, {
      type: 'line',
      data: {
        labels: labels,
        datasets: [
          {
            label: STATE.lang === 'fr' ? 'A — Combinaison Baker+CF+Khinchin' : 'A — Baker+CF+Khinchin combination',
            data: evolution.A,
            borderColor: '#c25450',
            backgroundColor: 'rgba(194, 84, 80, 0.12)',
            tension: 0.3, borderWidth: 2, pointRadius: 5
          },
          {
            label: STATE.lang === 'fr' ? "A' — Combinaison HORS-δ8 (holonomy)" : "A' — Combination OUTSIDE-δ8 (holonomy)",
            data: evolution.A_prime,
            borderColor: '#c8a86a',
            backgroundColor: 'rgba(200, 168, 106, 0.12)',
            tension: 0.3, borderWidth: 2, borderDash: [6, 5], pointRadius: 5
          },
          {
            label: STATE.lang === 'fr' ? 'B — Téléportation hors domaine' : 'B — Teleportation out-of-domain',
            data: evolution.B,
            borderColor: '#6a93b8',
            backgroundColor: 'rgba(106, 147, 184, 0.12)',
            tension: 0.3, borderWidth: 2, pointRadius: 5
          },
          {
            label: STATE.lang === 'fr' ? 'C — Riemann-class' : 'C — Riemann-class',
            data: evolution.C,
            borderColor: '#6a9b7a',
            backgroundColor: 'rgba(106, 155, 122, 0.12)',
            tension: 0.3, borderWidth: 3, pointRadius: 6
          }
        ]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            labels: {
              color: '#b8b5ad',
              font: { size: 12, family: "'Inter', sans-serif" },
              boxWidth: 28
            }
          },
          tooltip: {
            backgroundColor: '#1f2229',
            titleColor: '#e8e6e0',
            bodyColor: '#e8e6e0',
            borderColor: '#c8a86a',
            borderWidth: 1,
            callbacks: {
              label: ctx => `${ctx.dataset.label}: ${ctx.parsed.y}%`
            }
          }
        },
        scales: {
          y: {
            beginAtZero: true, max: 100,
            ticks: { color: '#8b887f', callback: v => v + '%' },
            grid: { color: 'rgba(139, 136, 127, 0.08)' }
          },
          x: {
            ticks: { color: '#8b887f', font: { size: 11 } },
            grid: { color: 'rgba(139, 136, 127, 0.08)' }
          }
        }
      }
    });
  }

  // ========== INIT ==========
  async function init() {
    // Charger données
    try {
      const resp = await fetch('assets/data/pistes.json');
      STATE.data = await resp.json();
    } catch (e) {
      console.error('Erreur chargement données :', e);
    }

    // Mermaid
    if (window.mermaid) {
      mermaid.initialize({
        startOnLoad: true,
        theme: 'dark',
        themeVariables: {
          primaryColor: '#16181f',
          primaryTextColor: '#e8e6e0',
          primaryBorderColor: '#c8a86a',
          lineColor: '#8b887f',
          secondaryColor: '#0e0f13',
          tertiaryColor: '#1f2229',
          fontFamily: "'Inter', sans-serif"
        }
      });
    }

    // Apply lang
    applyLang();

    // Filter handlers
    const searchInput = document.getElementById('searchInput');
    if (searchInput) searchInput.addEventListener('input', renderTable);

    document.querySelectorAll('.filter-btn').forEach(btn => {
      btn.addEventListener('click', () => setStatusFilter(btn.dataset.status, btn));
    });

    // Modal
    document.getElementById('pisteModal')?.addEventListener('click', e => {
      if (e.target.id === 'pisteModal') closeModal();
    });
    document.addEventListener('keydown', e => {
      if (e.key === 'Escape') closeModal();
    });

    // Toolbar
    document.getElementById('langBtn')?.addEventListener('click', toggleLang);
    document.getElementById('printBtn')?.addEventListener('click', () => window.print());
    document.getElementById('topBtn')?.addEventListener('click', () => {
      window.scrollTo({ top: 0, behavior: 'smooth' });
    });

    // Smooth scroll nav
    document.querySelectorAll('.nav a').forEach(link => {
      link.addEventListener('click', e => {
        const href = link.getAttribute('href');
        if (href.startsWith('#')) {
          e.preventDefault();
          const target = document.querySelector(href);
          if (target) target.scrollIntoView({ behavior: 'smooth', block: 'start' });
        }
      });
    });
  }

  // Exposer fonctions globales nécessaires
  window.closeModal = closeModal;

  // Démarrage
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
