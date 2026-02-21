IMAGE_NAME := dcroche/sws-container
VERSION    := $(shell cat VERSION)
TAG        := $(VERSION)
PLATFORMS  := linux/amd64,linux/arm64

.DEFAULT_GOAL := help
ALPHA_TAG  := $(VERSION)-alpha

.PHONY: help build push publish clean buildx-setup tag alpha alpha-push

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

buildx-setup: ## Create buildx builder if not exists
	@docker buildx inspect multiarch >/dev/null 2>&1 || docker buildx create --name multiarch --use
	@docker buildx use multiarch

build: buildx-setup ## Build multi-platform image (arm64 + amd64)
	docker buildx build --platform $(PLATFORMS) \
		--sbom=true \
		--provenance=mode=max \
		-t $(IMAGE_NAME):$(TAG) -t $(IMAGE_NAME):latest .

push: buildx-setup ## Build and push multi-platform image to Docker Hub
	docker buildx build --platform $(PLATFORMS) \
		--sbom=true \
		--provenance=mode=max \
		-t $(IMAGE_NAME):$(TAG) -t $(IMAGE_NAME):latest --push .

alpha: buildx-setup ## Build multi-platform alpha image
	docker buildx build --platform $(PLATFORMS) \
		--sbom=true \
		--provenance=mode=max \
		-t $(IMAGE_NAME):$(ALPHA_TAG) .

alpha-push: buildx-setup ## Build and push alpha image to Docker Hub
	docker buildx build --platform $(PLATFORMS) \
		--sbom=true \
		--provenance=mode=max \
		-t $(IMAGE_NAME):$(ALPHA_TAG) --push .

tag: ## Create a git tag for the current version
	git tag -a v$(VERSION) -m "Release v$(VERSION)"
	git push origin v$(VERSION)

publish: push tag ## Build, push image, and tag the repo

clean: ## Remove local image
	docker rmi $(IMAGE_NAME):$(TAG) 2>/dev/null || true
