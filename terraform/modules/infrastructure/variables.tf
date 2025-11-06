# Variables for infrastructure module

variable "prefix" {
  description = "Prefix for all resources"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key for node access"
  type        = string
}

variable "ssh_private_key_path" {
  description = "Path to SSH private key for node access"
  type        = string
}

variable "network_cidr" {
  description = "CIDR block for the cluster network"
  type        = string
}

variable "gateway_ip" {
  description = "Gateway IP address for the cluster network"
  type        = string
}

variable "dns_servers" {
  description = "DNS servers for the cluster"
  type        = list(string)
}

variable "master_nodes_count" {
  description = "Number of master nodes"
  type        = number
}

variable "worker_nodes_count" {
  description = "Number of worker nodes"
  type        = number
}

variable "node_image" {
  description = "Base image for nodes"
  type        = string
}

variable "master_node_flavor" {
  description = "VM flavor for master nodes"
  type        = string
}

variable "worker_node_flavor" {
  description = "VM flavor for worker nodes"
  type        = string
}

variable "storage_type" {
  description = "Storage backend type (zfs, ceph, nfs)"
  type        = string
}

variable "storage_size" {
  description = "Size of storage volumes"
  type        = string
}

variable "enable_tunneling" {
  description = "Whether to enable tunneling for remote access"
  type        = bool
  default     = false
}

variable "tunnel_type" {
  description = "Type of tunneling solution (cloudflare, zerotier)"
  type        = string
  default     = "cloudflare"
}