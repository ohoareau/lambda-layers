all: install
l ?= noname
layers ?= $(shell cd layers && ls -d */)

install:
	@$(foreach l,$(layers),make -C layers/$(l) install;)
layer-install:
	@make -C layers/$(l) install

test:
	@$(foreach l,$(layers),make -C layers/$(l) test;)
layer-test:
	@make -C layers/$(l) test

build:
	@$(foreach l,$(layers),make -C layers/$(l) build;)
layer-build:
	@make -C layers/$(l) build

publish:
	@$(foreach l,$(layers),make -C layers/$(l) publish;)
layer-publish:
	@make -C layers/$(l) publish

.PHONY: all \
		build \
		install \
		test \
		publish