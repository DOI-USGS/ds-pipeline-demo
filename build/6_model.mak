# Makefile for model phase

6_model : 6_model/doc/progress.csv.loc 6_model/doc/model_check.pdf.s3
	@echo "Made all for 6_model.mak"

6_model/doc/progress.csv.loc :\
		6_model/src/run_models.R\
		5_merge/doc/progress.csv.loc\
		lib/src/status.R
	@make -s 5_merge/doc/progress.csv
	${RSCRIPT} -e 'run_models()' ${LOCAL}

# using progress.csv as a status indicator; just update the .rds timestamps
6_model/out/%_lm.rds : 6_model/doc/progress.csv
	@touch "$@"

6_model/doc/model_check.pdf.s3 :\
		6_model/src/plot_models.R\
		6_model/doc/progress.csv.loc\
		lib/src/status.R lib/src/s3.R lib/cfg/s3_config.yaml
	@make -s 6_model/doc/progress.csv
	${RSCRIPT} -e 'plot_models()' ${POSTS3}

# recursively include all previous phase & helper makefiles
include build/5_merge.mak
