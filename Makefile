VERSION:=$(shell cat VERSION)

.PHONY: build
build:
	docker build --tag makobdk/weewx5:$(VERSION) --tag makobdk/weewx5:latest .

.PHONY: push
push:
	docker login
	docker push makobdk/weewx5:$(VERSION)
	docker push makobdk/weewx5:latest
