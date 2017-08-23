library(EGRET)
library(dplyr)
library(yaml)

merge_sample_flow <- function(merge_config){
  
  config.args <- yaml.load_file(merge_config)
  
  fetch.args <- config.args$fetch.args
  save.args <- config.args$save.args
  explore.args <- config.args$explore.args
  log.args <- config.args$log.args
  
  params <- data.frame(config.args$params, stringsAsFactors = FALSE)

  all.samples <- readRDS(file.path(fetch.args[["sample.path"]],fetch.args[["sample.file"]]))
  all.flow <- readRDS(file.path(fetch.args[["flow.path"]],fetch.args[["flow.file"]]))
  site.summary <- readRDS(file.path(fetch.args[["site.path"]],fetch.args[["site.file"]]))
  

  dir.create(file.path(log.args[["path"]]),recursive = TRUE, showWarnings = FALSE)
  dir.create(file.path(explore.args[["path"]]),recursive = TRUE, showWarnings = FALSE)
  dir.create(file.path(save.args[["path"]]),recursive = TRUE, showWarnings = FALSE)
  
  pdf(file = file.path(explore.args[["path"]],explore.args[["graph"]]))
  
  master_list <- data.frame(id = character(),
                            complete = logical(),
                            missing_all_sample = logical(),
                            missing_all_flow = logical(),
                            stringsAsFactors = FALSE)
  
  
  for(i in site.summary$SITE){
    sample.data <- filter(all.samples, SITE == i)
    flow_site <- site.summary$siteID[which(site.summary$SITE == i)]
    flow <- filter(all.flow, site_no == flow_site)
    if(nrow(flow) == 0){
      master_list <- bind_rows(master_list, 
                               data.frame(id = paste(i, params$paramShortName, sep="_"),
                                          complete = FALSE,
                                          missing_all_sample = FALSE,
                                          missing_all_flow = TRUE,
                                          stringsAsFactors = FALSE))
      write.csv(master_list, file = file.path(log.args[["path"]],log.args[["file"]]),row.names = FALSE)
      next
    }
    names(flow) <- c('agency', 'site', 'dateTime', 'value', 'code')
    
    Daily <- populateDaily(flow, 35.314667,verbose = FALSE)
    
    for(j in seq_len(nrow(params))){
      
      id <- paste0(i,"_",params$paramShortName[j])
      
      sample.sub <- sample.data[,c("DATE",params$name[j],
                                   paste("rmk",params$name[j],sep = "_"))]
      names(sample.sub) <- c("dateTime", "value", "code")
      sample.sub <- sample.sub[,c("dateTime", "code","value")]
      sample.sub <- sample.sub[!is.na(sample.sub$value),]
      if(nrow(sample.sub) == 0){
        master_list <- bind_rows(master_list, 
                                 data.frame(id = id,
                                            complete = FALSE,
                                            missing_all_sample = TRUE,
                                            missing_all_flow = FALSE,
                                            stringsAsFactors = FALSE))
        write.csv(master_list, file = file.path(log.args[["path"]],log.args[["file"]]),row.names = FALSE)
        next
      }
      compressedData <- compressData(sample.sub, verbose=FALSE)
      Sample <- populateSampleColumns(compressedData)
      INFO <- data.frame(paramShortName = params$paramShortName[j],
                         param.units = params$param.units[j],
                         shortName = i,
                         constitAbbrev = id,
                         staAbbrev = i,
                         paStart = 10,
                         paLong = 12,
                         stringsAsFactors = FALSE)
      
      Sample <- filter(Sample, Date %in% Daily$Date)
      
      if(nrow(Sample) < config.args$checks[["min.samples"]]){
        master_list <- bind_rows(master_list, 
                                 data.frame(id = id,
                                            complete = FALSE,
                                            missing_all_sample = TRUE,
                                            missing_all_flow = FALSE,
                                            stringsAsFactors = FALSE))
        write.csv(master_list, file = file.path(log.args[["path"]],log.args[["file"]]),row.names = FALSE)
        next
      }
      
      eList <- mergeReport(INFO,Daily,Sample,verbose = FALSE)
      
      saveRDS(eList, file = file.path(save.args[["path"]],paste0(id,".rds")))
      
      plot(eList)
      
      master_list <- bind_rows(master_list, 
                               data.frame(id = id,
                                          complete = TRUE,
                                          missing_all_sample = FALSE,
                                          missing_all_flow = FALSE,
                                          stringsAsFactors = FALSE))
      write.csv(master_list, file = file.path(log.args[["path"]],log.args[["file"]]),row.names = FALSE)
    }
    
  }
  
  dev.off()
  
  

}

merge_sample_flow(merge_config = "5_merge/in/merge_config.yaml")