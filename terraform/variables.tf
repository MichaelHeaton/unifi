# UniFi Network Variables
# Configuration variables for UniFi network management

# UniFi Controller Configuration
# Credentials can be provided via:
# 1. HashiCorp Vault (if available) - see vault-integration.tf
# 2. Variables (fallback when Vault is unavailable)
# 3. Environment variables (TF_VAR_unifi_api_key, etc.)

variable "unifi_api_url" {
  description = "UniFi controller API URL"
  type        = string
  default     = "https://unifi-mgmt.specterrealm.com"
}

variable "unifi_api_key" {
  description = "UniFi controller API key - Site Manager API key (optional, will use Vault if available)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "unifi_udm_api_key" {
  description = "UniFi UDM Pro local API key (from Control Plane > Integrations > API Keys)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "unifi_username" {
  description = "UniFi controller username (optional, will use Vault if available)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "unifi_password" {
  description = "UniFi controller password (optional, will use Vault if available)"
  type        = string
  default     = ""
  sensitive   = true
}

# WLAN Configuration (optional, will use Vault if available)
variable "wlan_main_password" {
  description = "Main WLAN password (optional, will use Vault if available)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "wlan_main_ssid" {
  description = "Main WLAN SSID (optional, will use Vault if available)"
  type        = string
  default     = ""
}

variable "wlan_iot_password" {
  description = "IoT WLAN password (optional, will use Vault if available)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "wlan_iot_ssid" {
  description = "IoT WLAN SSID (optional, will use Vault if available)"
  type        = string
  default     = ""
}

variable "wlan_guest_password" {
  description = "Guest WLAN password (optional, will use Vault if available)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "wlan_guest_ssid" {
  description = "Guest WLAN SSID (optional, will use Vault if available)"
  type        = string
  default     = ""
}

variable "use_vault" {
  description = "Whether to use Vault for credentials (set to false if Vault is unavailable)"
  type        = bool
  default     = true
}

variable "unifi_site" {
  description = "UniFi controller site"
  type        = string
  default     = "default"
}

variable "unifi_allow_insecure" {
  description = "Allow insecure connections to UniFi controller"
  type        = bool
  default     = false
}

# Network Configuration
variable "dns_servers" {
  description = "DNS servers for all VLANs"
  type        = list(string)
  default     = ["8.8.8.8", "8.8.4.4"]
}

variable "dhcp_lease_time" {
  description = "DHCP lease time in seconds"
  type        = number
  default     = 86400 # 24 hours
}

# VLAN Configuration
variable "enable_dhcp" {
  description = "Enable DHCP on all VLANs"
  type        = bool
  default     = true
}

variable "vlan_purpose" {
  description = "Purpose for all VLANs"
  type        = string
  default     = "corporate"
}

# Security Configuration
variable "enable_firewall" {
  description = "Enable firewall rules"
  type        = bool
  default     = true
}

variable "enable_guest_isolation" {
  description = "Enable guest network isolation"
  type        = bool
  default     = true
}

# Monitoring Configuration
variable "enable_monitoring" {
  description = "Enable network monitoring"
  type        = bool
  default     = true
}

variable "monitoring_retention" {
  description = "Monitoring data retention in days"
  type        = number
  default     = 30
}
