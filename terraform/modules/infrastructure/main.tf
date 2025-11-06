# Infrastructure module for AutoStack Deploy

# Create network resources
data "proxmox_virtual_environment_nodes" "available" {}

data "proxmox_virtual_environment_role" "admin" {
  role_id = "Administrator"
}

resource "proxmox_virtual_environment_pool" "this" {
  comment = "Managed by AutoStack Deploy"
  pool_id = "${var.prefix}-${var.environment}-pool"
}

# Create master nodes
resource "proxmox_virtual_environment_vm" "master_nodes" {
  count = var.master_nodes_count

  name        = "${var.prefix}-${var.environment}-master-${count.index}"
  description = "Managed by AutoStack Deploy"
  tags        = ["autostack", var.environment]

  node_name = data.proxmox_virtual_environment_nodes.available.names[0]
  vm_id     = 1000 + count.index
  pool_id   = proxmox_virtual_environment_pool.this.id

  template = false

  disk {
    datastore_id = "local-lvm"
    file_id      = var.node_image
    size         = 32
  }

  cpu {
    cores = 2
  }

  memory {
    dedicated = 4096
  }

  network_device {
    bridge = "vmbr0"
  }

  operating_system {
    type = "l26"
  }

  serial_device {}
}

# Create worker nodes
resource "proxmox_virtual_environment_vm" "worker_nodes" {
  count = var.worker_nodes_count

  name        = "${var.prefix}-${var.environment}-worker-${count.index}"
  description = "Managed by AutoStack Deploy"
  tags        = ["autostack", var.environment]

  node_name = data.proxmox_virtual_environment_nodes.available.names[0]
  vm_id     = 2000 + count.index
  pool_id   = proxmox_virtual_environment_pool.this.id

  template = false

  disk {
    datastore_id = "local-lvm"
    file_id      = var.node_image
    size         = 64
  }

  cpu {
    cores = 4
  }

  memory {
    dedicated = 8192
  }

  network_device {
    bridge = "vmbr0"
  }

  operating_system {
    type = "l26"
  }

  serial_device {}
}

# Configure storage based on type
resource "null_resource" "configure_storage" {
  depends_on = [
    proxmox_virtual_environment_vm.master_nodes,
    proxmox_virtual_environment_vm.worker_nodes
  ]

  # This would be replaced with actual storage configuration
  # based on var.storage_type (zfs, ceph, nfs)
  provisioner "local-exec" {
    command = "echo 'Configuring ${var.storage_type} storage with size ${var.storage_size}'"
  }
}

# Deploy tunneling solution if requested
resource "null_resource" "deploy_tunneling" {
  count = var.enable_tunneling ? 1 : 0

  depends_on = [
    proxmox_virtual_environment_vm.master_nodes,
    proxmox_virtual_environment_vm.worker_nodes
  ]

  provisioner "local-exec" {
    command = "echo 'Deploying ${var.tunnel_type} tunneling solution'"
  }
}

# Deploy monitoring stack
resource "null_resource" "deploy_monitoring" {
  depends_on = [
    proxmox_virtual_environment_vm.master_nodes,
    proxmox_virtual_environment_vm.worker_nodes
  ]

  provisioner "local-exec" {
    command = "echo 'Deploying Prometheus + Grafana monitoring stack'"
  }
}