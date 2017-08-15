library(EGRET)
library(dplyr)

make_eList <- function(){
  
  save.path <- "cached_data"
  sample.file <- "sample_data.rds"
  flow.file <- "all_flow.rds"
  sites.file <- "summary_sites.rds"
  model.path <- "cached_data/model"
  
  pdf(file = file.path(save.path,"data_check.pdf"))
  
  params <- data.frame(name = c("BOD20 (mg/L)",                    
              "BOD5 (mg/L)",                      
              "FC (MPN/100mL)",                   
              "NH3 (mg/L)",                       
              "TP (mg/L)",                        
              "Total Suspended Solids (mg/L)"),
              paramShortName = c("BOD20",                    
                                 "BOD5",                      
                                 "FC",                   
                                 "NH3",                       
                                 "TP",                        
                                 "Total Suspended Solids"),
              param.units = c("mg/L",                    
                              "mg/L",                      
                              "MPN/100mL",                   
                              "mg/L",                       
                              "mg/L",                        
                              "mg/L"),
              stringsAsFactors = FALSE)
  
  all.samples <- readRDS(file.path(save.path,sample.file))
  all.flow <- readRDS(file.path(save.path,flow.file))
  site.summary <- readRDS(file.path(save.path,sites.file))
  
  site.summary <- site.summary %>%
    rename(siteID = `USGS Flow Site to use`) %>%
    filter(count > 400) %>%
    filter(!is.na(siteID)) %>%
    arrange(desc(count))
  
  dir.create(file.path(model.path),recursive = TRUE, showWarnings = FALSE)
  
  for(i in site.summary$SITE){
    sample.data <- filter(all.samples, SITE == i)
    flow_site <- site.summary$siteID[which(site.summary$SITE == i)]
    flow <- filter(all.flow, site_no == flow_site)
    if(nrow(flow) == 0){next}
    names(flow) <- c('agency', 'site', 'dateTime', 'value', 'code')
    
    Daily <- populateDaily(flow, 35.314667,verbose = FALSE)
    
    for(j in seq_len(nrow(params))){
      
      sample.sub <- sample.data[,c("DATE",params$name[j],
                                   paste("rmk",params$name[j],sep = "_"))]
      names(sample.sub) <- c("dateTime", "value", "code")
      sample.sub <- sample.sub[,c("dateTime", "code","value")]
      sample.sub <- sample.sub[!is.na(sample.sub$value),]
      if(nrow(sample.sub) == 0){next}
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
      
      if(nrow(Sample) == 0){next}

      eList <- mergeReport(INFO,Daily,Sample,verbose = FALSE)
      saveRDS(eList, file = file.path(model.path,paste0(params$paramShortName[j],"_",i,".rds")))
      
      plot(eList)
      
    }
    
  }
  
  dev.off()
  
}

make_eList()