# overall workflow:
source("1_get_raw_data/src/get_siteinfo.R")
source("2_clean_sample/src/clean_sample_data.R")
source("3_filter/src/filter_samples.R")
source("4_discharge/src/get_flow.R")
source("5_merge/src/merge_sample_flow.R")
source("6_model/src/run_models.R")