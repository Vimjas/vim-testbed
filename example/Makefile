IMAGE ?= tweekmonster/ubuntu-vims
PLUGINS = test/plugins
DOCKER = docker run -a stderr --rm -v $(PWD):/testplugin -v $(PWD)/test:/home "$(IMAGE)"

$(PLUGINS)/vader.vim:
	mkdir -p $(PLUGINS)
	cd $(PLUGINS) && git clone https://github.com/junegunn/vader.vim.git

test-setup: $(PLUGINS)/vader.vim
	docker images -q $(IMAGE) || docker pull $(IMAGE)

test: test-setup
	vims=$$(docker run --rm $(IMAGE) ls /vim-build/bin | grep -E '^n?vim'); \
	if [ -z "$$vims" ]; then echo "No Vims found!"; exit 1; fi; \
	for vim in $$vims; do \
	  $(DOCKER) $$vim '+Vader! test/*'; \
	done
	out=$$(docker run --rm "$(IMAGE)" /vim-build/bin/argecho "arg1" "arg 2"); \
	for line in "PWD=/" "Running as: root" "Arguments:" "arg1" "arg 2"; do \
	  if ! echo "$$out" | grep -qFx -e "$$line"; then \
	    echo "Line not found: $$line"; echo "$$out"; exit 1; \
	  fi \
	done
	out=$$(docker run --rm "$(IMAGE)" argecho "arg1" "arg 2"); \
	for line in "Running as: vimtest" "PWD=/testplugin" "Arguments:" "-u" "/home/vimrc" "-i" "NONE" "arg1" "arg 2"; do \
	  if ! echo "$$out" | grep -qFx -e "$$line"; then \
	    echo "Line not found: $$line"; echo "$$out"; exit 1; \
	  fi \
	done

.PHONY: test-setup test
