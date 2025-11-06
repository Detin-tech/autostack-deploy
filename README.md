# AutoStack Deploy

A Terraform + Ansible automation framework that provisions and configures a complete on-prem or hybrid cluster environment with minimal manual setup.

## Features

- **Terraform**: Builds network, compute, and storage resources across bare-metal, virtual, or cloud targets.
- **Ansible**: Automates OS setup, service installs, and configuration for Kubernetes or Proxmox clusters.
- **Tunneling**: Optionally deploys Cloudflare or ZeroTier tunnels for secure remote access.
- **Monitoring**: Deploys Prometheus + Grafana dashboards for system metrics.
- **Storage Management**: Configures local or networked storage backends (ZFS, Ceph, or NFS).
- **Extensible**: Easily extend roles for services like Ollama, Caddy, or n8n.

## Prerequisites

Before you begin, ensure you have the following installed:
- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) >= 2.9
- Access to a Proxmox server (or compatible virtualization platform)
- SSH key pair for node access

## Installation

Clone the repository and install dependencies:

```bash
git clone <repository-url>
cd autostack-deploy
make install-deps
```

## Quick Start

1. **Configure your environment:**
   Copy the example configuration and modify it for your environment:
   ```bash
   cp terraform/environments/dev.tfvars.example terraform/environments/dev.tfvars
   ```

2. **Edit the configuration:**
   Modify `terraform/environments/dev.tfvars` with your environment details:
   ```hcl
   # Proxmox connection details
   proxmox_endpoint = "https://your-proxmox-server:8006/api2/json"
   proxmox_username = "terraform@pve"
   proxmox_password = "your-secure-password"
   
   # SSH keys
   ssh_public_key = "~/.ssh/id_rsa.pub"
   ssh_private_key_path = "~/.ssh/id_rsa"
   
   # Network settings
   gateway_ip = "192.168.1.1"
   network_cidr = "192.168.1.0/24"
   ```

3. **Initialize Terraform:**
   ```bash
   make init
   ```

4. **Plan the deployment:**
   ```bash
   make plan
   ```

5. **Apply the configuration:**
   ```bash
   make apply
   ```

6. **Deploy services with Ansible:**
   ```bash
   make deploy
   ```

## Makefile Commands

| Command             | Description                        |
|---------------------|------------------------------------|
| `make init`         | Initialize Terraform               |
| `make plan`         | Plan Terraform changes             |
| `make apply`        | Apply Terraform configuration      |
| `make deploy`       | Deploy with Ansible                |
| `make destroy`      | Destroy infrastructure             |
| `make install-deps` | Install dependencies               |
| `make validate`     | Validate both Terraform and Ansible|

### Environment Variables

You can specify different environments using the `ENV` variable:

```bash
# Use staging environment
ENV=staging make plan
ENV=staging make apply
ENV=staging make deploy
```

## Configuration Options

### Terraform Variables

These variables can be set in your `.tfvars` file:

| Variable              | Description                            | Default      | Required |
|-----------------------|----------------------------------------|--------------|----------|
| `prefix`              | Prefix for all resources               | `autostack`  | No       |
| `environment`         | Environment name                       | `dev`        | No       |
| `proxmox_endpoint`    | Proxmox API endpoint                   | -            | Yes      |
| `proxmox_username`    | Proxmox username                       | -            | Yes      |
| `proxmox_password`    | Proxmox password                       | -            | Yes      |
| `proxmox_insecure`    | Allow insecure HTTPS connections       | `true`       | No       |
| `ssh_public_key`      | SSH public key for node access         | -            | Yes      |
| `ssh_private_key_path`| Path to SSH private key                | -            | Yes      |
| `network_cidr`        | CIDR block for cluster network         | `10.0.1.0/24`| No       |
| `gateway_ip`          | Gateway IP address                     | `10.0.1.1`   | No       |
| `dns_servers`         | DNS servers for the cluster            | Google/Cloudflare IPs | No |
| `master_nodes_count`  | Number of master nodes                 | `1`          | No       |
| `worker_nodes_count`  | Number of worker nodes                 | `3`          | No       |
| `node_image`          | Base image for nodes                   | `ubuntu-22.04`| No      |
| `master_node_flavor`  | VM flavor for master nodes             | `medium`     | No       |
| `worker_node_flavor`  | VM flavor for worker nodes             | `large`      | No       |
| `storage_type`        | Storage backend type                   | `zfs`        | No       |
| `storage_size`        | Size of storage volumes                | `100G`       | No       |
| `enable_tunneling`    | Enable tunneling services              | `false`      | No       |
| `tunnel_type`         | Tunnel type (cloudflare/zerotier)      | -            | No       |

### Ansible Configuration

The Ansible configuration is automatically generated from Terraform outputs. 
Inventory groups are created dynamically:
- `masters`: Kubernetes control plane nodes
- `workers`: Kubernetes worker nodes
- `storage`: Nodes with storage capabilities
- `monitoring`: Nodes running monitoring services
- `tunnel`: Nodes running tunnel services

## Project Structure

```
autostack-deploy/
├── ansible/
│   ├── group_vars/
│   ├── host_vars/
│   ├── inventories/
│   ├── playbooks/
│   ├── roles/
│   └── ansible.cfg
├── terraform/
│   ├── modules/
│   ├── environments/
│   └── providers/
├── scripts/
└── docs/
```

## Extending AutoStack

### Adding New Services

To add new services to your cluster:

1. Create a new Ansible role in `ansible/roles/`
2. Add the role to `ansible/playbooks/site.yml`
3. Include any required variables in your tfvars file

Example for adding a custom service:
```yaml
# In ansible/playbooks/site.yml
- name: Deploy custom service
  hosts: custom_service_group
  become: yes
  roles:
    - my-custom-service
```

### Customizing Existing Roles

Each role in `ansible/roles/` can be customized by modifying:
- `tasks/main.yml`: Main execution steps
- `templates/`: Jinja2 templates for configuration files
- `handlers/main.yml`: Service restart handlers
- `defaults/main.yml`: Default variables (if present)

## Monitoring and Observability

AutoStack includes built-in monitoring with:
- **Prometheus**: Metrics collection and storage
- **Grafana**: Visualization dashboards

Access Grafana at `http://<monitoring-node-ip>:3000` (default credentials: admin/admin)

## Troubleshooting

### Common Issues

1. **Terraform state conflicts:**
   ```bash
   cd terraform
   terraform force-unlock <lock-id>
   ```

2. **Ansible connection issues:**
   Check SSH connectivity manually:
   ```bash
   ssh -i <private-key-path> <user>@<node-ip>
   ```

3. **Node provisioning failures:**
   Check Terraform logs and Proxmox UI for error messages.

### Validating Configuration

Validate your configuration before applying:
```bash
make validate
```

This runs both Terraform validation and Ansible syntax checks.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a pull request

## License

MIT

## Details

Found under /docs
