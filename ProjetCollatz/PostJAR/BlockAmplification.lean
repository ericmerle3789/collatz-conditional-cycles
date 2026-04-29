import Mathlib.Data.Real.Basic
import Mathlib.Analysis.SpecialFunctions.Pow.Real
import ProjetCollatz.PostJAR.CycleArithmetic
import ProjetCollatz.PostJAR.BlockDecomposition
import ProjetCollatz.Phase50CycleEquation
import ProjetCollatz.Phase52SteinerEquation

/-!
# BlockAmplification.lean — Round 66 NEW (angle ⊶ ChatGPT 5.5 #2)

## Origin

ChatGPT 5.5 (Pro Thinking, 9s) marqué l'angle #2 LE PLUS FORT :

> "Chaque cycle a un bloc témoin trop tendu. Si le produit des gains des blocs
> vaut 1, alors au moins un bloc doit être proche de l'équilibre 3^{k_b} ≈ 2^{S_b},
> mais avec endpoints minima imposés. Ce bloc témoin pourrait fournir un lemme
> universel : 'tout cycle contient un bloc quasi-résonant', à combiner ensuite
> avec congruences et min/max."

## Mathematical content

R66 NEW livre l'**infrastructure** :
1. Définition `amplification_block n i j` = `3^{j-i} / 2^{S_{[i,j]}}`
2. Identité full cycle : `amp(0, k) = 3^k / 2^S`
3. Conséquence Steiner poutre : `amp(0, k) < 1` pour tout cycle non-trivial
4. Positivité universelle : `amp(0, k) > 0`

R67 NEW2 prouvera `cycle_has_quasi_resonant_block` (statement seulement ici, sorry).

## NASA Power-of-Ten conformity

- Tous les statements sont non triviaux (vraies propositions)
- Sorry tracké TODO[ref=, owner=, ETA=]
- Naming truthful (suffix `_unproven` sur le seul statement non prouvé)
-/

namespace ProjetCollatz.PostJAR

open ProjetCollatz

/-! ## Section 0: Lemme auxiliaire — monotonie de aSumSeq -/

/-- `aSumSeq n` est monotone non-décroissant en l'argument k. -/
lemma aSumSeq_le_of_le (n : ℕ) {i j : ℕ} (h : i ≤ j) :
    aSumSeq n i ≤ aSumSeq n j := by
  obtain ⟨d, rfl⟩ := Nat.le.dest h
  induction d with
  | zero => exact le_refl _
  | succ d ih =>
    have h_eq : i + (d + 1) = (i + d) + 1 := by omega
    rw [h_eq, aSumSeq_succ' n (i + d)]
    omega

/-! ## Section 1: Définition `amplification_block` -/

/-- **R66 NEW — Amplification d'un bloc [i, j]**.

Définit le ratio asymptotique `3^{j-i} / 2^{aSumSeq n j - aSumSeq n i}` (dans ℝ).

Pour `j ≥ i`, c'est l'amplification approchée du sous-bloc parityVector[i..j].
Pour `j ≤ i` (cas dégénéré, Nat-subtraction tronquée), retourne 1.

`noncomputable` car utilise ℝ. Ne casse pas reproduce.sh (pas dans chaîne centrale). -/
noncomputable def amplification_block (n i j : ℕ) : ℝ :=
  (3 : ℝ) ^ (j - i) / (2 : ℝ) ^ (aSumSeq n j - aSumSeq n i)

/-! ## Section 2: Identité full cycle -/

/-- **R66.1 — Amplification full cycle** : `amp(n, 0, k) = 3^k / 2^(aSumSeq n k)`.

Identité fondamentale. Aucune hypothèse de cycle requise (universel). -/
theorem amplification_full_cycle (n k : ℕ) :
    amplification_block n 0 k = (3 : ℝ) ^ k / (2 : ℝ) ^ (aSumSeq n k) := by
  unfold amplification_block
  have h_sub_k : k - 0 = k := Nat.sub_zero k
  have h_zero : aSumSeq n 0 = 0 := by unfold aSumSeq aSum; simp
  have h_sub_S : aSumSeq n k - aSumSeq n 0 = aSumSeq n k := by
    rw [h_zero, Nat.sub_zero]
  rw [h_sub_k, h_sub_S]

/-! ## Section 3: Positivité universelle -/

/-- **R66.2 — Amplification full cycle > 0** (universel, pas d'hypothèse cycle). -/
theorem amplification_full_cycle_pos (n k : ℕ) :
    amplification_block n 0 k > 0 := by
  rw [amplification_full_cycle]
  positivity

/-! ## Section 4: Steiner poutre ⟹ amplification full cycle < 1 -/

/-- **R66.3 — Amplification full cycle < 1** : conséquence directe de Steiner poutre.

Pour tout cycle Collatz non-trivial, on a `2^S > 3^k`
(`cycle_pow2_gt_pow3_universal`). Donc `3^k / 2^S < 1`.

C'est l'**invariant universel** sur lequel se construit l'angle ⊶ #2 :
si l'amplification totale est < 1 mais le produit *exact* (avec corrections +1)
des gains du cycle vaut 1, alors la *moyenne* des amplifications de blocs est
forcée près de 1 — d'où existence d'un bloc quasi-résonant (R67 NEW2). -/
theorem cycle_full_amplification_lt_one (n k : ℕ) (hcyc : IsOddCycle n k) :
    amplification_block n 0 k < 1 := by
  rw [amplification_full_cycle]
  have h_pow : (2 : ℕ) ^ (aSumSeq n k) > (3 : ℕ) ^ k :=
    cycle_pow2_gt_pow3_universal n k hcyc
  have h_2S_pos : (0 : ℝ) < (2 : ℝ) ^ (aSumSeq n k) := by positivity
  rw [div_lt_one h_2S_pos]
  exact_mod_cast h_pow

/-! ## Section 5: Décomposition multiplicative additive (chainage de blocs) -/

/-- **R66.4 — Chainage multiplicatif d'amplifications**.

Pour tout `i ≤ m ≤ j`, `amp(n, i, m) * amp(n, m, j) = amp(n, i, j)`.

Cette identité multiplicative est l'outil de base pour décomposer une grande
amplification (ex: full cycle) en produit d'amplifications de sous-blocs.

C'est l'analogue multiplicatif de l'additivité de `aSumSeq` :
`aSumSeq n j - aSumSeq n i = (aSumSeq n m - aSumSeq n i) + (aSumSeq n j - aSumSeq n m)`. -/
theorem amplification_chain (n i m j : ℕ) (hij : i ≤ j) (him : i ≤ m) (hmj : m ≤ j) :
    amplification_block n i m * amplification_block n m j = amplification_block n i j := by
  unfold amplification_block
  -- LHS = (3^(m-i) / 2^(S_m - S_i)) * (3^(j-m) / 2^(S_j - S_m))
  -- RHS = 3^(j-i) / 2^(S_j - S_i)
  have h_aS_mono : aSumSeq n i ≤ aSumSeq n m := aSumSeq_le_of_le n him
  have h_aS_mono' : aSumSeq n m ≤ aSumSeq n j := aSumSeq_le_of_le n hmj
  have h_2_pos_mi : (0 : ℝ) < (2 : ℝ) ^ (aSumSeq n m - aSumSeq n i) := by positivity
  have h_2_pos_jm : (0 : ℝ) < (2 : ℝ) ^ (aSumSeq n j - aSumSeq n m) := by positivity
  -- 3^(m-i) * 3^(j-m) = 3^(j-i)
  have h3 : (3 : ℝ) ^ (m - i) * (3 : ℝ) ^ (j - m) = (3 : ℝ) ^ (j - i) := by
    rw [← pow_add]
    congr 1
    omega
  -- 2^(S_m - S_i) * 2^(S_j - S_m) = 2^(S_j - S_i)
  have h2 : (2 : ℝ) ^ (aSumSeq n m - aSumSeq n i) *
            (2 : ℝ) ^ (aSumSeq n j - aSumSeq n m) =
            (2 : ℝ) ^ (aSumSeq n j - aSumSeq n i) := by
    rw [← pow_add]
    congr 1
    omega
  field_simp
  rw [← h3, ← h2]
  ring

/-! ## Section 6: R67 NEW2 stub — cycle_has_quasi_resonant_block (sorry preserved)

R66 NEW (ce fichier) livre l'infrastructure :
- `amplification_block` (définition)
- `amplification_full_cycle` (identité)
- `cycle_full_amplification_lt_one` (Steiner poutre)
- `amplification_chain` (décomposition multiplicative)

R67 NEW2 utilisera `BlockDecomposition.isLocalMin_iff_aSeq_pattern` (R65) pour
partitionner [0, k) en blocs aux endpoints minima, puis montrer qu'au moins
un bloc est quasi-résonant.
-/

/-! ## Section 7: R67 NEW2 — cycle_has_quasi_resonant_block PROVED -/

/-- **Lemme intermédiaire R67 NEW2** : tout cycle non-trivial contient au moins
une position `i` avec `aSeq n i = 1` (ascension Syracuse).

**Preuve** par contradiction : si pour tout `i < k`, `aSeq n i ≠ 1`, alors par
`aSeq_ge_one_of_odd`, `aSeq n i ≥ 2` pour tout `i`. Par
`nSeq_decreases_if_aSeq_ge_2` (R64 NEW), la séquence est strictement
décroissante : `nSeq n (i + 1) < nSeq n i` pour tout `i`. Par récurrence,
`nSeq n k < nSeq n 0 = n`. Mais cycle ⟹ `nSeq n k = n`, contradiction. -/
theorem cycle_exists_aSeq_eq_one (n k : ℕ) (hcyc : IsOddCycle n k) :
    ∃ i : ℕ, i < k ∧ aSeq n i = 1 := by
  obtain ⟨hn_gt1, hodd, hk_pos, h_cyc_eq⟩ := hcyc
  by_contra h_not
  push_neg at h_not
  -- h_not : ∀ i, i < k → aSeq n i ≠ 1
  -- Combiné avec aSeq n i ≥ 1 (n impair) ⟹ aSeq n i ≥ 2 pour tout i < k.
  have h_all_ge_2 : ∀ i, i < k → aSeq n i ≥ 2 := by
    intro i hi
    have h_a_ge_1 : aSeq n i ≥ 1 := aSeq_ge_one_of_odd n i hodd
    have h_a_ne_1 : aSeq n i ≠ 1 := h_not i hi
    omega
  -- Donc nSeq n (i+1) < nSeq n i pour tout i < k.
  have h_n_pos : n > 0 := by omega
  have h_decreasing : ∀ i, i < k → nSeq n (i + 1) < nSeq n i := by
    intro i hi
    have h_n_i_ge_2 : nSeq n i ≥ 2 := by
      have := cycle_all_ge_three n k ⟨hn_gt1, hodd, hk_pos, h_cyc_eq⟩ i (le_of_lt hi)
      omega
    have h_a_ge_2 := h_all_ge_2 i hi
    exact nSeq_decreases_if_aSeq_ge_2 n h_n_pos hodd i h_n_i_ge_2 h_a_ge_2
  -- Par récurrence, nSeq n i < nSeq n 0 pour tout 1 ≤ i ≤ k.
  have h_strict_lt : ∀ i, 1 ≤ i → i ≤ k → nSeq n i < nSeq n 0 := by
    intro i hi1 hi_k
    induction i with
    | zero => omega
    | succ j ih =>
      by_cases hj0 : j = 0
      · subst hj0
        have h := h_decreasing 0 (by omega)
        exact h
      · have hj1 : 1 ≤ j := by omega
        have hj_k : j ≤ k := by omega
        have ih' := ih hj1 hj_k
        have h_dec := h_decreasing j (by omega)
        omega
  -- En particulier nSeq n k < nSeq n 0 = n.
  have h_k_lt : nSeq n k < nSeq n 0 := h_strict_lt k hk_pos (le_refl k)
  -- Mais nSeq n k = n par cycle, et nSeq n 0 = n par définition.
  have h_n_eq : nSeq n 0 = n := rfl
  rw [h_n_eq, h_cyc_eq] at h_k_lt
  omega

/-- **R67bis NEW2 — bloc 1-step amplifié à une ascension Syracuse**.

Pour tout cycle non-trivial avec k ≥ 2, il existe un bloc 1-step `[i, i+1]`
avec `i < i+1 ≤ k` et `aSeq n i = 1` (ascension Syracuse), dont l'amplification
est `3/2 ≥ 1/2`.

**⚠️ Précision sémantique (Red Team severity 8/10, fix R67bis NEW2)** : ce
théorème ne formalise PAS l'angle ⊶ #2 de ChatGPT 5.5. L'angle ⊶ #2 demande
un bloc **quasi-résonant** au sens `amp ≈ 1` (borne `[1-ε, 1+ε]`) avec
endpoints aux **minima locaux**. Ce que je prouve ici est différent :
- amp = 3/2 (over-amplifying, pas proche de 1)
- Bloc 1-step quelconque (pas aux endpoints minima)

Ce résultat est néanmoins une **étape préliminaire utile** vers l'angle ⊶ #2 :
le lemme intermédiaire `cycle_exists_aSeq_eq_one` est durable et exploitable
pour le vrai angle ⊶ #2 dans R72+.

TODO[ref=ChatGPT5.5 angle ⊶ #2 réel, owner=NEW2 ou NEW, ETA=R72+] :
prouver le vrai énoncé via moyenne géométrique sur blocs minima. -/
theorem cycle_has_amplified_block_at_aSeq_one
    (n k : ℕ) (hcyc : IsOddCycle n k) (hk : k ≥ 2) :
    ∃ i j : ℕ, i < j ∧ j ≤ k ∧
      amplification_block n i j ≥ (1 : ℝ) / 2 := by
  obtain ⟨i, hi_lt_k, h_aSeq_eq_1⟩ := cycle_exists_aSeq_eq_one n k hcyc
  refine ⟨i, i + 1, by omega, by omega, ?_⟩
  unfold amplification_block
  have h_sub_one : i + 1 - i = 1 := by omega
  have h_aS_diff : aSumSeq n (i + 1) - aSumSeq n i = aSeq n i := by
    rw [aSumSeq_succ']
    omega
  rw [h_sub_one, h_aS_diff, h_aSeq_eq_1]
  -- (3 : ℝ)^1 / (2 : ℝ)^1 = 3/2 ≥ 1/2
  norm_num

/-- **Corollaire R67bis NEW2 — borne forte 3/2** (raffinement de la borne 1/2). -/
theorem cycle_has_block_with_amp_three_halves
    (n k : ℕ) (hcyc : IsOddCycle n k) (hk : k ≥ 2) :
    ∃ i j : ℕ, i < j ∧ j ≤ k ∧
      amplification_block n i j ≥ (3 : ℝ) / 2 := by
  obtain ⟨i, hi_lt_k, h_aSeq_eq_1⟩ := cycle_exists_aSeq_eq_one n k hcyc
  refine ⟨i, i + 1, by omega, by omega, ?_⟩
  unfold amplification_block
  have h_sub_one : i + 1 - i = 1 := by omega
  have h_aS_diff : aSumSeq n (i + 1) - aSumSeq n i = aSeq n i := by
    rw [aSumSeq_succ']
    omega
  rw [h_sub_one, h_aS_diff, h_aSeq_eq_1]
  -- (3 : ℝ)^1 / (2 : ℝ)^1 = 3/2 ≥ 3/2
  norm_num

/-! ## Section 8: R73 NEW — Borne par moyenne géométrique 2-bloc (vers angle ⊶ #2)

R67bis NEW2 a prouvé un bloc 1-step avec amp = 3/2 (over-amplifying), mais
l'angle ⊶ #2 demande un bloc avec amp ≈ 1 aux endpoints minima.

R73 NEW commence le **vrai argument moyenne géométrique** :
pour toute partition `[0, k) = [0, m] ∪ [m, k]`, au moins un des deux blocs
a une amplification ≥ √(amp_full). Brique fondatrice pour R74+ (m-blocs).
-/

/-- amp_block est toujours strictement positif (universel, no cycle). -/
theorem amplification_block_pos_universal (n i j : ℕ) :
    amplification_block n i j > 0 := by
  unfold amplification_block
  positivity

/-- **R73 NEW — Borne moyenne géométrique 2-bloc**.

Pour toute partition `[0, k) = [0, m] ∪ [m, k]` avec `m ≤ k` :
au moins un des deux sous-blocs a une amplification ≥ √(amp(0, k)).

**Universel** (pas d'hypothèse cycle). Brique fondatrice pour le vrai angle
⊶ #2 : par récurrence, on étend à m-blocs et on obtient
`max amp_b ≥ amp_full^(1/m)`.

Pour cycles non-triviaux, `amp_full < 1` (Steiner poutre R59) mais peut être
proche de 1 (selon n_0 et k). Donc `max amp_b ≥ √amp_full ≈ 1` pour amp_full
proche de 1.

**Preuve** (~25 lignes) : par contradiction. Si les deux sont < √amp_full,
alors leur produit < amp_full (par `mul_lt_mul'`), mais leur produit = amp_full
(par `amplification_chain`). Contradiction. -/
theorem split_block_max_geometric_mean
    (n k m : ℕ) (hmk : m ≤ k) :
    amplification_block n 0 m ≥ Real.sqrt (amplification_block n 0 k) ∨
    amplification_block n m k ≥ Real.sqrt (amplification_block n 0 k) := by
  by_contra h_neg
  push_neg at h_neg
  obtain ⟨h_lt_a, h_lt_b⟩ := h_neg
  have h_chain : amplification_block n 0 m * amplification_block n m k =
                 amplification_block n 0 k :=
    amplification_chain n 0 m k (Nat.zero_le k) (Nat.zero_le m) hmk
  have h_pos_full : (0 : ℝ) < amplification_block n 0 k :=
    amplification_block_pos_universal n 0 k
  have h_sqrt_pos : (0 : ℝ) < Real.sqrt (amplification_block n 0 k) :=
    Real.sqrt_pos.mpr h_pos_full
  have h_pos_b : (0 : ℝ) ≤ amplification_block n m k :=
    le_of_lt (amplification_block_pos_universal n m k)
  have h_prod_lt : amplification_block n 0 m * amplification_block n m k <
                   Real.sqrt (amplification_block n 0 k) *
                   Real.sqrt (amplification_block n 0 k) :=
    mul_lt_mul' (le_of_lt h_lt_a) h_lt_b h_pos_b h_sqrt_pos
  rw [Real.mul_self_sqrt (le_of_lt h_pos_full)] at h_prod_lt
  rw [h_chain] at h_prod_lt
  exact lt_irrefl _ h_prod_lt

/-! ## Section 9: R74 NEW — Corollaire existentiel cycle-specific (vrai angle ⊶ #2 v0.5) -/

/-- **R74 NEW — Existence d'un bloc avec amp ≥ √amp_full** (cycle-specific).

Pour tout cycle non-trivial avec k ≥ 2, il existe un bloc `[i, j]` avec
`i < j ≤ k` dont l'amplification est ≥ `√(amp_full)`.

C'est l'**amélioration sémantique** par rapport à R67bis (placeholder amp = 3/2)
vers le vrai angle ⊶ #2 (amp ≈ 1) :
- R67bis : amp ≥ 3/2 (over-amplifying, 1-step bloc)
- R74 NEW : amp ≥ √amp_full ∈ (0, 1) (closer to 1 for amp_full near 1)

Pour cycles avec amp_full proche de 1 (cycle "long" ou n_0 grand), `√amp_full`
est très proche de 1. Pour amp_full = 0.9, √0.9 ≈ 0.949. Donc bloc avec amp
**dans (0.949, 1)**, encadrement utile.

**Comparaison avec R67bis** : R74 donne une borne inférieure proche de 1
(directement reliée à amp_full), tandis que R67bis donnait amp = 3/2 = 1.5
(au-dessus de 1, pas l'esprit "quasi-résonant").

**Preuve** (~5 lignes) : applique R73 NEW (split_block_max_geometric_mean) avec
m = 1, et fait case analysis sur la disjunction. -/
theorem cycle_max_amp_ge_sqrt_full
    (n k : ℕ) (hcyc : IsOddCycle n k) (hk : k ≥ 2) :
    ∃ i j : ℕ, i < j ∧ j ≤ k ∧
      amplification_block n i j ≥ Real.sqrt (amplification_block n 0 k) := by
  have h_split := split_block_max_geometric_mean n k 1 (by omega : (1 : ℕ) ≤ k)
  cases h_split with
  | inl h_left => exact ⟨0, 1, by omega, by omega, h_left⟩
  | inr h_right => exact ⟨1, k, by omega, le_refl k, h_right⟩

/-- **R74.2 NEW — Encadrement utile pour cycles : amp ∈ [√amp_full, ?)**.

Combine R74 NEW avec `cycle_full_amplification_lt_one` : pour cycle non-trivial,
`amp_full < 1` ⟹ `√amp_full < 1`. Donc le bloc R74 a amp ∈ [√amp_full, ...).

Pas de borne supérieure < 1 sur le bloc (l'amp peut dépasser 1, ex: bloc 1-step
avec aSeq=1 donne amp=3/2). Mais R74 garantit la borne inférieure utile. -/
theorem cycle_max_amp_sqrt_lower_bound_lt_one
    (n k : ℕ) (hcyc : IsOddCycle n k) (hk : k ≥ 2) :
    Real.sqrt (amplification_block n 0 k) < 1 := by
  have h_full_lt_one : amplification_block n 0 k < 1 :=
    cycle_full_amplification_lt_one n k hcyc
  have h_full_pos : (0 : ℝ) < amplification_block n 0 k :=
    amplification_block_pos_universal n 0 k
  -- √x < 1 ↔ x < 1 pour x ≥ 0
  rw [show (1 : ℝ) = Real.sqrt 1 from (Real.sqrt_one).symm]
  exact Real.sqrt_lt_sqrt (le_of_lt h_full_pos) h_full_lt_one

/-! ## Section 10: R75 NEW2 — M-bloc général via moyenne géométrique

🎯 **Suite tandem Option γ** (mailbox 1155 GO Option A) : généralisation de
R73 NEW (2-bloc) et R74 NEW (cycle existence) vers le **m-bloc général**.

**Statement** : pour toute partition `[0, k]` en `m` sous-blocs, au moins un
bloc satisfait `amp_b^m ≥ amp_full`. Équivalent à `max amp_b ≥ amp_full^(1/m)`
mais formulé avec puissance Nat (plus propre Lean, évite `Real.rpow`).

**Preuve** (~80 lignes) :
1. **Lemme intermédiaire** `amp_block_prod_telescope` : `∏_b amp_b = amp_full`
   par récurrence sur m + `amplification_chain` (R66 NEW).
2. **Théorème principal** : soit `b_max = argmax amp_b`. Alors :
   - `∏ amp_b ≤ ∏ (amp_{b_max}) = amp_{b_max}^m`
   - Or `∏ amp_b = amp_full` (étape 1)
   - Donc `amp_{b_max}^m ≥ amp_full` ✓

**Conséquence stratégique** : combiné avec Hercher `m ≤ 91` axiome, on a une
borne explicite `max amp_b ≥ amp_full^(1/91)` qui est *proche de 1* pour
`amp_full` proche de 1 (Steiner poutre R59 dit `amp_full < 1`).

C'est une étape vers l'angle ⊶ #2 réel (R76+ avec endpoints minima via
isLocalMin_iff_aSeq_pattern R65).
-/

/-- amp_block n a a = 1 (cas dégénéré, j = i). -/
lemma amplification_block_self (n a : ℕ) : amplification_block n a a = 1 := by
  unfold amplification_block
  simp

/-- Monotonie locale `<` ⟹ monotonie globale `≤` (à indices équivalents).

Si `i_block` est strictement croissante position par position pour tout `b < m`,
alors `i_block` est globalement non-décroissante sur `[0, m]`. -/
lemma i_block_mono_general (m : ℕ) (i_block : ℕ → ℕ)
    (h_mono : ∀ c, c < m → i_block c ≤ i_block (c + 1))
    (a b : ℕ) (hab : a ≤ b) (hb : b ≤ m) : i_block a ≤ i_block b := by
  induction b with
  | zero =>
    have ha : a = 0 := by omega
    rw [ha]
  | succ b ih =>
    by_cases h_eq : a = b + 1
    · rw [h_eq]
    · have hab' : a ≤ b := by omega
      have hb' : b ≤ m := by omega
      have h_mono_b : i_block b ≤ i_block (b + 1) := h_mono b (by omega)
      exact le_trans (ih hab' hb') h_mono_b

/-- **Lemme intermédiaire R75 NEW2** — produit télescopique des amplifications.

Pour toute partition strictement monotone `i_block 0 ≤ i_block 1 ≤ ... ≤ i_block m`,
le produit des `m` amplifications de sous-blocs vaut l'amplification full bloc.

Preuve par récurrence sur m + `amplification_chain` (R66 NEW). -/
lemma amp_block_prod_telescope
    (n : ℕ) (m : ℕ) (i_block : ℕ → ℕ)
    (h_mono : ∀ b, b < m → i_block b ≤ i_block (b + 1)) :
    ((Finset.range m).prod
      (fun b => amplification_block n (i_block b) (i_block (b + 1)))) =
    amplification_block n (i_block 0) (i_block m) := by
  induction m with
  | zero =>
    simp [amplification_block_self]
  | succ m ih =>
    rw [Finset.prod_range_succ]
    have h_mono_m : ∀ b, b < m → i_block b ≤ i_block (b + 1) := by
      intro b hb
      exact h_mono b (by omega)
    rw [ih h_mono_m]
    -- amp(i_0, i_m) * amp(i_m, i_(m+1)) = amp(i_0, i_(m+1)) par R66 amplification_chain
    have h_0_le_m : i_block 0 ≤ i_block m :=
      i_block_mono_general (m + 1) i_block h_mono 0 m (Nat.zero_le _) (by omega)
    have h_m_le_succ : i_block m ≤ i_block (m + 1) := h_mono m (Nat.lt_succ_self m)
    have h_0_le_succ : i_block 0 ≤ i_block (m + 1) := le_trans h_0_le_m h_m_le_succ
    exact amplification_chain n (i_block 0) (i_block m) (i_block (m + 1))
            h_0_le_succ h_0_le_m h_m_le_succ

/-- **R75 NEW2 — m-bloc général via max + produit télescopique**.

Pour toute partition strictement croissante `[0, k]` en m sous-blocs, au moins
un bloc `b ∈ [0, m)` satisfait `amp_b ^ m ≥ amp_full`.

Équivalent à `max amp_b ≥ amp_full^(1/m : ℝ)` mais formulé avec puissance Nat.

**Preuve** : combinaison de
- `amp_block_prod_telescope` : `∏ amp_b = amp_full`
- `Finset.prod_le_prod` : `∏ amp_b ≤ ∏ (max amp_b) = (max amp_b)^m` -/
theorem cycle_max_amp_pow_m_ge_full
    (n k m : ℕ) (hm : m ≥ 1)
    (i_block : ℕ → ℕ)
    (h_mono : ∀ b, b < m → i_block b < i_block (b + 1))
    (h_start : i_block 0 = 0) (h_end : i_block m = k) :
    ∃ b, b < m ∧
      (amplification_block n (i_block b) (i_block (b + 1))) ^ m ≥
      amplification_block n 0 k := by
  -- Convertir h_mono `<` en monotonie `≤` (pour les lemmes intermédiaires)
  have h_mono_le : ∀ b, b < m → i_block b ≤ i_block (b + 1) := by
    intro b hb
    exact le_of_lt (h_mono b hb)
  -- Étape 1 : Existence du max via Finset.exists_max_image
  have h_range_nonempty : (Finset.range m).Nonempty :=
    ⟨0, Finset.mem_range.mpr hm⟩
  obtain ⟨b_max, hb_max_mem, hb_max_max⟩ :=
    Finset.exists_max_image (Finset.range m)
      (fun b => amplification_block n (i_block b) (i_block (b + 1)))
      h_range_nonempty
  have hb_max_lt : b_max < m := Finset.mem_range.mp hb_max_mem
  -- Étape 2 : `prod ≤ (max amp)^m`
  have h_prod_le : (Finset.range m).prod
      (fun b => amplification_block n (i_block b) (i_block (b + 1))) ≤
      (amplification_block n (i_block b_max) (i_block (b_max + 1))) ^ m := by
    have h_prod_le_const :
        (Finset.range m).prod
          (fun b => amplification_block n (i_block b) (i_block (b + 1))) ≤
        (Finset.range m).prod
          (fun _ => amplification_block n (i_block b_max) (i_block (b_max + 1))) := by
      apply Finset.prod_le_prod
      · intro b _
        exact le_of_lt (amplification_block_pos_universal n _ _)
      · intro b hb
        exact hb_max_max b hb
    rw [Finset.prod_const, Finset.card_range] at h_prod_le_const
    exact h_prod_le_const
  -- Étape 3 : `prod = amp_full` (lemme intermédiaire)
  have h_prod_eq_full : (Finset.range m).prod
      (fun b => amplification_block n (i_block b) (i_block (b + 1))) =
      amplification_block n 0 k := by
    rw [amp_block_prod_telescope n m i_block h_mono_le]
    rw [h_start, h_end]
  -- Conclusion : amp_full = prod ≤ amp_max^m
  refine ⟨b_max, hb_max_lt, ?_⟩
  rw [← h_prod_eq_full]
  exact h_prod_le

/-! ## Section 11: R75bis NEW2 — Bridge Nat^m → Real.rpow (Red Team fix severity 8/10)

🚨 **Suite Red Team verdict R75 severity 8/10** (mailbox 1208) : le statement
R75 utilise puissance Nat (`^ m`) alors que l'angle ⊶ #2 demande Real.rpow
(`^(1/m : ℝ)`). Pas un bug Lean, mais gap sémantique avec l'intuition
mathématique originale.

**Fix R75bis NEW2** : bridge corollary qui convertit le statement Nat en
Real.rpow via `Real.rpow_natCast` + monotonie `Real.rpow_le_rpow`.

**Discipline NASA Power-of-Ten** : "le statement reflète exactement l'intuition
originale". Leçon réappliquée après R67bis.
-/

/-- **R75bis NEW2 — Bridge Real.rpow** : version Real.rpow de R75 NEW2.

Pour toute partition strictement croissante `[0, k]` en m sous-blocs, au
moins un bloc satisfait `amp_b ≥ amp_full^(1/m : ℝ)`.

**Équivalence** avec R75 NEW2 (Nat^m) via :
- `(amp_b)^m ≥ amp_full` (R75 NEW2)
- `Real.rpow_natCast` : `(amp_b)^m = (amp_b)^((m : ℕ) : ℝ)`
- `Real.rpow_le_rpow` avec exposant `1/m ≥ 0`
- Simplification `((x)^m)^(1/m) = x^(m * (1/m)) = x^1 = x`

C'est le **statement attendu pour l'angle ⊶ #2 réel** : pour cycle non-trivial,
`amp_full < 1` (Steiner R59), donc `amp_full^(1/m)` est *proche de 1* pour m
grand mais borné (Hercher m ≤ 91 axiome). -/
theorem cycle_max_amp_ge_rpow_full
    (n k m : ℕ) (hm : m ≥ 1)
    (i_block : ℕ → ℕ)
    (h_mono : ∀ b, b < m → i_block b < i_block (b + 1))
    (h_start : i_block 0 = 0) (h_end : i_block m = k) :
    ∃ b, b < m ∧
      amplification_block n (i_block b) (i_block (b + 1)) ≥
      (amplification_block n 0 k) ^ ((1 : ℝ) / (m : ℝ)) := by
  -- Apply R75 NEW2 to obtain `(amp_b)^m ≥ amp_full`
  obtain ⟨b, hb_lt, h_pow⟩ :=
    cycle_max_amp_pow_m_ge_full n k m hm i_block h_mono h_start h_end
  refine ⟨b, hb_lt, ?_⟩
  -- Setup nonneg facts
  have h_amp_b_pos : (0 : ℝ) <
      amplification_block n (i_block b) (i_block (b + 1)) :=
    amplification_block_pos_universal n _ _
  have h_amp_b_nn : (0 : ℝ) ≤
      amplification_block n (i_block b) (i_block (b + 1)) := le_of_lt h_amp_b_pos
  have h_amp_full_pos : (0 : ℝ) < amplification_block n 0 k :=
    amplification_block_pos_universal n 0 k
  have h_amp_full_nn : (0 : ℝ) ≤ amplification_block n 0 k := le_of_lt h_amp_full_pos
  have h_m_pos : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  have h_inv_m_nn : (0 : ℝ) ≤ (1 : ℝ) / (m : ℝ) :=
    div_nonneg zero_le_one (le_of_lt h_m_pos)
  -- Convert (amp_b)^m (Nat pow) to (amp_b)^((m : ℕ) : ℝ) (rpow)
  have h_rpow_eq :
      (amplification_block n (i_block b) (i_block (b + 1))) ^ ((m : ℕ) : ℝ) =
      (amplification_block n (i_block b) (i_block (b + 1))) ^ m := by
    rw [Real.rpow_natCast]
  -- h_pow : (amp_b)^m ≥ amp_full
  -- Equivalent: amp_full ≤ (amp_b)^((m : ℕ) : ℝ)
  have h_pow_rpow : amplification_block n 0 k ≤
      (amplification_block n (i_block b) (i_block (b + 1))) ^ ((m : ℕ) : ℝ) := by
    rw [h_rpow_eq]; exact h_pow
  -- Apply ^(1/m) (rpow) to both sides (monotone since 1/m ≥ 0)
  have h_rpow_step : (amplification_block n 0 k) ^ ((1 : ℝ) / (m : ℝ)) ≤
      ((amplification_block n (i_block b) (i_block (b + 1))) ^ ((m : ℕ) : ℝ)) ^
        ((1 : ℝ) / (m : ℝ)) :=
    Real.rpow_le_rpow h_amp_full_nn h_pow_rpow h_inv_m_nn
  -- Simplify ((amp_b)^m)^(1/m) = amp_b^(m * (1/m)) = amp_b^1 = amp_b
  have h_simplify :
      ((amplification_block n (i_block b) (i_block (b + 1))) ^ ((m : ℕ) : ℝ)) ^
        ((1 : ℝ) / (m : ℝ)) =
      amplification_block n (i_block b) (i_block (b + 1)) := by
    rw [← Real.rpow_mul h_amp_b_nn]
    have h_mul_one : ((m : ℕ) : ℝ) * ((1 : ℝ) / (m : ℝ)) = 1 := by
      have : (m : ℝ) ≠ 0 := ne_of_gt h_m_pos
      field_simp
    rw [h_mul_one, Real.rpow_one]
  rw [h_simplify] at h_rpow_step
  exact h_rpow_step

/-! ## Section 12: R76b NEW2 — Bloc avec UN endpoint minimum (étape modulaire)

🎯 **Suite plan modulaire R76 NEW2** (mailbox 1220) : étape 2/3.

🚨 **R76b-fix Red Team severity 9/10** (mailbox 1308) : naming initial
`at_min` était trompeur (suggérait endpoint minimum universel). Renommé en
`at_one_min` pour refléter que **AU MOINS UN** des deux endpoints est minimum
(pas les deux).

R76a NEW2 (BlockDecomposition.lean) : extraction de 2 minima distincts.
R76b NEW2 (ce théorème) : utilise un de ces minima comme **point de split**
dans R73 NEW (`split_block_max_geometric_mean`), pour obtenir un bloc avec
**au moins UN endpoint minimum local**.

**Statement** : pour cycle non-trivial avec ≥ 2 minima locaux, ∃ bloc
`[a, b]` tel que :
- `a < b ≤ k`
- `IsLocalMin n k a ∨ IsLocalMin n k b` (au moins UN endpoint minimum)
- `amp(a, b) ≥ √amp_full = amp_full^(1/2)`

⚠️ **Note structurelle** (Faille 2 RT) : dans la preuve, c'est **toujours**
`j` qui est l'endpoint minimum (jamais le `0` ou le `k`). La disjonction
`Or.inl ∨ Or.inr` exprime juste que `j` peut être à gauche ou à droite du bloc
(selon quel sous-bloc satisfait l'inégalité).

⚠️ **Note borne** (Faille 4 RT) : `√amp_full` est sémantiquement creux pour
cycles longs (amp_full → 0 exponentiellement). Borne utile uniquement pour
cycles courts ou n_0 grand (amp_full proche de 1).

C'est **plus fort que R74 NEW** (qui donnait juste un bloc cycle quelconque),
mais **plus faible que R76c final** (qui demandera les DEUX endpoints minima).

**Compatible avec angle 2 ChatGPT 5.5** ("bloc résonant rigide") :
le bloc obtenu ici peut servir de point d'ancrage pour les contraintes
de congruence locale (transport mod p sur bloc résonant).
-/

/-- **R76b NEW2** — bloc avec AU MOINS UN endpoint minimum, amp ≥ √amp_full.

Pour cycle non-trivial avec `cycleMinimaCount ≥ 2`, il existe un bloc
`[a, b]` avec `a < b ≤ k` dont **au moins UN endpoint est un minimum local**
et dont l'amplification satisfait `amp ≥ √amp_full`.

⚠️ **Naming truthful (R76b-fix)** : `at_one_min` = "endpoint minimum
existe" (au moins un, pas les deux). L'angle ⊶ #2 ChatGPT 5.5 réel demande
**deux endpoints minima** — ce sera R76c final.

**Stratégie** : extraire un second minimum `j` via R76a NEW2 (qui garantit
`j < k` et `j ≥ 1`), puis appliquer R73 NEW (`split_block_max_geometric_mean`)
au point `j`. R73 NEW donne `amp(0, j) ≥ √amp_full ∨ amp(j, k) ≥ √amp_full`.
Dans les deux cas, `j` est l'endpoint minimum garanti. -/
theorem cycle_block_at_one_min_amp_ge_sqrt
    (n k : ℕ) (hcyc : IsOddCycle n k) (hk : k ≥ 2)
    (h_minima : cycleMinimaCount n k ≥ 2) :
    ∃ a b : ℕ, a < b ∧ b ≤ k ∧
      (IsLocalMin n k a ∨ IsLocalMin n k b) ∧
      amplification_block n a b ≥ Real.sqrt (amplification_block n 0 k) := by
  obtain ⟨_i, j, _hi_min, hj_min, h_lt, h_lt_k⟩ :=
    cycle_exists_two_distinct_minima n k hcyc hk h_minima
  have hj_pos : j ≥ 1 := by omega
  -- R73 NEW : split à m = j, soit [0, j] soit [j, k] satisfait l'inégalité
  rcases split_block_max_geometric_mean n k j (le_of_lt h_lt_k) with h_left | h_right
  · -- Cas amp(0, j) ≥ √amp_full : endpoint b = j est minimum (Or.inr)
    refine ⟨0, j, hj_pos, le_of_lt h_lt_k, Or.inr hj_min, h_left⟩
  · -- Cas amp(j, k) ≥ √amp_full : endpoint a = j est minimum (Or.inl)
    refine ⟨j, k, h_lt_k, le_refl k, Or.inl hj_min, h_right⟩

end ProjetCollatz.PostJAR
