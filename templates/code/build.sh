#!/usr/bin/env bash

# this is a sample build file, please customize it to your need

yum -y install zip || exit 1

# start customization here

mkdir content
touch content/hello

# end customization here


zip -r /build/layer.zip content || exit 1