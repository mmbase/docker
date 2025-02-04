
.INTERMEDIATE: %.md %.xml README.md
.PHONY: explore
VERSION=dev

docker: Dockerfile ../docker.mk
	#docker buildx build --platform=linux/amd64,linux/arm64 -t $(NAME):$(VERSION) . --push
	docker build -t $(NAME):$(VERSION) .
	touch $@

push: pushimage pushrm

pushimage: docker
	docker buildx push $(NAME):$(VERSION)
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

explore: docker
	docker run -it --entrypoint bash $(NAME)

root: docker
	docker run -it --entrypoint bash -u root $(NAME)

clean:
	rm -f docker pushrm pushimage README.xml README.md
