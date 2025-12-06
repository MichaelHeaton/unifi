#!/bin/bash

# Import Firewall Rules from Backup Analysis
# This script imports the key firewall rules using their actual IDs from the backup

set -e

echo "🔥 Importing UniFi Firewall Rules from Backup Analysis..."

# Import the three key firewall rules with their actual IDs
echo "Importing: Allow All → pg_dns to Gateway (ID: 68a6524749b6161af5956092)"
terraform import "unifi_firewall_rule.allow_all_pg_dns_to_gateway" "68a6524749b6161af5956092"
echo "Waiting 5 seconds to avoid rate limiting..."
sleep 5

echo "Importing: Allow All → pg_ntp to Gateway (ID: 68a6527349b6161af59560d3)"
terraform import "unifi_firewall_rule.allow_all_pg_ntp_to_gateway" "68a6527349b6161af59560d3"
echo "Waiting 5 seconds to avoid rate limiting..."
sleep 5

echo "Importing: Allow traefik-internal to whoami (ID: 68c457bec32d671f48543d63)"
terraform import "unifi_firewall_rule.allow_traefik_internal_to_whoami" "68c457bec32d671f48543d63"
echo "Waiting 5 seconds to avoid rate limiting..."
sleep 5

echo "✅ All firewall rules imported successfully!"
echo "Running terraform plan to verify the imports..."

terraform plan
