library(dataRetrieval)

get_flow <- function(flow.file, save.as){

  summary.flow <- readRDS(flow.file)
  
  all_flow <- readNWISdv(summary.flow$siteID,"00060",
                         startDate = min(summary.flow$start),
                         endDate = max(summary.flow$end))
  
  saveRDS(all_flow, save.as)
  
}
