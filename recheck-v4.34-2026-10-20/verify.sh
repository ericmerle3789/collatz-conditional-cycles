#!/usr/bin/env bash
# Cold re-check on Lean 4.34.0 / Mathlib v4.34.0 (every Labo module compiled in an emptied build folder;
# Mathlib from its cache) of the v1.0 import closure of Phase58PorteDeuxFinal.lean (35 files) and of the three
# LABO-COLLATZ files of this folder.
# Usage: bash verify.sh   (needs elan, which provides lean and lake, git, curl, sha256sum or shasum, and network
# access: Lake clones Mathlib and its dependencies into this folder. Disk on a first run: about 8 GB in this
# folder, plus the Mathlib cache in ~/.cache/mathlib and the Lean toolchain in ~/.elan, about 13 GB in all)
# Exit codes:
#   0 success;
#   1 missing or broken tool, checksum mismatch or malformed SHA256SUMS, unexpected lakefile.lean, wrong Lean or
#     Lake version, or a dependency not at its pinned commit or with modified tracked files;
#   2 failure to clean .lake/build, build failure, `sorry`, or not all 38 Labo modules compiled;
#   3 probe failure, probes/axioms.lean not listing 18 theorems, axiom profile mismatch, or failed positive control;
#   4 failure of `lake exe cache get`;
#   any other unexpected failure exits with the failing command's own code.
set -euo pipefail
cd "$(dirname "$0")"
# Never take Labo build products from Lake's local artifact cache: every module must be compiled here.
export LAKE_ARTIFACT_CACHE=false
echo "start $(date '+%Y-%m-%d %H:%M:%S %z')"
echo "system: $(uname -srm)"
if [ "$(uname -s)" = Darwin ]; then
  echo "machine: $(sysctl -n hw.model), $(sysctl -n machdep.cpu.brand_string), $(( $(sysctl -n hw.memsize) / 1073741824 )) GB"
fi

for t in lean lake git curl; do
  command -v "$t" >/dev/null 2>&1 || { echo "$t not found (lean and lake come with elan, https://github.com/leanprover/elan)"; exit 1; }
done

# 0. The files match SHA256SUMS (43 entries; --strict rejects malformed lines).
if command -v sha256sum >/dev/null 2>&1; then SUM="sha256sum"
elif command -v shasum >/dev/null 2>&1; then SUM="shasum -a 256"
else echo "sha256sum or shasum not found"; exit 1; fi
[ "$(wc -l < SHA256SUMS | tr -d ' ')" -eq 43 ] || { echo "SHA256SUMS must have 43 entries"; exit 1; }
$SUM -c --strict --quiet SHA256SUMS || { echo "checksum mismatch"; exit 1; }
echo "checksums: OK ($(wc -l < SHA256SUMS | tr -d ' ') files; SHA256SUMS itself: $($SUM SHA256SUMS | cut -d' ' -f1))"
echo "verify.sh: $($SUM verify.sh | cut -d' ' -f1)"
# A lakefile.lean would take precedence over the checksummed lakefile.toml.
[ ! -e lakefile.lean ] || { echo "unexpected lakefile.lean"; exit 1; }

# 1. Toolchain (elan reads lean-toolchain); Lake fetches Mathlib and its dependencies as pinned in lake-manifest.json.
echo "lean-toolchain: $(cat lean-toolchain)"
version=$(lean --version) || { echo "lean --version failed"; exit 1; }
echo "$version"
echo "$version" | grep -q "version 4\.34\.0, .*commit 293d5d0c0c3f3dded4688b3ccd6a33939ac5102b" \
  || { echo "expected Lean 4.34.0 (commit 293d5d0c0c3f3dded4688b3ccd6a33939ac5102b)"; exit 1; }
lake_version=$(lake --version) || { echo "lake --version failed"; exit 1; }
echo "$lake_version"
echo "$lake_version" | grep -q "+293d5d0 (Lean version 4\.34\.0)" \
  || { echo "expected the Lake of Lean 4.34.0 (commit 293d5d0)"; exit 1; }
lake exe cache get || { echo "lake exe cache get failed"; exit 4; }
# Each of the 9 dependencies is at the commit pinned in lake-manifest.json, with no change to its tracked files.
deps=0
while read -r rev name; do
  d=".lake/packages/$name"
  got=$(git -C "$d" rev-parse HEAD) || { echo "no checkout of $name"; exit 1; }
  [ "$got" = "$rev" ] || { echo "$name: expected $rev, found $got"; exit 1; }
  git -C "$d" diff --quiet HEAD || { echo "$name: tracked files modified"; exit 1; }
  echo "dependency $name: $got"
  deps=$((deps + 1))
done < <(grep -E '"(rev|name)":' lake-manifest.json | sed -E 's/.*: "([^"]*)".*/\1/' | paste - - | awk 'NF == 2')
[ "$deps" -eq 9 ] || { echo "expected 9 dependencies, checked $deps"; exit 1; }

# 2. Cold state for this folder: delete every file in .lake/build (the build products of the Labo modules).
#    Mathlib's own .olean files (in .lake/packages) come from the Mathlib cache and are kept.
if [ -d .lake/build ]; then find .lake/build -type f -delete || { echo "could not clean .lake/build"; exit 2; }; fi

# 3. Build: the command of the 20 October 2026 run.
lake build Labo.S1_X02_Barina Labo.S1_Phase58PorteDeuxFinal 2>&1 | tee build.out || { echo "build failed"; exit 2; }
if grep -q "declaration uses" build.out; then echo "sorry found"; exit 2; fi
built=$( (grep -oE 'Built Labo\.[A-Za-z0-9_]+ \(' build.out || true) | sort -u | wc -l | tr -d ' ')
echo "Labo modules compiled: $built"
[ "$built" -eq 38 ] || { echo "expected all 38 Labo modules to be compiled"; exit 2; }

# 4. Axiom profile. AXIOMS_OK matches an output of #print axioms within the three standard axioms.
AXIOMS_OK='depends on axioms: \[(propext|Classical\.choice|Quot\.sound)(, (propext|Classical\.choice|Quot\.sound))*\]$|does not depend on any axioms$'
lake env lean probes/axioms.lean 2>&1 | tee axioms.out || { echo "probe failed"; exit 3; }
expected=$(grep -c '^#print axioms' probes/axioms.lean || true)
[ "$expected" -eq 18 ] || { echo "probes/axioms.lean must list 18 theorems"; exit 3; }
ok=$(grep -cE "$AXIOMS_OK" axioms.out || true)
echo "axiom profile: $ok of $expected theorems within [propext, Classical.choice, Quot.sound]"
if [ "$ok" -ne "$expected" ] || grep -q "sorryAx" axioms.out; then echo "AXIOM PROFILE MISMATCH"; exit 3; fi

# 5. Positive control: a native_decide proof shows up as an extra axiom, which the check above rejects.
lake env lean probes/native_control.lean 2>&1 | tee control.out || { echo "control probe failed"; exit 3; }
grep -q "k982_bound\._native\.native_decide\.ax" control.out || { echo "POSITIVE CONTROL FAILED"; exit 3; }
if grep -qE "$AXIOMS_OK" control.out; then
  echo "POSITIVE CONTROL FAILED"; exit 3
fi
echo "positive control: k982_bound (native_decide) has an auxiliary native axiom, as expected"

echo "end $(date '+%Y-%m-%d %H:%M:%S %z')"
echo "RE-CHECK PASSED"
