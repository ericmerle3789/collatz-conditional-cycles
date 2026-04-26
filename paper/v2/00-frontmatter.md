---
title: |
  On the non-existence of non-trivial Collatz cycles: a conditional formal proof in Lean 4 with documented structural obstructions
author: |
  Eric Merle\
  Independent researcher, Chartres, France\
  Email: eric.merle@ac-versailles.fr\
  ORCID: [0009-0008-7940-402X](https://orcid.org/0009-0008-7940-402X)
abstract: |
  We address the no-non-trivial-cycle disjunct of the Collatz conjecture. The central result, formalized in Lean 4 with Mathlib v4.27.0, is a conditional non-existence theorem declared parametrically with three structural hypotheses: `BakerSeparation` (after Baker 1966), `BarinaVerification` (after the 2025 computational verification that every positive integer below `2⁷¹` reaches `1`), and `ProductBoundThreshold`, a project-derived cycle-complexity bound made fully explicit in §4.3. The Lean formalization is machine-verified with kernel-3 axiom profile, no user axioms and no `sorry`, and is reproducible via `reproduce.sh` against an explicit `expected_axioms.md` baseline.

  We complement the theorem with two impossibility lemmas (δ8, δ8') showing that no uniform algebraic refinement of the Product Bound derivation can eliminate the third hypothesis within the Baker + continued-fraction framework; a literature mapping (δ9) documenting the absence of any peer-reviewed deterministic upper bound on cycle length in the 1977-2026 results we surveyed; and an alternative disjunctive framing (δ7) that connects the conditional theorem to Hercher's 2023 lower bound. The paper is intended as a stable substrate for future contributions resolving the structural conditionality.
---

**Keywords.** Collatz conjecture, 3x+1 problem, Collatz cycles, linear forms in logarithms, Baker's theorem, continued fractions, irrationality measure, formal verification, Lean 4, Mathlib.

**MSC 2020.** 11B83 (Special sequences), 11J81 (Transcendence; general theory of irrational numbers), 11J86 (Linear forms in logarithms), 11Y55 (Calculation of integer sequences), 37P99 (Arithmetic and non-Archimedean dynamical systems), 68V15 (Theorem proving and proof assistants).

\newpage
