#!/bin/bash

# Script to help identify all DNS records that need to be imported
# Since the API doesn't return DNS records, we need to manually identify them

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "📋 DNS Records Analysis"
echo "======================"
echo ""

# Get DNS records currently in Terraform state
echo "DNS records in Terraform state:"
terraform state list | grep dns_record | sed 's/unifi_dns_record\.//' | sort | nl
echo ""

# Get DNS records defined in dns-records.tf
echo "DNS records defined in dns-records.tf:"
grep 'resource "unifi_dns_record"' "$TERRAFORM_DIR/dns-records.tf" | sed 's/.*"unifi_dns_record" "\([^"]*\)".*/\1/' | sort | nl
echo ""

# Count
terraform_count=$(terraform state list | grep dns_record | wc -l | xargs)
tf_file_count=$(grep 'resource "unifi_dns_record"' "$TERRAFORM_DIR/dns-records.tf" | wc -l | xargs)

echo "Summary:"
echo "  - In Terraform state: $terraform_count records"
echo "  - Defined in dns-records.tf: $tf_file_count records"
echo "  - Total in UniFi UI: 41 records"
echo "  - Missing: $((41 - terraform_count)) records"
echo ""
echo "⚠️  We need to:"
echo "  1. Identify all 41 DNS records from the UniFi UI"
echo "  2. Get their IDs (via browser DevTools or backup file)"
echo "  3. Add missing records to dns-records.tf"
echo "  4. Import all missing records"
echo ""
echo "💡 Tip: Check the old import script for more DNS record IDs:"
echo "   scripts/import-dns-records.sh"

