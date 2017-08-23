library(EGRET)
library(dplyr)
library(yaml)

merge_sample_flow <- function(merge.config, sample.file, site.file, flow.file, save.csv.as){
  
  config.args <- yaml.load_file(merge.config)
  
  params <- data.frame(config.args$params, stringsAsFactors = FALSE)

  all.samples <- readRDS(sample.file)
  all.flow <- readRDS(flow.file)
  site.summary <- readRDS(site.file)
  
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
      write.csv(master_list, file = save.csv.as,row.names = FALSE)
      next
    }
    names(flow) <- c('agency', 'site', 'dateTime', 'value', 'code')
    
    Daily <- populateDaily(flow, 35.314667,verbose = FALSE)
    
    for(j in seq_len(nrow(params))){
      
      sample.sub <- sample.data[,c("DATE",params$name[j],
                                   paste("rmk",params$name[j],sep = "_"))]
      names(sample.sub) <- c("dateTime", "value", "code")
      sample.sub <- sample.sub[,c("dateTime", "code","value")]
      sample.sub <- sample.sub[!is.na(sample.sub$value),]
      if(nrow(sample.sub) == 0){
        master_list <- bind_rows(master_list, 
                                 data.frame(id = paste(i, params$paramShortName[j], sep="_"),
                                            complete = FALSE,
                                            missing_all_sample = TRUE,
                                            missing_all_flow = FALSE,
                                            stringsAsFactors = FALSE))
        write.csv(master_list, file = save.csv.as,row.names = FALSE)
        next
      }
      compressedData <- compressData(sample.sub, verbose=FALSE)
      Sample <- populateSampleColumns(compressedData)
      INFO <- data.frame(paramShortName = params$paramShortName[j],
                         param.units = params$param.units[j],
                         shortName = i,
                         constitAbbrev = paste(params$paramShortName[j],i,sep="_"),
                         staAbbrev = i,
                         paStart = 10,
                         paLong = 12,
                         stringsAsFactors = FALSE)
      
      Sample <- filter(Sample, Date %in% Daily$Date)
      
      if(nrow(Sample) < config.args$checks[["min.samples"]]){
        master_list <- bind_rows(master_list, 
                                 data.frame(id = paste(i, params$paramShortName[j], sep="_"),
                                            complete = FALSE,
                                            missing_all_sample = TRUE,
                                            missing_all_flow = FALSE,
                                            stringsAsFactors = FALSE))
        write.csv(master_list, file = save.csv.as,row.names = FALSE)
        next
      }
      
      eList <- mergeReport(INFO,Daily,Sample,verbose = FALSE)
      saveRDS(eList, file = file.path(config.args$save.args[["save.path"]],paste0(i,"_",params$paramShortName[j],".rds")))
      
      
      master_list <- bind_rows(master_list, 
                               data.frame(id = paste(i, params$paramShortName[j], sep="_"),
                                          complete = TRUE,
                                          missing_all_sample = FALSE,
                                          missing_all_flow = FALSE,
                                          stringsAsFactors = FALSE))
      write.csv(master_list, file = save.csv.as,row.names = FALSE)
    }
    
  }
}

plot_models <- function(eList.dir='5_merge/out', save.pdf.as='5_merge/doc/data_checks.pdf') {
  
  eList.files <- dir(eList.dir, pattern='.rds', full.names=TRUE)
  
  graphics.off()
  pdf(file = save.pdf.as)
  for(eList.file in eList.files){
    eList <- readRDS(eList.file)
    plot(eList)
  }
  dev.off()
  
}
