# Makefile for discharge phase

4_discharge : 4_discharge/out/flow.rds
	@echo "Made all for 4_discharge.mak"

4_discharge/out/flow.rds :\
		4_discharge/src/get_flow.R\
		3_filter/out/summary_flow.rds
	${RSCRIPT} -e 'get_flow(flow.file="$(word 2,$^)", save.as="$@")' ${ADDLOG}

# recursively include all previous phase & helper makefiles
include build/3_filter.mak
