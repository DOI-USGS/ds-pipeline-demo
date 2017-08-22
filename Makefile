# Makefile for entire project; uses phase-specific makefiles within the build/ directory
all:
	make -f build/3_filter.mak -n
