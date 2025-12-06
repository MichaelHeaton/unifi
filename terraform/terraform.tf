# Terraform Configuration for Network Infrastructure
# This configuration manages UniFi network infrastructure using HCP Terraform Cloud backend

terraform {
  required_version = ">= 1.0"

  required_providers {
    unifi = {
      source  = "ubiquiti-community/unifi"
      version = "~> 0.1"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.0"
      # Vault provider is optional - only used if use_vault is true
    }
  }

  # HCP Terraform Cloud backend (CLI-driven workflow)
  # Organization name can be overridden via TF_CLOUD_ORGANIZATION environment variable
  cloud {
    organization = "SpecterRealm"

    workspaces {
      name = "homelab-unifi"
    }
  }
}

# Configure the UniFi Provider
# Try UDM Pro local API key first, then Site Manager API key, then username/password
provider "unifi" {
  # Prefer UDM Pro local API key (from Control Plane > Integrations)
  api_key = local.unifi_udm_api_key != null ? local.unifi_udm_api_key : (local.unifi_api_key != null && local.unifi_api_key != "" ? local.unifi_api_key : null)
  # Fall back to username/password if no API key available
  username       = local.unifi_udm_api_key == null && (local.unifi_api_key == null || local.unifi_api_key == "") ? local.unifi_username : null
  password       = local.unifi_udm_api_key == null && (local.unifi_api_key == null || local.unifi_api_key == "") ? local.unifi_password : null
  api_url        = var.unifi_api_url
  site           = var.unifi_site
  allow_insecure = var.unifi_allow_insecure
}

# Configure the Vault Provider
# Vault token will be read from VAULT_TOKEN environment variable
# Provider is configured but only used if use_vault is true
provider "vault" {
  address = "https://vault.specterrealm.com"
  # If Vault is unavailable, set use_vault = false in terraform.tfvars
}
