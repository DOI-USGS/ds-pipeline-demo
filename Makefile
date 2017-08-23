# Makefile for entire project; uses phase-specific makefiles within the build/ directory
all:
	make -f build/6_model.mak
	@echo "Finished building project"
