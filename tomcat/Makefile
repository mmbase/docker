
NAME=mmbase/tomcat

docker: Dockerfile
	docker build -t $(NAME):latest .
	touch $@

push:
	docker push $(NAME):latest

explore: docker
	docker run -it --entrypoint bash $(NAME)

root: docker
	docker run -it --entrypoint bash -u root $(NAME)

run: docker
	docker run -p 8080:8080 $(NAME)

example:
	docker run -p 8080:8080 $(NAME)


clean:
	rm docker
