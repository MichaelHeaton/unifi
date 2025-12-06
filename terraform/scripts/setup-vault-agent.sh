#!/bin/bash
# Setup script for Vault Agent integration
# This script sets up Vault agent for seamless Terraform integration

echo "🔐 Setting up Vault Agent for Terraform Integration"
echo "=================================================="

# Check if Vault CLI is available
if ! command -v vault &> /dev/null; then
    echo "❌ Error: Vault CLI not found"
    echo "   Please install Vault CLI first:"
    echo "   brew install vault"
    exit 1
fi

# Check if Vault agent is available
if ! command -v vault &> /dev/null; then
    echo "❌ Error: Vault agent not found"
    echo "   Vault agent is included with Vault CLI"
    exit 1
fi

echo "✅ Vault CLI found"

# Set Vault address
export VAULT_ADDR="https://vault.specterrealm.com"
echo "✅ Vault address set to: $VAULT_ADDR"

# Test Vault connection
echo "🔍 Testing Vault connection..."
if vault status &> /dev/null; then
    echo "✅ Vault connection successful"
else
    echo "❌ Error: Cannot connect to Vault"
    echo "   Please check your network connection and Vault server status"
    exit 1
fi

# Create necessary directories
mkdir -p /tmp/vault-agent
echo "✅ Created agent directories"

# Update vault-agent.hcl with your credentials
echo "📝 Please update vault-agent.hcl with your actual credentials:"
echo "   1. Username: Replace 'admin' with your Vault username"
echo "   2. Password: Replace 'your-password' with your Vault password"
echo ""
echo "   Then run: vault agent -config=vault-agent.hcl"

echo ""
echo "🎉 Vault Agent setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Update vault-agent.hcl with your credentials"
echo "2. Start Vault agent: vault agent -config=vault-agent.hcl"
echo "3. In another terminal, source the environment: source /tmp/vault-env"
echo "4. Run Terraform commands"
echo ""
echo "🔐 The agent will automatically authenticate and provide tokens to Terraform!"

