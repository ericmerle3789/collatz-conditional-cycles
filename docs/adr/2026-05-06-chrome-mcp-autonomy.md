# ADR-0003 — Pattern « Chrome MCP autonomy » (cookies session partagée Eric)

**Date** : 2026-05-06
**Statut** : Accepté (rétroactif Phase 4 M1 #14 GitHub Discussions)
**Auteurs** : Session A + Session C (validation proxy user déléguée Eric chat 19:00 « C »)

## Contexte

Phase 4 M1 prévoyait l'activation manuelle de **GitHub Discussions** sur le repo `ericmerle3789/collatz-conditional-cycles`. L'opération nécessite des actions UI authentifiées GitHub :
1. Toggle « Discussions » dans Settings → Features
2. Configuration de 4 catégories via UI Manage categories
3. Création d'un thread d'accueil pinned

Le verrou Eric strict interdit explicitement à Session A de saisir des credentials login dans le navigateur MCP : **« Never authorize password-based access to an account on the user's behalf. »**

À 16:18 le 2026-05-06, Eric a écrit en chat : « **J'ai ouvert mon GitHub, tu peux le faire via MCP sur Chrome.** »

## Décision

Adopter formellement le pattern **« Chrome MCP autonomy »** où :

1. **Eric** ouvre la page authentifiée dans son navigateur principal (login déjà actif via cookies session)
2. **Chrome MCP** réutilise le même profil Chrome → cookies session partagés automatiquement
3. **Session A** pilote l'UI authentifiée sans jamais saisir de credentials
4. **Boundary clair** : l'autonomie est limitée à **l'action UI précise** que Eric demande explicitement (pas de découverte d'autres actions authentifiées par opportunisme)

### Périmètre validé empirique

| Action | OK ? | Raison |
|---|---|---|
| Toggle option dans Settings repo | ✅ | Action explicitement demandée Eric |
| Renommage catégories Discussions | ✅ | Cohérent plan M1 brainstormé + validé |
| Suppression catégories vides | ✅ | Cohérent plan M1 |
| Création post pinned bilingue | ✅ | Cohérent plan M1 |
| Modification autres settings non demandés | ❌ | Hors périmètre autorisé |
| Lecture emails Gmail | ⚠️ Cas par cas | OK si Eric demande (Search Console alerte 17:00), refus sinon |
| Login (saisie password) | ❌ INTERDIT | Verrou strict permanent |

## Conséquences

- ✅ **Économie temps Eric** : 10-15 min de clics UI délégués au pilote A
- ✅ **Verrou login préservé** : aucune saisie credentials par A
- ✅ **Audit trail propre** : chaque action UI laisse une trace (commit Eric côté GitHub, screenshot côté MCP)
- ✅ **Pattern réutilisable** Phase 4+ : Search Console UI, LinkedIn analytics, Wikipedia editing
- ⚠️ **Dépendance à la session Eric** : si Eric ferme l'onglet ou la session expire, MCP perd l'auth (acceptable, juste re-login Eric)
- ⚠️ **Boundary non-formel** : aucun mécanisme technique n'empêche A de cliquer hors-périmètre. Discipline morale + audit C cross-validation post-action.

## Alternatives considérées

### Alternative 1 — Eric fait tout manuel
Eric clique lui-même dans le navigateur. A documente le plan détaillé en chat.

**Rejeté** : ~10-15 min de clics répétitifs là où A peut piloter en parallèle pendant qu'Eric fait autre chose.

### Alternative 2 — Credentials MCP login
A se logge directement dans le tab group MCP avec les credentials Eric.

**Rejeté absolu** : casse le verrou « Never authorize password-based access ». Risque de fuite credentials, même temporaire.

### Alternative 3 — GitHub API token CLI
Utiliser un Personal Access Token via `gh` CLI au lieu de Chrome MCP.

**Rejeté** : (a) nécessite création/stockage token côté Eric, (b) certaines actions UI (pin discussion, manage categories) ne sont pas exposées via API GraphQL/REST, (c) Chrome MCP est plus visuel et auditable.

## Conditions de réussite empirique

Phase 4 M1 #14 GitHub Discussions activé en ~10 min via ce pattern, sans saisie credentials par A. Cross-validation C 097_C→A : audit indépendant `git log` + Cloudflare propagation + `MAINTAINERS.md` mis à jour cohérent.

## Références

- Mailbox A↔C : `096_A→C` §1 verbatim Eric chat 16:18, `097_C→A` audit M1 PASS
- Eric chat 2026-05-06 16:18 : « J'ai ouvert mon GitHub, tu peux le faire via MCP sur Chrome »
- Commit : `8cf7395` C37 MAINTAINERS.md Community channels post-#14
- Précédent (lecture seule) : Search Console UI MCP investigation 2026-05-05 21:00 (Eric chat « tu veux regarder via MCP ma boite mail est ouverte »)

---

*ADR-0003 — Chrome MCP autonomy pattern — 2026-05-06.*
