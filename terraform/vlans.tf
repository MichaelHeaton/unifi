# UniFi VLAN Configuration
# This file defines all your existing VLANs using centralized configuration

# Default VLAN
resource "unifi_network" "default" {
  name         = local.vlans.default.name
  purpose      = local.network.vlan_purpose
  subnet       = local.vlans.default.subnet
  vlan_id      = local.vlans.default.vlan_id
  dhcp_enabled = local.network.enable_dhcp
  dhcp_start   = local.vlans.default.dhcp_start
  dhcp_stop    = local.vlans.default.dhcp_stop
  dhcp_lease   = local.network.dhcp_lease
  # dhcp_dns removed to match current setup (empty DNS servers)

  # IPv6 Settings to match current setup
  dhcp_v6_start          = "::2"
  dhcp_v6_stop           = "::7d1"
  ipv6_pd_start          = "::2"
  ipv6_pd_stop           = "::7d1"
  ipv6_ra_enable         = true
  ipv6_ra_priority       = "high"
  ipv6_ra_valid_lifetime = 0
  multicast_dns          = true
  domain_name            = "realm.local"

  # Device Isolation settings to match current setup
  intra_network_access_enabled = false # Device Isolation ON (current setting)
}

# Family VLAN
resource "unifi_network" "family" {
  name         = local.vlans.family.name
  purpose      = local.network.vlan_purpose
  subnet       = local.vlans.family.subnet
  vlan_id      = local.vlans.family.vlan_id
  dhcp_enabled = local.network.enable_dhcp
  dhcp_start   = local.vlans.family.dhcp_start
  dhcp_stop    = local.vlans.family.dhcp_stop
  dhcp_lease   = local.network.dhcp_lease
  dhcp_dns     = ["172.16.5.2", "172.16.5.1", "1.1.1.1"]

  # IPv6 Settings to match current setup
  dhcp_v6_start          = "::2"
  dhcp_v6_stop           = "::7d1"
  ipv6_pd_start          = "::2"
  ipv6_pd_stop           = "::7d1"
  ipv6_ra_enable         = true
  ipv6_ra_priority       = "high"
  ipv6_ra_valid_lifetime = 0
  multicast_dns          = true

  # Device Isolation - using default (true), ignore changes to avoid drift
  lifecycle {
    ignore_changes = [intra_network_access_enabled]
  }
}

# Production VLAN
resource "unifi_network" "production" {
  name         = local.vlans.production.name
  purpose      = local.network.vlan_purpose
  subnet       = local.vlans.production.subnet
  vlan_id      = local.vlans.production.vlan_id
  dhcp_enabled = local.network.enable_dhcp
  dhcp_start   = local.vlans.production.dhcp_start
  dhcp_stop    = local.vlans.production.dhcp_stop
  dhcp_lease   = local.network.dhcp_lease
  # dhcp_dns removed to match current setup (empty DNS servers)

  # IPv6 Settings to match current setup
  dhcp_v6_start          = "::2"
  dhcp_v6_stop           = "::7d1"
  ipv6_pd_start          = "::2"
  ipv6_pd_stop           = "::7d1"
  ipv6_ra_enable         = true
  ipv6_ra_priority       = "high"
  ipv6_ra_valid_lifetime = 0
  multicast_dns          = true

  # Device Isolation settings to match current setup
  intra_network_access_enabled = false # Device Isolation ON (current setting)
}

# Cluster VLAN
resource "unifi_network" "cluster" {
  name         = local.vlans.cluster.name
  purpose      = local.network.vlan_purpose
  subnet       = local.vlans.cluster.subnet
  vlan_id      = local.vlans.cluster.vlan_id
  dhcp_enabled = local.network.enable_dhcp
  dhcp_start   = local.vlans.cluster.dhcp_start
  dhcp_stop    = local.vlans.cluster.dhcp_stop
  dhcp_lease   = local.network.dhcp_lease
  # dhcp_dns removed to match current setup (empty DNS servers)

  # IPv6 Settings to match current setup
  dhcp_v6_start          = "::2"
  dhcp_v6_stop           = "::7d1"
  ipv6_pd_start          = "::2"
  ipv6_pd_stop           = "::7d1"
  ipv6_ra_enable         = true
  ipv6_ra_priority       = "high"
  ipv6_ra_valid_lifetime = 0
  multicast_dns          = true

  # Device Isolation settings to match current setup
  intra_network_access_enabled = false # Device Isolation ON (current setting)
}

# Management Admin VLAN
resource "unifi_network" "mgmt_admin" {
  name         = local.vlans.mgmt_admin.name
  purpose      = local.network.vlan_purpose
  subnet       = local.vlans.mgmt_admin.subnet
  vlan_id      = local.vlans.mgmt_admin.vlan_id
  dhcp_enabled = local.network.enable_dhcp
  dhcp_start   = local.vlans.mgmt_admin.dhcp_start
  dhcp_stop    = local.vlans.mgmt_admin.dhcp_stop
  dhcp_lease   = local.network.dhcp_lease
  dhcp_dns     = ["172.16.15.2", "172.16.15.1", "1.1.1.1"]

  # IPv6 Settings to match current setup
  dhcp_v6_start          = "::2"
  dhcp_v6_stop           = "::7d1"
  ipv6_pd_start          = "::2"
  ipv6_pd_stop           = "::7d1"
  ipv6_ra_enable         = true
  ipv6_ra_priority       = "high"
  ipv6_ra_valid_lifetime = 0
  multicast_dns          = true

  # Device Isolation - using default (true), ignore changes to avoid drift
  lifecycle {
    ignore_changes = [intra_network_access_enabled]
  }
}

# Lab VLAN
resource "unifi_network" "lab" {
  name         = local.vlans.lab.name
  purpose      = local.network.vlan_purpose
  subnet       = local.vlans.lab.subnet
  vlan_id      = local.vlans.lab.vlan_id
  dhcp_enabled = local.network.enable_dhcp
  dhcp_start   = local.vlans.lab.dhcp_start
  dhcp_stop    = local.vlans.lab.dhcp_stop
  dhcp_lease   = local.network.dhcp_lease
  # dhcp_dns removed to match current setup (empty DNS servers)

  # IPv6 Settings to match current setup
  dhcp_v6_start          = "::2"
  dhcp_v6_stop           = "::7d1"
  ipv6_pd_start          = "::2"
  ipv6_pd_stop           = "::7d1"
  ipv6_ra_enable         = true
  ipv6_ra_priority       = "high"
  ipv6_ra_valid_lifetime = 0
  multicast_dns          = true

  # Device Isolation settings to match current setup
  intra_network_access_enabled = false # Device Isolation ON (current setting)
}

# Storage VLAN
resource "unifi_network" "storage" {
  name         = local.vlans.storage.name
  purpose      = local.network.vlan_purpose
  subnet       = local.vlans.storage.subnet
  vlan_id      = local.vlans.storage.vlan_id
  dhcp_enabled = local.network.enable_dhcp
  dhcp_start   = local.vlans.storage.dhcp_start
  dhcp_stop    = local.vlans.storage.dhcp_stop
  dhcp_lease   = local.network.dhcp_lease
  # dhcp_dns removed to match current setup (empty DNS servers)

  # IPv6 Settings to match current setup
  dhcp_v6_start          = "::2"
  dhcp_v6_stop           = "::7d1"
  ipv6_pd_start          = "::2"
  ipv6_pd_stop           = "::7d1"
  ipv6_ra_enable         = true
  ipv6_ra_priority       = "high"
  ipv6_ra_valid_lifetime = 0
  multicast_dns          = true

  # Device Isolation settings to match current setup
  intra_network_access_enabled = false # Device Isolation ON (current setting)
}

# DMZ VLAN
resource "unifi_network" "dmz" {
  name         = local.vlans.dmz.name
  purpose      = local.network.vlan_purpose
  subnet       = local.vlans.dmz.subnet
  vlan_id      = local.vlans.dmz.vlan_id
  dhcp_enabled = local.network.enable_dhcp
  dhcp_start   = local.vlans.dmz.dhcp_start
  dhcp_stop    = local.vlans.dmz.dhcp_stop
  dhcp_lease   = local.network.dhcp_lease
  # dhcp_dns removed to match current setup (empty DNS servers)

  # IPv6 Settings to match current setup
  dhcp_v6_start          = "::2"
  dhcp_v6_stop           = "::7d1"
  ipv6_pd_start          = "::2"
  ipv6_pd_stop           = "::7d1"
  ipv6_ra_enable         = true
  ipv6_ra_priority       = "high"
  ipv6_ra_valid_lifetime = 0
  multicast_dns          = true

  # Device Isolation settings to match current setup
  intra_network_access_enabled = false # Device Isolation ON (current setting)
}

# Parking VLAN (No DHCP but has ranges configured)
resource "unifi_network" "parking" {
  name         = local.vlans.parking.name
  purpose      = local.network.vlan_purpose
  subnet       = local.vlans.parking.subnet
  vlan_id      = local.vlans.parking.vlan_id
  dhcp_enabled = local.vlans.parking.dhcp_enabled
  dhcp_start   = local.vlans.parking.dhcp_start
  dhcp_stop    = local.vlans.parking.dhcp_stop
  dhcp_lease   = local.network.dhcp_lease

  # IPv6 Settings to match current setup
  dhcp_v6_start          = "::2"
  dhcp_v6_stop           = "::7d1"
  ipv6_pd_start          = "::2"
  ipv6_pd_stop           = "::7d1"
  ipv6_ra_enable         = true
  ipv6_ra_priority       = "high"
  ipv6_ra_valid_lifetime = 0
  multicast_dns          = true

  # Device Isolation settings to match current setup
  intra_network_access_enabled = false # Device Isolation ON (current setting)
}

# Guest VLAN
resource "unifi_network" "guest" {
  name         = local.vlans.guest.name
  purpose      = "guest" # Guest VLAN should be "guest" purpose, not "corporate"
  subnet       = local.vlans.guest.subnet
  vlan_id      = local.vlans.guest.vlan_id
  dhcp_enabled = local.network.enable_dhcp
  dhcp_start   = local.vlans.guest.dhcp_start
  dhcp_stop    = local.vlans.guest.dhcp_stop
  dhcp_lease   = local.network.dhcp_lease
  dhcp_dns     = ["172.16.101.2", "172.16.101.1", "1.1.1.1"]

  # IPv6 Settings to match current setup
  dhcp_v6_start          = "::2"
  dhcp_v6_stop           = "::7d1"
  ipv6_pd_start          = "::2"
  ipv6_pd_stop           = "::7d1"
  ipv6_ra_enable         = true
  ipv6_ra_priority       = "high"
  ipv6_ra_valid_lifetime = 0
  multicast_dns          = false # Guest VLAN has multicast_dns = false

  # Device Isolation - using default (true), ignore changes to avoid drift
  lifecycle {
    ignore_changes = [intra_network_access_enabled]
  }
}

# IoT VLAN
resource "unifi_network" "iot" {
  name         = local.vlans.iot.name
  purpose      = local.network.vlan_purpose
  subnet       = local.vlans.iot.subnet
  vlan_id      = local.vlans.iot.vlan_id
  dhcp_enabled = local.network.enable_dhcp
  dhcp_start   = local.vlans.iot.dhcp_start
  dhcp_stop    = local.vlans.iot.dhcp_stop
  dhcp_lease   = local.network.dhcp_lease
  # dhcp_dns removed to match current setup (empty DNS servers)

  # IPv6 Settings to match current setup
  dhcp_v6_start          = "::2"
  dhcp_v6_stop           = "::7d1"
  ipv6_pd_start          = "::2"
  ipv6_pd_stop           = "::7d1"
  ipv6_ra_enable         = true
  ipv6_ra_priority       = "high"
  ipv6_ra_valid_lifetime = 0
  multicast_dns          = true

  # Device Isolation settings to match current setup
  intra_network_access_enabled = false # Device Isolation ON (current setting)
}
