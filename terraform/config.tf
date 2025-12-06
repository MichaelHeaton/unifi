# UniFi Network Configuration
# Centralized configuration for UniFi network management

# Local values for common configuration
locals {
  # UniFi Controller Configuration
  unifi_controller = {
    url      = "https://unifi-mgmt.specterrealm.com"
    site     = "default"
    insecure = false
  }

  # Network Configuration
  network = {
    # Note: dhcp_dns is set per-network in vlans.tf to match actual UniFi state
    dhcp_lease   = 86400 # 24 hours
    vlan_purpose = "corporate"
    enable_dhcp  = true
  }

  # Security Configuration
  security = {
    enable_firewall        = true
    enable_guest_isolation = true
  }

  # Monitoring Configuration
  monitoring = {
    enabled   = true
    retention = 30
  }
}

# VLAN Configuration
locals {
  vlans = {
    default = {
      name       = "Default"
      vlan_id    = 0 # Default VLAN ID to match current setup
      subnet     = "172.16.0.0/24"
      dhcp_start = "172.16.0.30"
      dhcp_stop  = "172.16.0.254"
    }
    family = {
      name       = "Family"
      vlan_id    = 5
      subnet     = "172.16.5.0/24"
      dhcp_start = "172.16.5.6"
      dhcp_stop  = "172.16.5.254"
    }
    production = {
      name       = "Production"
      vlan_id    = 10
      subnet     = "172.16.10.0/24"
      dhcp_start = "172.16.10.6"
      dhcp_stop  = "172.16.10.254"
    }
    cluster = {
      name       = "Cluster"
      vlan_id    = 12
      subnet     = "172.16.12.0/24"
      dhcp_start = "172.16.12.10" # Match current setup
      dhcp_stop  = "172.16.12.254"
    }
    mgmt_admin = {
      name       = "Mgmt-Admin"
      vlan_id    = 15
      subnet     = "172.16.15.0/24"
      dhcp_start = "172.16.15.6"
      dhcp_stop  = "172.16.15.254"
    }
    lab = {
      name       = "Lab"
      vlan_id    = 20
      subnet     = "172.16.20.0/24"
      dhcp_start = "172.16.20.6"
      dhcp_stop  = "172.16.20.254"
    }
    storage = {
      name       = "Storage"
      vlan_id    = 30
      subnet     = "172.16.30.0/24"
      dhcp_start = "172.16.30.6"
      dhcp_stop  = "172.16.30.254"
    }
    dmz = {
      name       = "DMZ"
      vlan_id    = 40
      subnet     = "172.16.40.0/24"
      dhcp_start = "172.16.40.6"
      dhcp_stop  = "172.16.40.254"
    }
    parking = {
      name         = "Parking"
      vlan_id      = 99
      subnet       = "172.16.99.0/24"
      dhcp_enabled = false
      dhcp_start   = "172.16.99.6"   # Match current setup
      dhcp_stop    = "172.16.99.254" # Match current setup
    }
    guest = {
      name       = "Guest"
      vlan_id    = 101
      subnet     = "172.16.101.0/24"
      dhcp_start = "172.16.101.6"
      dhcp_stop  = "172.16.101.254"
    }
    iot = {
      name       = "IoT"
      vlan_id    = 200
      subnet     = "172.16.200.0/24"
      dhcp_start = "172.16.200.6"
      dhcp_stop  = "172.16.200.254"
    }
  }
}
