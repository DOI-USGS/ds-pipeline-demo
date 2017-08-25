library(dplyr)

summarize_flow <- function(summary.samples) {
  
  summary.flow <- summary.samples %>%
    group_by(siteID) %>%
    summarise(start = min(begin),
              end = max(end))
  
  return(summary.flow)
}
