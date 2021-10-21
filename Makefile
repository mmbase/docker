#SUBDIRS := $(wildcard */.)
SUBDIRS := env tomcat example build
TOPTARGETS := push clean docker


$(TOPTARGETS): $(SUBDIRS)
$(SUBDIRS):
	$(MAKE) -C $@ $(MAKECMDGOALS)

.PHONY: $(TOPTARGETS) $(SUBDIRS)
