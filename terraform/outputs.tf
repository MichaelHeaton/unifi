# UniFi Network Outputs
# Output values for network configuration

# VLAN Information
output "vlans" {
  description = "All configured VLANs"
  value = {
    default = {
      id      = unifi_network.default.id
      name    = unifi_network.default.name
      subnet  = unifi_network.default.subnet
      vlan_id = unifi_network.default.vlan_id
    }
    family = {
      id      = unifi_network.family.id
      name    = unifi_network.family.name
      subnet  = unifi_network.family.subnet
      vlan_id = unifi_network.family.vlan_id
    }
    production = {
      id      = unifi_network.production.id
      name    = unifi_network.production.name
      subnet  = unifi_network.production.subnet
      vlan_id = unifi_network.production.vlan_id
    }
    cluster = {
      id      = unifi_network.cluster.id
      name    = unifi_network.cluster.name
      subnet  = unifi_network.cluster.subnet
      vlan_id = unifi_network.cluster.vlan_id
    }
    mgmt_admin = {
      id      = unifi_network.mgmt_admin.id
      name    = unifi_network.mgmt_admin.name
      subnet  = unifi_network.mgmt_admin.subnet
      vlan_id = unifi_network.mgmt_admin.vlan_id
    }
    lab = {
      id      = unifi_network.lab.id
      name    = unifi_network.lab.name
      subnet  = unifi_network.lab.subnet
      vlan_id = unifi_network.lab.vlan_id
    }
    storage = {
      id      = unifi_network.storage.id
      name    = unifi_network.storage.name
      subnet  = unifi_network.storage.subnet
      vlan_id = unifi_network.storage.vlan_id
    }
    dmz = {
      id      = unifi_network.dmz.id
      name    = unifi_network.dmz.name
      subnet  = unifi_network.dmz.subnet
      vlan_id = unifi_network.dmz.vlan_id
    }
    parking = {
      id      = unifi_network.parking.id
      name    = unifi_network.parking.name
      subnet  = unifi_network.parking.subnet
      vlan_id = unifi_network.parking.vlan_id
    }
    guest = {
      id      = unifi_network.guest.id
      name    = unifi_network.guest.name
      subnet  = unifi_network.guest.subnet
      vlan_id = unifi_network.guest.vlan_id
    }
    iot = {
      id      = unifi_network.iot.id
      name    = unifi_network.iot.name
      subnet  = unifi_network.iot.subnet
      vlan_id = unifi_network.iot.vlan_id
    }
  }
}

# Network Summary
output "network_summary" {
  description = "Network configuration summary"
  value       = <<-EOT
    UniFi Network Configuration Complete!

    VLANs Configured:
    - Default (VLAN 1): 172.16.0.0/24
    - Family (VLAN 5): 172.16.5.0/24
    - Production (VLAN 10): 172.16.10.0/24
    - Cluster (VLAN 12): 172.16.12.0/24
    - Mgmt-Admin (VLAN 15): 172.16.15.0/24
    - Lab (VLAN 20): 172.16.20.0/24
    - Storage (VLAN 30): 172.16.30.0/24
    - DMZ (VLAN 40): 172.16.40.0/24
    - Parking (VLAN 99): 172.16.99.0/24
    - Guest (VLAN 101): 172.16.101.0/24
    - IoT (VLAN 200): 172.16.200.0/24

    Next Steps:
    1. Verify network connectivity
    2. Test DHCP functionality
    3. Configure firewall rules
    4. Deploy Proxmox infrastructure
    5. Build Image Factory
  EOT
}

# DHCP Information
output "dhcp_info" {
  description = "DHCP configuration information"
  value = {
    default = {
      enabled = unifi_network.default.dhcp_enabled
      start   = unifi_network.default.dhcp_start
      stop    = unifi_network.default.dhcp_stop
      lease   = unifi_network.default.dhcp_lease
    }
    family = {
      enabled = unifi_network.family.dhcp_enabled
      start   = unifi_network.family.dhcp_start
      stop    = unifi_network.family.dhcp_stop
      lease   = unifi_network.family.dhcp_lease
    }
    production = {
      enabled = unifi_network.production.dhcp_enabled
      start   = unifi_network.production.dhcp_start
      stop    = unifi_network.production.dhcp_stop
      lease   = unifi_network.production.dhcp_lease
    }
    lab = {
      enabled = unifi_network.lab.dhcp_enabled
      start   = unifi_network.lab.dhcp_start
      stop    = unifi_network.lab.dhcp_stop
      lease   = unifi_network.lab.dhcp_lease
    }
  }
}

# Site Information
# Note: Site information is configured in the provider block
# The ubiquiti-community/unifi provider doesn't support unifi_site data source
