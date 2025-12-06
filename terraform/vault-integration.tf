# Vault Integration for UniFi Network Management
# This file configures Terraform to use HashiCorp Vault for sensitive data (when available)
# Falls back to variables if Vault is unavailable

# Note: Vault provider configuration is in terraform.tf

# Data source to read UniFi controller credentials from Vault (only if use_vault is true)
data "vault_kv_secret_v2" "unifi_credentials" {
  count = var.use_vault ? 1 : 0
  mount = "secret"
  name  = "unifi/controller-credentials"
}

# Data source to read WLAN passwords from Vault (only if use_vault is true)
# Note: WLAN passwords are now organized by role in separate secrets
data "vault_kv_secret_v2" "wlan_main" {
  count = var.use_vault ? 1 : 0
  mount = "secret"
  name  = "unifi/wlan/main"
}

data "vault_kv_secret_v2" "wlan_iot" {
  count = var.use_vault ? 1 : 0
  mount = "secret"
  name  = "unifi/wlan/iot"
}

data "vault_kv_secret_v2" "wlan_guest" {
  count = var.use_vault ? 1 : 0
  mount = "secret"
  name  = "unifi/wlan/guest"
}

# Local values for UniFi controller configuration
# Uses Vault if available and use_vault is true, otherwise falls back to variables
locals {
  # UniFi credentials: Vault first, then variables
  unifi_username = var.use_vault && length(data.vault_kv_secret_v2.unifi_credentials) > 0 ? try(
    data.vault_kv_secret_v2.unifi_credentials[0].data["unifi_username"],
    var.unifi_username
  ) : var.unifi_username != "" ? var.unifi_username : null

  unifi_password = var.use_vault && length(data.vault_kv_secret_v2.unifi_credentials) > 0 ? try(
    data.vault_kv_secret_v2.unifi_credentials[0].data["unifi_password"],
    var.unifi_password
  ) : var.unifi_password != "" ? var.unifi_password : null

  unifi_api_key = var.use_vault && length(data.vault_kv_secret_v2.unifi_credentials) > 0 ? try(
    data.vault_kv_secret_v2.unifi_credentials[0].data["unifi_api_key"],
    var.unifi_api_key
  ) : var.unifi_api_key != "" ? var.unifi_api_key : null

  # UDM Pro local API key (separate from Site Manager API key)
  unifi_udm_api_key = var.unifi_udm_api_key != "" ? var.unifi_udm_api_key : null

  # WLAN passwords and SSIDs: Vault first, then variables
  wlan_main_password = var.use_vault && length(data.vault_kv_secret_v2.wlan_main) > 0 ? try(
    data.vault_kv_secret_v2.wlan_main[0].data["password"],
    var.wlan_main_password
  ) : var.wlan_main_password != "" ? var.wlan_main_password : null

  wlan_main_ssid = var.use_vault && length(data.vault_kv_secret_v2.wlan_main) > 0 ? try(
    data.vault_kv_secret_v2.wlan_main[0].data["ssid"],
    var.wlan_main_ssid
  ) : var.wlan_main_ssid != "" ? var.wlan_main_ssid : null

  wlan_iot_password = var.use_vault && length(data.vault_kv_secret_v2.wlan_iot) > 0 ? try(
    data.vault_kv_secret_v2.wlan_iot[0].data["password"],
    var.wlan_iot_password
  ) : var.wlan_iot_password != "" ? var.wlan_iot_password : null

  wlan_iot_ssid = var.use_vault && length(data.vault_kv_secret_v2.wlan_iot) > 0 ? try(
    data.vault_kv_secret_v2.wlan_iot[0].data["ssid"],
    var.wlan_iot_ssid
  ) : var.wlan_iot_ssid != "" ? var.wlan_iot_ssid : null

  wlan_guest_password = var.use_vault && length(data.vault_kv_secret_v2.wlan_guest) > 0 ? try(
    data.vault_kv_secret_v2.wlan_guest[0].data["password"],
    var.wlan_guest_password
  ) : var.wlan_guest_password != "" ? var.wlan_guest_password : null

  wlan_guest_ssid = var.use_vault && length(data.vault_kv_secret_v2.wlan_guest) > 0 ? try(
    data.vault_kv_secret_v2.wlan_guest[0].data["ssid"],
    var.wlan_guest_ssid
  ) : var.wlan_guest_ssid != "" ? var.wlan_guest_ssid : "BigBrothersWiFi"
}
