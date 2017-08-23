# Makefile for merge phase

5_merge : 5_merge/doc/data_checks.pdf 5_merge/out/progress.csv
	@echo "Made all for 5_merge.mak"

5_merge/doc/data_checks.pdf :\
		5_merge/src/merge_sample_flow.R\
		2_clean_sample/out/sample_data.rds\
		3_filter/out/summary_sites.rds\
		4_discharge/out/flow.rds\
		5_merge/cfg/merge_config.yaml
	${RSCRIPT} -e 'merge_sample_flow(\
		sample.file="$(word 2,$^)",\
		site.file="$(word 3,$^)",\
		flow.file="$(word 4,$^)",\
		merge.config="$(word 5,$^)", save.pdf.as="$@", save.csv.as="5_merge/out/progress.csv")'\
		${ADDLOG}

5_merge/out/progress.csv : 


	# recursively include all previous phase & helper makefiles
include build/4_discharge.mak
