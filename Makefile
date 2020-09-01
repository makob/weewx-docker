VERSION:=$(shell cat Dockerfile|grep -Po '(?<=ARG WEEWX=).*')

.PHONY: build
build:
	docker build --tag makobdk/weewx4:$(VERSION) --tag makobdk/weewx4:latest .

.PHONY: push
push:
	docker login
	docker push makobdk/weewx4:$(VERSION)
	docker push makobdk/weewx4:latest
