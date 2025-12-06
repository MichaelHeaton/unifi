#!/bin/bash

# Import all missing DNS records

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "📥 Importing Missing DNS Records"
echo "=================================="
echo ""

# Get list of DNS records to import
import_count=0
success_count=0
fail_count=0

cat "$TERRAFORM_DIR/import-ids.txt" | grep "^unifi_dns_record\." | grep -v "^#" | while IFS='=' read -r resource id; do
  resource=$(echo "$resource" | xargs)
  id=$(echo "$id" | tr -d '"' | xargs)
  resource_name=$(echo "$resource" | sed 's/unifi_dns_record\.//')

  # Check if already in state
  if terraform state list 2>/dev/null | grep -q "^${resource}$"; then
    echo "⏭️  Skipping $resource_name (already imported)"
    continue
  fi

  echo "📥 Importing $resource_name..."
  if terraform import "$resource" "$id" 2>&1 | grep -q "Import successful"; then
    echo "   ✅ Success"
    ((success_count++))
  else
    echo "   ❌ Failed"
    ((fail_count++))
  fi
  ((import_count++))

  # Rate limiting - wait between imports
  sleep 2
done

echo ""
echo "=========================================="
echo "Import Summary:"
echo "  ✅ Imported: $success_count"
echo "  ❌ Failed: $fail_count"
echo "  ⏭️  Skipped: $((import_count - success_count - fail_count))"

