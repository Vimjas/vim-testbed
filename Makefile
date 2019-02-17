TAG:=11

build:
	docker build -t testbed/vim:$(TAG) .

push:
	docker push testbed/vim:$(TAG)

update_latest:
	docker tag testbed/vim:$(TAG) testbed/vim:latest
	docker push testbed/vim:latest

# test: build the base image and example image on top, running tests therein.
build_example_for_test: build
	docker tag testbed/vim:$(TAG) vim-testbed-base
	make -C example build

test_example:
	make -C example test

test: build_example_for_test test_example

.PHONY: build push update_latest build_example_for_test test_example test
