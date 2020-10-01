l ?= noname
layers ?= $(shell cd layers && ls -d */)

export CI

all: install

build:
	@$(foreach l,$(layers),make -C layers/$(l) build;)

clean:
	@$(foreach l,$(layers),make -C layers/$(l) clean;)

generate:
	@yarn --silent microgen

install: install-root
	@$(foreach l,$(layers),make -C layers/$(l) install;)
install-root:
	@yarn --silent install

layer-build:
	@make -C layers/$(l) build
layer-install:
	@make -C layers/$(l) install
layer-publish:
	@make -C layers/$(l) publish
layer-test:
	@make -C layers/$(l) test

list-layers:
	@echo $(layers)

new:
	@/bin/echo -n "Layer name: " && read layer_name && cp -R templates layers/$$layer_name

pr:
	@hub pull-request -b $(b)

prepare-build:
	@$(foreach l,$(layers),make -C layers/$(l) prepare-build;)

publish:
	@$(foreach l,$(layers),make -C layers/$(l) publish;)

test:
	@$(foreach l,$(layers),make -C layers/$(l) test;)

.PHONY: all \
		build \
		clean \
		generate \
		install install-root \
		layer-build layer-install layer-publish layer-test \
		list-layers \
		new \
		pr \
		prepare-build \
		publish \
		test