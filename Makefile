#!/usr/bin/env makefile
IMAGE_NAME := tuod/book-renderer
USER_ID := $$(id -u)
GROUP_ID := $$(id -g)
VERSION := 0.0.$(shell date '+%Y%m%d%H%M%S')

all: pull render

deploy:	build publish

pull:
	@docker pull ${IMAGE_NAME}:latest

build:
	@docker build \
		--build-arg USER=${USER} \
		--build-arg USER_ID=${USER_ID} \
		--build-arg GROUP_ID=${GROUP_ID} \
		-t ${IMAGE_NAME}:latest .

publish:
	@docker tag ${IMAGE_NAME}:latest ${IMAGE_NAME}:${VERSION}
	@docker push ${IMAGE_NAME}:${VERSION}
	@docker push ${IMAGE_NAME}:latest

render:
	@docker run -i -v ${PWD}:/data -w /data \
		--user ${USER_ID}:${GROUP_ID} \
		--rm ${IMAGE_NAME}:latest bash -c "mdbook build"
