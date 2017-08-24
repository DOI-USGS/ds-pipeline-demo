# Makefile for cleaning phase

2_clean_sample : 2_clean_sample/out/sample_data.rds.s3
	@echo "Made all for 2_clean_sample.mak"

2_clean_sample/out/sample_data.rds.s3 :\
		2_clean_sample/src/clean_sample_data.R\
		1_get_raw_data/out/USGS_WQ_DATA_02-16.xlsx\
		lib/s3.R lib/s3_config.yaml
	${RSCRIPT}\
		-e 'clean_sample_data(sample.file=${OUT}, save.as="$(subst .s3,,$@)")'\
		-e 'post_s3(file.name="$(subst .s3,,$@)", s3.config="lib/s3_config.yaml")'\
		${ADDLOG}
	${DATETIME} > $@ # create the .st file
	@touch $(subst .s3,,$@) # make the .rds file newer than the .st file

# recursively include all previous phase & helper makefiles
include build/1_get_raw_data.mak
