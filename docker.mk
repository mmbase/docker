
.INTERMEDIATE: %.md %.xml README.md
.PHONY: explore build
#JV?=8u472-b08-jdk-noble
#VERSION?=latest-jdk8
JV?=25.0.1_8-jdk-noble
MAJOR?=25
TAG?=latest-jdk${MAJOR}
# REGISTRY is passed as a build argument when using 'build' target. Default it is ghcr.io/ in the images
REGISTRY?=ghcr.io/
DOCKER?=docker
#DOCKER?=podman
BUILDAH_FORMAT=docker

NAME?=UNSET
PORTS?=

ARGS=--build-arg REGISTRY=$(REGISTRY) \
     --build-arg JAVA_VERSION=$(JV) \
     --build-arg TAG=$(TAG)  \
     --build-arg JAVA_MAJOR=$(MAJOR) \
     --build-arg CI_COMMIT_REF_NAME=$(shell git rev-parse --abbrev-ref HEAD 2>/dev/null) \
     --build-arg CI_COMMIT_SHA=$(shell git rev-parse --verify HEAD 2>/dev/null) \
     --build-arg CI_COMMIT_SHA=$(shell git show -s --format=%cI HEAD 2>/dev/null) \
     --build-arg CI_COMMIT_TITLE="$(shell git log -1 --pretty=%s HEAD 2>/dev/null)"

#REGISTRY=ghcr.io/


help:     ## Show this help.
	@sed -n 's/^##//p' $(MAKEFILE_LIST)
	@grep -h -E '^[/%a-zA-Z0-9._-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


build_push: Dockerfile ../docker.mk  ## build docker image and push (multiplatform build)
	$(DOCKER) buildx build --platform=linux/amd64,linux/arm64 $(ARGS) -t $(REGISTRY)$(NAME):$(TAG) . --push

build: $(DEPS)  ## build docker image, no push, current platform. Handy for local testing
	$(DOCKER) build $(ARGS) -t $(REGISTRY)$(NAME):$(TAG) .


#https://github.com/christian-korneck/docker-pushrm
pushrm: README.md docker  ## Update the README.md on dockerhub.
	export DESCRIPTION=`$(DOCKER) inspect $(NAME) --format '{{ index .Config.Labels "org.mmbase.description"}}'` ; \
	$(DOCKER) pushrm  $(NAME):latest --file $< -s "$${DESCRIPTION}"

%.xml: %.adoc
	asciidoc -b docbook $<

%.md: %.xml  ## create markdown from docbook
	pandoc -f docbook -t gfm $< -o $@

explore: build work data  ## explore the docker image
	$(DOCKER) run -it --entrypoint bash --user $(shell id -u):$(shell id -g) -v $(PWD)/work:/work  -v $(PWD)/data:/data  -v $(HOME)/.m2:/.m2  $(REGISTRY)$(NAME):$(TAG)

run: build work data  ## run the docker image
	$(DOCKER) run -it $(PORTS) -v $(PWD)/work:/work  -v $(PWD)/data:/data  $(REGISTRY)$(NAME):$(TAG)

explore_published: work data  ## explore the docker image from ghcr.io
	$(DOCKER) run -it --entrypoint bash -v $(PWD)/work:/work  -v $(PWD)/data:/data $(REGISTRY)$(NAME):$(TAG)

root: build  work data ## explore the docker image as root
	$(DOCKER) run -it --entrypoint bash -u root -v $(PWD)/work:/work -v $(PWD)/data:/data $(REGISTRY)$(NAME):$(TAG)

work:
	mkdir -p $@

data:
	mkdir -p $@

clean: ## clean
	rm -rf docker pushrm pushimage README.xml README.md target maven-metadata.xml
