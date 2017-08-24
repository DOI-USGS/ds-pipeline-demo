# Makefile for data phase

1_get_raw_data : 1_get_raw_data/out/USGS_WQ_DATA_02-16.xlsx 1_get_raw_data/out/SampleGanttCharts_wRanks.xlsx
	@echo "Made all for 1_get_raw_data.mak"

1_get_raw_data/out/USGS_WQ_DATA_02-16.xlsx :\
		1_get_raw_data/src/get_siteinfo.R\
		1_get_raw_data/cfg/sample_config.yaml
	${RSCRIPT} -e 'get_siteinfo(${CFG}, file.data="$@")' ${ADDLOG}

1_get_raw_data/out/SampleGanttCharts_wRanks.xlsx :\
		1_get_raw_data/src/get_siteinfo.R\
		1_get_raw_data/cfg/siteinfo_config.yaml
	${RSCRIPT} -e 'get_siteinfo(${CFG}, file.data="$@")' ${ADDLOG}

include build/macros.mak