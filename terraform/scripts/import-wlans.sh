#!/bin/bash

# Script to import WLANs only
set -e

echo "📡 Importing WLANs..."

# Change to FW-U36 environment directory
cd /Users/michaelheaton/Documents/GitHub/homelab/terraform/infrastructure/network/environments/headquarters

# Function to get resource ID from original state
get_resource_id() {
    local resource_name=$1
    cd /Users/michaelheaton/Documents/GitHub/homelab/terraform/infrastructure/network
    terraform state show "$resource_name" | grep "id.*=.*\"" | grep -v "network_id\|user_group_id" | cut -d'"' -f2
    cd /Users/michaelheaton/Documents/GitHub/homelab/terraform/infrastructure/network/environments/headquarters
}

# Import WLANs
terraform import unifi_wlan.bigbrotherswifi "$(get_resource_id unifi_wlan.bigbrotherswifi)"
terraform import unifi_wlan.skynet "$(get_resource_id unifi_wlan.skynet)"
terraform import unifi_wlan.skynet_global_defense "$(get_resource_id unifi_wlan.skynet_global_defense)"
terraform import unifi_wlan.skynet_iot "$(get_resource_id unifi_wlan.skynet_iot)"
terraform import unifi_wlan.wifightclub "$(get_resource_id unifi_wlan.wifightclub)"

echo "✅ WLAN import complete! Running terraform plan to verify..."
terraform plan

echo "🎉 WLANs successfully imported!"
