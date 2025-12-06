# UniFi WLAN Configuration
# This file defines all your existing WLANs using centralized configuration

# Skynet Global Defense Network (Main Family WiFi)
resource "unifi_wlan" "skynet_global_defense" {
  name           = local.wlan_main_ssid
  security       = "wpapsk"
  passphrase     = local.wlan_main_password
  network_id     = unifi_network.family.id
  wlan_band      = "both"
  user_group_id  = "5f9b136a34ef8006578d187f"
  ap_group_ids   = ["5fcb5af8272e4f03936dc514"]
  bss_transition = false
  no2ghz_oui     = false

  lifecycle {
    ignore_changes = [
      name,
      passphrase
    ]
  }
}

# SkyNet (IoT 5GHz)
resource "unifi_wlan" "skynet" {
  name          = local.wlan_iot_ssid
  security      = "wpapsk"
  passphrase    = local.wlan_iot_password
  network_id    = unifi_network.iot.id
  wlan_band     = "5g"
  user_group_id = "5f9b136a34ef8006578d187f"
  ap_group_ids  = ["5fcb5af8272e4f03936dc514"]

  lifecycle {
    ignore_changes = [
      name,
      passphrase
    ]
  }
}

# SkyNet_IoT (IoT 2.4GHz)
resource "unifi_wlan" "skynet_iot" {
  name          = "SkyNet_IoT"
  security      = "wpapsk"
  passphrase    = local.wlan_iot_password
  network_id    = unifi_network.iot.id
  wlan_band     = "2g"
  user_group_id = "5f9b136a34ef8006578d187f"
  ap_group_ids  = ["5fcb5af8272e4f03936dc514"]
  no2ghz_oui    = false

  lifecycle {
    ignore_changes = [
      name,
      passphrase
    ]
  }
}

# WiFightClub (IoT WPA3)
resource "unifi_wlan" "wifightclub" {
  name          = local.wlan_iot_ssid
  security      = "wpapsk"
  passphrase    = local.wlan_iot_password
  network_id    = unifi_network.iot.id
  wlan_band     = "both"
  user_group_id = "5f9b136a34ef8006578d187f"
  ap_group_ids  = ["5fcb5af8272e4f03936dc514"]
  pmf_mode      = "required"
  wpa3_support  = true

  lifecycle {
    ignore_changes = [
      name,
      passphrase
    ]
  }
}

# BigBrothersWiFi (IoT 2.4GHz)
resource "unifi_wlan" "bigbrotherswifi" {
  name          = local.wlan_guest_ssid
  security      = "wpapsk"
  passphrase    = local.wlan_guest_password != null && local.wlan_guest_password != "" ? local.wlan_guest_password : "changeme"
  network_id    = unifi_network.iot.id
  wlan_band     = "2g"
  user_group_id = "5f9b136a34ef8006578d187f"
  ap_group_ids  = ["5fcb5af8272e4f03936dc514"]
  l2_isolation  = true
  no2ghz_oui    = false

  lifecycle {
    ignore_changes = [
      name,
      passphrase
    ]
  }
}
