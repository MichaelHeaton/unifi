#!/bin/bash

# Get Resource IDs from UniFi Controller via API (using curl)
# This script queries the UniFi API to extract resource IDs for Terraform import

set -e

# Load credentials from terraform.tfvars or environment
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

if [ -f "$TERRAFORM_DIR/terraform.tfvars" ]; then
    UNIFI_API_URL=$(grep "^unifi_api_url" "$TERRAFORM_DIR/terraform.tfvars" | cut -d'"' -f2 | head -1)
    UNIFI_SITE=$(grep "^unifi_site" "$TERRAFORM_DIR/terraform.tfvars" | cut -d'"' -f2 | head -1)
    UNIFI_API_KEY=$(grep "^unifi_api_key" "$TERRAFORM_DIR/terraform.tfvars" | cut -d'"' -f2 | head -1)
    UNIFI_USERNAME=$(grep "^unifi_username" "$TERRAFORM_DIR/terraform.tfvars" | cut -d'"' -f2 | head -1)
    UNIFI_PASSWORD=$(grep "^unifi_password" "$TERRAFORM_DIR/terraform.tfvars" | cut -d'"' -f2 | head -1)
fi

# Override with environment variables if set
UNIFI_API_URL="${TF_VAR_unifi_api_url:-${UNIFI_API_URL:-https://unifi.mgmt.specterrealm.com}}"
UNIFI_SITE="${TF_VAR_unifi_site:-${UNIFI_SITE:-default}}"
UNIFI_API_KEY="${TF_VAR_unifi_api_key:-${UNIFI_API_KEY}}"
UNIFI_USERNAME="${TF_VAR_unifi_username:-${UNIFI_USERNAME}}"
UNIFI_PASSWORD="${TF_VAR_unifi_password:-${UNIFI_PASSWORD}}"

if [ -z "$UNIFI_API_KEY" ] && [ -z "$UNIFI_USERNAME" ]; then
    echo "❌ Error: UniFi credentials not found"
    echo "Set TF_VAR_unifi_api_key or provide credentials in terraform.tfvars"
    exit 1
fi

OUTPUT_FILE="${1:-$TERRAFORM_DIR/import-ids.txt}"

echo "🔍 Extracting resource IDs from UniFi Controller"
echo "API URL: $UNIFI_API_URL"
echo "Site: $UNIFI_SITE"
echo "Output: $OUTPUT_FILE"
echo ""

# Remove trailing slash from API URL
UNIFI_API_URL="${UNIFI_API_URL%/}"
BASE_URL="$UNIFI_API_URL/api/s/$UNIFI_SITE"

# Create output file
cat > "$OUTPUT_FILE" << EOF
# Terraform Import IDs Extracted from UniFi Controller
# API URL: $UNIFI_API_URL
# Site: $UNIFI_SITE
# Generated: $(date)

EOF

# Function to query API endpoint
query_api() {
    local endpoint=$1
    local resource_type=$2
    local url="$BASE_URL/$endpoint"

    echo "Querying $resource_type..."

    if [ -n "$UNIFI_API_KEY" ]; then
        # Use API key authentication
        response=$(curl -s -k -X GET \
            -H "Authorization: Bearer $UNIFI_API_KEY" \
            -H "Content-Type: application/json" \
            "$url")
    else
        # Login first to get session cookie
        login_url="$UNIFI_API_URL/api/login"
        login_response=$(curl -s -k -c /tmp/unifi_cookies.txt -X POST \
            -H "Content-Type: application/json" \
            -d "{\"username\":\"$UNIFI_USERNAME\",\"password\":\"$UNIFI_PASSWORD\"}" \
            "$login_url")

        if [ $? -ne 0 ]; then
            echo "  ❌ Authentication failed"
            return 1
        fi

        # Query with session cookie
        response=$(curl -s -k -b /tmp/unifi_cookies.txt \
            -H "Content-Type: application/json" \
            "$url")
    fi

    if [ $? -eq 0 ] && [ -n "$response" ] && [ "$response" != "[]" ]; then
        echo "" >> "$OUTPUT_FILE"
        echo "## $resource_type" >> "$OUTPUT_FILE"

        # Extract IDs using jq if available, otherwise use basic parsing
        if command -v jq &> /dev/null; then
            echo "$response" | jq -r '.[] | "\(.name // .hostname // "unknown")|\(._id)"' | while IFS='|' read -r name id; do
                if [ -n "$id" ] && [ "$id" != "null" ]; then
                    clean_name=$(echo "$name" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_]/_/g' | sed 's/__*/_/g' | sed 's/^_\|_$//g')
                    echo "# $name" >> "$OUTPUT_FILE"
                    echo "unifi_${resource_type}.${clean_name} = \"$id\"" >> "$OUTPUT_FILE"
                fi
            done
        else
            # Basic parsing without jq
            echo "$response" | grep -o '"_id":"[^"]*"' | sed 's/"_id":"\([^"]*\)"/\1/' | while read -r id; do
                if [ -n "$id" ]; then
                    echo "# Resource ID: $id" >> "$OUTPUT_FILE"
                    echo "unifi_${resource_type}.resource_${id:0:8} = \"$id\"" >> "$OUTPUT_FILE"
                fi
            done
        fi
        echo "  ✅ Found resources"
    else
        echo "  ⚠️  No resources found or API error"
        echo "# $resource_type: No resources found" >> "$OUTPUT_FILE"
    fi
}

# Query different resource types
query_api "rest/networkconf" "network"
query_api "rest/wlanconf" "wlan"
query_api "rest/firewallgroup" "firewall_group"
query_api "rest/dnsrecord" "dns_record"
query_api "rest/routing" "static_route"
query_api "rest/usergroup" "user_group"
query_api "rest/firewallrule" "firewall_rule"

# Cleanup
rm -f /tmp/unifi_cookies.txt

echo "" >> "$OUTPUT_FILE"
echo "# Summary" >> "$OUTPUT_FILE"
echo "# Review the IDs above and match them with your Terraform resource names" >> "$OUTPUT_FILE"
echo "# Use: terraform import <resource_type>.<name> <id>" >> "$OUTPUT_FILE"

echo ""
echo "✅ Extraction complete! IDs saved to: $OUTPUT_FILE"
echo ""
echo "📋 Next steps:"
echo "1. Review the extracted IDs in $OUTPUT_FILE"
echo "2. Match resource names with your Terraform configuration files"
echo "3. Use the IDs to import resources: terraform import <resource_type>.<name> <id>"
echo ""
echo "Example:"
echo "  terraform import unifi_network.default <network-id>"
echo "  terraform import unifi_wlan.skynet_global_defense <wlan-id>"

