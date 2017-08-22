library(yaml)
library(dplyr)
library(readxl)

summarize_samples <- function(sample.file, config.args){
  
  data.wide <- readRDS(sample.file)
  
  summary.samples <- data.wide %>%
    group_by(SITE) %>%
    summarize(begin = min(DATE,na.rm = TRUE),
              end = max(DATE,na.rm = TRUE),
              count = n()) %>%
    filter(count > config.args$filter.args[["min.samples"]]) %>%
    arrange(desc(count)) 
 
  # Note:  S is surface, B bottom and M middle.
  
  summary.samples$main_site <- regmatches(summary.samples$SITE, regexpr("[A-Za-z]{2}-[0-9]{2}", summary.samples$SITE)) 
  
  summary.samples$depth_code <- gsub(pattern = "[A-Za-z]{2}-[0-9]{2}",replacement = "", summary.samples$SITE)

  return(summary.samples)
}

summarize_sites <- function(sample.file, site.file, config.file, save.as) {
  
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

summarize_flow <- function(smry.sample.file, save.as) {

  summary.samples <- readRDS(smry.sample.file)
  
  summary.flow <- summary.samples %>%
    group_by(siteID) %>%
    summarise(start = min(begin),
              end = max(end))
  
  saveRDS(summary.flow, file=save.as)
}
