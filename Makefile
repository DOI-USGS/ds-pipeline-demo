# Makefile for entire project; uses phase-specific makefiles within the build/ directory
all:
	make 6_model
	@echo "Finished building project"

clean_%:
	rm $**/out/*.rds

include build/6_model.mak
