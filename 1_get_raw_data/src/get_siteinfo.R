library(aws.s3)
library(aws.signature)
library(yaml)

# This script downloads the site summary info from AWS
# It saves it as-is
# The configuration is in 1a_siteinfo/in

get_siteinfo <- function(siteinfo.config){
  
  config.args <- yaml.load_file(siteinfo.config)
  
  fetch.args <- config.args$fetch.args
  save.args <- config.args$save.args
  
  s3Profile <- fetch.args[['s3Profile']]
  s3Path <- fetch.args[['s3Path']]
  bucket <- fetch.args[['bucket']]
  file.data <- fetch.args[['file.data.summary']]
  
  save.path <- save.args[['save.path']]
  
  dir.create(file.path(save.path),recursive = TRUE, showWarnings = FALSE)
  
  message("Downloading from S3")
  use_credentials(profile = s3Profile)
  save_object(object = file.path(s3Path,file.data), 
              bucket = bucket,
              file = file.path(save.path,file.data))

}

message('sourced get_siteinfo.R')

# get_siteinfo(siteinfo.config = "1_get_raw_data/in/siteinfo_config.yaml")
# get_siteinfo(siteinfo.config = "1_get_raw_data/in/sample_config.yaml")
