#!/bin/bash

# DNS Records Review and Test Script
# This script reviews all DNS records in Terraform and tests their resolution

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$TERRAFORM_DIR"

echo "🌐 DNS Records Review and Test"
echo "=============================="
echo ""

# Get all DNS records from Terraform state
echo "📋 DNS Records in Terraform State:"
echo "-----------------------------------"
DNS_COUNT=$(terraform state list | grep "unifi_dns_record" | wc -l | tr -d ' ')
echo "Total DNS records: $DNS_COUNT"
echo ""

# Create a detailed report
REPORT_FILE="$TERRAFORM_DIR/DNS-REVIEW-REPORT.md"
echo "# DNS Records Review Report" > "$REPORT_FILE"
echo "Generated: $(date)" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "## Summary" >> "$REPORT_FILE"
echo "- **Total DNS Records in Terraform**: $DNS_COUNT" >> "$REPORT_FILE"
echo "- **Missing Records**: 6 (documented in MISSING-6-DNS-RECORDS.md)" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "## All DNS Records" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "| Resource Name | DNS Name | Type | Value | Status |" >> "$REPORT_FILE"
echo "|---------------|----------|------|-------|--------|" >> "$REPORT_FILE"

# Process each DNS record
for record in $(terraform state list | grep "unifi_dns_record" | sort); do
    RESOURCE_NAME=$(echo "$record" | sed 's/unifi_dns_record\.//')

    # Get record details from state
    NAME=$(terraform state show "$record" 2>/dev/null | grep "name " | awk '{print $3}' | tr -d '"')
    TYPE=$(terraform state show "$record" 2>/dev/null | grep "record_type" | awk '{print $3}' | tr -d '"')
    VALUE=$(terraform state show "$record" 2>/dev/null | grep "^    value" | awk '{print $3}' | tr -d '"')

    # Test DNS resolution (only for A records and CNAME targets)
    if [ "$TYPE" = "A" ]; then
        # For A records, test if the IP is reachable
        if ping -c 1 -W 1 "$VALUE" >/dev/null 2>&1; then
            STATUS="✅ IP reachable"
        else
            STATUS="⚠️  IP not reachable (may be offline)"
        fi
    elif [ "$TYPE" = "CNAME" ]; then
        # For CNAME, test if target resolves
        TARGET=$(echo "$VALUE" | sed 's/\.$//')
        if dig +short "$TARGET" >/dev/null 2>&1; then
            STATUS="✅ Target resolves"
        else
            STATUS="⚠️  Target may not resolve"
        fi
    else
        STATUS="ℹ️  Not tested"
    fi

    echo "| \`$RESOURCE_NAME\` | \`$NAME\` | $TYPE | \`$VALUE\` | $STATUS |" >> "$REPORT_FILE"

    # Also print to console
    printf "  %-30s %-8s %-40s %s\n" "$NAME" "$TYPE" "$VALUE" "$STATUS"
done

echo "" >> "$REPORT_FILE"
echo "## Missing DNS Records" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "The following 6 DNS records are in the UniFi UI but not in Terraform:" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "1. \`hubitat.SpecterRealm.com\` (A) → \`172.16.0.17\`" >> "$REPORT_FILE"
echo "2. \`NAS01.SpecterRealm.com\` (A) → \`172.16.5.5\`" >> "$REPORT_FILE"
echo "3. \`NAS01-Mgmt.specterrealm.com\` (A) → \`172.16.15.5\`" >> "$REPORT_FILE"
echo "4. \`NAS01-Prod.SpecterRealm.com\` (A) → \`172.16.10.5\`" >> "$REPORT_FILE"
echo "5. \`NAS01-Storage.specterrealm.com\` (A) → \`172.16.30.5\`" >> "$REPORT_FILE"
echo "6. \`minecraft01.specterrealm.com\` (A) → \`172.16.5.74\`" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "See \`MISSING-6-DNS-RECORDS.md\` for details." >> "$REPORT_FILE"

echo ""
echo "✅ DNS review complete!"
echo "📄 Full report saved to: $REPORT_FILE"
echo ""
echo "📊 Summary:"
echo "  - DNS records in Terraform: $DNS_COUNT"
echo "  - Missing records: 6"
echo "  - Total expected: 41"

