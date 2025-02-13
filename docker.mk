
.INTERMEDIATE: %.md %.xml README.md
.PHONY: explore
VERSION=dev


help:     ## Show this help.
	@sed -n 's/^##//p' $(MAKEFILE_LIST)
	@grep -h -E '^[/%a-zA-Z0-9._-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


build_push: Dockerfile ../docker.mk  ## build docker image and push
	docker buildx build --platform=linux/amd64,linux/arm64 -t $(NAME):$(VERSION) . --push
	#docker build -t $(NAME):$(VERSION) .
	touch $@

build: Dockerfile ../docker.mk  ## build docker image
	docker build -t $(NAME):$(VERSION) .
	touch $@


#https://github.com/christian-korneck/docker-pushrm
pushrm: README.md docker
	export DESCRIPTION=`docker inspect $(NAME) --format '{{ index .Config.Labels "org.mmbase.description"}}'` ; \
	docker pushrm  $(NAME):latest --file $< -s "$${DESCRIPTION}"
	touch $@

%.xml: %.adoc
	asciidoc -b docbook $<

%.md: %.xml
	pandoc -f docbook -t gfm $< -o $@

explore: build  ## explore the docker image
	mkdir -p data
	docker run -it --entrypoint bash -v $(PWD)/data:/data $(NAME):$(VERSION)

root: build  ## explore the docker image as root
	mkdir -p data
	docker run -it --entrypoint bash -u root -v $(PWD)/data:/data $(NAME):$(VERSION)

clean:
	rm -f docker pushrm pushimage README.xml README.md
