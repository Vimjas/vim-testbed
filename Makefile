.PHONY: build test

build:
	docker build -t "testbed/vim" .

# test: build the base image and then the example image on top, running tests
# therein.
DOCKER_BASE_IMAGE:=vim-testbed-base
DOCKER_EXAMPLE_IMAGE:=vim-testbed-example
test:
	docker build -t "$(DOCKER_BASE_IMAGE)" . \
	  && cd example \
	  && docker build -f Dockerfile.tests -t "$(DOCKER_EXAMPLE_IMAGE)" . \
	  && make test IMAGE=$(DOCKER_EXAMPLE_IMAGE)
