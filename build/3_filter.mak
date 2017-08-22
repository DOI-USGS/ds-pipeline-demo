# Makefile for filter phase

3_filter: 3_filter/out/summary_sites.rds 3_filter/out/summary_flow.rds
	@echo "Made all for 3_filter.mak"

3_filter/out/summary_sites.rds :\
		3_filter/src/filter_samples.R\
		1_get_raw_data/out/SampleGanttCharts_wRanks.xlsx\
		2_clean_sample/out/sample_data.rds\
		3_filter/cfg/filter_config.yaml
	${RSCRIPT}\
		-e 'summarize_sites(\
			sample.file="$(word 3,$^)", site.file="$(word 2,$^)",\
			config.file="$(word 4,$^)", save.as="$@")'\
		${ADDLOG}

# Other ways you could make the summary_sites target:

# ${RSCRIPT}\
	# -e 'site.file="1_get_raw_data/out/SampleGanttCharts_wRanks.xlsx"'\
	# -e 'sample.file="2_clean_sample/out/sample_data.rds"'\
	# -e 'config.file="3_filter/cfg/filter_config.yaml"'\
	# -e 'summarize_sites(sample.file, site.file, config.file, save.as="$@")'\
	# ${ADDLOG}

# ${RSCRIPT}\
	# -e 'site.file="$(word 2,$^)"'\
	# -e 'sample.file="$(word 3,$^)"'\
	# -e 'config.file="$(word 4,$^)"'\
	# -e 'summarize_sites(sample.file, site.file, config.file, save.as="$@")'\
	# ${ADDLOG}

3_filter/out/summary_flow.rds :\
		3_filter/src/filter_samples.R\
		3_filter/out/summary_sites.rds
	${RSCRIPT}\
		-e 'summarize_flow(smry.sample.file="$(word 2,$^)", save.as="$@")'\
		${ADDLOG}

# recursively include all previous phase & helper makefiles
include build/2_clean_sample.mak
