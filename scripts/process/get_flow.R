library(readxl)
library(dplyr)
library(dataRetrieval)

get_flow <- function(){
  file.data <- "SampleGanttCharts_wRanks.xlsx"
  save.path <- "cached_data"
  sample.file <- "sample_data.rds"
  save.file <- "all_flow.rds"
  save.sites <- "summary_sites.rds"
  
  data.wide <- readRDS(file.path(save.path,sample.file))
  
  summary.sites <- data.wide %>%
    group_by(SITE) %>%
    summarize(begin = min(DATE,na.rm = TRUE),
              end = max(DATE,na.rm = TRUE),
              count = n())
  
  sheet.names <- excel_sheets(file.path(save.path,file.data))
  
  site.info <- read_excel(file.path(save.path,file.data), 
                           sheet = "SUMMARY_wRanks")
  
  flow.info <- select(site.info, Site, `USGS Flow Site to use`)
  
  # Note:  S is surface, B bottom and M middle.
  summary.sites$SITE
  
  summary.sites$main_site <- regmatches(summary.sites$SITE, regexpr("[A-Za-z]{2}-[0-9]{2}", summary.sites$SITE)) 
  
  summary.sites$depth_code <- gsub(pattern = "[A-Za-z]{2}-[0-9]{2}",replacement = "", summary.sites$SITE)
  
  summary.sites <- summary.sites %>%
    left_join(flow.info, by=c("main_site"="Site"))
  
  summary.flow <- summary.sites %>%
    rename(siteID = `USGS Flow Site to use`) %>%
    filter(!is.na(siteID)) %>%
    group_by(siteID) %>%
    summarise(start = min(begin),
              end = max(end))
  
  all_flow <- readNWISdv(summary.flow$siteID,"00060",
                         startDate = min(summary.flow$start),
                         endDate = max(summary.flow$end))
  
  dir.create(file.path(save.path),recursive = TRUE, showWarnings = FALSE)
  
  saveRDS(all_flow, file = file.path(save.path,save.file))
  saveRDS(summary.sites, file = file.path(save.path,save.sites))
}

get_flow()