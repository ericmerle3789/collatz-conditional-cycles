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

.PHONY: all draft-pdf final-latex full-paper clean check

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

# Clean generated artefacts (leave source and bib intact).
clean:
	@rm -f $(COMBINED) $(PDF) $(LATEX)
	@echo "==> cleaned generated artefacts"
