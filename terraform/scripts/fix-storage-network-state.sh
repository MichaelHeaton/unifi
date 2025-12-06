#!/bin/bash

# Fix the storage network state - it's pointing to the wrong network ID
# Storage network should be ID: 68951b8149b6161af5871100 (vlan 30)
# IoT network should be ID: 65d5228af2c32451e441287d (vlan 200)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$TERRAFORM_DIR"

echo "🔧 Fixing Storage Network State"
echo "==============================="
echo ""

# Get current state IDs
STORAGE_CURRENT_ID=$(terraform state show unifi_network.storage 2>/dev/null | grep "^id " | awk '{print $3}' | tr -d '"' || echo "")
IOT_CURRENT_ID=$(terraform state show unifi_network.iot 2>/dev/null | grep "^id " | awk '{print $3}' | tr -d '"' || echo "")

STORAGE_CORRECT_ID="68951b8149b6161af5871100"
IOT_CORRECT_ID="65d5228af2c32451e441287d"

echo "Current state:"
echo "  unifi_network.storage: $STORAGE_CURRENT_ID"
echo "  unifi_network.iot: $IOT_CURRENT_ID"
echo ""
echo "Correct IDs:"
echo "  Storage network: $STORAGE_CORRECT_ID"
echo "  IoT network: $IOT_CORRECT_ID"
echo ""

if [ "$STORAGE_CURRENT_ID" = "$IOT_CORRECT_ID" ]; then
    echo "⚠️  Storage network is pointing to IoT network ID!"
    echo "   Fixing by updating state..."
    echo ""

    # Remove from state
    terraform state rm unifi_network.storage

    # Re-import with correct ID
    terraform import unifi_network.storage "$STORAGE_CORRECT_ID"

    echo ""
    echo "✅ Storage network state fixed!"
else
    echo "✅ Storage network state looks correct"
fi

if [ "$IOT_CURRENT_ID" != "$IOT_CORRECT_ID" ] && [ -n "$IOT_CURRENT_ID" ]; then
    echo "⚠️  IoT network has wrong ID, fixing..."
    terraform state rm unifi_network.iot
    terraform import unifi_network.iot "$IOT_CORRECT_ID"
    echo "✅ IoT network state fixed!"
fi

echo ""
echo "Running plan to verify..."
terraform plan -out=tfplan-verify.binary 2>&1 | grep -E "(Plan:|No changes|will be)" | head -3

