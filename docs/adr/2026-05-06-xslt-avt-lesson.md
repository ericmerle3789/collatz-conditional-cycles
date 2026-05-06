# ADR-0004 — Piège XSLT 1.0 « `{}` dans attributs inline » (AVT)

**Date** : 2026-05-06
**Statut** : Accepté (leçon technique Phase 4.5)
**Auteurs** : Session A + Session C (validation proxy user déléguée Eric chat 19:00 « C »)

## Contexte

Pendant l'exécution du commit C38 (RSS UX bug fix via XSL stylesheet), un bug subtil a fait perdre ~15-20 minutes en debugging Chrome MCP timeout. La cause root, révélée tardivement par `xsltproc` en CLI, est un piège classique mais peu connu de XSLT 1.0.

### Symptôme observé
- Chrome MCP `executeScript` timeout 45 s sur `/feed.xml`
- Console JS vide (aucune erreur visible)
- DOM body length = 0 après `readyState=complete`
- Page d'accueil charge normalement (problème spécifique feed.xml)

### Root cause révélée par xsltproc

```
$ xsltproc feed-style.xsl feed.xml
XPath error : Invalid expression
this.nextElementSibling.style.display='inline';setTimeout(()=>this.nextElementSibling.style.display='none',2000)
                                              ^
compilation error: file feed-style.xsl line 76 element button
Attribute 'onclick': Failed to compile the expression in the AVT.
```

**Diagnostic** : XSLT 1.0 interprète les `{` et `}` dans **n'importe quel attribut HTML** comme une **Attribute Value Template** (AVT) — un mécanisme XSLT pour interpoler des expressions XPath dans des valeurs d'attributs.

Mon code initial avait :
```xml
<button onclick="navigator.clipboard.writeText(url).then(()=>{toast.style.display='inline';...})">
```

Le `{toast.style...}` était lu par XSLT comme une AVT et tentait de l'évaluer comme XPath, échouant immédiatement. Le navigateur recevait alors un XSL invalide → fallback silencieux → DOM vide.

### Pourquoi le bug a été lent à diagnostiquer

1. **Chrome MCP** ne montre que le timeout `executeScript`, pas l'erreur XSL sous-jacente
2. **Console JS vide** : XSL parse-time error n'arrive pas au runtime JS
3. **Page d'accueil OK** : faux signal (le problème est isolé à feed.xml)
4. **xsltproc en CLI** : seul outil qui crache l'erreur claire et exploitable

## Décision

Adopter les règles suivantes pour tout futur fichier XSLT 1.0 dans ce projet :

### Règle 1 — Pas d'attributs HTML inline avec `{` ou `}`
Si l'attribut contient `{` ou `}` (typique en JavaScript moderne avec arrow functions, object literals, blocks) :
- **Refuser inline** : ne pas mettre dans `<button onclick="...">`, `<a href="javascript:...">`, etc.
- **Préférer** : extraire vers un `<script>` séparé, attribuer un `id` à l'élément, attacher l'event listener depuis le script.

### Règle 2 — Wrapper le JS dans CDATA
Pour éviter qu'XSLT n'interprète aussi le JS dans `<script>` content :
```xml
<script>
  <xsl:text disable-output-escaping="yes"><![CDATA[
    (function() {
      // JS normal avec { } sans souci
    })();
  ]]></xsl:text>
</script>
```

### Règle 3 — Tester avec xsltproc CLI avant tout déploiement
Avant de pousser un XSL en local server ou production :
```bash
xsltproc feed-style.xsl feed.xml | head -20
```
Si erreur AVT : visible immédiatement avec ligne + colonne précise.

### Règle 4 — Si on doit absolument mettre `{` littéral dans un attribut AVT-aware
Échapper avec `{{` (deux accolades). Mais c'est illisible et fragile, donc à n'utiliser qu'en dernier recours.

## Conséquences

- ✅ **Code XSLT lisible** : le JS reste lisible dans `<script>`, pas mangled inline
- ✅ **Parser XSLT happy** : aucun risque d'AVT involontaire
- ✅ **Chrome MCP plus de timeout** sur ces pages
- ✅ **Pattern documenté** : tout XSL futur du projet bénéficie de la leçon
- ⚠️ **Coût mineur** : un peu plus verbeux qu'inline, mais largement compensé par debuggabilité

## Alternatives considérées

### Alternative 1 — Échapper `{{` `}}` partout
Garder l'inline `onclick=...` mais doubler chaque `{` et `}`.

**Rejeté** : illisible (`{{toast.style.display='inline';setTimeout(()=>{{toast.style...}},2000)}}`), fragile, difficile à maintenir, propice aux erreurs humaines.

### Alternative 2 — Inline strings concaténation pure
Construire le JS en string concaténation sans accolades : utiliser des if/else ternaires et appels de fonctions nommées.

**Rejeté** : limite considérablement les patterns JS modernes, force du code obscur, ne couvre pas tous les cas (object literals, etc.).

### Alternative 3 — XSLT 2.0+ qui n'a pas le piège AVT
Migration vers XSLT 2.0 ou 3.0 qui ont une syntaxe AVT plus restrictive.

**Rejeté** : Saxon ou autres processors ne sont pas natifs dans Chrome/Firefox/Safari. XSLT 1.0 est le seul niveau supporté côté navigateur. Migrer = perdre la transformation client-side.

## Référence rapide pour futurs cycles

Si tu écris un XSLT 1.0 et que tu vois un timeout Chrome MCP / Firefox / Safari sans erreur claire :
```bash
xsltproc <ton-xsl> <ton-xml-source> 2>&1 | head -20
```
Si « Failed to compile the expression in the AVT » → tu as `{` ou `}` dans un attribut. Refactor en `<script>` séparé.

## Références

- Mailbox A↔C : `100_A→C` §3 (bug découvert + corrigé), `101_C→A` §3 Q3 (ADR proposé)
- Commit : `a10bbef` C38 RSS UX bug fix (refactor onclick → script CDATA)
- Design doc : `docs/plans/2026-05-06-rss-xsl-design.md` §3 architecture
- Plan impl : `docs/plans/2026-05-06-rss-xsl-impl-plan.md` Task 4 + Rollback strategy
- Spec officielle XSLT 1.0 AVT : https://www.w3.org/TR/xslt-10/#dt-attribute-value-template

---

*ADR-0004 — XSLT 1.0 AVT lesson — 2026-05-06.*
