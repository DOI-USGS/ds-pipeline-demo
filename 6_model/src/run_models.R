library(EGRET)
library(yaml)

run_models <- function(
  eList.csv="5_merge/doc/progress.csv",
  eList.dir="5_merge/out",
  save.csv.as="6_model/doc/progress.csv",
  save.models.in="6_model/out"
){
  
  master.list <- read.csv(eList.csv, stringsAsFactors = FALSE)
  
  master.list$model_complete <- FALSE
  
  write.csv(master.list, save.csv.as, row.names = FALSE)
  
  for(i in master.list$id[master.list$complete]){
    eList <- readRDS(file.path(eList.dir, paste0(i,".rds")))
    Sample <- getSample(eList)
    
    lm.out <- lm(formula = log(ConcAve) ~ DecYear+LogQ+SinDY+CosDY,data=Sample)
    
    master.list$model_complete[master.list$id == i] <- TRUE
    
    write.csv(master.list, save.csv.as, row.names = FALSE)
    saveRDS(lm.out, file = file.path(save.models.in, paste0(i,"_lm.rds")))
  }
  
}
