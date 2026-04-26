# JAR Submission — Reviewer Suggestions (for author validation)

**Manuscript**: "On the non-existence of non-trivial Collatz cycles: a conditional formal proof in Lean 4 with documented structural obstructions"
**Author**: Eric Merle
**Target journal**: Journal of Automated Reasoning (Springer Nature)
**Editor-in-Chief**: Prof. Jasmin Blanchette

---

## Selection criteria

The ideal reviewer profile combines two of the following three competences:

1. **Lean 4 / Mathlib formalization** (the load-bearing technical contribution)
2. **Diophantine approximation / linear forms in logarithms** (the mathematical core: Baker, Rhin, Matveev)
3. **Collatz / 3x+1 problem** (the application domain)

Reviewers must also have a **recent (2023–2026) publication track record** in at least one of these areas to be plausible to the editor.

---

## Three primary suggestions (proposed in cover letter)

### 1. Jonas Bayer
- **Affiliation**: University of Cambridge, Department of Pure Mathematics and Mathematical Statistics (DPMMS / Centre for Mathematical Sciences). PhD student under Tim Gowers.
- **Email**: `jcb234@cam.ac.uk` *(verified against jonasbayer.de and Cambridge faculty page)*
- **Profile**: ITP / formalization expert. Co-author with Marco David of *A Formal Proof of Complexity Bounds on Diophantine Equations* (ITP 2025, LIPIcs vol. 352 art. 3, DOI 10.4230/LIPIcs.ITP.2025.3, arXiv:2505.16963).
- **Why him**: closest methodological precedent. He has formalized Diophantine bounds in Isabelle/HOL — exactly our problem class, in a sister theorem prover. Should immediately understand our `structure`-based conditionality.
- **Coverage**: criteria (1) + (2).

### 2. Christian Hercher
- **Affiliation**: Europa-Universität Flensburg
- **Profile**: Collatz expert. Author of *There are no Collatz m-Cycles with m ≤ 91* (J. Integer Sequences 26, 2023, Article 23.3.5).
- **Why him**: Hercher's lower bound is a *direct corollary* of our central theorem chain (§8.3, theorem `hercher_from_baker_barina`). He has the unique standing to verify our claim that the formalization recovers his published result independently.
- **Coverage**: criterion (3) — Collatz cycle expert.

### 3. Olivier Rozier
- **Affiliation**: Institut de Physique du Globe de Paris (IPGP), Université Paris Cité. Research Engineer.
- **Email**: `rozier@ipgp.fr` *(visible on IPGP profile page)*
- **Profile**: Diophantine / Collatz researcher. Co-author with Claude Terracol of *Paradoxical behavior in Collatz sequences* (Discrete Mathematics 349, 2026, Article 115167, DOI 10.1016/j.disc.2026.115167) and of *Are the Collatz and abc conjectures related?* (arXiv:2306.15284).
- **Why him**: bridges (2) and (3). His own paper uses the Rhin linear-form bound (Proposition 6.3) at a similar level of granularity to our `BakerSeparation` hypothesis.
- **Coverage**: criteria (2) + (3).

---

## Backup suggestions (if any of the above declines)

### 4. Marco David
- **Affiliation**: UC Berkeley, Leinweber Institute for Theoretical Physics
- **Email**: `marco.david@berkeley.edu` *(per marcodavid.net)*
- **Profile**: Co-author with Jonas Bayer of the ITP 2025 Diophantine bounds paper. Same coverage as #1.

### 5. Patrick Massot
- **Affiliation**: Université Paris-Saclay
- **Profile**: Mathlib core maintainer, Lean 4 formalization expert (perfectoid spaces, sphere eversion, etc.).
- **Coverage**: criterion (1) — exceptionally strong on Lean / Mathlib infrastructure.

### 6. Heather Macbeth
- **Affiliation**: Fordham University (Associate Professor); currently on leave at Imperial College London. `hmacbeth1@fordham.edu` still functional.
- **Profile**: Mathlib core contributor, mathematics formalization.
- **Coverage**: criterion (1).

### 7. Barinder S. Banwait
- **Affiliation**: Lodha Mathematical Sciences Institute, Mumbai
- **Email**: `barinder.s.banwait@gmail.com` *(per barindersbanwait.com)*
- **Profile**: Author of *A formal proof of the Ramanujan–Nagell theorem in Lean 4* (arXiv:2604.09808, April 2026).
- **Coverage**: criteria (1) + (2). Direct Lean 4 Diophantine precedent, very recent.

### 8. Alex Kontorovich
- **Affiliation**: Rutgers University
- **Profile**: Sinai-school 3x+1 expert. Co-author of *Stochastic Models for the 3x+1 and 5x+1 Problems* (arXiv:0910.1944) and *Structure Theorem for (d,g,h)-Maps* (arXiv:math/0601622).
- **Coverage**: criterion (3). His specific expertise is on the divergence half of Collatz — slightly orthogonal to our cycles-only paper, but he is a leading authority on the broader literature.

---

## Reviewers to **avoid** suggesting

- **Terence Tao** (UCLA) — extremely senior, low probability of acceptance; would also raise expectation calibration issues.
- **Jeffrey Lagarias** (Michigan) — venerable Collatz authority but possibly conflict of interest given his editorship of *The Ultimate Challenge* (AMS 2010) which figures in our literature mapping.
- **John Janik** — author of `syracuse-confinement`, a non-peer-reviewed, AI-assisted, 9-axiom parallel Lean effort (see internal note); not a credible reviewer for this work.
- **Authors of recent contested preprints** (Santana, Honarvar, Dhiman-Pandey) — they are cited, sometimes critically, in §6.4; suggesting them would raise impartiality concerns.

---

## Recommendation for the Editorial Manager submission form

The form typically requests 3–5 reviewer suggestions. Submit the **three primary suggestions** as preferred, plus two from the backup list (Marco David and Patrick Massot give the best balance of expertise breadth).

**Eric: please validate each name and confirm the email address before submission. The TU Munich and Université Paris Cité pages are the authoritative sources.**

---

*Prepared April 2026 in support of the JAR submission.*
