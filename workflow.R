# overall workflow:
source("1a_data/src/get_siteinfo.R")
source("2a_clean_sample/src/clean_sample_data.R")
source("2a_filter/src/filter_samples.R")
source("1b_discharge/src/get_flow.R")
source("3_merge/src/merge_sample_flow.R")
source("4_model/src/run_models.R")