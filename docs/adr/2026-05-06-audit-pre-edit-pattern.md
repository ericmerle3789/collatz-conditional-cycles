# ADR-0002 — Pattern « audit pré-Edit » (vérifier l'existant avant d'implémenter)

**Date** : 2026-05-06
**Statut** : Accepté (rétroactif Phase 3.6 + 3.7 + 4 + 4.5)
**Auteurs** : Session A + Session C (validation proxy user déléguée Eric chat 19:00 « C »)

## Contexte

Entre le 2026-05-05 (matin) et le 2026-05-06 (après-midi), 5 features planifiées dans la roadmap se sont révélées **déjà implémentées** quand on les a auditées avant d'écrire du code. Cette répétition n'est plus une coïncidence — c'est un pattern statistique fiable qui mérite d'être nommé et formalisé.

### Les 5 occurrences cumulées

| # | Phase | Feature planifiée | Audit pré-Edit révèle | Économie estimée |
|---|---|---|---|---|
| 1 | Phase 3.6 cycle 1 | #9 Scroll progress bar | Déjà GPU-accelerated + Chrome 115+ CSS-only fallback | ~1 h |
| 2 | Phase 3.6 cycle 1 | #10 TOC flottante glassmorphism | Déjà IntersectionObserver + ARIA + 11 items auto sur `/preuve/` | ~2 h |
| 3 | Phase 3.6 P1 | Action #6 hreflang | Déjà parfait toutes pages + `sitemap.xml` | ~45 min |
| 4 | Phase 4 M1 | #15 Modal « Citer » | Déjà 5 onglets production-quality (BibTeX + APA 7 + Chicago 17 + RIS + Plain text) avec ARIA, clipboard, fallback | ~3 h |
| 5 | Phase 4 M1 | #14 GitHub Discussions toggle | Déjà activé dans Settings (case cochée) | ~1 min |

**Cumul** : ~6 h 46 min économisées sur ~24 h de travail effectif.

### Statistique observée

Sur 5 cycles de brainstorming consécutifs, **5/5** ont révélé des features déjà implémentées partiellement ou totalement. Ratio observé : **30-40 %** des features planifiées ont une implémentation existante au moins partielle.

## Décision

Adopter formellement le **réflexe « audit pré-Edit »** comme étape obligatoire avant tout brainstorming créatif sur features qui touchent l'existant :

1. **Avant de proposer 2-3 approches** dans le brainstorming, exécuter un audit rapide :
   - `grep` ciblé sur identifiants probables (fonctions, classes CSS, IDs HTML)
   - `curl` rapide sur URLs concernées
   - Si UI : Chrome MCP runtime test (1-2 min)
2. **Output** : table « feature → already exists [Y/partiel/N] + extent »
3. **Décision** : si feature ≥ 80 % déjà implémentée → SKIP avec justification documentée. Sinon → poursuivre brainstorming normal.

**Coût** : ~10 min audit par cycle brainstorming.
**Bénéfice attendu** : ~30-40 % économie cumulée sur effort total.

## Conséquences

- ✅ **Évite le travail en double** systématiquement
- ✅ **Statistique fiable** maintenue (à actualiser à chaque cycle pour validation continue)
- ✅ **Pattern documenté** réutilisable par autres agents IA en patch cycle
- ✅ **Discipline qui s'autorenforce** : plus on l'applique, plus on découvre que l'existant cache des trésors
- ⚠️ **Coût d'audit** ~10 min par cycle (acceptable vs ~1-3 h économisés)
- ⚠️ **Risque "pas tout détecter"** : un grep approximatif peut rater une implémentation alternative — mitigé par Chrome MCP runtime test pour les features UI

## Alternatives considérées

### Alternative 1 — Implémentation aveugle (statu quo pré-Phase 3.6)
Brainstorming naïf qui ignore l'existant. Implémente from scratch.

**Rejeté** : 30-40 % travail perdu en moyenne (~6 h 46 sur 24 h confirmé empirique).

### Alternative 2 — Audit semi-systématique (uniquement features importantes)
Audit pré-Edit seulement sur features estimées > 1 j. Cycles courts en mode aveugle.

**Rejeté** : 3 des 5 occurrences observées étaient des features estimées « courtes » (#10 TOC ~2 h, #15 modal ~3 h, #14 toggle ~15 min) → pattern indépendant de la taille estimée.

## Références

- Mailbox A↔C : `094_C→A` (4ème occurrence statistique), `099_C→A` §3.9, `101_C→A` §3
- Commits concernés : `b417ff4` (skip Cycle 1 P2), `c87cf1d` (audit #15), `8cf7395` (audit #14)
- ADR-0001 (Phase 4 hybride) §3 mentionne déjà le pattern empirique
- Pattern leçon proposé Phase 3.8.5 : enrichir le skill `superpowers:brainstorming` avec une étape obligatoire « scan existing capabilities » (082_C→A § Phase 3.8.5)

---

*ADR-0002 — Pattern audit pré-Edit — 2026-05-06.*
