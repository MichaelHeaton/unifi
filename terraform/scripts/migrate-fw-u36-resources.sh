#!/bin/bash

# Script to migrate existing FW-U36 resources to the new multi-site structure
# This script imports all existing resources from the original state to the new FW-U36 environment

set -e

echo "🔄 Migrating FW-U36 resources to new multi-site structure..."

# Change to FW-U36 environment directory
cd /Users/michaelheaton/Documents/GitHub/homelab/terraform/infrastructure/network/environments/headquarters

# Initialize Terraform in the new environment
echo "📦 Initializing Terraform in FW-U36 environment..."
terraform init

# Function to get resource ID from original state
get_resource_id() {
    local resource_name=$1
    cd /Users/michaelheaton/Documents/GitHub/homelab/terraform/infrastructure/network
    terraform state show "$resource_name" | grep "id" | head -1 | cut -d'"' -f2
    cd /Users/michaelheaton/Documents/GitHub/homelab/terraform/infrastructure/network/environments/headquarters
}

# Import DNS Records
echo "🌐 Importing DNS records..."
terraform import unifi_dns_record.gpu01 "$(get_resource_id unifi_dns_record.gpu01)"
terraform import unifi_dns_record.gpu01_cl "$(get_resource_id unifi_dns_record.gpu01_cl)"
terraform import unifi_dns_record.nuc01 "$(get_resource_id unifi_dns_record.nuc01)"
terraform import unifi_dns_record.nuc01_cl "$(get_resource_id unifi_dns_record.nuc01_cl)"
terraform import unifi_dns_record.nuc02 "$(get_resource_id unifi_dns_record.nuc02)"
terraform import unifi_dns_record.nuc02_cl "$(get_resource_id unifi_dns_record.nuc02_cl)"
terraform import unifi_dns_record.portainer "$(get_resource_id unifi_dns_record.portainer)"
terraform import unifi_dns_record.portainer_mgmt "$(get_resource_id unifi_dns_record.portainer_mgmt)"
terraform import unifi_dns_record.traefik "$(get_resource_id unifi_dns_record.traefik)"
terraform import unifi_dns_record.whoami "$(get_resource_id unifi_dns_record.whoami)"

# Import Firewall Groups
echo "🔥 Importing firewall groups..."
terraform import unifi_firewall_group.grp_admin_targets "$(get_resource_id unifi_firewall_group.grp_admin_targets)"
terraform import unifi_firewall_group.grp_cluster_nodes "$(get_resource_id unifi_firewall_group.grp_cluster_nodes)"
terraform import unifi_firewall_group.grp_dns_servers "$(get_resource_id unifi_firewall_group.grp_dns_servers)"
terraform import unifi_firewall_group.grp_jumpbox "$(get_resource_id unifi_firewall_group.grp_jumpbox)"
terraform import unifi_firewall_group.grp_ntp_servers "$(get_resource_id unifi_firewall_group.grp_ntp_servers)"
terraform import unifi_firewall_group.grp_storage_targets "$(get_resource_id unifi_firewall_group.grp_storage_targets)"
terraform import unifi_firewall_group.grp_udm_gateways "$(get_resource_id unifi_firewall_group.grp_udm_gateways)"
terraform import unifi_firewall_group.grp_vpn_sources "$(get_resource_id unifi_firewall_group.grp_vpn_sources)"
terraform import unifi_firewall_group.host_gpu01 "$(get_resource_id unifi_firewall_group.host_gpu01)"
terraform import unifi_firewall_group.host_nas01 "$(get_resource_id unifi_firewall_group.host_nas01)"
terraform import unifi_firewall_group.host_traefik_internal "$(get_resource_id unifi_firewall_group.host_traefik_internal)"

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