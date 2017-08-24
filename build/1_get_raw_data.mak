# Makefile for data phase

1_get_raw_data : 1_get_raw_data/out/USGS_WQ_DATA_02-16.xlsx 1_get_raw_data/out/SampleGanttCharts_wRanks.xlsx
	@echo "Made all for 1_get_raw_data.mak"

1_get_raw_data/out/USGS_WQ_DATA_02-16.xlsx :\
		lib/s3.R lib/s3_config.yaml
	${RSCRIPT} -e 'get_s3(file.name="$@", s3.config="lib/s3_config.yaml")' $(call addlog,1_get_raw_data)

1_get_raw_data/out/SampleGanttCharts_wRanks.xlsx :\
		lib/s3.R lib/s3_config.yaml
	$(call get_s3,1_get_raw_data)

# the above two targets could be merged into one if we used %.xlsx as the target name.
# we're using addlog instead of ADDLOG because there aren't any src/*.R files to tell ADDLOG where to put the .Rlog file, so we need to specify it directly.

include build/macros.mak
