# UniFi Security Module Variables

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
