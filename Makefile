REPO=tibs/unifi-video
VERSION := $(shell cat VERSION)

PHONY: unifi-video
unifi-video:
	docker build --build-arg VERSION=${VERSION} -t ${REPO} -t ${REPO}:${VERSION} .

all: unifi-video push

push:
	docker push ${REPO}
