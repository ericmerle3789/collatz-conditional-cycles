# RSS XSL Stylesheet Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Fixer le bug UX où cliquer sur 📡 RSS dans le footer du site affiche du XML brut au lieu d'une page lisible. Solution : ajouter un XSL stylesheet (XSLT 1.0) qui transforme côté navigateur le feed Atom en page HTML cohérente avec le ton académique-pédagogue du site, tout en préservant 100% la compatibilité avec les readers RSS automatiques.

**Architecture:** Création d'un fichier `feed-style.xsl` (~60 lignes XSLT 1.0) qui transforme `<feed>` Atom en HTML5 + ajout d'un `<?xml-stylesheet?>` directive en ligne 2 de `feed.xml`. Les readers RSS automatiques (Feedly, Inoreader, NetNewsWire) ignorent la directive et lisent le XML normalement. Les humains via navigateur voient une page formatée.

**Tech Stack:** XSLT 1.0, HTML5, CSS inline (palette `--accent` du site), JavaScript inline minimal (clipboard handler), Atom 1.0 feed XML.

---

## Tasks overview

| Task | Sujet | Effort estimé | Dépendances |
|---|---|---|---|
| 1 | Créer `feed-style.xsl` squelette + header HTML | 10 min | aucune |
| 2 | Ajouter mini-explication paragraphe bilingue + URL box + Copy button | 10 min | Task 1 |
| 3 | Ajouter XSL template pour entrées Atom (titre/date/summary/link) | 10 min | Task 1 |
| 4 | Ajouter footer transparent + responsive CSS | 5 min | Task 1 |
| 5 | Modifier `feed.xml` : ajouter `<?xml-stylesheet?>` ligne 2 | 2 min | aucune |
| 6 | UX MCP runtime test localhost (bug fix verified) | 10 min | Tasks 1-5 |
| 7 | Anti-régression test reader RSS auto (curl + parse) | 5 min | Task 5 |
| 8 | Commit C38 + push origin | 5 min | Tasks 1-7 |
| 9 | Audit C indépendant + cross-validation post-push | 5 min | Task 8 |
| 10 | UX live test + Eric verification visuelle | 5 min | Task 8 |

**Total ETA** : ~67 min effort A + ~5 min audit C + ~5 min Eric verify = ~75 min total.

---

## Task 1 — Créer `feed-style.xsl` squelette + header HTML

**Files:**
- Create: `/Users/ericmerle/Documents/collatz-gh-pages/feed-style.xsl`

**Step 1.1: Test runtime AVANT implementation**

Run via Chrome MCP localhost:8080:
```
1. Navigate to http://localhost:8080/feed.xml
2. Expected: XML brut avec warning "This XML file does not appear to have any style information"
   (= bug actuel, baseline avant fix)
```

**Step 1.2: Créer `feed-style.xsl` avec XSLT 1.0 namespace + Atom namespace + HTML5 output**

Ce fichier transforme un Atom feed en HTML lisible. Toute la structure XSL est dans un fichier unique.

Contenu (copier exactement) :

```xml
<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:atom="http://www.w3.org/2005/Atom"
                exclude-result-prefixes="atom">

  <xsl:output method="html" encoding="UTF-8" indent="yes"
              doctype-system="about:legacy-compat"/>

  <xsl:template match="/atom:feed">
    <html lang="en">
      <head>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <title>
          <xsl:text>Updates feed — </xsl:text>
          <xsl:value-of select="atom:title"/>
        </title>
        <link rel="stylesheet" href="/assets/css/main.css?v=20260506-C38-RSS-XSL"/>
        <style>
          <!-- Inline styles spécifiques feed page (additif au main.css) -->
          .feed-wrap { max-width: 760px; margin: 3rem auto; padding: 0 1.2rem; font-family: var(--sans); color: var(--text-primary); }
          .feed-wrap h1 { font-family: var(--serif); font-size: clamp(1.6rem, 3.5vw, 2.2rem); line-height: 1.2; margin: 0 0 0.5rem; }
          .feed-wrap .feed-subtitle { font-style: italic; color: var(--text-secondary); margin: 0 0 2rem; }
          .feed-wrap .feed-intro { background: rgba(217, 119, 6, 0.06); border-left: 3px solid var(--accent); padding: 1rem 1.2rem; border-radius: 4px; margin: 0 0 2rem; }
          .feed-wrap .feed-intro p { margin: 0 0 0.8rem; }
          .feed-wrap .feed-intro p:last-child { margin-bottom: 0; }
          .feed-wrap .feed-url-box { background: var(--bg-secondary); border: 1px solid var(--border); border-radius: 4px; padding: 0.8rem 1rem; display: flex; align-items: center; justify-content: space-between; gap: 1rem; margin: 0 0 2.5rem; flex-wrap: wrap; }
          .feed-wrap .feed-url { font-family: var(--mono); font-size: 0.92rem; color: var(--accent); word-break: break-all; }
          .feed-wrap .feed-copy-btn { background: var(--accent); color: white; border: none; padding: 0.5rem 1rem; border-radius: 4px; font-family: var(--sans); font-weight: 500; cursor: pointer; white-space: nowrap; }
          .feed-wrap .feed-copy-btn:hover { opacity: 0.9; }
          .feed-wrap .feed-copy-toast { color: var(--accent); font-size: 0.88rem; margin-left: 0.5rem; }
          .feed-wrap .feed-entries-heading { font-family: var(--serif); font-size: 1.3rem; margin: 2rem 0 1rem; padding-bottom: 0.5rem; border-bottom: 1px solid var(--border); }
          .feed-wrap .feed-entry { margin: 0 0 2rem; padding-bottom: 1.5rem; border-bottom: 1px dashed var(--border); }
          .feed-wrap .feed-entry:last-child { border-bottom: none; }
          .feed-wrap .feed-entry-meta { font-family: var(--mono); font-size: 0.82rem; color: var(--text-secondary); margin: 0 0 0.4rem; }
          .feed-wrap .feed-entry h3 { font-family: var(--serif); font-size: 1.15rem; margin: 0 0 0.6rem; }
          .feed-wrap .feed-entry-summary { color: var(--text-primary); font-size: 0.95rem; line-height: 1.55; }
          .feed-wrap .feed-entry-summary p { margin: 0 0 0.6rem; }
          .feed-wrap .feed-entry-link { display: inline-block; margin-top: 0.6rem; color: var(--accent); text-decoration: none; font-size: 0.9rem; }
          .feed-wrap .feed-entry-link:hover { text-decoration: underline; }
          .feed-wrap .feed-footer { margin-top: 3rem; padding-top: 1.5rem; border-top: 1px solid var(--border); color: var(--text-secondary); font-size: 0.85rem; }
          .feed-wrap .feed-footer p { margin: 0 0 0.4rem; }
          .feed-wrap .feed-footer a { color: var(--accent); text-decoration: none; }
          .feed-wrap .feed-footer a:hover { text-decoration: underline; }
        </style>
      </head>
      <body>
        <main class="feed-wrap">
          <h1>
            <span lang="en">Updates feed — collatz-lab.org</span>
            <br/>
            <span lang="fr">Flux des mises à jour — collatz-lab.org</span>
          </h1>
          <p class="feed-subtitle">
            <xsl:value-of select="atom:subtitle"/>
          </p>

          <!-- TASK 2 will add intro paragraph + URL box here -->

          <!-- TASK 3 will add entries here -->

          <!-- TASK 4 will add footer here -->
        </main>
      </body>
    </html>
  </xsl:template>

</xsl:stylesheet>
```

**Step 1.3: Pas de directive xml-stylesheet sur feed.xml encore (Task 5)**

→ Aucun rendering visible côté browser tant que Task 5 pas faite. Mais le fichier `feed-style.xsl` est valide XSLT 1.0.

**Step 1.4: Test fail expected**

Run: `curl -sI http://localhost:8080/feed-style.xsl`
Expected: HTTP 200 (le fichier existe et est servi)

Run: `xmllint --noout /Users/ericmerle/Documents/collatz-gh-pages/feed-style.xsl 2>&1 || echo OK`
Expected: pas d'erreur XML (squelette valide)

**Step 1.5: Pas de commit isolé** (intégré dans C38 final commit Task 8)

---

## Task 2 — Mini-explication paragraphe bilingue + URL box + Copy button

**Files:**
- Modify: `/Users/ericmerle/Documents/collatz-gh-pages/feed-style.xsl` (remplacer commentaire `<!-- TASK 2 will add intro paragraph + URL box here -->`)

**Step 2.1: Remplacer le placeholder par le bloc intro + URL box**

Remplacer :
```xml
          <!-- TASK 2 will add intro paragraph + URL box here -->
```

Par :
```xml
          <div class="feed-intro">
            <p>
              <span lang="fr">🇫🇷 Cette page est un flux Atom (standard RSS) listant les mises à jour de <code>collatz-lab.org</code>. Pour suivre les nouvelles versions sans intermédiaire, ajoute l'URL ci-dessous dans un lecteur de flux (NetNewsWire, Feedly, Inoreader, ou ton client mail s'il supporte les flux).</span>
            </p>
            <p>
              <span lang="en">🇬🇧 This page is an Atom feed (RSS standard) listing updates to <code>collatz-lab.org</code>. To follow new releases without intermediaries, add the URL below to a feed reader (NetNewsWire, Feedly, Inoreader, or your mail client if it supports feeds).</span>
            </p>
          </div>

          <div class="feed-url-box">
            <code class="feed-url">https://collatz-lab.org/feed.xml</code>
            <button class="feed-copy-btn" onclick="navigator.clipboard.writeText('https://collatz-lab.org/feed.xml').then(()=>{this.nextElementSibling.style.display='inline';setTimeout(()=>this.nextElementSibling.style.display='none',2000)}).catch(()=>{const r=document.createRange();r.selectNode(this.previousElementSibling);window.getSelection().removeAllRanges();window.getSelection().addRange(r);})">📋 Copier / Copy</button>
            <span class="feed-copy-toast" style="display:none">✓ Copié / Copied</span>
          </div>
```

**Note** : le bouton inline `onclick` utilise navigator.clipboard avec fallback range selection. Pas de JS externe. Pas de toast HTML5 dialog complexe — juste un span qui apparaît 2 sec.

**Step 2.2: Test runtime intermédiaire**

Pas testable visuellement sans Task 5 (directive xml-stylesheet). Skip.

---

## Task 3 — Template pour entrées Atom

**Files:**
- Modify: `/Users/ericmerle/Documents/collatz-gh-pages/feed-style.xsl` (remplacer commentaire `<!-- TASK 3 will add entries here -->`)

**Step 3.1: Remplacer le placeholder par le bloc entrées**

Remplacer :
```xml
          <!-- TASK 3 will add entries here -->
```

Par :
```xml
          <h2 class="feed-entries-heading">
            <span lang="en">Latest entries</span>
            <span lang="fr">Dernières entrées</span>
          </h2>

          <xsl:for-each select="atom:entry">
            <article class="feed-entry">
              <p class="feed-entry-meta">
                <xsl:value-of select="substring(atom:updated, 1, 10)"/>
              </p>
              <h3>
                <xsl:value-of select="atom:title"/>
              </h3>
              <div class="feed-entry-summary">
                <xsl:value-of select="atom:summary" disable-output-escaping="yes"/>
              </div>
              <a class="feed-entry-link">
                <xsl:attribute name="href">
                  <xsl:value-of select="atom:link/@href"/>
                </xsl:attribute>
                <span lang="en">Read on the site →</span>
                <span lang="fr">Lire sur le site →</span>
              </a>
            </article>
          </xsl:for-each>
```

**Notes XSLT** :
- `substring(atom:updated, 1, 10)` extrait `YYYY-MM-DD` de `2026-04-30T16:50:00Z`
- `disable-output-escaping="yes"` car le `<summary type="html">` du feed contient du HTML CDATA qu'on veut rendre, pas escape
- `<xsl:attribute name="href">` car on ne peut pas utiliser `{atom:link/@href}` AVT (Attribute Value Templates) dans XSLT 1.0 cross-namespace propre — `<xsl:attribute>` est plus safe

**Step 3.2: Pas de test isolé** (validé en Task 6 UX MCP test)

---

## Task 4 — Footer transparent + clip layout finale

**Files:**
- Modify: `/Users/ericmerle/Documents/collatz-gh-pages/feed-style.xsl` (remplacer commentaire `<!-- TASK 4 will add footer here -->`)

**Step 4.1: Remplacer le placeholder par le footer**

Remplacer :
```xml
          <!-- TASK 4 will add footer here -->
```

Par :
```xml
          <footer class="feed-footer">
            <p>
              <span lang="fr">Cette page est un flux XML transformé pour la lecture humaine via XSLT. Le XML brut reste valide pour les lecteurs automatiques.</span>
            </p>
            <p>
              <span lang="en">This is an XML feed transformed for human reading via XSLT. The raw XML remains valid for automated readers.</span>
            </p>
            <p>
              <a href="/">
                <span lang="en">← Back to collatz-lab.org</span>
                <span lang="fr">← Retour à collatz-lab.org</span>
              </a>
            </p>
          </footer>
```

**Step 4.2: Verify XSLT validity**

Run: `xmllint --noout /Users/ericmerle/Documents/collatz-gh-pages/feed-style.xsl && echo OK`
Expected: `OK` (pas d'erreur XML après ajouts Tasks 2-4)

---

## Task 5 — Modifier `feed.xml` : ajouter `<?xml-stylesheet?>` directive

**Files:**
- Modify: `/Users/ericmerle/Documents/collatz-gh-pages/feed.xml:2` (insérer ligne 2)

**Step 5.1: Lire la ligne 1 actuelle**

Run: `head -3 /Users/ericmerle/Documents/collatz-gh-pages/feed.xml`
Expected:
```
<?xml version="1.0" encoding="utf-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">
  <title>...</title>
```

**Step 5.2: Insérer `<?xml-stylesheet?>` directive AU-DESSUS de `<feed>`**

Modifier : insérer la ligne `<?xml-stylesheet type="text/xsl" href="/feed-style.xsl"?>` ENTRE la ligne `<?xml version="1.0" encoding="utf-8"?>` et `<feed xmlns="http://www.w3.org/2005/Atom">`.

Résultat attendu :
```
<?xml version="1.0" encoding="utf-8"?>
<?xml-stylesheet type="text/xsl" href="/feed-style.xsl"?>
<feed xmlns="http://www.w3.org/2005/Atom">
  <title>...</title>
```

**Step 5.3: Verify feed.xml reste valide XML**

Run: `xmllint --noout /Users/ericmerle/Documents/collatz-gh-pages/feed.xml && echo OK`
Expected: `OK`

**Step 5.4: Verify directive position**

Run: `head -3 /Users/ericmerle/Documents/collatz-gh-pages/feed.xml`
Expected:
```
<?xml version="1.0" encoding="utf-8"?>
<?xml-stylesheet type="text/xsl" href="/feed-style.xsl"?>
<feed xmlns="http://www.w3.org/2005/Atom">
```

**Step 5.5: Garde-fou EXCLUSION §6.23 vérifié**

Run: `grep -A 1 'v0.6.0' /Users/ericmerle/Documents/collatz-gh-pages/feed.xml | head -5`
Expected: l'entrée v0.6.0 (lignes ~20+32) est intacte (audit pré-Edit C 099 §3.9 confirmé).

---

## Task 6 — UX MCP runtime test localhost

**Files:**
- (test only, no modifications)

**Step 6.1: Verify dev server actif**

Run: `lsof -ti:8080`
Expected: PID actif

**Step 6.2: Test feed.xml rendu HTML via Chrome MCP**

Via Chrome MCP localhost:8080:
```
1. Navigate to http://localhost:8080/feed.xml
2. Wait 2 seconds (XSLT transformation client-side)
3. Screenshot
```

Expected (verify visually):
- ✅ Pas de XML brut warning "This XML file does not appear..."
- ✅ Header "Updates feed — collatz-lab.org / Flux des mises à jour — collatz-lab.org"
- ✅ Subtitle italique
- ✅ Box ambrée mini-explication bilingue FR + EN
- ✅ Box URL avec bouton "📋 Copier / Copy"
- ✅ Liste des entrées avec date + titre + summary + lien "Read on the site →"
- ✅ Footer transparent + lien retour

**Step 6.3: Test bouton Copy**

Via Chrome MCP:
```
1. Click "📋 Copier / Copy" button
2. Wait 1s
3. Screenshot
```

Expected:
- ✅ Toast "✓ Copié / Copied" apparaît 2 sec
- ✅ Pas d'erreur console

**Step 6.4: Test responsive mobile**

Via Chrome MCP:
```
1. Resize viewport à 375x667 (mobile)
2. Screenshot
```

Expected:
- ✅ Layout reste lisible (flex-wrap sur URL box)
- ✅ Pas de horizontal scroll

---

## Task 7 — Anti-régression test reader RSS auto

**Files:**
- (test only, no modifications)

**Step 7.1: Test parsing XML par xmllint (équivalent reader auto)**

Run:
```bash
xmllint --xpath "//*[local-name()='entry']" /Users/ericmerle/Documents/collatz-gh-pages/feed.xml | head -5
```
Expected: les `<entry>` extraites correctement, ignore le `<?xml-stylesheet?>` directive.

**Step 7.2: Test count entries préservées**

Run: `grep -c '<entry>' /Users/ericmerle/Documents/collatz-gh-pages/feed.xml`
Expected: même nombre qu'avant (audit pré-modification baseline).

**Step 7.3: Validator W3C feed (post-deploy seulement)**

Cette validation se fera post-push origin via https://validator.w3.org/feed/check.cgi?url=https%3A%2F%2Fcollatz-lab.org%2Ffeed.xml

Expected: feed valide Atom 1.0 (pas de regression).

---

## Task 8 — Commit C38 + push origin

**Files:**
- Stage: `feed-style.xsl` (NEW), `feed.xml` (MODIFIED), `docs/plans/2026-05-06-rss-xsl-design.md` (NEW), `docs/plans/2026-05-06-rss-xsl-impl-plan.md` (NEW = ce fichier)

**Step 8.1: Verify état git pre-commit**

Run: `cd /Users/ericmerle/Documents/collatz-gh-pages && git status --short`
Expected:
```
?? docs/plans/2026-05-06-rss-xsl-design.md
?? docs/plans/2026-05-06-rss-xsl-impl-plan.md
?? feed-style.xsl
 M feed.xml
```

**Step 8.2: Stage all C38 files**

```bash
cd /Users/ericmerle/Documents/collatz-gh-pages
git add feed-style.xsl feed.xml docs/plans/2026-05-06-rss-xsl-design.md docs/plans/2026-05-06-rss-xsl-impl-plan.md
git status --short
```

Expected: tous les fichiers en `A` ou `M` (pas de `??`).

**Step 8.3: Commit C38**

```bash
git commit -m "patch RSS UX bug fix C38 (Eric chat 17:00 « drôle de fenêtre RSS » + chat 17:55 cadrage éditorial pro académique pédagogue + chat ~18:00 vote α approche 4 hybride + C 099 vote convergent α (A) + 8 suggestions techniques + garde-fous EXCLUSION §6.23 + EXCLUSION #14 footer Pattern A préservés) : (1) feed-style.xsl créé (XSLT 1.0, ~70 lignes) — transforme feed Atom en HTML5 page lisible côté navigateur (header bilingue FR/EN sobre + subtitle italique + box ambrée mini-explication factuelle 1 paragraphe par langue + box URL avec bouton Copier/Copy clipboard API + fallback range selection + liste entrées Atom titre/date/summary HTML rendu/lien Read on site + footer transparent mention transformation XSL + lien retour), (2) feed.xml ligne 2 directive <?xml-stylesheet type=text/xsl href=/feed-style.xsl?> (entrée v0.6.0 historique L20+32 EXCLUSION §6.23 intacte), (3) docs/plans/2026-05-06-rss-xsl-design.md design doc 9 sections (contexte + 4 approches + décision approche 4 + architecture + error handling + testing + verrous + skip MVP + références), (4) docs/plans/2026-05-06-rss-xsl-impl-plan.md plan implémentation 10 tasks bite-sized (TDD-spirit via UX MCP + xmllint validation + W3C feed check post-deploy) (Phase 4.5 commit C38 RSS UX fix)

Bug UX user-reported Eric dogfooding test : feed.xml mode XML brut Chrome warning « This XML file does not appear to have any style information ». Solution : XSL stylesheet transformation client-side (Hacker News/Substack pattern). Préserve 100% compatibilité readers automatiques (Feedly/Inoreader/NetNewsWire ignorent <?xml-stylesheet?> directive). Approche 4 hybride académique-pédagogue : registre /papers/ sobre factuel, pas /pour-tous/ familier, pas de deep links commerciaux. Cohérent voix Eric Style Guide.

UX runtime test localhost:8080 PASS : header bilingue rendu, intro box ambrée, URL Copy fonctionne, entrées listées avec date/titre/summary/lien, footer transparent, responsive mobile OK.

Anti-régression : xmllint parse OK (readers auto compatibles), W3C feed validator post-deploy.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

**Step 8.4: Verify commit créé**

Run: `git log --oneline -2`
Expected: HEAD = C38 commit, prev = `8cf7395` (C37).

**Step 8.5: Push origin (autonomie A+C maintenue Eric chat 16:18)**

```bash
git push origin gh-pages
```
Expected: `8cf7395..XXXXXXX  gh-pages -> gh-pages`

---

## Task 9 — Audit C indépendant + cross-validation post-push

**Files:**
- (mailbox communication only)

**Step 9.1: Send 100_A→C status post-push**

Composer mailbox file `/Users/ericmerle/Documents/collatz-lab-audit/_mailbox/from_A_to_C/100_A→C_C38_RSS_XSL_SHIPPED.md` :
- Stats commit C38 (4 fichiers)
- UX runtime test résultats
- Anti-régression xmllint OK
- Demande cross-validation C indépendante

**Step 9.2: Wait C polling cycle (~4 min)**

C va probablement émettre `101_C→A` audit indépendant.

**Step 9.3: Si audit C convergent**

Mark Task 9 complete + proceed Task 10.

**Step 9.4: Si audit C divergent**

Itération : commit C39 fix selon feedback C, push, repeat.

---

## Task 10 — UX live test post-Cloudflare propagation

**Files:**
- (test only, live URLs)

**Step 10.1: Wait Cloudflare propagation ~3-5 min**

**Step 10.2: Test live `/feed.xml` rendu HTML**

Run:
```bash
curl -sI https://collatz-lab.org/feed.xml | grep -i "last-modified\|content-type"
```
Expected:
- `last-modified` cohérent push timestamp
- `content-type: application/atom+xml; charset=utf-8`

Via Chrome MCP:
```
1. Navigate to https://collatz-lab.org/feed.xml
2. Screenshot
```
Expected: page HTML rendue (pas XML brut warning).

**Step 10.3: Test live feed-style.xsl accessible**

Run: `curl -sI https://collatz-lab.org/feed-style.xsl`
Expected: HTTP 200, content-type text/xml ou application/xslt+xml.

**Step 10.4: Test reader auto compatibility**

Run:
```bash
curl -s https://collatz-lab.org/feed.xml | head -3
```
Expected:
```
<?xml version="1.0" encoding="utf-8"?>
<?xml-stylesheet type="text/xsl" href="/feed-style.xsl"?>
<feed xmlns="http://www.w3.org/2005/Atom">
```

Run W3C validator manually : https://validator.w3.org/feed/check.cgi?url=https%3A%2F%2Fcollatz-lab.org%2Ffeed.xml
Expected: "This is a valid Atom 1.0 feed."

**Step 10.5: Notify Eric chat pour verification visuelle finale**

Eric peut tester direct via :
- https://collatz-lab.org/feed.xml (devrait s'afficher en page lisible maintenant)

---

## Rollback strategy

Si bug critique post-push (très peu probable car client-side XSL = fallback gracieux) :

1. **Pas de revert force-push** (rule git strict)
2. **Commit C39 fix** : retirer la ligne `<?xml-stylesheet?>` de `feed.xml` (1 ligne supprimée)
3. **Push C39**
4. **Effet** : retour comportement actuel (XML brut Chrome warning), `feed-style.xsl` reste accessible mais inutilisé. Les readers automatiques continuent de fonctionner.

---

## Time budget récap

| Task | Estimé | Cumul |
|---|---|---|
| 1. feed-style.xsl squelette + header | 10 min | 10 min |
| 2. Intro paragraphe + URL box + Copy | 10 min | 20 min |
| 3. Template entrées Atom | 10 min | 30 min |
| 4. Footer + responsive | 5 min | 35 min |
| 5. feed.xml directive | 2 min | 37 min |
| 6. UX MCP runtime test | 10 min | 47 min |
| 7. Anti-régression xmllint | 5 min | 52 min |
| 8. Commit C38 + push | 5 min | 57 min |
| 9. Audit C cross-validation | 5 min | 62 min |
| 10. UX live test | 5 min | 67 min |

**Total** : ~67 min effort A (vs ~40 min initial estimé) — overhead docs + tests TDD-spirit.

---

## Verrous opérationnels (rappel)

1. Pas de push origin sans Eric chat OK ou autonomie A+C maintenue (chat 16:18)
2. Pas de modif EXCLUSIONS originales (#14 footer Pattern A + §6.23 entrée v0.6.0 protégés)
3. Pas de touche identifiant Lean `BakerSeparation`
4. Branche `gh-pages` uniquement (jamais `main`)
5. UX MCP runtime test obligatoire post-apply

---

*Fin de plan d'implémentation RSS XSL — v1.0 — 2026-05-06.*
