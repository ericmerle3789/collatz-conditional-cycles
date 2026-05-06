# Notes de migration & décisions techniques — collatz-lab.org

> Ce fichier trace les décisions techniques importantes prises pendant les phases 3.5 → 3.7 (printemps 2026), pour mémoire collective et pérennité.
> **Source canonique** : ce fichier (branche `gh-pages`).
> **Dernière mise à jour** : 2026-05-06 · v0.7.2 · Phase 3.6 wrap-up.
> **Audience** : mainteneurs futurs, Eric (mémoire), agents IA (Claude/ChatGPT/Gemini) en patch cycle.

---

## §1. Phase 3.6 wrap-up — récapitulatif des commits

Phase 3.6 a livré **9 commits** sur la branche `gh-pages` entre le 5 mai 2026 (toute la journée) :

| Commit | Catégorie | Résumé |
|--------|-----------|--------|
| `C28` | Perf P0 | KaTeX async via Filament Group preload+onload + `setTimeout(fn, 200)` post-LCP |
| `C29` | UI | Hero font 2.8rem → 2.2rem + `overflow-wrap` + `hyphens: auto` |
| `C30` | Marketing P0#1 | Footer 10 pages : LinkedIn + 📡 RSS + microformat W3C `rel="me noopener"` |
| `C31` | SEO P1#5 | `sitemap.xml` lastmod + `robots.txt` 6 IA bots Allow + `Disallow: /assets/data/` |
| `C32` | SEO P1#4 | JSON-LD `ScholarlyArticle` 20 champs (action #6 hreflang : SKIP audit PASS) |
| `C33` | SEO P1#4 refinement | Fix 5 warnings non critiques Google Rich Results Test |
| `C34a` | UX P2 cycle 2 #8 | Création `pour-tous/index.html` — page vulgarisation grand public |
| `C34b` | UX P2 cycle 2 #8 | Intégration site-wide : nav 11 pages + bandeau home + cache buster + 2 micro-fixes |
| `C34c` | UX P2 cycle 2 #8 | `sitemap.xml` ajout entrée `/pour-tous/` priorité 0.8 |

**Stats Phase 3.6** :
- 9 commits + 1 tag annoté `v0.7.2`
- 14 fichiers modifiés total (sur 11 pages HTML + assets/css + assets/js + sitemap.xml + nouveau dossier docs/)
- 1 nouvelle page (`/pour-tous/`, 5 sections bilingue inline FR/EN)
- 1 nouvelle entrée nav site-wide (`Pour tous` 2ème position)
- Cache buster final : `?v=20260506-C35-DOC-WRAPUP` (bumpé depuis `?v=20260505-C29-HERO-FONT`)

**SKIP confirmés** par audit pré-Edit (voir §5 et §6) :
- Cycle 1 P2 #9 scroll progress bar : déjà implémenté production-quality
- Cycle 1 P2 #10 TOC flottante : déjà implémenté avec IntersectionObserver + ARIA
- Action #6 hreflang : audit PASS, déjà parfait

---

## §2. Search Console — alerte 02/05/2026 : comportement par design

Le 5 mai 2026 vers 21:02 UTC, Google Search Console a notifié Eric de **6 URLs non-indexées** sous 2 motifs. **Aucune action de fix n'est requise** : c'est le comportement attendu après la mise en place Phase 3.6 (canonicals + hreflang + redirects HTTPS/non-www).

### §2.1 Motif 1 : « Page avec redirection » (3 URLs)

Google a découvert 3 anciennes URLs qui redirigent en `301` vers la version canonique :

| URL flaggée | Redirige vers | Cause |
|-------------|---------------|-------|
| `http://collatz-lab.org/` | `https://collatz-lab.org/` | Forçage TLS |
| `http://www.collatz-lab.org/` | `https://collatz-lab.org/` | TLS + non-www |
| `https://www.collatz-lab.org/` | `https://collatz-lab.org/` | non-www enforcement |

**Origine probable** : anciens backlinks externes ou cache Google historique pré-Phase 3.6. Aucun lien interne n'a pointé vers ces variants depuis la migration domaine.

**Action** : aucune (Google suit le 301 et indexe la destination canonique).

### §2.2 Motif 2 : « Autre page avec balise canonique correcte » (3 URLs)

Google a trouvé 3 variants `?lang=fr` déclarés via `xhtml:link hreflang="fr"` dans `sitemap.xml`. Leur balise `<link rel="canonical">` pointe vers la version sans query string :

| URL flaggée | Canonical déclarée |
|-------------|---------------------|
| `https://collatz-lab.org/lemmes/?lang=fr` | `https://collatz-lab.org/lemmes/` |
| `https://collatz-lab.org/preuve/?lang=fr` | `https://collatz-lab.org/preuve/` |
| `https://collatz-lab.org/research-ledger/?lang=fr` | `https://collatz-lab.org/research-ledger/` |

**C'est précisément le but** du pattern hreflang Phase 3.6 #6 : exposer les variants linguistiques à Google sans dupliquer le contenu indexé.

**Action** : aucune (Google respecte la canonical et indexe la version canonique uniquement).

### §2.3 Anti-patterns à NE PAS appliquer

- ❌ Ajouter `Disallow: /*?lang=fr` dans `robots.txt` → casserait hreflang
- ❌ Retirer les variants `?lang=fr` du `sitemap.xml` → casserait l'i18n SEO
- ❌ Modifier les canonicals pour pointer vers les variants `?lang=fr` → casserait l'indexation

### §2.4 Optionnel cosmétique

Eric peut cliquer « VALIDER LA CORRECTION » sur les 2 motifs côté UI Search Console. Ça dit à Google « j'ai vu, recheck quand tu veux ». Purement esthétique — aucun changement de comportement.

---

## §3. Footer Pattern post-C30 — duplication intentionnelle Atom feed / 📡 RSS

Depuis le commit `C30` (footer 10 pages, post-2026-04-29), le footer suit ce pattern :

```html
<footer>
  <p>
    © Eric Merle 2026 · CC BY-SA 4.0 · ORCID · GitHub · Changelog · Atom feed
  </p>
  <p style="margin-top: 0.5rem;">
    Page mise à jour le YYYY-MM-DD · vX.Y.Z
  </p>
  <p style="margin-top: 0.6rem;">
    LinkedIn · 📡 RSS
  </p>
</footer>
```

### §3.1 Duplication apparente Atom feed / 📡 RSS

Le lien `Atom feed` (paragraphe 1) et le lien `📡 RSS` (paragraphe 3) pointent **tous deux vers `/feed.xml`** — la même URL. Cette duplication est **intentionnelle** :

| Lien | Public cible | Style |
|------|--------------|-------|
| `Atom feed` (p1, texte simple) | Lecteurs académiques familiers du standard Atom | Formel, sobre |
| `📡 RSS` (p3, emoji + label populaire) | Grand public, terminologie « RSS » plus connue | Visuel, discovery |

**Décision Phase 3.6** : garder les 2 — chacun sert un public différent. Phase 3.7+ pourra éventuellement consolider si l'analyse Cloudflare montre un pattern d'usage clair.

### §3.2 Position de LinkedIn (p3, pas p1)

LinkedIn est sur la **3ème ligne** du footer (avec 📡 RSS), séparée par `margin-top: 0.6rem`. Ce n'est pas une erreur de design — c'est cohérent avec l'esprit « réseaux sociaux secondaires aux liens académiques » :
- p1 : ©, licence, identifiants académiques (CC BY-SA, ORCID)
- p2 : version + date de mise à jour
- p3 : réseaux sociaux + RSS

Un précédent draft (074_C→A §5.1) suggérait de mettre LinkedIn en p1. Audit pattern réel post-C30 (5 mai 2026) a confirmé que le pattern site-wide est LinkedIn en p3. Cohérence maintenue sur 11 pages.

---

## §4. EXCLUSIONS — renvoi vers audit folder

Les **EXCLUSIONS** sont les éléments du codebase qui ne doivent **PAS** être modifiés sans concertation explicite (citations académiques, paper title verbatim, mea culpa text, identifiants Lean, voix Eric validée). Elles sont documentées en détail dans :

```
collatz-lab-audit/findings/EXCLUSIONS_LIST.md  (privé, audit folder)
```

**Résumé** :
- 11 EXCLUSIONS originales (Phase 3.5) : paper title JAR, mea culpa #28, rule descriptions, etc.
- 3 EXCLUSIONS Phase 3.6 (#12-#14, ajoutées 2026-05-06) :
  - **#12** : Hero + aside F14 + Three-Key paragraphes de `/pour-tous/` (voix Eric validée chat 21:00)
  - **#13** : Mapping FAQ Q1+Q4+Q5+Q6+Q7+Q8 → Sections `/pour-tous/` (cohérence à maintenir si FAQ évolue)
  - **#14** : Footer Pattern post-C30 (LinkedIn p3 séparé + Atom feed p1 + 📡 RSS p3) sur 11 pages

**Garde-fou Lean** : l'identifiant `BakerSeparation` (axiome externe documenté dans le code Lean) ne doit **JAMAIS** être renommé ou paraphrasé dans le code. Les reformulations grand public (« bornes de Baker » dans `/pour-tous/`) sont OK car elles ne touchent pas l'identifiant Lean lui-même.

---

## §5. Cycle 1 P2 — SKIP par audit pré-Edit

La Phase 3.6 cycle 1 prévoyait l'implémentation de :
- **#9** Scroll progress bar (estimation ~1h)
- **#10** TOC flottante glassmorphism (estimation ~2h)

L'audit pré-Edit a révélé que **les deux features sont déjà implémentées** en production-quality :

### §5.1 #9 Scroll progress bar (déjà OK)
- CSS `.scroll-progress` avec `transform: scaleX()` (GPU-accelerated)
- Fallback CSS `@supports (animation-timeline: scroll())` pour Chrome 115+ (CSS-only, sans JS)
- Position `fixed; top: 0; height: 3px; background: var(--accent)`

### §5.2 #10 TOC flottante (déjà OK)
- Glassmorphism + IntersectionObserver pour highlight section actuelle
- ARIA roles complets (`role="navigation"`, `aria-label`)
- 11 items auto-générés sur `/preuve/` depuis les `<h2>`/`<h3>`
- Hide responsive sur mobile

**Décision** : 0 commit nécessaire. Le cycle 1 a sauté directement vers le cycle 2 (#8 vulgarisateur, voir C34a/b/c).

---

## §6. Action #6 hreflang — SKIP par audit PASS

Phase 3.6 P1 prévoyait l'ajout de hreflang sur 11 pages. L'audit a révélé que :
- `<link rel="alternate" hreflang="en|fr|x-default">` étaient déjà présents sur les 11 pages canoniques
- Le `sitemap.xml` déclarait déjà `<xhtml:link rel="alternate" hreflang="..."/>` pour chaque URL
- Pattern Phase 3.5 (commit antérieur) était déjà conforme spec Google

**Décision** : 0 commit nécessaire. Action #6 marquée SKIP avec mention « audit PASS, déjà parfait ».

---

## §7. Phase 3.7 ordonnancement (α / β / γ)

### §7.1 α — Quick wins doc (CE COMMIT C35)

- ✅ `docs/MIGRATION_NOTES.md` (ce fichier)
- ✅ `findings/EXCLUSIONS_LIST.md` (audit folder, externe à ce repo)
- ✅ CSS `.nav a { white-space: nowrap; }` pour éviter cassure « Pour tous » en 2 lignes
- ✅ Tag `v0.7.2` annoté Phase 3.6 wrap-up

### §7.2 β — Pause monitoring 7-14j

Avant tout patch cycle Phase 3.7+, observer 7 à 14 jours :
- **Cloudflare** : ratio bots/humains (objectif < 99% bots), pages vues, referrers
- **Google Search Console** : indexation `/pour-tous/` effective, impressions, clicks
- **LinkedIn** : engagement post Eric publication (si annonce `/pour-tous/`)
- **Direct trafic** : referrers nouveaux ?

Aligné `changefreq: monthly` du sitemap (Google revisite mensuellement).

### §7.3 γ — Patch cycle basé insights

Décision Eric **post-monitoring** selon données observées :
- Audience humaine augmente → continuer direction grand public (#11 lambda animé, enrichissement `/pour-tous/`)
- Audience humaine stagne → repositionner stratégie (#7 Mermaid cliquable audience Lean experte)
- Search Console silent → rien d'urgent ; site live stable

---

## §8. Cache buster strategy

Pattern : `?v=YYYYMMDD-CXX-LABEL` sur `assets/css/main.css` et `assets/js/main.js`.

Historique :
- `?v=20260505-C29-HERO-FONT` → C29 hero font fix
- `?v=20260505-C34-POUR-TOUS` → C34 vulgarisateur intégration
- `?v=20260506-C35-DOC-WRAPUP` → C35 docs + nav nowrap (ce commit)

**Règle** : bump le cache buster **uniquement** si CSS ou JS modifié. Si juste HTML/markdown, pas nécessaire (HTML max-age=600s par défaut). Le bump force les CDN (Cloudflare) et browser caches à recharger les assets.

---

## §9. Verrous opérationnels permanents (rappel)

1. **Pas de push origin sans OK chat explicite Eric** (verrou GF8 strict)
2. **Pas de modif EXCLUSIONS originales** (Phase 3.5 + #12-#14 Phase 3.6)
3. **Pas de touche identifiant Lean `BakerSeparation`** (axiome externe documenté)
4. **Branche `gh-pages` uniquement** (jamais `main` réservé paper JAR Springer)
5. **Concertation A+C systématique** via mailbox `_handoff_mailbox/` (multi-cerveaux Claude Code)
6. **UX MCP runtime test obligatoire post-apply** sur localhost:8080 (Eric directive)
7. **Three-Key validation** (Claude+ChatGPT+Gemini) pour décisions structurantes

---

*Fin de MIGRATION_NOTES.md — v0.7.2 — Phase 3.6 wrap-up — 2026-05-06.*
