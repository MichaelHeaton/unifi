#!/bin/bash

# Get Firewall Group and DNS Record IDs from UniFi API
# Uses the UDM Pro local API key to query resources

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Load credentials from terraform.tfvars
if [ -f "$TERRAFORM_DIR/terraform.tfvars" ]; then
    UNIFI_API_URL=$(grep "^unifi_api_url" "$TERRAFORM_DIR/terraform.tfvars" | cut -d'"' -f2 | head -1)
    UNIFI_SITE=$(grep "^unifi_site" "$TERRAFORM_DIR/terraform.tfvars" | cut -d'"' -f2 | head -1)
    UNIFI_UDM_API_KEY=$(grep "^unifi_udm_api_key" "$TERRAFORM_DIR/terraform.tfvars" | cut -d'"' -f2 | head -1)
    UNIFI_USERNAME=$(grep "^unifi_username" "$TERRAFORM_DIR/terraform.tfvars" | cut -d'"' -f2 | head -1)
    UNIFI_PASSWORD=$(grep "^unifi_password" "$TERRAFORM_DIR/terraform.tfvars" | cut -d'"' -f2 | head -1)
fi

# Override with environment variables if set
UNIFI_API_URL="${TF_VAR_unifi_api_url:-${UNIFI_API_URL:-https://unifi.mgmt.specterrealm.com}}"
UNIFI_SITE="${TF_VAR_unifi_site:-${UNIFI_SITE:-default}}"
UNIFI_UDM_API_KEY="${TF_VAR_unifi_udm_api_key:-${UNIFI_UDM_API_KEY}}"
UNIFI_USERNAME="${TF_VAR_unifi_username:-${UNIFI_USERNAME}}"
UNIFI_PASSWORD="${TF_VAR_unifi_password:-${UNIFI_PASSWORD}}"

OUTPUT_FILE="${1:-$TERRAFORM_DIR/firewall-dns-ids.txt}"

echo "🔍 Extracting Firewall Group and DNS Record IDs from UniFi API"
echo "=============================================================="
echo "API URL: $UNIFI_API_URL"
echo "Site: $UNIFI_SITE"
echo "Output: $OUTPUT_FILE"
echo ""

# Remove trailing slash
UNIFI_API_URL="${UNIFI_API_URL%/}"
BASE_URL="$UNIFI_API_URL/proxy/network/api/s/$UNIFI_SITE"

# Function to query API with authentication
query_api() {
    local endpoint=$1
    local resource_type=$2
    local url="$BASE_URL/$endpoint"

    echo "Querying $resource_type..."

    if [ -n "$UNIFI_UDM_API_KEY" ]; then
        # Use UDM Pro local API key
        response=$(curl -s -k -X GET \
            -H "X-API-KEY: $UNIFI_UDM_API_KEY" \
            -H "Accept: application/json" \
            "$url" 2>&1)
    elif [ -n "$UNIFI_USERNAME" ] && [ -n "$UNIFI_PASSWORD" ]; then
        # Login first to get session cookie
        login_url="$UNIFI_API_URL/api/login"
        login_response=$(curl -s -k -c /tmp/unifi_cookies.txt -X POST \
            -H "Content-Type: application/json" \
            -d "{\"username\":\"$UNIFI_USERNAME\",\"password\":\"$UNIFI_PASSWORD\"}" \
            "$login_url")

        if [ $? -ne 0 ] || echo "$login_response" | grep -q "error"; then
            echo "  ❌ Authentication failed"
            return 1
        fi

        # Query with session cookie
        response=$(curl -s -k -b /tmp/unifi_cookies.txt \
            -H "Content-Type: application/json" \
            "$url" 2>&1)
    else
        echo "  ❌ No credentials available"
        return 1
    fi

    if [ $? -eq 0 ] && [ -n "$response" ] && ! echo "$response" | grep -q '"rc":"error"'; then
        # Check if jq is available for better parsing
        if command -v jq &> /dev/null; then
            # Parse JSON response - UniFi API returns {"meta": {...}, "data": [...]}
            data_array=$(echo "$response" | jq -r '.data // . // []' 2>/dev/null)

            if [ -n "$data_array" ] && [ "$data_array" != "null" ]; then
                # Extract each resource
                echo "$data_array" | jq -r 'if type == "array" then .[] else . end | "\(.name // .hostname // .domain // "unknown")|\(._id)"' 2>/dev/null | while IFS='|' read -r name id; do
                    if [ -n "$id" ] && [ "$id" != "null" ] && [ "$id" != "" ]; then
                        if [ "$name" != "null" ] && [ "$name" != "unknown" ] && [ -n "$name" ]; then
                            echo "# $name" >> "$OUTPUT_FILE"
                            clean_name=$(echo "$name" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_]/_/g' | sed 's/__*/_/g' | sed 's/^_\|_$//g')
                            echo "unifi_${resource_type}.${clean_name} = \"$id\"" >> "$OUTPUT_FILE"
                        else
                            echo "# Resource ID: $id" >> "$OUTPUT_FILE"
                            echo "unifi_${resource_type}.resource_${id:0:8} = \"$id\"" >> "$OUTPUT_FILE"
                        fi
                    fi
                done
                count=$(echo "$data_array" | jq -r 'if type == "array" then length else 1 end' 2>/dev/null)
                echo "  ✅ Found $count resource(s)"
            else
                echo "  ⚠️  No data in response"
                echo "# $resource_type: No data in API response" >> "$OUTPUT_FILE"
            fi
        else
            # Basic parsing without jq - extract _id fields
            ids=$(echo "$response" | grep -o '"_id":"[^"]*"' | sed 's/"_id":"\([^"]*\)"/\1/' | head -20)
            if [ -n "$ids" ]; then
                echo "$ids" | while read -r id; do
                    if [ -n "$id" ]; then
                        echo "# Resource ID: $id" >> "$OUTPUT_FILE"
                        echo "unifi_${resource_type}.resource_${id:0:8} = \"$id\"" >> "$OUTPUT_FILE"
                    fi
                done
                count=$(echo "$ids" | wc -l | xargs)
                echo "  ⚠️  Found $count resource(s) (install jq for better parsing)"
            else
                echo "  ⚠️  No resources found"
                echo "# $resource_type: No resources found" >> "$OUTPUT_FILE"
            fi
        fi
    else
        echo "  ⚠️  API error or no resources"
        error_msg=$(echo "$response" | grep -o '"msg":"[^"]*"' | head -1 | sed 's/"msg":"\([^"]*\)"/\1/')
        if [ -n "$error_msg" ]; then
            echo "  Error: $error_msg"
        else
            echo "  Response: ${response:0:200}"
        fi
        echo "# $resource_type: API error - $error_msg" >> "$OUTPUT_FILE"
    fi
}

# Create output file
cat > "$OUTPUT_FILE" << EOF
# Firewall Group and DNS Record IDs Extracted from UniFi API
# Generated: $(date)
# API URL: $UNIFI_API_URL
# Site: $UNIFI_SITE

EOF

# Query Firewall Groups
echo "" >> "$OUTPUT_FILE"
echo "## firewall_group" >> "$OUTPUT_FILE"
query_api "rest/firewallgroup" "firewall_group"

# Query DNS Records - try different endpoints
echo "" >> "$OUTPUT_FILE"
echo "## dns_record" >> "$OUTPUT_FILE"
# Try different endpoints for DNS records
echo "Trying DNS record endpoints..."
query_api "rest/dnsrecord" "dns_record" || \
query_api "rest/networkconf" "dns_record" || \
query_api "rest/setting/dns" "dns_record" || \
query_api "rest/setting" "dns_record"

# Query Static Routes
echo "" >> "$OUTPUT_FILE"
echo "## static_route" >> "$OUTPUT_FILE"
query_api "rest/routing" "static_route"

# Query User Groups
echo "" >> "$OUTPUT_FILE"
echo "## user_group" >> "$OUTPUT_FILE"
query_api "rest/usergroup" "user_group"

# Cleanup
rm -f /tmp/unifi_cookies.txt

echo ""
echo "✅ Extraction complete! IDs saved to: $OUTPUT_FILE"
echo ""
echo "📋 Next steps:"
echo "1. Review the extracted IDs in $OUTPUT_FILE"
echo "2. Match resource names with your Terraform configuration"
echo "3. Update import-ids.txt with the correct IDs"
echo "4. Import resources: terraform import <resource_type>.<name> <id>"

