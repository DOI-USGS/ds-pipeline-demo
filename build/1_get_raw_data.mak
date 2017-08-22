# Makefile for data phase

# helper macros that make R calls tidier
include build/macros.mak

# all is the default target, so list all file targets as dependencies
all: 1_get_raw_data/out/USGS_WQ_DATA_02-16.xlsx 1_get_raw_data/out/SampleGanttCharts_wRanks.xlsx

# first file target
1_get_raw_data/out/USGS_WQ_DATA_02-16.xlsx :\
		1_get_raw_data/src/get_siteinfo.R 1_get_raw_data/src/help-get_siteinfo.R\
		1_get_raw_data/cfg/sample_config.yaml
	${RSCRIPT} -e 'get_siteinfo(${CFG})' ${ADDLOG}

1_get_raw_data/out/SampleGanttCharts_wRanks.xlsx :\
		1_get_raw_data/src/get_siteinfo.R\
		1_get_raw_data/cfg/siteinfo_config.yaml
	${RSCRIPT} -e 'get_siteinfo(${CFG})' ${ADDLOG}
