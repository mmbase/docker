
JV25=25.0.2_10-jdk-noble
JV8=8u482-b08-jdk-noble
JV?=$(JV25)
TAG?=latest-jdk25
REGISTRY?=ghcr.io/


#SUBDIRS := $(wildcard */.)
SUBDIRS := env tomcat build commandserver
TOPTARGETS := build_push build clean docker


$(TOPTARGETS): $(SUBDIRS)  ## Execute target in all subdirectories

$(SUBDIRS):
	$(MAKE) -C $@ $(MAKECMDGOALS) JV=$(JV) TAG=$(TAG) REGISTRY=$(REGISTRY)

.PHONY: $(TOPTARGETS) $(SUBDIRS)

help:   ## Show all target
	@sed -n 's/^##//p' $(MAKEFILE_LIST)
	@grep -h -E '^[/%a-zA-Z0-9._-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
	@echo E.g. Push everything to docker.io:
	@echo "make build_push REGISTRY= JV=$(JV25) TAG=latest-jdk25"
	@echo "make build_push REGISTRY= JV=$(JV8) TAG=latest-jdk8"



pushall8:  ## Push java 8 images to docker.io
	(cd env ;  make build_push REGISTRY JV=$(JV8) TAG=latest-jdk8)
	(cd tomcat ;  make build_push REGISTRY= JV=$(JV8) TAG=latest-jdk8)

pushall25: ## Push java 25 images to docker.io
	(cd env ;  make build_push REGISTRY JV=$(JV25) TAG=latest-jdk8)
	(cd tomcat ;  make build_push REGISTRY= JV=$(JV25) TAG=latest-jdk8)


build8:
	(cd env ;  make build_push REGISTRY= JV=$(JV8) TAG=latest-jdk8)
	(cd tomcat ;  make build REGISTRY= JV=(JV8) TAG=latest-jdk8)
