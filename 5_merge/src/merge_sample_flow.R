library(EGRET)
library(dplyr)
library(yaml)

merge_sample_flow <- function(merge.config, all.samples, site.summary, all.flow){
  
  config.args <- yaml.load_file(merge.config)
  
  params <- data.frame(config.args$params, stringsAsFactors = FALSE)

  
  master_list <- data.frame(id = character(),
                            complete = logical(),
                            missing_all_sample = logical(),
                            missing_all_flow = logical(),
                            stringsAsFactors = FALSE)
  
  data.out <- list(eList = list(), master.list = data.frame(stringsAsFactors = FALSE))
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
      data.out$master.list <- master_list
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
        data.out$master.list <- master_list
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
        data.out$master.list <- master_list
        next
      }
      
      e.name <- paste0(i,"_",params$paramShortName[j])
      data.out[['eList']][[e.name]] <- mergeReport(INFO,Daily,Sample,verbose = FALSE)
      
      master_list <- bind_rows(master_list, 
                               data.frame(id = paste(i, params$paramShortName[j], sep="_"),
                                          complete = TRUE,
                                          missing_all_sample = FALSE,
                                          missing_all_flow = FALSE,
                                          stringsAsFactors = FALSE))
      
    }
    
  }
  data.out$master.list <- master_list
  return(data.out)
}

as.progress_csv <- function(merged.sample.flow, file.name){
  progress <- merged.sample.flow$master.list
  write.csv(progress, file = file.name, row.names = FALSE)
}

as.eLists <- function(merged.sample.flow){
  return(merged.sample.flow$eList)
}

plot_eLists <- function(eLists, save.pdf.as='5_merge/doc/data_checks.pdf') {
  
  graphics.off()
  pdf(file = save.pdf.as)
  for(eList in eLists){
    plot(eList)
  }
  dev.off()
  
}
