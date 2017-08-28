# Makefile for merge phase

5_merge : 5_merge/doc/progress.csv 5_merge/doc/data_checks.pdf
	@echo "Made all for 5_merge.mak"

# this first target actually creates a bunch of .rds files as well as the .csv
5_merge/doc/progress.csv.loc :\
		5_merge/src/merge_sample_flow.R\
		2_clean_sample/out/sample_data.rds.s3\
		3_filter/out/summary_sites.rds.s3\
		4_discharge/out/flow.rds.s3\
		5_merge/cfg/merge_config.yaml\
		lib/src/status.R
	@make -s\
		2_clean_sample/out/sample_data.rds\
		3_filter/out/summary_sites.rds\
		4_discharge/out/flow.rds
	${RSCRIPT} -e 'merge_sample_flow()' ${LOCAL}

# using progress.csv as an indicator for the presence of 5_merge/out/%.rds
5_merge/doc/data_checks.pdf.s3 :\
		5_merge/src/merge_sample_flow.R\
		5_merge/doc/progress.csv.loc\
		lib/src/status.R lib/src/s3.R lib/cfg/s3_config.yaml
	@make -s 5_merge/doc/progress.csv
	${RSCRIPT} -e 'plot_eLists()' ${POSTS3}

# recursively include all previous phase & helper makefiles
include build/4_discharge.mak
