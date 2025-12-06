#!/bin/bash

# Import Static Routes
# This script imports static routes into Terraform state using the IDs from the backup analysis

set -e

echo "🛣️ Importing UniFi Static Routes..."

# List of static routes to import (resource_name:id)
static_routes=(
    "vpn_to_lan:604923d8272e4f044c2539f5"
)

for route_entry in "${static_routes[@]}"; do
    IFS=':' read -r resource_name route_id <<< "$route_entry"
    echo "Importing static route: $resource_name (ID: $route_id)"
    terraform import "unifi_static_route.${resource_name}" "$route_id"
    echo "Waiting 5 seconds to avoid rate limiting..."
    sleep 5
done

echo "All static routes import commands executed. Running terraform plan to verify..."
terraform plan
