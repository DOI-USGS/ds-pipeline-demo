# Makefile for data phase

1_get_raw_data :\
		1_get_raw_data/out/USGS_WQ_DATA_02-16.xlsx.s3\
		1_get_raw_data/out/SampleGanttCharts_wRanks.xlsx.s3
	@echo "Made all for 1_get_raw_data.mak"

# the following rule creates an .s3 status indicator file corresponding to each data file. we will also commit these .s3 files, so this rule will only be used the first time (per file) the first person runs it
1_get_raw_data/out/%.s3 :
	@make -s $@fromcache

include build/macros.mak
include build/cache.mak
