# UniFi Firewall Rules
# Firewall rules for network access control

# Allow access from Management (VLAN 15) to Production (VLAN 10)
# This allows the desktop on VLAN 15 to access the Plex VM on VLAN 10
# Note: VLAN 5 (Family) should NOT have direct access - they must go through Traefik reverse proxy

# Rule: Allow Management (VLAN 15) to Production (VLAN 10)
resource "unifi_firewall_rule" "allow_mgmt_to_production" {
  name    = "Allow Mgmt to Production"
  action  = "accept"
  ruleset = "LAN_IN" # Rules that apply to traffic coming into the network

  protocol = "all" # Allow all protocols (TCP, UDP, ICMP, etc.)

  # Source: VLAN 15 (Management) - use address directly
  src_address = "172.16.15.0/24"

  # Destination: VLAN 10 (Production) - use address directly
  dst_address = "172.16.10.0/24"

  # Rule settings
  # Rule index: Using 20000 (5-digit range for newer UniFi Network Application versions)
  rule_index = 20000
  enabled    = true
  logging    = false
}
