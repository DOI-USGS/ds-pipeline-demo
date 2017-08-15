
run_models <- function(){

  model.path <- "cached_data/model"
  model.output <- "cached_data/model/output"
  save.path <- "cached_data"
  master.file <- "master_list.rds"
  
  master.list <- readRDS(file.path(save.path,master.file))
  
  pdf(file = file.path(save.path,"model_check.pdf"))
  
  dir.create(file.path(model.output),recursive = TRUE, showWarnings = FALSE)
  
  for(i in master.list$id[master.list$complete]){
    eList <- readRDS(file.path(model.path,paste0(i,".rds")))
    Sample <- getSample(eList)
    
    lm.out <- lm(formula = log(ConcAve) ~ DecYear+LogQ+SinDY+CosDY,data=Sample)
    par(mfrow=c(2,2), oma = c(1,1,1,1))
    for(j in 1:4){
      plot(lm.out, which=j)
      title(i)
    }
    saveRDS(lm.out, file = file.path(model.output,paste0(i,"_lm.rds")))
  }
  
  dev.off()
}

run_models()