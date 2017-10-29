.PHONY: build push test

TAG:=6

build:
	docker build -t testbed/vim:$(TAG) .

push:
	docker push testbed/vim:$(TAG)

# test: build the base image and example image on top, running tests therein.
DOCKER_BASE_IMAGE:=vim-testbed-base
test:
	docker build -t "$(DOCKER_BASE_IMAGE)" .
	make -C example test
