library(EGRET)
library(dplyr)

merge_sample_flow <- function(merge_config){
  
  config.args <- yaml.load_file(merge_config)
  
  fetch.args <- config.args$fetch.args
  flow.path <- fetch.args[["flow.path"]]
  flow.file <- fetch.args[["flow.file"]]
  sample.path <- fetch.args[["sample.path"]]
  sample.file <- fetch.args[["sample.file"]]
  site.path <- fetch.args[["site.path"]]
  site.file <- fetch.args[["site.file"]]
  
  all.samples <- readRDS(file.path(sample.path,sample.file))
  all.flow <- readRDS(file.path(flow.path,flow.file))
  
  site.summary <- readRDS(file.path(site.path,site.file))
  
  save.args <- config.args$save.args
  save.path <- save.args[["save.path"]]
  save.file <- save.args[["save.file"]]
}

merge_sample_flow(merge_config = "3_merge/in/merge_config.yaml")