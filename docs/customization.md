# AutoStack Deploy Customization Guide

This guide explains how to extend and customize AutoStack Deploy for your specific needs.

## Adding New Services

To add a new service to your deployment:

1. Create a new Ansible role:
   ```bash
   mkdir -p ansible/roles/mynewservice/{tasks,templates,files}
   ```

2. Implement the role tasks in `ansible/roles/mynewservice/tasks/main.yml`:
   ```yaml
   ---
   - name: Install mynewservice
     apt:
       name: mynewservice
       state: present
   
   - name: Configure mynewservice
     template:
       src: mynewservice.conf.j2
       dest: /etc/mynewservice/mynewservice.conf
     notify: Restart mynewservice
   
   - name: Start mynewservice
     systemd:
       name: mynewservice
       state: started
       enabled: yes
   ```

3. Add the role to the appropriate section in `ansible/playbooks/site.yml`:
   ```yaml
   - name: Deploy mynewservice
     hosts: mynewservice_hosts
     become: yes
     roles:
       - mynewservice
   ```

4. Define the hosts group in your inventory.

## Customizing Existing Services

### Kubernetes Configuration

To customize Kubernetes settings, modify:

1. `ansible/roles/kubernetes/master/templates/` - Control plane configurations
2. `ansible/roles/kubernetes/worker/templates/` - Worker configurations
3. `ansible/roles/kubernetes/master/tasks/main.yml` - Installation process

### Storage Backends

To add support for a new storage backend:

1. Create a new task file in `ansible/roles/storage/tasks/`
2. Add conditional logic in `ansible/roles/storage/tasks/main.yml`
3. Create necessary templates in `ansible/roles/storage/templates/`
4. Update documentation and variables

Example for adding a new storage type:
```yaml
- name: Install MyStorage packages
  apt:
    name: mystorage-utils
    state: present
  when: storage_type == "mystorage"

- name: Configure MyStorage cluster
  template:
    src: mystorage.conf.j2
    dest: /etc/mystorage/mystorage.conf
  when: 
    - storage_type == "mystorage"
    - inventory_hostname in groups['storage']
```

## Adding New Infrastructure Types

To extend infrastructure provisioning beyond Proxmox:

1. Add a new provider in `terraform/main.tf`:
   ```hcl
   provider "aws" {
     region = var.aws_region
   }
   ```

2. Create new modules in `terraform/modules/` for the provider
3. Update the main infrastructure module to conditionally use different providers
4. Add provider-specific variables in `terraform/variables.tf`

## Environment-Specific Configurations

Different environments (dev, staging, prod) can have separate configurations:

1. Create environment-specific variable files in `terraform/environments/`
2. Create environment-specific inventory directories in `ansible/inventories/`
3. Use group variables in `ansible/group_vars/` for shared settings

Example structure:
```
terraform/environments/
├── dev.tfvars
├── staging.tfvars
└── prod.tfvars

ansible/inventories/
├── dev/
│   └── hosts
├── staging/
│   └── hosts
└── prod/
    └── hosts
```

## Adding Monitoring Dashboards

To add custom Grafana dashboards:

1. Create a JSON dashboard template in `ansible/roles/monitoring/grafana/files/`
2. Add a task to import the dashboard:
   ```yaml
   - name: Import custom dashboard
     uri:
       url: http://localhost:3000/api/dashboards/db
       user: admin
       password: admin
       method: POST
       body_format: json
       body: "{{ lookup('file', 'dashboards/custom-dashboard.json') }}"
   ```

## Custom Network Configurations

To customize network setup:

1. Modify `terraform/modules/infrastructure/main.tf` network definitions
2. Update `ansible/roles/common/tasks/main.yml` network configuration tasks
3. Add custom firewall rules as needed

## Secret Management

For managing sensitive information:

1. Use Ansible Vault for encrypting sensitive variables:
   ```bash
   ansible-vault encrypt ansible/group_vars/all/vault.yml
   ```

2. Store non-sensitive variables separately
3. Reference vault variables in playbooks normally

## Testing Customizations

Before deploying customizations:

1. Validate Terraform configuration:
   ```bash
   cd terraform
   terraform validate
   ```

2. Check Ansible syntax:
   ```bash
   cd ansible
   ansible-playbook --syntax-check site.yml
   ```

3. Test on a development environment first

## CI/CD Integration

To integrate with CI/CD pipelines:

1. Create pipeline-specific configuration files
2. Add validation steps to the pipeline
3. Implement automated testing where possible
4. Use pipeline secrets for sensitive variables

Example GitHub Actions workflow:
```yaml
name: Deploy to Staging
on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - name: Deploy with AutoStack
      run: |
        ./scripts/deploy.sh -e staging
      env:
        PROXMOX_PASSWORD: ${{ secrets.PROXMOX_PASSWORD }}
        CLOUDFLARE_API_KEY: ${{ secrets.CLOUDFLARE_API_KEY }}
```