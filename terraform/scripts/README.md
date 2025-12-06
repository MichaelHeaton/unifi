# Terraform Import Scripts

This directory contains scripts to help with importing existing UniFi resources into Terraform.

## Available Scripts

### `get-resource-ids-curl.sh` (Recommended)

**Purpose**: Extract resource IDs from the UniFi controller via API for Terraform import (uses curl, no Python dependencies).

**Usage**:

```bash
cd terraform
./scripts/get-resource-ids-curl.sh [output-file]
```

**Requirements**:

- UniFi credentials configured in `terraform.tfvars` or environment variables
- `curl` (usually pre-installed)
- `jq` (optional, for better parsing - install with `brew install jq`)

**Output**:

- Creates a file (default: `import-ids.txt`) with resource IDs formatted for Terraform import

**Example**:

```bash
# Extract IDs using credentials from terraform.tfvars
./scripts/get-resource-ids-curl.sh

# Or specify output file
./scripts/get-resource-ids-curl.sh my-import-ids.txt
```

### `get-resource-ids.sh` (Alternative)

**Purpose**: Extract resource IDs from the UniFi controller via API (Python version).

**Usage**:

```bash
cd terraform
./scripts/get-resource-ids.sh [output-file]
```

**Requirements**:

- UniFi credentials configured in `terraform.tfvars` or environment variables
- Python 3 with `requests` library: `pip3 install requests`

**Note**: Use `get-resource-ids-curl.sh` instead if you don't have Python dependencies installed.

### `extract-ids-from-backup.sh`

**Purpose**: Extract resource IDs from a UniFi backup file (if backup format is supported).

**Usage**:

```bash
cd terraform
./scripts/extract-ids-from-backup.sh [backup-file] [output-file]
```

**Note**: UniFi backup files may be encrypted or in a proprietary format. If this script doesn't work, use `get-resource-ids.sh` instead.

### `import-dns-records.sh`

**Purpose**: Import DNS records into Terraform state.

**Usage**:

```bash
cd terraform
./scripts/import-dns-records.sh
```

**Note**: Update the script with the correct resource IDs before running.

### `import-firewall-rules.sh`

**Purpose**: Import firewall rules into Terraform state.

**Usage**:

```bash
cd terraform
./scripts/import-firewall-rules.sh
```

### `import-wlans.sh`

**Purpose**: Import WLANs into Terraform state.

**Usage**:

```bash
cd terraform
./scripts/import-wlans.sh
```

### `import-static-routes.sh`

**Purpose**: Import static routes into Terraform state.

**Usage**:

```bash
cd terraform
./scripts/import-static-routes.sh
```

## Import Workflow

1. **Extract Resource IDs**:

   ```bash
   ./scripts/get-resource-ids.sh
   ```

2. **Review the extracted IDs**:

   ```bash
   cat import-ids.txt
   ```

3. **Match resource names** with your Terraform configuration files:

   - `vlans.tf` - Network resources
   - `wlans.tf` - WLAN resources
   - `firewall-groups.tf` - Firewall group resources
   - `dns-records.tf` - DNS record resources
   - etc.

4. **Import resources**:

   ```bash
   terraform import unifi_network.default <network-id>
   terraform import unifi_wlan.skynet_global_defense <wlan-id>
   # etc.
   ```

5. **Verify imports**:
   ```bash
   terraform plan
   ```
   Should show no changes if imports were successful.

## Troubleshooting

### API Authentication Issues

If `get-resource-ids.sh` fails with authentication errors:

1. Verify credentials in `terraform.tfvars`:

   ```hcl
   unifi_api_key  = "your-api-key"
   unifi_username = "admin"
   unifi_password = "password"
   ```

2. Or set environment variables:

   ```bash
   export TF_VAR_unifi_api_key="your-api-key"
   export TF_VAR_unifi_username="admin"
   export TF_VAR_unifi_password="password"
   ```

3. Check API URL and site name are correct

### Missing Python Dependencies

Install required Python packages:

```bash
pip3 install requests urllib3
```

### SSL Certificate Issues

If using self-signed certificates, the script will automatically disable SSL verification. For production, configure proper SSL certificates.

## Notes

- Resource IDs are unique identifiers assigned by the UniFi controller
- Resource names in Terraform should match or be mapped to the actual resource names
- Some resources may have dependencies (e.g., WLANs depend on Networks)
- Import resources in the correct order to avoid dependency issues
