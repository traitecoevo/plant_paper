all: ms.pdf

LATEX_OPTIONS=-interaction=nonstopmode -halt-on-error -file-line-error
LATEX=pdflatex ${LATEX_OPTIONS}
REMAKE_SOURCES = remake.yml R/*

ms.pdf: ms.tex refs.bib .ms_deps
	${LATEX} ms
	bibtex ms
	${LATEX} ms
	${LATEX} ms
	${LATEX} ms

.ms_deps: ${REMAKE_SOURCES}
	remake
	# Remake may not actually update .ms_deps if there are no changes
	touch $@

tidy:
	rm -f ms.aux ms.bbl ms.blg ms.log ms.out

clean: tidy
	rm -f ms.pdf
	remake clean

.PHONY: all tidy