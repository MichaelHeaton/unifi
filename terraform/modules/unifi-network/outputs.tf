# UniFi Network Module Outputs

# Network Information
output "networks" {
  description = "UniFi networks"
  value = {
    for k, v in unifi_network.this : k => {
      id   = v.id
      name = v.name
      cidr = v.subnet
    }
  }
}

# WLAN Information
output "wlans" {
  description = "UniFi WLANs"
  value = {
    for k, v in unifi_wlan.this : k => {
      id   = v.id
      name = v.name
      ssid = v.ssid
    }
  }
}

# DNS Records
output "dns_records" {
  description = "UniFi DNS records"
  value = {
    for k, v in unifi_dns_record.this : k => {
      id   = v.id
      name = v.name
      type = v.record_type
    }
  }
}

