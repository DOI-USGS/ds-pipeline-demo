library(EGRET)
library(yaml)

run_models <- function(eList.csv, eLists, save.csv.as, save.models.in){
  
  master.list <- read.csv(eList.csv, stringsAsFactors = FALSE)

  master.list$model_complete <- FALSE
  master.list$model_path <- NA_character_
  
  for(i in master.list$id[master.list$complete]){
    eList <- eLists[[i]]
    Sample <- getSample(eList)
    row.j <- master.list$id == i
    lm.out <- lm(formula = log(ConcAve) ~ DecYear+LogQ+SinDY+CosDY,data=Sample)
    
    master.list$model_complete[row.j] <- TRUE
    master.list$model_path[row.j] <- file.path(save.models.in, paste0(i,"_lm.rds"))
    
    write.csv(master.list, save.csv.as, row.names = FALSE)
    saveRDS(lm.out, file = master.list$model_path[row.j])
  }
  
}
