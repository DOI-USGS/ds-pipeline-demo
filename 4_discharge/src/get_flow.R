library(dataRetrieval)

get_flow <- function(
  flow.file="3_filter/out/summary_flow.rds",
  save.as="4_discharge/out/flow.rds"
){
  
  summary.flow <- readRDS(flow.file)
  
  all_flow <- readNWISdv(summary.flow$siteID,"00060",
                         startDate = min(summary.flow$start),
                         endDate = max(summary.flow$end))
  
  saveRDS(all_flow, save.as)
  
}
