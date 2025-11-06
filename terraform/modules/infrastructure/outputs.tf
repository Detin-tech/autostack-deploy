# Outputs for infrastructure module

output "master_nodes_ips" {
  description = "IP addresses of master nodes"
  value = [
    for vm in proxmox_virtual_environment_vm.master_nodes :
    vm.ipv4_addresses[0][0] if length(vm.ipv4_addresses) > 0 and length(vm.ipv4_addresses[0]) > 0 else ""
  ]
}

output "worker_nodes_ips" {
  description = "IP addresses of worker nodes"
  value = [
    for vm in proxmox_virtual_environment_vm.worker_nodes :
    vm.ipv4_addresses[0][0] if length(vm.ipv4_addresses) > 0 and length(vm.ipv4_addresses[0]) > 0 else ""
  ]
}

output "storage_network_info" {
  description = "Information about storage network"
  value = {
    type = var.storage_type
    size = var.storage_size
  }
}

output "monitoring_endpoint" {
  description = "Endpoint for accessing monitoring dashboard"
  value = "http://${proxmox_virtual_environment_vm.master_nodes[0].ipv4_addresses[0][0]}:3000"
}

output "tunnel_info" {
  description = "Information about remote access tunnels"
  value = var.enable_tunneling ? {
    type = var.tunnel_type
    status = "configured"
  } : {
    type = "none"
    status = "disabled"
  }
}