## DEFINITIONS - CACHING & CACHE SHARING ##

lib/s3_inventory.tsv :\
		lib/s3.R lib/s3_config.yaml
	${RSCRIPT}\
		-e 'inventory_s3()'\
		-e 'warnings()' -e 'devtools::session_info()' > $(subst lib,lib/log,$(subst .tsv,.s3log,$@)) 2>&1

# Generic rule for making a status indicator file based on the presence & timestamp of a corresponding file in the cache
# [ -e x ] tests whether file x exists
# $(shell date -r ...) gets the timestamp of a file
# > writes the text on the left to a file on the right
# touch -d changes the timestamp of a file to match a text date
# the sequence from if to fi needs to be a single make line, hence the \'s at the ends of lines
%.s3fromcache :\
		lib/s3_inventory.tsv\
		lib/s3.R lib/s3_config.yaml
	${RSCRIPT} -e 'make_s3_indicator(file.name="$(subst .s3fromcache,,$@)")' > lib/log/last_s3fromcache.Rlog 2>&1

# Generic rule for making a status indicator file based on confidence that a corresponding cache file exists and was created at a similar time. This is reasonable if checking remotely is more onerous than the likelihood*consequence of occasionally being wrong, which might be the case for S3...experience will tell
%.s3bytrust :
	@echo "made $(subst .s3bytrust,.s3,$@) on trust that $(subst .s3bytrust,,$@) is in cache"
	@${DATETIME} > $(subst .s3bytrust,.s3,$@)

# Macro for attaching to the end of an RSCRIPT expression. posts the data file to S3, creates an .s3 status indictor file, and updates the data file's timestamp so make understands that it's up to date relative to the status file. We could switch the updating from bytrust to fromcache, at the cost of making more status check calls to S3.
POSTS3=-e 'post_s3(file.name="$(subst .s3,,$@)", s3.config="lib/s3_config.yaml")'\
		${ADDLOG};\
	@make -s $@bytrust;\
	touch $(subst .s3,,$@)

# Generic rule for downloading a data file from S3, which will only be attempted if the corresponding status file already exists. A data file is out of date if it's older than its .s3 indicator file. With a shared-cache project, 'making' a data file actually means either (1) pulling the data file from the cache or (2) making the indicator file, where (2) always has a byproduct of recomputing the data file and posting it to the cache. If we call `make datafile` and #2 applies, then it's worth a timestamp check after the .s3 dependency is built and before trying the download, because the data fila may already exist locally as a side effect of building the .s3 indicator file. `make` won't have noticed for us, so we need to check ourselves.
# [ x -ot y ] tests whether x is older than y to within ~1 second
# [... -o ! -e x ] adds an OR test for whether x is a missing file
% : %.s3\
		lib/s3.R lib/s3_config.yaml
	@if [ $@ -ot $@.s3 -o ! -e $@ ]; then\
		${RSCRIPT}\
		-e 'get_s3(file.name="$@", s3.config="lib/s3_config.yaml")'\
		-e 'warnings()' -e 'devtools::session_info()' > $(dir $(patsubst %/,%,$(dir $@)))log/$(notdir $(basename $@)).s3log 2>&1
		touch -d "$(shell cat $@.s3)" $@;\
	else\
		echo "$@ is available locally";\
	fi;
