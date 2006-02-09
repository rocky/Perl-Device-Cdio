#=============================================================
# $Id$
#=============================================================
# Invariably there will be folks who just haven't gotten with 
# the program. In fact they may never learn. This file is for them. 
.PHONY: all check

BUILD_TARGETS = build clean code config_data diff dist distcheck distclean \
	distdir distmeta distsign disttest docs fakeinstall help html \
	install manifest ppd ppmdis realclean skipcheck test testcover \
	testdb testpod versioninstall

all: Build
	@echo "We use perl Build.PL here. Don't count on too much, but"
	@echo "I'll try transferring your request."
	perl Build

Build:: Build.PL
	perl Build.PL

$(BUILD_TARGETS): Build
	@echo "We use perl Build.PL here. Don't count on too much, but"
	@echo "I'll try transferring your request."
	perl Build $@

check: Build
	perl Build test
