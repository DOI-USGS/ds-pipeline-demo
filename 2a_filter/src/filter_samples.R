library(yaml)
library(dplyr)
library(readxl)

filter_samples <- function(filter.config){
  
  config.args <- yaml.load_file(filter.config)
  
  fetch.args <- config.args$fetch.args
  file.data <- fetch.args[["file.data"]]
  fetch.path <- fetch.args[["path"]]
  
  site.data <- fetch.args[["site.data"]]
  site.path <- fetch.args[["site.path"]]
  site.sheet <- fetch.args[["sheet"]]
  
  save.args <- config.args$save.args
  save.path <- save.args[["save.path"]]
  save.file <- save.args[["save.file"]]
  
  filter.count <- config.args$filter.args
  
  data.wide <- readRDS(file.path(fetch.path,file.data))
  
  summary.sites <- data.wide %>%
    group_by(SITE) %>%
    summarize(begin = min(DATE,na.rm = TRUE),
              end = max(DATE,na.rm = TRUE),
              count = n())
  
  sheet.names <- excel_sheets(file.path(site.path,site.data))
  
  site.info <- read_excel(file.path(site.path,site.data), 
                          sheet = site.sheet)
  
  flow.info <- select(site.info, Site, `USGS Flow Site to use`)
  
  # Note:  S is surface, B bottom and M middle.
  
  summary.sites$main_site <- regmatches(summary.sites$SITE, regexpr("[A-Za-z]{2}-[0-9]{2}", summary.sites$SITE)) 
  
  summary.sites$depth_code <- gsub(pattern = "[A-Za-z]{2}-[0-9]{2}",replacement = "", summary.sites$SITE)
  
  summary.sites <- summary.sites %>%
    left_join(flow.info, by=c("main_site"="Site"))
  
  summary.flow <- summary.sites %>%
    rename(siteID = `USGS Flow Site to use`) %>%
    filter(count > filter.count[["min.samples"]]) %>%
    filter(!is.na(siteID)) %>%
    arrange(desc(count)) %>%
    group_by(siteID) %>%
    summarise(start = min(begin),
              end = max(end))
  
  
  dir.create(file.path(save.path),recursive = TRUE, showWarnings = FALSE)
  
  saveRDS(summary.flow, file=file.path(save.path,save.file))
    
}

filter_samples(filter.config = "2a_filter/in/filter_config.yaml")