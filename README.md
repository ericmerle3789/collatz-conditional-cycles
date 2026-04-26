# Collatz cycles: conditional non-existence in Lean 4

Companion repository for the paper *On the non-existence of non-trivial Collatz cycles: a conditional formal proof in Lean 4 with documented structural obstructions*, by Eric Merle.

**Repository**: <https://github.com/ericmerle3789/collatz-conditional-cycles> (branch `main`).
**Paper PDF (28 pages)**: [`paper/v2/collatz-conditional-proof.pdf`](paper/v2/collatz-conditional-proof.pdf), also available as a [GitHub Release v1.0 download](https://github.com/ericmerle3789/collatz-conditional-cycles/releases/tag/v1.0).

## Status

The paper proves a **conditional** theorem: there are no non-trivial Collatz cycles, *provided* three explicit hypotheses (one published, one computational, one project-derived) hold. It does not address the unconditional convergence-to-1 statement (the divergence half of the Collatz conjecture); only the no-non-trivial-cycle disjunct is treated. See paper §3 for the statement and §4–§6 for the status of each hypothesis.

## Author

Eric Merle, Independent researcher, Chartres, France.\
ORCID: [0009-0008-7940-402X](https://orcid.org/0009-0008-7940-402X).\
Contact: `eric.merle@ac-versailles.fr`.

## Contents

| Path | Description |
|---|---|
| `paper/v2/` | Paper sources (Markdown), bibliography (`references.bib`), build configuration (`Makefile`), and the compiled `collatz-conditional-proof.pdf` (28 pages) plus its Pandoc-generated `.tex` source. |
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

- **`BakerSeparation`** — a quantitative form of Baker's theorem on linear forms in logarithms (A. Baker, *Linear forms in the logarithms of algebraic numbers*, *Mathematika* 13 (1966), 204–216).
- **`BarinaVerification`** — the computational verification of D. Barina, *Improved verification limit for the convergence of the Collatz conjecture*, *J. Supercomputing* 81 (2025), 810 (extending the verified bound to `2⁷¹`).
- **`ProductBoundThreshold`** — a project-derived cycle-complexity bound, introduced and justified in paper §4.3.

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
  doi       = {[to be added upon Zenodo deposit]},
  url       = {https://github.com/ericmerle3789/collatz-conditional-cycles}
}
```

## Acknowledgements

The Lean formalization builds on Mathlib (Mathematics in Lean 4); the author thanks the Mathlib community for the continued-fraction, Diophantine-approximation, and number-theory infrastructure on which the central chain depends. The author also thanks D. Barina for the 2025 computational verification underpinning hypothesis (ii). The state-of-the-art mapping in paper §6 is indebted to the cumulative work of the Collatz literature 1977–2026 surveyed therein.

---

*Version 1.0, April 2026.*
