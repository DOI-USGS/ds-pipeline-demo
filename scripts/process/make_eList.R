library(EGRET)
library(dplyr)

save.path <- "cached_data"
sample.file <- "sample_data.rds"
flow.file <- "all_flow.rds"
sites.file <- "summary_sites.rds"
model.path <- "cached_data/model"

all.samples <- readRDS(file.path(save.path,sample.file))
all.flow <- readRDS(file.path(save.path,flow.file))
site.summary <- readRDS(file.path(save.path,sites.file))

site.summary <- site.summary %>%
  rename(siteID = `USGS Flow Site to use`) %>%
  filter(count > 400) %>%
  filter(!is.na(siteID)) %>%
  arrange(desc(count))

for(i in site.summary$SITE){
  
}