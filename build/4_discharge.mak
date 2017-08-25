# Makefile for discharge phase

4_discharge : 4_discharge/out/flow.rds
	@echo "Made all for 4_discharge.mak"

4_discharge/out/flow.rds.s3 :\
		4_discharge/src/get_flow.R\
		3_filter/out/summary_flow.rds\
		lib/s3.R lib/s3_config.yaml
	${RSCRIPT} -e 'get_flow(flow.file="$(word 2,$^)", save.as="$(subst .s3,,$@)")' ${POSTS3}

# recursively include all previous phase & helper makefiles
include build/3_filter.mak
