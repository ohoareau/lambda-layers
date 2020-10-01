# lambda layers

## Install all dependencies

    make

or

    make install

or to install dependencies for a specific layer:

    make layer-install l=layer-name

## Build layers

    make build

or to build a specific layer:

    make layer-build l=layer-name

## Execute tests (if any)

    make test

or to execute tests for a specific layer:

    make layer-test l=layer-name

## Publish layer (additional configuration required)

Prior to publishing you need to have built the layer and generated a `layers/layer-name/build/layer.zip` file.
This `layer.zip` will be the one that will be published to AWS S3, without any modifications.

    make publish

or to publish a specific layer:

    make layer-publish l=layer-name


