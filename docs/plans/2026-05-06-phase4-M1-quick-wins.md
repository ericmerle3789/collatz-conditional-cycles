# Phase 4 M1 — Quick Wins Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Livrer M1 du roadmap Phase 4 hybride : #14 GitHub Discussions activation + #15 Modal Citer 3 onglets BibTeX/RIS/APA + ADR-0001 capturant la décision approche hybride.

**Architecture:** Site statique HTML/CSS/JS bilingue inline. Modal injecté dynamiquement par JS (pas de duplication 11 pages). GitHub Discussions = option native côté repo settings (action manuelle Chrome MCP ou Eric direct). ADR = doc markdown audit decision.

**Tech Stack:** HTML5 `<dialog>` natif, CSS modal styles, JavaScript clipboard API (`navigator.clipboard.writeText`), i18n existant Pattern B (`STATE.lang`), data Schema.org JSON-LD existant.

---

## Tasks overview

| Task | Sujet | Effort estimé | Bloquant |
|---|---|---|---|
| 1 | ADR-0001 création | 15 min | Non |
| 2 | #15 Modal Citer HTML structure | 30 min | Non |
| 3 | #15 Modal Citer CSS styles | 30 min | Non |
| 4 | #15 Modal Citer JS logic + clipboard | 60 min | Non |
| 5 | #15 i18n keys FR/EN | 15 min | Non |
| 6 | #14 GitHub Discussions activation | 15-20 min | Eric login GitHub |
| 7 | Cache buster bump 11 pages | 5 min | Non |
| 8 | UX MCP runtime test localhost | 15 min | Dev server actif |
| 9 | Commit C36 M1 + audit C indépendant | 10 min | Non |
| 10 | Push origin + UX live test | 10 min | Eric chat OK ou autonomie A+C maintenue |

**Total ETA** : ~3h30 (cohérent estimation 090 §6).

---

## Task 1 — ADR-0001 création

**Files:**
- Create: `/Users/ericmerle/Documents/collatz-gh-pages/docs/adr/2026-05-06-phase4-hybrid-cluster-storytelling.md`

**Step 1.1: Écrire ADR-0001 contenu (template Michael Nygard 2011)**

Contenu (copier verbatim) :

```markdown
# ADR-0001 — Phase 4 : Approche hybride « clusters cohérents »

**Date** : 2026-05-06
**Statut** : Accepté
**Auteurs** : Session A + Session C (validation proxy user, Eric chat 2026-05-06 15:25 « En autonomie avec session C »)

## Contexte

Le 2026-05-06 chat 15:18, Eric livre 7 idées de génie pour Phase 4 : #11 Behind the proof (1-2j, ★★★★★), #12 Lean playground (3-5j, ★★★★), #13 Newsletter (5h, ★★★★★, ✅ pré-validée), #14 GitHub Discussions (15 min, ★★★★), #15 Modal Citer (3h, ★★★★), #16 Wikipedia (2h, ★★★★★, post-JAR), #17 Carte postale (2-3h, ★★★).

Phase 3.6 + 3.7 α SHIPPED le matin, β monitoring 7-14j en arrière-plan (calendar 2026-05-13 + 2026-05-20). 3 approches d'ordonnancement possibles : séquentiel strict, parallèle agressif, hybride clusters.

Eric chat 15:25 délègue validation à C (proxy user role HARD-GATE brainstorming skill).

## Décision

Adopter **approche hybride « clusters cohérents »** :

- **M1 J+0 (today, 2026-05-06)** — Quick wins burst (parallèle car indépendants)
  - #14 GitHub Discussions (15 min, ROI extrême)
  - #15 Modal Citer (3h, alimente #16 futur)
- **M2 J+7 (2026-05-13)** — Cluster Storytelling start
  - #11 Behind the proof (1-2j, hub central narratif voix Eric)
- **M3 J+14 (2026-05-20)** — Cluster Storytelling end
  - #17 Carte postale PNG (2-3h, alimenté visuels #11)
  - #13 Newsletter setup (5h, 1er numéro = #11 distillé)
- **M4 post-JAR acceptation** — Parking lot
  - #16 Wikipedia (2h, déclencheur externe)
- **M5 sprint dédié post-M3** — Marathon
  - #12 Lean playground (3-5j, sandbox isolé)

## Conséquences

- ✅ Charge cognitive maîtrisée (★★ modérée, 1 cluster = 1 thème)
- ✅ Quick wins immédiats M1 (momentum + sentiment shipped)
- ✅ Cluster Storytelling cohérent (effet vague communication)
- ✅ Marathon technique séparé (pas de pollution roadmap principale)
- ⚠️ Période #11 (1-2j) sans livraison intermédiaire — patience requise
- ⚠️ Newsletter (#13) dépend de #11 (cascade) — blocage si #11 retardé

## Alternatives considérées

- **Séquentiel strict** : 1 idée à la fois, ~2-3 semaines, perd momentum. Rejeté pour vitesse insuffisante.
- **Parallèle agressif** : tout en parallèle, ~1 semaine, qualité réduite si rush. Rejeté pour charge cognitive ★★★ excessive.

## Références

- Mailbox : `090_A→C` brainstorming + `091_C→A` vote convergent α/α/α/α + `092_A→C` HARD-GATE relâché
- Eric chat 2026-05-06 15:25 « En autonomie avec session C » (proxy validation déléguée)
- Design doc : `docs/plans/2026-05-06-phase4-roadmap-design.md`
- Précédent : Phase 3.6 wrap-up + Phase 3.7 α (tag `v0.7.2`)
```

**Step 1.2: Vérifier markdown valide**

Run: `head -3 docs/adr/2026-05-06-phase4-hybrid-cluster-storytelling.md`
Expected: `# ADR-0001 — Phase 4 : Approche hybride « clusters cohérents »`

**Step 1.3: Pas de commit isolé** (intégré dans C36 M1 final commit Task 9)

---

## Task 2 — #15 Modal Citer HTML structure

**Files:**
- Modify: `/Users/ericmerle/Documents/collatz-gh-pages/assets/js/main.js` (ajouter fonction `createCiteModal()`)

**Step 2.1: Test avant — vérifier que le modal n'existe pas**

Run via Chrome MCP localhost:8080 :
```
Click on #citeBtn in topbar
```
Expected: rien ne se passe (pas de modal défini, citeBtn n'a pas de handler)

**Step 2.2: Ajouter fonction `createCiteModal()` dans main.js**

Localiser la section après `setupBilingualToggle()` ou similaire dans main.js. Ajouter :

```javascript
function createCiteModal() {
  // Avoid duplicate injection
  if (document.getElementById('cite-modal')) return;
  
  const dialog = document.createElement('dialog');
  dialog.id = 'cite-modal';
  dialog.className = 'cite-modal';
  dialog.innerHTML = `
    <div class="cite-modal-inner">
      <header class="cite-modal-header">
        <h3>
          <span lang="fr">Citer ce travail</span>
          <span lang="en">Cite this work</span>
        </h3>
        <button class="cite-modal-close" aria-label="Close">×</button>
      </header>
      <nav class="cite-tabs" role="tablist">
        <button role="tab" class="cite-tab active" data-tab="bibtex" aria-selected="true">BibTeX</button>
        <button role="tab" class="cite-tab" data-tab="ris" aria-selected="false">RIS</button>
        <button role="tab" class="cite-tab" data-tab="apa" aria-selected="false">APA</button>
      </nav>
      <div class="cite-content">
        <pre class="cite-format active" data-format="bibtex">@article{merle2026collatz,
  author  = {Merle, Eric},
  title   = {Conditional theorem on Collatz / Syracuse non-trivial cycles},
  year    = {2026},
  note    = {Submitted to Journal of Automated Reasoning},
  doi     = {10.5281/zenodo.19790406},
  url     = {https://collatz-lab.org/papers/}
}</pre>
        <pre class="cite-format" data-format="ris">TY  - JOUR
AU  - Merle, Eric
TI  - Conditional theorem on Collatz / Syracuse non-trivial cycles
PY  - 2026
DO  - 10.5281/zenodo.19790406
UR  - https://collatz-lab.org/papers/
N1  - Submitted to Journal of Automated Reasoning
ER  -</pre>
        <pre class="cite-format" data-format="apa">Merle, E. (2026). Conditional theorem on Collatz / Syracuse non-trivial cycles. Submitted to Journal of Automated Reasoning. https://doi.org/10.5281/zenodo.19790406</pre>
      </div>
      <footer class="cite-modal-footer">
        <button class="cite-copy-btn">
          <span lang="fr">📋 Copier</span>
          <span lang="en">📋 Copy</span>
        </button>
        <span class="cite-toast" hidden>
          <span lang="fr">Copié !</span>
          <span lang="en">Copied!</span>
        </span>
      </footer>
    </div>
  `;
  document.body.appendChild(dialog);
  return dialog;
}
```

**Step 2.3: Test fail — vérifier que le bouton encore inactif**

Run: ouvrir Chrome MCP localhost:8080, click #citeBtn
Expected: rien (handler pas encore wiré, viendra Task 4)

---

## Task 3 — #15 Modal Citer CSS styles

**Files:**
- Modify: `/Users/ericmerle/Documents/collatz-gh-pages/assets/css/main.css` (ajouter section `.cite-modal`)

**Step 3.1: Ajouter CSS modal en fin de main.css**

Append to main.css :

```css
/* Cite Modal — Phase 4 M1 #15 */
.cite-modal {
  border: 1px solid var(--border);
  border-radius: 8px;
  background: var(--bg-primary);
  color: var(--text-primary);
  max-width: 600px;
  width: 90vw;
  padding: 0;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
}

.cite-modal::backdrop {
  background: rgba(0, 0, 0, 0.5);
  backdrop-filter: blur(4px);
}

.cite-modal-inner {
  display: flex;
  flex-direction: column;
}

.cite-modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem 1.5rem;
  border-bottom: 1px solid var(--border);
}

.cite-modal-header h3 {
  margin: 0;
  font-family: var(--serif);
  font-size: 1.2rem;
}

.cite-modal-close {
  background: none;
  border: none;
  font-size: 1.5rem;
  cursor: pointer;
  color: var(--text-secondary);
  padding: 0;
  width: 32px;
  height: 32px;
  border-radius: 4px;
  transition: background 0.15s;
}

.cite-modal-close:hover {
  background: var(--bg-secondary);
  color: var(--text-primary);
}

.cite-tabs {
  display: flex;
  gap: 0;
  padding: 0 1.5rem;
  border-bottom: 1px solid var(--border);
}

.cite-tab {
  background: none;
  border: none;
  border-bottom: 2px solid transparent;
  padding: 0.75rem 1rem;
  font-family: var(--mono);
  font-size: 0.9rem;
  cursor: pointer;
  color: var(--text-secondary);
  transition: all 0.15s;
}

.cite-tab.active {
  color: var(--accent);
  border-bottom-color: var(--accent);
}

.cite-tab:hover:not(.active) {
  color: var(--text-primary);
}

.cite-content {
  padding: 1.5rem;
  max-height: 50vh;
  overflow-y: auto;
}

.cite-format {
  display: none;
  font-family: var(--mono);
  font-size: 0.85rem;
  background: var(--bg-secondary);
  padding: 1rem;
  border-radius: 4px;
  border-left: 3px solid var(--accent);
  margin: 0;
  white-space: pre-wrap;
  word-break: break-word;
}

.cite-format.active {
  display: block;
}

.cite-modal-footer {
  display: flex;
  justify-content: flex-end;
  align-items: center;
  gap: 1rem;
  padding: 1rem 1.5rem;
  border-top: 1px solid var(--border);
}

.cite-copy-btn {
  background: var(--accent);
  color: white;
  border: none;
  padding: 0.5rem 1rem;
  border-radius: 4px;
  font-family: var(--sans);
  font-weight: 500;
  cursor: pointer;
  transition: opacity 0.15s;
}

.cite-copy-btn:hover {
  opacity: 0.9;
}

.cite-toast {
  color: var(--accent);
  font-size: 0.9rem;
  font-weight: 500;
  animation: cite-toast-fade 2s ease-out forwards;
}

@keyframes cite-toast-fade {
  0%, 80% { opacity: 1; }
  100% { opacity: 0; }
}
```

**Step 3.2: Test rendering CSS**

Run via Chrome MCP localhost:8080, eval JS console :
```javascript
document.body.appendChild(createCiteModal());
document.getElementById('cite-modal').showModal();
```
Expected: modal apparaît avec backdrop blur, 3 tabs visibles, contenu BibTeX par défaut

---

## Task 4 — #15 Modal Citer JS logic + clipboard

**Files:**
- Modify: `/Users/ericmerle/Documents/collatz-gh-pages/assets/js/main.js` (ajouter fonction `wireCiteModal()`)

**Step 4.1: Ajouter logique tabs + copy + close**

Append to main.js après `createCiteModal()` :

```javascript
function wireCiteModal() {
  const citeBtn = document.getElementById('citeBtn');
  if (!citeBtn) return;
  
  citeBtn.addEventListener('click', () => {
    const dialog = createCiteModal();
    if (!dialog) return;
    
    // Wire close button
    const closeBtn = dialog.querySelector('.cite-modal-close');
    closeBtn.addEventListener('click', () => dialog.close());
    
    // Wire backdrop click to close
    dialog.addEventListener('click', (e) => {
      if (e.target === dialog) dialog.close();
    });
    
    // Wire tabs
    const tabs = dialog.querySelectorAll('.cite-tab');
    const formats = dialog.querySelectorAll('.cite-format');
    tabs.forEach(tab => {
      tab.addEventListener('click', () => {
        tabs.forEach(t => {
          t.classList.remove('active');
          t.setAttribute('aria-selected', 'false');
        });
        formats.forEach(f => f.classList.remove('active'));
        tab.classList.add('active');
        tab.setAttribute('aria-selected', 'true');
        const targetFormat = tab.dataset.tab;
        const formatEl = dialog.querySelector(`[data-format="${targetFormat}"]`);
        if (formatEl) formatEl.classList.add('active');
      });
    });
    
    // Wire copy button
    const copyBtn = dialog.querySelector('.cite-copy-btn');
    const toast = dialog.querySelector('.cite-toast');
    copyBtn.addEventListener('click', async () => {
      const activeFormat = dialog.querySelector('.cite-format.active');
      if (!activeFormat) return;
      const text = activeFormat.textContent;
      try {
        await navigator.clipboard.writeText(text);
      } catch (err) {
        // Fallback for older browsers
        const textarea = document.createElement('textarea');
        textarea.value = text;
        document.body.appendChild(textarea);
        textarea.select();
        document.execCommand('copy');
        document.body.removeChild(textarea);
      }
      toast.hidden = false;
      setTimeout(() => { toast.hidden = true; }, 2000);
    });
    
    // Show dialog
    dialog.showModal();
  });
}
```

**Step 4.2: Wire dans l'init (DOMContentLoaded)**

Localiser la fonction d'init main.js (probablement `init()` ou `DOMContentLoaded` listener). Ajouter :
```javascript
wireCiteModal();
```

**Step 4.3: Test PASS — modal complet fonctionnel**

Run via Chrome MCP localhost:8080 :
```
1. Click #citeBtn → modal s'ouvre, BibTeX visible par défaut
2. Click tab "RIS" → contenu RIS visible
3. Click tab "APA" → contenu APA visible
4. Click "Copier" → toast "Copié!" 2 sec
5. Click backdrop → modal ferme
6. Click #citeBtn → modal réapparaît (réutilisé)
```
Expected: tous les tests passent

**Step 4.4: Test clipboard contenu**

Run: après avoir cliqué Copier sur BibTeX, paste dans un editor
Expected: contenu BibTeX complet copié (de `@article{` à la dernière `}`)

---

## Task 5 — #15 i18n keys FR/EN

**Files:**
- Modify: `/Users/ericmerle/Documents/collatz-gh-pages/assets/js/main.js` (ajouter clé `citeBtn` dans dicts fr/en)

**Step 5.1: Vérifier que `citeBtn` existe déjà dans i18n**

Run: `grep -n "citeBtn" /Users/ericmerle/Documents/collatz-gh-pages/assets/js/main.js`
Expected: au moins 1 occurrence (label « Cite » sur le bouton existant) — sinon, ajouter.

**Step 5.2: Si manque, ajouter `citeBtn: "Citer"` (FR) et `citeBtn: "Cite"` (EN)**

Localiser dicts `fr:` et `en:` dans main.js (déjà existant pour navAccueil etc.). Ajouter ligne :
```javascript
fr: { ... citeBtn: "Citer", ... }
en: { ... citeBtn: "Cite", ... }
```

**Step 5.3: Test bilingual switch**

Run via Chrome MCP : click langBtn pour basculer FR/EN
Expected: bouton citeBtn affiche « Citer » en FR, « Cite » en EN. Modal interne FR/EN inline switche aussi (déjà géré par Pattern B).

---

## Task 6 — #14 GitHub Discussions activation

**Note** : action manuelle GitHub UI, peut être pilotée via Chrome MCP si Eric session active sur github.com. Sinon Eric clique le toggle directement.

**Step 6.1: Naviguer vers Settings repo**

Via Chrome MCP :
```
navigate to https://github.com/ericmerle3789/collatz-conditional-cycles/settings
```
Expected: page Settings du repo, login Eric requis

**Step 6.2: Scroll vers section Features**

Settings → Features → Discussions checkbox

**Step 6.3: Enable Discussions**

Click "Set up discussions" button → confirme template par défaut

**Step 6.4: Créer 4 catégories initiales**

Naviguer vers Discussions → "..." → "Manage categories" → ajouter :
- 📢 Announcements (pinned, posts Eric uniquement, type: Announcement)
- 💬 General (open discussion, type: Open-ended discussion)
- 🔬 Math discussions (théorie Collatz, axiomes, pistes, type: Open-ended discussion)
- 🐛 Site feedback (bugs, suggestions UX, type: Open-ended discussion)

**Step 6.5: Premier post pinned bilingue**

Créer thread dans Announcements :
- Titre : « Bienvenue / Welcome — Discussions ouvertes / Discussions are now open »
- Body :
```markdown
🇫🇷 **Bienvenue !** Les Discussions du repo sont maintenant ouvertes. N'hésite pas à :
- 💬 Poser des questions générales sur Collatz / Syracuse Conditional Cycles
- 🔬 Discuter de la théorie, des axiomes, des pistes mathématiques
- 🐛 Signaler des bugs ou suggérer des améliorations sur le site
- 📢 Suivre les annonces officielles (pinned thread, comme celui-ci)

Les questions purement techniques peuvent aussi rester sur les Issues si tu préfères.

🇬🇧 **Welcome!** The repo Discussions are now open. Feel free to:
- 💬 Ask general questions about Collatz / Syracuse Conditional Cycles
- 🔬 Discuss the theory, axioms, and mathematical approaches
- 🐛 Report site bugs or suggest UX improvements
- 📢 Follow official announcements (pinned thread, like this one)

Pure technical questions can stay on Issues if you prefer.

— Eric Merle
```
- Pin le thread

**Step 6.6: Update MAINTAINERS.md (mention Discussions)**

Modify `/Users/ericmerle/Documents/collatz-gh-pages/MAINTAINERS.md` — ajouter section :
```markdown
## Discussions

Les questions, suggestions et discussions techniques se passent sur :
**[GitHub Discussions](https://github.com/ericmerle3789/collatz-conditional-cycles/discussions)**

4 catégories actives : Announcements / General / Math discussions / Site feedback.
```

---

## Task 7 — Cache buster bump 11 pages

**Files:**
- Modify: 11 fichiers HTML (changelog, faq, histoire, index, lambda, lemmes, papers, pour-tous, preuve, research-ledger, syracuse)

**Step 7.1: Bulk replace cache buster**

Run script Python :
```python
from pathlib import Path

base = Path("/Users/ericmerle/Documents/collatz-gh-pages")
pages = [
    "changelog/index.html", "faq/index.html", "histoire/index.html",
    "index.html", "lambda/index.html", "lemmes/index.html",
    "papers/index.html", "pour-tous/index.html", "preuve/index.html",
    "research-ledger/index.html", "syracuse/index.html",
]

OLD = "?v=20260506-C35-DOC-WRAPUP"
NEW = "?v=20260506-C36-M1-CITE"

for relpath in pages:
    path = base / relpath
    content = path.read_text(encoding="utf-8")
    n = content.count(OLD)
    if n > 0:
        path.write_text(content.replace(OLD, NEW), encoding="utf-8")
        print(f"{relpath}: bumped x{n}")
```

**Step 7.2: Vérifier propagation**

Run: `grep -l "C36-M1-CITE" /Users/ericmerle/Documents/collatz-gh-pages/*.html /Users/ericmerle/Documents/collatz-gh-pages/*/index.html | wc -l`
Expected: 11

---

## Task 8 — UX MCP runtime test localhost

**Step 8.1: Vérifier dev server actif**

Run: `lsof -ti:8080`
Expected: PID actif (sinon démarrer `python3 -m http.server 8080`)

**Step 8.2: Test #15 modal sur 4 pages random**

Via Chrome MCP localhost:8080 :
```
For each page in [/, /pour-tous/, /preuve/, /faq/]:
  1. Navigate to page
  2. Click #citeBtn
  3. Verify modal opens
  4. Verify 3 tabs (BibTeX/RIS/APA) switch correctly
  5. Click "Copier" → verify toast appears
  6. Verify clipboard content matches active tab
  7. Close modal
```
Expected: tous les tests PASS sur 4 pages

**Step 8.3: Test bilingual switch**

Click `#langBtn` → verify modal title et bouton « Copier »/« Copy » switchent
Expected: switch fonctionnel FR ↔ EN

**Step 8.4: Anti-régression test**

Vérifier que :
- KaTeX rendering intact (formules sur preuve/, faq/, lemmes/)
- Footer Pattern A intact (LinkedIn p3, Atom feed p1)
- Bandeau home « Pour tous » visible
- Nav `Pour tous` visible 11 pages

---

## Task 9 — Commit C36 M1 + audit C indépendant

**Files:**
- Stage: ADR-0001 + main.js + main.css + 11 pages cache buster + MAINTAINERS.md (Discussions mention) + design doc Phase 4 + plan doc M1

**Step 9.1: Vérifier git status avant commit**

Run: `git status --short`
Expected: liste des fichiers modifiés/créés cohérente

**Step 9.2: Stage all C36 files**

```bash
cd /Users/ericmerle/Documents/collatz-gh-pages
git add docs/adr/2026-05-06-phase4-hybrid-cluster-storytelling.md \
        docs/plans/2026-05-06-phase4-roadmap-design.md \
        docs/plans/2026-05-06-phase4-M1-quick-wins.md \
        assets/js/main.js \
        assets/css/main.css \
        MAINTAINERS.md \
        changelog/index.html faq/index.html histoire/index.html \
        index.html lambda/index.html lemmes/index.html \
        papers/index.html pour-tous/index.html preuve/index.html \
        research-ledger/index.html syracuse/index.html
```

**Step 9.3: Commit C36 M1**

```bash
git commit -m "patch Phase 4 M1 quick wins (Eric chat 15:25 autonomie A+C + C 091 vote convergent α/α/α/α) : (1) ADR-0001 docs/adr/2026-05-06-phase4-hybrid-cluster-storytelling.md (Phase 3.8.1 activé) — capture décision approche hybride clusters cohérents (M1 quick wins burst + M2-M3 Storytelling + M4 parking lot Wikipedia + M5 marathon Lean playground), (2) #15 Modal Citer 3 onglets BibTeX/RIS/APA — HTML5 dialog natif + injection dynamique JS + clipboard API + toast + bilingue inline FR/EN + i18n keys citeBtn (sub-vote α sobriété MVP, skip CSL JSON/Markdown/eprint/RIS-skel Phase 4.5+), (3) #14 GitHub Discussions activation manuelle GitHub UI (4 catégories : Announcements + General + Math + Site feedback) + premier post pinned bilingue + mention MAINTAINERS.md, (4) cache buster bump 11 pages C35-DOC-WRAPUP → C36-M1-CITE, (5) docs/plans/2026-05-06-phase4-roadmap-design.md design doc complet (10 sections) + docs/plans/2026-05-06-phase4-M1-quick-wins.md plan implémentation (10 tasks) (Phase 4 commit C36 M1 quick wins)

Phase 4 ordonnancement (cohérent ADR-0001) :
- M1 J+0 (today) : ce commit C36
- M2 J+7 (2026-05-13) : #11 Behind the proof + 1er β weekly check
- M3 J+14 (2026-05-20) : #17 carte postale + #13 newsletter setup + 2ème β + γ décision Eric
- M4 post-JAR : #16 Wikipedia
- M5 sprint dédié post-M3 : #12 Lean playground

Sub-vote α MVP (skip Phase 4.5+) :
- CSL JSON / Markdown simple / BibTeX eprint arXiv / RIS skeleton complet : conservés en table candidates si feedback monitoring β montre demande

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

**Step 9.4: Vérifier commit créé**

Run: `git log --oneline -2`
Expected: HEAD = C36 commit avec hash abrégé, prev = ea14f40 (C35)

**Step 9.5: Notifier C via mailbox 093_A→C**

Composer message audit invitation :
- Stats commit (fichiers modifiés, lignes)
- Plan UX MCP test résultats
- Demande cross-validation

---

## Task 10 — Push origin + UX live test

**Step 10.1: Vérifier autonomie A+C maintenue OU ping Eric chat**

Eric chat 15:25 « En autonomie avec session C » → autonomie acquise pour push (cohérent push C35 hier).

**Step 10.2: Push origin gh-pages**

```bash
git push origin gh-pages
```
Expected: `XXXXXXX..YYYYYYY  gh-pages -> gh-pages`

**Step 10.3: Attendre Cloudflare propagation (~3-5 min)**

**Step 10.4: UX live test**

```bash
# Verify cache buster live
curl -s https://collatz-lab.org/ | grep -c "C36-M1-CITE"
# Expected: 2 (CSS + JS)

# Verify ADR-0001 accessible
curl -sI https://collatz-lab.org/docs/adr/2026-05-06-phase4-hybrid-cluster-storytelling.md
# Expected: HTTP/2 200

# Verify design doc accessible
curl -sI https://collatz-lab.org/docs/plans/2026-05-06-phase4-roadmap-design.md
# Expected: HTTP/2 200
```

**Step 10.5: UX live test #15 modal**

Via Chrome MCP `https://collatz-lab.org/` :
- Click #citeBtn → modal opens
- 3 tabs switch
- Copy fonctionne

**Step 10.6: Vérifier #14 GitHub Discussions accessible**

Naviguer https://github.com/ericmerle3789/collatz-conditional-cycles/discussions
Expected: page Discussions live, 4 catégories visibles, premier post pinned visible

---

## Rollback strategy

Si bug critique détecté post-push :
1. Pas de revert force-push (rule git strict)
2. Commit C37 fix immédiat avec correction
3. Push C37
4. Si Cloudflare cache stale, attendre TTL ~10 min ou bumper cache buster `C36-M1-CITE-FIX`

---

## Time budget récap

| Task | Estimé | Cumul |
|---|---|---|
| 1. ADR-0001 | 15 min | 15 min |
| 2. Modal HTML | 30 min | 45 min |
| 3. Modal CSS | 30 min | 1h15 |
| 4. Modal JS + clipboard | 60 min | 2h15 |
| 5. i18n keys | 15 min | 2h30 |
| 6. GitHub Discussions | 15-20 min | 2h45-2h50 |
| 7. Cache buster bump | 5 min | 2h50-2h55 |
| 8. UX MCP test | 15 min | 3h05-3h10 |
| 9. Commit C36 + 093_A→C | 10 min | 3h15-3h20 |
| 10. Push + UX live test | 10 min | 3h25-3h30 |

**Total** : ~3h30 (cohérent estimation 092 §5).

---

*Fin de plan d'implémentation Phase 4 M1 — 2026-05-06.*
