
NAME=mmbase/tomcat
include ../docker.mk

run: build data  ## run the docker image
	docker run -it -p 8080:8080 -p 8000:8000 -p 3000:3000 -v $(PWD)/data:/data $(NAME):$(VERSION)




