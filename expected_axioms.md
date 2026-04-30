# expected_axioms.md

**Baseline for `probes/check_central_axioms.lean`** — snapshot of axiom dependencies for all central and auxiliary theorems of `collatz-conditional-cycles`. The exact repository commit captured by this snapshot is recorded in the Zenodo metadata associated with the release; reproduction details are in §8 of the paper and in `reproduce.sh`.

Any commit that alters these expectations MUST update this file AND pass `reproduce.sh` EXIT 0.

---

## Legend

- **(S)** = one of the 3 standard Lean kernel axioms: `propext`, `Classical.choice`, `Quot.sound`
- **(N)** = `native_decide` axioms: `Lean.ofReduceBool`, `Lean.trustCompiler`
- `sorryAx` = Lean's sorry axiom — **FORBIDDEN** in every central or auxiliary theorem listed here

---

## Section 1 — Central theorem chain

All 7 theorems depend on exactly the 3 fundamental Mathlib axioms :

| Theorem | Expected axioms | Classification |
|---------|-----------------|----------------|
| `ProjetCollatz.no_nontrivial_cycle_phase59` | `[propext, Classical.choice, Quot.sound]` | Central (principal) |
| `ProjetCollatz.no_nontrivial_cycle_final` | `[propext, Classical.choice, Quot.sound]` | Central (variant/alias) |
| `ProjetCollatz.no_nontrivial_cycle_derived` | `[propext, Classical.choice, Quot.sound]` | Central (variant/alias) |
| `ProjetCollatz.no_nontrivial_cycle_full` | `[propext, Classical.choice, Quot.sound]` | Central (variant/alias) |
| `ProjetCollatz.no_cycle_k_le_1322` | `[propext, Classical.choice, Quot.sound]` | Central (sub-branch k ≤ 1322, Barina) |
| `ProjetCollatz.no_cycle_k_gt_1322` | `[propext, Classical.choice, Quot.sound]` | Central (sub-branch k > 1322, CF) |
| `ProjetCollatz.sdw_from_cf` | `[propext, Classical.choice, Quot.sound]` | Central (key conditional lemma) |

**All 3 axioms are standard Mathlib kernel axioms**, required by any non-constructive theorem using classical reasoning and quotient types. No user-declared `axiom` is ever introduced in `ProjetCollatz/`.

---

## Section 2 — Auxiliary native_decide lemmas

These 3 sampled lemmas (out of a broader family) use `native_decide` to verify arithmetic gap constants from continued-fractions theory :

| Theorem | Expected axioms | Role |
|---------|-----------------|------|
| `ProjetCollatz.cf_gap_8` | `[propext, Lean.ofReduceBool, Lean.trustCompiler]` | CF Window 8 arithmetic gap |
| `ProjetCollatz.cf_gap_13` | `[propext, Lean.ofReduceBool, Lean.trustCompiler]` | CF Window 13 arithmetic gap |
| `ProjetCollatz.cf_nbound_8` | `[propext, Lean.ofReduceBool, Lean.trustCompiler]` | CF Window 8 `n` bound |

**Important isolation property**: these lemmas are **not** in the transitive axiom chain of `no_nontrivial_cycle_phase59`, because `DerivedLargeKBound` is a `structure` taken as a **parameter** by the central theorem. The `cf_gap_*` and `cf_nbound_*` lemmas are the mathematical justification of the structure's content (detailed in the paper) but are not composed into its proof in Lean.

---

## Section 3bis — Out-of-scope at the current reproducibility baseline

The following theorems and structures exist in `ProjetCollatz/` but are **not** in the authoritative probe at the current baseline. They are either (a) definitions or structures, not theorems with proofs, or (b) lower-level lemmas not considered public API, or (c) deemed out-of-scope for the current reproducibility pass.

- `ProjetCollatz.BakerSeparation` — external hypothesis structure (definition, not a theorem)
- `ProjetCollatz.BarinaVerification` — external hypothesis structure
- `ProjetCollatz.ProductBoundThreshold` — external hypothesis structure
- `ProjetCollatz.IsOddCycle` — definition, not a theorem
- `ProjetCollatz.steiner_equation` — internal lemma, not public API
- Other `cf_gap_*` / `cf_nbound_*` variants beyond the 3 sampled — content-similar, axiom pattern expected identical

Reason for exclusion: the current baseline establishes the core axiom profile for the **publicly claimed result** (`no_nontrivial_cycle_*` + its immediate dependencies).

---

## Section 3ter — δ10 Cartographic Audit (Phase64, 2026-04-30)

The δ10 lemma is a **finite cartographic impossibility** documenting that no published Diophantine bound from the audited catalogue `{Salikhov2007, Wu2003, Rhin1987, SimonsDeWeger2005}` can replace `BarinaVerification` in the proof of Collatz cycle non-existence. It is parallel to δ8/δ8' (Phase58) but addresses the second hypothesis (Barina) rather than the third (Product-Bound).

| Theorem | Expected axioms | Role |
|---------|-----------------|------|
| `ProjetCollatz.delta10_barina_replacement_impossibility` | `[propext]` | δ10 cartographic impossibility (kernel-1 only) |
| `ProjetCollatz.delta10_no_audited_profile_can_replace` | `[propext]` | corollary on 4 concrete profiles |
| `ProjetCollatz.Delta10Catalog_finite_cases` | `[]` (no axioms) | finite catalogue enumeration |

**Notable**: δ10 uses **only `[propext]`**, not the full `[propext, Classical.choice, Quot.sound]` triplet. The proof is constructive (no classical choice needed), since the catalogue is finite and the case analysis is by `rcases` + `simp` on concrete boolean profiles.

**Three-Key validation**: this lemma was scoped collaboratively by OLD3 + NEW4 + ChatGPT 5.5 thinking extended. ChatGPT's Q0 RED TEAM "FEU ORANGE SÉRIEUX" (Q13, 2026-04-30) prevented over-reach: a universal claim ("no method ever can replace Barina") would be infeasible. The cartographic claim is faisable, kernel-checkable, and defendable.

**Dated catalogue**: `Delta10AuditDate := "2026-04-30"`. Sources published AFTER this date are not audited by this lemma; future work may extend the catalogue.

**Numerical justification (REQ-MATH-012)**: for `K_max = 1322`:
- Salikhov 2007 (μ-1 ≈ 4.125): `1322^4.125 ≈ 2^42.77 < 2^71` ✓ numerically, but bridge theorem μ(log 3) → μ(log_2 3) missing.
- Wu 2003 (~7.6155): `1322^7.6155 ≈ 2^78.96 > 2^71` ✗ insufficient.
- Simons-de Weger 2005 (~13.3): `1322^13.3 ≈ 2^137.90 >> 2^71` ✗ largely insufficient + uses X_0 computational.
- Rhin 1987 (Padé chain): same bridge issue as Salikhov.

→ Each of the 4 profiles fails at least one of the 3 conditions of `CanReplaceBarina`. δ10 closes the loop with FIND-016 transparency note (mea culpa #28): the strict k^6 axiom is necessary because no published bound suffices.

**Probe status**: not yet in `reproduce.sh` (post-audit work). Verify manually:
```bash
lake env lean -c '#print axioms ProjetCollatz.delta10_barina_replacement_impossibility'
# Expected: depends on axioms: [propext]
```

---

## Section 4 — Forbidden patterns

Any appearance of the following in the `#print axioms` output of a Section 1 or Section 2 theorem is a **BLOCKER**, detected by `reproduce.sh` :

- `sorryAx` → EXIT 4 (incomplete proof)
- Any user-declared `axiom` (e.g. `ProjetCollatz.some_axiom`) not listed in this file → EXIT 3 (unexpected axiom)
- Any unlisted axiom from a dependency → EXIT 3 (dependency drift)

---

## Verification

```bash
bash reproduce.sh
# EXIT 0 if baseline maintained
# EXIT 3 if axiom drift
# EXIT 4 if sorryAx detected
```

`reproduce.sh` parses the output of `probes/check_central_axioms.lean` and `probes/check_sorry.lean` against this file. CI (`.github/workflows/verify.yml`) enforces the same checks on every push and pull request.

---

## Historical note

- **2026-04-22**: axiom baseline established via manual `#print axioms` probe; the corresponding Lean source is fixed by the Mathlib pin in `lake-manifest.json` (commit `a3a10db0e9d66acbebf76c5e6a135066525ac900`) and by the `lean-toolchain` pin (`leanprover/lean4:v4.27.0`). Reproduction of this baseline therefore requires only the two pinned versions plus a clean `lake build` plus the probes in `probes/`.
- **2026-04-22**: this canonical document created; probes and CI integration added.
