#!/bin/bash

# AutoStack Deploy script

set -e

usage() {
  echo "Usage: $0 [OPTIONS]"
  echo "Options:"
  echo "  -e, --environment ENV   Set environment (dev, staging, prod)"
  echo "  -c, --config FILE       Set configuration file"
  echo "  -d, --destroy           Destroy infrastructure"
  echo "  -h, --help              Show this help message"
  exit 1
}

ENVIRONMENT="dev"
CONFIG_FILE=""
DESTROY=false

while [[ $# -gt 0 ]]; do
  case $1 in
e)
    ENVIRONMENT="$2"
    shift 2
    ;;
    -e|--environment)
    ENVIRONMENT="$2"
    shift 2
    ;;
    -c|--config)
    CONFIG_FILE="$2"
    shift 2
    ;;
    -d|--destroy)
    DESTROY=true
    shift
    ;;
    -h|--help)
    usage
    ;;
    *)
    echo "Unknown option $1"
    usage
    ;;
  esac
done

if [ "$DESTROY" = true ]; then
  echo "Destroying AutoStack environment: $ENVIRONMENT"
  cd terraform
  terraform destroy -var-file="environments/$ENVIRONMENT.tfvars"
  cd ..
else
  echo "Deploying AutoStack environment: $ENVIRONMENT"
  
  # Apply Terraform configuration
  cd terraform
  terraform init
  terraform apply -var-file="environments/$ENVIRONMENT.tfvars" -auto-approve
  cd ..
  
  # Generate Ansible inventory from Terraform output
  echo "Generating Ansible inventory..."
  cd terraform
  terraform output -json > ../ansible/inventories/$ENVIRONMENT/terraform.json
  cd ..
  
  # Run Ansible playbooks
  echo "Running Ansible playbooks..."
  cd ansible
  ansible-playbook -i inventories/$ENVIRONMENT site.yml
  cd ..
  
  echo "Deployment completed successfully!"
fi
