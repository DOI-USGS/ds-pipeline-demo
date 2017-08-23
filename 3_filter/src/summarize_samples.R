library(dplyr)

summarize_samples <- function(sample.file, config.args){
  
  data.wide <- readRDS(sample.file)
  
  summary.samples <- data.wide %>%
    group_by(SITE) %>%
    summarize(begin = min(DATE,na.rm = TRUE),
              end = max(DATE,na.rm = TRUE),
              count = n()) %>%
    filter(count > config.args$filter.args[["min.samples"]]) %>%
    arrange(desc(count)) 
  
  # Note:  S is surface, B bottom and M middle.
  
  summary.samples$main_site <- regmatches(summary.samples$SITE, regexpr("[A-Za-z]{2}-[0-9]{2}", summary.samples$SITE)) 
  
  summary.samples$depth_code <- gsub(pattern = "[A-Za-z]{2}-[0-9]{2}",replacement = "", summary.samples$SITE)
  
  return(summary.samples)
}
