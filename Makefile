WORKDIR := /workspace
DOCKER_RUN := docker run --rm -it -w $(WORKDIR)
TERRAFORM_IMAGE := hashicorp/terraform:0.12.24
AWS_VAULT_ENV_VARS := -e AWS_VAULT -e AWS_DEFAULT_REGION -e AWS_REGION -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e AWS_SESSION_TOKEN -e AWS_SECURITY_TOKEN
TERRAFORM_RUN := $(DOCKER_RUN) -v `pwd`/infrastructure:$(WORKDIR):delegated $(AWS_VAULT_ENV_VARS) $(TERRAFORM_IMAGE)
PACKER_RUN := $(DOCKER_RUN) -v `pwd`/image:$(WORKDIR):delegated $(AWS_VAULT_ENV_VARS) $(PACKER_IMAGE)

.PHONY: all
all: lint setup plan

.PHONY: lint
lint: lint_terraform

.PHONY: lint_terraform
lint_terraform:
	$(TERRAFORM_RUN) fmt

.PHONY: setup
setup:
	aws-vault exec worldpeace -- $(TERRAFORM_RUN) init domains/solongandthanksforallthe.fish

.PHONY: plan
plan:
	aws-vault exec worldpeace -- $(TERRAFORM_RUN) plan -var-file="domains/solongandthanksforallthe.fish/terraform.tfvars" "domains/solongandthanksforallthe.fish"

.PHONY: deploy
deploy:
	aws-vault exec worldpeace -- $(TERRAFORM_RUN) apply -var-file="domains/solongandthanksforallthe.fish/terraform.tfvars" "domains/solongandthanksforallthe.fish"

.PHONY: destroy
destroy:
	aws-vault exec worldpeace -- $(TERRAFORM_RUN) destroy
