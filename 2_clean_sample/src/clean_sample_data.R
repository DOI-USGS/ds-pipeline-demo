library(readxl)
library(tidyr)
library(stringr)
library(dplyr)
library(data.table)
library(yaml)


clean_sample_data <- function(sample.file){

  sheet.names <- excel_sheets(sample.file)
  
  data.full <- data.frame()
  
  for(i in sheet.names){
    data.sheet <- read_excel(sample.file, 
                             sheet = i,col_types = c("text","date",
                                                     rep("text",7)))
    
    data.long <- data.sheet %>%
      select(-`FC (CFU/100mL)`) %>%
      gather(key = "param", value = "value", -SITE, -DATE) %>%
      mutate(rmk = "")
    
    data.long$rmk[which(str_detect(data.long$value, pattern = "<"))] <- "<"
    data.long$rmk[which(str_detect(data.long$value, pattern = ">"))] <- ">"
    data.long$rmk[which(str_detect(data.long$value, pattern = "M"))] <- "M"
    
    data.long$value.new <- gsub(" ","", data.long$value)
    data.long$value.new <- gsub(">","", data.long$value.new)
    data.long$value.new <- gsub("<","", data.long$value.new)
    data.long$value.new <- gsub("M","", data.long$value.new)
    
    data.long <- data.long %>%
      filter(!is.na(value.new)) %>%
      distinct()
  
    data.long$value.new <- as.numeric(data.long$value.new)
    
    data.full <- rbind(data.full, data.long)
    
  }
  
  # Right now, we have data with >1 sample per day, 
  # but no more info than that. 
  # For now...deleting all but the first unique site/date combo:
  
  site_date <- paste(data.full$SITE, data.full$DATE, data.full$param)
  dup.rows <- which(duplicated(site_date))
  
  data.wide <- dcast(setDT(data.full[-dup.rows,]),
                     SITE + DATE ~ param,
                     value.var = c("value.new", "rmk"))
  
  
  
  names(data.wide) <- gsub("value.new_","",names(data.wide))
  return(data.wide)
}
