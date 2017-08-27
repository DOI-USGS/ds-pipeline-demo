# These functions download or upload any file you want, using the
# project-specific configuration for an S3 bucket and subfolder

library(aws.signature)
library(aws.s3)
library(yaml)
library(dplyr)

get_s3 <- function(file.name, s3.config="lib/s3_config.yaml") {
  
  message("Downloading ", file.name, " from S3")
  s3_config <- yaml.load_file(s3.config)
  use_credentials(profile = s3_config$s3Profile)
  save_object(object = file.path(s3_config$s3Path, basename(file.name)), 
              bucket = s3_config$bucket,
              file = file.name)
  
}

post_s3 <- function(file.name, s3.config="lib/s3_config.yaml") {
  
  message("Uploading ", file.name, " to S3")
  s3_config <- yaml.load_file(s3.config)
  use_credentials(profile = s3_config$s3Profile)
  put_object(file = file.name,
             object = file.path(s3_config$s3Path, basename(file.name)), 
             bucket = s3_config$bucket)
  
}

list_s3 <- function(s3.config="lib/s3_config.yaml") {
  
  message("Listing project files on S3")
  s3_config <- yaml.load_file(s3.config)
  use_credentials(profile = s3_config$s3Profile)
  bucket_df <- aws.s3::get_bucket_df(bucket=s3_config$bucket)
  dplyr::filter(bucket_df, grepl(sprintf("^%s/.+", s3_config$s3Path),Key))
  
}

inventory_s3 <- function(s3.inventory="lib/s3_inventory.tsv", s3.config="lib/s3_config.yaml") {
  
  cache_df <- list_s3()
  write.table(cache_df, file=s3.inventory, sep='\t', row.names=FALSE)
  
}

make_s3_indicator <- function(file.name, s3.inventory="lib/s3_inventory.tsv", s3.config="lib/s3_config.yaml") {
  
  cache_df <- read.table(s3.inventory, header=TRUE, sep='\t', stringsAsFactors=FALSE, colClasses='character')
  s3_config <- yaml.load_file(s3.config)
  cached_file <- dplyr::filter(cache_df, Key==file.path(s3_config$s3Path, basename(file.name)))
  if(nrow(cached_file) != 1) stop(paste0("failed to find exactly 1 cached file named ", file.name))
  
  datestamp <- dplyr::pull(cached_file, LastModified) %>%
    gsub('T',' ',.) %>%
    gsub('.',' +',.,fixed=TRUE) %>%
    gsub('Z','0',.)
  writeLines(datestamp, con=sprintf("%s.s3", file.name))
  
}
