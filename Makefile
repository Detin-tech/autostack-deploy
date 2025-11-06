# AutoStack Deploy Makefile

.PHONY: help init plan apply destroy install-deps

# Default environment
ENV ?= dev

# Help target
default: help

help:
	@echo "AutoStack Deploy Makefile"
	@echo ""
	@echo "Usage:"
	@echo "  make init            Initialize Terraform"
	@echo "  make plan            Plan Terraform changes"
	@echo "  make apply           Apply Terraform configuration"
	@echo "  make deploy          Deploy with Ansible"
	@echo "  make destroy         Destroy infrastructure"
	@echo "  make install-deps    Install dependencies"
	@echo ""
	@echo "Environment:"
	@echo "  ENV=[environment]    Set environment (default: dev)"

# Terraform targets
init:
	cd terraform && terraform init

plan:
	cd terraform && terraform plan -var-file=environments/$(ENV).tfvars

apply:
	cd terraform && terraform apply -var-file=environments/$(ENV).tfvars

destroy:
	cd terraform && terraform destroy -var-file=environments/$(ENV).tfvars

# Ansible targets
deploy:
	cd ansible && ansible-playbook -i inventories/$(ENV) site.yml

check:
	cd ansible && ansible-inventory -i inventories/$(ENV) --list

# Dependency installation
install-deps:
	# Install Terraform
	wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
	echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $$(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
	apt update && apt install terraform

	# Install Ansible
	apt update
	apt install software-properties-common
	add-apt-repository --yes --update ppa:ansible/ansible
	apt install ansible

	# Install required Ansible collections
	ansible-galaxy collection install community.general
	ansible-galaxy collection install ansible.posix

# Validation targets
validate-terraform:
	cd terraform && terraform validate

validate-ansible:
	cd ansible && ansible-playbook --syntax-check site.yml

validate: validate-terraform validate-ansible

# Clean targets
clean:
	cd terraform && rm -rf .terraform terraform.tfstate*
