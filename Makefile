.PHONY: build push test

DOCKER_REPO_BASE:=testbed/vim
DOCKER_REPO_VIMS_DEFAULT:=testbed/vim-default
DOCKER_REPO_VIMS_LATEST:=testbed/vim-latest

TAG:=11

build:
	docker build -t $(DOCKER_REPO_BASE):$(TAG) .
push:
	docker push $(DOCKER_REPO_BASE):$(TAG)

build_default:
	docker build -f Dockerfile.default -t $(DOCKER_REPO_VIMS_DEFAULT) .
push_default:
	docker push $(DOCKER_REPO_VIMS_DEFAULT)

update_latest:
	docker tag testbed/vim:$(TAG) testbed/vim:latest
	docker push testbed/vim:latest

build_latest:
	docker build -f Dockerfile.latest -t $(DOCKER_REPO_VIMS_LATEST) .
push_latest:
	docker push $(DOCKER_REPO_VIMS_LATEST)

# test: build the base image and example image on top, running tests therein.
DOCKER_BASE_IMAGE:=vim-testbed-base
test:
	docker build -t "$(DOCKER_BASE_IMAGE)" .
	make -C example test
