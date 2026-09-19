.DEFAULT_GOAL := watch

TYPST ?= typst
SOURCE := typst/bachelorarbeit.typ
OUTPUT ?= output/pdf/bachelorarbeit-typst.pdf

.PHONY: watch build

watch:
	mkdir -p "$(dir $(OUTPUT))"
	$(TYPST) watch "$(SOURCE)" "$(OUTPUT)"

build:
	mkdir -p "$(dir $(OUTPUT))"
	$(TYPST) compile "$(SOURCE)" "$(OUTPUT)"
