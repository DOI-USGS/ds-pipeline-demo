# Makefile for entire project; uses phase-specific makefiles within the build/ directory
all:
	make 6_model
	@echo "Finished building project"

include build/6_model.mak
