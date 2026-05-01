/-
TestsMath.lean — racine de la lib `TestsMath` (Phase 7 CGS-7)

Cette lib regroupe les fichiers Lean de `tests_math/lean/` (tests + théorèmes
post-JAR) sans polluer la lib principale `ProjetCollatz` (paper JAR en review).

Modules :
- ChatGPTLemmas_test : 9 lemmes auxiliaires ChatGPT (drop_forces_s_ge_two, etc.)
- CGS7Theorem : théorème CGS-7 instancié (Phase 3 audit 4 IA convergent)
-/

-- Phase 8 : on n'inclut PAS ChatGPTLemmas_test (4 erreurs Mathlib v4.27 sur
-- des lemmes auxiliaires non utilisés par CGS-7). On utilise CGS7Dependencies
-- qui contient uniquement les 2 lemmes nécessaires patchés v4.27.
import CGS7Dependencies
import CGS7Theorem
