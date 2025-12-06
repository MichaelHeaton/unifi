# UniFi Security Module Outputs

# Firewall Groups
output "firewall_groups" {
  description = "UniFi firewall groups"
  value = {
    for k, v in unifi_firewall_group.this : k => {
      id   = v.id
      name = v.name
      type = v.type
    }
  }
}

# Firewall Rules
output "firewall_rules" {
  description = "UniFi firewall rules"
  value = {
    for k, v in unifi_firewall_rule.this : k => {
      id     = v.id
      name   = v.name
      action = v.action
    }
  }
}

# Static Routes
output "static_routes" {
  description = "UniFi static routes"
  value = {
    for k, v in unifi_static_route.this : k => {
      id      = v.id
      name    = v.name
      network = v.network
    }
  }
}




