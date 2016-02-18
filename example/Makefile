PLUGINS = test/plugins
IMAGE = tweekmonster/ubuntu-vims
DOCKER = docker run -it --rm -v $(PWD):/testplugin -v $(PWD)/test:/home "$(IMAGE)"

test-setup:
	mkdir -p $(PLUGINS)
	docker pull tweekmonster/ubuntu-vims
	cd $(PLUGINS) && git clone https://github.com/junegunn/vader.vim.git

test:
	 $(DOCKER) vim-precise '+Vader! test/*'
	 $(DOCKER) vim-trusty '+Vader! test/*'
	 $(DOCKER) vim-vivid '+Vader! test/*'
	 $(DOCKER) vim-wily '+Vader! test/*'
	 $(DOCKER) vim-xenial '+Vader! test/*'

.PHONY: test-setup test
