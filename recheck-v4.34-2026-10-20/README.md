# Re-check on Lean 4.34.0 (20–21 October 2026)

Release v1.0 of this repository was checked on Lean 4.27.0, before the fix of the Lean kernel soundness bug [lean4#14576](https://github.com/leanprover/lean4/issues/14576). This folder re-checks, on Lean 4.34.0 with Mathlib v4.34.0, the 35 v1.0 Lean files that make up the import closure of `ProjetCollatz/Phase58PorteDeuxFinal.lean` (the file of `no_cycle_k_le_1322`), as copies with renamed imports, together with three files written in the author's lab. It is not part of any Zenodo version (item 5 of the erratum of Zenodo v4, [10.5281/zenodo.23496480](https://doi.org/10.5281/zenodo.23496480)). It does not change what the theorems say: the headline theorems are circular, and `BakerSeparation` is a working hypothesis (items 1 and 2 of the erratum).

## Result

In run 2 (`logs/RECHECK_2026-10-21_verify.log`), all 38 `Labo` modules were compiled from source (`Labo modules compiled: 38`; `Build completed successfully (8961 jobs).`). None of the 18 theorems listed in `probes/axioms.lean` depends on any axiom other than `propext`, `Classical.choice` and `Quot.sound` (`18 of 18 theorems within [propext, Classical.choice, Quot.sound]`). For the main one:

```
'ProjetCollatz.no_cycle_k_le_1322' depends on axioms: [propext, Classical.choice, Quot.sound]
ProjetCollatz.no_cycle_k_le_1322 : ProjetCollatz.BakerSeparation →
  ProjetCollatz.BarinaVerification → ∀ (n k : ℕ), ProjetCollatz.IsOddCycle n k → k ≤ 1322 → False
```

The 18 theorems are `no_cycle_k_le_1322`, what v1.0 proves without circularity (erratum, item 1); `no_nontrivial_cycle_final`, `no_nontrivial_cycle_derived` and `no_nontrivial_cycle_full`, which add nothing beyond k ≤ 1322 (item 1); `bk_1322_derived`, `hercher_from_baker_barina` and `hercher_derived`, immediate consequences of `no_cycle_k_le_1322` (item 6); and 11 theorems of the three lab files.

## Not re-checked

- The other 7 of the 42 Lean files under `ProjetCollatz/` (40 at top level, 2 in `PhaseVIII/`): Phase59 to Phase63 and the 2 files of `PhaseVIII/`, hence `no_nontrivial_cycle_phase59`, `no_cycle_k_gt_1322` and `sdw_from_cf`; also `Main.lean`, `ProjetCollatz.lean`, the repository's root `probes/`, and the two Lean proofs at the end of the erratum.
- Proofs by `native_decide`, which the kernel does not check: on Lean 4.34.0 each one adds an auxiliary axiom. Seven of the 35 files contain such proofs; none of the 18 theorems depends on them. `probes/native_control.lean` shows that the axiom check catches such an axiom (`ProjetCollatz.k982_bound._native.native_decide.ax_1_1`).
- Mathlib and its dependencies: the compiled files that the `Labo` modules import come from the Mathlib cache (`lake exe cache get`).
- No independent checker (such as `leanchecker`) replayed the compiled files.
- Lean 4.34.0 contains the fix of lean4#14576 (PR [lean4#14577](https://github.com/leanprover/lean4/pull/14577), an ancestor of the `v4.34.0` tag), but not three runtime fixes released later in v4.34.1: [lean4#15241](https://github.com/leanprover/lean4/pull/15241), [lean4#15289](https://github.com/leanprover/lean4/pull/15289) and [lean4#15288](https://github.com/leanprover/lean4/pull/15288). According to their pull requests, the bugs fixed by #15241 and #15289 could in principle be extended into a proof of False in the official kernel, and #15288 fixes possible undefined behavior; the pull requests describe when the bugs can occur: with at least 18 GB of free RAM (#15241), with inputs above 100 GB (#15289), and for objects with a huge number of incoming references shared between threads (#15288). The machine of run 2 has 16 GB of physical memory.

## Diff against v1.0

In each of the 35 files, every line equals the v1.0 line, except that `import ProjetCollatz.<Name>` becomes `import Labo.S1_<Name>` (50 lines in all). The Lean sources of `ProjetCollatz/` are the same at tag `v1.0` and on `main`. From the repository root:

```bash
git rev-parse -q --verify v1.0 >/dev/null || echo "tag v1.0 missing: run git fetch --tags"
for f in recheck-v4.34-2026-10-20/Labo/S1_*.lean; do
  m=$(basename "$f" .lean); m=${m#S1_}
  git cat-file -e v1.0:ProjetCollatz/$m.lean 2>/dev/null || { echo "not in v1.0: $m"; continue; }
  diff <(git show v1.0:ProjetCollatz/$m.lean | sed -E 's/^import ProjetCollatz\./import Labo.S1_/') "$f" >/dev/null \
    && echo "identical: $m" || echo "DIFFERS: $m"
done
```

Expected: 35 `identical`, 3 `not in v1.0` (the lab files), no `DIFFERS`.

## Files

| Path | Content |
|---|---|
| `Labo/S1_<Name>.lean` (35 files) | `ProjetCollatz/<Name>.lean` of v1.0, with renamed imports |
| `Labo/S1_X02_H3.lean`, `Labo/S1_H1_Fini.lean`, `Labo/S1_X02_Barina.lean` | the three lab files, not part of v1.0 |
| `lean-toolchain`, `lake-manifest.json` | Lean 4.34.0; Mathlib v4.34.0 (commit `5ed2965256430c3649e86755f9576b54eca72435`) and its dependencies; those of run 1 |
| `lakefile.toml` | that of run 1, without the library `OneObstruction` (unrelated files) and its `defaultTargets` line |
| `probes/axioms.lean`, `probes/native_control.lean` | the axiom probe (18 theorems) and the positive control |
| `verify.sh` | replays the re-check; its comments list what it checks, its requirements and its exit codes |
| `SHA256SUMS` | checksums of the 38 Lean files of `Labo/`, the three files above and the two probes (43 files) |
| `.gitignore` | re-includes `logs/*.log`, which the repository's `.gitignore` excludes |
| `logs/S1_COLD_BUILD_2026-10-20.log` | log of run 1 (sha256 `addf21601e1017c560a0f463458fb3362fbf862e0b8a545f3c2e3d13bfe06788`) |
| `logs/RECHECK_2026-10-21_verify.log` | log of run 2 (sha256 `4c89e9c066f6e12fdc8e1dbf1c396de8dcef85c18339598e4d6cda59ceeb631d`) |

## Runs

Both runs used the build command `lake build Labo.S1_X02_Barina Labo.S1_Phase58PorteDeuxFinal`.

1. **Run 1, 20 October 2026, 08:52:17–09:13:49 (local time).** The command was typed in a Claude Code session of the lab, in its working folder, without `verify.sh`: no checksum or version check, Lake's artifact cache not turned off, build folder not emptied. The log reports all 38 `Labo` modules as `Built` (in the Lake of Lean 4.34.0, only `Built` means that a module was compiled) and `Build completed successfully (8961 jobs).`, then the axioms of `no_cycle_k_le_1322` shown above. It does not record the date (taken from its file name), the toolchain or the machine.
2. **Run 2, 21 October 2026, 08:13:08–08:40:55 (CEST).** `bash verify.sh` on a fresh copy of this folder (this README, which is not checksummed, was edited afterwards), captured with `bash verify.sh > log 2>&1; echo "exit=$?" >> log`. The log records the machine, the Lean and Lake versions, the commit of each dependency, the sha256 of `SHA256SUMS` and of `verify.sh` (those of the files published here), and ends with `RE-CHECK PASSED` and `exit=0`.

Both builds print the same 87 warnings (linter and deprecation warnings) and no errors. Earlier versions of `verify.sh` were run eleven times while it was being written; every run passed, and the logs are kept in the lab's records.

## The lab files

They are not part of v1.0 and do not modify it. In them, "H1" is `BakerSeparation`, "H2" is `BarinaVerification` and "H3" is `ProductBoundThreshold` (in `HYPOTHESES.md`, H3 is `DerivedLargeKBound`); their other labels (S1, X02, R03, A1, A4) are internal references of the lab.

- `S1_X02_H3.lean`: under H1 and H2, H3 is equivalent to "there is no non-trivial cycle" (`S1_x02_H3_iff_no_cycle`), and `no_cycle_k_le_1322` holds with H1 used only for 2 ≤ k ≤ 1322 (`S1_no_cycle_k_le_1322_local`).
- `S1_H1_Fini.lean`: H1 for 2 ≤ k ≤ 1322 is proved by one kernel reduction (`decide +kernel`, no `native_decide`) and monotonicity in s, hence no non-trivial cycle with k ≤ 1322 under H2 alone (`S1_no_cycle_k_le_1322_barina_only`).
- `S1_X02_Barina.lean`: the equivalence of `S1_X02_H3.lean` under H2 alone.

None of this is new mathematics: by item 1 of the erratum, H3 excludes every non-trivial cycle on its own, and by item 4, Hercher's Corollary 29 with Bařina's verification gives more than 1.375·10¹¹ odd terms for any non-trivial cycle.

## Authorship and use of AI

The port of the 35 files (import lines only) and the three lab files were made on 25 September 2026 by Claude agents (Anthropic) in Claude Code sessions of the lab; run 1 was made by another session of the lab on 20 October 2026. This README, `verify.sh`, the two probes, `SHA256SUMS`, `.gitignore` and the change to `lakefile.toml` were written by Claude Opus 5.5 (Anthropic) on 20–21 October 2026, in the session that made run 2, and reviewed by separate Claude sessions. The proofs are the Lean files; the kernel checks them, not their hypotheses. Responsible: Eric Merle.
