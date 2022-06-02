#!/usr/bin/env makefile
IMAGE_NAME := book-renderer

all: build render

build:
	@docker build -t ${IMAGE_NAME}:latest .

render:
	@docker run -i -v ${PWD}:/data -w /data \
		--user $(id -u):$(id -g) \
		--rm ${IMAGE_NAME}:latest bash -c "mdbook build"
