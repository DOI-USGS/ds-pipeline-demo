library(aws.s3)
library(aws.signature)
library(yaml)

# This script downloads the site summary info from AWS
# It saves it as-is
# The configuration is in 1a_siteinfo/in

get_siteinfo <- function(siteinfo.config, file.data){
  
  config.args <- yaml.load_file(siteinfo.config)
  fetch.args <- config.args$fetch.args
  
  s3Profile <- fetch.args[['s3Profile']]
  s3Path <- fetch.args[['s3Path']]
  bucket <- fetch.args[['bucket']]
  
  message("Downloading from S3")
  use_credentials(profile = s3Profile)
  save_object(object = file.path(s3Path, basename(file.data)), 
              bucket = bucket,
              file = file.data)

}
