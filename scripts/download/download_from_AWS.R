library(aws.s3)
library(aws.signature)

s3Profile <- 'default'
bucket <- 'ds-pipeline'

file.data <- "USGS_WQ_DATA_02-16.xlsx"
file.data.summary <- "SampleGanttCharts_wRanks.xlsx"

s3Path <- 'MMSD'
save.path <- "cached_data"
dir.create(file.path(save.path),recursive = TRUE, showWarnings = FALSE)

message("Downloading from S3")
use_credentials(profile = s3Profile)
save_object(object = file.path(s3Path,file.data), 
            bucket = bucket,
            file = file.path(save.path,file.data))
save_object(object = file.path(s3Path,file.data.summary), 
            bucket = bucket,
            file = file.path(save.path,file.data.summary))
