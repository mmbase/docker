
.INTERMEDIATE: %.md %.xml README.md
.PHONY: explore

docker: Dockerfile
	docker build -t $(NAME):latest .
	touch $@

push: pushimage pushrm

pushimage: docker
	docker push $(NAME):latest
	touch $@

#https://github.com/christian-korneck/docker-pushrm
pushrm: README.md docker
	export DESCRIPTION=`docker inspect $(NAME) --format '{{ index .Config.Labels "org.mmbase.image.description"}}'` ; \
	docker pushrm -D $(NAME):latest --file $< -s "$${DESCRIPTION}"
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
