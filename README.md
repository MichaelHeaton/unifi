# UniFi Network Infrastructure

This repository contains infrastructure-as-code and documentation for managing UniFi network infrastructure in the homelab.

## Overview

This repository manages:

- **UniFi Network Configuration**: VLANs, WLANs, firewall rules, DNS records, and static routes
- **Terraform Infrastructure**: Complete Terraform configuration for managing UniFi resources

**Note**: NAS02 (UniFi UNAS Pro) storage configuration documentation has been moved to `specs-homelab/storage/`.

## Repository Structure

```
unifi/
├── README.md                    # This file
├── LICENSE                      # License file
├── terraform/                   # Terraform infrastructure
│   ├── README.md               # Terraform documentation
│   ├── SETUP.md                # Terraform setup guide
│   ├── main.tf                 # Main Terraform configuration
│   ├── terraform.tf             # Provider and backend configuration
│   ├── config.tf                # Centralized configuration
│   ├── vlans.tf                 # VLAN definitions
│   ├── wlans.tf                 # WLAN definitions
│   ├── firewall-groups.tf       # Firewall group definitions
│   ├── firewall-rules.tf        # Firewall rule definitions
│   ├── dns-records.tf           # DNS record definitions
│   ├── static-routes.tf         # Static route definitions
│   ├── user-groups.tf           # User group definitions
│   ├── vault-integration.tf     # Vault integration
│   ├── modules/                 # Terraform modules
│   ├── scripts/                 # Utility scripts
│   └── shared/                  # Shared configuration
└── backup/                      # UniFi backup files
    └── unifi_os_backup_*.unifi
```

## Quick Start

### Terraform Setup

1. **Create HCP Terraform Cloud Workspace**:

   - Log in to [HashiCorp Cloud Platform](https://app.terraform.io)
   - Create a new workspace named `homelab-unifi` with CLI-driven workflow

2. **Configure Vault Secrets**:

   - Store UniFi credentials in Vault (see `terraform/SETUP.md`)

3. **Initialize Terraform**:

   ```bash
   cd terraform
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   terraform login
   terraform init
   ```

4. **Plan and Apply**:
   ```bash
   terraform plan -out tfplan
   terraform apply tfplan
   ```

For detailed setup instructions, see [terraform/SETUP.md](terraform/SETUP.md).

## Documentation

### Terraform

- **[terraform/README.md](terraform/README.md)**: Complete Terraform documentation
- **[terraform/SETUP.md](terraform/SETUP.md)**: Step-by-step setup guide

### NAS02 (UniFi UNAS Pro)

NAS02 storage configuration documentation has been moved to the specs-homelab repository:

- **[NAS02_NFS_CONFIG.md](../../specs-homelab/storage/NAS02_NFS_CONFIG.md)**: NFS configuration and mount information
- **[NAS02_SHARES_REVIEW.md](../../specs-homelab/storage/NAS02_SHARES_REVIEW.md)**: Share configuration review

## Features

### Network Management

- **11 VLANs**: Default, Family, Production, Cluster, Mgmt-Admin, Lab, Storage, DMZ, Parking, Guest, IoT
- **5 WLANs**: Skynet Global Defense Network, SkyNet, SkyNet_IoT, WiFightClub, BigBrothersWiFi
- **DNS Records**: Static A and CNAME records
- **Firewall Groups**: Address and port groups for security policies
- **Static Routes**: VPN and network routing configuration

### Infrastructure as Code

- **Terraform**: Complete infrastructure-as-code for UniFi resources
- **HCP Backend**: Remote state management via HashiCorp Cloud Platform
- **Vault Integration**: Secure secrets management for API keys and passwords
- **Modular Design**: Reusable modules for network and security resources

### Import Scripts

Scripts are available to import existing resources from the UniFi controller:

- `terraform/scripts/import-dns-records.sh`: Import DNS records
- `terraform/scripts/import-firewall-rules.sh`: Import firewall rules
- `terraform/scripts/import-wlans.sh`: Import WLANs
- `terraform/scripts/import-static-routes.sh`: Import static routes

## Prerequisites

- **Terraform** >= 1.0
- **HashiCorp Cloud Platform** account with Terraform Cloud organization
- **HashiCorp Vault** for secrets management
- **UniFi Controller** with API access enabled

## Workflow

### Making Changes

1. **Plan changes**:

   ```bash
   cd terraform
   terraform fmt
   terraform validate
   terraform plan -out tfplan
   ```

2. **Review the plan** to ensure changes are correct

3. **Apply changes**:
   ```bash
   terraform apply tfplan
   ```

### Importing Click-Ops Changes

If you've made changes in the UniFi controller UI, use the import scripts to bring them into Terraform:

```bash
cd terraform/scripts
./import-dns-records.sh
./import-firewall-rules.sh
# etc.
```

## State Management

- **Backend**: HashiCorp Cloud Platform (Terraform Cloud)
- **Workflow**: CLI-driven (manual runs)
- **State Location**: Remote (HCP Terraform Cloud)
- **Locking**: Automatic state locking
- **Versioning**: Automatic state versioning

## Security

- **Secrets**: All sensitive data (API keys, passwords) stored in HashiCorp Vault
- **State**: Remote state stored securely in HCP with encryption at rest and in transit
- **Access**: Workspace access restricted to authorized users

## Related Repositories

- **specs-homelab**: Infrastructure documentation and specifications
- **proxmox**: Proxmox virtualization infrastructure
- **synology**: Synology NAS infrastructure

## Contributing

This repository is part of the homelab multi-repo structure. Follow the Terraform standards documented in `specs-homelab/standards/terraform-standards.md`.

## License

See [LICENSE](LICENSE) file for details.

---

**Part of the [SpecterRealm Homelab](https://github.com/SpecterRealm/homelab) infrastructure**
