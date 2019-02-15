.PHONY: build push test

TAG:=12

build:
	docker build -t testbed/vim:$(TAG) .

push:
	docker push testbed/vim:$(TAG)

update_latest:
	docker tag testbed/vim:$(TAG) testbed/vim:latest
	docker push testbed/vim:latest

# test: build the base image and example image on top, running tests therein.
DOCKER_BASE_IMAGE:=vim-testbed-base
test:
	docker build -t "$(DOCKER_BASE_IMAGE)" .
	make -C example test
