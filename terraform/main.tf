# Main Terraform configuration for AutoStack Deploy

terraform {
  required_version = ">= 1.0"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.9.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = ">= 4.0.0"
    }
    zerotier = {
      source  = "zerotier/zerotier"
      version = ">= 1.0.0"
    }
  }
}

# Provider configurations (will be customized per environment)
provider "proxmox" {
  endpoint = var.proxmox_endpoint
  username = var.proxmox_username
  password = var.proxmox_password
  insecure = var.proxmox_insecure
}

provider "cloudflare" {
  email   = var.cloudflare_email
  api_key = var.cloudflare_api_key
}

provider "zerotier" {
  zerotier_central_url = var.zerotier_central_url
  zerotier_central_token = var.zerotier_central_token
}

# Module for creating infrastructure
module "infrastructure" {
  source = "./modules/infrastructure"

  # Common variables
  prefix              = var.prefix
  environment         = var.environment
  ssh_public_key      = var.ssh_public_key
  ssh_private_key_path = var.ssh_private_key_path

  # Network configuration
  network_cidr        = var.network_cidr
  gateway_ip          = var.gateway_ip
  dns_servers         = var.dns_servers

  # Compute resources
  master_nodes_count  = var.master_nodes_count
  worker_nodes_count  = var.worker_nodes_count
  node_image          = var.node_image
  master_node_flavor  = var.master_node_flavor
  worker_node_flavor  = var.worker_node_flavor

  # Storage configuration
  storage_type        = var.storage_type
  storage_size        = var.storage_size
}