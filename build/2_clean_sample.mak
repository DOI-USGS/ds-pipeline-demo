# Makefile for cleaning phase

2_clean_sample : 2_clean_sample/out/sample_data.rds
	@echo "Made all for 2_clean_sample.mak"

2_clean_sample/out/sample_data.rds :\
		2_clean_sample/src/clean_sample_data.R\
		1_get_raw_data/out/USGS_WQ_DATA_02-16.xlsx
	${RSCRIPT} -e 'clean_sample_data(sample.file=${OUT}, save.as="$@")' ${ADDLOG}

# recursively include all previous phase & helper makefiles
include build/1_get_raw_data.mak
