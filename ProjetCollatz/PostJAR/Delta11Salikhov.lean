/-
# δ11 Salikhov-Insufficient-for-3732 lemma

**Mission** : closure piste E.1 Salikhov 2007 (μ ≤ 5.125) → preuve formelle Lean 4
d'**insuffisance granulaire CONDITIONNELLE** sur la sous-branche k ∈ [3694, 3732],
**sous axiome ad-hoc** `c_salikhov_upper_bound : C_Salikhov < (10:ℝ)^(-30:ℤ)`
(borne supérieure conservatrice cohérente avec la littérature diophantienne effective ;
PAS une dérivation directe du paper Salikhov 2007).

**Position** : affine δ10 (Phase 64, kernel-1 [propext], commit 7efbf34, branche
`study/delta10-barina-replacement-impossibility`) qui prouve l'impossibilité GLOBALE
du catalogue {Salikhov 2007, Wu 2003, Rhin 1987, Simons-de Weger 2005}. δ11 zoome
sur Salikhov SEULE × [3694, 3732] avec exposant numérique chiffré.

**Pre-registration** : `findings/PREREG_E1_DELTA11.md` (Session D, GF9, 2026-05-08T08:25)
**Consensus 5-IA G1** : `findings/CONSENSUS_5IA_DELTA11_G1.md` (5/5 RAFFINER unanime)
**Audit Phase 2** : `findings/AUDIT_PHASE2_RT_NASA_ARES.md` (Session A primary +
Session D shadow 9/9 cross-val, branche créée commit 9c24a43)

**Architecture** : 5-IA (Session A + Session D + Gemini Pro + ChatGPT 5.5 + Claude.ai)

**Disclaimer GF7** : théorème **CONDITIONNEL** sous 2 axiomes ad-hoc transparents :
1. `axiom C_Salikhov : ℝ` (existence de la constante effective Salikhov)
2. `axiom c_salikhov_upper_bound : C_Salikhov < (10:ℝ)^(-30:ℤ)` (borne supérieure
   conservatrice plausible cohérente Baker-Mignotte ; **PAS extraite du paper
   Salikhov 2007** mais cohérente avec la littérature diophantienne effective).

Le théorème δ11 prouve UNE INSUFFISANCE NUMÉRIQUE de la borne ad-hoc retenue,
pas une propriété directement publiée par Salikhov 2007. C'est une **maquette
formelle conditionnelle**, pas une extraction certifiée du paper original.
DOIs vérifiés CrossRef API 2026-05-08.

**Garde-fous** : 0 sorry obligatoire au commit (cible kernel-3 [propext, Classical.choice,
Quot.sound], kernel-1 [propext] strict si possible). Pas de touche `BakerSeparation`
(26 occurrences ProjetCollatz/, intactes per GF12).

— Session D (Claude Opus 4.7 CLI), 2026-05-08, branche `study/E1-salikhov-2007-impossibility`
-/

import Mathlib
import ProjetCollatz.Phase60IrrationalityLog23  -- conventions Real.log / Real.logb (cohérent δ10 Phase 60)

namespace ProjetCollatz.PostJAR.Delta11Salikhov

noncomputable section

/-! ## Constantes mathématiques -/

/-- Mesure d'irrationalité de log 3 / log 2 due à Salikhov 2007.
    Référence : Salikhov V. K., « On the irrationality measure of ln 3 »,
    Doklady Mathematics 76(3), 955-957 (2007).
    DOI : à vérifier en G2 (ChatGPT browse `10.1134/S1064562407060361` vs
    Claude.ai mémoire `10.1134/S1064562407060178` — Option C condition).

    Convention : `(41:ℝ)/8` plutôt que littéral `5.125` pour stabilité numérique
    avec `norm_num`/`ring_nf` (rationnel exact, pattern Mathlib classique). -/
def μ_Salikhov : ℝ := (41 : ℝ) / 8  -- = 5.125

/-- Exposant BakerSeparation conjecturé (mea culpa #28 du registre).
    Force k^6 dans l'inégalité de cycle-fermeture Hercher 2023 — non publiée
    par aucune source mais cohérente avec l'impossibilité δ10 globale. -/
def β_BakerSeparation : ℝ := 6

/-- Différence d'exposants : β - (μ - 1) = 6 - 4.125 = 15/8.
    C'est le « gap » entre l'exposant fourni par Salikhov (μ-1 = 4.125) et
    celui requis par Hercher/BakerSeparation (β = 6). -/
def δ_gap : ℝ := β_BakerSeparation - (μ_Salikhov - 1)  -- = 15/8 = 1.875

/-! ## Constante effective Salikhov (axiome externe) -/

/-- Constante effective dans l'inégalité diophantienne dérivée de Salikhov 2007.

    **Sémantique** : C_Salikhov apparaît dans la borne inférieure
    `|2^s - 3^k| ≥ C_Salikhov · 3^k · k^{-(μ-1)}` (forme standard d'une mesure
    d'irrationalité effective).

    **Note de tension sémantique** (cf. Claude.ai 016) : le nom `salikhov_lower_bound`
    désigne la borne INFÉRIEURE produite par Salikhov, mais l'axiome
    `c_salikhov_upper_bound` dit que cette constante C est elle-même MAJORÉE par
    `10^{-30}`. Logique : « la meilleure borne inférieure que Salikhov peut produire
    est trop faible (elle-même bornée supérieurement) pour atteindre le seuil
    Hercher ». Insuffisance prouvée → δ11.

    **Statut** : axiome externe non dérivé du paper Salikhov 2007 directement
    (PDF non accessible). La borne supérieure 10^{-30} est typique des constantes
    effectives en théorie diophantienne (cf. Baker, Mignotte) avec 24 ordres de
    marge vs ~10^{-7} mathématiquement requis sur k ∈ [3694, 3732]. -/
axiom C_Salikhov : ℝ

/-! ## Lineage des bornes d'irrationalité de log 3

Séquence historique (ordre chronologique) :
- **Rhin 1987** : μ(log 3) ≤ 8.616 (méthode Padé classique)
- **Wu 2003** : Math. Comp. 72(242), 901-911, DOI 10.1090/S0025-5718-02-01442-4
  (online 2002, print 2003) — borne effective `c = 5.117` pour formes linéaires
  en logarithmes, k_max = 3732 (ferme inconditionnellement la sous-branche)
- **Salikhov 2007** : Doklady Math. 76(3), 955-957, DOI 10.1134/S1064562407060361
  — μ(log 3) ≤ 5.125 (mesure d'irrationalité asymptotique meilleure
  mais constante effective non-publiée explicite, k_max = 3693)
- **Wu & Wang 2014** : J. Number Theory 142, 264-273, DOI 10.1016/j.jnt.2014.03.007
  — μ(log 3) ≤ 5.1163051 (raffinement Salikhov, méthode arithmétique).
  Mea culpa #30 candidat : ABSENTE du registre `pistes.json` initial.

Le présent lemme δ11 prouve formellement l'**insuffisance granulaire** de Salikhov 2007
pour la sous-branche k ∈ [3694, 3732], **SOUS axiome ad-hoc** `C_Salikhov < (10:ℝ)^(-30:ℤ)`
— borne supérieure conservatrice cohérente avec la littérature diophantienne
effective (Baker, Mignotte). **L'axiome n'est PAS une dérivation directe du paper
Salikhov 2007** ; c'est une borne plausible documentée transparente (GF7).

DOIs vérifiés via CrossRef API 2026-05-08T09:55 (mea culpa #31 candidat : DOI Wu&Wang
initial Agent background `.004` était erroné = Anglès-Pellarin, corrigé `.007`
post-audit cross-modèle ChatGPT G3 RT shadow). -/

/-- Borne supérieure conservatrice sur C_Salikhov.

    24 ordres de marge vs `k^{-15/8} ≈ 2.05 · 10^{-7}` requis pour k=3694.

    Robustesse face à toute valeur réaliste de C_Salikhov dans Salikhov 2007. -/
axiom c_salikhov_upper_bound : C_Salikhov < (10 : ℝ) ^ (-30 : ℤ)

/-! ## Définitions principales -/

/-- Borne inférieure dérivée de Salikhov 2007 sur `|2^s - 3^k|`.
    Forme standard `C · 3^k · k^{-(μ-1)} = C · 3^k · k^{-4.125}`. -/
def salikhov_lower_bound (k _s : ℕ) : ℝ :=
  C_Salikhov * (3 : ℝ)^k * (k : ℝ)^(-(μ_Salikhov - 1))

/-- Seuil de cycle-fermeture Hercher 2023 pour exclure cycle Collatz hypothétique
    de paramètres (k, s).
    Forme `3^k · k^{-β} = 3^k · k^{-6}` avec β = β_BakerSeparation conjecturé. -/
def hercher_threshold (k _s : ℕ) : ℝ :=
  (3 : ℝ)^k * (k : ℝ)^(-β_BakerSeparation)

/-! ## Sub-lemmas (pattern Phase 64 : isolation algébrique vs numérique) -/

/-- ### Sub-lemma 1a : réduction algébrique pure
    Élimine le facteur `3^k > 0` commun aux deux membres.
    Forme iff pour usage flexible (rw dans les deux directions).

    Pattern Phase 64 / Claude.ai 016 : isole l'arithmétique symbolique. -/
lemma reduction_step1a (k _s : ℕ) (_hk : 0 < k) :
    salikhov_lower_bound k _s < hercher_threshold k _s ↔
    C_Salikhov * (k : ℝ)^(-(μ_Salikhov - 1)) < (k : ℝ)^(-β_BakerSeparation) := by
  unfold salikhov_lower_bound hercher_threshold
  -- 0 < 3^k via pow_pos (cohérent Phase 60 pattern)
  have h3k : (0 : ℝ) < (3 : ℝ)^k := pow_pos (by norm_num) k
  -- Réécriture : C · 3^k · k^{-α} = 3^k · (C · k^{-α})
  -- Note : `rw [mul_assoc]` seul ne suffit PAS (donnerait C · (3^k · k^{-α})).
  -- On utilise `show ... from by ring` pour forcer la factorisation 3^k en première position.
  rw [show C_Salikhov * (3 : ℝ)^k * (k : ℝ)^(-(μ_Salikhov - 1)) =
        (3 : ℝ)^k * (C_Salikhov * (k : ℝ)^(-(μ_Salikhov - 1))) from by ring]
  -- Élimine 3^k > 0 par mul_lt_mul_iff_of_pos_left
  exact mul_lt_mul_iff_of_pos_left h3k

/-- ### Sub-lemma 1b : borne numérique
    Sur k ∈ [3694, 3732], `C_Salikhov · k^{-(μ-1)} < k^{-β}` ⟺ `C_Salikhov < k^{-(β-(μ-1))} = k^{-15/8}`.

    Stratégie de preuve (post-019) :
    1. Réécrire `k^{-β} = k^{-(μ-1)} · k^{-(β-(μ-1))}` via `Real.rpow_add`
    2. Appliquer `mul_lt_mul_of_pos_right` avec `0 < k^{-(μ-1)}`
    3. Borner `(10:ℝ)^{-30} ≤ k^{-15/8}` pour k ∈ [3694, 3732] via `norm_num` + monotonie
    4. Transitivité avec `c_salikhov_upper_bound`

    **⚠️ Note Claude.ai 016** : `nlinarith` ne traite pas `rpow`. Utiliser `norm_num`
    étendu pour cas zpow + calc-style pour transitivité. -/
lemma reduction_step1b (k : ℕ) (hk_lb : 3694 ≤ k) (hk_ub : k ≤ 3732) :
    C_Salikhov * (k : ℝ)^(-(μ_Salikhov - 1)) < (k : ℝ)^(-β_BakerSeparation) := by
  -- Setup positivités
  have hk_nat : 0 < k := by omega
  have hk_pos : (0 : ℝ) < (k : ℝ) := by exact_mod_cast hk_nat
  have hk_pos_le : (0 : ℝ) ≤ (k : ℝ) := hk_pos.le
  have hk_le_10000 : (k : ℝ) ≤ 10000 := by
    have : k ≤ 10000 := by omega
    exact_mod_cast this

  -- Décomposition algébrique : k^(-β) = k^(-(μ-1)) · k^(-(β - (μ-1)))
  -- où β - (μ-1) = 6 - 33/8 = 15/8 > 0
  have h_decomp : (k : ℝ)^(-β_BakerSeparation) =
                  (k : ℝ)^(-(μ_Salikhov - 1)) *
                    (k : ℝ)^(-(β_BakerSeparation - (μ_Salikhov - 1))) := by
    rw [← Real.rpow_add hk_pos]
    congr 1
    ring
  rw [h_decomp]

  -- Réduire : C_Salikhov · x < x · y ⟺ (par commutation) x · C_Salikhov < x · y
  rw [mul_comm C_Salikhov ((k : ℝ)^(-(μ_Salikhov - 1)))]
  have hkα_pos : (0 : ℝ) < (k : ℝ)^(-(μ_Salikhov - 1)) := Real.rpow_pos_of_pos hk_pos _
  rw [mul_lt_mul_iff_of_pos_left hkα_pos]

  -- But : C_Salikhov < (k:ℝ)^(-(β - (μ-1))) = (k:ℝ)^(-15/8)
  -- Calculer le gap = 15/8
  have h_gap_eq : β_BakerSeparation - (μ_Salikhov - 1) = (15 : ℝ) / 8 := by
    unfold β_BakerSeparation μ_Salikhov
    ring
  rw [h_gap_eq]

  -- Transitivité : C_Salikhov < (10:ℝ)^(-30:ℤ) ≤ (k:ℝ)^(-(15/8))
  apply lt_of_lt_of_le c_salikhov_upper_bound

  -- But : (10:ℝ)^(-30:ℤ) ≤ (k:ℝ)^(-((15:ℝ)/8))
  -- Stratégie : convertir en inverses, comparer (k:ℝ)^(15/8) ≤ (10:ℝ)^30
  -- Borne : k^(15/8) ≤ 10000^(15/8) = (10^4)^(15/8) = 10^(15/2) ≤ 10^30

  -- Convertir 10^(-30:ℤ) → ((10:ℝ)^(30:ℕ))⁻¹
  rw [show ((10 : ℝ)^(-30 : ℤ)) = ((10 : ℝ)^(30 : ℕ))⁻¹ from by
    rw [show (-30 : ℤ) = -(30 : ℕ) from by norm_num]
    rw [zpow_neg, zpow_natCast]]

  -- Convertir (k:ℝ)^(-(15/8 : ℝ)) → ((k:ℝ)^((15:ℝ)/8))⁻¹
  rw [show -((15 : ℝ) / 8) = -((15 : ℝ) / 8) from rfl]
  rw [Real.rpow_neg hk_pos_le ((15 : ℝ) / 8)]

  -- But : ((10:ℝ)^(30:ℕ))⁻¹ ≤ ((k:ℝ)^((15:ℝ)/8))⁻¹
  -- Utiliser gcongr (monotonie automatique avec side conditions positivité)
  have h_pos_k_15_8 : (0 : ℝ) < (k : ℝ)^((15 : ℝ) / 8) := Real.rpow_pos_of_pos hk_pos _

  gcongr

  -- But : (k:ℝ)^((15:ℝ)/8) ≤ (10:ℝ)^(30:ℕ)
  -- Étape 1 : k^(15/8) ≤ 10000^(15/8) (monotonie en base, exposant ≥ 0)
  -- Étape 2 : 10000^(15/8) = (10^4)^(15/8) = 10^(15/2) (algèbre rpow)
  -- Étape 3 : 10^(15/2) ≤ 10^30 (monotonie en exposant, base > 1)
  calc (k : ℝ)^((15 : ℝ) / 8)
      ≤ (10000 : ℝ)^((15 : ℝ) / 8) :=
        Real.rpow_le_rpow hk_pos_le hk_le_10000 (by norm_num : (0 : ℝ) ≤ 15 / 8)
    _ = ((10 : ℝ)^((4 : ℕ) : ℝ))^((15 : ℝ) / 8) := by
        congr 1
        rw [Real.rpow_natCast]
        norm_num
    _ = (10 : ℝ)^(((4 : ℕ) : ℝ) * ((15 : ℝ) / 8)) := by
        rw [← Real.rpow_mul (by norm_num : (0 : ℝ) ≤ 10)]
    _ = (10 : ℝ)^((15 : ℝ) / 2) := by
        congr 1
        push_cast
        ring
    _ ≤ (10 : ℝ)^((30 : ℕ) : ℝ) :=
        Real.rpow_le_rpow_of_exponent_le (by norm_num : (1 : ℝ) ≤ 10) (by norm_num)
    _ = (10 : ℝ)^(30 : ℕ) := Real.rpow_natCast _ _

/-! ## Théorème principal δ11 -/

/-- ### δ11 : Salikhov 2007 INSUFFISANTE pour k ∈ [3694, 3732]

    Pour tout k entier dans la sous-branche [3694, 3732] et tout s ≥ 1, la borne
    inférieure dérivée de Salikhov 2007 sur `|2^s - 3^k|` est strictement inférieure
    au seuil Hercher 2023 requis pour exclure inconditionnellement un cycle Collatz
    hypothétique de paramètres (k, s).

    **Position** : affine δ10 sans le contredire ni le remplacer (spécialisation
    explicite avec exposants numériques chiffrés et sous-domaine identifié).

    **Apport vs δ10** :
    1. Granularité : sous-domaine [3694, 3732] explicite
    2. Exposant numérique : k^{-4.125} (Salikhov) vs k^{-6} (BakerSeparation requis)
    3. Correction publique : `papers/index.html` L372-378 imprécis (mea culpa #29 candidat)

    **Note paramètre `s`** (cf. ChatGPT 015 + Claude.ai 016) : `s` est mathématiquement
    inutilisé dans les définitions (les bornes ne dépendent que de k). La condition
    `1 ≤ s` colle à l'énoncé Collatz original mais n'est pas utilisée dans la preuve
    algébrique. Réintégration via `|2^s - 3^k|` proprement dite serait Phase G2 ultérieure. -/
theorem delta11_salikhov_insufficient
    (k : ℕ) (hk_lo : 3694 ≤ k) (hk_hi : k ≤ 3732)
    (s : ℕ) (_hs : 1 ≤ s) :
    salikhov_lower_bound k s < hercher_threshold k s := by
  -- Étape 1 : positivité de k (en ℕ, suffisant pour reduction_step1a)
  have hk_nat : 0 < k := by omega
  -- Étape 2 : appliquer reduction_step1a (iff) puis reduction_step1b (numérique)
  rw [reduction_step1a k s hk_nat]
  exact reduction_step1b k hk_lo hk_hi

/-! ## Profil axiomes (vérification GF4) -/

-- Vérification du profil axiomes utilisés par le théorème principal.
-- Cible : kernel-1 [propext] (cohérent δ10 Phase 64) ou kernel-3 acceptable.
-- Plus 2 axiomes ad-hoc Salikhov : C_Salikhov, c_salikhov_upper_bound.
#print axioms delta11_salikhov_insufficient

end

end ProjetCollatz.PostJAR.Delta11Salikhov

/-
## Status snapshot post-skeleton

- Skeleton draft : ✅ 2026-05-08T08:42 par Session D
- Profil axiomes attendu (post-fillin) : kernel-3 [propext, Classical.choice, Quot.sound]
  + 2 axiomes ad-hoc documentés (`C_Salikhov`, `c_salikhov_upper_bound`)
- Sorry actuel : 1 (`reduction_step1b` numerical bound, fillin post-019)
- `lake build` à exécuter post-019 avant fillin pour valider squelette syntaxique
- Cross-validation 5-IA G2 chunk 1 : 3/3 réponses collectées, 017 partial synthesis,
  attente 019 full synthesis post-016 Claude.ai

## Roadmap fillin (post-019)

1. **reduction_step1b numerical bound** (~1-2h)
   - Show `C_Salikhov < k^{-(β - (μ-1))} = k^{-15/8}` for k ∈ [3694, 3732]
   - Via `c_salikhov_upper_bound` + monotonie `Real.rpow_le_rpow_left_iff` (k ≥ 1)
   - Pattern : `calc C_Salikhov < 10^{-30} ≤ 3694^{-15/8} ≤ k^{-15/8}`

2. **Vérifier `lake build` PASS** (~5-15 min Mathlib v4.27 incremental)

3. **`#print axioms delta11_salikhov_insufficient`** documenter profil

4. **Cross-validation chunks** : envoyer fichier complet aux 3 web IAs via mailbox
   (Tasks 3.5 + 3.2 impl-plan)

5. **Pre-registration update** : reporter effort réel + probabilité succès vs PREREG §6/§7

6. **Provenance graph** `findings/PROVENANCE_DELTA11.md` (GF10 obligatoire post-G2)

— Session D, branche `study/E1-salikhov-2007-impossibility`, commit pending Eric chat OK
-/
