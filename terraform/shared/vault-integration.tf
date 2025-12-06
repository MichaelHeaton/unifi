# Shared Vault Integration for UniFi Network Management
# This file provides Vault integration that can be used across all environments

# Note: Vault provider configuration is in the main terraform.tf

# Data source to read UniFi controller credentials from Vault
data "vault_kv_secret_v2" "unifi_credentials" {
  mount = "secret"
  name  = "unifi/controller-credentials"
}

# Data source to read WLAN passwords from Vault
# Note: WLAN passwords are now organized by role in separate secrets
data "vault_kv_secret_v2" "wlan_main" {
  mount = "secret"
  name  = "unifi/wlan/main"
}

data "vault_kv_secret_v2" "wlan_iot" {
  mount = "secret"
  name  = "unifi/wlan/iot"
}

data "vault_kv_secret_v2" "wlan_guest" {
  mount = "secret"
  name  = "unifi/wlan/guest"
}

# Local values for UniFi controller configuration
locals {
  unifi_username = data.vault_kv_secret_v2.unifi_credentials.data["unifi_username"]
  unifi_password = data.vault_kv_secret_v2.unifi_credentials.data["unifi_password"]
  unifi_api_key  = data.vault_kv_secret_v2.unifi_credentials.data["unifi_api_key"]

  # WLAN passwords from Vault (organized by role)
  wlan_main_password  = data.vault_kv_secret_v2.wlan_main.data["password"]
  wlan_iot_password   = data.vault_kv_secret_v2.wlan_iot.data["password"]
  wlan_guest_password = data.vault_kv_secret_v2.wlan_guest.data["password"]
}

# Outputs for use by calling modules
output "unifi_api_key" {
  description = "UniFi API key from Vault"
  value       = local.unifi_api_key
  sensitive   = true
}

output "unifi_username" {
  description = "UniFi username from Vault"
  value       = local.unifi_username
  sensitive   = true
}

output "unifi_password" {
  description = "UniFi password from Vault"
  value       = local.unifi_password
  sensitive   = true
}

output "wlan_passwords" {
  description = "WLAN passwords from Vault (organized by role)"
  value = {
    main  = local.wlan_main_password
    iot   = local.wlan_iot_password
    guest = local.wlan_guest_password
  }
  sensitive = true
}
