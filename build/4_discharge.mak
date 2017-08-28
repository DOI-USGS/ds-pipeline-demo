# Makefile for discharge phase

4_discharge : 4_discharge/out/flow.rds.s3
	@echo "Made all for 4_discharge.mak"

4_discharge/out/flow.rds.s3 :\
		3_filter/out/summary_flow.rds.loc\
		4_discharge/src/get_flow.R\
		lib/src/status.R lib/src/s3.R lib/cfg/s3_config.yaml
	@make -s 3_filter/out/summary_flow.rds
	${RSCRIPT} -e 'get_flow()' ${POSTS3}

# recursively include all previous phase & helper makefiles
include build/3_filter.mak
