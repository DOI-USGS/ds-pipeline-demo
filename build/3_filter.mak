# Makefile for filter phase

3_filter : 3_filter/out/summary_sites.rds.s3 3_filter/out/summary_flow.rds.loc
	@echo "Made all for 3_filter.mak"

3_filter/out/summary_sites.rds.s3 :\
		3_filter/src/summarize_sites.R\
		3_filter/src/summarize_samples.R\
		1_get_raw_data/out/SampleGanttCharts_wRanks.xlsx.s3\
		2_clean_sample/out/sample_data.rds.s3\
		3_filter/cfg/filter_config.yaml\
		lib/src/status.R lib/src/s3.R lib/cfg/s3_config.yaml
	@make -s 1_get_raw_data/out/SampleGanttCharts_wRanks.xlsx 2_clean_sample/out/sample_data.rds
	${RSCRIPT} -e 'summarize_sites()' ${POSTS3}

# we won't cache summary_flow on s3 because it's an easy intermediate between summary_sites and 4/o/flow.rds, so less important to store on s3. and i want practice not-caching.
3_filter/out/summary_flow.rds.loc :\
		3_filter/src/summarize_flow.R\
		3_filter/out/summary_sites.rds.s3\
		lib/src/status.R
	@make -s 3_filter/out/summary_sites.rds
	${RSCRIPT} -e 'summarize_flow()' ${LOCAL}

# recursively include all previous phase & helper makefiles
include build/2_clean_sample.mak
