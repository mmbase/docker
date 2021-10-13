
NAME=mmbase/env

docker: Dockerfile
	docker build -t $(NAME):latest .
	touch $@

push:
	docker push $(NAME):latest

explore: docker
	docker run -it $(NAME) bash

clean:
	rm docker
