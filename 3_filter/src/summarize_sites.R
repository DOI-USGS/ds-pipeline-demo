library(yaml)
library(dplyr)
library(readxl)

summarize_sites <- function(sample.data, site.file, config.file) {
  
  config.args <- yaml.load_file(config.file)
  
  summary.samples <- summarize_samples(sample.data, config.args)
  
  site.info <- read_excel(site.file, sheet = config.args$fetch.args[["sheet"]])
  
  flow.info <- select(site.info, Site, `USGS Flow Site to use`)
  
  summary.sites <- summary.samples %>%
    left_join(flow.info, by=c("main_site"="Site")) %>%
    rename(siteID = `USGS Flow Site to use`) %>%
    filter(!is.na(siteID)) 
  
  return(summary.sites)
}
