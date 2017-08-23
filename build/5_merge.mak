# Makefile for merge phase

5_merge : 5_merge/doc/progress.csv 5_merge/doc/data_checks.pdf
	@echo "Made all for 5_merge.mak"

# this first target actually creates a bunch of .rds files as well as the .csv
5_merge/doc/progress.csv :\
		5_merge/src/merge_sample_flow.R\
		2_clean_sample/out/sample_data.rds\
		3_filter/out/summary_sites.rds\
		4_discharge/out/flow.rds\
		5_merge/cfg/merge_config.yaml
	${RSCRIPT} -e 'merge_sample_flow(\
		sample.file="$(word 2,$^)",\
		site.file="$(word 3,$^)",\
		flow.file="$(word 4,$^)",\
		merge.config="$(word 5,$^)",\
		save.csv.as="$@",\
		save.eLists.in="5_merge/out")'\
		${ADDLOG}

# using progress.csv as a status indicator; just update the .rds timestamps
5_merge/out/%.rds : 5_merge/doc/progress.csv
	@touch "$@"

5_merge/doc/data_checks.pdf :\
		5_merge/src/merge_sample_flow.R\
		5_merge/out/*.rds
	${RSCRIPT} -e 'plot_eLists(eList.dir="5_merge/out", save.pdf.as="$@")' ${ADDLOG}

# recursively include all previous phase & helper makefiles
include build/4_discharge.mak
