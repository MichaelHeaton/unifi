# UniFi Static Routes
# These routes were extracted from the UniFi backup file analysis

resource "unifi_static_route" "vpn_to_lan" {
  name      = "VPN to LAN"
  network   = "192.168.3.0/24"
  distance  = 2
  type      = "interface-route"
  interface = "5f9b136a34ef8006578d187e" # Default network interface
}
