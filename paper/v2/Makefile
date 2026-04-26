# paper/v2/ Makefile
# Targets: draft-pdf, final-latex, full-paper, clean, combined.md
#
# Pattern: Markdown-first, pandoc-last.
# All section files are concatenated in numeric order (00-, 01-, ..., 11-).
# References are pulled from references.bib via pandoc --citeproc.

SECTIONS := $(shell ls -1 [0-9][0-9]-*.md | sort)
COMBINED := combined.md
LATEX    := collatz-conditional-proof.tex
PDF      := collatz-conditional-proof.pdf
BIB      := references.bib

# Pandoc version guard: require ≥ 3.0 for --citeproc robustness.
PANDOC   ?= pandoc
PANDOC_FLAGS := --from markdown --citeproc --bibliography $(BIB) --metadata link-citations=true --pdf-engine=xelatex \
    --variable documentclass=amsart \
    --variable classoption=11pt \
    --variable geometry:margin=1in \
    --number-sections \
    --variable secnumdepth=4 \
    --variable mainfont="STIX Two Text" \
    --variable monofont="Menlo" \
    --variable mathfont="STIX Two Math" \
    --include-in-header=preamble.tex

.PHONY: all draft-pdf final-latex full-paper clean check jar-pdf jar-clean

all: draft-pdf

# Concatenate all section files in numeric order into combined.md.
# A trailing blank line is appended after each file so that ATX headings
# starting the next section (e.g. "# Appendix A.") are not absorbed into
# the preceding paragraph by CommonMark/Pandoc heading-detection.
$(COMBINED): $(SECTIONS)
	@echo "==> Concatenating $(words $(SECTIONS)) section files"
	@: > $(COMBINED); for f in $(SECTIONS); do cat "$$f" >> $(COMBINED); printf '\n\n' >> $(COMBINED); done

# Reviewer-facing PDF (pandoc default template).
draft-pdf: $(COMBINED) $(BIB)
	@echo "==> Building draft PDF (pandoc default template)"
	$(PANDOC) $(PANDOC_FLAGS) --to pdf $(COMBINED) -o $(PDF)
	@echo "==> draft PDF ready: $(PDF)"

# Submission LaTeX source (template selection Day 6-7).
final-latex: $(COMBINED) $(BIB)
	@echo "==> Building LaTeX source (no template yet; default)"
	$(PANDOC) $(PANDOC_FLAGS) --to latex $(COMBINED) -o $(LATEX)
	@echo "==> LaTeX source ready: $(LATEX)"

# Combined target: regenerate combined.md + PDF.
full-paper: draft-pdf

# Sanity checks: required tooling, required files.
check:
	@command -v $(PANDOC) >/dev/null 2>&1 || { echo "ERROR: pandoc not in PATH"; exit 1; }
	@test -f $(BIB) || { echo "ERROR: $(BIB) missing"; exit 1; }
	@test -n "$(SECTIONS)" || { echo "ERROR: no section files found (pattern [0-9][0-9]-*.md)"; exit 1; }
	@echo "==> check OK: $(words $(SECTIONS)) sections, $(BIB) present, $(PANDOC) available"

# JAR submission build: Springer Nature template (sn-jnl.cls + sn-mathphys-num.bst).
# Output: jar-build/main-jar.pdf (33-page A4 PDF formatted per JAR / Springer style).
# Requires: pdflatex, bibtex (TeX Live 2025+), pandoc.
jar-pdf: $(COMBINED) $(BIB)
	@echo "==> Building JAR submission PDF (Springer Nature sn-jnl.cls)"
	@test -d jar-build || { echo "ERROR: jar-build/ missing — see jar-build/main-jar.tex"; exit 1; }
	@test -f jar-build/sn-jnl.cls || { echo "ERROR: jar-build/sn-jnl.cls missing — re-download Springer template"; exit 1; }
	@test -f jar-build/sn-mathphys-num.bst || cp jar-build/bst/sn-mathphys-num.bst jar-build/
	@test -L jar-build/references.bib || ln -sf ../$(BIB) jar-build/references.bib
	@$(PANDOC) --from markdown --to latex --top-level-division=section --syntax-highlighting=none --natbib --bibliography=$(BIB) $(COMBINED) -o jar-build/body-raw.tex
	@awk '/^\\section\{Introduction\}/{found=1} /^\\section\{References\}/{exit} found{print}' jar-build/body-raw.tex > jar-build/body.tex
	@cd jar-build && pdflatex -interaction=nonstopmode main-jar.tex > /dev/null
	@cd jar-build && bibtex main-jar > /dev/null
	@cd jar-build && pdflatex -interaction=nonstopmode main-jar.tex > /dev/null
	@cd jar-build && pdflatex -interaction=nonstopmode main-jar.tex > /dev/null
	@echo "==> JAR PDF ready: jar-build/main-jar.pdf"

# JAR-build cleanup (intermediate LaTeX artefacts only; keep main-jar.pdf, main-jar.tex, sn-jnl.cls, bst/).
jar-clean:
	@rm -f jar-build/*.aux jar-build/*.log jar-build/*.bbl jar-build/*.blg jar-build/*.out jar-build/*.toc jar-build/body.tex jar-build/body-raw.tex
	@echo "==> JAR-build intermediates cleaned"

# Clean generated artefacts (leave source and bib intact).
clean:
	@rm -f $(COMBINED) $(PDF) $(LATEX)
	@echo "==> cleaned generated artefacts"
