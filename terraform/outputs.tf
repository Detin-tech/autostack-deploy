# Outputs for AutoStack Deploy

output "master_nodes_ips" {
  description = "IP addresses of master nodes"
  value       = module.infrastructure.master_nodes_ips
}

output "worker_nodes_ips" {
  description = "IP addresses of worker nodes"
  value       = module.infrastructure.worker_nodes_ips
}

output "storage_network_info" {
  description = "Information about storage network"
  value       = module.infrastructure.storage_network_info
}

output "monitoring_endpoint" {
  description = "Endpoint for accessing monitoring dashboard"
  value       = module.infrastructure.monitoring_endpoint
}

output "tunnel_info" {
  description = "Information about remote access tunnels"
  value       = module.infrastructure.tunnel_info
}