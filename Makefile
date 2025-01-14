cnf ?= .env
include $(cnf)
export $(shell sed 's/=.*//' $(cnf))

# Get the latest tag
TAG=$(shell git describe --tags --abbrev=0)
GIT_COMMIT=$(shell git log -1 --format=%h)
TERRAFORM_VERSION=1.1.4

# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

t-init: ## Run terraform init to download all necessary plugins
	  docker run --rm -v $$PWD:/app -v $$HOME/.ssh/:/root/.ssh/ -w /app/ -e TF_VAR_github_token=$$TF_VAR_github_token -e TF_VAR_github_owner=$$TF_VAR_github_owner hashicorp/terraform:$(TERRAFORM_VERSION) init -upgrade=true

t-plan: ## Exec a terraform plan and puts it on a file called tfplan
	  docker run --rm -v $$PWD:/app -v $$HOME/.ssh/:/root/.ssh/ -w /app/ -e TF_VAR_github_token=$$TF_VAR_github_token -e TF_VAR_github_owner=$$TF_VAR_github_owner hashicorp/terraform:$(TERRAFORM_VERSION) plan -out=tfplan

t-apply: ## Uses tfplan to apply the changes on AWS.
	  docker run --rm -v $$PWD:/app -v $$HOME/.ssh/:/root/.ssh/ -w /app/ -e TF_VAR_github_token=$$TF_VAR_github_token -e TF_VAR_github_owner=$$TF_VAR_github_owner hashicorp/terraform:$(TERRAFORM_VERSION) apply -auto-approve

t-destroy: ## Destroy all resources created by the terraform file in this repo.
	  docker run --rm -v $$PWD:/app -v $$HOME/.ssh/:/root/.ssh/ -w /app/ -e TF_VAR_github_token=$$TF_VAR_github_token -e TF_VAR_github_owner=$$TF_VAR_github_owner hashicorp/terraform:$(TERRAFORM_VERSION) destroy -auto-approve

t-set-workspace-dev: ## Set workspace dev
	  docker run --rm -v $$PWD:/app -v $$HOME/.ssh/:/root/.ssh/ -w /app/ -e TF_VAR_github_token=$$TF_VAR_github_token -e TF_VAR_github_owner=$$TF_VAR_github_owner hashicorp/terraform:$(TERRAFORM_VERSION) workspace select dev

t-set-workspace-prod: ## Set workspace production
	  docker run --rm -v $$PWD:/app -v $$HOME/.ssh/:/root/.ssh/ -w /app/ -e TF_VAR_github_token=$$TF_VAR_github_token -e TF_VAR_github_owner=$$TF_VAR_github_owner hashicorp/terraform:$(TERRAFORM_VERSION) workspace select prod

t-set-workspace-staging: ## Set workspace staging
	  docker run --rm -v $$PWD:/app -v $$HOME/.ssh/:/root/.ssh/ -w /app/ -e TF_VAR_github_token=$$TF_VAR_github_token -e TF_VAR_github_owner=$$TF_VAR_github_owner hashicorp/terraform:$(TERRAFORM_VERSION) workspace select staging

t-new-workspace-staging: ## Create workspace staging
	  docker run --rm -v $$PWD:/app -v $$HOME/.ssh/:/root/.ssh/ -w /app/ -e TF_VAR_github_token=$$TF_VAR_github_token -e TF_VAR_github_owner=$$TF_VAR_github_owner hashicorp/terraform:$(TERRAFORM_VERSION) workspace new staging

t-sh: ## terraform console
	  docker run -it --rm -v $$PWD:/app -v $$HOME/.ssh/:/root/.ssh/ -w /app/ -e TF_VAR_github_token=$$TF_VAR_github_token -e TF_VAR_github_owner=$$TF_VAR_github_owner --entrypoint "" hashicorp/terraform:$(TERRAFORM_VERSION) sh

packer-build: ## packer build
	  docker run -it --rm -v $$PWD:/app -v $$HOME/.ssh/:/root/.ssh/ -w /app/ -e TF_VAR_github_token=$$TF_VAR_github_token -e TF_VAR_github_owner=$$TF_VAR_github_owner hashicorp/packer build examples/consul-ami/consul.json

packer-sh: ## packer console
	  docker run -it --rm -v $$PWD:/app -v $$HOME/.ssh/:/root/.ssh/ -w /app/ -e TF_VAR_github_token=$$TF_VAR_github_token -e TF_VAR_github_owner=$$TF_VAR_github_owner --entrypoint "" hashicorp/packer sh

