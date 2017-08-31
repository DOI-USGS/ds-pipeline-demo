library(yaml)
library(dplyr)
library(readxl)

summarize_sites <- function(
  sample.file="2_clean_sample/out/sample_data.rds",
  site.file="1_get_raw_data/out/SampleGanttCharts_wRanks.xlsx",
  config.file="3_filter/cfg/filter_config.yaml",
  save.as="3_filter/out/summary_sites.rds"
) {
  
  config.args <- yaml.load_file(config.file)
  
  summary.samples <- summarize_samples(sample.file, config.args)
  
  site.info <- read_excel(site.file, sheet = config.args$fetch.args[["sheet"]])
  
  flow.info <- select(site.info, Site, `USGS Flow Site to use`)
  
  summary.sites <- summary.samples %>%
    left_join(flow.info, by=c("main_site"="Site")) %>%
    rename(siteID = `USGS Flow Site to use`) %>%
    filter(!is.na(siteID)) 
  
  saveRDS(summary.sites, file=save.as)
}
