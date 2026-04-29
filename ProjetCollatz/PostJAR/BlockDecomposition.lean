import ProjetCollatz.PostJAR.CycleArithmetic
import ProjetCollatz.Phase50CycleEquation

/-!
# BlockDecomposition.lean — Round 61 (NEW2): Décomposition en blocs de minima

## Origine

Suite à l'identification par ChatGPT R25 (severity 10/10) du gap sémantique entre
le `k ≤ 91` actuellement utilisé dans `HercherTheorem.lean` et le **vrai** énoncé
de Hercher 2023 — qui borne `m ≤ 91`, où `m` est le nombre de **minima locaux**
de la trajectoire d'un cycle (et m ≤ k toujours) — ce fichier introduit le
**changement de niveau** entre `k` et `m`.

## Conventions

Une position `i ∈ [0, k)` est un *minimum local* du cycle si :
- `nSeq n i ≤ nSeq n (i + k - 1)` (voisin précédent, avec wraparound périodique)
- `nSeq n i ≤ nSeq n (i + 1)` (voisin suivant, avec wraparound périodique)

L'expression `nSeq n (i + k - 1)` exploite la périodicité `cycle_nSeq_periodic` :
- Pour `i = 0` : `nSeq n (k - 1)` directement.
- Pour `i ≥ 1` : par périodicité, `nSeq n (i + k - 1) = nSeq n (i - 1)`.

L'expression `nSeq n (i + 1)` :
- Pour `i < k - 1` : direct.
- Pour `i = k - 1` : `nSeq n k = n = nSeq n 0` par hypothèse cycle.

Cette convention exploite naturellement la périodicité du cycle, sans `if-then-else`.

## Résultats

| # | Théorème | Statut |
|---|---|---|
| 1 | `IsLocalMin` (définition) | ✅ |
| 2 | `cycleMinimaCount` (définition) | ✅ |
| 3 | `cycle_m_le_k` (m ≤ k) | ✅ PROVED |
| 4 | `cycle_m_ge_one` (m ≥ 1) | ✅ PROVED |
| 5 | `hercher_m_le_91_axiom` (axiomatisation Hercher refereed) | ⚠️ AXIOM |

L'axiome `hercher_m_le_91_axiom` reformule fidèlement le résultat de Hercher 2023
(qui borne `m ≤ 91`, pas `k`) et constitue le pont vers la version forte du
théorème conditionnel `no_collatz_cycle_full`.

## Date : 2026-04-28 (NEW2)
-/

namespace ProjetCollatz.PostJAR

open ProjetCollatz

/-! ## Définition d'un minimum local -/

/--
Une position `i ∈ [0, k)` est un **minimum local** du cycle déterminé par
`(n, k)` si `nSeq n i` est inférieur ou égal à ses voisins immédiats dans
le cycle (avec wraparound périodique).

Convention de wraparound :
- Voisin précédent : `nSeq n (i + k - 1)`. Pour `i = 0`, c'est `nSeq n (k - 1)`.
  Pour `i ≥ 1`, on a `i + k - 1 = (i - 1) + k`, donc par périodicité du cycle
  cela vaut `nSeq n (i - 1)`.
- Voisin suivant : `nSeq n (i + 1)`. Pour `i = k - 1`, c'est `nSeq n k = n`
  par hypothèse de cycle.

Note : la définition est valide *combinatoirement* pour tout `(n, k, i)` mais
sa **sémantique** de "minimum local du cycle" requiert que `(n, k)` soit
effectivement un cycle (pour la périodicité).
-/
def IsLocalMin (n k i : ℕ) : Prop :=
  i < k ∧
  nSeq n i ≤ nSeq n (i + k - 1) ∧
  nSeq n i ≤ nSeq n (i + 1)

/-- `IsLocalMin` est décidable mais marqué noncomputable car `nSeq` est
non-computable (dépend de `syracuseNext` qui repose sur `v2_3n1`). -/
noncomputable instance (n k i : ℕ) : Decidable (IsLocalMin n k i) := by
  unfold IsLocalMin
  infer_instance

/-! ## Compteur de minima locaux -/

/--
Le nombre `m` de minima locaux dans le cycle déterminé par `(n, k)`.

C'est le cardinal du sous-ensemble des positions `i ∈ [0, k)` qui sont des
minima locaux.

**Interprétation Hercher 2023** : `m` est le nombre de "blocs" dans la
décomposition de la trajectoire. Hercher prouve `m ≤ 91` pour tout cycle
non-trivial (axiomatisé ici).
-/
noncomputable def cycleMinimaCount (n k : ℕ) : ℕ :=
  ((Finset.range k).filter (IsLocalMin n k)).card

/-! ## Propriétés triviales -/

/-- **Tout cycle satisfait `m ≤ k`** (par construction du compteur).

Preuve : `cycleMinimaCount` est le cardinal d'un sous-ensemble filtré de
`Finset.range k`, donc borné par `k`. -/
theorem cycle_m_le_k (n k : ℕ) (_hcyc : IsOddCycle n k) :
    cycleMinimaCount n k ≤ k := by
  unfold cycleMinimaCount
  calc ((Finset.range k).filter (IsLocalMin n k)).card
      ≤ (Finset.range k).card := Finset.card_filter_le _ _
    _ = k := Finset.card_range k

/-- **Tout cycle non-trivial admet au moins un minimum local** (m ≥ 1).

Preuve : on prend `i_min ∈ Finset.range k` qui minimise `fun i => nSeq n i`.
Ce `i_min` est un minimum local par construction :
- `nSeq n i_min ≤ nSeq n j` pour tout `j ∈ [0, k)` (minimalité globale).
- En particulier, c'est ≤ ses voisins immédiats (avec wraparound).

Pour le voisin précédent (`i_min + k - 1`) :
- Si `i_min = 0`, le voisin est `k - 1 ∈ [0, k)`, direct par minimalité.
- Si `i_min ≥ 1`, par périodicité du cycle on a
  `nSeq n (i_min + k - 1) = nSeq n (i_min - 1)`, et `i_min - 1 ∈ [0, k)`.

Pour le voisin suivant (`i_min + 1`) :
- Si `i_min < k - 1`, le voisin est dans `[0, k)`, direct.
- Si `i_min = k - 1`, le voisin est `nSeq n k = n = nSeq n 0`, et `0 ∈ [0, k)`.
-/
theorem cycle_m_ge_one (n k : ℕ) (hcyc : IsOddCycle n k) :
    1 ≤ cycleMinimaCount n k := by
  obtain ⟨hn_gt1, _hodd, hk_pos, h_cyc_eq⟩ := hcyc
  -- Étape 1 : il existe i_min ∈ Finset.range k qui minimise nSeq n.
  have h_range_nonempty : (Finset.range k).Nonempty :=
    ⟨0, Finset.mem_range.mpr hk_pos⟩
  obtain ⟨i_min, hi_min_mem, hi_min_min⟩ :=
    Finset.exists_min_image (Finset.range k) (fun i => nSeq n i) h_range_nonempty
  have hi_min_lt : i_min < k := Finset.mem_range.mp hi_min_mem
  -- Étape 2 : i_min est un minimum local.
  have h_local_min : IsLocalMin n k i_min := by
    refine ⟨hi_min_lt, ?_, ?_⟩
    · -- Voisin précédent : nSeq n i_min ≤ nSeq n (i_min + k - 1)
      by_cases h0 : i_min = 0
      · -- Cas i_min = 0 : i_min + k - 1 = k - 1
        subst h0
        have hk_1_mem : (k - 1) ∈ Finset.range k :=
          Finset.mem_range.mpr (by omega)
        have h := hi_min_min (k - 1) hk_1_mem
        -- 0 + k - 1 = k - 1
        have h_eq : (0 : ℕ) + k - 1 = k - 1 := by omega
        rw [h_eq]
        exact h
      · -- Cas i_min ≥ 1 : périodicité
        have hge : i_min ≥ 1 := Nat.one_le_iff_ne_zero.mpr h0
        -- i_min + k - 1 = (i_min - 1) + k
        have h_eq : i_min + k - 1 = (i_min - 1) + k := by omega
        rw [h_eq]
        have h_periodic : nSeq n ((i_min - 1) + k) = nSeq n (i_min - 1) :=
          cycle_nSeq_periodic n k h_cyc_eq (i_min - 1)
        rw [h_periodic]
        have hi_pred_mem : (i_min - 1) ∈ Finset.range k :=
          Finset.mem_range.mpr (by omega)
        exact hi_min_min (i_min - 1) hi_pred_mem
    · -- Voisin suivant : nSeq n i_min ≤ nSeq n (i_min + 1)
      by_cases h_last : i_min + 1 < k
      · -- Cas i_min < k - 1 : direct
        have hi_succ_mem : (i_min + 1) ∈ Finset.range k :=
          Finset.mem_range.mpr h_last
        exact hi_min_min (i_min + 1) hi_succ_mem
      · -- Cas i_min = k - 1 : i_min + 1 = k, nSeq n k = n par cycle
        push_neg at h_last
        have h_succ_eq_k : i_min + 1 = k := by omega
        rw [h_succ_eq_k, h_cyc_eq]
        -- nSeq n i_min ≤ n. Or nSeq n 0 = n par définition.
        have h0_mem : (0 : ℕ) ∈ Finset.range k :=
          Finset.mem_range.mpr hk_pos
        have h := hi_min_min 0 h0_mem
        -- nSeq n 0 = n par définition de nSeq
        change nSeq n i_min ≤ n
        have h_n_eq : nSeq n 0 = n := rfl
        rw [h_n_eq] at h
        exact h
  -- Étape 3 : i_min ∈ filter, donc cycleMinimaCount ≥ 1.
  unfold cycleMinimaCount
  have h_mem : i_min ∈ (Finset.range k).filter (IsLocalMin n k) :=
    Finset.mem_filter.mpr ⟨hi_min_mem, h_local_min⟩
  exact Finset.card_pos.mpr ⟨i_min, h_mem⟩

/-! ## Hercher 2023 — Borne `m ≤ 91` (axiomatisée) -/

/--
**Hercher 2023 — borne sur le nombre de minima locaux** (axiomatisée).

Pour tout cycle non-trivial `IsOddCycle n k`, le nombre `m` de minima locaux
satisfait `m ≤ 91`.

⚠️ **Note sémantique critique** (ChatGPT R25, severity 10/10) : Hercher borne
`m ≤ 91`, **pas** `k ≤ 91`. Ce sont des bornes différentes — `m ≤ k` toujours,
donc `m ≤ 91` est une condition **plus forte** que `k ≤ 91`.

Status : **axiomatisé** (refereed, comme `lmn_log_bound` et `barina_collatz_verified`).
La preuve formelle est ~50-100 pages d'arithmétique dense (Hercher 2023).

TODO[ref=Hercher2023, owner=NEW2, ETA=R75+] : Remplacer par théorème dérivé
quand l'infrastructure Lean (Padé bounds + Steiner identity) sera prête.
-/
axiom hercher_m_le_91_axiom : ∀ (n k : ℕ), IsOddCycle n k →
  cycleMinimaCount n k ≤ 91

/-! ## Round 64 NEW2 — Lien algébrique parityVector ↔ blocs

🎯 **Conjecture R64 NEW Q4 (validée par directeur)** : un bloc "descendant"
dans l'orbite Syracuse ⟺ `aSeq n i ≥ 2`.

NEW R61 a déjà prouvé la direction `←` dans `nSeq_decreases_if_aSeq_ge_2`
(CycleArithmetic.lean:2183). Je complète ici la direction `→` via la
contraposée :
- Pour n impair, `aSeq n i ≥ 1` toujours (car `3·n_i + 1` est pair).
- Si `aSeq n i = 1`, alors `nSeq n (i+1) > nSeq n i` (ascension stricte).
- Donc si `nSeq n (i+1) < nSeq n i`, on doit avoir `aSeq n i ≥ 2`.

Le iff complet `nSeq_decreases_iff_aSeq_ge_2` constitue le **pont algébrique**
entre les outils R24/R32-33 (parityVector) et l'arbre 10 (BlockDecomposition).
-/

/-- **Lemme intermédiaire R64 NEW2** : si `aSeq n i = 1`, alors la trajectoire
Syracuse fait une **ascension stricte** au pas i.

Mathématiquement : `nSeq n (i+1) = (3·n_i + 1)/2 > n_i` quand `n_i ≥ 1`,
parce que `2·nSeq n (i+1) = 3·n_i + 1 > 2·n_i + 1 > 2·n_i`. -/
theorem nSeq_increases_if_aSeq_eq_one
    (n : ℕ) (hn : n > 0) (hodd : n % 2 = 1)
    (i : ℕ) (h_a_eq_1 : aSeq n i = 1) :
    nSeq n i < nSeq n (i + 1) := by
  show nSeq n i < syracuseNext (nSeq n i)
  have hpos_i : nSeq n i > 0 := nSeq_pos n hn i
  -- syracuseNext_spec: syracuseNext m * 2^(v2_3n1 m) = 3*m + 1
  have h_spec : syracuseNext (nSeq n i) * 2 ^ (v2_3n1 (nSeq n i)) =
                3 * nSeq n i + 1 := syracuseNext_spec (nSeq n i)
  -- aSeq n i = v2_3n1 (nSeq n i) par définition
  have h_aSeq_def : aSeq n i = v2_3n1 (nSeq n i) := rfl
  rw [← h_aSeq_def, h_a_eq_1] at h_spec
  -- h_spec : syracuseNext (nSeq n i) * 2^1 = 3 * nSeq n i + 1
  have h_2pow_one : (2 : ℕ) ^ 1 = 2 := by norm_num
  rw [h_2pow_one] at h_spec
  -- h_spec : syracuseNext (nSeq n i) * 2 = 3 * nSeq n i + 1
  -- Comparons : si syracuseNext ≤ nSeq, alors 2·syracuseNext ≤ 2·nSeq < 3·nSeq + 1, contradiction.
  omega

/-- **R64 NEW2 — Théorème principal (iff)** : la trajectoire Syracuse
**descend strictement** au pas i si et seulement si `aSeq n i ≥ 2`.

Combine `nSeq_decreases_if_aSeq_ge_2` (NEW R61, direction `←`) avec
`nSeq_increases_if_aSeq_eq_one` (NEW2 R64, direction `→` par contraposée).

**Conséquence pour BlockDecomposition** : on peut caractériser les minima
locaux algébriquement via le vecteur de parités. Voir
`isLocalMin_iff_aSeq_pattern` (à venir). -/
theorem nSeq_decreases_iff_aSeq_ge_2
    (n : ℕ) (hn : n > 0) (hodd : n % 2 = 1)
    (i : ℕ) (h_n_i_ge_2 : nSeq n i ≥ 2) :
    nSeq n (i + 1) < nSeq n i ↔ aSeq n i ≥ 2 := by
  constructor
  · -- → : si nSeq n (i+1) < nSeq n i, alors aSeq n i ≥ 2 (par contraposée).
    intro h_dec
    by_contra h_not
    push_neg at h_not  -- h_not : aSeq n i < 2
    -- Pour n impair, aSeq n i ≥ 1 (3·n_i + 1 est toujours pair).
    have h_a_ge_1 : aSeq n i ≥ 1 := aSeq_ge_one_of_odd n i hodd
    have h_a_eq_1 : aSeq n i = 1 := by omega
    have h_inc := nSeq_increases_if_aSeq_eq_one n hn hodd i h_a_eq_1
    omega
  · -- ← : c'est exactement nSeq_decreases_if_aSeq_ge_2 (NEW R61).
    intro h_a_ge_2
    exact nSeq_decreases_if_aSeq_ge_2 n hn hodd i h_n_i_ge_2 h_a_ge_2

/-! ## Round 65 NEW2 — Caractérisation algorithmique de `IsLocalMin`

🎯 **But** : exprimer `IsLocalMin n k i` purement en fonction du vecteur de
parités `aSeq`, sans manipuler `nSeq` directement.

**Caractérisation** : pour un cycle non-trivial avec `nSeq n i ≥ 2` et
`nSeq n (i + k - 1) ≥ 2`,
$$
\text{IsLocalMin}(n, k, i) \iff (\text{aSeq}(n, i + k - 1) \ge 2 \wedge \text{aSeq}(n, i) = 1).
$$

**Sémantique** :
- `aSeq[prev] ≥ 2` ⟺ descente (prev → i) ⟺ `n_prev > n_i`.
- `aSeq[i] = 1` ⟺ ascension (i → i+1) ⟺ `n_i < n_{i+1}`.
- Combinaison ⟺ `n_i` est un minimum local.

**Conséquence** : `cycleMinimaCount n k` peut maintenant être calculé via le
seul `parityVector`, sans toucher à `nSeq`. C'est l'**aboutissement de
l'arbre 10** : pont algorithmique entre la combinatoire des minima locaux et
le vecteur de parités.

**Lien avec R66 NEW (angle ⊶ ChatGPT 5.5)** : ce théorème est le pré-requis pour
formaliser `cycle_has_quasi_resonant_block` (R67) — le bloc minimal critique
identifié par GPT-5.5 comme angle d'attaque le plus fort.
-/

/-- **R65 NEW2 — caractérisation algorithmique de IsLocalMin**.

Sous hypothèse de cycle non-trivial avec `nSeq` aux positions critiques ≥ 2,
`IsLocalMin n k i` se caractérise complètement via le vecteur de parités :

* `aSeq n (i + k - 1) ≥ 2` (descente du voisin précédent vers i)
* `aSeq n i = 1` (ascension de i vers le voisin suivant)

Cette caractérisation est l'**aboutissement de l'arbre 10** : elle permet de
calculer `cycleMinimaCount` algorithmiquement sans manipuler `nSeq`. -/
theorem isLocalMin_iff_aSeq_pattern
    (n k i : ℕ) (hcyc : IsOddCycle n k) (hi : i < k)
    (h_n_i_ge_2 : nSeq n i ≥ 2) (h_n_prev_ge_2 : nSeq n (i + k - 1) ≥ 2) :
    IsLocalMin n k i ↔
      (aSeq n (i + k - 1) ≥ 2 ∧ aSeq n i = 1) := by
  obtain ⟨hn_gt1, hodd, hk_pos, h_cyc_eq⟩ := hcyc
  have h_n_pos : n > 0 := by omega
  -- Étape 1 : équivalence pour le voisin précédent.
  have h_eq_prev : nSeq n i ≤ nSeq n (i + k - 1) ↔ aSeq n (i + k - 1) ≥ 2 := by
    have h_iff_strict :=
      nSeq_decreases_iff_aSeq_ge_2 n h_n_pos hodd (i + k - 1) h_n_prev_ge_2
    -- h_iff_strict : nSeq n ((i + k - 1) + 1) < nSeq n (i + k - 1) ↔ aSeq n (i + k - 1) ≥ 2
    have h_periodic : nSeq n ((i + k - 1) + 1) = nSeq n i := by
      have h_eq : (i + k - 1) + 1 = i + k := by omega
      rw [h_eq]
      exact cycle_nSeq_periodic n k h_cyc_eq i
    rw [h_periodic] at h_iff_strict
    -- h_iff_strict : nSeq n i < nSeq n (i + k - 1) ↔ aSeq n (i + k - 1) ≥ 2
    constructor
    · intro h_le
      by_contra h_not
      push_neg at h_not
      -- aSeq < 2, et aSeq ≥ 1 (n impair), donc aSeq = 1
      have h_a_ge_1 : aSeq n (i + k - 1) ≥ 1 := aSeq_ge_one_of_odd n (i + k - 1) hodd
      have h_a_eq_1 : aSeq n (i + k - 1) = 1 := by omega
      have h_inc :=
        nSeq_increases_if_aSeq_eq_one n h_n_pos hodd (i + k - 1) h_a_eq_1
      -- h_inc : nSeq n (i + k - 1) < nSeq n ((i + k - 1) + 1) = nSeq n i
      rw [h_periodic] at h_inc
      omega
    · intro h_a_ge_2
      have h_strict := h_iff_strict.mpr h_a_ge_2
      omega
  -- Étape 2 : équivalence pour le voisin suivant.
  have h_eq_next : nSeq n i ≤ nSeq n (i + 1) ↔ aSeq n i = 1 := by
    have h_iff_strict :=
      nSeq_decreases_iff_aSeq_ge_2 n h_n_pos hodd i h_n_i_ge_2
    constructor
    · intro h_le
      have h_not_dec : ¬ (nSeq n (i + 1) < nSeq n i) := by omega
      have h_not_ge_2 : ¬ (aSeq n i ≥ 2) := fun h => h_not_dec (h_iff_strict.mpr h)
      have h_a_ge_1 : aSeq n i ≥ 1 := aSeq_ge_one_of_odd n i hodd
      omega
    · intro h_a_eq_1
      have h_inc := nSeq_increases_if_aSeq_eq_one n h_n_pos hodd i h_a_eq_1
      omega
  -- Étape 3 : combiner les deux équivalences via la définition d'IsLocalMin.
  unfold IsLocalMin
  constructor
  · rintro ⟨_, h_prev_le, h_next_le⟩
    exact ⟨h_eq_prev.mp h_prev_le, h_eq_next.mp h_next_le⟩
  · rintro ⟨h_a_prev_ge_2, h_a_curr_eq_1⟩
    exact ⟨hi, h_eq_prev.mpr h_a_prev_ge_2, h_eq_next.mpr h_a_curr_eq_1⟩

/-! ## Round 66 NEW2 — Caractérisation algorithmique de `IsLocalMax`

Symétrique de R65 pour les **maxima locaux**. Suggéré par NEW (directeur)
dans son audit R62/R64.

**Caractérisation** :
$$
\text{IsLocalMax}(n, k, i) \iff (\text{aSeq}(n, i + k - 1) = 1 \wedge \text{aSeq}(n, i) \ge 2).
$$

**Sémantique** (inversée par rapport à IsLocalMin) :
- `aSeq[prev] = 1` ⟺ ascension (prev → i) ⟺ `n_prev < n_i`.
- `aSeq[i] ≥ 2` ⟺ descente (i → i+1) ⟺ `n_i > n_{i+1}`.
- Combinaison ⟺ `n_i` est un maximum local.

**Conséquence pour les futurs travaux R67+** : un bloc `[i_min, i_max]` se
caractérise par une séquence d'aSeq `(s_(i_min) = 1, s_(i_min)+1, ..., s_(i_max-1) ≥ 2)`
avec montée puis descente. C'est le **squelette algorithmique du bloc minimal
critique** (angle ⊶ ChatGPT 5.5).
-/

/--
Une position `i ∈ [0, k)` est un **maximum local** du cycle si `nSeq n i` est
supérieur ou égal à ses voisins (avec wraparound périodique). Symétrique de
`IsLocalMin`.
-/
def IsLocalMax (n k i : ℕ) : Prop :=
  i < k ∧
  nSeq n i ≥ nSeq n (i + k - 1) ∧
  nSeq n i ≥ nSeq n (i + 1)

/-- `IsLocalMax` est décidable (noncomputable car `nSeq` l'est). -/
noncomputable instance (n k i : ℕ) : Decidable (IsLocalMax n k i) := by
  unfold IsLocalMax
  infer_instance

/-- **R66 NEW2 — caractérisation algorithmique de IsLocalMax**.

Symétrique de `isLocalMin_iff_aSeq_pattern` (R65) :

* `aSeq n (i + k - 1) = 1` (ascension du voisin précédent vers i)
* `aSeq n i ≥ 2` (descente de i vers le voisin suivant) -/
theorem isLocalMax_iff_aSeq_pattern
    (n k i : ℕ) (hcyc : IsOddCycle n k) (hi : i < k)
    (h_n_i_ge_2 : nSeq n i ≥ 2) (h_n_prev_ge_2 : nSeq n (i + k - 1) ≥ 2) :
    IsLocalMax n k i ↔
      (aSeq n (i + k - 1) = 1 ∧ aSeq n i ≥ 2) := by
  obtain ⟨hn_gt1, hodd, hk_pos, h_cyc_eq⟩ := hcyc
  have h_n_pos : n > 0 := by omega
  -- Étape 1 : équivalence pour le voisin précédent (ascension prev → i).
  have h_eq_prev : nSeq n i ≥ nSeq n (i + k - 1) ↔ aSeq n (i + k - 1) = 1 := by
    have h_iff_strict :=
      nSeq_decreases_iff_aSeq_ge_2 n h_n_pos hodd (i + k - 1) h_n_prev_ge_2
    have h_periodic : nSeq n ((i + k - 1) + 1) = nSeq n i := by
      have h_eq : (i + k - 1) + 1 = i + k := by omega
      rw [h_eq]
      exact cycle_nSeq_periodic n k h_cyc_eq i
    rw [h_periodic] at h_iff_strict
    -- h_iff_strict : nSeq n i < nSeq n (i + k - 1) ↔ aSeq n (i + k - 1) ≥ 2
    constructor
    · intro h_ge
      -- nSeq n i ≥ nSeq n (i + k - 1) ⟹ ¬(nSeq n i < nSeq n (i + k - 1)) ⟹ ¬(aSeq ≥ 2)
      have h_not_lt : ¬ (nSeq n i < nSeq n (i + k - 1)) := by omega
      have h_not_ge_2 : ¬ (aSeq n (i + k - 1) ≥ 2) :=
        fun h => h_not_lt (h_iff_strict.mpr h)
      have h_a_ge_1 : aSeq n (i + k - 1) ≥ 1 :=
        aSeq_ge_one_of_odd n (i + k - 1) hodd
      omega
    · intro h_a_eq_1
      have h_inc :=
        nSeq_increases_if_aSeq_eq_one n h_n_pos hodd (i + k - 1) h_a_eq_1
      rw [h_periodic] at h_inc
      omega
  -- Étape 2 : équivalence pour le voisin suivant (descente i → i+1).
  have h_eq_next : nSeq n i ≥ nSeq n (i + 1) ↔ aSeq n i ≥ 2 := by
    have h_iff_strict :=
      nSeq_decreases_iff_aSeq_ge_2 n h_n_pos hodd i h_n_i_ge_2
    constructor
    · intro h_ge
      by_contra h_not
      push_neg at h_not
      have h_a_ge_1 : aSeq n i ≥ 1 := aSeq_ge_one_of_odd n i hodd
      have h_a_eq_1 : aSeq n i = 1 := by omega
      have h_inc := nSeq_increases_if_aSeq_eq_one n h_n_pos hodd i h_a_eq_1
      omega
    · intro h_a_ge_2
      have h_strict := h_iff_strict.mpr h_a_ge_2
      omega
  -- Étape 3 : combiner les deux équivalences.
  unfold IsLocalMax
  constructor
  · rintro ⟨_, h_prev_ge, h_next_ge⟩
    exact ⟨h_eq_prev.mp h_prev_ge, h_eq_next.mp h_next_ge⟩
  · rintro ⟨h_a_prev_eq_1, h_a_curr_ge_2⟩
    exact ⟨hi, h_eq_prev.mpr h_a_prev_eq_1, h_eq_next.mpr h_a_curr_ge_2⟩

/-! ## Round 66bis NEW2 — Cleanup : élimination hypothèses parasites

🎯 **Décision directeur Q5 (Option B)** : prouver `cycle_all_gt_one` plutôt
que d'axiomatiser. C'est une vérité Collatz fondamentale qui suit directement
de la définition.

🚨 **Faille Red Team severity 7/10** : pour k=1, R65/R66 sont sémantiquement
opaques. Mais `cycle_k_ge_two` existe déjà dans `Phase50CycleEquation.lean:153`
(prouvé par Eric R55). Ce résultat élimine le cas k=1 complètement, donc R65
et R66 sont OK pour k ≥ 2 (cycles non-triviaux).

### Théorèmes ajoutés

| Théorème | Statut | Utilité |
|---|---|---|
| `cycle_all_gt_one` | ✅ PROVED | élimine hyp `nSeq n i ≥ 2` parasites downstream |
| `cycle_all_ge_three` | ✅ PROVED | corollaire fort (impair + > 1 ⟹ ≥ 3) |

**Stratégie de preuve `cycle_all_gt_one`** :
- Si `nSeq n i = 1` (pour i ≤ k), alors par `nSeq_stays_at_one`, on a
  `nSeq n (i + (k-i)) = nSeq 1 (k-i) = 1`, c'est-à-dire `nSeq n k = 1`.
- Mais par hypothèse cycle, `nSeq n k = n > 1`, contradiction.

Conséquence : R65 et R66 NEW2 sont automatiquement satisfaits dans tout
cycle non-trivial (les hypothèses `nSeq n i ≥ 2` deviennent dérivables).
-/

/-- **R66bis NEW2** — tout intermédiaire d'un cycle non-trivial est `> 1`.

Preuve par contradiction : si `nSeq n i = 1` pour un `i ≤ k`, alors `1` est
un point fixe Syracuse (`nSeq_stays_at_one`), donc tous les itérés à partir
de `i` valent `1`. En particulier `nSeq n k = 1`. Mais par cycle, `nSeq n k = n > 1`. -/
theorem cycle_all_gt_one (n k : ℕ) (hcyc : IsOddCycle n k) (i : ℕ) (hi : i ≤ k) :
    nSeq n i > 1 := by
  obtain ⟨hn_gt1, _hodd, hk_pos, h_cyc_eq⟩ := hcyc
  by_contra h_not
  push_neg at h_not  -- h_not : nSeq n i ≤ 1
  have h_n_pos : n > 0 := by omega
  have h_pos := nSeq_pos n h_n_pos i  -- nSeq n i > 0
  have h_nseq_eq_1 : nSeq n i = 1 := by omega
  -- nSeq n (i + (k - i)) = nSeq (nSeq n i) (k - i) = nSeq 1 (k - i) = 1
  have h_split : nSeq n (i + (k - i)) = nSeq (nSeq n i) (k - i) := nSeq_add n i (k - i)
  have h_diff : i + (k - i) = k := by omega
  rw [h_diff, h_nseq_eq_1] at h_split
  -- h_split : nSeq n k = nSeq 1 (k - i)
  rw [nSeq_stays_at_one] at h_split
  -- h_split : nSeq n k = 1
  rw [h_cyc_eq] at h_split
  -- h_split : n = 1, contradiction avec hn_gt1
  omega

/-- **R66bis NEW2 — corollaire fort** : tout intermédiaire d'un cycle
non-trivial est `≥ 3` (impair et `> 1`). -/
theorem cycle_all_ge_three (n k : ℕ) (hcyc : IsOddCycle n k) (i : ℕ) (hi : i ≤ k) :
    nSeq n i ≥ 3 := by
  have h_gt_one : nSeq n i > 1 := cycle_all_gt_one n k hcyc i hi
  obtain ⟨_hn_gt1, hodd, _hk_pos, _⟩ := hcyc
  have h_odd : nSeq n i % 2 = 1 := nSeq_odd n i hodd
  omega

/-! ## Round 66ter NEW2 — Versions "clean" sans hypothèses parasites

Suite à R66bis NEW2 (`cycle_all_gt_one` + `cycle_all_ge_three`), les
hypothèses `nSeq n i ≥ 2` deviennent automatiquement satisfaites pour cycles
non-triviaux. On peut donc dériver des versions "clean" de R65 et R66 NEW2 :

* `isLocalMin_iff_aSeq_pattern_clean` : sans hypothèse `nSeq n i ≥ 2`
* `isLocalMax_iff_aSeq_pattern_clean` : idem pour max

Ces versions sont les **API publiques recommandées** pour usage downstream
(R67+). Les versions originales restent utiles si on a déjà les hypothèses
en main.

**Stratégie technique** : pour `n_prev = nSeq n (i + k - 1)`, on distingue :
- `i = 0` : `nSeq n (k - 1) ≥ 3` directement par `cycle_all_ge_three`.
- `i ≥ 1` : par périodicité, `nSeq n (i + k - 1) = nSeq n (i - 1) ≥ 3`.
-/

/-- **R66ter NEW2 — version clean de R65** : sans hypothèses parasites.

API recommandée pour usage downstream. -/
theorem isLocalMin_iff_aSeq_pattern_clean
    (n k i : ℕ) (hcyc : IsOddCycle n k) (hi : i < k) :
    IsLocalMin n k i ↔
      (aSeq n (i + k - 1) ≥ 2 ∧ aSeq n i = 1) := by
  have h_n_i_ge_2 : nSeq n i ≥ 2 := by
    have := cycle_all_ge_three n k hcyc i (le_of_lt hi)
    omega
  have h_n_prev_ge_2 : nSeq n (i + k - 1) ≥ 2 := by
    by_cases h0 : i = 0
    · subst h0
      have h_eq : (0 : ℕ) + k - 1 = k - 1 := by omega
      rw [h_eq]
      have := cycle_all_ge_three n k hcyc (k - 1) (by omega)
      omega
    · have h_eq : i + k - 1 = (i - 1) + k := by omega
      rw [h_eq, cycle_nSeq_periodic n k hcyc.2.2.2 (i - 1)]
      have := cycle_all_ge_three n k hcyc (i - 1) (by omega)
      omega
  exact isLocalMin_iff_aSeq_pattern n k i hcyc hi h_n_i_ge_2 h_n_prev_ge_2

/-- **R66ter NEW2 — version clean de R66** : sans hypothèses parasites.

API recommandée pour usage downstream. -/
theorem isLocalMax_iff_aSeq_pattern_clean
    (n k i : ℕ) (hcyc : IsOddCycle n k) (hi : i < k) :
    IsLocalMax n k i ↔
      (aSeq n (i + k - 1) = 1 ∧ aSeq n i ≥ 2) := by
  have h_n_i_ge_2 : nSeq n i ≥ 2 := by
    have := cycle_all_ge_three n k hcyc i (le_of_lt hi)
    omega
  have h_n_prev_ge_2 : nSeq n (i + k - 1) ≥ 2 := by
    by_cases h0 : i = 0
    · subst h0
      have h_eq : (0 : ℕ) + k - 1 = k - 1 := by omega
      rw [h_eq]
      have := cycle_all_ge_three n k hcyc (k - 1) (by omega)
      omega
    · have h_eq : i + k - 1 = (i - 1) + k := by omega
      rw [h_eq, cycle_nSeq_periodic n k hcyc.2.2.2 (i - 1)]
      have := cycle_all_ge_three n k hcyc (i - 1) (by omega)
      omega
  exact isLocalMax_iff_aSeq_pattern n k i hcyc hi h_n_i_ge_2 h_n_prev_ge_2

/-! ## Round 76a NEW2 — Extraction de 2 minima distincts

🎯 **Étape vers R76 NEW2 final** (vrai angle ⊶ #2 avec endpoints minima).

Pour tout cycle non-trivial avec `cycleMinimaCount ≥ 2`, on peut extraire
**2 minima locaux distincts** `i < j ∈ [0, k)`.

C'est la première brique du plan modulaire R76 NEW2 (mailbox 1220).
-/

/-- **R76a NEW2** — extraction de 2 minima distincts dans un cycle ayant
au moins 2 minima locaux.

Stratégie : utiliser `Finset.min'` et `Finset.max'` du Finset des positions
minima. Si la cardinalité est ≥ 2, alors min < max. -/
theorem cycle_exists_two_distinct_minima
    (n k : ℕ) (hcyc : IsOddCycle n k) (hk : k ≥ 2)
    (h_minima : cycleMinimaCount n k ≥ 2) :
    ∃ i j : ℕ, IsLocalMin n k i ∧ IsLocalMin n k j ∧ i < j ∧ j < k := by
  unfold cycleMinimaCount at h_minima
  have h_card_ge_2 : ((Finset.range k).filter (IsLocalMin n k)).card ≥ 2 := h_minima
  have h_nonempty : ((Finset.range k).filter (IsLocalMin n k)).Nonempty := by
    rw [← Finset.card_pos]; omega
  -- min' < max' grâce à card ≥ 2
  have h_min_lt_max :
      ((Finset.range k).filter (IsLocalMin n k)).min' h_nonempty <
      ((Finset.range k).filter (IsLocalMin n k)).max' h_nonempty := by
    apply Finset.min'_lt_max'_of_card
    omega
  -- min' et max' sont membres du filter, donc dans range k et IsLocalMin
  have h_min_mem :
      ((Finset.range k).filter (IsLocalMin n k)).min' h_nonempty ∈
      ((Finset.range k).filter (IsLocalMin n k)) :=
    ((Finset.range k).filter (IsLocalMin n k)).min'_mem h_nonempty
  have h_max_mem :
      ((Finset.range k).filter (IsLocalMin n k)).max' h_nonempty ∈
      ((Finset.range k).filter (IsLocalMin n k)) :=
    ((Finset.range k).filter (IsLocalMin n k)).max'_mem h_nonempty
  rw [Finset.mem_filter, Finset.mem_range] at h_min_mem h_max_mem
  refine ⟨((Finset.range k).filter (IsLocalMin n k)).min' h_nonempty,
          ((Finset.range k).filter (IsLocalMin n k)).max' h_nonempty,
          h_min_mem.2, h_max_mem.2, h_min_lt_max, h_max_mem.1⟩

/-! ## Documentation : changement de niveau k → m

Le diagramme conceptuel :

```
Cycle Collatz (n, k)
   │
   ├── k = longueur Syracuse (nombre de pas odd→odd)
   │
   └── m = cycleMinimaCount n k
          │
          ├── m ≤ k toujours (cycle_m_le_k)
          ├── m ≥ 1 toujours (cycle_m_ge_one)
          └── m ≤ 91 (Hercher 2023, hercher_m_le_91_axiom)
```

**Conséquence** : le théorème conditionnel `no_collatz_cycle_full` peut être
renforcé en remplaçant l'hypothèse `k ≤ 91` par `m ≤ 91`, qui est l'énoncé
exact de Hercher.

**Travaux futurs** (R62+) :
- Outil 4 (OLD) : transport de congruences via décomposition en blocs.
- Lien `m`-bloc vs `k`-Syracuse : exprimer `cycleMinimaCount` en fonction du
  vecteur de parités `parityVector n k`.
- Bridge avec `m_cycle_reduces_to_minimal` (MCycleReduction.lean).
-/

end ProjetCollatz.PostJAR
