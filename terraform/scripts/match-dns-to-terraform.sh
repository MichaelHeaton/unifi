#!/bin/bash

# Match DNS records from API with Terraform resource names
# Creates a mapping file for import

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Load credentials
if [ -f "$TERRAFORM_DIR/terraform.tfvars" ]; then
    UNIFI_API_URL=$(grep "^unifi_api_url" "$TERRAFORM_DIR/terraform.tfvars" | cut -d'"' -f2 | head -1)
    UNIFI_UDM_API_KEY=$(grep "^unifi_udm_api_key" "$TERRAFORM_DIR/terraform.tfvars" | cut -d'"' -f2 | head -1)
fi

UNIFI_API_URL="${TF_VAR_unifi_api_url:-${UNIFI_API_URL:-https://unifi.mgmt.specterrealm.com}}"
UNIFI_UDM_API_KEY="${TF_VAR_unifi_udm_api_key:-${UNIFI_UDM_API_KEY}}"

OUTPUT_FILE="$TERRAFORM_DIR/dns-terraform-mapping.txt"

echo "🔗 Matching DNS Records to Terraform Resources"
echo "=============================================="
echo ""

# Fetch DNS records
response=$(curl -s -k -X GET \
    -H "X-API-KEY: $UNIFI_UDM_API_KEY" \
    -H "Accept: application/json" \
    "$UNIFI_API_URL/proxy/network/v2/api/site/default/static-dns")

if [ $? -ne 0 ] || [ -z "$response" ]; then
    echo "❌ Failed to fetch DNS records"
    exit 1
fi

# Create mapping file
cat > "$OUTPUT_FILE" << EOF
# DNS Record to Terraform Resource Mapping
# Generated: $(date)
# Format: terraform_resource_name|domain_name|id|type|value

EOF

# Function to normalize domain name to Terraform resource name
normalize_name() {
    local key="$1"
    # Convert to lowercase
    key=$(echo "$key" | tr '[:upper:]' '[:lower:]')
    # Remove domain suffixes
    key=$(echo "$key" | sed 's/\.specterrealm\.com$//' | sed 's/\.mgmt\.specterrealm\.com$//')
    # Replace special chars with underscores
    key=$(echo "$key" | sed 's/[^a-z0-9_]/_/g' | sed 's/__*/_/g' | sed 's/^_\|_$//g')
    echo "$key"
}

# Extract and map each record
echo "$response" | jq -r '.[] | "\(.key)|\(._id)|\(.value)|\(.record_type)"' 2>/dev/null | while IFS='|' read -r key id value type; do
    terraform_name=$(normalize_name "$key")
    echo "${terraform_name}|${key}|${id}|${type}|${value}" >> "$OUTPUT_FILE"
done

echo "✅ Mapping created: $OUTPUT_FILE"
echo ""
echo "Total DNS records: $(cat "$OUTPUT_FILE" | grep -v '^#' | wc -l | xargs)"
echo ""
echo "Next: Review the mapping and add missing records to dns-records.tf"

