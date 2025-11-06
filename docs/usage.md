# AutoStack Deploy Usage Guide

## Prerequisites

1. Terraform >= 1.0
2. Ansible >= 2.9
3. Access to a Proxmox VE cluster
4. SSH key pair for node access

## Quick Start

1. Clone the repository:
   ```
   git clone https://github.com/yourusername/autostack-deploy.git
   cd autostack-deploy
   ```

2. Create a configuration file:
   ```
   cp terraform/environments/dev.tfvars.example terraform/environments/dev.tfvars
   # Edit the file with your settings
   vim terraform/environments/dev.tfvars
   ```

3. Run the deployment:
   ```
   ./scripts/deploy.sh -e dev
   ```

## Configuration

### Terraform Variables

The following variables can be configured in your `.tfvars` file:

| Variable | Description | Default |
|----------|-------------|---------|
| `prefix` | Prefix for all resources | `autostack` |
| `environment` | Environment name | `dev` |
| `proxmox_endpoint` | Proxmox API endpoint | Required |
| `proxmox_username` | Proxmox username | Required |
| `proxmox_password` | Proxmox password | Required |
| `ssh_public_key` | SSH public key path | Required |
| `ssh_private_key_path` | SSH private key path | Required |
| `network_cidr` | Cluster network CIDR | `10.0.1.0/24` |
| `gateway_ip` | Network gateway | `10.0.1.1` |
| `master_nodes_count` | Number of master nodes | `1` |
| `worker_nodes_count` | Number of worker nodes | `3` |
| `storage_type` | Storage backend (`zfs`, `ceph`, `nfs`) | `zfs` |
| `storage_size` | Storage volume size | `100G` |
| `enable_tunneling` | Enable remote access tunnel | `false` |
| `tunnel_type` | Tunnel type (`cloudflare`, `zerotier`) | `cloudflare` |

## Deployment Process

The deployment process consists of two phases:

1. **Infrastructure Provisioning** (Terraform)
   - Creates VMs for master and worker nodes
   - Configures network and storage resources
   - Sets up tunneling if enabled

2. **Configuration Management** (Ansible)
   - Installs and configures OS packages
   - Sets up Kubernetes cluster
   - Deploys monitoring stack (Prometheus/Grafana)
   - Configures storage backend
   - Sets up tunneling if enabled

## Extending AutoStack Deploy

### Adding New Services

To add a new service to your deployment:

1. Create a new Ansible role in `ansible/roles/`
2. Add the role to the appropriate section in `ansible/playbooks/site.yml`
3. Add any required variables to your tfvars file

### Customizing Node Roles

Node roles can be customized by modifying:
- `ansible/playbooks/site.yml` - Main playbook
- `ansible/inventories/*/hosts` - Host grouping
- Individual role files in `ansible/roles/`

## Troubleshooting

### Common Issues

1. **Terraform fails to connect to Proxmox**
   - Verify Proxmox credentials in your tfvars file
   - Check if the Proxmox API is accessible
   - Ensure the user has sufficient permissions

2. **Ansible fails to connect to nodes**
   - Verify SSH key paths in your configuration
   - Check if nodes are reachable over the network
   - Ensure the `autostack` user exists on nodes

3. **Kubernetes fails to initialize**
   - Check if required ports are open (6443, 2379-2380, 10250-10252)
   - Verify sufficient system resources
   - Check logs on master node: `journalctl -u kubelet`

### Useful Commands

```bash
# Check Terraform configuration
cd terraform
terraform plan -var-file=environments/dev.tfvars

cd ..
# Check Ansible inventory
ansible-inventory -i ansible/inventories/dev --list

# Run specific Ansible plays
ansible-playbook -i ansible/inventories/dev ansible/playbooks/site.yml --tags=kubernetes

# Destroy deployment
cd terraform
terraform destroy -var-file=environments/dev.tfvars
```
