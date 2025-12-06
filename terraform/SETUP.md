# UniFi Terraform Setup Guide

## Quick Start Checklist

### 1. Create HCP Terraform Cloud Workspace

1. Log in to [HashiCorp Cloud Platform](https://app.terraform.io)
2. Navigate to your organization
3. Click **"New Workspace"**
4. Choose **"CLI-Driven Workflow"** (not VCS-driven)
5. Name the workspace: `homelab-unifi`
6. Click **"Create Workspace"**

### 2. Configure Credentials

You have two options for providing credentials:

#### Option A: Using HashiCorp Vault (if available)

1. **Set Vault environment variables**:

   ```bash
   export VAULT_ADDR="https://vault.specterrealm.com"
   export VAULT_TOKEN="your-vault-token"
   ```

2. **Store UniFi controller credentials**:

   ```bash
   vault kv put secret/unifi/controller-credentials \
     unifi_username="admin" \
     unifi_password="your-password" \
     unifi_api_key="your-api-key"
   ```

   Or use the provided script:

   ```bash
   ./scripts/store-unifi-credentials.sh
   ```

3. **Store WLAN passwords**:

   ```bash
   vault kv put secret/unifi/wlan/main \
     password="main-wifi-password" \
     ssid="MainNetworkName"

   vault kv put secret/unifi/wlan/iot \
     password="iot-wifi-password" \
     ssid="IoTNetworkName"

   vault kv put secret/unifi/wlan/guest \
     password="guest-wifi-password" \
     ssid="GuestNetworkName"
   ```

4. **Set use_vault = true** in `terraform.tfvars`

#### Option B: Using Variables (if Vault is unavailable)

1. **Set use_vault = false** in `terraform.tfvars`

2. **Provide credentials via environment variables** (recommended for security):

   ```bash
   export TF_VAR_unifi_api_key="your-api-key"
   export TF_VAR_unifi_username="admin"
   export TF_VAR_unifi_password="your-password"
   export TF_VAR_wlan_main_password="main-wifi-password"
   export TF_VAR_wlan_main_ssid="MainNetworkName"
   export TF_VAR_wlan_iot_password="iot-wifi-password"
   export TF_VAR_wlan_iot_ssid="IoTNetworkName"
   export TF_VAR_wlan_guest_password="guest-wifi-password"
   export TF_VAR_wlan_guest_ssid="GuestNetworkName"
   ```

   Or add them directly to `terraform.tfvars` (less secure, but gitignored):

   ```hcl
   use_vault = false
   unifi_api_key  = "your-api-key-here"
   unifi_username = "admin"
   unifi_password = "your-password-here"
   wlan_main_password  = "main-wifi-password"
   wlan_main_ssid      = "MainNetworkName"
   # ... etc
   ```

### 3. Local Configuration

1. **Copy the example file**:

   ```bash
   cd /Users/michaelheaton/Projects/HomeLab/unifi/terraform
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Edit `terraform.tfvars`** with your values:

   ```hcl
   unifi_api_url        = "https://unifi.mgmt.specterrealm.com"
   unifi_site           = "default"
   unifi_allow_insecure = true
   ```

   **Note**: HCP organization name is set in `terraform.tf` (currently "SpecterRealm").
   To use a different organization, either:

   - Edit `terraform.tf` and change the organization name, or
   - Set the `TF_CLOUD_ORGANIZATION` environment variable

### 4. Authenticate with HCP

```bash
terraform login
```

This will:

- Open your browser
- Authenticate with HCP
- Save credentials locally

### 5. Initialize Terraform

```bash
terraform init
```

This will:

- Download the UniFi and Vault providers
- Connect to HCP Terraform Cloud
- Set up remote state backend

### 6. Verify Configuration

```bash
# Format code
terraform fmt

# Validate configuration
terraform validate
```

### 7. Test Connection (Optional)

You can test the connection by running a plan:

```bash
terraform plan
```

This should connect to HCP, Vault, and the UniFi controller and show the current state.

## Next Steps

Once the basic setup is working:

1. **Review existing resources** in the UniFi controller
2. **Import existing resources** if needed (see import scripts)
3. **Test with plan** before applying
4. **Apply changes** when ready

## Importing Click-Ops Changes

If you've made changes in the UniFi controller UI (click-ops), you can import them:

### Import DNS Records

```bash
./scripts/import-dns-records.sh
```

### Import Firewall Rules

```bash
./scripts/import-firewall-rules.sh
```

### Import WLANs

```bash
./scripts/import-wlans.sh
```

### Import Static Routes

```bash
./scripts/import-static-routes.sh
```

## Troubleshooting

### Authentication Issues

If `terraform login` fails:

- Make sure you're logged into HCP in your browser
- Check that you have access to the organization
- Try logging out and back in: `terraform logout` then `terraform login`

### Backend Connection Issues

If `terraform init` fails to connect:

- Verify the workspace name matches: `homelab-unifi`
- Check that the organization name is correct
- Ensure you have workspace access permissions

### Vault Connection Issues

If Vault is unavailable or connection fails:

- **Option 1**: Set `use_vault = false` in `terraform.tfvars` and provide credentials via variables or environment variables (see Option B in step 2)
- **Option 2**: If you want to use Vault, verify `VAULT_ADDR` and `VAULT_TOKEN` environment variables
- Check that Vault is accessible from your network
- Ensure the secrets exist in Vault (see step 2, Option A)

### UniFi API Issues

If the UniFi provider fails:

- Check that your UniFi controller is accessible
- Verify the API URL, site name, and credentials in Vault
- Check if `unifi_allow_insecure = true` is needed for self-signed certificates
- Ensure API access is enabled on your UniFi controller

### Provider Issues

If providers fail to download:

- Check your internet connection
- Verify Terraform version (>= 1.0 required)
- Try clearing the provider cache: `rm -rf .terraform`

## Workspace Configuration Summary

- **Workspace Name**: `homelab-unifi`
- **Workflow Type**: CLI-Driven
- **Execution Mode**: Local (runs on your machine)
- **State Storage**: Remote (HCP Terraform Cloud)
- **Organization**: Set via variable or environment variable

## Reference

- Full documentation: [README.md](README.md)
- Terraform standards: [`../../specs-homelab/standards/terraform-standards.md`](../../specs-homelab/standards/terraform-standards.md)
- UniFi infrastructure docs: [`../../specs-homelab/infrastructure/unifi.md`](../../specs-homelab/infrastructure/unifi.md)
