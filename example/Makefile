IMAGE ?= tweekmonster/ubuntu-vims
PLUGINS = test/plugins
DOCKER = docker run -it --rm -v $(PWD):/testplugin -v $(PWD)/test:/home "$(IMAGE)"

$(PLUGINS)/vader.vim:
	mkdir -p $(PLUGINS)
	cd $(PLUGINS) && git clone https://github.com/junegunn/vader.vim.git

test-setup: $(PLUGINS)/vader.vim
	docker images -q $(IMAGE) || docker pull $(IMAGE)

test: test-setup
	for vim in $$(docker run --rm $(IMAGE) ls /vim-build/bin | grep -E '^n?vim'); do \
	  $(DOCKER) $$vim '+Vader! test/*'; \
	done

.PHONY: test-setup test
