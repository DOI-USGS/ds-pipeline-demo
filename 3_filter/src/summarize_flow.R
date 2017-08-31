library(dplyr)

summarize_flow <- function(
  smry.sample.file="3_filter/out/summary_sites.rds",
  save.as="3_filter/out/summary_flow.rds"
) {
  
  summary.samples <- readRDS(smry.sample.file)
  
  summary.flow <- summary.samples %>%
    group_by(siteID) %>%
    summarise(start = min(begin),
              end = max(end))
  
  saveRDS(summary.flow, file=save.as)
}
