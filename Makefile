VERSION:=$(shell cat Dockerfile|grep -Po '(?<=ARG WEEWX=).*')
EXTRA_VERSION=-1

.PHONY: build
build:
	docker build --tag makobdk/weewx4:$(VERSION)$(EXTRA_VERSION) --tag makobdk/weewx4:latest .

.PHONY: push
push:
	docker login
	docker push makobdk/weewx4:$(VERSION)$(EXTRA_VERSION)
	docker push makobdk/weewx4:latest
