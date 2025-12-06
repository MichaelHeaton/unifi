#!/bin/bash

# Decrypt UniFi Backup File
# Based on: https://www.incredigeek.com/home/extract-unifi-unf-backup-file/
# Uses script from: https://github.com/zhangyoufu/unifi-backup-decrypt

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BACKUP_DIR="$TERRAFORM_DIR/../backup"
WORK_DIR="$TERRAFORM_DIR/tmp-backup-extract"

# Find backup file
BACKUP_FILE=$(find "$BACKUP_DIR" -name "*.unifi" -o -name "*.unf" | head -1)

if [ -z "$BACKUP_FILE" ]; then
    echo "❌ No backup file found in $BACKUP_DIR"
    exit 1
fi

echo "📦 Decrypting UniFi Backup File"
echo "==============================="
echo "Backup file: $BACKUP_FILE"
echo ""

# Create work directory
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

# Check if openssl is available
if ! command -v openssl &> /dev/null; then
    echo "❌ openssl is required but not installed"
    echo "Install with: brew install openssl (macOS) or apt install openssl (Linux)"
    exit 1
fi

# Check if unzip is available
if ! command -v unzip &> /dev/null; then
    echo "❌ unzip is required but not installed"
    echo "Install with: brew install unzip (macOS) or apt install unzip (Linux)"
    exit 1
fi

BACKUP_NAME=$(basename "$BACKUP_FILE" .unifi)
BACKUP_NAME=$(basename "$BACKUP_NAME" .unf)
ZIP_FILE="$WORK_DIR/${BACKUP_NAME}.zip"

echo "Step 1: Decrypting backup file..."
echo "Using AES-128-CBC decryption with UniFi key"

# Decrypt using openssl with the UniFi backup key
# Key: 626379616e676b6d6c756f686d617273
# IV: 75626e74656e74657270726973656170
TMP_FILE=$(mktemp)
trap "rm -f ${TMP_FILE}" EXIT

openssl enc -d -in "$BACKUP_FILE" -out "$TMP_FILE" \
    -aes-128-cbc \
    -K 626379616e676b6d6c756f686d617273 \
    -iv 75626e74656e74657270726973656170 \
    -nopad

echo "Step 2: Repairing zip file..."
# Repair the zip file (UniFi backups sometimes have zip file issues)
yes | zip -FF "$TMP_FILE" --out "$ZIP_FILE" > /dev/null 2>&1 || {
    echo "⚠️  Zip repair had issues, trying direct extraction..."
    cp "$TMP_FILE" "$ZIP_FILE"
}

echo "Step 3: Extracting zip archive..."
EXTRACT_DIR="$WORK_DIR/extracted"
mkdir -p "$EXTRACT_DIR"

# Check if zip is empty or invalid
ZIP_SIZE=$(stat -f%z "$ZIP_FILE" 2>/dev/null || stat -c%s "$ZIP_FILE" 2>/dev/null || echo "0")
if [ "$ZIP_SIZE" -lt 100 ]; then
    echo "⚠️  Zip file appears empty or invalid"
    echo "The .unifi format might be different from .unf format"
    echo ""
    echo "Trying alternative: Direct JSON extraction from decrypted file..."

    # The decrypted file might contain JSON directly
    DECRYPTED_FILE="$WORK_DIR/decrypted.bin"
    openssl enc -d -in "$BACKUP_FILE" -out "$DECRYPTED_FILE" \
        -aes-128-cbc \
        -K 626379616e676b6d6c756f686d617273 \
        -iv 75626e74656e74657270726973656170 \
        -nopad

    # Try to extract JSON from the decrypted binary
    python3 << 'PYTHON_SCRIPT' > "$EXTRACT_DIR/extraction.log" 2>&1
import json
import re
import sys

decrypted_file = "$DECRYPTED_FILE"
output_json = "$EXTRACT_DIR/db.json"

try:
    with open(decrypted_file, 'rb') as f:
        data = f.read()

    # Try to find JSON in the binary data
    text = data.decode('utf-8', errors='ignore')

    # Look for _id patterns (MongoDB ObjectIDs)
    id_pattern = r'[^a-f0-9]([a-f0-9]{24})[^a-f0-9]'
    ids = re.findall(id_pattern, text)

    if ids:
        print(f"Found {len(ids)} potential resource IDs")
        # Try to build a structure from found IDs
        # This is a fallback - we'll need to match them manually
        result = {'extracted_ids': ids[:100]}  # Limit to first 100
        with open(output_json, 'w') as f:
            json.dump(result, f, indent=2)
        print(f"Saved {len(ids)} IDs to {output_json}")
    else:
        print("No IDs found in decrypted file")
        print("The backup format may require UniFi OS restore process")
except Exception as e:
    print(f"Error: {e}")
    import traceback
    traceback.print_exc()
PYTHON_SCRIPT

    if [ -f "$EXTRACT_DIR/db.json" ]; then
        echo "✅ Extracted IDs to: $EXTRACT_DIR/db.json"
    fi
else
    unzip -q "$ZIP_FILE" -d "$EXTRACT_DIR" || {
        echo "⚠️  Standard unzip failed, trying with -j (junk paths)..."
        unzip -q -j "$ZIP_FILE" -d "$EXTRACT_DIR" || {
            echo "❌ Failed to extract zip file"
            echo "The backup file may be corrupted or in a different format"
        }
    }
fi

echo "✅ Backup decrypted and extracted!"
echo ""
echo "Extracted files:"
ls -lh "$EXTRACT_DIR" | head -10
echo ""

# Check for db.gz file
if [ -f "$EXTRACT_DIR/db.gz" ]; then
    echo "✅ Found db.gz (BSON database)"
    echo ""
    echo "Step 4: Converting BSON to JSON..."

    # Check if bsondump is available
    if command -v bsondump &> /dev/null; then
        JSON_FILE="$WORK_DIR/db.json"
        gunzip -c "$EXTRACT_DIR/db.gz" | bsondump > "$JSON_FILE"
        echo "✅ Database converted to JSON: $JSON_FILE"
        echo ""
        echo "You can now use this JSON file to extract resource IDs"
        echo "Run: python3 $SCRIPT_DIR/extract-ids-from-json.py $JSON_FILE"
    else
        echo "⚠️  bsondump not found"
        echo "Install mongo-tools to convert BSON to JSON:"
        echo "  macOS: brew install mongodb/brew/mongodb-database-tools"
        echo "  Linux: apt install mongo-tools"
        echo ""
        echo "Or manually extract:"
        echo "  gunzip -c $EXTRACT_DIR/db.gz | bsondump > db.json"
    fi
else
    echo "⚠️  db.gz not found in extracted files"
    echo "Looking for JSON files instead..."

    # Look for JSON files
    JSON_FILES=$(find "$EXTRACT_DIR" -name "*.json" -type f)
    if [ -n "$JSON_FILES" ]; then
        echo "Found JSON files:"
        echo "$JSON_FILES"
        echo ""
        echo "You can use these JSON files to extract resource IDs"
    else
        echo "No JSON files found either"
        echo "The backup may be in a different format"
    fi
fi

echo ""
echo "Extraction complete! Files are in: $WORK_DIR"
echo "Clean up when done: rm -rf $WORK_DIR"

