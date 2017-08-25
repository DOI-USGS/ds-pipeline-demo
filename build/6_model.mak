# Makefile for model phase

6_model : 6_model/doc/progress.csv 6_model/doc/model_check.pdf
	@echo "Made all for 6_model.mak"

6_model/doc/progress.csv :\
		6_model/src/run_models.R\
		5_merge/doc/progress.csv\
		5_merge/out/*.rds
	${RSCRIPT} -e 'run_models(\
		eList.csv="$(word 2,$^)",\
		eList.dir="$(dir $(word 3,$^))",\
		save.csv.as="$@",\
		save.models.in="6_model/out")'\
		${ADDLOG}

# using progress.csv as a status indicator; just update the .rds timestamps
6_model/out/%_lm.rds : 6_model/doc/progress.csv
	@touch "$@"

6_model/doc/model_check.pdf.s3 :\
		6_model/src/plot_models.R\
		6_model/out/*_lm.rds\
		lib/s3.R lib/s3_config.yaml
	${RSCRIPT} -e 'plot_models(\
		model.dir="$(dir $(word 2,$^))",\
		save.pdf.as="$(subst .s3,,$@)")'\
		${POSTS3}

# recursively include all previous phase & helper makefiles
include build/5_merge.mak
