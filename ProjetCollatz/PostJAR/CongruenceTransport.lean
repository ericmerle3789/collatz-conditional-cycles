import Mathlib.Data.Nat.ModEq
import Mathlib.Data.ZMod.Basic
import Mathlib.Data.Nat.PrimeFin
import Mathlib.Data.Nat.GCD.BigOperators
import Mathlib.GroupTheory.OrderOfElement
import ProjetCollatz.PostJAR.CycleArithmetic
import ProjetCollatz.Phase52SteinerEquation

/-!
# CongruenceTransport.lean — Round 66: Vrais énoncés ZMod (OLD scaffolding raffiné)

## Origin

Per ChatGPT R56+ recommendation: "Transport de congruences par blocs : c'est
le filtre arithmétique non tautologique."

R63 OLD: scaffolding initial (`True := by trivial` mensongeur — Red Team severity 9/10).
R65bis NEW: fix mensongeur via renommage `_unproven` + body sorry. Statement reste `True`.
R66 OLD (ce fichier): **vrais énoncés mathématiques** ZMod avec sorry préservé.

## Mathematical content

For any Collatz cycle `IsOddCycle n k`, the Steiner identity
  n * 2^S = 3^k * n + corrSum n k
reduces modulo any prime p to:
  n * D_s ≡ C_s [MOD p]   where D_s = 2^S - 3^k

For primes p ∤ D_s, n is forced to a unique value modulo p (in ZMod p).

## Honest scope (NASA Power-of-Ten — leçon Red Team R65)

**Truthful naming + sorry trackable**. Chaque énoncé non prouvé est :
1. Une **vraie proposition mathématique** (pas un `True`-stub)
2. Avec un **sorry** marqué `TODO[ref=, owner=, ETA=]`

**TOUTES SECTIONS PROUVÉES** (R67 + R68 + R69 NEW désaxiomatisation):
- Section 1-2 PROVED (tautologique)
- Section 3 PROVED (R67 NEW : ZMod.natCast_eq_zero_iff + push_cast + mul_inv_cancel₀)
- Section 4 PROVED (R68 NEW : orderOf_dvd_iff_pow_eq_one + linear_combination)
- Section 5 PROVED (R69 NEW : Nat.Coprime + ZMod.coe_mul_inv_eq_one + mul_assoc)

**Outil 4 (transport mod p) maintenant complètement formalisé sans sorry.**
-/

namespace ProjetCollatz.PostJAR

open ProjetCollatz Nat

/-! ## Section 1: Steiner identity mod p (universal, PROVED) -/

/-- **R63.1 — Steiner identity mod p**.

For any Collatz cycle `IsOddCycle n k` and any natural p:
  n * 2^(aSumSeq n k) ≡ 3^k * n + corrSum n k [MOD p]

Tautological but explicit. Used as foundation for non-tautological combinations.
-/
theorem cycle_steiner_mod_p (n k p : ℕ) (hcyc : IsOddCycle n k) :
    n * 2 ^ (aSumSeq n k) ≡ 3 ^ k * n + corrSum n k [MOD p] := by
  have h_steiner : n * 2 ^ (aSumSeq n k) = 3 ^ k * n + corrSum n k :=
    steiner_cycle_eq n k hcyc
  rw [h_steiner]

/-! ## Section 2: D_s positivity (universal, PROVED) -/

/-- **R63.2 — D_s > 0 for any cycle** (universal). Wrapper for cycle_pow2_gt_pow3. -/
theorem cycle_D_s_pos (n k : ℕ) (hcyc : IsOddCycle n k) :
    (2 : ℤ) ^ (aSumSeq n k) - 3 ^ k > 0 :=
  steiner_denom_pos_universal n k hcyc

/-! ## Section 2.5: n · D_s = corrSum (identité Steiner factorisée, R72 NEW) -/

/-- **R72 NEW — identité Steiner factorisée** : `n · (2^S - 3^k) = corrSum n k`.

C'est l'identité Steiner exprimée en factorisant `n` du côté gauche, en utilisant
la soustraction Nat valide grâce à `2^S > 3^k` pour les cycles.

**Universel** : pour tout cycle `IsOddCycle n k` (pas d'hypothèse sur p, modularité, etc.).

**Applications downstream** :
- R71 NEW : `p ∣ D_s ⟹ p ∣ corrSum` (preuve directe via `Dvd.dvd.mul_left`)
- Bornes corrSum : `corrSum ≤ n · D_s` (inégalité)
- Identité combinatoire pure (sans modularité)

**Preuve** (~10 lignes) : `Nat.mul_sub_left_distrib` + Steiner ℕ + omega.
-/
theorem cycle_n_mul_D_s_eq_corrSum
    (n k : ℕ) (hcyc : IsOddCycle n k) :
    n * ((2 : ℕ) ^ (aSumSeq n k) - 3 ^ k) = corrSum n k := by
  have h_steiner_nat : n * 2 ^ (aSumSeq n k) = 3 ^ k * n + corrSum n k :=
    steiner_cycle_eq n k hcyc
  have h_pow_gt : 2 ^ (aSumSeq n k) > 3 ^ k :=
    cycle_pow2_gt_pow3_universal n k hcyc
  have h_n_D_distrib : n * ((2 : ℕ) ^ (aSumSeq n k) - 3 ^ k) =
                       n * 2 ^ (aSumSeq n k) - n * 3 ^ k := by
    rw [Nat.mul_sub_left_distrib]
  rw [h_n_D_distrib, h_steiner_nat]
  have h_comm : 3 ^ k * n = n * 3 ^ k := by ring
  omega

/-! ## Section 3: Forcing n modulo p when p ∤ D_s (R66 — vrai énoncé) -/

/-- **R66.1 — Forcing n modulo p (HONEST statement, sorry preserved)**.

For any Collatz cycle `IsOddCycle n k` and prime p ≥ 5 with `p ∤ D_s`:
  (n : ZMod p) = (corrSum n k : ZMod p) * ((2^S - 3^k : ℕ) : ZMod p)⁻¹

This is a **non-trivial proposition** (no longer `True := sorry` mensongeur).
The proof is deferred to a sorry, but the *statement* is now mathematically
meaningful : `(n mod p)` is forced to a unique value when `D_s` is invertible.

Proof outline (R67) :
1. From `cycle_steiner_mod_p` cast to ZMod p :
     `(n : ZMod p) * (2^S : ZMod p) = (3^k : ZMod p) * (n : ZMod p) + (corrSum n k : ZMod p)`
2. Rearrange : `(n : ZMod p) * (2^S - 3^k) = corrSum n k`
3. `p ∤ D_s` ⟹ `(D_s : ZMod p) ≠ 0`
4. `ZMod p` is a field (p prime) ⟹ inverse exists
5. Multiply both sides by inverse.

**R67 NEW (test scaffolding OLD)**: désaxiomatisation via Mathlib ZMod.
Pattern : Steiner ℕ → cast ZMod → réarrangement → multiplication par inverse. -/
theorem cycle_n_forced_mod_p
    (n k p : ℕ) (hp : p.Prime) (hp_ge : p ≥ 5)
    (hcyc : IsOddCycle n k)
    (h_p_nmid : ¬ p ∣ ((2 : ℕ) ^ (aSumSeq n k) - 3 ^ k)) :
    (n : ZMod p) =
      (corrSum n k : ZMod p) *
      (((2 : ℕ) ^ (aSumSeq n k) - 3 ^ k : ℕ) : ZMod p)⁻¹ := by
  haveI : Fact p.Prime := ⟨hp⟩
  -- Étape 1 : Steiner identity in ℕ
  have h_steiner_nat : n * 2 ^ (aSumSeq n k) = 3 ^ k * n + corrSum n k :=
    steiner_cycle_eq n k hcyc
  -- Étape 2 : cast to ZMod p
  have h_steiner_zmod :
      (n : ZMod p) * (2 : ZMod p) ^ (aSumSeq n k) =
      (3 : ZMod p) ^ k * (n : ZMod p) + (corrSum n k : ZMod p) := by
    have h_cast : ((n * 2 ^ (aSumSeq n k) : ℕ) : ZMod p) =
                  ((3 ^ k * n + corrSum n k : ℕ) : ZMod p) :=
      congrArg (Nat.cast : ℕ → ZMod p) h_steiner_nat
    push_cast at h_cast
    exact h_cast
  -- Étape 3 : 2^S > 3^k for cycle
  have h_pow_gt : 2 ^ (aSumSeq n k) > 3 ^ k :=
    cycle_pow2_gt_pow3_universal n k hcyc
  have h_le : 3 ^ k ≤ 2 ^ (aSumSeq n k) := le_of_lt h_pow_gt
  -- Étape 4 : Nat-sub cast → ZMod difference
  have h_sub_cast :
      (((2 : ℕ) ^ (aSumSeq n k) - 3 ^ k : ℕ) : ZMod p) =
      (2 : ZMod p) ^ (aSumSeq n k) - (3 : ZMod p) ^ k := by
    rw [Nat.cast_sub h_le]
    push_cast
    ring
  -- Étape 5 : (D_s : ZMod p) ≠ 0
  have h_D_nonzero : (((2 : ℕ) ^ (aSumSeq n k) - 3 ^ k : ℕ) : ZMod p) ≠ 0 := by
    intro h_zero
    apply h_p_nmid
    rwa [ZMod.natCast_eq_zero_iff] at h_zero
  -- Étape 6 : rearrange n · D_s = corrSum mod p
  have h_rearr : (n : ZMod p) *
                 (((2 : ℕ) ^ (aSumSeq n k) - 3 ^ k : ℕ) : ZMod p) =
                 (corrSum n k : ZMod p) := by
    rw [h_sub_cast]
    have h_distr : (n : ZMod p) *
                   ((2 : ZMod p) ^ (aSumSeq n k) - (3 : ZMod p) ^ k) =
                   (n : ZMod p) * (2 : ZMod p) ^ (aSumSeq n k) -
                   (3 : ZMod p) ^ k * (n : ZMod p) := by ring
    rw [h_distr, h_steiner_zmod]
    ring
  -- Étape 7 : multiply by inverse
  rw [eq_comm, ← h_rearr, mul_assoc, mul_inv_cancel₀ h_D_nonzero, mul_one]

/-! ## Section 4: Order constraint when ord_p(2) | S (R66 — vrai énoncé) -/

/-- **R66.2 — Constraint when ord_p(2) divides S (HONEST statement, sorry preserved)**.

For p prime ≥ 5 with `orderOf (2 : ZMod p) ∣ aSumSeq n k`, we have
`(2 : ZMod p)^S = 1`. Combined with Steiner mod p :
  (n : ZMod p) * (1 - (3 : ZMod p)^k) = (corrSum n k : ZMod p)

Vraie proposition (no longer `True := sorry`). Proof outline (R68) :
1. From hypothesis ord_p(2) | S, we have `(2 : ZMod p)^S = 1` (Mathlib `pow_orderOf_eq_one`).
2. Cast `cycle_steiner_mod_p` to ZMod p with `(2^S : ZMod p) = 1`.
3. Rearrange algebraically.

**R68 NEW (désaxiomatisation)** : preuve via `orderOf_dvd_iff_pow_eq_one`. -/
theorem cycle_constraint_when_ord_divides_S
    (n k p : ℕ) (hp : p.Prime) (_hp_ge : p ≥ 5)
    (hcyc : IsOddCycle n k)
    (h_ord : orderOf (2 : ZMod p) ∣ aSumSeq n k) :
    (n : ZMod p) * (1 - (3 : ZMod p) ^ k) = (corrSum n k : ZMod p) := by
  haveI : Fact p.Prime := ⟨hp⟩
  -- Étape 1 : (2 : ZMod p)^S = 1
  have h_pow_one : (2 : ZMod p) ^ aSumSeq n k = 1 :=
    orderOf_dvd_iff_pow_eq_one.mp h_ord
  -- Étape 2 : Steiner mod p
  have h_steiner_nat : n * 2 ^ (aSumSeq n k) = 3 ^ k * n + corrSum n k :=
    steiner_cycle_eq n k hcyc
  have h_steiner_zmod :
      (n : ZMod p) * (2 : ZMod p) ^ (aSumSeq n k) =
      (3 : ZMod p) ^ k * (n : ZMod p) + (corrSum n k : ZMod p) := by
    have h_cast : ((n * 2 ^ (aSumSeq n k) : ℕ) : ZMod p) =
                  ((3 ^ k * n + corrSum n k : ℕ) : ZMod p) :=
      congrArg (Nat.cast : ℕ → ZMod p) h_steiner_nat
    push_cast at h_cast
    exact h_cast
  -- Étape 3 : substituer 2^S = 1
  rw [h_pow_one, mul_one] at h_steiner_zmod
  -- h_steiner_zmod : (n : ZMod p) = (3 : ZMod p)^k * (n : ZMod p) + (corrSum n k : ZMod p)
  linear_combination h_steiner_zmod

/-! ## Section 5: CRT combination across distinct primes (R66 — vrai énoncé) -/

/-- **R66.3 — CRT combination (HONEST statement, sorry preserved)**.

If p₁ ≠ p₂ are distinct primes both ≥ 5 not dividing D_s, then
`(n : ZMod (p₁ * p₂))` is forced via Chinese Remainder Theorem.

Vraie proposition (no longer `True := sorry`). Proof outline (R69) :
1. Decompose `ZMod (p1 * p2) ≃ ZMod p1 × ZMod p2` via `ZMod.chineseRemainderEquiv`.
2. Apply `cycle_n_forced_mod_p` separately for p1 and p2.
3. Recombine via CRT isomorphism.

**R69 NEW (désaxiomatisation)** : preuve via `IsUnit.eq_mul_inv_iff_mul_eq` +
coprime D_s avec p1*p2 (Nat.Prime.coprime_iff_not_dvd + Nat.Coprime.mul_right). -/
theorem cycle_n_forced_mod_p1_p2
    (n k p1 p2 : ℕ) (hp1 : p1.Prime) (hp2 : p2.Prime) (_hp_distinct : p1 ≠ p2)
    (_hp1_ge : p1 ≥ 5) (_hp2_ge : p2 ≥ 5)
    (hcyc : IsOddCycle n k)
    (h_p1_nmid : ¬ p1 ∣ ((2 : ℕ) ^ (aSumSeq n k) - 3 ^ k))
    (h_p2_nmid : ¬ p2 ∣ ((2 : ℕ) ^ (aSumSeq n k) - 3 ^ k)) :
    (n : ZMod (p1 * p2)) =
      (corrSum n k : ZMod (p1 * p2)) *
      (((2 : ℕ) ^ (aSumSeq n k) - 3 ^ k : ℕ) : ZMod (p1 * p2))⁻¹ := by
  -- Étape 1 : Steiner ℕ
  have h_steiner_nat : n * 2 ^ (aSumSeq n k) = 3 ^ k * n + corrSum n k :=
    steiner_cycle_eq n k hcyc
  -- Étape 2 : cast to ZMod (p1*p2)
  have h_steiner_zmod :
      (n : ZMod (p1 * p2)) * (2 : ZMod (p1 * p2)) ^ (aSumSeq n k) =
      (3 : ZMod (p1 * p2)) ^ k * (n : ZMod (p1 * p2)) +
      (corrSum n k : ZMod (p1 * p2)) := by
    have h_cast : ((n * 2 ^ (aSumSeq n k) : ℕ) : ZMod (p1 * p2)) =
                  ((3 ^ k * n + corrSum n k : ℕ) : ZMod (p1 * p2)) :=
      congrArg (Nat.cast : ℕ → ZMod (p1 * p2)) h_steiner_nat
    push_cast at h_cast
    exact h_cast
  -- Étape 3 : 2^S > 3^k
  have h_pow_gt : 2 ^ (aSumSeq n k) > 3 ^ k :=
    cycle_pow2_gt_pow3_universal n k hcyc
  have h_le : 3 ^ k ≤ 2 ^ (aSumSeq n k) := le_of_lt h_pow_gt
  -- Étape 4 : Nat-sub cast → ZMod sub
  have h_sub_cast :
      (((2 : ℕ) ^ (aSumSeq n k) - 3 ^ k : ℕ) : ZMod (p1 * p2)) =
      (2 : ZMod (p1 * p2)) ^ (aSumSeq n k) - (3 : ZMod (p1 * p2)) ^ k := by
    rw [Nat.cast_sub h_le]; push_cast; ring
  -- Étape 5 : n · D_s = corrSum mod (p1*p2)
  have h_rearr : (n : ZMod (p1 * p2)) *
                 (((2 : ℕ) ^ (aSumSeq n k) - 3 ^ k : ℕ) : ZMod (p1 * p2)) =
                 (corrSum n k : ZMod (p1 * p2)) := by
    rw [h_sub_cast]
    have h_distr : (n : ZMod (p1 * p2)) *
                   ((2 : ZMod (p1 * p2)) ^ (aSumSeq n k) -
                    (3 : ZMod (p1 * p2)) ^ k) =
                   (n : ZMod (p1 * p2)) * (2 : ZMod (p1 * p2)) ^ (aSumSeq n k) -
                   (3 : ZMod (p1 * p2)) ^ k * (n : ZMod (p1 * p2)) := by ring
    rw [h_distr, h_steiner_zmod]; ring
  -- Étape 6 : coprime D_s avec p1 et p2
  have h_coprime_p1 : Nat.Coprime ((2 : ℕ) ^ (aSumSeq n k) - 3 ^ k) p1 := by
    rw [Nat.coprime_comm]
    exact (Nat.Prime.coprime_iff_not_dvd hp1).mpr h_p1_nmid
  have h_coprime_p2 : Nat.Coprime ((2 : ℕ) ^ (aSumSeq n k) - 3 ^ k) p2 := by
    rw [Nat.coprime_comm]
    exact (Nat.Prime.coprime_iff_not_dvd hp2).mpr h_p2_nmid
  have h_coprime : Nat.Coprime ((2 : ℕ) ^ (aSumSeq n k) - 3 ^ k) (p1 * p2) :=
    Nat.Coprime.mul_right h_coprime_p1 h_coprime_p2
  -- Étape 7 : D_s · D_s⁻¹ = 1 dans ZMod (p1·p2) (via coe_mul_inv_eq_one)
  have h_inv : (((2 : ℕ) ^ (aSumSeq n k) - 3 ^ k : ℕ) : ZMod (p1 * p2)) *
               (((2 : ℕ) ^ (aSumSeq n k) - 3 ^ k : ℕ) : ZMod (p1 * p2))⁻¹ = 1 :=
    ZMod.coe_mul_inv_eq_one _ h_coprime
  -- Étape 8 : multiplier h_rearr par D_s⁻¹ et simplifier
  have h_step : (n : ZMod (p1 * p2)) *
                (((2 : ℕ) ^ (aSumSeq n k) - 3 ^ k : ℕ) : ZMod (p1 * p2)) *
                (((2 : ℕ) ^ (aSumSeq n k) - 3 ^ k : ℕ) : ZMod (p1 * p2))⁻¹ =
                (corrSum n k : ZMod (p1 * p2)) *
                (((2 : ℕ) ^ (aSumSeq n k) - 3 ^ k : ℕ) : ZMod (p1 * p2))⁻¹ :=
    congrArg (· * _) h_rearr
  rw [mul_assoc, h_inv, mul_one] at h_step
  exact h_step

/-! ## Section 6: Documentation note (Honest scope OLD F1)

**Honest scope (R66 OLD raffiné)**:

Outil 4 (transport de congruences) est l'**infrastructure** pour combiner
contraintes modulaires. Par lui-même, il ne tue pas les cycles (essentiellement
Steiner mod p, tautologique). Sa **valeur** vient de la combinaison avec :

1. OU-A (descent, R56) → n forced + Barina bound + stopping time.
2. OU-B (ratio, R59) → max/min n_i bounded.
3. OU-D (v_2 = 0, R58) → 2-adic structure.
4. CRT across multiple primes → polynomial bound on n.

R67-R69 désaxiomatiseront les sorries via Mathlib ZMod machinery.

**Leçon NASA Power-of-Ten** (Red Team R65 severity 9/10) :
- Naming truthful : pas de `_unproven` suffix si statement réel
- Statement non trivial : pas de `True := sorry` mensongeur
- Sorry trackable : `TODO[ref=, owner=, ETA=]`
- Cohérence docstring/body : flagger explicitement les sorries
-/

/-! ## Section 6.5: R75 NEW — n divise corrSum (conséquence directe R72) -/

/-- **R75 NEW — n divise corrSum** (conséquence directe de R72).

Pour tout cycle non-trivial, `n ∣ corrSum n k`. C'est une **contrainte
Diophantienne universelle** :

`n` (le minimum du cycle) divise toujours son propre contrepoids `corrSum`.

**Universel** (pas d'hypothèse modulaire, pas de primalité).

**Conséquence stratégique** : combinée avec R71 NEW (p ∣ D_s ⟹ p ∣ corrSum),
on a deux contraintes complémentaires sur corrSum :
- `n ∣ corrSum n k` (cette R75)
- `∀ p, p ∣ D_s ⟹ p ∣ corrSum` (R71)

Donc `lcm(n, D_s) ∣ corrSum n k` (mais cette propriété n'est pas formalisée
explicitement ici, dépend de Mathlib `Nat.lcm_dvd`).

**Preuve** (~3 lignes) : R72 donne `n * D_s = corrSum`, donc directement
`n ∣ n * D_s = corrSum`. -/
theorem cycle_n_dvd_corrSum
    (n k : ℕ) (hcyc : IsOddCycle n k) :
    n ∣ corrSum n k := by
  rw [← cycle_n_mul_D_s_eq_corrSum n k hcyc]
  exact dvd_mul_right n _

/-- **R75.2 NEW — D_s divise corrSum** (autre conséquence de R72).

Symétrique de R75 NEW : `(2^S - 3^k) ∣ corrSum n k`.

C'est l'**autre direction** de R71 NEW. R71 dit "tout diviseur de D_s divise
corrSum". R75.2 dit "D_s lui-même divise corrSum" (cas particulier triviale via R72). -/
theorem cycle_D_s_dvd_corrSum
    (n k : ℕ) (hcyc : IsOddCycle n k) :
    ((2 : ℕ) ^ (aSumSeq n k) - 3 ^ k) ∣ corrSum n k := by
  rw [← cycle_n_mul_D_s_eq_corrSum n k hcyc]
  exact dvd_mul_left _ n

/-! ## Section 6.6: R76 NEW — bornes Diophantiennes sur corrSum (corollaires R72)

R72 (`n * D_s = corrSum`) implique des **contraintes Diophantiennes structurelles**
sur le contrepoids `corrSum n k` que je rends explicites ici pour usage downstream.
-/

/-- **R76.1 NEW — corrSum ≥ n** (taille minimum du contrepoids).

Pour tout cycle non-trivial, `corrSum n k ≥ n`. C'est un **outil de comparaison
numérique** : combiné avec une borne supérieure sur corrSum (par exemple via
formule combinatoire parityVector), donne une borne supérieure sur n.

**Preuve** (~5 lignes) : `corrSum = n * D_s` (R72), `D_s ≥ 1` (cycle_pow2_gt_pow3),
donc `corrSum ≥ n * 1 = n`. -/
theorem cycle_corrSum_ge_n
    (n k : ℕ) (hcyc : IsOddCycle n k) :
    corrSum n k ≥ n := by
  rw [← cycle_n_mul_D_s_eq_corrSum n k hcyc]
  have h_D_s_ge_one : (2 : ℕ) ^ (aSumSeq n k) - 3 ^ k ≥ 1 := by
    have h_strict : (2 : ℕ) ^ (aSumSeq n k) > 3 ^ k :=
      cycle_pow2_gt_pow3_universal n k hcyc
    omega
  calc n * ((2 : ℕ) ^ (aSumSeq n k) - 3 ^ k)
      ≥ n * 1 := Nat.mul_le_mul_left n h_D_s_ge_one
    _ = n := by ring

/-- **R76.2 NEW — gcd(n, corrSum) = n** (refinement divisibilité).

Pour tout cycle non-trivial, `Nat.gcd n (corrSum n k) = n`. C'est un
**raffinement** de R75.1 (`n ∣ corrSum`) : le pgcd est exactement `n`.

**Preuve** (~3 lignes) : `n ∣ corrSum` (R75.1) ⟹ `gcd n corrSum = n` via
`Nat.gcd_eq_left` (Mathlib).
-/
theorem cycle_gcd_n_corrSum_eq_n
    (n k : ℕ) (hcyc : IsOddCycle n k) :
    Nat.gcd n (corrSum n k) = n :=
  Nat.gcd_eq_left (cycle_n_dvd_corrSum n k hcyc)

/-- **R76.3 NEW — lcm(n, D_s) ∣ corrSum** (combinaison R75.1 + R75.2).

Pour tout cycle non-trivial, `Nat.lcm n D_s ∣ corrSum n k`. Utilise
`Nat.lcm_dvd` (Mathlib) : si `a ∣ c` et `b ∣ c`, alors `lcm a b ∣ c`.

**Conséquence quantitative** : `lcm(n, D_s) * gcd(n, D_s) = n * D_s = corrSum`
(via R72), donc `lcm(n, D_s) = corrSum / gcd(n, D_s)`. C'est une identité
**quotient explicite** : le contrepoids divisé par le pgcd donne le ppcm. -/
theorem cycle_lcm_n_D_s_dvd_corrSum
    (n k : ℕ) (hcyc : IsOddCycle n k) :
    Nat.lcm n ((2 : ℕ) ^ (aSumSeq n k) - 3 ^ k) ∣ corrSum n k :=
  Nat.lcm_dvd (cycle_n_dvd_corrSum n k hcyc) (cycle_D_s_dvd_corrSum n k hcyc)

/-! ## Section 6.7: R77 NEW — bornes via n ≥ 3 (cycles odd > 1)

`IsOddCycle` exige `n > 1` ET `n % 2 = 1`. Le plus petit entier odd > 1 est 3,
donc `n ≥ 3` toujours. Ce fait basique permet de raffiner R76.1 (`corrSum ≥ n`)
en utilisant la borne tighter `corrSum ≥ 3 * D_s`.
-/

/-- **R77.1 NEW — n ≥ 3 pour tout cycle non-trivial** (universel).

`IsOddCycle n k` exige `n > 1` ET `n % 2 = 1`. Donc `n ≥ 3` (plus petit
entier odd > 1).

Outil universel basique qui devrait être utilisé dans tous les théorèmes
nécessitant une borne minimum sur n. -/
theorem cycle_n_ge_three
    (n k : ℕ) (hcyc : IsOddCycle n k) :
    n ≥ 3 := by
  obtain ⟨hn_gt1, hodd, _, _⟩ := hcyc
  -- n > 1 et n impair ⟹ n ≥ 3
  omega

/-- **R77.2 NEW — corrSum ≥ 3 * D_s** (raffinement quantitatif R76.1).

Pour tout cycle non-trivial, `corrSum n k ≥ 3 * (2^S - 3^k)`. Trois fois plus
fort que R76.1 (`corrSum ≥ n` avec n ≥ 1 implicite).

**Preuve** : R72 (`corrSum = n * D_s`) + R77.1 (`n ≥ 3`).

**Conséquence** : si on a une borne supérieure sur corrSum (ex: combinatoire
parityVector), elle donne une borne supérieure sur D_s = (2^S - 3^k)/n ≤ corrSum/3.
C'est un canal Diophantien explicit. -/
theorem cycle_corrSum_ge_three_times_D_s
    (n k : ℕ) (hcyc : IsOddCycle n k) :
    corrSum n k ≥ 3 * ((2 : ℕ) ^ (aSumSeq n k) - 3 ^ k) := by
  rw [← cycle_n_mul_D_s_eq_corrSum n k hcyc]
  have h_n_ge_three : n ≥ 3 := cycle_n_ge_three n k hcyc
  -- Goal: n * D_s ≥ 3 * D_s
  exact Nat.mul_le_mul_right _ h_n_ge_three

/-- **R77.3 NEW — D_s ≤ corrSum / 3** (corollaire de R77.2).

Pour tout cycle non-trivial, `D_s = 2^S - 3^k ≤ corrSum n k / 3` (division
entière). C'est l'**autre direction** de R77.2 — borne explicite sur D_s en
termes de corrSum. -/
theorem cycle_D_s_le_corrSum_div_three
    (n k : ℕ) (hcyc : IsOddCycle n k) :
    (2 : ℕ) ^ (aSumSeq n k) - 3 ^ k ≤ corrSum n k / 3 := by
  have h_ge : corrSum n k ≥ 3 * ((2 : ℕ) ^ (aSumSeq n k) - 3 ^ k) :=
    cycle_corrSum_ge_three_times_D_s n k hcyc
  -- Nat.le_div_iff_mul_le : (a ≤ b / c) ↔ (a * c ≤ b) si c > 0
  rw [Nat.le_div_iff_mul_le (by norm_num : (0 : ℕ) < 3)]
  linarith

/-! ## Section 6.8: R78 NEW — sandwich corrSum n ≤ corrSum < n * 2^S

Combine R76.1 (corrSum ≥ n) avec une borne supérieure : corrSum < n * 2^S.

Borne supérieure : `corrSum = n * (2^S - 3^k) < n * 2^S` (puisque 3^k > 0).
-/

/-- **R78.1 NEW — corrSum > 0** (positivité stricte).

Pour tout cycle non-trivial, `corrSum n k > 0`. Conséquence directe de
`corrSum ≥ n` (R76.1) et `n ≥ 3` (R77.1).

Usage : nécessaire pour les cast ZMod et les divisions dans bornes downstream. -/
theorem cycle_corrSum_pos
    (n k : ℕ) (hcyc : IsOddCycle n k) :
    corrSum n k > 0 := by
  have h_ge : corrSum n k ≥ n := cycle_corrSum_ge_n n k hcyc
  have h_n_ge : n ≥ 3 := cycle_n_ge_three n k hcyc
  omega

/-- **R78.2 NEW — corrSum < n * 2^S** (borne supérieure naturelle).

Pour tout cycle non-trivial, `corrSum n k < n * 2^(aSumSeq n k)`.

**Preuve** : R72 (`corrSum = n * (2^S - 3^k)`) + `2^S - 3^k < 2^S` (puisque 3^k > 0).

**Usage** : combinée avec R76.1 (`corrSum ≥ n`), donne le **sandwich `n ≤ corrSum < n * 2^S`**
qui borne corrSum dans un intervalle explicite en termes de n et S. -/
theorem cycle_corrSum_lt_n_times_2_pow_S
    (n k : ℕ) (hcyc : IsOddCycle n k) :
    corrSum n k < n * 2 ^ (aSumSeq n k) := by
  rw [← cycle_n_mul_D_s_eq_corrSum n k hcyc]
  -- Goal: n * (2^S - 3^k) < n * 2^S
  have h_n_pos : n > 0 := by
    have h_n_ge : n ≥ 3 := cycle_n_ge_three n k hcyc
    omega
  have h_pow_gt : (2 : ℕ) ^ (aSumSeq n k) > 3 ^ k :=
    cycle_pow2_gt_pow3_universal n k hcyc
  have h_3k_pos : (3 : ℕ) ^ k > 0 := pow_pos (by norm_num) k
  have h_diff_lt : (2 : ℕ) ^ (aSumSeq n k) - 3 ^ k < 2 ^ (aSumSeq n k) := by
    omega
  exact Nat.mul_lt_mul_of_pos_left h_diff_lt h_n_pos

/-- **R78.3 NEW — sandwich corrSum** : `n ≤ corrSum n k < n * 2^S`.

Théorème de synthèse combinant R76.1 et R78.2. Sandwich Diophantien sur
corrSum en termes de n et 2^S. -/
theorem cycle_corrSum_sandwich
    (n k : ℕ) (hcyc : IsOddCycle n k) :
    n ≤ corrSum n k ∧ corrSum n k < n * 2 ^ (aSumSeq n k) :=
  ⟨cycle_corrSum_ge_n n k hcyc, cycle_corrSum_lt_n_times_2_pow_S n k hcyc⟩

/-! ## Section 6.9: R79 NEW — corrSum = gcd(n, D_s) × lcm(n, D_s)

Identité gcd-lcm fondamentale (Mathlib `Nat.gcd_mul_lcm`) : `gcd a b * lcm a b = a * b`.
Combinée avec R72 (`corrSum = n * D_s`), donne :

**corrSum n k = gcd(n, D_s) × lcm(n, D_s)**

C'est une identité **exacte** qui renforce R76.3 (`lcm ∣ corrSum`) avec un quotient
explicite : `corrSum / lcm(n, D_s) = gcd(n, D_s)`.
-/

/-- **R79 NEW — Identité corrSum = gcd × lcm**.

Pour tout cycle non-trivial,
  `Nat.gcd n (2^S - 3^k) * Nat.lcm n (2^S - 3^k) = corrSum n k`

**Conséquence quantitative** : si on connaît `gcd(n, D_s)` (par exemple = 1
pour cycles "co-primes"), on a `corrSum = lcm(n, D_s)` directement.

**Preuve** (~3 lignes) : `Nat.gcd_mul_lcm` + R72 (`n * D_s = corrSum`).
-/
theorem cycle_gcd_mul_lcm_eq_corrSum
    (n k : ℕ) (hcyc : IsOddCycle n k) :
    Nat.gcd n ((2 : ℕ) ^ (aSumSeq n k) - 3 ^ k) *
    Nat.lcm n ((2 : ℕ) ^ (aSumSeq n k) - 3 ^ k) = corrSum n k := by
  rw [Nat.gcd_mul_lcm]
  exact cycle_n_mul_D_s_eq_corrSum n k hcyc

/-- **R79.2 NEW — Corollaire : si gcd(n, D_s) = 1 alors corrSum = lcm(n, D_s)**.

Pour cycles avec `n` et `D_s` co-premiers, le contrepoids est exactement le ppcm.

**Conséquence** : pour cycles co-premiers (probable cas générique), `corrSum`
est entièrement déterminé par `lcm(n, D_s)` qui peut être borné en termes de
n et D_s individuels. -/
theorem cycle_corrSum_eq_lcm_of_coprime
    (n k : ℕ) (hcyc : IsOddCycle n k)
    (h_coprime : Nat.Coprime n ((2 : ℕ) ^ (aSumSeq n k) - 3 ^ k)) :
    corrSum n k = Nat.lcm n ((2 : ℕ) ^ (aSumSeq n k) - 3 ^ k) := by
  have h_id : Nat.gcd n ((2 : ℕ) ^ (aSumSeq n k) - 3 ^ k) *
              Nat.lcm n ((2 : ℕ) ^ (aSumSeq n k) - 3 ^ k) = corrSum n k :=
    cycle_gcd_mul_lcm_eq_corrSum n k hcyc
  rw [h_coprime] at h_id
  -- h_id : 1 * Nat.lcm ... = corrSum n k
  rw [one_mul] at h_id
  exact h_id.symm

/-! ## Section 7: R70 NEW — corrSum divisé par premiers résonants -/

/-- **R70 NEW — corollaire fort de R68** : pour tout cycle non-trivial et
tout premier p ≥ 5 tel que `ord_p(2) ∣ S` ET `ord_p(3) ∣ k`, alors `p ∣ corrSum n k`.

**Sémantique** : si p est "doublement résonant" (les ordres de 2 et 3 modulo p
divisent respectivement S et k), alors le contrepoids `corrSum` du cycle est
forcément divisé par p.

**Conséquence Collatz** : pour des cycles courts (k petit), les premiers p tels
que ord_p(3) | k sont nombreux (par théorie des ordres). Combiné avec la
condition ord_p(2) | S, c'est une **contrainte non-triviale** sur corrSum
qui dépend du parityVector. L'arbre 13 est ainsi connecté à la structure
combinatoire des cycles.

**Preuve** (~20 lignes) :
1. R68 ⟹ `(n : ZMod p) * (1 - (3 : ZMod p)^k) = (corrSum n k : ZMod p)`
2. ord_p(3) | k ⟹ `(3 : ZMod p)^k = 1`
3. Donc `(n : ZMod p) * 0 = (corrSum n k : ZMod p)`
4. Donc `(corrSum n k : ZMod p) = 0`
5. Par `ZMod.natCast_eq_zero_iff` : `p ∣ corrSum n k`. -/
theorem cycle_corrSum_dvd_by_resonant_prime
    (n k p : ℕ) (hp : p.Prime) (hp_ge : p ≥ 5)
    (hcyc : IsOddCycle n k)
    (h_ord_2 : orderOf (2 : ZMod p) ∣ aSumSeq n k)
    (h_ord_3 : orderOf (3 : ZMod p) ∣ k) :
    p ∣ corrSum n k := by
  -- Étape 1 : appliquer R68
  have h_R68 : (n : ZMod p) * (1 - (3 : ZMod p) ^ k) = (corrSum n k : ZMod p) :=
    cycle_constraint_when_ord_divides_S n k p hp hp_ge hcyc h_ord_2
  -- Étape 2 : (3 : ZMod p)^k = 1
  have h_3_pow_one : (3 : ZMod p) ^ k = 1 :=
    orderOf_dvd_iff_pow_eq_one.mp h_ord_3
  -- Étape 3 : substituer dans R68
  rw [h_3_pow_one, sub_self, mul_zero] at h_R68
  -- h_R68 : 0 = (corrSum n k : ZMod p)
  -- Étape 4 : conclure via ZMod.natCast_eq_zero_iff
  have h_zero : (corrSum n k : ZMod p) = 0 := h_R68.symm
  rwa [ZMod.natCast_eq_zero_iff] at h_zero

/-! ## Section 8: R71 NEW — généralisation universelle (sans primalité ni ordres)

R70 NEW exige `ord_p(2) | S` ET `ord_p(3) | k` (deux conditions sur p premier).
Mais en remontant la preuve via Steiner ℕ, on obtient une **généralisation
universelle plus forte** sans aucune hypothèse sur p.

**Insight clé** : Steiner identité ⟹ `n * D_s = corrSum n k` (dans ℕ).
Donc `p ∣ D_s ⟹ p ∣ (n * D_s) = corrSum`. Aucune primalité requise.
-/

/-- **R71 NEW — généralisation universelle de R70 (sans primalité)**.

Pour tout cycle non-trivial et tout entier `p ≥ 0` divisant `D_s = 2^S - 3^k` :
  p ∣ corrSum n k

Pas d'hypothèse de primalité, pas d'hypothèse sur les ordres. Forme la plus
générale du résultat "D_s contraint corrSum".

**Conséquence** :
- R70 NEW (avec `ord_p(2) | S ∧ ord_p(3) | k`) est un **cas particulier**
  car ces conditions impliquent `2^S ≡ 1` et `3^k ≡ 1` mod p, donc `p ∣ D_s`.
- R71 généralise à tous les diviseurs de D_s, y compris non-premiers.

**Conséquence quantitative** : `D_s = 2^S - 3^k` est un nombre concret pour
chaque cycle. Tout diviseur de D_s divise corrSum. Donc `D_s ∣ corrSum n k *
gcd(...)` ou similar — fournit des contraintes sur la structure de corrSum.

**Preuve** (~15 lignes) : Steiner ℕ donne `n * 2^S = 3^k * n + corrSum`. Avec
`2^S > 3^k` (cycle), on obtient `n * (2^S - 3^k) = corrSum` par soustraction.
Si `p ∣ D_s = 2^S - 3^k`, alors `p ∣ n * D_s = corrSum`. -/
theorem cycle_p_dvd_D_s_implies_p_dvd_corrSum
    (n k p : ℕ) (hcyc : IsOddCycle n k)
    (h_p_dvd : p ∣ ((2 : ℕ) ^ (aSumSeq n k) - 3 ^ k)) :
    p ∣ corrSum n k := by
  -- Refactoring R72 NEW : utilise cycle_n_mul_D_s_eq_corrSum directement
  rw [← cycle_n_mul_D_s_eq_corrSum n k hcyc]
  exact Dvd.dvd.mul_left h_p_dvd n

/-! ### Note sur la version converse (non prouvée)

Si on suppose le lemme converse `p ∣ corrSum n k ⟹ ord_p(2) ∣ S ∧ ord_p(3) ∣ k`
(non prouvé ici, à explorer), on obtiendrait une caractérisation. Pour
l'instant, R70 NEW livre seulement la direction directe (⟹), suffisante
pour l'arbre 13.

La direction converse est non triviale et n'est probablement pas vraie sans
hypothèses additionnelles. -/

/-! ## Section 10: R81 NEW — Finset version : n premiers distincts → produit ∣ corrSum

Généralisation Finset de R80 NEW. Pour tout Finset S de premiers tous divisant
D_s, le produit `S.prod id` divise corrSum n k.

Étape vers "radical(D_s) ∣ corrSum" qui prendrait S = primeFactors(D_s).
-/

/-- **R81 NEW — Finset version multi-premier ∣ D_s ⟹ produit ∣ corrSum**.

Pour tout cycle non-trivial et tout Finset `S` de premiers divisant `D_s`,
on a `S.prod id ∣ corrSum n k`.

**Stratégie** : induction sur `S` via `Finset.induction_on`. À chaque étape,
appliquer R71 + coprimalité (premiers distincts) + `Nat.Coprime.mul_dvd_of_dvd_of_dvd`.

**Preuve** (~20 lignes) : pas de dépendance Mathlib non triviale au-delà de
`Nat.Coprime.prod_right` + `Nat.coprime_primes` + `Finset.induction_on`. -/
theorem cycle_finset_distinct_primes_dvd_D_s_dvd_corrSum
    (n k : ℕ) (hcyc : IsOddCycle n k) (S : Finset ℕ)
    (h_primes : ∀ p ∈ S, p.Prime)
    (h_dvd : ∀ p ∈ S, p ∣ ((2 : ℕ) ^ (aSumSeq n k) - 3 ^ k)) :
    S.prod id ∣ corrSum n k := by
  classical
  induction S using Finset.induction_on with
  | empty => simp
  | @insert a r har ih =>
    rw [Finset.prod_insert har]
    have ha_prime : a.Prime := h_primes a (Finset.mem_insert_self a r)
    have ha_dvd_D_s : a ∣ ((2 : ℕ) ^ (aSumSeq n k) - 3 ^ k) :=
      h_dvd a (Finset.mem_insert_self a r)
    have ha_dvd_corr : a ∣ corrSum n k :=
      cycle_p_dvd_D_s_implies_p_dvd_corrSum n k a hcyc ha_dvd_D_s
    have h_primes_r : ∀ p ∈ r, p.Prime :=
      fun p hp => h_primes p (Finset.mem_insert_of_mem hp)
    have h_dvd_r : ∀ p ∈ r, p ∣ ((2 : ℕ) ^ (aSumSeq n k) - 3 ^ k) :=
      fun p hp => h_dvd p (Finset.mem_insert_of_mem hp)
    have h_ih : r.prod id ∣ corrSum n k := ih h_primes_r h_dvd_r
    have h_coprime : Nat.Coprime a (r.prod id) := by
      apply Nat.Coprime.prod_right
      intro p hp
      have hp_prime : p.Prime := h_primes_r p hp
      have hp_ne_a : p ≠ a := fun h_eq => by
        rw [h_eq] at hp
        exact har hp
      simp only [id]
      exact (Nat.coprime_primes ha_prime hp_prime).mpr (Ne.symm hp_ne_a)
    exact Nat.Coprime.mul_dvd_of_dvd_of_dvd h_coprime ha_dvd_corr h_ih

/-! ## Section 9: R80 NEW — produit de 2 premiers distincts divisant D_s

Extension multiplicative de R71 NEW. Si p₁ ≠ p₂ sont 2 premiers divisant
tous deux D_s, alors leur produit p₁ × p₂ divise corrSum.

Étape vers "radical(D_s) ∣ corrSum" version Finset (R81+ futur).
-/

/-- **R80 NEW — 2 premiers distincts ∣ D_s ⟹ p₁ × p₂ ∣ corrSum**.

Pour tout cycle non-trivial et 2 premiers distincts `p₁ ≠ p₂` divisant `D_s`,
on a `p₁ * p₂ ∣ corrSum n k`.

**Stratégie** : combine R71 (chaque pᵢ ∣ corrSum) + coprimalité distincte primes
+ `Nat.Coprime.mul_dvd_of_dvd_of_dvd`.

**Conséquence** : pour cycles avec D_s ayant plusieurs facteurs premiers
distincts, corrSum est très divisible. Borne inférieure forte sur corrSum
(produit de tous les premiers distincts dans factorisation D_s).

**Preuve** (~10 lignes) : R71 deux fois + coprime de Prime distinct + Mathlib. -/
theorem cycle_two_distinct_primes_dvd_D_s_dvd_corrSum
    (n k p1 p2 : ℕ) (hp1 : p1.Prime) (hp2 : p2.Prime) (h_distinct : p1 ≠ p2)
    (hcyc : IsOddCycle n k)
    (h_p1_dvd : p1 ∣ ((2 : ℕ) ^ (aSumSeq n k) - 3 ^ k))
    (h_p2_dvd : p2 ∣ ((2 : ℕ) ^ (aSumSeq n k) - 3 ^ k)) :
    p1 * p2 ∣ corrSum n k := by
  have h_p1_corr : p1 ∣ corrSum n k :=
    cycle_p_dvd_D_s_implies_p_dvd_corrSum n k p1 hcyc h_p1_dvd
  have h_p2_corr : p2 ∣ corrSum n k :=
    cycle_p_dvd_D_s_implies_p_dvd_corrSum n k p2 hcyc h_p2_dvd
  have h_coprime : Nat.Coprime p1 p2 :=
    (Nat.coprime_primes hp1 hp2).mpr h_distinct
  exact Nat.Coprime.mul_dvd_of_dvd_of_dvd h_coprime h_p1_corr h_p2_corr

/-! ## Section 11: R82 NEW — radical(D_s) ∣ corrSum (Mathlib primeFactors)

Application directe de R81 NEW à `S = (D_s).primeFactors`. Donne le résultat
le plus fort dans cette direction : **le produit de TOUS les premiers distincts
divisant D_s divise corrSum**.
-/

/-- **R82 NEW — radical(D_s) ∣ corrSum n k** (Mathlib primeFactors version).

Pour tout cycle non-trivial,
  `((D_s).primeFactors).prod id ∣ corrSum n k`

où `D_s = 2^S - 3^k` et `primeFactors` est la `Finset` des premiers distincts
divisant D_s (Mathlib API).

**Conséquence forte** : c'est le **radical de D_s** (squarefree part) qui
divise corrSum. Pour D_s avec beaucoup de petits facteurs premiers distincts,
le radical peut être grand ⟹ corrSum est très divisible.

**Preuve** (~5 lignes) : applique R81 avec `S = (D_s).primeFactors` et utilise
`Nat.mem_primeFactors` pour extraire primalité + divisibilité. -/
theorem cycle_radical_D_s_dvd_corrSum
    (n k : ℕ) (hcyc : IsOddCycle n k) :
    (((2 : ℕ) ^ (aSumSeq n k) - 3 ^ k).primeFactors).prod id ∣ corrSum n k := by
  apply cycle_finset_distinct_primes_dvd_D_s_dvd_corrSum n k hcyc
  · intro p hp
    exact (Nat.mem_primeFactors.mp hp).1
  · intro p hp
    exact (Nat.mem_primeFactors.mp hp).2.1

/-! ## Section 12: R83 NEW — forme lacunaire de corrSum (étape 1 angle ⊶ 1 ChatGPT 5.5)

ChatGPT 5.5 a marqué LE PLUS FORT (⊶) l'angle "prime primitif témoin" :
transformer R71 (p ∣ D_s ⟹ p ∣ corrSum) en IMPOSSIBILITÉ via la structure
**lacunaire** de corrSum.

R83 NEW livre l'**identité lacunaire explicite** :
  corrSum n k = Σ_{i=0}^{k-1} 3^(k-1-i) · 2^(aSumSeq n i)

C'est l'étape 1 (universelle, pas d'hypothèse cycle). Étapes 2-3 viendront
en R84-R85+ pour formaliser le geste "cette somme lacunaire ≠ 0 mod p
primitif" qui contredit R71.
-/

/-- **R83 NEW — corrSum forme lacunaire explicite** (universel, pas d'hypothèse cycle).

  corrSum n k = Σ_{i=0}^{k-1} 3^(k-1-i) · 2^(aSumSeq n i)

C'est la forme **lacunaire** : produit de puissances de 3 (décroissant) et de 2
(croissant via aSumSeq).

**Preuve** par induction sur k, utilise corrSum_succ (recurrence corrSum n (K+1)
= 3 · corrSum n K + 2^(aSumSeq n K)) et Finset.sum_range_succ.

**Étape 1 angle ⊶ 1 ChatGPT 5.5**. -/
theorem cycle_corrSum_eq_lacunary_sum (n k : ℕ) :
    corrSum n k = ∑ i ∈ Finset.range k, 3^(k-1-i) * 2^(aSumSeq n i) := by
  induction k with
  | zero => simp [corrSum]
  | succ k ih =>
    rw [corrSum_succ, Finset.sum_range_succ]
    -- Goal: 3 * corrSum n k + 2^(aSumSeq n k) = (∑ i ∈ range k, 3^(k+1-1-i) * 2^(aSumSeq n i)) + 3^(k+1-1-k) * 2^(aSumSeq n k)
    rw [show (k + 1 - 1 - k : ℕ) = 0 from by omega, pow_zero, one_mul]
    rw [ih, Finset.mul_sum]
    -- Goal: ∑ i ∈ range k, 3 * (3^(k-1-i) * 2^(aSumSeq n i)) + 2^(aSumSeq n k)
    --     = ∑ i ∈ range k, 3^(k+1-1-i) * 2^(aSumSeq n i) + 2^(aSumSeq n k)
    congr 1
    apply Finset.sum_congr rfl
    intro i hi
    rw [Finset.mem_range] at hi
    -- Goal: 3 * (3^(k-1-i) * 2^(aSumSeq n i)) = 3^(k+1-1-i) * 2^(aSumSeq n i)
    have h_pow : 3 * (3 : ℕ)^(k - 1 - i) = 3^(k + 1 - 1 - i) := by
      rw [show (k + 1 - 1 - i : ℕ) = (k - 1 - i) + 1 from by omega]
      rw [pow_succ]; ring
    calc 3 * (3 ^ (k - 1 - i) * 2 ^ aSumSeq n i)
        = (3 * 3 ^ (k - 1 - i)) * 2 ^ aSumSeq n i := by ring
      _ = 3 ^ (k + 1 - 1 - i) * 2 ^ aSumSeq n i := by rw [h_pow]

/-! ## Section 13: R84 NEW — corrSum forme lacunaire dans ZMod p (building block)

Cast de R83 NEW vers `ZMod p`. Brique pour formaliser ultérieurement
"corrSum ≠ 0 mod p primitif" (étape 2 angle ⊶ 1 ChatGPT 5.5).
-/

/-- **R84 NEW — corrSum forme lacunaire dans ZMod p**.

  (corrSum n k : ZMod p) = ∑_{i=0}^{k-1} (3 : ZMod p)^(k-1-i) · (2 : ZMod p)^(aSumSeq n i)

Universel (pas d'hypothèse cycle ni primalité). Cast de R83 vers ZMod.

**Building block** pour étape 2 angle ⊶ 1 : prouver que pour p primitif
(ordre suffisant), cette somme lacunaire ne peut pas être nulle dans ZMod p
sauf cas dégénérés (parityVector périodique). -/
theorem cycle_corrSum_mod_p_lacunary (n k p : ℕ) :
    (corrSum n k : ZMod p) =
    ∑ i ∈ Finset.range k, (3 : ZMod p)^(k-1-i) * (2 : ZMod p)^(aSumSeq n i) := by
  rw [cycle_corrSum_eq_lacunary_sum]
  push_cast
  rfl

/-! ## Section 14: R85 NEW — identités division explicites depuis R72

R72 (`n * D_s = corrSum`) implique deux identités de division entières
(quand n > 0 et D_s > 0, garantis pour cycles non-triviaux) :

  corrSum / n = D_s
  corrSum / D_s = n

Ces identités exposent la structure quotient explicite, utile downstream.
-/

/-- **R85.1 NEW — corrSum / n = D_s** (identité division ℕ).

Pour cycle non-trivial, `corrSum n k / n = 2^(aSumSeq n k) - 3^k = D_s`.

**Preuve** (~3 lignes) : R72 + Nat.mul_div_cancel_left (puisque n ≥ 3 > 0). -/
theorem cycle_corrSum_div_n_eq_D_s
    (n k : ℕ) (hcyc : IsOddCycle n k) :
    corrSum n k / n = (2 : ℕ) ^ (aSumSeq n k) - 3 ^ k := by
  rw [← cycle_n_mul_D_s_eq_corrSum n k hcyc]
  have h_n_pos : n > 0 := by
    have h_n_ge : n ≥ 3 := cycle_n_ge_three n k hcyc
    omega
  exact Nat.mul_div_cancel_left _ h_n_pos

/-- **R85.2 NEW — corrSum / D_s = n** (identité division ℕ symétrique).

Pour cycle non-trivial, `corrSum n k / (2^S - 3^k) = n`.

**Preuve** (~5 lignes) : R72 + commutativité + Nat.mul_div_cancel_left. -/
theorem cycle_corrSum_div_D_s_eq_n
    (n k : ℕ) (hcyc : IsOddCycle n k) :
    corrSum n k / ((2 : ℕ) ^ (aSumSeq n k) - 3 ^ k) = n := by
  rw [← cycle_n_mul_D_s_eq_corrSum n k hcyc]
  have h_D_s_pos : (2 : ℕ) ^ (aSumSeq n k) - 3 ^ k > 0 := by
    have h_pow_gt : (2 : ℕ) ^ (aSumSeq n k) > 3 ^ k :=
      cycle_pow2_gt_pow3_universal n k hcyc
    omega
  -- Goal: n * D_s / D_s = n
  exact Nat.mul_div_cancel _ h_D_s_pos

/-! ## Section 15: R86 NEW — Steiner mod p reformulation explicite

R72 (`n * D_s = corrSum`) projetée modulo p donne plusieurs reformulations
utiles pour combiner avec arbre 13 (transport mod p).
-/

/-- **R86 NEW — Steiner factorisée mod p**.

Pour tout cycle non-trivial et tout p ∈ ℕ :
  `(n : ZMod p) * ((2 : ZMod p)^S - (3 : ZMod p)^k) = (corrSum n k : ZMod p)`

C'est R72 cast directement à ZMod p, en utilisant `(2 : ZMod p)^S - (3 : ZMod p)^k`
(différence ZMod) plutôt que `((2 : ℕ)^S - 3^k : ℕ : ZMod p)` (Nat-sub puis cast).

**Utilité** : forme native ZMod, permet d'utiliser `ring` et `field_simp` sans
gérer la Nat-subtraction. -/
theorem cycle_steiner_factored_mod_p (n k p : ℕ) (hcyc : IsOddCycle n k) :
    (n : ZMod p) * ((2 : ZMod p) ^ (aSumSeq n k) - (3 : ZMod p) ^ k) =
    (corrSum n k : ZMod p) := by
  have h_nat : n * ((2 : ℕ) ^ (aSumSeq n k) - 3 ^ k) = corrSum n k :=
    cycle_n_mul_D_s_eq_corrSum n k hcyc
  -- Cast to ZMod p
  have h_cast : ((n * ((2 : ℕ) ^ (aSumSeq n k) - 3 ^ k) : ℕ) : ZMod p) =
                ((corrSum n k : ℕ) : ZMod p) :=
    congrArg (Nat.cast : ℕ → ZMod p) h_nat
  -- Use Nat.cast_sub since 2^S ≥ 3^k for cycles
  have h_pow_gt : (2 : ℕ) ^ (aSumSeq n k) > 3 ^ k :=
    cycle_pow2_gt_pow3_universal n k hcyc
  have h_le : 3 ^ k ≤ 2 ^ (aSumSeq n k) := le_of_lt h_pow_gt
  -- LHS cast
  push_cast [Nat.cast_sub h_le] at h_cast
  exact h_cast

/-! ## Section 16: R87 NEW — Dichotomie p ∣ corrSum vs n forcé mod p

Théorème de synthèse unifiant R67 NEW (cycle_n_forced_mod_p) et R71 NEW
(cycle_p_dvd_D_s_implies_p_dvd_corrSum).

Pour tout p premier ≥ 5, **soit p divise corrSum, soit n est forcé mod p**.
Pas de tertium quid : la dichotomie est exhaustive.
-/

/-- **R87 NEW — Dichotomie modulaire pour cycles**.

Pour tout cycle non-trivial et tout premier `p ≥ 5`, exactement deux cas :

- **Cas 1 (résonant)** : `p ∣ corrSum n k` (et donc aussi `p ∣ D_s` par R71-réciproque
  via R72)
- **Cas 2 (non-résonant)** : `n` est **forcé** modulo p à la valeur
  `corrSum * D_s⁻¹` (R67)

**Conséquence** : pour tout cycle et tout p ≥ 5, on a une **contrainte
modulaire** explicite (de l'un des deux types).

**Utilité downstream** : pour étape 2 angle ⊶ 1, on cherche un p tel que
le Cas 1 (`p ∣ corrSum`) soit **impossible** sous certaines hypothèses
(ordre multiplicatif), forçant ainsi le Cas 2 + contradiction structurelle.

**Preuve** (~10 lignes) : case analysis sur `p ∣ D_s`. -/
theorem cycle_dichotomy_p_dvd_or_n_forced
    (n k p : ℕ) (hp : p.Prime) (hp_ge : p ≥ 5) (hcyc : IsOddCycle n k) :
    p ∣ corrSum n k ∨
    (n : ZMod p) = (corrSum n k : ZMod p) *
      (((2 : ℕ) ^ (aSumSeq n k) - 3 ^ k : ℕ) : ZMod p)⁻¹ := by
  by_cases h_p_dvd : p ∣ ((2 : ℕ) ^ (aSumSeq n k) - 3 ^ k)
  · -- Cas 1 : p ∣ D_s ⟹ p ∣ corrSum (R71)
    left
    exact cycle_p_dvd_D_s_implies_p_dvd_corrSum n k p hcyc h_p_dvd
  · -- Cas 2 : p ∤ D_s ⟹ n forcé mod p (R67)
    right
    exact cycle_n_forced_mod_p n k p hp hp_ge hcyc h_p_dvd

/-! ## Section 17: R88 NEW — Périodisation corrSum mod p (étape 2 angle ⊶ 1, tractable)

Stratégie ⊶ A ChatGPT 5.5 (mailbox 1320) : pour rendre étape 2 tractable Lean,
réduire les exposants modulo `orderOf(2 : ZMod p)`. Mathlib `pow_mod_orderOf`.

Cela transforme corrSum mod p en somme finie de classes d'exposants — **certificat
fini par prime p**.
-/

/-- **R88 NEW — Périodisation corrSum mod p par orderOf(2)**.

  (corrSum n k : ZMod p) = ∑ i ∈ range k, (3 : ZMod p)^(k-1-i) * (2 : ZMod p)^(aSumSeq n i % orderOf(2 : ZMod p))

Universel. Cast de R84 NEW (forme lacunaire ZMod p) avec réduction des exposants
modulo `orderOf(2 : ZMod p)` via Mathlib `pow_mod_orderOf`.

**Conséquence stratégique** : pour p prime fixe, corrSum mod p ne dépend que des
**classes d'exposants modulo orderOf(2 : ZMod p)** (groupe fini).

Étape 2 angle ⊶ 1 : pour p tel que orderOf(2) est petit (ex: ord_7(2) = 3),
on peut **énumérer** les classes d'exposants et vérifier corrSum ≠ 0 par
`native_decide`. -/
theorem cycle_corrSum_mod_p_periodic_exponents (n k p : ℕ) :
    (corrSum n k : ZMod p) =
    ∑ i ∈ Finset.range k,
      (3 : ZMod p)^(k-1-i) * (2 : ZMod p)^((aSumSeq n i) % orderOf (2 : ZMod p)) := by
  rw [cycle_corrSum_mod_p_lacunary]
  apply Finset.sum_congr rfl
  intro i _
  congr 1
  exact (pow_mod_orderOf _ _).symm

/-! ## Section 18: R89 NEW — double périodisation corrSum mod p (orderOf 2 ET 3)

R88 NEW livre la périodisation par orderOf(2 : ZMod p). R89 NEW ajoute
la périodisation par orderOf(3 : ZMod p) sur l'autre exposant.

Le résultat : corrSum mod p est entièrement déterminé par les classes
d'exposants `(k-1-i) mod orderOf(3 : ZMod p)` et `aSumSeq n i mod orderOf(2 : ZMod p)`.

C'est la **forme pleinement classifiée** pour certificats finis (étape 2
angle ⊶ 1 ChatGPT 5.5).
-/

/-- **R89 NEW — Double périodisation corrSum mod p**.

  (corrSum n k : ZMod p) = ∑ i ∈ range k,
    (3 : ZMod p)^((k-1-i) % orderOf(3 : ZMod p)) *
    (2 : ZMod p)^((aSumSeq n i) % orderOf(2 : ZMod p))

Universel. Utilise R88 NEW + Mathlib `pow_mod_orderOf` pour le second exposant.

**Utilité** : pour p prime fixe, corrSum mod p ne dépend que de :
- (k-1-i) mod orderOf(3 : ZMod p) — cycle 3-adique
- aSumSeq n i mod orderOf(2 : ZMod p) — cycle 2-adique

Donc le nombre de classes pour corrSum mod p est borné par
`(orderOf(3) * orderOf(2))^k` au pire — c'est un univers fini où
`native_decide` peut chercher contradictions.

Pour p = 5 : ord(2)=4, ord(3)=4 ⟹ classes en 4^(2k) = 16^k. Pour k ≤ 5, 10^6.
Pour p = 7 : ord(2)=3, ord(3)=6 ⟹ classes en 18^k. Pour k ≤ 4, 105K.

Pour ces tailles, `native_decide` est encore tractable (k petit). -/
theorem cycle_corrSum_mod_p_double_periodic (n k p : ℕ) :
    (corrSum n k : ZMod p) =
    ∑ i ∈ Finset.range k,
      (3 : ZMod p)^((k-1-i) % orderOf (3 : ZMod p)) *
      (2 : ZMod p)^((aSumSeq n i) % orderOf (2 : ZMod p)) := by
  rw [cycle_corrSum_mod_p_periodic_exponents]
  apply Finset.sum_congr rfl
  intro i _
  congr 1
  exact (pow_mod_orderOf _ _).symm

/-! ## Section 19: R90 NEW — pont contradiction explicite (R71 + R89)

**Objectif** : combiner R71 NEW (p ∣ D_s ⟹ p ∣ corrSum) avec R89 NEW
(double périodisation corrSum mod p) pour obtenir le **lien explicite** :

  Pour cycle non-trivial, p prime ≥ 5 avec `p ∣ D_s`,
  la somme lacunaire (en classes mod orderOf) **DOIT être 0** mod p.

C'est la base de l'attaque angle ⊶ 1 : si on trouve un (n, k, p) où la somme
lacunaire ne **peut pas** être 0 mod p (par certificat fini native_decide),
alors p ∤ D_s, ce qui force `n` modulo p (via R67), donnant contraintes
combinables avec d'autres premiers.
-/

/-- **R90 NEW — pont contradiction explicite**.

Pour tout cycle non-trivial et tout `p` premier ≥ 5 divisant `D_s`, la somme
lacunaire pleinement classifiée (R89 NEW) est **0 dans ZMod p** :

  ∑_{i=0}^{k-1} (3 : ZMod p)^((k-1-i) % ord(3)) · (2 : ZMod p)^(s_i % ord(2)) = 0

**Stratégie attaque angle ⊶ 1** : pour démontrer l'inexistence d'un cycle
particulier, il suffit de trouver `p` premier divisant `D_s` tel que cette
somme lacunaire est ≠ 0 dans ZMod p (via certificat fini).

R90 fournit le pont : la **direction `p ∣ D_s ⟹ somme = 0`** est universelle.
La **contraposée** (`somme ≠ 0 ⟹ p ∤ D_s`) sera utilisée pour les certificats. -/
theorem cycle_p_dvd_D_s_implies_lacunary_zero
    (n k p : ℕ) (hcyc : IsOddCycle n k)
    (h_p_dvd : p ∣ ((2 : ℕ) ^ (aSumSeq n k) - 3 ^ k)) :
    (∑ i ∈ Finset.range k,
      (3 : ZMod p)^((k-1-i) % orderOf (3 : ZMod p)) *
      (2 : ZMod p)^((aSumSeq n i) % orderOf (2 : ZMod p))) = 0 := by
  -- Étape 1 : R71 ⟹ p ∣ corrSum
  have h_p_dvd_corr : p ∣ corrSum n k :=
    cycle_p_dvd_D_s_implies_p_dvd_corrSum n k p hcyc h_p_dvd
  -- Étape 2 : (corrSum n k : ZMod p) = 0
  have h_corr_zero : (corrSum n k : ZMod p) = 0 := by
    rw [ZMod.natCast_eq_zero_iff]
    exact h_p_dvd_corr
  -- Étape 3 : R89 ⟹ somme lacunaire = (corrSum : ZMod p) = 0
  rw [← cycle_corrSum_mod_p_double_periodic]
  exact h_corr_zero

/-- **R90.2 NEW — Contraposée explicite**.

Si la somme lacunaire est ≠ 0 dans ZMod p pour un cycle, alors `p ∤ D_s`.

C'est la **forme actionable** : pour tester si `p | D_s` est possible pour
un cycle donné, on calcule la somme lacunaire et on compare à 0.

**Conséquence stratégique** : pour cycle non-trivial avec parityVector connu,
on peut vérifier par calcul fini (native_decide) si tel ou tel petit premier
divise `D_s`. -/
theorem cycle_lacunary_nonzero_implies_p_nmid_D_s
    (n k p : ℕ) (hcyc : IsOddCycle n k)
    (h_lacunary_nonzero : (∑ i ∈ Finset.range k,
      (3 : ZMod p)^((k-1-i) % orderOf (3 : ZMod p)) *
      (2 : ZMod p)^((aSumSeq n i) % orderOf (2 : ZMod p))) ≠ 0) :
    ¬ p ∣ ((2 : ℕ) ^ (aSumSeq n k) - 3 ^ k) := by
  intro h_p_dvd
  exact h_lacunary_nonzero (cycle_p_dvd_D_s_implies_lacunary_zero n k p hcyc h_p_dvd)

/-! ## Section 20: R91 NEW — valeurs explicites orderOf pour petits p

Building blocks pour étape 2 angle ⊶ 1 : `decide` permet de calculer
orderOf(2 : ZMod p) et orderOf(3 : ZMod p) pour petits p ≥ 5.

Ces valeurs sont nécessaires pour les certificats finis native_decide
qui vérifient corrSum ≠ 0 mod p sur des classes d'exposants spécifiques.
-/

/-- **R91.1 NEW — orderOf(2 : ZMod 5) = 4** (preuve via orderOf_eq_iff + decide).

Mathlib `orderOf` est `noncomputable`. Pour obtenir des valeurs explicites,
on utilise `orderOf_eq_iff` qui réduit à des conditions décidables :
- `x^n = 1` (calculable par decide en ZMod fini)
- `∀ m < n, 0 < m → x^m ≠ 1` (énumérable en ZMod fini). -/
theorem orderOf_2_ZMod_5 : orderOf (2 : ZMod 5) = 4 := by
  rw [orderOf_eq_iff (by norm_num : 0 < 4)]
  refine ⟨by decide, ?_⟩
  intro m hm hm_pos
  interval_cases m <;> decide

/-- **R91.2 NEW — orderOf(3 : ZMod 5) = 4**. -/
theorem orderOf_3_ZMod_5 : orderOf (3 : ZMod 5) = 4 := by
  rw [orderOf_eq_iff (by norm_num : 0 < 4)]
  refine ⟨by decide, ?_⟩
  intro m hm hm_pos
  interval_cases m <;> decide

/-- **R91.3 NEW — orderOf(2 : ZMod 7) = 3**. -/
theorem orderOf_2_ZMod_7 : orderOf (2 : ZMod 7) = 3 := by
  rw [orderOf_eq_iff (by norm_num : 0 < 3)]
  refine ⟨by decide, ?_⟩
  intro m hm hm_pos
  interval_cases m <;> decide

/-- **R91.4 NEW — orderOf(3 : ZMod 7) = 6**. -/
theorem orderOf_3_ZMod_7 : orderOf (3 : ZMod 7) = 6 := by
  rw [orderOf_eq_iff (by norm_num : 0 < 6)]
  refine ⟨by decide, ?_⟩
  intro m hm hm_pos
  interval_cases m <;> decide

/-- **R91.5 NEW — orderOf(2 : ZMod 11) = 10**. -/
theorem orderOf_2_ZMod_11 : orderOf (2 : ZMod 11) = 10 := by
  rw [orderOf_eq_iff (by norm_num : 0 < 10)]
  refine ⟨by decide, ?_⟩
  intro m hm hm_pos
  interval_cases m <;> decide

/-- **R91.6 NEW — orderOf(3 : ZMod 11) = 5**. -/
theorem orderOf_3_ZMod_11 : orderOf (3 : ZMod 11) = 5 := by
  rw [orderOf_eq_iff (by norm_num : 0 < 5)]
  refine ⟨by decide, ?_⟩
  intro m hm hm_pos
  interval_cases m <;> decide

/-- **R91.7 NEW — orderOf(2 : ZMod 13) = 12**. -/
theorem orderOf_2_ZMod_13 : orderOf (2 : ZMod 13) = 12 := by
  rw [orderOf_eq_iff (by norm_num : 0 < 12)]
  refine ⟨by decide, ?_⟩
  intro m hm hm_pos
  interval_cases m <;> decide

/-- **R91.8 NEW — orderOf(3 : ZMod 13) = 3**. -/
theorem orderOf_3_ZMod_13 : orderOf (3 : ZMod 13) = 3 := by
  rw [orderOf_eq_iff (by norm_num : 0 < 3)]
  refine ⟨by decide, ?_⟩
  intro m hm hm_pos
  interval_cases m <;> decide

/-! ## Section 21: R92 NEW — Showcase concret native_decide (cycle k=2, p=7)

Démonstration **concrète** de l'angle ⊶ 1 ChatGPT 5.5 : pour un cycle de
longueur k=2 avec parityVector spécifique, on prouve que p=7 ne divise pas
D_s via certificat fini.

C'est le **proof of concept** pour étape 2 : la stratégie ⊶ A (périodisation
+ decide) fonctionne vraiment.
-/

/-- **R92 NEW — Showcase : pour cycle k=2 avec aSeq[0] ≡ 1 mod 3 ∧ aSeq[1] ≡ 1 mod 3, p=7 ∤ D_s**.

C'est le **premier certificat fini** dérivé de l'arsenal R83-R91. Pour cycle
de longueur 2 avec parityVector satisfaisant `(aSeq n 0 % 3, aSeq n 1 % 3) = (1, 1)` :

  Somme lacunaire mod 7 = 3^1 * 2^1 + 3^0 * 2^1 = 6 + 2 = 8 ≡ 1 ≠ 0 (mod 7)

Donc par R90.2 (contraposée), `7 ∤ D_s = 2^(aSumSeq n 2) - 9`.

**Conséquence Diophantienne** : un tel cycle (s'il existe) ne peut pas avoir
`D_s = 2^S - 9 ≡ 0 (mod 7)`. C'est une contrainte concrète sur n, S.

**Stratégie de preuve** : R90.2 + valeurs orderOf R91 + decide sur la somme finie. -/
theorem cycle_k_2_parity_1_1_p_7_no_dvd_D_s
    (n : ℕ) (hcyc : IsOddCycle n 2)
    (h_s_0 : aSeq n 0 % 3 = 1)
    (h_s_1 : aSeq n 1 % 3 = 1) :
    ¬ (7 : ℕ) ∣ ((2 : ℕ) ^ (aSumSeq n 2) - 3 ^ 2) := by
  apply cycle_lacunary_nonzero_implies_p_nmid_D_s n 2 7 hcyc
  -- Goal: somme lacunaire ≠ 0 dans ZMod 7
  rw [orderOf_2_ZMod_7, orderOf_3_ZMod_7]
  -- Réécrire les aSumSeq
  have h_aS_0 : aSumSeq n 0 = 0 := by unfold aSumSeq aSum; simp
  have h_aS_1 : aSumSeq n 1 = aSeq n 0 := aSumSeq_one_eq n
  -- Expand le Finset.sum
  rw [Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_zero]
  simp only [zero_add]
  -- Substitue les aSumSeq
  rw [h_aS_0, h_aS_1]
  -- Goal: (3 : ZMod 7)^((2-1-0) % 6) * (2 : ZMod 7)^(0 % 3) +
  --       (3 : ZMod 7)^((2-1-1) % 6) * (2 : ZMod 7)^((aSeq n 0) % 3) ≠ 0
  simp only [show (2 - 1 - 0 : ℕ) = 1 from rfl, show (2 - 1 - 1 : ℕ) = 0 from rfl,
             show (1 % 6 : ℕ) = 1 from rfl, show (0 % 6 : ℕ) = 0 from rfl,
             show (0 % 3 : ℕ) = 0 from rfl, h_s_0]
  -- Goal: (3 : ZMod 7)^1 * (2 : ZMod 7)^0 + (3 : ZMod 7)^0 * (2 : ZMod 7)^1 ≠ 0
  decide

/-! ## Section 22: R93 NEW — Découverte structurelle (cycle k=2, lacunary form)

**Insight clé** : pour cycle de longueur k=2, la somme lacunaire mod p ne dépend
QUE de `aSeq n 0 mod ord_p(2)`, **PAS de aSeq n 1**.

Raison : aSumSeq n 0 = 0 et aSumSeq n 1 = aSeq n 0. Le terme i=2 n'apparaît
PAS dans la somme `∑ i ∈ range 2`. Donc aSeq n 1 (qui apparaît seulement dans
aSumSeq n 2 via l'addition) est **invisible** dans la lacunary form.

Pour p=7 et k=2 : Lacunary = 3 + 2^(aSeq n 0 % 3) mod 7.

Table (aSeq n 0 % 3) :
| aSeq n 0 mod 3 | Lacunary mod 7 | Conclusion |
|----------------|----------------|------------|
| 0              | 3 + 1 = 4      | ≠ 0 ⟹ 7 ∤ D_s |
| 1              | 3 + 2 = 5      | ≠ 0 ⟹ 7 ∤ D_s (R92) |
| 2              | 3 + 4 = 7 ≡ 0  | = 0 ⟹ 7 ∣ corrSum possible |

→ **Constat R93** : pour cycle k=2 avec aSeq n 0 mod 3 ∈ {0, 1}, 7 ∤ D_s.
Pour aSeq n 0 mod 3 = 2, p=7 ne suffit pas — nécessite autre prime.

**Note historique** : ma première R93.2 (parity (2,2)) était FAUSSE. decide
détecté que lacunary = 0 mod 7. Discipline NASA Power-of-Ten "vérifier avant
poster" — mea culpa.
-/

/-- **R93 NEW — Cycle k=2 avec aSeq[0] ≡ 0 mod 3 : 7 ∤ D_s**.

Variante de R92 (aSeq[0] ≡ 1) avec aSeq[0] ≡ 0 mod 3 à la place. **Note** :
aSeq n 1 n'intervient PAS dans la conclusion (insight R93).

Lacunary sum mod 7 = 3 * 2^0 + 2^0 = 4 ≠ 0. -/
theorem cycle_k_2_s0_mod_3_eq_0_p_7_no_dvd_D_s
    (n : ℕ) (hcyc : IsOddCycle n 2)
    (h_s_0 : aSeq n 0 % 3 = 0) :
    ¬ (7 : ℕ) ∣ ((2 : ℕ) ^ (aSumSeq n 2) - 3 ^ 2) := by
  apply cycle_lacunary_nonzero_implies_p_nmid_D_s n 2 7 hcyc
  rw [orderOf_2_ZMod_7, orderOf_3_ZMod_7]
  have h_aS_0 : aSumSeq n 0 = 0 := by unfold aSumSeq aSum; simp
  have h_aS_1 : aSumSeq n 1 = aSeq n 0 := aSumSeq_one_eq n
  rw [Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_zero]
  simp only [zero_add, h_aS_0, h_aS_1,
             show (2 - 1 - 0 : ℕ) = 1 from rfl, show (2 - 1 - 1 : ℕ) = 0 from rfl,
             show (1 % 6 : ℕ) = 1 from rfl, show (0 % 6 : ℕ) = 0 from rfl,
             h_s_0]
  decide

/-! ## Section 23: R94 NEW — Extension cross-prime cycle k=2 (p=5)

Pour cycles k=2 où p=7 ne suffit pas (aSeq[0] mod 3 = 2), on utilise p=5.

Lacunary mod 5 = 3 + 2^(aSeq[0] % 4) mod 5
Table :
| aSeq[0] mod 4 | Lac mod 5 | Conclusion |
| 0             | 3 + 1 = 4 | ≠ 0 ⟹ 5 ∤ D_s |
| 1             | 3 + 2 = 0 | resonant |
| 2             | 3 + 4 = 2 | ≠ 0 ⟹ 5 ∤ D_s |
| 3             | 3 + 8 ≡ 1 | ≠ 0 ⟹ 5 ∤ D_s |

3 classes sur 4 donnent 5 ∤ D_s. Combiné avec p=7 (2 classes sur 3),
couverture multi-prime bonne pour cycles k=2.
-/

/-- **R94 NEW — Cycle k=2 avec aSeq[0] ≡ 0 mod 4 : 5 ∤ D_s** (cross-prime via p=5).

Lacunary mod 5 = 3 + 2^0 = 4 ≠ 0.

C'est la **première extension cross-prime** : pour cas où p=7 ne donnait pas
contradiction (par exemple aSeq[0] ≡ 2 mod 3), p=5 peut donner contradiction
si aSeq[0] mod 4 ≠ 1. -/
theorem cycle_k_2_s0_mod_4_eq_0_p_5_no_dvd_D_s
    (n : ℕ) (hcyc : IsOddCycle n 2)
    (h_s_0 : aSeq n 0 % 4 = 0) :
    ¬ (5 : ℕ) ∣ ((2 : ℕ) ^ (aSumSeq n 2) - 3 ^ 2) := by
  apply cycle_lacunary_nonzero_implies_p_nmid_D_s n 2 5 hcyc
  rw [orderOf_2_ZMod_5, orderOf_3_ZMod_5]
  have h_aS_0 : aSumSeq n 0 = 0 := by unfold aSumSeq aSum; simp
  have h_aS_1 : aSumSeq n 1 = aSeq n 0 := aSumSeq_one_eq n
  rw [Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_zero]
  simp only [zero_add, h_aS_0, h_aS_1,
             show (2 - 1 - 0 : ℕ) = 1 from rfl, show (2 - 1 - 1 : ℕ) = 0 from rfl,
             show (1 % 4 : ℕ) = 1 from rfl, show (0 % 4 : ℕ) = 0 from rfl,
             h_s_0]
  decide

/-! ## Section 24: R95 NEW — NON-EXISTENCE DE CYCLE DE LONGUEUR 2 (résultat universel !)

Premier résultat de **non-existence universelle** : aucun cycle de Collatz n'a
longueur exactement 2.

C'est le **proof of concept** que l'arsenal R34-R94 peut effectivement éliminer
des cycles spécifiques. Pour k=2, on dérive directement contradiction sans
besoin du Red Team certificate (l'arsenal Diophantien suffit).

**Argument analytique** :
- corrSum n 2 = 3 + 2^(aSeq[0])  (corrSum_two_eq)
- D_s = 2^S - 9 où S = aSeq[0] + aSeq[1]  (cycle Steiner)
- D_s ≤ corrSum ⟹ 2^S ≤ 12 + 2^(aSeq[0])
- aSeq[1] ≥ 1 ⟹ 2^S ≥ 2 * 2^(aSeq[0]) ⟹ 2^(aSeq[0]) ≤ 12 ⟹ aSeq[0] ≤ 3
- aSeq[0] ≤ 3 ⟹ corrSum ≤ 11
- 2^S > 9 ⟹ S ≥ 4 ⟹ D_s ≥ 7
- R77.2 : corrSum ≥ 3 * D_s ≥ 21
- Mais corrSum ≤ 11 < 21 — CONTRADICTION
-/

/-- **R95 NEW — NON-EXISTENCE de cycle de longueur 2** (universel, pas de hypothèse).

  ∀ n, ¬ IsOddCycle n 2

**Argument** :
- corrSum n 2 = 3 + 2^(aSeq[0]) ≤ 3 + 2^S (car aSeq[0] ≤ aSumSeq n 2 = S)
- corrSum ≥ 3 * D_s = 3 * (2^S - 9) (R77.2 + h_pow_gt)
- Combinés : 3 + 2^S ≥ 3 * (2^S - 9) ⟹ 2 * 2^S ≤ 30 ⟹ 2^S ≤ 15
- Mais 2^S > 9 ⟹ 2^S ≥ 16 (next power of 2 above 9)
- 15 ≥ 16 — CONTRADICTION -/
theorem no_cycle_of_length_two : ∀ n, ¬ IsOddCycle n 2 := by
  intro n hcyc
  -- 2^S > 9 (Steiner poutre R59)
  have h_pow_gt : (2 : ℕ)^(aSumSeq n 2) > 9 := by
    have := cycle_pow2_gt_pow3_universal n 2 hcyc
    norm_num at this
    exact this
  -- aSeq[0] ≤ aSumSeq n 2 (puisque aSumSeq n 2 = aSeq[0] + aSeq[1])
  have h_a0_le_S : aSeq n 0 ≤ aSumSeq n 2 := by
    rw [aSumSeq_two_eq]; omega
  -- 2^(aSeq[0]) ≤ 2^(aSumSeq n 2) (monotonie)
  have h_pow_a0_le : (2 : ℕ)^(aSeq n 0) ≤ (2 : ℕ)^(aSumSeq n 2) :=
    Nat.pow_le_pow_right (by norm_num) h_a0_le_S
  -- corrSum n 2 = 3 + 2^(aSeq[0]) ≤ 3 + 2^(aSumSeq n 2)
  have h_corr_le : corrSum n 2 ≤ 3 + (2 : ℕ)^(aSumSeq n 2) := by
    rw [corrSum_two_eq]; omega
  -- corrSum ≥ 3 * D_s (R77.2)
  have h_corr_ge_3D : corrSum n 2 ≥ 3 * ((2 : ℕ)^(aSumSeq n 2) - 3^2) :=
    cycle_corrSum_ge_three_times_D_s n 2 hcyc
  -- Renforcer 2^S > 9 ⟹ 2^S ≥ 16 (aSumSeq ≥ 4)
  have h_S_ge_4 : aSumSeq n 2 ≥ 4 := by
    by_contra h_S_lt
    push_neg at h_S_lt
    interval_cases (aSumSeq n 2) <;> simp_all <;> omega
  have h_pow_ge_16 : (2 : ℕ)^(aSumSeq n 2) ≥ 16 := by
    calc (2 : ℕ)^(aSumSeq n 2) ≥ 2^4 :=
          Nat.pow_le_pow_right (by norm_num) h_S_ge_4
      _ = 16 := by norm_num
  -- 3^2 = 9
  have h_3_sq : (3 : ℕ)^2 = 9 := by norm_num
  rw [h_3_sq] at h_corr_ge_3D
  -- Setup pour omega
  set y := (2 : ℕ)^(aSumSeq n 2)
  -- h_corr_le : corrSum n 2 ≤ 3 + y
  -- h_corr_ge_3D : corrSum n 2 ≥ 3 * (y - 9)
  -- h_pow_ge_16 : y ≥ 16
  -- ⟹ 3 + y ≥ 3*(y - 9) = 3y - 27 ⟹ 30 ≥ 2y ⟹ y ≤ 15
  -- Mais y ≥ 16. Contradiction.
  omega

/-! ## Section 25: R96 NEW — Cas spécifiques cycle k=3 (énumération parityVectors)

Stratégie ⊶ A ChatGPT 5.5 (mailbox 1340 follow-up) : énumération certifiée
des parityVectors. Pour k=3, 6 vecteurs avec S=5 + 10 avec S=6 = 16 cas
au total. Chacun se réduit à : `n * D_s = corrSum` n'a pas de solution
n ≥ 3.

R96 commence par cas concret (a,b,c)=(1,1,3) comme proof of concept.
-/

/-- **R96 NEW — Cycle k=3 avec parityVector (1, 1, 3) impossible**.

Si cycle de longueur 3 avait aSeq=(1,1,3), alors :
- corrSum = 9 + 3*2 + 2^2 = 19
- D_s = 2^5 - 27 = 5
- n * 5 = 19 ⟹ n = 19/5 — pas entier

Contradiction directe. ~10 lignes Lean. -/
theorem cycle_k_3_parity_1_1_3_impossible
    (n : ℕ) (hcyc : IsOddCycle n 3)
    (h_a : aSeq n 0 = 1) (h_b : aSeq n 1 = 1) (h_c : aSeq n 2 = 3) :
    False := by
  have h_corr : corrSum n 3 = 19 := by
    rw [corrSum_three_eq, h_a, h_b]; norm_num
  have h_aS : aSumSeq n 3 = 5 := by
    rw [aSumSeq_three_eq, h_a, h_b, h_c]
  have h_n_D : n * ((2 : ℕ)^(aSumSeq n 3) - 3^3) = corrSum n 3 :=
    cycle_n_mul_D_s_eq_corrSum n 3 hcyc
  rw [h_aS, h_corr] at h_n_D
  have h_n_ge_3 : n ≥ 3 := cycle_n_ge_three n 3 hcyc
  -- 2^5 = 32, 3^3 = 27, donc 32 - 27 = 5
  -- n * 5 = 19 ⟹ contradiction (n ≥ 3 ⟹ n*5 ≥ 15, mais on cherche = 19, et n entier)
  omega

end ProjetCollatz.PostJAR
