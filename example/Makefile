
NAME=mmbase/example-webapp

docker: Dockerfile
	docker build -t $(NAME):latest .
	touch $@

push:
	docker push $(NAME):latest


run: docker
	docker run --name mmbase-example-webapp -p 8080:8080 $(NAME)


clean:
	rm docker
