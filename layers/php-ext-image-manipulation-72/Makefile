run = @make -C ../../scripts dir=$(shell pwd)

all: install

clean:
	@$(run) clean

install:
	@$(run) install

test:
	@$(run) test

prepare-build:
	@$(run) prepare-build

build: clean prepare-build
	@$(run) build

publish:
	@$(run) publish

.PHONY: all \
		build \
		clean \
		install \
		test \
		prepare-build \
		publish