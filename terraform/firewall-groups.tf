# Cleaned Firewall Groups
# This file defines firewall groups with their actual names from the UniFi controller

# Admin targets group
resource "unifi_firewall_group" "grp_admin_targets" {
  name = "grp_admin_targets"
  type = "address-group"
  members = [
    "172.16.0.1",
    "172.16.10.1",
    "172.16.101.1",
    "172.16.12.1",
    "172.16.20.1",
    "172.16.200.1",
    "172.16.201.1",
    "172.16.30.1",
    "172.16.40.1",
    "172.16.5.1",
    "172.16.99.1"
  ]
}

# Cluster nodes group
resource "unifi_firewall_group" "grp_cluster_nodes" {
  name = "grp_cluster_nodes"
  type = "address-group"
  members = [
    "172.16.12.10",
    "172.16.12.11",
    "172.16.12.12"
  ]
}

# DNS servers group
resource "unifi_firewall_group" "grp_dns_servers" {
  name    = "grp_dns_servers"
  type    = "address-group"
  members = ["172.16.0.1"]
}

# NTP servers group
resource "unifi_firewall_group" "grp_ntp_servers" {
  name    = "grp_ntp_servers"
  type    = "address-group"
  members = ["172.16.0.1"]
}

# Jump box group
resource "unifi_firewall_group" "grp_jumpbox" {
  name    = "grp_jumpbox"
  type    = "address-group"
  members = ["172.16.15.50"]
}

# VPN sources group
resource "unifi_firewall_group" "grp_vpn_sources" {
  name    = "grp_vpn_sources"
  type    = "address-group"
  members = ["195.168.12.4"]
}

# UDM gateways group
resource "unifi_firewall_group" "grp_udm_gateways" {
  name = "grp_udm_gateways"
  type = "address-group"
  members = [
    "172.16.0.1",
    "172.16.10.1",
    "172.16.101.1",
    "172.16.12.1",
    "172.16.15.1",
    "172.16.20.1",
    "172.16.200.1",
    "172.16.201.1",
    "172.16.30.1",
    "172.16.40.1",
    "172.16.5.1",
    "172.16.99.1"
  ]
}

# Storage targets group
resource "unifi_firewall_group" "grp_storage_targets" {
  name = "grp_storage_targets"
  type = "address-group"
  members = [
    "172.16.30.10",
    "172.16.30.11",
    "172.16.30.12",
    "172.16.30.4",
    "172.16.30.5"
  ]
}

# NAS server host
resource "unifi_firewall_group" "host_nas01" {
  name    = "host_NAS01"
  type    = "address-group"
  members = ["172.16.0.5"]
}

# GPU server host
resource "unifi_firewall_group" "host_gpu01" {
  name    = "host_GPU01"
  type    = "address-group"
  members = ["172.16.0.10"]
}

# Traefik Internal host group
resource "unifi_firewall_group" "host_traefik_internal" {
  name    = "host_Traefik-Internal"
  type    = "address-group"
  members = ["172.16.5.9"]
}
