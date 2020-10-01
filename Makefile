all: install
layers ?= $(shell cd layers && ls -d */)

install:
	@$(foreach l,$(layers),make -C layers/$(l) install;)
test:
	@$(foreach l,$(layers),make -C layers/$(l) test;)

build:
	@$(foreach l,$(layers),make -C layers/$(l) build;)

publish:
	@$(foreach l,$(layers),make -C layers/$(l) publish;)

.PHONY: all \
		build \
		install \
		test \
		publish