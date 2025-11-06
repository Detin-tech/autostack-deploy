# Variables for AutoStack Deploy

# Environment configuration
variable "prefix" {
  description = "Prefix for all resources"
  type        = string
  default     = "autostack"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

# Proxmox provider variables
variable "proxmox_endpoint" {
  description = "Proxmox API endpoint"
  type        = string
}

variable "proxmox_username" {
  description = "Proxmox username"
  type        = string
}

variable "proxmox_password" {
  description = "Proxmox password"
  type        = string
  sensitive   = true
}

variable "proxmox_insecure" {
  description = "Allow insecure HTTPS connections to Proxmox"
  type        = bool
  default     = true
}

# Cloudflare provider variables
variable "cloudflare_email" {
  description = "Cloudflare account email"
  type        = string
  default     = ""
}

variable "cloudflare_api_key" {
  description = "Cloudflare API key"
  type        = string
  default     = ""
  sensitive   = true
}

# ZeroTier provider variables
variable "zerotier_central_url" {
  description = "ZeroTier Central API URL"
  type        = string
  default     = "https://my.zerotier.com/api"
}

variable "zerotier_central_token" {
  description = "ZeroTier Central API token"
  type        = string
  default     = ""
  sensitive   = true
}

# SSH configuration
variable "ssh_public_key" {
  description = "SSH public key for node access"
  type        = string
}

variable "ssh_private_key_path" {
  description = "Path to SSH private key for node access"
  type        = string
}

# Network configuration
variable "network_cidr" {
  description = "CIDR block for the cluster network"
  type        = string
  default     = "10.0.1.0/24"
}

variable "gateway_ip" {
  description = "Gateway IP address for the cluster network"
  type        = string
  default     = "10.0.1.1"
}

variable "dns_servers" {
  description = "DNS servers for the cluster"
  type        = list(string)
  default     = ["8.8.8.8", "1.1.1.1"]
}

# Compute resources
variable "master_nodes_count" {
  description = "Number of master nodes"
  type        = number
  default     = 1
}

variable "worker_nodes_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 3
}

variable "node_image" {
  description = "Base image for nodes"
  type        = string
  default     = "ubuntu-22.04"
}

variable "master_node_flavor" {
  description = "VM flavor for master nodes"
  type        = string
  default     = "medium"
}

variable "worker_node_flavor" {
  description = "VM flavor for worker nodes"
  type        = string
  default     = "large"
}

# Storage configuration
variable "storage_type" {
  description = "Storage backend type (zfs, ceph, nfs)"
  type        = string
  default     = "zfs"
}

variable "storage_size" {
  description = "Size of storage volumes"
  type        = string
  default     = "100G"
}