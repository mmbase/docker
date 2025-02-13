
NAME=mmbase/tomcat
include ../docker.mk


run: build  ## run the docker image
	mkdir -p data
	docker run -p 8080:8080 -v $(PWD)/data:/data $(NAME):$(VERSION)




