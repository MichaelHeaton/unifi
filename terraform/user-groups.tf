# User Groups (Client Groups)
# This file defines user groups with bandwidth limits

# Default user group
resource "unifi_user_group" "default" {
  name              = "Default"
  qos_rate_max_down = -1 # No limit
  qos_rate_max_up   = -1 # No limit
}

# Guest user group
resource "unifi_user_group" "guest" {
  name              = "Guest"
  qos_rate_max_down = -1 # No limit
  qos_rate_max_up   = -1 # No limit
}
