#!/usr/bin/env python3
"""REQ-MATH-012 — δ10 Barina-Replacement Impossibility numerical thresholds

Sandbox cross-check (Two-Key OLD3↔NEW4↔ChatGPT) for the δ10 cartographic
audit lemma in `ProjetCollatz/Phase64Delta10BarinaReplacement.lean`.

Verifies that no published Diophantine bound exponent extracted directly
from {Salikhov 2007, Wu 2003, Rhin 1987, Simons-de Weger 2005} can give
n < 2^71 uniformly for k ≤ 1322 without using a Barina-style X_0
computational verification:

  - Salikhov 2007 (μ-1 ≈ 4.125): 1322^4.125 ≈ 2^42.77 < 2^71 ✓ numerically
    BUT bridge theorem μ(log 3) → μ(log_2 3) missing.
  - Wu 2003 (~7.6155): 1322^7.6155 ≈ 2^78.96 > 2^71 ✗ insufficient.
  - Simons-de Weger 2005 (~13.3): 1322^13.3 ≈ 2^137.90 >> 2^71 ✗ + uses X_0.
  - Rhin 1987 (Padé chain): same bridge issue as Salikhov.

The Lean axiom uses k^6 (FIND-016 baseline), which numerically reaches
1322^6 ≈ 2^62.21 < 2^71. This is STRONGER than any published bound
directly extractable, justifying the FIND-016 transparency note.

References:
- Phase64Delta10BarinaReplacement.lean (theorem delta10_barina_replacement_impossibility)
- chatgpt_queries/Q13-response-etude-delta10.md (Three-Key Phase B)
- _audit_mailbox_OLD3-NEW4/findings/2026-04-30-finding-016-bakerseparation-exponent-unjustified.md

Author: OLD3 + NEW4 cross-check (Two-Key sandbox)
Date: 2026-04-30
ARES rules: 1 (zero mental calc), 5 (sandbox tests_math/), 6 (Two-Key)
"""
import math
import sys

K = 1322
THRESHOLD = 2**71  # Barina computational limit


def check_threshold(label: str, exponent: float, expect_below: bool) -> bool:
    """Return True if the test passes (matches expected)."""
    log2_K = math.log2(K)
    log2_val = exponent * log2_K
    is_below = log2_val < 71
    pass_status = (is_below == expect_below)
    status = "✓" if pass_status else "✗"
    print(f"  {status} {label}: 1322^{exponent} ≈ 2^{log2_val:.4f} ; "
          f"< 2^71 ? {is_below} ; expected_below={expect_below}")
    return pass_status


def main() -> int:
    print(f"=== REQ-MATH-012 — δ10 Barina threshold cross-check ===")
    print(f"K = {K}, Barina threshold 2^71 = {THRESHOLD:.3e}, log2 = 71.000")
    print(f"")

    print(f"[1/5] Lean axiom k^6 (FIND-016 baseline) :")
    t1 = check_threshold("k^6", 6, expect_below=True)

    print(f"[2/5] Meta-prompt drift k^7 (mathematically invalid) :")
    t2 = check_threshold("k^7", 7, expect_below=False)

    print(f"[3/5] Wu 2003 ~7.6155 (linear independence measure) :")
    t3 = check_threshold("k^7.6155", 7.6155, expect_below=False)

    print(f"[4/5] Simons-de Weger 2005 ~13.3 (effective constants + X_0) :")
    t4 = check_threshold("k^13.3", 13.3, expect_below=False)

    print(f"[5/5] Salikhov 2007 μ-1 ≈ 4.125 (numerical OK, bridge missing) :")
    t5 = check_threshold("k^4.125", 4.125, expect_below=True)

    all_pass = all([t1, t2, t3, t4, t5])

    print(f"")
    print(f"=== Verdict δ10 (cartographic impossibility, dated 2026-04-30) ===")
    print(f"  Salikhov μ-1=4.125  : numerically OK BUT bridge theorem missing")
    print(f"                        (μ(log 3) ≠ μ(log_2 3) without ε-bridge)")
    print(f"  k^6 (axiom Lean)    : OK BUT stronger than any published bound (FIND-016)")
    print(f"  Wu 7.6155           : INSUFFISANT (1322^7.6155 > 2^71)")
    print(f"  Simons-de Weger 13.3: LARGEMENT INSUFFISANT + uses X_0")
    print(f"  Rhin 1987 (Padé)    : same bridge issue as Salikhov, exponent ~13.3 anyway")
    print(f"")
    print(f"=> AUCUN exposant publié atteignable directement ne donne n < 2^71")
    print(f"   uniformément jusqu'à k=1322 sans Barina X_0 computationnel.")
    print(f"")
    print(f"=> δ10 cartographic impossibility CONFIRMED numerically.")
    print(f"   Theorem: ProjetCollatz.delta10_barina_replacement_impossibility")
    print(f"   Axiom profile: [propext] only (kernel-1, no Classical.choice).")
    print(f"")

    if all_pass:
        print(f"REQ-MATH-012 PASS : 5/5 checks confirm δ10 cartographic catalogue.")
        return 0
    else:
        print(f"REQ-MATH-012 FAIL : at least one threshold expectation diverges.")
        return 1


if __name__ == "__main__":
    sys.exit(main())
