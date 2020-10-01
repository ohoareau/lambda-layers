all:
	@true

install:
	@true

clean:
	@rm -rf $(dir)/build

prepare-build:
	@mkdir -p $(dir)/build

test:
	@true

build:
ifeq ("", "$(CI)")
	@docker run -it --rm -v $(dir)/code:/code -v $(dir)/build:/build amazonlinux:latest /bin/bash /code/build.sh
else
	@docker create -v /code -v /build --name shared alpine:3.4 /bin/true
	@docker cp $(dir)/code/* shared:/code
	@docker run --name $(basename $0) --volumes-from shared amazonlinux:latest /bin/bash /code/build.sh
	@docker cp $(basename $0):/build/layer.zip ./build/layer.zip
	@docker rm -f $(basename $0)
endif

publish:
	@true


.PHONY: all \
		build \
		clean \
		install \
		test \
		prepare-build \
		publish
