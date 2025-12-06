# Site-Agnostic Network Configuration Module
# This module configures network management for any site based on site capabilities

# Site configuration variables
variable "site_name" {
  description = "Site name"
  type        = string
}

variable "site_type" {
  description = "Site type (headquarters, remote, etc.)"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "network" {
  description = "Network configuration"
  type        = map(any)
  default     = {}
}

variable "services" {
  description = "Services configuration"
  type        = map(any)
  default     = {}
}

# UniFi configuration variables
variable "unifi_username" {
  description = "UniFi controller username"
  type        = string
  sensitive   = true
}

variable "unifi_password" {
  description = "UniFi controller password"
  type        = string
  sensitive   = true
}

variable "unifi_api_url" {
  description = "UniFi controller API URL"
  type        = string
}

variable "unifi_site" {
  description = "UniFi site name"
  type        = string
  default     = "default"
}

variable "unifi_insecure" {
  description = "Allow insecure UniFi connections"
  type        = bool
  default     = false
}

# Network configuration based on site capabilities
resource "unifi_site" "site" {
  count = var.services.unifi_enabled ? 1 : 0
  name  = var.site_name
  desc  = "${var.site_name} site configuration"
}

# VLAN configuration based on network config
resource "unifi_network" "management" {
  count = var.services.unifi_enabled && var.network.vlan_management ? 1 : 0
  name  = "Management"
  site  = unifi_site.site[0].name

  purpose = "corporate"
  subnet  = "10.${var.network.vlan_management}.1.1/24"
  vlan_id = var.network.vlan_management

  dhcp_start   = "10.${var.network.vlan_management}.1.6"
  dhcp_stop    = "10.${var.network.vlan_management}.1.254"
  dhcp_enabled = true
}

resource "unifi_network" "guest" {
  count = var.services.unifi_enabled && var.network.vlan_guest ? 1 : 0
  name  = "Guest"
  site  = unifi_site.site[0].name

  purpose = "guest"
  subnet  = "10.${var.network.vlan_guest}.1.1/24"
  vlan_id = var.network.vlan_guest

  dhcp_start   = "10.${var.network.vlan_guest}.1.6"
  dhcp_stop    = "10.${var.network.vlan_guest}.1.254"
  dhcp_enabled = true
}

resource "unifi_network" "iot" {
  count = var.services.unifi_enabled && var.network.vlan_iot ? 1 : 0
  name  = "IoT"
  site  = unifi_site.site[0].name

  purpose = "corporate"
  subnet  = "10.${var.network.vlan_iot}.1.1/24"
  vlan_id = var.network.vlan_iot

  dhcp_start   = "10.${var.network.vlan_iot}.1.6"
  dhcp_stop    = "10.${var.network.vlan_iot}.1.254"
  dhcp_enabled = true
}

resource "unifi_network" "servers" {
  count = var.services.unifi_enabled && var.network.vlan_servers ? 1 : 0
  name  = "Servers"
  site  = unifi_site.site[0].name

  purpose = "corporate"
  subnet  = "10.${var.network.vlan_servers}.1.1/24"
  vlan_id = var.network.vlan_servers

  dhcp_start   = "10.${var.network.vlan_servers}.1.6"
  dhcp_stop    = "10.${var.network.vlan_servers}.1.254"
  dhcp_enabled = true
}

# WLAN configuration based on services
resource "unifi_wlan" "main" {
  count = var.services.unifi_enabled ? 1 : 0
  name  = "${var.site_name}-Main"
  site  = unifi_site.site[0].name

  security = "wpapsk"
  wpa_enc  = "wpa2"
  wpa_mode = "wpa2"

  network_id = unifi_network.management[0].id
}

resource "unifi_wlan" "guest" {
  count = var.services.unifi_enabled && var.network.vlan_guest ? 1 : 0
  name  = "${var.site_name}-Guest"
  site  = unifi_site.site[0].name

  security   = "open"
  network_id = unifi_network.guest[0].id
}

# Outputs
output "network_info" {
  description = "Network information for this site"
  value = var.services.unifi_enabled ? {
    site_name  = var.site_name
    unifi_site = unifi_site.site[0].name
    networks = {
      management = var.network.vlan_management ? unifi_network.management[0].name : null
      guest      = var.network.vlan_guest ? unifi_network.guest[0].name : null
      iot        = var.network.vlan_iot ? unifi_network.iot[0].name : null
      servers    = var.network.vlan_servers ? unifi_network.servers[0].name : null
    }
    wlans = {
      main  = unifi_wlan.main[0].name
      guest = var.network.vlan_guest ? unifi_wlan.guest[0].name : null
    }
  } : null
}

output "site_structure" {
  description = "Site structure information"
  value = {
    site_name   = var.site_name
    site_type   = var.site_type
    environment = var.environment
    network     = var.network
    services    = var.services
  }
}

