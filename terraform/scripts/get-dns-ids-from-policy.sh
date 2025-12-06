#!/bin/bash

# Get DNS Record IDs from UniFi Policy API
# DNS records are stored as policies with type "dns" in UniFi OS

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Load credentials from terraform.tfvars
if [ -f "$TERRAFORM_DIR/terraform.tfvars" ]; then
    UNIFI_API_URL=$(grep "^unifi_api_url" "$TERRAFORM_DIR/terraform.tfvars" | cut -d'"' -f2 | head -1)
    UNIFI_SITE=$(grep "^unifi_site" "$TERRAFORM_DIR/terraform.tfvars" | cut -d'"' -f2 | head -1)
    UNIFI_UDM_API_KEY=$(grep "^unifi_udm_api_key" "$TERRAFORM_DIR/terraform.tfvars" | cut -d'"' -f2 | head -1)
fi

# Override with environment variables if set
UNIFI_API_URL="${TF_VAR_unifi_api_url:-${UNIFI_API_URL:-https://unifi.mgmt.specterrealm.com}}"
UNIFI_SITE="${TF_VAR_unifi_site:-${UNIFI_SITE:-default}}"
UNIFI_UDM_API_KEY="${TF_VAR_unifi_udm_api_key:-${UNIFI_UDM_API_KEY}}"

OUTPUT_FILE="${1:-$TERRAFORM_DIR/dns-ids-from-policy.txt}"

echo "🔍 Extracting DNS Record IDs from UniFi Policy API"
echo "==================================================="
echo "API URL: $UNIFI_API_URL"
echo "Site: $UNIFI_SITE"
echo "Output: $OUTPUT_FILE"
echo ""

# Remove trailing slash
UNIFI_API_URL="${UNIFI_API_URL%/}"
BASE_URL="$UNIFI_API_URL/proxy/network/api/s/$UNIFI_SITE"

# Query policy API for DNS records
echo "Querying policy API for DNS records..."
url="$BASE_URL/rest/policy"

if [ -n "$UNIFI_UDM_API_KEY" ]; then
    response=$(curl -s -k -X GET \
        -H "X-API-KEY: $UNIFI_UDM_API_KEY" \
        -H "Accept: application/json" \
        "$url" 2>&1)
else
    echo "❌ Error: No API key provided"
    exit 1
fi

# Create output file
cat > "$OUTPUT_FILE" << EOF
# DNS Record IDs Extracted from UniFi Policy API
# Generated: $(date)
# API URL: $UNIFI_API_URL
# Site: $UNIFI_SITE

EOF

if [ $? -eq 0 ] && [ -n "$response" ] && ! echo "$response" | grep -q '"rc":"error"'; then
    if command -v jq &> /dev/null; then
        # Parse JSON response - filter for DNS policies
        dns_policies=$(echo "$response" | jq -r '.data[] | select(.type == "dns")' 2>/dev/null)

        if [ -n "$dns_policies" ]; then
            echo "$dns_policies" | jq -s '.' | jq -r '.[] | "\(.domain_name // .name // "unknown")|\(._id)|\(.value // .ip_address // "unknown")|\(.record_type // "A")"' 2>/dev/null | while IFS='|' read -r name id value type; do
                if [ -n "$id" ] && [ "$id" != "null" ] && [ "$id" != "" ]; then
                    # Normalize name for Terraform resource name
                    clean_name=$(echo "$name" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_]/_/g' | sed 's/__*/_/g' | sed 's/^_\|_$//g')
                    echo "# $name ($type -> $value)" >> "$OUTPUT_FILE"
                    echo "unifi_dns_record.${clean_name} = \"$id\"" >> "$OUTPUT_FILE"
                fi
            done
            count=$(echo "$dns_policies" | jq -s '. | length' 2>/dev/null)
            echo "  ✅ Found $count DNS record(s)"
        else
            echo "  ⚠️  No DNS policies found"
            echo "# No DNS records found" >> "$OUTPUT_FILE"
        fi
    else
        echo "  ⚠️  jq not installed - cannot parse JSON"
        echo "# Install jq to parse DNS records" >> "$OUTPUT_FILE"
    fi
else
    echo "  ❌ API error"
    error_msg=$(echo "$response" | jq -r '.meta.msg // "Unknown error"' 2>/dev/null || echo "Unknown error")
    echo "  Error: $error_msg"
    echo "# DNS records: API error - $error_msg" >> "$OUTPUT_FILE"
fi

echo ""
echo "✅ Extraction complete! IDs saved to: $OUTPUT_FILE"
echo ""
echo "📋 Next steps:"
echo "1. Review the extracted IDs in $OUTPUT_FILE"
echo "2. Match DNS record names with your Terraform configuration (dns-records.tf)"
echo "3. Update import-ids.txt with the correct IDs"
echo "4. Import DNS records: terraform import unifi_dns_record.<name> <id>"

