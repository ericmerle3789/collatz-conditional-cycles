# Maintainers — collatz-lab.org

> Ce fichier liste les mainteneurs du site `collatz-lab.org` et le plan de continuité associé.
> **Source canonique** : ce fichier (branche `gh-pages`).
> **Dernière mise à jour** : 2026-05-06.

---

## Primary

| Rôle | Identifiant | Contact |
|------|-------------|---------|
| Auteur, mainteneur principal | **Eric Merle** | GitHub: [@ericmerle3789](https://github.com/ericmerle3789) · ORCID: [0009-0008-7940-402X](https://orcid.org/0009-0008-7940-402X) |
| Affiliation | Chercheur indépendant | — |

**Domaines couverts** :
- Architecture et déploiement du site (`gh-pages` branche)
- Code Lean 4 (`main` + branches dérivées)
- Paper JAR (`paper/v2/`)
- Documentation, FAQ, mea culpa, research-ledger
- Comptes externes (DOI Zenodo, HAL, Lean Zulip, MathOverflow)

---

## Secondary

> **Recrutement en cours**. Ce projet a besoin d'un co-mainteneur Lean-literate
> pour réduire le bus factor (actuellement N=1).

| Rôle souhaité | Statut | Critères |
|---------------|--------|----------|
| Co-mainteneur Lean-literate | **À recruter (post-JAR review)** | Mathlib v4.x contributor, Diophantine analysis, disponibilité 2-4h/mois |
| Co-mainteneur site | **À recruter** | Web statique (HTML/CSS/JS vanilla), GitHub Pages, Cloudflare |

**Comment se proposer** : ouvrir une issue sur le repo `ericmerle3789/collatz-conditional-cycles` ou contacter Eric Merle via ORCID.

**Compensation** : co-authorship paper futur (sur publication post-JAR) ou simple acknowledgment dans le research-ledger, selon contribution.

---

## Community channels

**[GitHub Discussions](https://github.com/ericmerle3789/collatz-conditional-cycles/discussions)** (activé 2026-05-06) — 4 catégories ouvertes :

- 📢 **Announcements** — Mises à jour officielles (posts maintainers uniquement)
- 💬 **General** — Discussions générales sur le projet
- 🔬 **Math discussions** — Théorie Collatz, axiomes, pistes mathématiques, formalisation Lean 4
- 🐛 **Site feedback** — Bugs, suggestions UX, améliorations site `collatz-lab.org`

Pour des questions purement techniques (bugs code, build issues), les [Issues](https://github.com/ericmerle3789/collatz-conditional-cycles/issues) restent disponibles en parallèle.

---

## Continuity plan

### Si le mainteneur principal est inactif > 90 jours

1. **Repo GitHub** : reste public et consultable indéfiniment (politique GitHub pour comptes inactifs).
2. **DOI Zenodo `10.5281/zenodo.19790406`** : archivage long terme garanti par CERN/Zenodo (≥10 ans). PDF v1.0 + sources préservés.
3. **Site `collatz-lab.org`** :
   - Cache Cloudflare survit 10 minutes (`cache-control: max-age=600`).
   - GitHub Pages reste hébergé tant que le compte GitHub n'est pas supprimé.
   - TLS Let's Encrypt expire à J+88 sans renouvellement automatique.
   - Domaine `.org` expire à la prochaine échéance annuelle Cloudflare Registrar.
   - **Estimation accessibilité passive** : 6-12 mois.
4. **Reproduction de la preuve Lean** : self-contained via `bash reproduce.sh` dans le repo. Documentation : `README.md`, `HYPOTHESES.md`, `PROOF_CHAIN.md`, `expected_axioms.md`.

### Si le mainteneur principal souhaite transférer le projet

1. Transférer la propriété du repo GitHub à un mainteneur de confiance.
2. Mettre à jour ce fichier `MAINTAINERS.md`.
3. Créer un nouveau DOI Zenodo (release v1.x+1) avec mention "transition de mainteneur" dans le changelog.
4. Notifier la communauté via Lean Zulip + research-ledger event `type: "repository", subtype: "transfer"`.

### Bus factor cible

- **Actuel** : N=1 (Eric Merle)
- **Cible court terme (post-JAR)** : N=2 (recrutement co-mainteneur Lean-literate)
- **Cible long terme** : N≥3 (NASA-STD-8739.8 software assurance standard)

---

## Contact escalation

| Type | Canal | Délai cible |
|------|-------|-------------|
| Bug / question technique site | [GitHub Issues](https://github.com/ericmerle3789/collatz-conditional-cycles/issues) | 7 jours |
| Question mathématique sur la preuve | [GitHub Discussions](https://github.com/ericmerle3789/collatz-conditional-cycles/discussions) ou Lean Zulip thread | 14 jours |
| Sécurité (RFC 9116) | _En cours de mise en place — `/.well-known/security.txt` à venir_ | 48-72h objectif |
| Citation académique | [ORCID profile](https://orcid.org/0009-0008-7940-402X) | n/a |
| Demande mass-media / vulgarisation | Via ORCID ou GitHub | n/a |

**Note transparence** : ce site est maintenu par un chercheur indépendant. Il n'y a pas
d'institution employeur ni de financement public dédié à ce projet. Toute correction d'erreur
est documentée publiquement dans le [research-ledger](https://collatz-lab.org/research-ledger/)
et dans la section "Vingt-huit mea culpa publics" de la home.

---

## Audit trail

Ce fichier est versionné sur `gh-pages`. Modifications historiques disponibles via :

```bash
git log --follow MAINTAINERS.md
```

**Création** : 2026-05-01 dans le cadre de la mise en œuvre de la roadmap consolidée
post-audit 4 IA (CM5a — cf. `findings/ROADMAP_CONSOLIDEE.md` dans le dossier d'audit privé).

---

## Notes complémentaires

- **CODEOWNERS** : fichier `.github/CODEOWNERS` à créer côté branche `main` post-acceptation JAR
  (interdiction de modifier `main` pendant la review).
- **2FA hardware key** : recommandé pour les comptes GitHub, Cloudflare, Zenodo du mainteneur principal.
- **Branch protection** sur `main` : recommandé post-JAR (require PR + status checks + signed commits).
- **Mirror du repo** : aucun mirror actif identifié (Codeberg, GitLab, Software Heritage).
  Recommandé pour résilience.

— Eric Merle (mainteneur principal), 2026-05-06.
