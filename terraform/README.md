# UniFi Terraform Infrastructure

This directory contains Terraform configurations for managing the UniFi network infrastructure.

## Structure

```
terraform/
├── main.tf                    # Main configuration
├── terraform.tf              # Provider and backend configuration
├── config.tf                 # Centralized configuration
├── variables.tf              # Variable definitions
├── outputs.tf                # Output definitions
├── terraform.tfvars.example  # Example variable values
├── vlans.tf                  # VLAN definitions
├── wlans.tf                  # WLAN (WiFi) definitions
├── firewall-groups.tf        # Firewall group definitions
├── firewall-rules.tf         # Firewall rule definitions
├── dns-records.tf            # DNS record definitions
├── static-routes.tf          # Static route definitions
├── user-groups.tf            # User group definitions
├── vault-integration.tf      # Vault provider configuration
├── modules/                  # Reusable Terraform modules
│   ├── unifi-network/       # Network resources module
│   ├── unifi-security/       # Security resources module
│   └── network-site/         # Multi-site network configuration module
├── shared/                   # Shared configuration
│   ├── common-variables.tf
│   └── vault-integration.tf
├── scripts/                  # Terraform utility scripts
│   ├── deploy-fw-u36.sh
│   ├── deploy-rv.sh
│   ├── import-dns-records.sh
│   ├── import-firewall-rules.sh
│   └── ...
└── README.md                 # This file
```

## Getting Started

### Prerequisites

1. **HCP Terraform Cloud Account**: You need a HashiCorp Cloud Platform account with a Terraform Cloud organization
2. **Workspace Created**: Create a workspace named `homelab-unifi` in HCP Terraform with CLI-driven workflow
3. **HashiCorp Vault**: Vault is required for storing UniFi API credentials and WLAN passwords
4. **UniFi Controller**: Ensure your UniFi controller has API access enabled

### Initial Setup

1. **Copy the example variables file**:

   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Fill in your values** in `terraform.tfvars`:

   - `unifi_api_url`: Your UniFi controller API URL (e.g., `https://unifi-mgmt.specterrealm.com`)
   - `unifi_site`: Your UniFi site name (e.g., `default`)
   - `unifi_allow_insecure`: Set to `true` if using self-signed certificate, `false` otherwise

   **Note**: HCP organization name is set in `terraform.tf` (currently "SpecterRealm") and can be overridden via `TF_CLOUD_ORGANIZATION` environment variable.

3. **Configure Vault secrets**:

   UniFi credentials and WLAN passwords are stored in HashiCorp Vault. Ensure the following secrets exist:

   - `secret/unifi/controller-credentials` with keys: `unifi_username`, `unifi_password`, `unifi_api_key`
   - `secret/unifi/wlan/main` with keys: `password`, `ssid`
   - `secret/unifi/wlan/iot` with keys: `password`, `ssid`
   - `secret/unifi/wlan/guest` with keys: `password`, `ssid`

   See `scripts/store-unifi-credentials.sh` for an example of how to store credentials.

4. **Set Vault token**:

   ```bash
   export VAULT_TOKEN="your-vault-token"
   export VAULT_ADDR="https://vault.specterrealm.com"
   ```

5. **Authenticate with HCP**:

   ```bash
   terraform login
   ```

   This will open a browser to authenticate and generate an API token.

6. **Initialize Terraform**:

   ```bash
   terraform init
   ```

   This will:

   - Download the UniFi and Vault providers
   - Connect to HCP Terraform Cloud backend
   - Configure remote state storage

7. **Validate configuration**:

   ```bash
   terraform fmt
   terraform validate
   ```

8. **Plan changes**:

   ```bash
   terraform plan -out tfplan
   ```

9. **Apply changes** (when ready):
   ```bash
   terraform apply tfplan
   ```

## Workflow

### Always Run

1. **Terraform fmt**: Format code

   ```bash
   terraform fmt
   ```

2. **Terraform validate**: Validate configuration

   ```bash
   terraform validate
   ```

3. **Terraform plan**: Create execution plan
   ```bash
   terraform plan -out tfplan
   ```

### Never Run

- **terraform apply**: Never run without a plan file
  ```bash
  # Always use:
  terraform apply tfplan
  ```

## State Management

### Remote State

- **Backend**: HashiCorp Cloud Platform (Terraform Cloud)
- **Location**: Remote state stored in HCP
- **Encryption**: At rest and in transit (managed by HashiCorp)
- **Locking**: Automatic state locking (managed by Terraform Cloud)
- **Versioning**: Automatic state versioning (managed by Terraform Cloud)
- **Workflow**: CLI-driven (manual runs via `terraform apply`)

### State File Security

- **Never Commit**: State files to Git
- **Backup**: Automatic backups managed by HCP
- **Access**: Restricted to workspace access

## Resources Managed

### Network Resources

- **VLANs**: Network VLANs with DHCP configuration
- **WLANs**: WiFi networks with security settings
- **DNS Records**: Static DNS records
- **Static Routes**: Static routing configuration
- **User Groups**: Client groups with bandwidth limits

### Security Resources

- **Firewall Groups**: Address and port groups
- **Firewall Rules**: Firewall rule definitions

### Current Configuration

- **11 VLANs**: Default, Family, Production, Cluster, Mgmt-Admin, Lab, Storage, DMZ, Parking, Guest, IoT
- **5 WLANs**: Skynet Global Defense Network, SkyNet, SkyNet_IoT, WiFightClub, BigBrothersWiFi
- **22 DNS Records**: Static A records for infrastructure devices (see `dns-records.tf`)
- **11 Firewall Groups**: Admin targets, cluster nodes, DNS servers, storage targets, etc.
- **1 Static Route**: VPN to LAN routing
- **2 User Groups**: Default and Guest

## Importing Existing Resources

All existing UniFi resources have been imported into Terraform. To import new resources:

1. **Identify the resource** in your UniFi controller
2. **Add the resource** to your Terraform configuration
3. **Import the resource**:
   ```bash
   terraform import unifi_network.example_network <network-id>
   ```
4. **Verify the import**:
   ```bash
   terraform plan
   ```
   Should show no changes if import was successful

### Active Utility Scripts

- `scripts/review-dns-records.sh`: Review and test DNS records
- `scripts/list-all-dns-records.sh`: List all DNS records

**Note**: One-time import scripts have been archived to `scripts/archive/` as they are no longer needed.

## Vault Integration

This configuration uses HashiCorp Vault for secrets management:

- **UniFi Credentials**: Stored in `secret/unifi/controller-credentials`
- **WLAN Passwords**: Stored in `secret/unifi/wlan/{role}` (main, iot, guest)
- **Vault Provider**: Configured in `terraform.tf` and `vault-integration.tf`

### Setting Up Vault Secrets

```bash
# Store UniFi controller credentials
vault kv put secret/unifi/controller-credentials \
  unifi_username="admin" \
  unifi_password="password" \
  unifi_api_key="api-key"

# Store WLAN passwords
vault kv put secret/unifi/wlan/main \
  password="wifi-password" \
  ssid="NetworkName"

vault kv put secret/unifi/wlan/iot \
  password="iot-password" \
  ssid="IoTNetwork"

vault kv put secret/unifi/wlan/guest \
  password="guest-password" \
  ssid="GuestNetwork"
```

## Provider Documentation

- **UniFi Provider**: [ubiquiti-community/terraform-provider-unifi](https://github.com/ubiquiti-community/terraform-provider-unifi)
- **Vault Provider**: [hashicorp/terraform-provider-vault](https://registry.terraform.io/providers/hashicorp/vault/latest/docs)

## Notes

- State is stored remotely in HCP Terraform Cloud
- All runs are executed locally (CLI-driven workflow)
- Sensitive variables (API keys, passwords) are stored in Vault, not in tfvars files
- Follow Terraform standards in `../specs-homelab/standards/terraform-standards.md`
- Network configuration is centralized in `config.tf` using locals

## Troubleshooting

### Vault Connection Issues

If Vault connection fails:

- Verify `VAULT_ADDR` and `VAULT_TOKEN` environment variables
- Check that Vault is accessible from your network
- Ensure the secrets exist in Vault

### UniFi API Issues

If UniFi API connection fails:

- Verify API credentials in Vault
- Check that `unifi_allow_insecure` is set correctly for self-signed certificates
- Ensure API access is enabled on the UniFi controller

### Backend Connection Issues

If HCP connection fails:

- Verify the workspace name matches: `homelab-unifi`
- Check that the organization name is correct
- Ensure you have workspace access permissions
- Run `terraform login` to refresh authentication
