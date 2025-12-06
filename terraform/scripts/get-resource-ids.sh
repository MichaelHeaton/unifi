#!/bin/bash

# Get Resource IDs from UniFi Controller via API
# This script queries the UniFi API to extract resource IDs for Terraform import

set -e

# Load credentials from environment or terraform.tfvars
if [ -f "../terraform.tfvars" ]; then
    # Try to extract from tfvars (basic parsing)
    UNIFI_API_URL=$(grep "^unifi_api_url" ../terraform.tfvars | cut -d'"' -f2 | head -1)
    UNIFI_SITE=$(grep "^unifi_site" ../terraform.tfvars | cut -d'"' -f2 | head -1)
    UNIFI_API_KEY=$(grep "^unifi_api_key" ../terraform.tfvars | cut -d'"' -f2 | head -1)
fi

# Override with environment variables if set
UNIFI_API_URL="${TF_VAR_unifi_api_url:-${UNIFI_API_URL:-https://unifi.mgmt.specterrealm.com}}"
UNIFI_SITE="${TF_VAR_unifi_site:-${UNIFI_SITE:-default}}"
UNIFI_API_KEY="${TF_VAR_unifi_api_key:-${UNIFI_API_KEY}}"
UNIFI_USERNAME="${TF_VAR_unifi_username:-${UNIFI_USERNAME}}"
UNIFI_PASSWORD="${TF_VAR_unifi_password:-${UNIFI_PASSWORD}}"

if [ -z "$UNIFI_API_KEY" ] && [ -z "$UNIFI_USERNAME" ]; then
    echo "❌ Error: UniFi credentials not found"
    echo "Set TF_VAR_unifi_api_key or provide credentials in terraform.tfvars"
    exit 1
fi

OUTPUT_FILE="${1:-import-ids.txt}"

echo "🔍 Extracting resource IDs from UniFi Controller"
echo "API URL: $UNIFI_API_URL"
echo "Site: $UNIFI_SITE"
echo "Output: $OUTPUT_FILE"
echo ""

# Create Python script to query UniFi API
python3 << 'PYTHON_SCRIPT' > "$OUTPUT_FILE"
import sys
import json
import requests
from urllib3.exceptions import InsecureRequestWarning

# Suppress SSL warnings if using self-signed certs
requests.packages.urllib3.disable_warnings(InsecureRequestWarning)

api_url = sys.argv[1]
site = sys.argv[2]
api_key = sys.argv[3] if len(sys.argv) > 3 else None
username = sys.argv[4] if len(sys.argv) > 4 else None
password = sys.argv[5] if len(sys.argv) > 5 else None

base_url = f"{api_url}/api/s/{site}"

# Create session
session = requests.Session()
session.verify = False  # Allow self-signed certs

# Authenticate
if api_key:
    # Use API key authentication
    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json"
    }
else:
    # Use username/password authentication
    login_url = f"{api_url}/api/login"
    login_data = {
        "username": username,
        "password": password
    }
    response = session.post(login_url, json=login_data, verify=False)
    if response.status_code != 200:
        print(f"❌ Authentication failed: {response.status_code}")
        sys.exit(1)
    headers = {"Content-Type": "application/json"}

print("# Terraform Import IDs Extracted from UniFi Controller")
print(f"# API URL: {api_url}")
print(f"# Site: {site}")
print("")

# Helper function to query API
def query_api(endpoint, resource_name):
    try:
        url = f"{base_url}/{endpoint}"
        response = session.get(url, headers=headers, verify=False)
        if response.status_code == 200:
            data = response.json()
            if isinstance(data, list) and len(data) > 0:
                print(f"## {resource_name}")
                for item in data:
                    name = item.get('name', item.get('hostname', 'unknown'))
                    _id = item.get('_id', '')
                    if _id:
                        # Clean name for Terraform resource name
                        clean_name = name.lower().replace(' ', '_').replace('-', '_').replace('.', '_')
                        print(f"# {name}")
                        print(f"unifi_{resource_name.lower().replace(' ', '_')}.{clean_name} = \"{_id}\"")
                print("")
                return len(data)
        else:
            print(f"# Warning: {resource_name} - HTTP {response.status_code}")
    except Exception as e:
        print(f"# Error querying {resource_name}: {e}")
    return 0

# Query different resource types
networks_count = query_api("rest/networkconf", "network")
wlans_count = query_api("rest/wlanconf", "wlan")
firewall_groups_count = query_api("rest/firewallgroup", "firewall_group")
dns_records_count = query_api("rest/dnsrecord", "dns_record")
static_routes_count = query_api("rest/routing", "static_route")
user_groups_count = query_api("rest/usergroup", "user_group")
firewall_rules_count = query_api("rest/firewallrule", "firewall_rule")

print("# Summary")
print(f"# Total Networks: {networks_count}")
print(f"# Total WLANs: {wlans_count}")
print(f"# Total Firewall Groups: {firewall_groups_count}")
print(f"# Total DNS Records: {dns_records_count}")
print(f"# Total Static Routes: {static_routes_count}")
print(f"# Total User Groups: {user_groups_count}")
print(f"# Total Firewall Rules: {firewall_rules_count}")

PYTHON_SCRIPT
"$UNIFI_API_URL" "$UNIFI_SITE" "$UNIFI_API_KEY" "$UNIFI_USERNAME" "$UNIFI_PASSWORD"

echo "✅ Extraction complete! IDs saved to: $OUTPUT_FILE"
echo ""
echo "📋 Next steps:"
echo "1. Review the extracted IDs in $OUTPUT_FILE"
echo "2. Match resource names with your Terraform configuration"
echo "3. Use the IDs to import resources: terraform import <resource_type>.<name> <id>"
echo ""
echo "Example import commands:"
echo "  terraform import unifi_network.default <network-id>"
echo "  terraform import unifi_wlan.skynet_global_defense <wlan-id>"

