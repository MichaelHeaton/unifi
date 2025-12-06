#!/bin/bash
# Setup script for Vault integration with Terraform
# This script sets up the environment for using Vault with Terraform

echo "🔐 Setting up Vault Integration for Terraform"
echo "=============================================="

# Check if Vault is available
if ! command -v vault &> /dev/null; then
    echo "❌ Error: Vault CLI not found"
    echo "   Please install Vault CLI first"
    exit 1
fi

# Check if VAULT_ADDR is set
if [ -z "$VAULT_ADDR" ]; then
    echo "❌ Error: VAULT_ADDR environment variable not set"
    echo "   Please set VAULT_ADDR to your Vault server URL"
    echo "   Example: export VAULT_ADDR=\"https://vault.yourdomain.com\""
    exit 1
fi

# Check if VAULT_TOKEN is set
if [ -z "$VAULT_TOKEN" ]; then
    echo "❌ Error: VAULT_TOKEN environment variable not set"
    echo "   Please set VAULT_TOKEN to your Vault token"
    echo "   Example: export VAULT_TOKEN=\"your-vault-token\""
    exit 1
fi

# Test Vault connection
echo "🔍 Testing Vault connection..."
if vault status &> /dev/null; then
    echo "✅ Vault connection successful"
else
    echo "❌ Error: Cannot connect to Vault"
    echo "   Please check your VAULT_ADDR and VAULT_TOKEN"
    exit 1
fi

# Check if secrets exist
echo "🔍 Checking Vault secrets..."

# Check UniFi credentials
if vault kv get unifi/controller-credentials &> /dev/null; then
    echo "✅ UniFi credentials found in Vault"
else
    echo "❌ Error: UniFi credentials not found in Vault"
    echo "   Please store credentials with:"
    echo "   vault kv put unifi/controller-credentials \\"
    echo "     unifi_username=\"your-username\" \\"
    echo "     unifi_password=\"your-password\""
    exit 1
fi

# Check WLAN passwords
if vault kv get unifi/wlan-passwords &> /dev/null; then
    echo "✅ WLAN passwords found in Vault"
else
    echo "❌ Error: WLAN passwords not found in Vault"
    echo "   Please store passwords with:"
    echo "   vault kv put unifi/wlan-passwords \\"
    echo "     wlan_skynet_global_password=\"password1\" \\"
    echo "     wlan_skynet_password=\"password2\" \\"
    echo "     wlan_skynet_iot_password=\"password3\" \\"
    echo "     wlan_wifightclub_password=\"password4\" \\"
    echo "     wlan_bigbrothers_password=\"password5\""
    exit 1
fi

echo ""
echo "🎉 Vault integration setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Run: terraform init"
echo "2. Run: terraform plan"
echo "3. Run: terraform apply (when ready)"
echo ""
echo "🔐 All sensitive data is now stored securely in Vault!"
