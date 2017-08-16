library(yaml)

run_models <- function(model.config){
  config.args <- yaml.load_file(model.config)
  
  fetch.args <- config.args$fetch.args
  save.args <- config.args$save.args
  
  master.list <- read.csv(file.path(fetch.args[["data.path"]],fetch.args[["progress.file"]]),stringsAsFactors = FALSE)
  
  master.list$model_complete <- FALSE
  
  dir.create(file.path(save.args[["save.path"]]),recursive = TRUE, showWarnings = FALSE)
  write.csv(master.list, file.path(save.args[["save.path"]],save.args[["save.file"]]),row.names = FALSE)
  
  pdf(file = file.path(save.args[["save.path"]],save.args[["save.graph"]]))
  
  for(i in master.list$id[master.list$complete]){
    eList <- readRDS(file.path(fetch.args[["data.path"]],paste0(i,".rds")))
    Sample <- getSample(eList)
    
    lm.out <- lm(formula = log(ConcAve) ~ DecYear+LogQ+SinDY+CosDY,data=Sample)
    par(mfrow=c(2,2), oma = c(1,1,1,1))
    for(j in 1:4){
      plot(lm.out, which=j)
      title(i)
    }
    master.list$model_complete[master.list$id == i] <- TRUE
    
    write.csv(master.list, file.path(save.args[["save.path"]],save.args[["save.file"]]),row.names = FALSE)
    saveRDS(lm.out, file = file.path(save.args[["save.path"]],paste0(i,"_lm.rds")))
  }
  
  dev.off()
  
}

run_models(model.config = "6_model/in/model_config.yaml")