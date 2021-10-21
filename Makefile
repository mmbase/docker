#SUBDIRS := $(wildcard */.)
SUBDIRS := env tomcat example
TOPTARGETS := push clean docker build


$(TOPTARGETS): $(SUBDIRS)
$(SUBDIRS):
	$(MAKE) -C $@ $(MAKECMDGOALS)

.PHONY: $(TOPTARGETS) $(SUBDIRS)
