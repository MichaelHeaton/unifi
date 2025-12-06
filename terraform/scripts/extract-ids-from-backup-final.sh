#!/bin/bash

# Extract Resource IDs from UniFi Backup File
# This script provides multiple methods to extract IDs from UniFi backup files

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BACKUP_DIR="$TERRAFORM_DIR/../backup"
OUTPUT_FILE="${1:-$TERRAFORM_DIR/import-ids.txt}"

echo "📦 UniFi Backup ID Extraction"
echo "============================="
echo ""

# Find backup file
BACKUP_FILE=$(find "$BACKUP_DIR" -name "*.unifi" -o -name "*.unf" | head -1)

if [ -z "$BACKUP_FILE" ]; then
    echo "❌ No backup file found in $BACKUP_DIR"
    exit 1
fi

echo "Found backup: $BACKUP_FILE"
echo ""

# Method 1: Try Python extraction
echo "Method 1: Python JSON extraction..."
if python3 "$SCRIPT_DIR/extract-ids-from-backup-v2.py" "$BACKUP_FILE" "$OUTPUT_FILE" 2>/dev/null; then
    if [ -s "$OUTPUT_FILE" ] && grep -q "=" "$OUTPUT_FILE" 2>/dev/null; then
        echo "✅ Successfully extracted IDs using Python"
        echo "Results saved to: $OUTPUT_FILE"
        exit 0
    fi
fi

echo "❌ Python extraction didn't find IDs"
echo ""

# Method 2: Use UniFi Backup Explorer (online tool)
echo "Method 2: UniFi Backup Explorer (Manual)"
echo "-----------------------------------------"
echo "The backup file appears to be in a proprietary format."
echo ""
echo "To extract IDs using UniFi Backup Explorer:"
echo "1. Go to: https://github.com/Art-of-WiFi/UniFi-backup-decoder"
echo "   Or use the online tool at a UniFi backup explorer website"
echo "2. Upload your backup file: $(basename "$BACKUP_FILE")"
echo "3. Download the extracted contents (usually a zip file)"
echo "4. Extract the zip and look for JSON files"
echo "5. Run this script again with the extracted JSON, or manually extract IDs"
echo ""

# Method 3: Provide instructions for manual extraction
echo "Method 3: Manual Extraction from UniFi Controller"
echo "-------------------------------------------------"
echo "Since the backup file format is proprietary, you can get IDs from:"
echo ""
echo "1. UniFi Web UI:"
echo "   - Networks: Settings > Networks > Click each network > Check URL or page source"
echo "   - WLANs: Settings > WiFi > Click each WLAN > Note the ID"
echo "   - Firewall Groups: Settings > Firewall & Security > Groups"
echo "   - DNS Records: Settings > Internet > DNS > Static DNS Records"
echo ""
echo "2. Browser Developer Tools:"
echo "   - Open UniFi Controller in browser"
echo "   - Press F12 > Network tab"
echo "   - Navigate to Settings > Networks (or other resources)"
echo "   - Look for API calls - IDs are in the JSON responses"
echo ""
echo "3. Terraform Import (Recommended):"
echo "   - Run: terraform plan"
echo "   - For each resource that shows 'will be created', get the ID from UniFi"
echo "   - Import: terraform import <resource_type>.<name> <id>"
echo ""

# Create a template file
cat > "$OUTPUT_FILE" << 'EOF'
# Terraform Import IDs
# Fill in the IDs from your UniFi controller or extracted backup

# Networks (VLANs)
# Get IDs from: Settings > Networks > [Network Name]
unifi_network.default = "<network-id>"
unifi_network.family = "<network-id>"
unifi_network.production = "<network-id>"
unifi_network.cluster = "<network-id>"
unifi_network.mgmt_admin = "<network-id>"
unifi_network.lab = "<network-id>"
unifi_network.storage = "<network-id>"
unifi_network.dmz = "<network-id>"
unifi_network.parking = "<network-id>"
unifi_network.guest = "<network-id>"
unifi_network.iot = "<network-id>"

# WLANs
# Get IDs from: Settings > WiFi > [WLAN Name]
unifi_wlan.skynet_global_defense = "<wlan-id>"
unifi_wlan.skynet = "<wlan-id>"
unifi_wlan.skynet_iot = "<wlan-id>"
unifi_wlan.wifightclub = "<wlan-id>"
unifi_wlan.bigbrotherswifi = "<wlan-id>"

# Firewall Groups
# Get IDs from: Settings > Firewall & Security > Groups
unifi_firewall_group.grp_admin_targets = "<group-id>"
unifi_firewall_group.grp_cluster_nodes = "<group-id>"
unifi_firewall_group.grp_dns_servers = "<group-id>"
# ... add more as needed

# DNS Records
# Get IDs from: Settings > Internet > DNS > Static DNS Records
unifi_dns_record.portainer = "<dns-id>"
unifi_dns_record.whoami = "<dns-id>"
unifi_dns_record.gpu01 = "<dns-id>"
# ... add more as needed

# Static Routes
# Get IDs from: Settings > Internet > Static Routes
unifi_static_route.vpn_to_lan = "<route-id>"

# User Groups
# Get IDs from: Settings > User Groups
unifi_user_group.default = "<group-id>"
unifi_user_group.guest = "<group-id>"
EOF

echo "✅ Created template file: $OUTPUT_FILE"
echo ""
echo "Next steps:"
echo "1. Use one of the methods above to get resource IDs"
echo "2. Fill in the IDs in $OUTPUT_FILE"
echo "3. Import resources: terraform import <resource_type>.<name> <id>"

