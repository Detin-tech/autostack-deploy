# AutoStack Deploy Architecture

## Overview

AutoStack Deploy uses a two-phase approach to provision and configure infrastructure:

1. **Infrastructure Provisioning** using Terraform to create compute, network, and storage resources
2. **Configuration Management** using Ansible to install software and configure services

## Terraform Architecture

### Modules

- `infrastructure`: Main module that orchestrates all infrastructure creation
  - Creates master and worker nodes
  - Configures storage based on selected backend
  - Sets up networking
  - Deploys tunneling solutions

### Providers

- **Proxmox**: Primary provider for VM creation and management
- **Cloudflare**: For DNS and tunnel management (optional)
- **ZeroTier**: For VPN tunneling (optional)

### Resources Created

1. Virtual machines for:
   - Kubernetes master nodes
   - Kubernetes worker nodes
   - Storage nodes (depending on backend)

2. Network configuration:
   - VM network interfaces
   - Port forwarding rules
   - Firewall rules

3. Storage setup:
   - ZFS pools and datasets
   - Ceph clusters
   - NFS shares

## Ansible Architecture

### Playbooks

- `site.yml`: Main playbook that orchestrates all configuration

### Roles

1. **common**: Basic OS setup and hardening
2. **kubernetes/**:
   - `master`: Kubernetes control plane setup
   - `worker`: Kubernetes worker node setup
3. **monitoring/**:
   - `prometheus`: Metrics collection
   - `grafana`: Visualization dashboard
4. **storage**: Storage backend configuration (ZFS, Ceph, NFS)
5. **tunnel/**:
   - `cloudflare`: Cloudflare Tunnel setup
   - `zerotier`: ZeroTier network configuration

### Configuration Flow

1. All nodes:
   - OS updates and package installation
   - SSH hardening
   - Hostname and network configuration

2. Storage nodes:
   - Backend-specific storage configuration

3. Kubernetes master:
   - kubeadm initialization
   - Pod network deployment
   - Join token generation

4. Kubernetes workers:
   - Join cluster using token

5. Monitoring:
   - Prometheus installation and configuration
   - Grafana deployment with dashboards

6. Tunneling:
   - Remote access configuration

## Data Flow

```
+-------------------+    +------------------+    +------------------+
|   Configuration   |    |  Infrastructure  |    |   Monitoring     |
|     Files         |    |   Provisioning   |    |   & Observability|
|                   |    |                  |    |                  |
| - tfvars files    |--->| - Terraform      |--->| - Prometheus     |
| - Ansible vars    |    | - VM Creation    |    | - Grafana        |
| - Inventory       |    | - Network Setup  |    |                  |
+-------------------+    | - Storage Config |    +------------------+
                         +------------------+
                                   |
                                   v
                         +------------------+
                         | Configuration    |
                         | Management       |
                         |                  |
                         | - Ansible        |
                         | - Service Setup  |
                         | - Cluster Config |
                         +------------------+
```

## Extensibility

### Adding New Services

1. Create a new Ansible role in `ansible/roles/`
2. Add the role to the appropriate play in `site.yml`
3. Include any required variables in configuration files

### Adding New Infrastructure Types

1. Extend the Terraform infrastructure module
2. Add new provider configurations as needed
3. Update the Ansible inventory generation scripts

## Security Considerations

1. **SSH Access**:
   - Key-based authentication only
   - Disabled password authentication
   - Non-standard users

2. **Network Security**:
   - Minimal exposed ports
   - Firewall rules by default
   - Private networks where possible

3. **Secrets Management**:
   - Sensitive variables marked in Terraform
   - Ansible Vault for encrypted secrets
   - No secrets stored in plain text

## High Availability

Current implementation supports:
- Multi-master Kubernetes clusters
- Redundant worker nodes
- Distributed storage backends

Planned enhancements:
- Load balancer for master nodes
- Automatic failover configuration
- Backup and disaster recovery procedures
