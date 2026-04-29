# Branche `arsenal-postjar`

Cette branche héberge l'**arsenal Lean post-JAR** (R34-R96) développé après la soumission JAR
du paper principal sur la branche `main`.

## Contenu

- `ProjetCollatz/PostJAR/` : 13 fichiers Lean (R34-R96 : transport modulaire, décomposition par
  blocs, amplification, axiomes externes, hercher theorem, etc.)
- `tests_math/lean/` : tests isolés (ChatGPTLemmas_test.lean — patches Mathlib v4.27)

## Note importante

Cette branche existe **uniquement** pour permettre au site web cartographique
`https://ericmerle3789.github.io/collatz-conditional-cycles/` de référencer ces fichiers.

**Branche main** : JAR paper soumis (intact, non touché).
**Branche gh-pages** : site web (orphan).
**Cette branche** : arsenal post-JAR (extension de main).

## Statut

Travail en cours. Les patches API Mathlib v4.27 dans `tests_math/lean/ChatGPTLemmas_test.lean`
nécessitent compilation (`lake env lean`) pour validation finale (50-70% probabilité auto-compile
selon Cycle 4 d'autonomie 2026-04-29).

