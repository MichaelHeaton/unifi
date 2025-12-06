#!/usr/bin/env python3
"""
Extract Resource IDs from Decrypted UniFi Backup JSON
Parses the db.json file from a decrypted UniFi backup
"""

import json
import sys
import os
from pathlib import Path

def extract_ids_from_json(json_file):
    """Extract resource IDs from UniFi backup JSON"""

    print(f"📦 Parsing JSON file: {json_file}")
    print("")

    with open(json_file, 'r') as f:
        data = json.load(f)

    # UniFi database structure - look for collections
    # The database is typically structured as collections
    if isinstance(data, dict):
        # Look for common UniFi collection names
        collections = {
            'network': ['networkconf', 'networks', 'network'],
            'wlan': ['wlanconf', 'wlans', 'wlan'],
            'firewall_group': ['firewallgroups', 'firewallgroup'],
            'dns_record': ['dnsrecords', 'dnsrecord', 'dns_records'],
            'static_route': ['staticroutes', 'static_route', 'routing'],
            'user_group': ['usergroups', 'usergroup'],
            'firewall_rule': ['firewallrules', 'firewallrule']
        }

        output_file = sys.argv[2] if len(sys.argv) > 2 else 'import-ids.txt'

        with open(output_file, 'w') as out:
            out.write("# Terraform Import IDs Extracted from UniFi Backup JSON\n")
            out.write(f"# JSON file: {json_file}\n")
            out.write(f"# Generated: {__import__('datetime').datetime.now()}\n")
            out.write("\n")

            for terraform_type, collection_names in collections.items():
                out.write(f"## {terraform_type}\n")
                found_any = False

                for collection_name in collection_names:
                    # Look in various possible locations
                    if collection_name in data:
                        items = data[collection_name]
                        if not isinstance(items, list):
                            items = [items]

                        for item in items:
                            if isinstance(item, dict):
                                name = item.get('name', item.get('hostname', item.get('_id', 'unknown')))
                                _id = item.get('_id', '')
                                if _id and len(_id) == 24:  # MongoDB ObjectID length
                                    clean_name = name.lower().replace(' ', '_').replace('-', '_').replace('.', '_')
                                    out.write(f"# {name}\n")
                                    out.write(f"unifi_{terraform_type}.{clean_name} = \"{_id}\"\n")
                                    found_any = True

                if not found_any:
                    out.write("# No resources found\n")
                out.write("\n")

        print(f"✅ Extraction complete! IDs saved to: {output_file}")
        return output_file
    else:
        print("❌ Unexpected JSON structure")
        print(f"Top level type: {type(data)}")
        if isinstance(data, list) and len(data) > 0:
            print(f"List with {len(data)} items")
            if isinstance(data[0], dict):
                print(f"First item keys: {list(data[0].keys())[:10]}")
        return None

def main():
    json_file = sys.argv[1] if len(sys.argv) > 1 else None

    if not json_file:
        # Look for db.json in common locations
        script_dir = Path(__file__).parent
        possible_locations = [
            script_dir.parent / 'tmp-backup-extract' / 'db.json',
            script_dir.parent.parent / 'backup' / 'db.json',
            Path.cwd() / 'db.json'
        ]

        for loc in possible_locations:
            if loc.exists():
                json_file = str(loc)
                break

        if not json_file:
            print("❌ No JSON file specified and none found in common locations")
            print("Usage: python3 extract-ids-from-json.py <json-file> [output-file]")
            sys.exit(1)

    if not os.path.exists(json_file):
        print(f"❌ JSON file not found: {json_file}")
        sys.exit(1)

    output_file = extract_ids_from_json(json_file)

    if output_file:
        print("")
        print("📋 Next steps:")
        print("1. Review the extracted IDs in the output file")
        print("2. Match resource names with your Terraform configuration")
        print("3. Use the IDs to import: terraform import <resource_type>.<name> <id>")

if __name__ == '__main__':
    main()

