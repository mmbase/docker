
.INTERMEDIATE: %.md %.xml README.md
.PHONY: explore build
VERSION?=latest
# REGISTRY is passed as a build argument when using 'build' target. Default it is ghcr.io/ in the images
REGISTRY?=
NAME?=UNSET
PORTS?=
#REGISTRY=ghcr.io/


help:     ## Show this help.
	@sed -n 's/^##//p' $(MAKEFILE_LIST)
	@grep -h -E '^[/%a-zA-Z0-9._-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


build_push: Dockerfile ../docker.mk  ## build docker image and push (multiplatform build)
	docker buildx build --platform=linux/amd64,linux/arm64 -t $(NAME):$(VERSION) . --push
	#docker build -t $(NAME):$(VERSION) .
	touch $@

build: Dockerfile ../docker.mk  ## build docker image, no push, current platform. Handy for local testing
	docker build --build-arg REGISTRY=$(REGISTRY) -t $(NAME):$(VERSION) .


#https://github.com/christian-korneck/docker-pushrm
pushrm: README.md docker  ## Update the README.md on dockerhub.
	export DESCRIPTION=`docker inspect $(NAME) --format '{{ index .Config.Labels "org.mmbase.description"}}'` ; \
	docker pushrm  $(NAME):latest --file $< -s "$${DESCRIPTION}"
	touch $@

%.xml: %.adoc
	asciidoc -b docbook $<

%.md: %.xml  ## create markdown from docbook
	pandoc -f docbook -t gfm $< -o $@

explore: build work data  ## explore the docker image
	docker run -it --entrypoint bash -v $(PWD)/work:/work  -v $(PWD)/data:/data $(NAME):$(VERSION)

run: build work data  ## run the docker image
	docker run -it $(PORTS) -v $(PWD)/work:/work  -v $(PWD)/data:/data $(NAME):$(VERSION)

explore_published: work data  ## explore the docker image from ghcr.io
	docker run -it --entrypoint bash -v $(PWD)/work:/work  -v $(PWD)/data:/data ghcr.io/$(NAME):$(VERSION)

root: build  work data ## explore the docker image as root
	docker run -it --entrypoint bash -u root -v $(PWD)/work:/work -v $(PWD)/data:/data $(NAME):$(VERSION)

work:
	mkdir -p $@

data:
	mkdir -p $@

clean: ## clean
	rm -f docker pushrm pushimage README.xml README.md
