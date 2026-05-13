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
      navPourTous: "Pour tous",
      navPistes: "Pistes",
      navLemmes: "Lemmes",
      navPreuve: "Preuve",
      navPapers: "Papers",
      navHypotheses: "Hypothèses",
      navTests: "Tests",
      navMeaCulpa: "Mea culpa",
      navLedger: "Registre",
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
      pistesTitle: "Catalogue des voies d'attaque",
      pistesIntro: "Catalogue exhaustif des approches mathématiques pour la non-existence des cycles non triviaux Collatz. Cliquez sur une ligne pour voir les détails. <em>Transparence éditoriale : 21 entrées sur 36 (≈58 %) sont en statut <code>stub</code> — notes exploratoires en attente de sourçage formel ; le champ <code>status_meta</code> du JSON les marque explicitement (cf. <code>assets/data/pistes.json</code>).</em>",
      searchPlaceholder: "Rechercher une piste, une référence, un auteur…",
      filterAll: "Toutes",
      filterCds: "Culs-de-sac",
      filterInsuf: "Insuffisance prouvée",
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
      meaCulpaTitle: "Vingt-huit mea culpa publics",
      meaCulpaIntro: "La discipline antifragile demande que chaque erreur détectée soit documentée publiquement avec sévérité 0-10 et règle extraite. Sans cela, le pattern multi-cerveau humain-IA répète indéfiniment les mêmes hallucinations. <em>Aperçu de 16 mea culpa parmi les 32 documentés au total ; archive complète dans le repo GitHub <code>_handoff_mailbox/</code>.</em>",
      researchStatusTitle: "État des travaux",
      researchStatusIntro: "Snapshot d'activité du projet, traçable sur GitHub. <a href=\"/research-ledger/\">Registre complet (Research Ledger) →</a>",
      statusLastMilestone: "Dernier jalon validé",
      statusPaper: "Statut paper",
      statusLastLean: "Dernière vérification Lean",
      statusLastAudit: "Dernier audit résolu",
      statusOngoing: "Études en cours",
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
      mainResultEyebrow: "Résultat principal — preprint 28 p. (DOI Zenodo)",
      mainResultTitle: "Théorème conditionnel : aucun cycle Collatz non-trivial — modulo 3 hypothèses externes documentées",
      mainResultDesc: "Le théorème principal <code>no_nontrivial_cycle_phase59</code> est <strong>kernel-checked</strong> en Lean 4 (Mathlib v4.27), avec 3 axiomes Lean kernel (<code>propext</code>, <code>Classical.choice</code>, <code>Quot.sound</code>) et <strong>3 hypothèses externes documentées</strong> : <strong>BakerSeparation</strong> (<em>conjecture de travail</em>, renforcement non démontré des bornes Rhin 1987 / Wu 2003 / Salikhov 2007 publiées — voir <a href=\"#meaculpa\">#28</a> + <strong>δ10</strong>), <strong>BarinaVerification</strong> (n &lt; 2<sup>71</sup>, vérification computationnelle reproductible, Barina 2025), <strong>DerivedLargeKBound</strong> (<em>dérivation projet</em>, k &gt; 1322 ⇒ n &lt; 2<sup>71</sup> ; combine BakerSeparation + gaps fractions continues log<sub>2</sub>3 + Product Bound + BarinaVerification ; <strong>n'est pas un théorème publié</strong> — cf. <a href=\"https://github.com/ericmerle3789/collatz-conditional-cycles/blob/main/HYPOTHESES.md\" target=\"_blank\" rel=\"noopener\">HYPOTHESES.md §5</a>).",
      mainResultContrib: "<strong>Contribution scientifique</strong> : pas la non-existence inconditionnelle (cf. δ8 lemma, irréalisable avec les outils 2026), mais la <em>cartographie rigoureuse des obstructions structurelles</em> qui rend la conditionnalité <strong>nécessaire</strong>, pas <em>arbitraire</em>. Sept théorèmes centraux, ~30 fichiers Lean, paper 28 pages, reproductible via <code>reproduce.sh</code> EXIT 0.",
      readPaper: "Lire le paper (PDF, 28 p.)",
      readProof: "Architecture de la preuve",
      diagramCaption: "→ Le théorème principal <code>no_nontrivial_cycle_phase59</code> est l'unique nœud de fermeture conditionnelle. Les 14 paradigmes convergent vers le verrou Λ ; seules les 3 hypothèses externes (BakerSeparation, BarinaVerification, DerivedLargeKBound) — et non les paradigmes — alimentent le théorème final.",
      citeBtn: "Citer",
      citeTitle: "Comment citer ce travail",
      citePlain: "Texte simple",
      citeCopy: "Copier",
      citeDoiLabel: "DOI",
      searchPalettePlaceholder: "Rechercher théorèmes, pistes, pages…",
      searchEmpty: "Aucun résultat",
      searchNav: "naviguer",
      searchOpen: "ouvrir",
      searchClose: "fermer",
      buildPassing: "site build : passing",
      lastCommit: "dernier commit",
      changelogLink: "changelog"
    },
    en: {
      navAccueil: "Home",
      navPourTous: "For everyone",
      navPistes: "Approaches",
      navLemmes: "Lemmas",
      navPreuve: "Proof",
      navPapers: "Papers",
      navHypotheses: "Hypotheses",
      navTests: "Tests",
      navMeaCulpa: "Mea culpa",
      navLedger: "Ledger",
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
      pistesTitle: "Catalogue of attack pathways",
      pistesIntro: "Comprehensive catalog of mathematical approaches to the non-existence of non-trivial Collatz cycles. Click a row for details. <em>Editorial transparency: 21 of 36 entries (≈58 %) are <code>stub</code> status — unsourced exploratory notes pending formal sourcing; the JSON <code>status_meta</code> field flags them explicitly (cf. <code>assets/data/pistes.json</code>).</em>",
      searchPlaceholder: "Search by name, reference, or author…",
      filterAll: "All",
      filterCds: "Dead ends",
      filterInsuf: "Insufficiency proven",
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
      researchStatusTitle: "Research status",
      researchStatusIntro: "Project activity snapshot, traceable on GitHub. <a href=\"/research-ledger/\">Full registry (Research Ledger) →</a>",
      statusLastMilestone: "Last validated milestone",
      statusPaper: "Paper status",
      statusLastLean: "Last Lean verification",
      statusLastAudit: "Last resolved audit",
      statusOngoing: "Ongoing studies",
      meaCulpaTitle: "Twenty-eight public mea culpa",
      meaCulpaIntro: "Antifragile discipline requires every detected error be documented publicly with severity 0-10 and an extracted rule. Without this, the human-AI multi-brain pattern repeats the same hallucinations indefinitely. <em>Sample of 16 mea culpa out of 32 total documented ; full archive in the GitHub repo <code>_handoff_mailbox/</code>.</em>",
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
      mainResultEyebrow: "Main result — 28-page preprint (Zenodo DOI)",
      mainResultTitle: "Conditional theorem: no non-trivial Collatz cycle — modulo 3 documented external hypotheses",
      mainResultDesc: "The main theorem <code>no_nontrivial_cycle_phase59</code> is <strong>kernel-checked</strong> in Lean 4 (Mathlib v4.27), with 3 Lean kernel axioms (<code>propext</code>, <code>Classical.choice</code>, <code>Quot.sound</code>) and <strong>3 documented external hypotheses</strong>: <strong>BakerSeparation</strong> (<em>working conjecture</em>, undemonstrated strengthening of published Rhin 1987 / Wu 2003 / Salikhov 2007 bounds — see <a href=\"#meaculpa\">#28</a> + <strong>δ10</strong>), <strong>BarinaVerification</strong> (n &lt; 2<sup>71</sup>, reproducible computational verification, Barina 2025), <strong>DerivedLargeKBound</strong> (<em>project-derived hypothesis</em>, k &gt; 1322 ⇒ n &lt; 2<sup>71</sup>; combines BakerSeparation + continued-fraction gaps of log<sub>2</sub>3 + Product Bound + BarinaVerification; <strong>not a published theorem</strong> — see <a href=\"https://github.com/ericmerle3789/collatz-conditional-cycles/blob/main/HYPOTHESES.md\" target=\"_blank\" rel=\"noopener\">HYPOTHESES.md §5</a>).",
      mainResultContrib: "<strong>Scientific contribution</strong>: not unconditional non-existence (cf. δ8 lemma, unattainable with 2026 tools), but a <em>rigorous mapping of structural obstructions</em> that makes the conditionality <strong>necessary</strong>, not <em>arbitrary</em>. Seven central theorems, ~30 Lean files, 28-page paper, reproducible via <code>reproduce.sh</code> EXIT 0.",
      readPaper: "Read the paper (PDF, 28 pp.)",
      readProof: "Proof architecture",
      diagramCaption: "→ The main theorem <code>no_nontrivial_cycle_phase59</code> is the unique conditional closure node. The 14 paradigms converge onto the Λ lock ; only the 3 external hypotheses (BakerSeparation, BarinaVerification, DerivedLargeKBound) — not the paradigms — feed the final theorem.",
      citeBtn: "Cite",
      citeTitle: "How to cite this work",
      citePlain: "Plain text",
      citeCopy: "Copy to clipboard",
      citeDoiLabel: "DOI",
      searchPalettePlaceholder: "Search theorems, approaches, pages…",
      searchEmpty: "No results",
      searchNav: "navigate",
      searchOpen: "open",
      searchClose: "close",
      buildPassing: "site build: passing",
      lastCommit: "last commit",
      changelogLink: "changelog"
    }
  };

  const STATUS_LABELS = {
    fr: {
      main: "★ Résultat principal",
      cds: "Cul-de-sac",
      partiel: "Partielle",
      insuf: "Insuffisance formelle prouvée (conditionnelle)",
      inconnu: "Inconnue",
      prouve: "Prouvée",
      prometteur: "Prometteuse",
      axiome: "Axiome"
    },
    en: {
      main: "★ Main result",
      cds: "Dead end",
      partiel: "Partial",
      insuf: "Formal insufficiency proven (conditional)",
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
  // main = preprint v1.1 (Phase12-63, paper/, reproduce.sh, expected_axioms.md)
  // arsenal-postjar = extensions R34-R96 (PostJAR/, tests_math/ general) — branch name preserved historically
  // study/delta10-... = Phase64 cartographic impossibility + delta10-specific tests
  // study/E1-salikhov-2007-impossibility = Phase65 δ11 conditional E.1 closure
  // study/cgs-7-instantiation = CGS-7 theorem + CGS7Dependencies (Phase 3 finalisation)
  const GH_REPO = 'https://github.com/ericmerle3789/collatz-conditional-cycles/blob/';

  function ghURL(filePath) {
    if (!filePath) return null;
    // CGS-7 instantiation files (Phase 3 finalisation, branch dérivée arsenal-postjar)
    if (filePath.includes('CGS7Theorem') || filePath.includes('CGS7Dependencies')) {
      return GH_REPO + 'study/cgs-7-instantiation/' + filePath;
    }
    // delta10-specific files (Phase64 theorem + REQ-MATH-012 numerical test)
    if (filePath.includes('Phase64') || filePath.includes('delta10')) {
      return GH_REPO + 'study/delta10-barina-replacement-impossibility/' + filePath;
    }
    // δ11 Salikhov-Insufficient files (Phase65 conditional E.1 closure, post-Phase 6 push 2026-05-08)
    if (filePath.includes('Delta11Salikhov') || filePath.includes('Phase65')) {
      return GH_REPO + 'study/E1-salikhov-2007-impossibility/' + filePath;
    }
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
    // Each render is independently caught so a single failure can't interrupt
    // applyLang() and starve later toolbar listeners from being attached.
    if (STATE.data) {
      const safeRender = (name, fn) => { try { fn(); } catch (e) { console.warn(name + ' failed:', e); } };
      if (typeof renderTable === 'function' && document.querySelector('#pistesTable')) safeRender('renderTable', renderTable);
      if (typeof renderTests === 'function' && document.querySelector('#testsGrid')) safeRender('renderTests', renderTests);
      if (typeof renderMeaCulpa === 'function' && document.querySelector('#meaCulpaGrid')) safeRender('renderMeaCulpa', renderMeaCulpa);
      if (typeof renderHypothesesChart === 'function' && document.querySelector('#hypothesesChart')) safeRender('renderHypothesesChart', renderHypothesesChart);
    }

    // Re-générer la TOC dans la nouvelle langue (delay pour laisser le DOM se mettre à jour)
    // Use Promise.resolve().then to ensure microtask ordering after DOM updates
    Promise.resolve().then(() => {
      try {
        initTableOfContents();
      } catch (e) {
        console.warn('TOC regeneration failed:', e);
      }
    });

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
    note: "Preprint deposited on Zenodo",
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
    return `${c.authorFamily}, ${c.authorGiven.charAt(0)}. (${c.year}). ${c.title} [Preprint]. ${c.publisher}. https://doi.org/${c.doi}`;
  }
  function citeChicago(c) {
    return `${c.authorFamily}, ${c.authorGiven}. "${c.title}." Preprint. ${c.publisher}, ${c.month} ${c.day}, ${c.year}. https://doi.org/${c.doi}.`;
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

  // ========== COMMAND PALETTE / THEOREM SEARCH (Cmd+K / Ctrl+K) ==========
  // Recherche universelle sur pistes + théorèmes Lean (centralTheorems,
  // auxiliaryTheorems, cfGaps, postJarArsenal). Fonctionne sur toutes les
  // pages : navigation cross-page si match dans une page distincte.
  let SEARCH_INDEX = null;
  let SEARCH_LEMMES = null;

  async function ensureSearchIndex() {
    // pistes : déjà chargé via STATE.data
    // lemmes : à fetcher si pas déjà
    if (SEARCH_INDEX) return SEARCH_INDEX;
    const base = assetsBaseURL();
    if (!SEARCH_LEMMES) {
      try {
        // Cache buster aligné main.js (cf. bug catché 2026-05-08, voir init())
        const scriptSrc = document.currentScript?.src
          || Array.from(document.querySelectorAll('script[src*="main.js"]')).map(s => s.src)[0]
          || '';
        const cacheBuster = scriptSrc.match(/\?v=([^&]+)/)?.[1] || Date.now();
        const r = await fetch(base + 'data/lemmes.json?v=' + cacheBuster);
        if (r.ok) SEARCH_LEMMES = await r.json();
      } catch (e) { /* sous-page sans accès */ }
    }
    SEARCH_INDEX = [];
    // Pistes
    if (STATE.data && STATE.data.pistes) {
      STATE.data.pistes.forEach(p => {
        SEARCH_INDEX.push({
          type: 'piste',
          id: p.id,
          title: p.en?.name || p.fr?.name || p.id,
          titleFr: p.fr?.name || '',
          subtitle: 'Approach · Region ' + p.region + ' · ' + p.status,
          desc: (p.en?.why || p.fr?.why || '').substring(0, 140),
          url: 'index.html#pistes',
          keywords: [p.id, p.lean, p.ref, p.fr?.name, p.en?.name, p.fr?.why, p.en?.why, p.region, p.status].filter(Boolean).join(' ').toLowerCase()
        });
      });
    }
    // Théorèmes Lean centraux
    if (SEARCH_LEMMES && SEARCH_LEMMES.centralTheorems) {
      SEARCH_LEMMES.centralTheorems.forEach(t => {
        SEARCH_INDEX.push({
          type: 'theorem',
          id: t.name,
          title: t.name,
          subtitle: 'Central theorem · ' + (t.en?.role || t.fr?.role || ''),
          desc: (t.en?.desc || t.fr?.desc || '').substring(0, 140),
          url: 'lemmes/',
          file: t.file,
          keywords: [t.name, t.file, t.en?.desc, t.fr?.desc, ...(t.depends || []), ...(t.axioms || [])].filter(Boolean).join(' ').toLowerCase()
        });
      });
    }
    if (SEARCH_LEMMES && SEARCH_LEMMES.auxiliaryTheorems) {
      SEARCH_LEMMES.auxiliaryTheorems.forEach(t => {
        SEARCH_INDEX.push({
          type: 'lemma',
          id: t.name,
          title: t.name,
          subtitle: 'Auxiliary lemma · ' + (t.en?.role || t.fr?.role || ''),
          desc: (t.en?.desc || t.fr?.desc || '').substring(0, 140),
          url: 'lemmes/',
          file: t.file,
          keywords: [t.name, t.file, t.en?.desc, t.fr?.desc].filter(Boolean).join(' ').toLowerCase()
        });
      });
    }
    if (SEARCH_LEMMES && SEARCH_LEMMES.cfGaps) {
      SEARCH_LEMMES.cfGaps.forEach(g => {
        SEARCH_INDEX.push({
          type: 'cfgap',
          id: g.name,
          title: g.name,
          subtitle: 'CF gap · Window W' + g.window + ' · convergent ' + g.convergent,
          desc: 'Arithmetic inequality at convergent (' + g.convergent + ') of log_2 3, validated by native_decide.',
          url: 'lemmes/',
          keywords: ['cf_gap', 'cf gap', g.name, 'W' + g.window, g.convergent, 'native_decide', 'continued fraction'].join(' ').toLowerCase()
        });
      });
    }
    if (SEARCH_LEMMES && SEARCH_LEMMES.postJarArsenal && SEARCH_LEMMES.postJarArsenal.files) {
      SEARCH_LEMMES.postJarArsenal.files.forEach(f => {
        SEARCH_INDEX.push({
          type: 'postjar',
          id: f.name,
          title: f.name,
          subtitle: 'PostJAR file · ' + f.theoremCount + ' theorems',
          desc: (f.en || f.fr || '').substring(0, 140),
          url: 'lemmes/',
          keywords: [f.name, f.en, f.fr, 'PostJAR', 'R34-R96', 'arsenal'].filter(Boolean).join(' ').toLowerCase()
        });
      });
    }
    // Pages
    SEARCH_INDEX.push(
      { type: 'page', id: '/', title: 'Home — Cartography', subtitle: 'Page · Main entry', desc: '35 approaches, 3 axiom pillars, the lock Λ_{S,k}', url: 'index.html', keywords: 'home cartography main lambda lock baker barina hercher' },
      { type: 'page', id: '/preuve/', title: 'Proof chain', subtitle: 'Page · Lean 4 architecture', desc: 'Phase52 → Phase58 → Phase59 → Phase63', url: 'preuve/', keywords: 'proof chain phase52 phase58 phase59 phase63 steiner barina continued fractions' },
      { type: 'page', id: '/papers/', title: 'Papers pipeline', subtitle: 'Page · 1 preprint + drafts', desc: 'Preprint (Zenodo DOI) + drafts in progress', url: 'papers/', keywords: 'papers pipeline preprint zenodo drafts' },
      { type: 'page', id: '/lemmes/', title: 'Lean catalog', subtitle: 'Page · 7 central + auxiliaries + cf_gaps + PostJAR', desc: 'Catalog of all Lean 4 theorems', url: 'lemmes/', keywords: 'lean catalog theorems central auxiliary cf_gap postjar arsenal' }
    );
    return SEARCH_INDEX;
  }

  function searchScore(query, item) {
    const q = query.toLowerCase().trim();
    if (!q) return 0;
    const tokens = q.split(/\s+/).filter(Boolean);
    let score = 0;
    for (const tok of tokens) {
      if (item.id.toLowerCase().includes(tok)) score += 50;
      if (item.title.toLowerCase().includes(tok)) score += 30;
      if (item.subtitle.toLowerCase().includes(tok)) score += 10;
      if ((item.desc || '').toLowerCase().includes(tok)) score += 5;
      if (item.keywords.includes(tok)) score += 8;
      // Match exact ID = bonus
      if (item.id.toLowerCase() === tok) score += 100;
    }
    return score;
  }

  function getBaseHref() {
    // Calcule la base relative pour les liens internes selon la page courante
    const path = location.pathname;
    if (path.endsWith('/preuve/') || path.endsWith('/papers/') || path.endsWith('/lemmes/')) return '../';
    return '';
  }

  async function openSearchPalette() {
    await ensureSearchIndex();
    if (document.getElementById('searchPalette')) {
      document.getElementById('searchPalette').classList.add('active');
      document.getElementById('searchInputPalette')?.focus();
      return;
    }
    const dict = t[STATE.lang];
    const html = `
      <div class="modal-overlay" id="searchPalette" role="dialog" aria-modal="true">
        <div class="search-palette">
          <div class="search-input-wrap">
            <span class="search-icon" aria-hidden="true">⌕</span>
            <input id="searchInputPalette" type="search" autocomplete="off" spellcheck="false"
                   placeholder="${dict.searchPalettePlaceholder || 'Search theorems, approaches, pages…'}"
                   aria-label="${dict.searchPalettePlaceholder || 'Search'}">
            <kbd class="search-esc">ESC</kbd>
          </div>
          <div id="searchResults" class="search-results" role="listbox"></div>
          <div class="search-footer">
            <span><kbd>↑</kbd><kbd>↓</kbd> ${dict.searchNav || 'navigate'}</span>
            <span><kbd>↵</kbd> ${dict.searchOpen || 'open'}</span>
            <span><kbd>ESC</kbd> ${dict.searchClose || 'close'}</span>
          </div>
        </div>
      </div>
    `;
    document.body.insertAdjacentHTML('beforeend', html);
    const overlay = document.getElementById('searchPalette');
    const input = document.getElementById('searchInputPalette');
    const results = document.getElementById('searchResults');
    let activeIdx = 0;

    function renderResults(items) {
      activeIdx = 0;
      if (!items.length) {
        results.innerHTML = `<div class="search-empty">${dict.searchEmpty || 'No results'}</div>`;
        return;
      }
      results.innerHTML = items.map((it, i) => `
        <div class="search-result ${i === 0 ? 'active' : ''}" role="option" data-idx="${i}">
          <div class="search-result-type">${it.type}</div>
          <div class="search-result-body">
            <div class="search-result-title">${escapeHtml(it.title)}</div>
            <div class="search-result-subtitle">${escapeHtml(it.subtitle)}</div>
            ${it.desc ? `<div class="search-result-desc">${escapeHtml(it.desc)}</div>` : ''}
          </div>
        </div>
      `).join('');
      results.querySelectorAll('.search-result').forEach(el => {
        el.addEventListener('click', () => {
          activeIdx = parseInt(el.dataset.idx, 10);
          openResult(items[activeIdx]);
        });
        el.addEventListener('mouseenter', () => {
          results.querySelectorAll('.search-result').forEach(r => r.classList.remove('active'));
          el.classList.add('active');
          activeIdx = parseInt(el.dataset.idx, 10);
        });
      });
    }

    function openResult(item) {
      overlay.classList.remove('active');
      const base = getBaseHref();
      let href = base + item.url;
      // Pour les pistes : naviguer vers la home + ouvrir la modale
      if (item.type === 'piste' && STATE.data) {
        const piste = STATE.data.pistes.find(p => p.id === item.id);
        if (piste && location.pathname.match(/\/(index\.html)?$/)) {
          // Sur la home : ouvrir directement le modal piste
          if (typeof openPisteModal === 'function') openPisteModal(piste);
          return;
        }
      }
      location.href = href;
    }

    function doSearch(query) {
      const q = (query || '').trim();
      if (!q) {
        renderResults(SEARCH_INDEX.filter(it => it.type === 'page'));
        return;
      }
      const scored = SEARCH_INDEX
        .map(it => ({ ...it, _s: searchScore(q, it) }))
        .filter(it => it._s > 0)
        .sort((a, b) => b._s - a._s)
        .slice(0, 12);
      renderResults(scored);
    }

    input.addEventListener('input', () => doSearch(input.value));

    input.addEventListener('keydown', (e) => {
      const items = results.querySelectorAll('.search-result');
      if (e.key === 'ArrowDown') {
        e.preventDefault();
        activeIdx = Math.min(activeIdx + 1, items.length - 1);
        items.forEach((el, i) => el.classList.toggle('active', i === activeIdx));
        items[activeIdx]?.scrollIntoView({ block: 'nearest' });
      } else if (e.key === 'ArrowUp') {
        e.preventDefault();
        activeIdx = Math.max(activeIdx - 1, 0);
        items.forEach((el, i) => el.classList.toggle('active', i === activeIdx));
        items[activeIdx]?.scrollIntoView({ block: 'nearest' });
      } else if (e.key === 'Enter') {
        e.preventDefault();
        const item = items[activeIdx];
        if (item) item.click();
      } else if (e.key === 'Escape') {
        overlay.classList.remove('active');
      }
    });

    overlay.addEventListener('click', e => {
      if (e.target.id === 'searchPalette') overlay.classList.remove('active');
    });

    // Initial : montre les 4 pages
    doSearch('');
    overlay.classList.add('active');
    setTimeout(() => input.focus(), 50);
  }

  function escapeHtml(str) {
    return String(str).replace(/[&<>"']/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
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

      // Main result is always pinned at top (ignores status filter, respects search)
      const isMain = p.status === 'main';
      if (!matchSearch) return;
      if (!isMain && !matchStatus) return;
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
    if (!grid || !STATE.data || !Array.isArray(STATE.data.tests)) return;
    const dict = STATE.lang;
    grid.innerHTML = '';

    STATE.data.tests.forEach(test => {
      const localized = test[dict] || test.fr || test.en || {};
      const isWarning = test.exit !== 0;
      const div = document.createElement('div');
      div.className = 'test-card' + (isWarning ? ' warning' : '');
      div.innerHTML = `
        <div class="test-id">${test.id || '—'} ${isWarning ? '⚠' : '✓'}</div>
        <div class="test-title">${localized.title || ''}</div>
        <div class="test-desc">${localized.result || ''}</div>
        <div class="test-file">${test.file || ''}</div>
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
      { id: '#23', sev: '9', title: '3 références inventées', rule: 'Vérifier toute référence par grep direct sur references.bib.' },
      { id: '#26', sev: '6', title: 'Migration domaine : robots.txt + sitemap.xml obsolètes', rule: 'Migration de domaine ⇒ checklist post-migration : sitemap, robots, JSON-LD, OG image, hreflang, canonical, redirects 301.' },
      { id: '#27', sev: '7', title: 'Annonces de conférences/cibles présomptueuses sur /papers/', rule: 'Humilité scientifique : ne jamais annoncer publiquement de conférence ou venue ciblée sans soumission ferme. On peut mentionner "en cours d\'écriture / de formalisation / à explorer", jamais "Cible : AITP 2026".' },
      { id: '#28', sev: '8', title: 'BakerSeparation k^6 plus strict que littérature publiée', rule: 'Toute borne diophantienne effective utilisée comme axiome doit être validée contre la littérature (Rhin 1987 exp 13.3, Wu 2003 μ=7.6155, Simons-de Weger 2005 exp 13.3). Si l\'exposant est plus strict, le déclarer explicitement comme hypothèse de travail dans le doc-comment Lean + abstract JSON-LD + paper §4. La borne (2^s − 3^k)·k^6 ≥ 3^k n\'est attestée par AUCUNE source publiée et doit être tracée comme hypothèse. <strong>Suite formelle</strong> : <a href="https://github.com/ericmerle3789/collatz-conditional-cycles/tree/study/delta10-barina-replacement-impossibility" target="_blank" rel="noopener">δ10 cartographic impossibility lemma</a> (Phase 64, kernel-checked Lean 4, axiom profile <code>[propext]</code>) prouve que la cartographie publiée NE PEUT PAS donner un remplaçant Barina-free, justifiant la nécessité de la force k^6.' }
      , { id: '#29', sev: '5', title: 'papers/index.html présentait Salikhov 2007 et Wu 2003 comme équivalents pour k ≤ 3732', rule: 'Vérifier l\'exact k_max de chaque borne diophantienne avant de présenter plusieurs papers comme équivalents. Salikhov 2007 ferme k ≤ 3693 (μ=5.125 asymptotique mais constante effective trop large) ; Wu 2003 ferme k ≤ 3732 (c=5.117 effective). <strong>Suite formelle</strong> : <a href="https://github.com/ericmerle3789/collatz-conditional-cycles/tree/study/E1-salikhov-2007-impossibility" target="_blank" rel="noopener">δ11 Salikhov-Insufficient-for-3732</a> (Phase 65, kernel-3 + 3 axiomes ad-hoc transparents).' }
      , { id: '#30', sev: '6', title: 'Wu & Wang 2014 (μ ≤ 5.116) absent du registre pistes.json', rule: 'Le registre <code>pistes.json</code> doit contenir TOUTES les bornes d\'irrationalité de log 3 publiées et pertinentes. Wu &amp; Wang 2014 (J. Number Theory 142, 264-273, DOI <a href="https://doi.org/10.1016/j.jnt.2014.03.007" target="_blank" rel="noopener">10.1016/j.jnt.2014.03.007</a>, μ ≤ 5.1163051) raffine Salikhov 2007 et était omis du registre initial. Procédure : audit semestriel littérature diophantienne effective + ajout entrée dédiée par référence. Découvert par Gemini Pro 3.1 lors du brainstorming G1, confirmé par Session D Agent background + Session A CrossRef API.' }
      , { id: '#31', sev: '7', title: 'DOI Wu & Wang 2014 initialement erroné dans PROVENANCE_DELTA11.md', rule: 'Tout DOI cité dans documentation Lean ou audit doit être vérifié indépendamment via CrossRef API ou source d\'autorité publique avant publication. Erreur initiale <code>10.1016/j.jnt.2014.03.004</code> (= Anglès-Pellarin 2014 « Functional identities for L-series ») corrigée en <code>10.1016/j.jnt.2014.03.007</code> (= Wu &amp; Wang 2014 « On the irrationality measure of log 3 ») suite à audit ChatGPT G3 RT shadow + verification CrossRef API. <strong>Leçon</strong> : valeur du cross-modèle (Opus a halluciné, ChatGPT a catché). <strong>Workflow recommandé</strong> : <code>curl -s api.crossref.org/works/&lt;DOI&gt;</code> + python parsing pour chaque référence avant publication.' }
      , { id: '#32', sev: '8', title: 'axiom C_Salikhov : ℝ initialement non positivement restreint dans Delta11Salikhov.lean', rule: 'Tout axiome déclarant une constante d\'origine arithmétique/diophantienne dans Lean doit explicitement déclarer son signe (positivité, négativité) sous peine de rendre les théorèmes utilisateurs vacuously-true. Erreur initiale <code>axiom C_Salikhov : ℝ</code> permettait C ≤ 0 → théorème δ11 vacuously-true (négatif &lt; positif). Corrigé Phase 5e par ajout de <code>axiom C_Salikhov_pos : 0 &lt; C_Salikhov</code> (convention diophantienne effective Salikhov 2007 explicitée). Catché par <strong>Gemini Pro 3.1 ARES shadow Deep Research</strong> (G3 cross-modèle), invisible aux 5 IAs précédentes (Session D RT/NASA/ARES sub-agents Opus + ChatGPT G3 RT shadow + Claude.ai G3 NASA shadow). <strong>Leçon méthodologique</strong> : 2ème catch cross-modèle (après mea culpa #31), validation empirique du Niveau 2 anti-corrélation. <strong>Workflow recommandé</strong> : pour chaque <code>axiom X : T</code> futur, audit cross-modèle dédié sur le typage T (positivité, monotonie, contraintes implicites de domaine).' }
    ] : [
      { id: '#3', sev: '9', title: 'R76b naming "at_min"', rule: 'Naming reflects the exact claim, not the intent.' },
      { id: '#11', sev: '10', title: 'BHV+lacunary conjecture', rule: 'Test R72 (Steiner identity) before any commit.' },
      { id: '#13', sev: '7.5', title: 'Wu 2003 without reading obstruction-I', rule: 'Read paper/v2/05-obstruction-I BEFORE proposing Baker/Wu.' },
      { id: '#14', sev: '—', title: 'Bibliography ≠ proper study', rule: 'Never cite a reference without direct verification.' },
      { id: '#16', sev: '—', title: 'Over-assertion without epistemic tags', rule: 'Mandatory tags [VERIFIED]/[PARTIAL]/[SPECULATIVE]/[UNKNOWN].' },
      { id: '#19', sev: '8', title: 'Inverted Wu vs Salikhov hierarchy', rule: 'Numerically test all bounds (Python script).' },
      { id: '#20', sev: '10', title: 'log|ρ| formula nuanced', rule: 'Mandatory SymPy test for any mathematical formula.' },
      { id: '#22', sev: '8', title: 'Underestimating δ8 lemma', rule: "Test any Baker+CF+Khinchin combination against δ8/δ8'." },
      { id: '#23', sev: '9', title: '3 fabricated references', rule: 'Verify every reference via direct grep on references.bib.' },
      { id: '#26', sev: '6', title: 'Domain migration: robots.txt + sitemap.xml stale', rule: 'Domain migration ⇒ post-migration checklist: sitemap, robots, JSON-LD, OG image, hreflang, canonical, 301 redirects.' },
      { id: '#27', sev: '7', title: 'Presumptuous conference/venue announcements on /papers/', rule: 'Scientific humility: never publicly announce a conference or target venue without firm submission. Use "drafting / under formalization / to explore" instead, never "Target: AITP 2026".' },
      { id: '#28', sev: '8', title: 'BakerSeparation k^6 stricter than published bounds', rule: 'Any effective Diophantine bound used as an axiom must be validated against published literature (Rhin 1987 exp 13.3, Wu 2003 μ=7.6155, Simons-de Weger 2005 exp 13.3). If the exponent is stricter, declare it explicitly as a working hypothesis in the Lean doc-comment + JSON-LD abstract + paper §4. The bound (2^s − 3^k)·k^6 ≥ 3^k is attested by NO published source and must be tracked as a hypothesis. <strong>Formal follow-up</strong>: <a href="https://github.com/ericmerle3789/collatz-conditional-cycles/tree/study/delta10-barina-replacement-impossibility" target="_blank" rel="noopener">δ10 cartographic impossibility lemma</a> (Phase 64, kernel-checked Lean 4, axiom profile <code>[propext]</code>) proves that the published catalogue CANNOT provide a Barina-free replacement, justifying the necessity of the k^6 strength.' }
      , { id: '#29', sev: '5', title: 'papers/index.html presented Salikhov 2007 and Wu 2003 as equivalent for k ≤ 3732', rule: 'Verify exact k_max of each Diophantine bound before presenting multiple papers as equivalent. Salikhov 2007 closes k ≤ 3693 (μ=5.125 asymptotic but effective constant too large) ; Wu 2003 closes k ≤ 3732 (c=5.117 effective). <strong>Formal follow-up</strong>: <a href="https://github.com/ericmerle3789/collatz-conditional-cycles/tree/study/E1-salikhov-2007-impossibility" target="_blank" rel="noopener">δ11 Salikhov-Insufficient-for-3732</a> (Phase 65, kernel-3 + 3 transparent ad-hoc axioms).' }
      , { id: '#30', sev: '6', title: 'Wu & Wang 2014 (μ ≤ 5.116) absent from pistes.json registry', rule: 'The <code>pistes.json</code> registry must contain ALL relevant published log 3 irrationality bounds. Wu &amp; Wang 2014 (J. Number Theory 142, 264-273, DOI <a href="https://doi.org/10.1016/j.jnt.2014.03.007" target="_blank" rel="noopener">10.1016/j.jnt.2014.03.007</a>, μ ≤ 5.1163051) refines Salikhov 2007 and was omitted from the initial registry. Procedure: semi-annual audit of effective Diophantine literature + dedicated entry per reference. Discovered by Gemini Pro 3.1 during G1 brainstorm, confirmed by Session D Agent background + Session A CrossRef API.' }
      , { id: '#31', sev: '7', title: 'Wu & Wang 2014 DOI initially wrong in PROVENANCE_DELTA11.md', rule: 'Every DOI cited in Lean documentation or audit must be verified independently via CrossRef API or authoritative public source before publication. Initial error <code>10.1016/j.jnt.2014.03.004</code> (= Anglès-Pellarin 2014 "Functional identities for L-series") corrected to <code>10.1016/j.jnt.2014.03.007</code> (= Wu &amp; Wang 2014 "On the irrationality measure of log 3") following ChatGPT G3 RT shadow audit + CrossRef API verification. <strong>Lesson</strong>: value of cross-model audit (Opus hallucinated, ChatGPT caught). <strong>Recommended workflow</strong>: <code>curl -s api.crossref.org/works/&lt;DOI&gt;</code> + python parsing for each reference before publication.' }
      , { id: '#32', sev: '8', title: 'axiom C_Salikhov : ℝ initially not positively restricted in Delta11Salikhov.lean', rule: 'Every Lean axiom declaring an arithmetic/Diophantine-origin constant must explicitly declare its sign (positivity, negativity) or risk making downstream theorems vacuously-true. Initial error <code>axiom C_Salikhov : ℝ</code> allowed C ≤ 0 → δ11 theorem vacuously-true (negative &lt; positive). Fixed in Phase 5e by adding <code>axiom C_Salikhov_pos : 0 &lt; C_Salikhov</code> (Salikhov 2007 effective Diophantine convention made explicit). Caught by <strong>Gemini Pro 3.1 ARES shadow Deep Research</strong> (G3 cross-model), invisible to all 5 previous AIs (Session D RT/NASA/ARES Opus sub-agents + ChatGPT G3 RT shadow + Claude.ai G3 NASA shadow). <strong>Methodological lesson</strong>: 2nd cross-model catch (after mea culpa #31), empirical validation of Level-2 anti-correlation. <strong>Recommended workflow</strong>: for every future <code>axiom X : T</code>, dedicated cross-model audit on typing T (positivity, monotonicity, implicit domain constraints).' }
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

  // ========== STICKY TABLE OF CONTENTS ==========
  // Génère une TOC latérale auto à partir des h2 visibles dans <main>,
  // highlight la section courante via IntersectionObserver.
  function initTableOfContents() {
    const main = document.querySelector('main');
    if (!main) return;
    // Récupère les h2/h3 visibles (pas hidden, pas wrapped dans hidden parent)
    const headings = Array.from(main.querySelectorAll('h2, h3')).filter(h => {
      // Skip headings dans hero, hero-banner ou cachés par lang
      if (h.closest('.hero, .hero-banner, .modal, .search-palette')) return false;
      if (h.hidden) return false;
      // Skip si parent en lang fr et current state en
      const langParent = h.closest('[lang]');
      if (langParent && langParent !== document.documentElement) {
        if (langParent.getAttribute('lang') !== STATE.lang) return false;
      }
      return true;
    });
    if (headings.length < 3) return; // pas assez pour une TOC

    // Remove précédente
    document.querySelector('.toc')?.remove();

    // Donne un id si manquant
    headings.forEach((h, i) => {
      if (!h.id) {
        const slug = (h.textContent || '').toLowerCase()
          .replace(/[^\w\s-]/g, '').replace(/\s+/g, '-').substring(0, 40);
        h.id = slug || ('section-' + i);
      }
    });

    const tocLabel = STATE.lang === 'fr' ? 'Sommaire' : 'On this page';
    const toc = document.createElement('nav');
    toc.className = 'toc';
    toc.setAttribute('aria-label', tocLabel);
    toc.innerHTML = `
      <div class="toc-title">${tocLabel}</div>
      <ul class="toc-list">
        ${headings.map(h => `
          <li class="toc-item">
            <a href="#${h.id}" class="toc-link toc-${h.tagName.toLowerCase()}">${h.textContent.replace(/^§\s*[IVX]+(\.\w+)?\s*[—-]\s*/, '')}</a>
          </li>
        `).join('')}
      </ul>
    `;
    document.body.appendChild(toc);

    // Smooth scroll on click
    toc.querySelectorAll('a').forEach(a => {
      a.addEventListener('click', e => {
        e.preventDefault();
        const target = document.querySelector(a.getAttribute('href'));
        target?.scrollIntoView({ behavior: 'smooth', block: 'start' });
      });
    });

    // IntersectionObserver pour highlight + maj progress dot sur barre collapsée
    const links = new Map();
    toc.querySelectorAll('a').forEach(a => {
      const id = a.getAttribute('href').substring(1);
      links.set(id, a);
    });
    const headingOrder = headings.map(h => h.id);
    function updateProgressDot(activeId) {
      const idx = headingOrder.indexOf(activeId);
      if (idx >= 0) {
        const ratio = idx / Math.max(headingOrder.length - 1, 1);
        toc.style.setProperty('--toc-progress', ratio);
      }
    }
    const obs = new IntersectionObserver((entries) => {
      entries.forEach(e => {
        const link = links.get(e.target.id);
        if (!link) return;
        if (e.isIntersecting) {
          links.forEach(l => l.classList.remove('active'));
          link.classList.add('active');
          updateProgressDot(e.target.id);
        }
      });
    }, { rootMargin: '-15% 0px -70% 0px' });
    headings.forEach(h => obs.observe(h));
  }

  // ========== LAST COMMIT (footer) ==========
  async function fetchLastCommit() {
    const el = document.getElementById('lastCommitDate');
    if (!el) return;
    try {
      const cached = sessionStorage.getItem('collatz-lastcommit');
      if (cached) {
        const obj = JSON.parse(cached);
        if (obj.ts && Date.now() - obj.ts < 5 * 60 * 1000) { // 5 min cache
          el.textContent = obj.text;
          return;
        }
      }
      const r = await fetch('https://api.github.com/repos/ericmerle3789/collatz-conditional-cycles/commits/gh-pages', {
        headers: { 'Accept': 'application/vnd.github.v3+json' }
      });
      if (r.ok) {
        const j = await r.json();
        const date = new Date(j.commit?.author?.date || j.commit?.committer?.date);
        const sha7 = (j.sha || '').substring(0, 7);
        const text = `${date.toISOString().substring(0, 10)} · ${sha7}`;
        el.textContent = text;
        sessionStorage.setItem('collatz-lastcommit', JSON.stringify({ ts: Date.now(), text }));
      }
    } catch (e) {
      el.textContent = '—';
    }
  }

  // ========== READING TIME + WORD COUNT ==========
  // Calcule la durée de lecture en min (220 wpm anglais, 200 wpm français)
  function injectReadingMeta() {
    const main = document.querySelector('main');
    if (!main || document.querySelector('.reading-meta')) return;
    const text = main.textContent || '';
    const words = text.trim().split(/\s+/).filter(Boolean).length;
    const wpm = STATE.lang === 'fr' ? 200 : 220;
    const minutes = Math.max(1, Math.round(words / wpm));

    // Insère après le premier .hero-eyebrow ou en haut de main
    const hero = main.querySelector('.hero, .hero-banner');
    if (!hero) return;

    const dict = { fr: { read: 'min de lecture', words: 'mots', verified: 'build vérifié' },
                   en: { read: 'min read', words: 'words', verified: 'build verified' } };
    const d = dict[STATE.lang] || dict.en;
    const meta = document.createElement('div');
    meta.className = 'reading-meta';
    meta.innerHTML = `
      <span class="reading-meta-item">⏱ ${minutes} ${d.read}</span>
      <span class="reading-meta-item">${words.toLocaleString()} ${d.words}</span>
      <span class="reading-meta-item" id="lastVerifiedMeta">⚡ ${d.verified} <span id="lastVerifiedDate">…</span></span>
    `;
    // Insère dans le hero
    const heroContent = hero.querySelector('.hero-eyebrow, .hero-banner-eyebrow');
    if (heroContent && heroContent.parentNode) {
      heroContent.parentNode.insertBefore(meta, heroContent.nextSibling);
    } else {
      hero.insertAdjacentElement('afterend', meta);
    }
  }

  // ========== THEOREM PERMALINKS (hover ¶, click to copy) ==========
  // Ajoute une icône ¶ sur les <code>theorem_name</code> pour copier le permalien
  function injectPermalinks() {
    // Cibler les codes inline qui ressemblent à des noms de théorèmes (snake_case >= 8 chars)
    const codes = document.querySelectorAll('main code');
    codes.forEach(code => {
      const txt = code.textContent.trim();
      if (txt.length < 8 || code.classList.contains('language-bash') || code.classList.contains('language-lean')) return;
      if (!/^[a-z][a-z0-9_]*[a-z0-9]$/.test(txt)) return; // snake_case identifier
      if (code.parentElement?.classList.contains('has-permalink')) return; // déjà fait

      const wrap = document.createElement('span');
      wrap.className = 'has-permalink';
      const link = document.createElement('a');
      link.href = '#' + txt;
      link.className = 'permalink-icon';
      link.textContent = '¶';
      link.title = 'Copy permalink';
      link.setAttribute('aria-label', 'Copy permalink to ' + txt);
      link.addEventListener('click', async (e) => {
        e.preventDefault();
        const url = location.origin + location.pathname + '#' + txt;
        try {
          await navigator.clipboard.writeText(url);
          showPermalinkToast(STATE.lang === 'fr' ? 'Permalien copié ✓' : 'Permalink copied ✓');
          history.replaceState(null, '', '#' + txt);
        } catch (err) {
          location.hash = '#' + txt;
        }
      });
      code.parentNode.insertBefore(wrap, code);
      wrap.appendChild(code);
      wrap.appendChild(link);
      // Ajoute id sur le code pour deep linking
      if (!code.id) code.id = txt;
    });
  }

  function showPermalinkToast(msg) {
    const old = document.querySelector('.permalink-copied');
    if (old) old.remove();
    const toast = document.createElement('div');
    toast.className = 'permalink-copied';
    toast.textContent = msg;
    document.body.appendChild(toast);
    setTimeout(() => toast.remove(), 2000);
  }

  // ========== READING FOCUS MODE (touche F) ==========
  function setupFocusMode() {
    let active = null;
    function findActiveSection() {
      const sections = Array.from(document.querySelectorAll('main section, main article'));
      let best = null, bestRatio = 0;
      const vh = window.innerHeight;
      for (const s of sections) {
        const r = s.getBoundingClientRect();
        const visible = Math.min(r.bottom, vh) - Math.max(r.top, 0);
        const ratio = Math.max(0, visible / Math.min(r.height, vh));
        if (ratio > bestRatio) { bestRatio = ratio; best = s; }
      }
      return best;
    }
    function toggleFocus() {
      const html = document.documentElement;
      if (html.dataset.focusMode === 'on') {
        html.removeAttribute('data-focus-mode');
        document.querySelectorAll('.focus-active').forEach(e => e.classList.remove('focus-active'));
        showPermalinkToast(STATE.lang === 'fr' ? 'Mode focus désactivé' : 'Focus mode off');
      } else {
        html.dataset.focusMode = 'on';
        const active = findActiveSection();
        if (active) active.classList.add('focus-active');
        showPermalinkToast(STATE.lang === 'fr' ? 'Mode focus activé · F pour quitter' : 'Focus mode on · F to exit');
      }
    }
    function updateActive() {
      if (document.documentElement.dataset.focusMode !== 'on') return;
      document.querySelectorAll('.focus-active').forEach(e => e.classList.remove('focus-active'));
      const a = findActiveSection();
      if (a) a.classList.add('focus-active');
    }
    document.addEventListener('keydown', e => {
      const tag = (e.target.tagName || '').toLowerCase();
      if (tag === 'input' || tag === 'textarea' || e.target.isContentEditable) return;
      if (e.key === 'f' || e.key === 'F') {
        if (e.metaKey || e.ctrlKey || e.altKey) return;
        e.preventDefault();
        toggleFocus();
      }
    });
    window.addEventListener('scroll', updateActive, { passive: true });
  }

  // ========== THEME CYCLE (dark → light → sepia → dark) ==========
  // Override le toggleTheme pour cycler 3 thèmes
  const THEME_CYCLE = ['dark', 'light', 'sepia'];
  function toggleThemeCycle() {
    const current = STATE.theme || 'dark';
    const idx = THEME_CYCLE.indexOf(current);
    STATE.theme = THEME_CYCLE[(idx + 1) % THEME_CYCLE.length];
    localStorage.setItem('collatz-theme', STATE.theme);
    applyTheme();
    const dict = { fr: { dark: 'Sombre', light: 'Clair', sepia: 'Sépia' },
                   en: { dark: 'Dark', light: 'Light', sepia: 'Sepia' } };
    showPermalinkToast((dict[STATE.lang] || dict.en)[STATE.theme]);
  }

  // ========== GITHUB STARS COUNTER (cache 1h via localStorage) ==========
  async function fetchGitHubStars() {
    const el = document.getElementById('githubStars');
    if (!el) return;
    try {
      const cached = localStorage.getItem('gh-stars-cache');
      if (cached) {
        const obj = JSON.parse(cached);
        if (Date.now() - obj.ts < 60 * 60 * 1000) {
          el.textContent = obj.stars;
          return;
        }
      }
      const r = await fetch('https://api.github.com/repos/ericmerle3789/collatz-conditional-cycles');
      if (r.ok) {
        const j = await r.json();
        const stars = j.stargazers_count || 0;
        el.textContent = stars;
        localStorage.setItem('gh-stars-cache', JSON.stringify({ ts: Date.now(), stars }));
      }
    } catch (e) { el.textContent = '—'; }
  }

  // ========== LAST VERIFIED (date du dernier commit main) ==========
  async function fetchLastVerified() {
    const el = document.getElementById('lastVerifiedDate');
    if (!el) return;
    try {
      const cached = sessionStorage.getItem('gh-mainsha-cache');
      if (cached) {
        const obj = JSON.parse(cached);
        if (Date.now() - obj.ts < 30 * 60 * 1000) {
          el.textContent = obj.date;
          return;
        }
      }
      const r = await fetch('https://api.github.com/repos/ericmerle3789/collatz-conditional-cycles/commits/main');
      if (r.ok) {
        const j = await r.json();
        const date = (j.commit?.committer?.date || j.commit?.author?.date || '').substring(0, 10);
        const sha = (j.sha || '').substring(0, 7);
        const text = `${date} · ${sha}`;
        el.textContent = text;
        sessionStorage.setItem('gh-mainsha-cache', JSON.stringify({ ts: Date.now(), date: text }));
      }
    } catch (e) { el.textContent = '—'; }
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
      // Cache buster aligné avec celui du <script> courant pour invalider le
      // cache HTTP du JSON dès qu'une release modifie le pistes.json
      // (sinon les utilisateurs continuent à voir l'ancien snapshot — bug catché
      // post-Phase 7-ter via test UX Chrome MCP, 2026-05-08)
      const scriptSrc = document.currentScript?.src
        || Array.from(document.querySelectorAll('script[src*="main.js"]')).map(s => s.src)[0]
        || '';
      const cacheBuster = scriptSrc.match(/\?v=([^&]+)/)?.[1] || Date.now();
      const resp = await fetch(base + 'data/pistes.json?v=' + cacheBuster);
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
    document.getElementById('themeBtn')?.addEventListener('click', toggleThemeCycle);
    document.getElementById('citeBtn')?.addEventListener('click', openCiteModal);
    document.getElementById('printBtn')?.addEventListener('click', () => window.print());

    // Raccourci clavier : 'C' ouvre la modale citation (sauf en input)
    document.addEventListener('keydown', e => {
      const tag = (e.target.tagName || '').toLowerCase();
      const inInput = tag === 'input' || tag === 'textarea' || e.target.isContentEditable;
      // Cmd+K / Ctrl+K → palette de recherche
      if ((e.key === 'k' || e.key === 'K') && (e.metaKey || e.ctrlKey)) {
        e.preventDefault();
        openSearchPalette();
        return;
      }
      // '/' (slash) → palette de recherche (style GitHub)
      if (e.key === '/' && !inInput && !e.metaKey && !e.ctrlKey && !e.altKey) {
        e.preventDefault();
        openSearchPalette();
        return;
      }
      // 'C' → citation
      if ((e.key === 'c' || e.key === 'C') && !e.metaKey && !e.ctrlKey && !e.altKey) {
        if (inInput) return;
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

    // Last commit info (footer)
    fetchLastCommit();

    // TOC sticky : init après applyLang pour avoir les bons headings
    setTimeout(initTableOfContents, 200);

    // Reading meta + permalinks + focus mode + GitHub stars + last verified
    setTimeout(injectReadingMeta, 250);
    setTimeout(injectPermalinks, 300);
    setupFocusMode();
    fetchGitHubStars();
    fetchLastVerified();

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

// C22 (Phase 3.5 F-θ): scroll auto + ouverture details post-hash navigation
// Détecté UX MCP A2 runtime — DOM ancres FAQ q1-q12 OK (C20) mais browser ne scrolle pas auto post-click sur ../faq/#qN
(function() {
  function scrollToHashTarget() {
    if (!window.location.hash) return;
    const target = document.querySelector(window.location.hash);
    if (target?.tagName === 'DETAILS') {
      target.setAttribute('open', '');
      target.scrollIntoView({behavior: 'instant', block: 'start'});
    }
  }
  window.addEventListener('hashchange', scrollToHashTarget);
  window.addEventListener('load', () => setTimeout(scrollToHashTarget, 100));
})();
