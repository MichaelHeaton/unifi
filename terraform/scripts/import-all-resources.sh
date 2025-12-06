#!/bin/bash

# Import All Resources from import-ids.txt
# This script reads import-ids.txt and imports all resources with IDs

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
IMPORT_FILE="$TERRAFORM_DIR/import-ids.txt"

cd "$TERRAFORM_DIR"

if [ ! -f "$IMPORT_FILE" ]; then
    echo "❌ Import IDs file not found: $IMPORT_FILE"
    exit 1
fi

echo "📥 Importing Resources from import-ids.txt"
echo "=========================================="
echo ""

# Extract import commands from the file
# Format: unifi_resource_type.resource_name = "id"

IMPORTED=0
SKIPPED=0
FAILED=0

while IFS= read -r line; do
    # Skip comments and empty lines
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    [[ -z "${line// }" ]] && continue

    # Parse: unifi_resource_type.resource_name = "id"
    if [[ "$line" =~ ^[[:space:]]*unifi_([^.]+)\.([^[:space:]]+)[[:space:]]*=[[:space:]]*\"([^\"]+)\" ]]; then
        resource_type="${BASH_REMATCH[1]}"
        resource_name="${BASH_REMATCH[2]}"
        resource_id="${BASH_REMATCH[3]}"

        # Skip placeholder IDs
        if [[ "$resource_id" == "<id-from-unifi>" ]]; then
            echo "⏭️  Skipping $resource_type.$resource_name (no ID provided)"
            ((SKIPPED++))
            continue
        fi

        echo "📥 Importing $resource_type.$resource_name..."

        if terraform import "unifi_${resource_type}.${resource_name}" "$resource_id" 2>&1; then
            echo "   ✅ Success"
            ((IMPORTED++))
            # Small delay to avoid rate limiting
            sleep 2
        else
            echo "   ❌ Failed"
            ((FAILED++))
        fi
        echo ""
    fi
done < "$IMPORT_FILE"

echo "=========================================="
echo "Import Summary:"
echo "  ✅ Imported: $IMPORTED"
echo "  ⏭️  Skipped: $SKIPPED"
echo "  ❌ Failed: $FAILED"
echo ""

if [ $IMPORTED -gt 0 ]; then
    echo "Running terraform plan to verify imports..."
    terraform plan -out=tfplan
    echo ""
    echo "✅ Import complete! Review the plan above."
    echo "If everything looks good, you can apply: terraform apply tfplan"
fi

