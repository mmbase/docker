
NAME=mmbase/env

docker:
	docker build -t $(NAME):latest .

push:
	docker push $(NAME):latest
