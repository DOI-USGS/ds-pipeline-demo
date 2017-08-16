library(yaml)
library(dplyr)
library(readxl)

filter_samples <- function(filter.config){
  
  config.args <- yaml.load_file(filter.config)
  
  fetch.args <- config.args$fetch.args
  save.args <- config.args$save.args

  filter.count <- config.args$filter.args
  
  data.wide <- readRDS(file.path(fetch.args[["path"]],fetch.args[["file.data"]]))
  
  summary.sites <- data.wide %>%
    group_by(SITE) %>%
    summarize(begin = min(DATE,na.rm = TRUE),
              end = max(DATE,na.rm = TRUE),
              count = n()) %>%
    filter(count > filter.count[["min.samples"]]) %>%
    arrange(desc(count)) 
 
  site.info <- read_excel(file.path(fetch.args[["site.path"]],fetch.args[["site.data"]]), 
                          sheet = fetch.args[["sheet"]])
  
  flow.info <- select(site.info, Site, `USGS Flow Site to use`)
  
  # Note:  S is surface, B bottom and M middle.
  
  summary.sites$main_site <- regmatches(summary.sites$SITE, regexpr("[A-Za-z]{2}-[0-9]{2}", summary.sites$SITE)) 
  
  summary.sites$depth_code <- gsub(pattern = "[A-Za-z]{2}-[0-9]{2}",replacement = "", summary.sites$SITE)
  
  summary.sites <- summary.sites %>%
    left_join(flow.info, by=c("main_site"="Site")) %>%
    rename(siteID = `USGS Flow Site to use`) %>%
    filter(!is.na(siteID)) 
  
  summary.flow <- summary.sites %>%
    group_by(siteID) %>%
    summarise(start = min(begin),
              end = max(end))
  
  
  dir.create(file.path(save.args[["save.path"]]),recursive = TRUE, showWarnings = FALSE)
  
  saveRDS(summary.flow, file=file.path(save.args[["save.path"]],save.args[["save.flow"]]))
  saveRDS(summary.sites, file=file.path(save.args[["save.path"]],save.args[["save.site"]]))
    
}

filter_samples(filter.config = "2a_filter/in/filter_config.yaml")