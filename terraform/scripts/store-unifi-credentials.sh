#!/bin/bash
# Script to store UniFi credentials in Vault
# This script stores UniFi controller credentials and WLAN passwords in Vault

echo "🔐 Storing UniFi Credentials in Vault"
echo "===================================="

# Check if Vault CLI is available
if ! command -v vault &> /dev/null; then
    echo "❌ Error: Vault CLI not found"
    exit 1
fi

# Set Vault address
export VAULT_ADDR="https://vault.specterrealm.com"
echo "✅ Vault address set to: $VAULT_ADDR"

# Test Vault connection
echo "🔍 Testing Vault connection..."
if vault status &> /dev/null; then
    echo "✅ Vault connection successful"
else
    echo "❌ Error: Cannot connect to Vault"
    echo "   Please authenticate first: vault auth -method=userpass username=your-username"
    exit 1
fi

# Use existing homelab/ KV v2 secrets engine
echo "🔧 Using existing homelab/ KV v2 secrets engine..."
# No need to enable - homelab/ mount is managed by Terraform

# Store UniFi controller credentials
echo "📝 Storing UniFi controller credentials..."
echo "Please enter your UniFi controller credentials:"
read -p "UniFi Username: " UNIFI_USERNAME
read -s -p "UniFi Password: " UNIFI_PASSWORD
echo ""

# Store credentials in Vault under homelab/ structure
vault kv put homelab/infrastructure/unifi/headquarters/controller-credentials \
  unifi_username="$UNIFI_USERNAME" \
  unifi_password="$UNIFI_PASSWORD"

if [ $? -eq 0 ]; then
    echo "✅ UniFi controller credentials stored successfully"
else
    echo "❌ Error: Failed to store UniFi credentials"
    exit 1
fi

# Store WLAN passwords
echo "📝 Storing WLAN passwords..."
echo "Please enter your WLAN passwords:"
read -p "Skynet Global Password: " SKYNET_GLOBAL_PASSWORD
read -p "Skynet Password: " SKYNET_PASSWORD
read -p "Skynet IoT Password: " SKYNET_IOT_PASSWORD
read -p "WiFightClub Password: " WIFIGHTCLUB_PASSWORD
read -p "BigBrothers Password: " BIGBROTHERS_PASSWORD

# Store WLAN passwords in Vault under homelab/ structure
vault kv put homelab/infrastructure/unifi/headquarters/wlan-passwords \
  wlan_skynet_global_password="$SKYNET_GLOBAL_PASSWORD" \
  wlan_skynet_password="$SKYNET_PASSWORD" \
  wlan_skynet_iot_password="$SKYNET_IOT_PASSWORD" \
  wlan_wifightclub_password="$WIFIGHTCLUB_PASSWORD" \
  wlan_bigbrothers_password="$BIGBROTHERS_PASSWORD"

if [ $? -eq 0 ]; then
    echo "✅ WLAN passwords stored successfully"
else
    echo "❌ Error: Failed to store WLAN passwords"
    exit 1
fi

echo ""
echo "🎉 All credentials stored successfully in Vault!"
echo ""
echo "📋 Next steps:"
echo "1. Start Vault agent: vault agent -config=vault-agent.hcl"
echo "2. Source environment: source /tmp/vault-env"
echo "3. Test Terraform: terraform plan"
echo ""
echo "🔐 Your credentials are now securely stored in Vault!"

