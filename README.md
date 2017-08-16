# MMSD_trends

## Workflow

Generally can be run:

```
source("1_get_raw_data/src/get_siteinfo.R")
source("2_clean_sample/src/clean_sample_data.R")
source("3_filter/src/filter_samples.R")
source("4_discharge/src/get_flow.R")
source("5_merge/src/merge_sample_flow.R")
source("6_model/src/run_models.R")
```

What's going on?

### 1_get_raw_data

Raw data files are saved on a private S3 bucket. The function in this step assumes you have a "default" credential set up on your computer. Then, the files are simply downloaded to the "1_get_raw_data/out" folder.

### 2_clean_sample

This step opens the raw data, converts the data to numbers + remarks (because the data is coming in like "< 0.5" for example).

### 3_filter

This step associates the MMSD sites with USGS gages, and filters out sites that don't have enough data. 

TODO: some sites on the raw data Excel file don't have USGS flow sites properly assigned. When we update that file, we'll want to only get new data.

### 4_discharge

This step gets the discharge data using `dataRetrieval`. 

TODO: only get new data!

### 5_merge

This step merges the water-quality data with the flow data and makes `EGRET`'s "eList" objects. A "master_list" csv is saved at every step to watch the progress. Also, a pdf of the data is create to check how it all looks.

TODO: make smarter using that list.

### 6_model

This step runs a simple `lm` model on the data. It also outputs a progress.csv file. A pdf of all the model output in basic `lm` plots is output.

## Disclaimer


This software is in the public domain because it contains materials that originally came from the U.S. Geological Survey (USGS), an agency of the United States Department of Interior. For more information, see the official USGS copyright policy at <https://www.usgs.gov/visual-id/credit_usgs.html#copyright>

Although this software program has been used by the USGS, no warranty, expressed or implied, is made by the USGS or the U.S. Government as to the accuracy and functioning of the program and related program material nor shall the fact of distribution constitute any such warranty, and no responsibility is assumed by the USGS in connection therewith.

This software is provided "AS IS."

[![CC0](http://i.creativecommons.org/p/zero/1.0/88x31.png)](http://creativecommons.org/publicdomain/zero/1.0/)
