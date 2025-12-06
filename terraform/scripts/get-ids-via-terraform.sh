#!/bin/bash

# Get Resource IDs using Terraform Provider
# This uses terraform console to query existing resources

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
OUTPUT_FILE="${1:-$TERRAFORM_DIR/import-ids.txt}"

cd "$TERRAFORM_DIR"

echo "🔍 Getting Resource IDs via Terraform Provider"
echo "=============================================="
echo ""

# First, try to get IDs by running terraform plan
# This will show us what resources exist and what needs to be imported
echo "Step 1: Running terraform plan to identify resources..."
echo ""

# Create a script to query resources via terraform console
cat > /tmp/terraform-query.tf << 'EOF'
# Temporary file to query resources
# This will be used to get resource IDs from the UniFi controller

# Note: We can't directly query all resources, but we can try to import
# and see what IDs Terraform expects, or use the provider's data sources
EOF

# Actually, the best approach is to use terraform import with a dummy ID
# and see what error we get, or use the web UI

echo "Since the backup file is encrypted, here are the best options:"
echo ""
echo "Option 1: Use UniFi Web UI"
echo "--------------------------"
echo "1. Open: https://unifi.mgmt.specterrealm.com"
echo "2. For each resource:"
echo "   - Networks: Settings > Networks > Click network > Check browser DevTools Network tab"
echo "   - WLANs: Settings > WiFi > Click WLAN > Check DevTools"
echo "   - Look for API calls - the _id field will be in the JSON responses"
echo ""
echo "Option 2: Use Terraform Import (Recommended)"
echo "---------------------------------------------"
echo "1. Run: terraform plan"
echo "2. For each resource showing 'will be created':"
echo "   - Get the ID from UniFi web UI (see Option 1)"
echo "   - Import: terraform import <resource_type>.<name> <id>"
echo "3. Repeat until terraform plan shows no changes"
echo ""
echo "Option 3: Use Browser DevTools"
echo "-------------------------------"
echo "1. Open UniFi Controller in browser"
echo "2. Press F12 > Network tab"
echo "3. Navigate to Settings > Networks (or other resources)"
echo "4. Look for API calls to /api/s/default/rest/..."
echo "5. Click on the API call > Response tab"
echo "6. Find the _id fields in the JSON response"
echo ""

# Create template
cat > "$OUTPUT_FILE" << 'EOF'
# Terraform Import IDs
# Fill in IDs from UniFi Controller (see methods above)

# Networks - Get from: Settings > Networks > [Network] > DevTools > API response
unifi_network.default = "<id-from-unifi>"
unifi_network.family = "<id-from-unifi>"
unifi_network.production = "<id-from-unifi>"
unifi_network.cluster = "<id-from-unifi>"
unifi_network.mgmt_admin = "<id-from-unifi>"
unifi_network.lab = "<id-from-unifi>"
unifi_network.storage = "<id-from-unifi>"
unifi_network.dmz = "<id-from-unifi>"
unifi_network.parking = "<id-from-unifi>"
unifi_network.guest = "<id-from-unifi>"
unifi_network.iot = "<id-from-unifi>"

# WLANs - Get from: Settings > WiFi > [WLAN] > DevTools > API response
unifi_wlan.skynet_global_defense = "<id-from-unifi>"
unifi_wlan.skynet = "<id-from-unifi>"
unifi_wlan.skynet_iot = "<id-from-unifi>"
unifi_wlan.wifightclub = "<id-from-unifi>"
unifi_wlan.bigbrotherswifi = "<id-from-unifi>"

# Firewall Groups - Get from: Settings > Firewall & Security > Groups
unifi_firewall_group.grp_admin_targets = "<id-from-unifi>"
unifi_firewall_group.grp_cluster_nodes = "<id-from-unifi>"
unifi_firewall_group.grp_dns_servers = "<id-from-unifi>"

# DNS Records - Get from: Settings > Internet > DNS > Static DNS Records
unifi_dns_record.portainer = "<id-from-unifi>"
unifi_dns_record.whoami = "<id-from-unifi>"
unifi_dns_record.gpu01 = "<id-from-unifi>"

# Static Routes - Get from: Settings > Internet > Static Routes
unifi_static_route.vpn_to_lan = "<id-from-unifi>"

# User Groups - Get from: Settings > User Groups
unifi_user_group.default = "<id-from-unifi>"
unifi_user_group.guest = "<id-from-unifi>"
EOF

echo "✅ Created template: $OUTPUT_FILE"
echo ""
echo "Quick method: Use browser DevTools to get IDs from API responses"
echo "This is the fastest way since the backup file is encrypted."

