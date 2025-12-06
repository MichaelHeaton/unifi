#!/bin/bash

# Parse UniFi URLs to extract resource IDs
# This script extracts IDs from UniFi web UI URLs and matches them with Terraform resources

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
OUTPUT_FILE="${1:-$TERRAFORM_DIR/import-ids.txt}"

echo "🔍 Parsing UniFi URLs to extract resource IDs"
echo "=============================================="
echo ""

# WiFi IDs from URLs
WIFI_IDS=(
    "5f9b156334ef8006578d18a6"
    "5f9b159434ef8006578d18a7"
    "5fcb5af8272e4f03936dc516"
    "6898d9a349b6161af589fb40"
    "6898d9a349b6161af589fb43"
)

# Network IDs from URLs
NETWORK_IDS=(
    "5f9b136a34ef8006578d187e"
    "6896371e49b6161af587f13e"
    "65d523a7f2c32451e4412967"
    "6896376049b6161af587f14b"
    "6896378549b6161af587f153"
    "65d5240ef2c32451e4412973"
    "68951b8149b6161af5871100"
    "65d52424f2c32451e4412982"
    "689637ee49b6161af587f240"
    "5f9b15e134ef8006578d18ad"
    "65d5228af2c32451e441287d"
)

echo "Found ${#WIFI_IDS[@]} WiFi IDs"
echo "Found ${#NETWORK_IDS[@]} Network IDs"
echo ""

# Create output file
cat > "$OUTPUT_FILE" << 'EOF'
# Terraform Import IDs Extracted from UniFi Web UI URLs
# Generated from URL parsing

EOF

# Write WiFi IDs
echo "## wlan" >> "$OUTPUT_FILE"
echo "# WiFi Networks - Match IDs with your WLAN names from UniFi controller" >> "$OUTPUT_FILE"
for i in "${!WIFI_IDS[@]}"; do
    echo "unifi_wlan.wlan_$((i+1)) = \"${WIFI_IDS[$i]}\"" >> "$OUTPUT_FILE"
done
echo "" >> "$OUTPUT_FILE"

# Write Network IDs
echo "## network" >> "$OUTPUT_FILE"
echo "# Networks (VLANs) - Match IDs with your network names from UniFi controller" >> "$OUTPUT_FILE"
for i in "${!NETWORK_IDS[@]}"; do
    echo "unifi_network.network_$((i+1)) = \"${NETWORK_IDS[$i]}\"" >> "$OUTPUT_FILE"
done
echo "" >> "$OUTPUT_FILE"

echo "✅ IDs extracted and saved to: $OUTPUT_FILE"
echo ""
echo "📋 Next steps:"
echo "1. Open each URL in your browser to see the resource name"
echo "2. Match the ID with the Terraform resource name in:"
echo "   - vlans.tf (for networks)"
echo "   - wlans.tf (for WiFi networks)"
echo "3. Update the import-ids.txt file with correct resource names"
echo "4. Import: terraform import <resource_type>.<name> <id>"

