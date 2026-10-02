# Collatz cycles: conditional non-existence in Lean 4

> **Erratum (October 2026) — please read before citing.**
>
> 1. **The headline theorem is circular.** Given `BakerSeparation` and `BarinaVerification`, the third hypothesis `ProductBoundThreshold` ("every odd cycle has k ≤ 982") is equivalent to "no non-trivial cycle": `no_cycle_k_le_1322` (same file) already rules out every cycle with k ≤ 1322, and conversely the bound holds vacuously if there is no cycle. Likewise, given `BarinaVerification`, `DerivedLargeKBound` (Phase59) amounts to "no cycle with k > 1322". The value 982 is not derived from (k⁷+k)/3 < 2⁷¹: that inequality only shows that small k are excluded. Paper §4.3 itself notes that k ≤ 982 is "vacuously true assuming the Collatz no-cycle conjecture".
> 2. **What is actually proved** is `no_cycle_k_le_1322`: no non-trivial cycle with k ≤ 1322 odd steps, assuming `BakerSeparation` and `BarinaVerification`. This range is already covered by published results (e.g. Hercher 2023).
> 3. **`BakerSeparation` is a working hypothesis, not a published theorem.** We know of no published result giving (2^s − 3^k)·k⁶ ≥ 3^k for all k ≥ 2 with constant 1 (the effective bound in Simons–de Weger 2005, Lemma 12, after Rhin 1987, has exponent 13.3). Its "≈ 50× margin" is the value at k = 2; "for all k ≥ 2" is not proved. For k ≤ 1322 only finitely many instances are needed, but the theorem takes the full hypothesis as a parameter.
> 4. **μ ≤ 5.125 is Salikhov's (2007) irrationality measure of ln 3**, not a measure of log₂3, and not Rhin's. `HYPOTHESES.md` and the paper (§2, §4.1, §10) misattribute it and apply it to log₂3; the claim that the exponents of ln 3 and log₂3 coincide (§4.1) is unjustified (log₂3 is not a rational multiple of ln 3), and the bound "k ≤ 3693" (§10) is withdrawn.
> 5. **Hercher 2023** (Christian Hercher, *There are no Collatz m-Cycles with m ≤ 91*, J. Integer Seq. 26 (2023), Article 23.3.5) is about m (local minima), not k. The Lean lemmas proving k ≥ 92 (`hercher_from_baker_barina`, `hercher_derived`) do not recover Hercher's theorem. `HYPOTHESES.md` line 24 should read m ≤ 91.
> 6. **Lean kernel.** The project is pinned to Lean v4.27.0, before the fix of the kernel soundness bug lean4#14576 (fixed in v4.32.2, 28 July 2026). It has not been re-checked on a fixed kernel in this repository. The bug does not by itself invalidate these proofs.
>
> The paper, PDF and Lean sources below are kept unchanged as deposited in April 2026 (Zenodo); this erratum takes precedence over their headline claims.

Companion repository for the paper *On the non-existence of non-trivial Collatz cycles: a conditional formal proof in Lean 4 with documented structural obstructions*, by Eric Merle.

**Repository**: <https://github.com/ericmerle3789/collatz-conditional-cycles> (branch `main`).
**Paper PDF (29 pages; the v1.0 release PDF has 28)**: [`paper/v2/collatz-conditional-proof.pdf`](paper/v2/collatz-conditional-proof.pdf), also available as a [GitHub Release v1.0 download](https://github.com/ericmerle3789/collatz-conditional-cycles/releases/tag/v1.0).
**Zenodo DOI**: [10.5281/zenodo.19790406](https://doi.org/10.5281/zenodo.19790406)
**Author ORCID**: [0009-0008-7940-402X](https://orcid.org/0009-0008-7940-402X)

## Status

The repository compiles a theorem with three hypothesis parameters. As explained in the erratum above, the third parameter is equivalent to the conclusion, so the theorem does not establish the non-existence of non-trivial cycles, even conditionally on published results. Its non-circular content is `no_cycle_k_le_1322`. The divergence half of the Collatz conjecture is not addressed.

## Author

Eric Merle, Independent researcher, Chartres, France.\
ORCID: [0009-0008-7940-402X](https://orcid.org/0009-0008-7940-402X).\
Contact: `eric.merle@ac-versailles.fr`.

## Contents

| Path | Description |
|---|---|
| `paper/v2/` | Paper sources (Markdown), bibliography (`references.bib`), build configuration (`Makefile`), and the compiled `collatz-conditional-proof.pdf` (29 pages) plus its Pandoc-generated `.tex` source. |
| `ProjetCollatz/` | Lean 4 formalization (40 files, Mathlib v4.27.0). |
| `probes/` | Axiom-profile probes used by the verification script. |
| `expected_axioms.md` | Reference axiom profile for the central theorem chain. |
| `reproduce.sh` | End-to-end verification script (axioms + sorry detection). |
| `verify.sh` | Lean build sanity check. |
| `lean-toolchain` | Pinned `leanprover/lean4:v4.27.0`. |
| `lakefile.toml`, `lake-manifest.json` | Lake build configuration with pinned Mathlib commit. |
| `HYPOTHESES.md`, `PROOF_CHAIN.md` | Per-hypothesis pedigree and proof-chain navigation aid. |

## Central theorem

```lean
theorem ProjetCollatz.no_nontrivial_cycle_final
    (baker : BakerSeparation)
    (barina : BarinaVerification)
    (sdw   : ProductBoundThreshold)
    (n k : ℕ) (hcyc : IsOddCycle n k) : False
```

Defined in `ProjetCollatz/Phase58PorteDeuxFinal.lean` (line 339). The full axiom dependency can be inspected with `#print axioms ProjetCollatz.no_nontrivial_cycle_final`. The three structure parameters represent:

- **`BakerSeparation`** — a working hypothesis of Baker type, (2^s − 3^k)·k⁶ ≥ 3^k for k ≥ 2, motivated by A. Baker, *Mathematika* 13 (1966), 204–216; it is not a published theorem (see erratum, point 3).
- **`BarinaVerification`** — the computational verification of D. Barina, *Improved verification limit for the convergence of the Collatz conjecture*, *J. Supercomputing* 81 (2025), 810 (extending the verified bound to `2⁷¹`).
- **`ProductBoundThreshold`** — "every odd cycle has k ≤ 982"; given the two other hypotheses it is equivalent to the conclusion (see erratum, point 1).

See paper §4 for the published-source pedigree of each.

## Building the paper

Requirements: `pandoc ≥ 3.0` and a TeX distribution providing `xelatex` (TeX Live recommended). The build also requires the system fonts `STIX Two Text` (and `STIX Two Math`) and `Menlo`.

```bash
cd paper/v2/
make draft-pdf       # produces collatz-conditional-proof.pdf
make final-latex     # produces collatz-conditional-proof.tex
```

## Verifying the formalization

Requirements: [`elan`](https://github.com/leanprover/elan) (the Lean version manager). The Mathlib cache occupies approximately 10 GB on disk; a clean build is RAM-intensive (8 GB recommended).

```bash
bash reproduce.sh
```

Expected outcome: exit 0 with axiom profile `[propext, Classical.choice, Quot.sound]` (the three Mathlib kernel axioms) for the central chain.

Approximate runtime on a Mac M1 Pro 16 GB:

- with the Mathlib cache: 3–5 minutes
- without cache (`bash reproduce.sh --from-source`): about 90 minutes

The script's exit codes are:

```
0 = success (build green, axioms match expected_axioms.md, zero sorry)
1 = toolchain mismatch or missing elan/lake
2 = build failure (or sorry warning surfaced in build log)
3 = axiom drift (unexpected or missing axiom on a probed theorem)
4 = sorryAx detected (incomplete proof)
```

The script runs the toolchain check, fetches the Mathlib cache, builds the project, runs the axiom-profile probes (`probes/check_central_axioms.lean` and per-section probes), and runs the `sorry`-detection probe.

## License

Creative Commons Attribution 4.0 International (CC-BY 4.0), for both the paper sources and the Lean formalization. See `LICENSE`.

## Citation

```bibtex
@misc{merle2026collatzcycles,
  author    = {Merle, Eric},
  title     = {On the non-existence of non-trivial {Collatz} cycles:
               a conditional formal proof in {Lean 4} with documented structural obstructions},
  year      = {2026},
  publisher = {Zenodo},
  version   = {v1.0},
  doi       = {10.5281/zenodo.19790406},
  url       = {https://doi.org/10.5281/zenodo.19790406}
}
```

## Acknowledgements

The Lean formalization builds on Mathlib (Mathematics in Lean 4); the author thanks the Mathlib community for the continued-fraction, Diophantine-approximation, and number-theory infrastructure on which the central chain depends. The author also thanks D. Barina for the 2025 computational verification underpinning hypothesis (ii). The state-of-the-art mapping in paper §6 is indebted to the cumulative work of the Collatz literature 1977–2026 surveyed therein.

---

*Version 1.0, April 2026.*
