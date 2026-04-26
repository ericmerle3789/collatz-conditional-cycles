# expected_axioms.md

**Baseline for `probes/check_central_axioms.lean`** — snapshot of axiom dependencies for all central and auxiliary theorems of `collatz-conditional-cycles`. The exact repository commit captured by this snapshot is the one cited in `paper/v2/lean-source-README.md` and in `paper/v2/§8`.

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
