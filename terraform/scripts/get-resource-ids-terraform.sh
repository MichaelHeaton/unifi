#!/bin/bash

# Get Resource IDs using Terraform Provider
# This script uses Terraform to query the UniFi API and extract resource IDs

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
OUTPUT_FILE="${1:-$TERRAFORM_DIR/import-ids.txt}"

cd "$TERRAFORM_DIR"

echo "🔍 Extracting resource IDs using Terraform provider"
echo "Output: $OUTPUT_FILE"
echo ""

# Create a temporary Terraform file to query resources
cat > /tmp/unifi-query.tf << 'EOF'
# Temporary file to query UniFi resources

# Query all networks
data "unifi_network" "all" {
  for_each = toset([
    "default",
    "family",
    "production",
    "cluster",
    "mgmt_admin",
    "lab",
    "storage",
    "dmz",
    "parking",
    "guest",
    "iot"
  ])
  name = each.key
}

# Query all WLANs (we'll need to list them differently)
# Note: UniFi provider doesn't have a data source to list all WLANs
# We'll need to use the API directly or import existing resources

output "network_ids" {
  value = {
    for k, v in data.unifi_network.all : k => v.id
  }
}

output "network_names" {
  value = {
    for k, v in data.unifi_network.all : k => v.name
  }
}
EOF

# Try to get network IDs using Terraform
echo "Querying networks via Terraform..."
if terraform init -backend=false > /dev/null 2>&1; then
    terraform apply -auto-approve -target=data.unifi_network.all > /dev/null 2>&1 || true
    NETWORK_OUTPUT=$(terraform output -json network_ids 2>/dev/null || echo "{}")

    if [ "$NETWORK_OUTPUT" != "{}" ] && [ -n "$NETWORK_OUTPUT" ]; then
        echo "$NETWORK_OUTPUT" | grep -o '"[^"]*":"[^"]*"' | while IFS=':' read -r key value; do
            name=$(echo "$key" | tr -d '"')
            id=$(echo "$value" | tr -d '"')
            echo "Found network: $name = $id"
        done
    fi
fi

# Cleanup
rm -f /tmp/unifi-query.tf

echo ""
echo "⚠️  Note: Terraform data sources are limited."
echo "For complete resource extraction, use the UniFi API directly."
echo ""
echo "Alternative: Use terraform import with resource names from your config files"
echo "and get IDs from the UniFi controller web UI or API."

