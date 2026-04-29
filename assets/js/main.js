/* ==========================================================================
   Cartographie Collatz — Application principale
   - i18n FR/EN complet
   - Mermaid, Chart.js, modal, filtres
   - Analytics GoatCounter (privacy-friendly)
   ========================================================================== */

(function() {
  'use strict';

  // ========== ÉTAT GLOBAL ==========
  // Stratégie EN-canonique : anglais par défaut pour tout navigateur
  // sauf détection explicite d'une locale francophone (fr, fr-FR, fr-CA…).
  // localStorage écrase toujours la détection (persistance du choix utilisateur).
  const STATE = {
    lang: localStorage.getItem('collatz-lang') ||
          (navigator.language && navigator.language.toLowerCase().startsWith('fr') ? 'fr' : 'en'),
    theme: localStorage.getItem('collatz-theme') ||
           (window.matchMedia && window.matchMedia('(prefers-color-scheme: light)').matches ? 'light' : 'dark'),
    data: null,
    statusFilter: 'all'
  };

  // Application immédiate du thème (avant DOMContentLoaded pour éviter FOUC)
  document.documentElement.dataset.theme = STATE.theme;

  const t = {
    fr: {
      navAccueil: "Accueil",
      navPistes: "Pistes",
      navLemmes: "Lemmes",
      navPreuve: "Preuve",
      navPapers: "Papers",
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
      noResult: "Aucune piste ne correspond à la recherche.",
      mainResultEyebrow: "Résultat principal — paper soumis JAR Springer",
      mainResultTitle: "Aucun cycle Collatz non-trivial — modulo trois conditions explicites",
      mainResultDesc: "Le théorème principal <code>no_nontrivial_cycle_phase59</code> est <strong>kernel-checked</strong> en Lean 4 (Mathlib v4.27), avec un profil d'axiomes minimal (3 axiomes Lean kernel : <code>propext</code>, <code>Classical.choice</code>, <code>Quot.sound</code>) et trois hypothèses externes documentées : <strong>BakerSeparation</strong> (LMN95), <strong>BarinaVerification</strong> (n &lt; 2<sup>71</sup>), <strong>DerivedLargeKBound</strong> (Hercher 2023, m ≤ 91).",
      mainResultContrib: "<strong>Contribution scientifique</strong> : pas la non-existence inconditionnelle (cf. δ8 lemma, irréalisable avec les outils 2026), mais la <em>cartographie rigoureuse des obstructions structurelles</em> qui rend la conditionnalité <strong>nécessaire</strong>, pas <em>arbitraire</em>. Sept théorèmes centraux, ~30 fichiers Lean, paper 28 pages, reproductible via <code>reproduce.sh</code> EXIT 0.",
      readPaper: "Lire le paper (PDF, 28 p.)",
      readProof: "Architecture de la preuve",
      diagramCaption: "→ Le théorème JAR <code>no_nontrivial_cycle_phase59</code> est l'unique nœud de fermeture conditionnelle. Les 14 paradigmes convergent vers le verrou Λ ; seules les 3 hypothèses externes (Baker, Barina, Hercher) — et non les paradigmes — alimentent le théorème final.",
      citeBtn: "Citer",
      citeTitle: "Comment citer ce travail",
      citePlain: "Texte simple",
      citeCopy: "Copier",
      citeDoiLabel: "DOI"
    },
    en: {
      navAccueil: "Home",
      navPistes: "Approaches",
      navLemmes: "Lemmas",
      navPreuve: "Proof",
      navPapers: "Papers",
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
      noResult: "No approach matches the search.",
      mainResultEyebrow: "Main result — paper submitted to JAR Springer",
      mainResultTitle: "No non-trivial Collatz cycle — modulo three explicit conditions",
      mainResultDesc: "The main theorem <code>no_nontrivial_cycle_phase59</code> is <strong>kernel-checked</strong> in Lean 4 (Mathlib v4.27), with a minimal axiom profile (3 Lean kernel axioms: <code>propext</code>, <code>Classical.choice</code>, <code>Quot.sound</code>) and three documented external hypotheses: <strong>BakerSeparation</strong> (LMN95), <strong>BarinaVerification</strong> (n &lt; 2<sup>71</sup>), <strong>DerivedLargeKBound</strong> (Hercher 2023, m ≤ 91).",
      mainResultContrib: "<strong>Scientific contribution</strong>: not unconditional non-existence (cf. δ8 lemma, unattainable with 2026 tools), but a <em>rigorous mapping of structural obstructions</em> that makes the conditionality <strong>necessary</strong>, not <em>arbitrary</em>. Seven central theorems, ~30 Lean files, 28-page paper, reproducible via <code>reproduce.sh</code> EXIT 0.",
      readPaper: "Read the paper (PDF, 28 pp.)",
      readProof: "Proof architecture",
      diagramCaption: "→ The JAR theorem <code>no_nontrivial_cycle_phase59</code> is the unique conditional closure node. The 14 paradigms converge onto the Λ lock ; only the 3 external hypotheses (Baker, Barina, Hercher) — not the paradigms — feed the final theorem.",
      citeBtn: "Cite",
      citeTitle: "How to cite this work",
      citePlain: "Plain text",
      citeCopy: "Copy to clipboard",
      citeDoiLabel: "DOI"
    }
  };

  const STATUS_LABELS = {
    fr: {
      jar: "★ Résultat JAR",
      cds: "Cul-de-sac",
      partiel: "Partielle",
      inconnu: "Inconnue",
      prouve: "Prouvée",
      prometteur: "Prometteuse",
      axiome: "Axiome"
    },
    en: {
      jar: "★ JAR result",
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

  // ========== GITHUB URL ROUTING ==========
  // main = JAR paper (Phase12-63, paper/, reproduce.sh, expected_axioms.md)
  // arsenal-postjar = extensions R34-R96 (PostJAR/, tests_math/)
  const GH_REPO = 'https://github.com/ericmerle3789/collatz-conditional-cycles/blob/';

  function ghURL(filePath) {
    if (!filePath) return null;
    if (filePath.startsWith('ProjetCollatz/PostJAR/') || filePath.startsWith('tests_math/')) {
      return GH_REPO + 'arsenal-postjar/' + filePath;
    }
    return GH_REPO + 'main/' + filePath;
  }

  // ========== I18N ==========
  function applyLang() {
    const dict = t[STATE.lang];
    document.documentElement.lang = STATE.lang;
    document.documentElement.dataset.lang = STATE.lang;

    // Pattern A — clés data-i18n résolues via dictionnaire (utilisé sur index.html)
    document.querySelectorAll('[data-i18n]').forEach(el => {
      const key = el.getAttribute('data-i18n');
      if (dict[key]) {
        el.innerHTML = dict[key];
      }
    });

    // Pattern B — contenu dual inline lang="fr"/lang="en" (utilisé sur sous-pages)
    // Masque tous les éléments dont la langue ne correspond pas à STATE.lang
    document.querySelectorAll('[lang="fr"], [lang="en"]').forEach(el => {
      // Ne pas affecter <html> lui-même ni les enfants des autres scripts (KaTeX etc.)
      if (el === document.documentElement) return;
      el.hidden = (el.getAttribute('lang') !== STATE.lang);
    });

    // Placeholders
    document.querySelectorAll('[data-i18n-placeholder]').forEach(el => {
      const key = el.getAttribute('data-i18n-placeholder');
      if (dict[key]) el.setAttribute('placeholder', dict[key]);
    });

    // Bouton lang : affiche la langue ALTERNATIVE (cliquer pour basculer)
    const langBtn = document.getElementById('langBtn');
    if (langBtn) langBtn.textContent = dict.langBtn;

    // Re-render dynamique (tableau, tests, mea culpa) — gracieux si pas sur index.html
    if (STATE.data) {
      if (typeof renderTable === 'function' && document.querySelector('#pistesTable')) renderTable();
      if (typeof renderTests === 'function' && document.querySelector('#testsGrid')) renderTests();
      if (typeof renderMeaCulpa === 'function' && document.querySelector('#meaCulpaGrid')) renderMeaCulpa();
      if (typeof renderHypothesesChart === 'function' && document.querySelector('#hypothesesChart')) renderHypothesesChart();
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

  // ========== THEME (clair / sombre) ==========
  function applyTheme() {
    document.documentElement.dataset.theme = STATE.theme;
    // Met à jour aussi <meta name="theme-color"> pour la barre de statut mobile
    const metaTheme = document.querySelector('meta[name="theme-color"]');
    if (metaTheme) metaTheme.content = (STATE.theme === 'light') ? '#fbfaf6' : '#0e0f13';
    // Re-render Mermaid avec le bon thème (sombre / par défaut)
    if (window.mermaid && document.querySelector('.mermaid')) {
      mermaid.initialize({
        startOnLoad: false,
        theme: (STATE.theme === 'light') ? 'default' : 'dark',
        themeVariables: STATE.theme === 'light'
          ? { primaryColor: '#ffffff', primaryTextColor: '#1a1a1a', primaryBorderColor: '#8b6f30', lineColor: '#6b6760', secondaryColor: '#f5f2ea', tertiaryColor: '#ece8dc', fontFamily: "'Inter', sans-serif" }
          : { primaryColor: '#16181f', primaryTextColor: '#e8e6e0', primaryBorderColor: '#c8a86a', lineColor: '#8b887f', secondaryColor: '#0e0f13', tertiaryColor: '#1f2229', fontFamily: "'Inter', sans-serif" }
      });
      // Re-render les diagrammes en re-parsant
      document.querySelectorAll('.mermaid').forEach((el, i) => {
        if (el.dataset.original) { el.innerHTML = el.dataset.original; el.removeAttribute('data-processed'); }
        else { el.dataset.original = el.innerHTML; }
      });
      mermaid.run();
    }
    // Re-render Chart.js avec couleurs adaptées
    if (typeof renderHypothesesChart === 'function' && document.querySelector('#hypothesesChart')) {
      renderHypothesesChart();
    }
  }

  function toggleTheme() {
    STATE.theme = STATE.theme === 'dark' ? 'light' : 'dark';
    localStorage.setItem('collatz-theme', STATE.theme);
    applyTheme();
  }

  // ========== CITATION (BibTeX / APA / Chicago / RIS / plain) ==========
  // Source unique de vérité pour les métadonnées de citation
  const CITATION_DATA = {
    title: "On the non-existence of non-trivial Collatz cycles: a conditional formal proof in Lean 4 with documented structural obstructions",
    author: "Eric Merle",
    authorFamily: "Merle",
    authorGiven: "Eric",
    year: "2026",
    month: "April",
    day: "27",
    doi: "10.5281/zenodo.19790406",
    url: "https://doi.org/10.5281/zenodo.19790406",
    repo: "https://github.com/ericmerle3789/collatz-conditional-cycles",
    publisher: "Zenodo",
    journal: "Journal of Automated Reasoning",
    note: "Submitted to Journal of Automated Reasoning",
    orcid: "0009-0008-7940-402X"
  };

  function citeBibTeX(c) {
    return `@misc{merle${c.year}collatz,
  author       = {${c.author}},
  title        = {${c.title}},
  year         = {${c.year}},
  month        = ${c.month.toLowerCase()},
  doi          = {${c.doi}},
  url          = {${c.url}},
  publisher    = {${c.publisher}},
  note         = {${c.note}. Lean~4 source: \\url{${c.repo}}},
  howpublished = {\\url{${c.url}}}
}`;
  }
  function citeAPA(c) {
    return `${c.authorFamily}, ${c.authorGiven.charAt(0)}. (${c.year}). ${c.title} [Manuscript submitted for publication]. ${c.publisher}. https://doi.org/${c.doi}`;
  }
  function citeChicago(c) {
    return `${c.authorFamily}, ${c.authorGiven}. "${c.title}." Submitted to ${c.journal}. ${c.publisher}, ${c.month} ${c.day}, ${c.year}. https://doi.org/${c.doi}.`;
  }
  function citeRIS(c) {
    return `TY  - GEN
T1  - ${c.title}
AU  - ${c.authorFamily}, ${c.authorGiven}
PY  - ${c.year}
DA  - ${c.year}/${('0'+(['','January','February','March','April','May','June','July','August','September','October','November','December'].indexOf(c.month))).slice(-2)}/${('0'+c.day).slice(-2)}
DO  - ${c.doi}
UR  - ${c.url}
PB  - ${c.publisher}
N1  - ${c.note}. Lean 4 source: ${c.repo}
ER  - `;
  }
  function citePlain(c) {
    return `${c.author} (${c.year}). ${c.title}. DOI: ${c.doi}. ${c.note}.`;
  }

  function renderCitation(format) {
    const out = document.getElementById('citeOutput');
    if (!out) return;
    const c = CITATION_DATA;
    let txt = '';
    switch (format) {
      case 'bibtex': txt = citeBibTeX(c); break;
      case 'apa':    txt = citeAPA(c); break;
      case 'chicago':txt = citeChicago(c); break;
      case 'ris':    txt = citeRIS(c); break;
      case 'plain':  txt = citePlain(c); break;
    }
    out.textContent = txt;
    out.dataset.format = format;
  }

  function injectCitationModal() {
    if (document.getElementById('citeModal')) return; // déjà présent
    const dict = t[STATE.lang];
    const html = `
      <div class="modal-overlay" id="citeModal" role="dialog" aria-modal="true" aria-labelledby="citeModalTitle">
        <div class="modal" style="max-width: 820px;">
          <button class="modal-close" id="citeModalClose" aria-label="Close">×</button>
          <h3 id="citeModalTitle"><span data-i18n="citeTitle">${dict.citeTitle || 'How to cite this work'}</span></h3>
          <div class="cite-tabs" role="tablist">
            <button class="cite-tab active" data-fmt="bibtex" role="tab" aria-selected="true">BibTeX</button>
            <button class="cite-tab" data-fmt="apa" role="tab">APA 7</button>
            <button class="cite-tab" data-fmt="chicago" role="tab">Chicago 17</button>
            <button class="cite-tab" data-fmt="ris" role="tab">RIS</button>
            <button class="cite-tab" data-fmt="plain" role="tab" data-i18n="citePlain">${dict.citePlain || 'Plain text'}</button>
          </div>
          <div class="cite-content">
            <pre id="citeOutput" aria-live="polite" style="white-space: pre-wrap; word-break: break-word; max-height: 380px; overflow-y: auto;"></pre>
            <div style="display: flex; justify-content: space-between; align-items: center; margin-top: 0.8rem; flex-wrap: wrap; gap: 0.6rem;">
              <span class="text-muted small">
                <span data-i18n="citeDoiLabel">${dict.citeDoiLabel || 'DOI'}</span> :
                <a href="https://doi.org/10.5281/zenodo.19790406" target="_blank" rel="noopener" style="color: var(--accent);">10.5281/zenodo.19790406</a>
                · <a href="https://orcid.org/${CITATION_DATA.orcid}" target="_blank" rel="noopener" style="color: var(--accent);">ORCID</a>
              </span>
              <button id="copyCiteBtn" class="btn-icon" style="border: 1px solid var(--accent); padding: 0.5rem 1.1rem; color: var(--accent); border-radius: 3px;">
                <span data-i18n="citeCopy">${dict.citeCopy || 'Copy to clipboard'}</span>
              </button>
            </div>
          </div>
        </div>
      </div>
    `;
    document.body.insertAdjacentHTML('beforeend', html);

    // Wire les events
    document.getElementById('citeModalClose')?.addEventListener('click', () => {
      document.getElementById('citeModal').classList.remove('active');
    });
    document.getElementById('citeModal')?.addEventListener('click', e => {
      if (e.target.id === 'citeModal') {
        document.getElementById('citeModal').classList.remove('active');
      }
    });
    document.querySelectorAll('.cite-tab').forEach(btn => {
      btn.addEventListener('click', () => {
        document.querySelectorAll('.cite-tab').forEach(b => {
          b.classList.remove('active');
          b.setAttribute('aria-selected', 'false');
        });
        btn.classList.add('active');
        btn.setAttribute('aria-selected', 'true');
        renderCitation(btn.dataset.fmt);
      });
    });
    document.getElementById('copyCiteBtn')?.addEventListener('click', async (e) => {
      const txt = document.getElementById('citeOutput')?.textContent || '';
      try {
        await navigator.clipboard.writeText(txt);
        const orig = e.currentTarget.querySelector('span').textContent;
        e.currentTarget.querySelector('span').textContent = '✓ Copied';
        setTimeout(() => { e.currentTarget.querySelector('span').textContent = orig; }, 1800);
      } catch (err) {
        // Fallback : sélectionner le texte
        const range = document.createRange();
        range.selectNode(document.getElementById('citeOutput'));
        window.getSelection().removeAllRanges();
        window.getSelection().addRange(range);
      }
    });

    // Render initial format
    renderCitation('bibtex');
  }

  function openCiteModal() {
    injectCitationModal();
    document.getElementById('citeModal').classList.add('active');
  }

  // ========== SCROLL PROGRESS BAR ==========
  // Fallback JS pour navigateurs qui ne supportent pas scroll-driven animations
  function initScrollProgress() {
    if (CSS.supports && CSS.supports('animation-timeline: scroll()')) return; // CSS natif suffit
    const updateProgress = () => {
      const scrolled = window.scrollY;
      const max = document.documentElement.scrollHeight - window.innerHeight;
      const ratio = max > 0 ? Math.min(scrolled / max, 1) : 0;
      document.documentElement.style.setProperty('--scroll-progress', ratio);
    };
    window.addEventListener('scroll', updateProgress, { passive: true });
    window.addEventListener('resize', updateProgress, { passive: true });
    updateProgress();
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

      // JAR result is always pinned at top (ignores status filter, respects search)
      const isJar = p.status === 'jar';
      if (!matchSearch) return;
      if (!isJar && !matchStatus) return;
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
        <td>${p.leanFile ? `<a href="${ghURL(p.leanFile)}" target="_blank" rel="noopener" class="small">.lean ↗</a>` : (p.ref ? '<span class="text-muted small">' + p.ref.substring(0, 40) + (p.ref.length > 40 ? '…' : '') + '</span>' : '<span class="text-muted">—</span>')}</td>
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
      content += `<p style="margin-top: 1.5rem;"><a href="${ghURL(piste.leanFile)}" target="_blank" rel="noopener" style="color: var(--accent); text-decoration: none; border-bottom: 1px solid var(--accent);">↗ ${piste.leanFile}</a></p>`;
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
  // Calcule un chemin absolu vers /assets/ depuis l'URL du script lui-même.
  // Permet à main.js de fonctionner depuis /, /preuve/, /papers/, /lemmes/, etc.
  function assetsBaseURL() {
    const scripts = document.querySelectorAll('script[src]');
    for (const s of scripts) {
      const m = s.src.match(/^(.*\/assets\/)js\/main\.js(\?.*)?$/);
      if (m) return m[1];
    }
    // Fallback : chemin relatif (fonctionne sur index.html racine)
    return 'assets/';
  }

  async function init() {
    // Charger données — uniquement si présent (sur index.html, pas sur sous-pages)
    // mais on charge quand même pour permettre i18n cohérent partout
    try {
      const base = assetsBaseURL();
      const resp = await fetch(base + 'data/pistes.json');
      if (resp.ok) STATE.data = await resp.json();
    } catch (e) {
      console.warn('Données pistes.json non chargées (page secondaire ?) :', e.message);
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
    document.getElementById('themeBtn')?.addEventListener('click', toggleTheme);
    document.getElementById('citeBtn')?.addEventListener('click', openCiteModal);
    document.getElementById('printBtn')?.addEventListener('click', () => window.print());

    // Raccourci clavier : 'C' ouvre la modale citation (sauf en input)
    document.addEventListener('keydown', e => {
      if ((e.key === 'c' || e.key === 'C') && !e.metaKey && !e.ctrlKey && !e.altKey) {
        const tag = (e.target.tagName || '').toLowerCase();
        if (tag === 'input' || tag === 'textarea' || e.target.isContentEditable) return;
        e.preventDefault();
        openCiteModal();
      }
    });
    document.getElementById('topBtn')?.addEventListener('click', () => {
      window.scrollTo({ top: 0, behavior: 'smooth' });
    });

    // Theme + Scroll progress
    applyTheme();
    initScrollProgress();

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
