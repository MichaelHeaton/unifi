#!/bin/bash

# Match extracted IDs with Terraform resource names and update import-ids.txt

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
EXTRACTED_IDS="$TERRAFORM_DIR/firewall-dns-ids.txt"
IMPORT_IDS="$TERRAFORM_DIR/import-ids.txt"

echo "🔗 Matching extracted IDs with Terraform resource names"
echo "========================================================"

# Read firewall groups from Terraform
declare -A TF_FIREWALL_GROUPS
while IFS= read -r line; do
    if [[ $line =~ resource\ \"unifi_firewall_group\"\ \"([^\"]+)\" ]]; then
        name="${BASH_REMATCH[1]}"
        # Get the name attribute from the resource
        name_attr=$(grep -A 5 "resource \"unifi_firewall_group\" \"$name\"" "$TERRAFORM_DIR/firewall-groups.tf" | grep "name\s*=" | head -1 | sed 's/.*name\s*=\s*"\([^"]*\)".*/\1/')
        if [ -n "$name_attr" ]; then
            TF_FIREWALL_GROUPS["$name"]="$name_attr"
        fi
    fi
done < "$TERRAFORM_DIR/firewall-groups.tf"

# Read DNS records from Terraform
declare -A TF_DNS_RECORDS
while IFS= read -r line; do
    if [[ $line =~ resource\ \"unifi_dns_record\"\ \"([^\"]+)\" ]]; then
        name="${BASH_REMATCH[1]}"
        # Get the name attribute from the resource
        name_attr=$(grep -A 5 "resource \"unifi_dns_record\" \"$name\"" "$TERRAFORM_DIR/dns-records.tf" | grep "name\s*=" | head -1 | sed 's/.*name\s*=\s*"\([^"]*\)".*/\1/')
        if [ -n "$name_attr" ]; then
            TF_DNS_RECORDS["$name"]="$name_attr"
        fi
    fi
done < "$TERRAFORM_DIR/dns-records.tf"

# Match firewall groups
echo ""
echo "📋 Matching Firewall Groups:"
echo "----------------------------"
matched=0
while IFS= read -r line; do
    if [[ $line =~ ^unifi_firewall_group\.([^=]+)\s*=\s*\"([^\"]+)\" ]]; then
        extracted_name="${BASH_REMATCH[1]}"
        extracted_id="${BASH_REMATCH[2]}"

        # Try to match with Terraform resource names
        for tf_name in "${!TF_FIREWALL_GROUPS[@]}"; do
            tf_name_attr="${TF_FIREWALL_GROUPS[$tf_name]}"
            # Normalize names for comparison
            normalized_extracted=$(echo "$extracted_name" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]//g')
            normalized_tf=$(echo "$tf_name" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]//g')
            normalized_attr=$(echo "$tf_name_attr" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]//g')

            if [ "$normalized_extracted" == "$normalized_tf" ] || [ "$normalized_extracted" == "$normalized_attr" ]; then
                echo "  ✅ $tf_name -> $extracted_id"
                # Update import-ids.txt
                sed -i.bak "s|unifi_firewall_group\.$tf_name = \"<id-from-unifi>\"|unifi_firewall_group.$tf_name = \"$extracted_id\"|" "$IMPORT_IDS"
                ((matched++))
                break
            fi
        done
    fi
done < "$EXTRACTED_IDS"

echo "  Matched $matched firewall groups"

# Match static routes
echo ""
echo "📋 Matching Static Routes:"
echo "-------------------------"
if grep -q "unifi_static_route.vpn_to_lan" "$EXTRACTED_IDS"; then
    route_id=$(grep "unifi_static_route.vpn_to_lan" "$EXTRACTED_IDS" | sed 's/.*= "\([^"]*\)".*/\1/')
    if [ -n "$route_id" ]; then
        sed -i.bak "s|unifi_static_route\.vpn_to_lan = \"<id-from-unifi>\"|unifi_static_route.vpn_to_lan = \"$route_id\"|" "$IMPORT_IDS"
        echo "  ✅ vpn_to_lan -> $route_id"
    fi
fi

# Match user groups
echo ""
echo "📋 Matching User Groups:"
echo "----------------------"
if grep -q "unifi_user_group.default" "$EXTRACTED_IDS"; then
    default_id=$(grep "unifi_user_group.default" "$EXTRACTED_IDS" | sed 's/.*= "\([^"]*\)".*/\1/')
    if [ -n "$default_id" ]; then
        sed -i.bak "s|unifi_user_group\.default = \"<id-from-unifi>\"|unifi_user_group.default = \"$default_id\"|" "$IMPORT_IDS"
        echo "  ✅ default -> $default_id"
    fi
fi

if grep -q "unifi_user_group.guest" "$EXTRACTED_IDS"; then
    guest_id=$(grep "unifi_user_group.guest" "$EXTRACTED_IDS" | sed 's/.*= "\([^"]*\)".*/\1/')
    if [ -n "$guest_id" ]; then
        sed -i.bak "s|unifi_user_group\.guest = \"<id-from-unifi>\"|unifi_user_group.guest = \"$guest_id\"|" "$IMPORT_IDS"
        echo "  ✅ guest -> $guest_id"
    fi
fi

# Clean up backup file
rm -f "$IMPORT_IDS.bak"

echo ""
echo "✅ Matching complete! Updated $IMPORT_IDS"
echo ""
echo "📋 Remaining tasks:"
echo "  - DNS Records: Need to find correct API endpoint"
echo "  - Review firewall group matches manually if needed"

