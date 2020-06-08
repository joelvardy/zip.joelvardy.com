# Source: http://clarkgrubb.com/makefile-style-guide
MAKEFLAGS += --warn-undefined-variables
.DEFAULT_GOAL := help

.PHONY: install
install: ## Install dependencies
	yarn install --no-progress --frozen-lockfile

.PHONY: serve
serve: ## Run project for local development
	yarn serve

.PHONY: build
build: ## Build website for deployment
	yarn build

.PHONY: lint
lint: ## Lint website code
	yarn lint --no-fix

.PHONY: deploy-infrastructure
deploy-infrastructure: ## Deploy infrastructure
	./node_modules/serverless/bin/serverless.js deploy --verbose --stage=master

.PHONY: deploy-website
deploy-website: ## Deploy website
	aws s3 sync ./dist s3://$(S3_WEBSITE_BUCKET_NAME) --delete
	aws cloudfront create-invalidation --distribution-id $(CLOUDFRONT_DISTRIBUTION_ID) --paths=/*

# Source: https://www.client9.com/self-documenting-makefiles/
.PHONY: help
help:
	@awk -F ':|##' '/^[^\t].+?:.*?##/ {\
	printf "\033[36m%-30s\033[0m %s\n", $$1, $$NF \
	}' $(MAKEFILE_LIST)
