#!/bin/bash

# Simple script to help extract resource IDs
# Since API authentication is complex, this provides manual steps

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
OUTPUT_FILE="${1:-$TERRAFORM_DIR/import-ids.txt}"

cd "$TERRAFORM_DIR"

echo "📋 UniFi Resource ID Extraction Guide"
echo "======================================"
echo ""
echo "Since direct API access requires complex authentication,"
echo "here are the best ways to get resource IDs:"
echo ""
echo "Method 1: Use Terraform Import (Recommended)"
echo "--------------------------------------------"
echo "1. Run 'terraform plan' to see what resources Terraform wants to create"
echo "2. For each resource, use the UniFi web UI to find the ID:"
echo "   - Networks: Settings > Networks > [Network Name] > Note the ID in URL"
echo "   - WLANs: Settings > WiFi > [WLAN Name] > Note the ID"
echo "   - Firewall Groups: Settings > Firewall & Security > Groups > Note IDs"
echo ""
echo "3. Import using: terraform import <resource_type>.<name> <id>"
echo ""
echo "Method 2: Use Terraform Console"
echo "--------------------------------"
echo "After running 'terraform init' and 'terraform plan',"
echo "you can use 'terraform console' to query resources:"
echo ""
echo "  terraform console"
echo "  > data.unifi_network.default.id"
echo ""
echo "Method 3: Browser Developer Tools"
echo "----------------------------------"
echo "1. Open UniFi Controller web UI"
echo "2. Open browser Developer Tools (F12)"
echo "3. Navigate to Network tab"
echo "4. Go to Settings > Networks (or other resource)"
echo "5. Look for API calls in Network tab - IDs are in responses"
echo ""
echo "Method 4: Manual Import with Terraform Plan"
echo "--------------------------------------------"
echo "1. Run: terraform plan"
echo "2. For each resource that shows 'will be created',"
echo "   note the resource name (e.g., unifi_network.default)"
echo "3. Get the ID from UniFi controller"
echo "4. Import: terraform import unifi_network.default <id>"
echo "5. Run terraform plan again - should show no changes"
echo ""
echo "Creating template import file..."
echo ""

cat > "$OUTPUT_FILE" << 'EOF'
# Terraform Import IDs Template
# Fill in the IDs from your UniFi controller

# Networks (VLANs)
# Get IDs from: Settings > Networks > [Network Name]
# Or from URL when viewing network details
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

# Firewall Rules
# Get IDs from: Settings > Firewall & Security > Rules
# Note: Firewall rules may need to be imported individually
EOF

echo "✅ Created template file: $OUTPUT_FILE"
echo ""
echo "Next steps:"
echo "1. Open UniFi Controller web UI"
echo "2. Navigate to each resource type and find the IDs"
echo "3. Fill in the IDs in $OUTPUT_FILE"
echo "4. Use the IDs to import: terraform import <resource_type>.<name> <id>"
echo ""
echo "Tip: You can also try running 'terraform plan' first to see"
echo "     which resources need to be imported."

