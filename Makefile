# Makefile for entire project; uses phase-specific makefiles within the build/ directory
all:
	make -f build/4_discharge.mak
