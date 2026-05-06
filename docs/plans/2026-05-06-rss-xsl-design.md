# Design — RSS XSL stylesheet (approche 4 hybride académique-pédagogue)

> **Date** : 2026-05-06
> **Auteurs** : Session A + Session C (validation proxy user déléguée Eric chat 16:18 + 17:25)
> **Statut** : Validé α par Eric chat 17:55 « (α) OK approche 4 hybride académique-pédagogue »
> **Skill chain** : `superpowers:brainstorming` HARD-GATE relâché → terminal `superpowers:writing-plans`
> **Trigger** : Eric chat 17:00 « Quand j'appuie sur RSS, j'ai une drôle de fenêtre qui s'ouvre »

---

## §1. Contexte

### Bug UX user-reported

Eric a cliqué le bouton 📡 RSS du footer de `collatz-lab.org` et est tombé sur la page brute du fichier `feed.xml` (XML mode Chrome avec warning « This XML file does not appear to have any style information »). Bug UX réel pour humains, pas pour readers automatiques (Feedly/Inoreader/NetNewsWire qui ignorent le `<?xml-stylesheet?>` directive).

### 4 approches considérées

1. **Sobre minimaliste** (~30 min) — juste lisible, pas de pédagogie
2. **Riche avec quick subscribe** (~50 min) — boutons readers commerciaux
3. **Éducative avec tutoriel** (~45 min) — voix Eric `/pour-tous/` (méthode "enfant en face")
4. **Hybride académique-pédagogue** ⭐ (~40 min) — sobre factuel + 1 paragraphe explicatif minimal

### Cadrage éditorial Eric chat 17:55

> « Tu dois défendre le côté pro du site, côté académique, intègre et rigoureux et en même temps pédagogue. »

→ Registre `/papers/` plutôt que `/pour-tous/`. Pas de fluff marketing, pas de "tu" familier, pas de boutons readers commerciaux (deep links Feedly/Inoreader = casserait l'intégrité).

### Pattern de référence

- **arXiv RSS feeds** — sobres, factuels
- **Quanta Magazine** — pédagogique mais sobre
- **Annals of Mathematics blog** — académique pur

---

## §2. Décision — Approche 4 hybride

### Composants

#### Header sobre (pas d'emoji décoratif H1)
```
Updates feed — collatz-lab.org
Flux des mises à jour — collatz-lab.org

[<subtitle> Atom rendu en italique : "Updates on the conditional formal proof of no non-trivial Collatz cycles in Lean 4."]
```

#### Mini-explication factuelle bilingue (1 paragraphe)
```
🇫🇷 Cette page est un flux Atom (standard RSS) listant les mises à jour
de collatz-lab.org. Pour suivre les nouvelles versions sans
intermédiaire, ajoute l'URL ci-dessous dans un lecteur de flux
(NetNewsWire, Feedly, Inoreader, ou ton client mail s'il supporte
les flux).

🇬🇧 This page is an Atom feed (RSS standard) listing updates to
collatz-lab.org. To follow new releases without intermediaries, add
the URL below to a feed reader (NetNewsWire, Feedly, Inoreader, or
your mail client if it supports feeds).
```

→ Mention factuelle des readers (liste informative, pas deep links commerciaux).

#### Bloc URL canonique avec bouton Copier
```
┌──────────────────────────────────────────────────────┐
│ https://collatz-lab.org/feed.xml         [📋 Copier] │
└──────────────────────────────────────────────────────┘
```
- Box ambrée subtile (palette site `--accent` + `rgba(217, 119, 6, 0.08)`)
- Bouton « Copier » via `navigator.clipboard.writeText()` + toast confirmation 2 sec
- Fallback : sélection automatique du texte si clipboard API indisponible

#### Liste des entrées
```xml
<xsl:for-each select="atom:entry">
  <article class="feed-entry">
    <h3>v0.6.0 — 2026-04-30</h3>
    <p class="entry-title">[atom:title]</p>
    <div class="entry-summary">[atom:summary]</div>
    <a class="entry-link" href="[atom:link/@href]">Read on the site →</a>
  </article>
</xsl:for-each>
```

→ Chaque entrée : titre h3 + date small + summary HTML rendu (atom utilise `type="html"` CDATA) + lien `Read on the site`.

#### Footer XSL transparent
```
This is an XML feed transformed for human reading via XSLT.
The raw XML remains valid for automated readers.

← Back to collatz-lab.org / ← Retour à collatz-lab.org
```

→ **Mention transparente** que c'est une transformation XSL (rigueur académique : pas de tromperie, le visiteur sait que c'est du XML).

### Style visuel

- Palette site : `--bg-primary` (dark default), `--accent` (ambré), `--text-primary`, `--text-secondary`, `--mono` pour URL
- Typographies cohérentes : Crimson Pro (titres), Inter (corps), JetBrains Mono (URL et code)
- Bilingue Pattern B inline : `<span lang="fr">` + `<span lang="en">`
- Responsive : `max-width: 760px` (cohérent `/pour-tous/` et `/papers/`)
- Pas de JS lourd : juste handler clipboard inline (~10 lignes dans XSL)

### Trade-offs acceptés

- ✅ Cohérent ton académique site (`/papers/` registre)
- ✅ Pédagogie minimale respectueuse (1 paragraphe factuel, pas tutoriel expansif)
- ✅ Intégrité technique préservée (mention transformation XSL transparente)
- ✅ Compatible 100% readers automatiques (ils ignorent `<?xml-stylesheet?>`)
- ✅ EXCLUSION #14 footer Pattern A post-C30 PRÉSERVÉE (on ne touche pas au lien `📡 RSS` p3 sur 11 pages)
- ✅ EXCLUSION §6.23 entrée v0.6.0 historique L20+32 PRÉSERVÉE (ajout `<?xml-stylesheet?>` au début ne touche pas aux entrées existantes)
- ⚠️ XSLT 1.0 = vieille techno, mais bien supportée Chrome/Safari/Firefox modernes + mobile
- ⚠️ 2 langues affichées en parallèle si JS i18n n'importe pas (acceptable, fallback graceful)

---

## §3. Architecture / Components

### Fichiers à créer/modifier

| Fichier | Action | Effort |
|---|---|---|
| `feed-style.xsl` (NEW) | Création XSLT 1.0 ~60 lignes | ~25 min |
| `feed.xml` | Ajout `<?xml-stylesheet?>` ligne 2 | ~2 min |
| `docs/plans/2026-05-06-rss-xsl-design.md` (NEW) | Ce fichier (design doc) | ~15 min |
| `docs/plans/2026-05-06-rss-xsl-impl-plan.md` (NEW) | Plan implém via writing-plans skill | ~10 min |

### Data flow

```
1. User clicks "📡 RSS" link in footer of any page
   → URL = https://collatz-lab.org/feed.xml

2. Browser GETs /feed.xml
   → Cloudflare proxy → GitHub Pages → returns feed.xml

3. Browser parses XML, finds <?xml-stylesheet?> directive line 2
   → Browser GETs /feed-style.xsl
   → Cloudflare proxy → GitHub Pages → returns feed-style.xsl

4. Browser applies XSLT transformation client-side
   → Renders HTML page with header + paragraph + URL box + entries + footer

5. (Optional) User clicks "📋 Copier" button
   → JS calls navigator.clipboard.writeText(feedURL)
   → Toast "✓ Copié" appears 2 sec
```

### Reader RSS automatique (Feedly, Inoreader, NetNewsWire) data flow

```
1. Reader subscribes to https://collatz-lab.org/feed.xml
2. Reader GETs /feed.xml periodically (e.g., every 30 min)
3. Reader parses XML
4. Reader IGNORES <?xml-stylesheet?> directive
5. Reader extracts <feed>, <entry>, <title>, <updated>, <summary>, <link>
6. Reader displays in its own UI
```

→ **Aucune régression** côté readers automatiques. La directive XSL est ignorée.

---

## §4. Error handling

### Browser ne supporte pas XSLT 1.0
- Très peu probable (Chrome/Safari/Firefox/Edge tous OK depuis 2003)
- Fallback graceful : Chrome affiche XML brut comme avant (= comportement actuel)
- Pas de régression

### `feed-style.xsl` 404
- Si Cloudflare cache stale ou GitHub Pages glitch
- Fallback graceful : Chrome affiche XML brut comme avant
- Pas de régression

### `navigator.clipboard.writeText()` indisponible
- Old browser ou contexte non-secure
- Fallback : sélection automatique du texte URL via `range.selectNode()`
- User peut copier manuellement Cmd+C

### Reader RSS automatique échec parsing
- Très peu probable (XML reste 100% valide)
- Test manuel post-deploy avec Feedly fetch validator
- Si problème : revert directive, retour comportement actuel

---

## §5. Testing strategy

### Browsers testés (UX MCP runtime localhost:8080)
- Chrome (primary) — XSLT support natif
- (Optional) Safari + Firefox via Chrome MCP screenshot, mais Chrome suffit pour MVP

### Validators
- W3C feed validator : https://validator.w3.org/feed/check.cgi
- Feedly preview : https://feedly.com/i/discover/sources/search/feed/{URL}

### Tests fonctionnels
1. `/feed.xml` rend HTML lisible (pas XML brut warning)
2. Header bilingue affiché
3. Mini-explication paragraphe affichée
4. URL `/feed.xml` dans box copiable
5. Bouton "Copier" copie URL dans clipboard + toast
6. Liste des entrées rendue avec titre/date/summary/link
7. Lien "← Back to collatz-lab.org" fonctionne
8. Reader RSS automatique parse encore correctement (Feedly test fetch)

### Anti-régression
- 11 pages site : footer `📡 RSS` link reste sur `/feed.xml` (EXCLUSION #14 préservée)
- Cache buster : pas de bump nécessaire (nouveau fichier `.xsl`, pas de modif `.css`/`.js`)

---

## §6. Verrous opérationnels

1. Pas de push origin sans OK chat explicite Eric OU autonomie A+C maintenue
2. Pas de modif EXCLUSIONS originales (11 + #12-#14 = 14 protégées)
3. Pas de touche identifiant Lean `BakerSeparation`
4. Branche `gh-pages` uniquement (jamais `main`)
5. Concertation A+C via mailbox `_handoff_mailbox/`
6. UX MCP runtime test obligatoire post-apply

---

## §7. Skip MVP (différés Phase 4.5+)

- ❌ Deep links subscribe Feedly/Inoreader/NetNewsWire (commercial, casserait intégrité académique)
- ❌ Tutoriel expansif "C'est quoi RSS ?" multi-paragraphes (trop `/pour-tous/` familier)
- ❌ Bouton "Add to Vivaldi" / autres readers spécifiques
- ❌ Animation/transitions CSS sur affichage (overkill pour feed page)
- ❌ Pagination des entrées (le feed Atom contient tout, browser scrollable suffit)

---

## §8. Références

- Mailbox A↔C : `098_A→C` bug UX detected + `099_C→A` vote convergent α
- Eric chat 2026-05-06 17:00 : « Quand j'appuie sur RSS... »
- Eric chat 2026-05-06 17:55 : « Tu dois défendre le côté pro... pédagogue »
- Eric chat 2026-05-06 ~17:58 : « (α) OK approche 4 hybride académique-pédagogue »
- Pattern : Hacker News, Substack, Phoronix, Daring Fireball XSL feeds
- Spec : XSLT 1.0 https://www.w3.org/TR/xslt-10/

---

## §9. Transition writing-plans

Ce design doc est **input** au skill `superpowers:writing-plans` qui produit le **plan d'implémentation détaillé** :
- Steps numbered avec dependencies
- Validation points (UX MCP test, audit C, etc.)
- Rollback strategy si bug
- Time budget par step

Plan généré dans `docs/plans/2026-05-06-rss-xsl-impl-plan.md`.

---

*Fin de design RSS XSL — v1.0 — 2026-05-06.*
