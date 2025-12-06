#!/bin/bash

# Script to continue migrating remaining FW-U36 resources
# This script imports the remaining resources (networks, routes, groups, WLANs)

set -e

echo "🔄 Continuing FW-U36 resource migration..."

# Change to FW-U36 environment directory
cd /Users/michaelheaton/Documents/GitHub/homelab/terraform/infrastructure/network/environments/headquarters

# Function to get resource ID from original state
get_resource_id() {
    local resource_name=$1
    cd /Users/michaelheaton/Documents/GitHub/homelab/terraform/infrastructure/network
    terraform state show "$resource_name" | grep "id.*=.*\"" | grep -v "network_id\|user_group_id" | cut -d'"' -f2
    cd /Users/michaelheaton/Documents/GitHub/homelab/terraform/infrastructure/network/environments/headquarters
}

# Import Networks
echo "🌍 Importing networks..."
terraform import unifi_network.cluster "$(get_resource_id unifi_network.cluster)"
terraform import unifi_network.default "$(get_resource_id unifi_network.default)"
terraform import unifi_network.dmz "$(get_resource_id unifi_network.dmz)"
terraform import unifi_network.family "$(get_resource_id unifi_network.family)"
terraform import unifi_network.guest "$(get_resource_id unifi_network.guest)"
terraform import unifi_network.iot "$(get_resource_id unifi_network.iot)"
terraform import unifi_network.lab "$(get_resource_id unifi_network.lab)"
terraform import unifi_network.mgmt_admin "$(get_resource_id unifi_network.mgmt_admin)"
terraform import unifi_network.parking "$(get_resource_id unifi_network.parking)"
terraform import unifi_network.production "$(get_resource_id unifi_network.production)"
terraform import unifi_network.storage "$(get_resource_id unifi_network.storage)"

# Import Static Routes
echo "🛣️ Importing static routes..."
terraform import unifi_static_route.vpn_to_lan "$(get_resource_id unifi_static_route.vpn_to_lan)"

# Import User Groups
echo "👥 Importing user groups..."
terraform import unifi_user_group.default "$(get_resource_id unifi_user_group.default)"
terraform import unifi_user_group.guest "$(get_resource_id unifi_user_group.guest)"

# Import WLANs
echo "📡 Importing WLANs..."
terraform import unifi_wlan.bigbrotherswifi "$(get_resource_id unifi_wlan.bigbrotherswifi)"
terraform import unifi_wlan.skynet "$(get_resource_id unifi_wlan.skynet)"
terraform import unifi_wlan.skynet_global_defense "$(get_resource_id unifi_wlan.skynet_global_defense)"
terraform import unifi_wlan.skynet_iot "$(get_resource_id unifi_wlan.skynet_iot)"
terraform import unifi_wlan.wifightclub "$(get_resource_id unifi_wlan.wifightclub)"

echo "✅ Migration complete! Running terraform plan to verify..."
terraform plan

echo "🎉 FW-U36 resources successfully migrated to new multi-site structure!"
