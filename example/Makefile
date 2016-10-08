IMAGE ?= tweekmonster/ubuntu-vims
PLUGINS = test/plugins
DOCKER = docker run -it --rm -v $(PWD):/testplugin -v $(PWD)/test:/home "$(IMAGE)"

$(PLUGINS)/vader.vim:
	mkdir -p $(PLUGINS)
	cd $(PLUGINS) && git clone https://github.com/junegunn/vader.vim.git

test-setup: $(PLUGINS)/vader.vim
	docker images -q $(IMAGE) || docker pull $(IMAGE)

test: test-setup
	 $(DOCKER) vim-precise '+Vader! test/*'
	 $(DOCKER) vim-trusty '+Vader! test/*'
	 $(DOCKER) vim-vivid '+Vader! test/*'
	 $(DOCKER) vim-wily '+Vader! test/*'
	 $(DOCKER) vim-xenial '+Vader! test/*'

.PHONY: test-setup test
