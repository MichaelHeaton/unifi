#!/bin/bash

# Import Static DNS Records
# This script imports static DNS records into Terraform state using the IDs from the backup analysis

set -e

echo "🌐 Importing UniFi Static DNS Records..."

# List of DNS records to import (resource_name:id)
dns_records=(
    "portainer:66fc4d90ff2c6622dc7e4166"
    "whoami:68c2eff8c32d671f485232b0"
    "jenkins:68c754d1c32d671f4859132c"
    "admin:68c595a9c32d671f48563107"
    "gpu01:68ae0ee849b6161af59f8577"
    "nuc01:68ae1e8e49b6161af59faa36"
    "nuc02:68ae1ea049b6161af59faa44"
    "nuc01_cl:68ae2b0e49b6161af59fc21d"
    "nuc02_cl:68ae2b1f49b6161af59fc235"
    "gpu01_cl:68ae2b2d49b6161af59fc24a"
    "traefik:68c2f016c32d671f485232c2"
    "portainer_mgmt:68c350abc32d671f4852bb55"
    "jenkins_mgmt:68c7553ec32d671f48591397"
    "jenkins_agent_01:68c75568c32d671f485913bc"
)

for record_entry in "${dns_records[@]}"; do
    IFS=':' read -r resource_name record_id <<< "$record_entry"
    echo "Importing DNS record: $resource_name (ID: $record_id)"
    terraform import "unifi_dns_record.${resource_name}" "$record_id"
    echo "Waiting 5 seconds to avoid rate limiting..."
    sleep 5
done

echo "All DNS records import commands executed. Running terraform plan to verify..."
terraform plan