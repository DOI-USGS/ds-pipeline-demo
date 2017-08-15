library(dataRetrieval)

get_flow <- function(flow.config){

  config.args <- yaml.load_file(flow.config)
  
  fetch.args <- config.args$fetch.args
  file.data <- fetch.args[["summary.file"]]
  fetch.path <- fetch.args[["path"]]

  save.args <- config.args$save.args
  save.path <- save.args[["save.path"]]
  save.file <- save.args[["save.file"]]
  
  summary.flow <- readRDS(file.path(fetch.path,file.data))
  
  all_flow <- readNWISdv(summary.flow$siteID,"00060",
                         startDate = min(summary.flow$start),
                         endDate = max(summary.flow$end))
  
  dir.create(file.path(save.path),recursive = TRUE, showWarnings = FALSE)
  
  saveRDS(all_flow, file = file.path(save.path,save.file))
  
}

get_flow(flow.config = "1b_discharge/in/get_flow_config.yaml")