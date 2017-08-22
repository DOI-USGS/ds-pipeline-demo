# Macros and functions to share across makefiles

# These macros make it prettier to call R by leveraging a known project structure.
# All .R files in the /src/ directory source() calls

## EXAMPLES ##

# These macros separate the target's dependencies into categories by dir & extension
# (the $@ target comes with make; see https://www.gnu.org/software/make/manual/html_node/Automatic-Variables.html)
eg_dirvars : 1_get_raw_data/src/get_siteinfo.R 1_get_raw_data/cfg/sample_config.yaml 1_get_raw_data/out/README.md
	@echo 'target: $@'
	@echo 'SRC: ${SRC}'
	@echo 'RSC: ${RSC}'
	@echo 'CFG: ${CFG}'
	@echo 'OUT: ${OUT}'

# A low-text way to call Rscript and load R script dependencies all at once
eg_rscript : 1_get_raw_data/src/*.R
	${RSCRIPT} -e '1+2'

eg_addlog : 1_get_raw_data/src/*.R
	${RSCRIPT} -e 'print(1+2); message ("hi"); stop("oops")' ${ADDLOG}


## DEFINITIONS ##

# rvector turns space-separated list of unquoted strings 
# into comma-separated list of quoted strings wrapped in c()
dquote := "
comma := ,
null :=
space := $(null) $(null)
vecpre := c(
vecpost := )
define rvector
$(addprefix $(vecpre),$(addsuffix $(vecpost),$(subst $(space),$(comma),$(addprefix $(dquote),$(addsuffix $(dquote),$(strip $(1)))))))
endef

CFG=$(call rvector,$(filter $(wildcard */cfg/*.*),$^))
SRC=$(call rvector,$(filter $(wildcard */src/*.*),$^))
RSC=$(call rvector,$(filter $(wildcard */src/*.R),$^))
OUT=$(call rvector,$(filter $(wildcard */out/*.*),$^))

# Call R via ${RSCRIPT} to avoid typing all this. Automatically loads any dependencies 
RSCRIPT=Rscript -e 'x <- lapply(${RSC}, source)'

# ${ADDLOG} at the end of an Rscript call directs both stdout and stderr
# to a file named like the target but with the .Rlog suffix
ADDLOG=-e 'sessionInfo()' > $(basename $@).Rlog 2>&1 

# Tips

# prefix a command with @ to avoid echoing it, e.g., '	@echo "hi"' only prints 'hi', not the 'echo' line
#	@echo 'SRC: ${SRC}'
#	@echo 'SRC: $(call rvector,${SRC})'
