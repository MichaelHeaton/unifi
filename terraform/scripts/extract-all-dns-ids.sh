#!/bin/bash

# Extract all DNS record IDs from UniFi v2 API and match with Terraform resources

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

OUTPUT_FILE="$TERRAFORM_DIR/all-dns-ids.txt"

echo "🔍 Extracting All DNS Record IDs from UniFi v2 API"
echo "=================================================="
echo "API URL: $UNIFI_API_URL"
echo ""

# Fetch all DNS records
response=$(curl -s -k -X GET \
    -H "X-API-KEY: $UNIFI_UDM_API_KEY" \
    -H "Accept: application/json" \
    "$UNIFI_API_URL/proxy/network/v2/api/site/default/static-dns")

if [ $? -eq 0 ] && [ -n "$response" ]; then
    if command -v jq &> /dev/null; then
        count=$(echo "$response" | jq -r '. | length' 2>/dev/null)
        echo "✅ Found $count DNS records"
        echo ""

        # Create output file
        cat > "$OUTPUT_FILE" << EOF
# All DNS Record IDs from UniFi v2 API
# Generated: $(date)
# Total records: $count

EOF

        # Extract each record
        echo "$response" | jq -r '.[] | "\(.key)|\(._id)|\(.value)|\(.record_type)"' 2>/dev/null | while IFS='|' read -r key id value type; do
            # Normalize key for Terraform resource name
            clean_name=$(echo "$key" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_]/_/g' | sed 's/__*/_/g' | sed 's/^_\|_$//g')
            echo "# $key ($type -> $value)" >> "$OUTPUT_FILE"
            echo "unifi_dns_record.${clean_name} = \"$id\"" >> "$OUTPUT_FILE"
        done

        echo "✅ IDs extracted and saved to: $OUTPUT_FILE"
    else
        echo "❌ jq not installed - cannot parse JSON"
        exit 1
    fi
else
    echo "❌ Failed to fetch DNS records"
    exit 1
fi

echo ""
echo "📋 Next steps:"
echo "1. Review $OUTPUT_FILE"
echo "2. Match DNS record names with Terraform configuration"
echo "3. Add missing records to dns-records.tf"
echo "4. Update import-ids.txt with all IDs"
echo "5. Import all missing DNS records"

