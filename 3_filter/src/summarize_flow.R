library(dplyr)

summarize_flow <- function(smry.sample.file, save.as) {

  summary.samples <- readRDS(smry.sample.file)
  
  summary.flow <- summary.samples %>%
    group_by(siteID) %>%
    summarise(start = min(begin),
              end = max(end))
  
  saveRDS(summary.flow, file=save.as)
}
