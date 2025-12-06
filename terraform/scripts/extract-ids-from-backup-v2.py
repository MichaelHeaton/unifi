#!/usr/bin/env python3
"""
Extract Resource IDs from UniFi Backup File
Tries multiple methods to parse the backup file and extract resource IDs
"""

import json
import sys
import os
import re
import gzip
import tarfile
from pathlib import Path

def try_extract_json_from_backup(backup_path):
    """Try multiple methods to extract JSON from UniFi backup"""

    methods = []

    # Method 1: Try as plain JSON
    try:
        with open(backup_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
            methods.append(('Plain JSON', data))
    except:
        pass

    # Method 2: Try as gzip
    try:
        with gzip.open(backup_path, 'rt') as f:
            data = json.load(f)
            methods.append(('Gzip JSON', data))
    except:
        pass

    # Method 3: Try to find JSON in binary file
    try:
        with open(backup_path, 'rb') as f:
            raw_data = f.read()

        # Look for JSON start markers
        for i in range(len(raw_data) - 1000):
            try:
                chunk = raw_data[i:i+10000]  # Check 10KB chunks
                decoded = chunk.decode('utf-8', errors='ignore')

                # Look for JSON-like structures
                if decoded.strip().startswith('{') or decoded.strip().startswith('['):
                    # Try to extract complete JSON
                    json_str = decoded
                    # Try to find the end
                    brace_count = 0
                    bracket_count = 0
                    in_string = False
                    escape_next = False

                    end_pos = 0
                    for j, char in enumerate(json_str):
                        if escape_next:
                            escape_next = False
                            continue
                        if char == '\\':
                            escape_next = True
                            continue
                        if char == '"' and not escape_next:
                            in_string = not in_string
                            continue
                        if in_string:
                            continue
                        if char == '{':
                            brace_count += 1
                        elif char == '}':
                            brace_count -= 1
                        elif char == '[':
                            bracket_count += 1
                        elif char == ']':
                            bracket_count -= 1

                        if brace_count == 0 and bracket_count == 0 and (char == '}' or char == ']'):
                            end_pos = j + 1
                            break

                    if end_pos > 0:
                        try:
                            json_data = json_str[:end_pos]
                            data = json.loads(json_data)
                            methods.append((f'Binary JSON (offset {i})', data))
                        except:
                            pass
            except:
                pass
    except Exception as e:
        pass

    # Method 4: Try as tar.gz (support file)
    try:
        with tarfile.open(backup_path, 'r:gz') as tar:
            # Look for JSON files inside
            for member in tar.getmembers():
                if member.name.endswith('.json'):
                    f = tar.extractfile(member)
                    if f:
                        data = json.load(f)
                        methods.append((f'Tar.gz JSON ({member.name})', data))
    except:
        pass

    # Method 5: Extract IDs using regex from raw text
    try:
        with open(backup_path, 'rb') as f:
            raw_data = f.read()
        text = raw_data.decode('utf-8', errors='ignore')

        # Look for _id patterns
        id_pattern = r'"_id"\s*:\s*"([a-f0-9]{24})"'
        name_pattern = r'"name"\s*:\s*"([^"]+)"'

        ids = re.findall(id_pattern, text)
        names = re.findall(name_pattern, text)

        if ids:
            # Try to build a structure
            data = {'extracted_ids': ids, 'extracted_names': names}
            methods.append(('Regex extraction', data))
    except Exception as e:
        pass

    return methods

def extract_resource_ids(data, resource_type, name_key='name', id_key='_id'):
    """Extract resource IDs from parsed data"""
    results = []

    if isinstance(data, dict):
        # Look for common UniFi backup structures
        possible_keys = [
            'networks', 'networkconf', 'network',
            'wlans', 'wlanconf', 'wlan',
            'firewallgroups', 'firewallgroup',
            'dnsrecords', 'dnsrecord', 'dns_records',
            'staticroutes', 'static_route', 'routing',
            'usergroups', 'usergroup',
            'firewallrules', 'firewallrule'
        ]

        for key in possible_keys:
            if key in data:
                items = data[key] if isinstance(data[key], list) else [data[key]]
                for item in items:
                    if isinstance(item, dict):
                        name = item.get(name_key, item.get('hostname', 'unknown'))
                        _id = item.get(id_key, '')
                        if _id:
                            results.append((name, _id))

        # Also check top-level if it's a list of items
        if 'extracted_ids' in data:
            # This is from regex extraction
            for i, _id in enumerate(data.get('extracted_ids', [])):
                name = data.get('extracted_names', ['unknown'] * len(data['extracted_ids']))[i] if i < len(data.get('extracted_names', [])) else f'resource_{i}'
                results.append((name, _id))

    elif isinstance(data, list):
        for item in data:
            if isinstance(item, dict):
                name = item.get(name_key, item.get('hostname', 'unknown'))
                _id = item.get(id_key, '')
                if _id:
                    results.append((name, _id))

    return results

def main():
    backup_file = sys.argv[1] if len(sys.argv) > 1 else None

    if not backup_file:
        # Look for backup file in backup directory
        script_dir = Path(__file__).parent
        backup_dir = script_dir.parent.parent / 'backup'
        backup_files = list(backup_dir.glob('*.unifi'))
        if backup_files:
            backup_file = str(backup_files[0])
        else:
            print("❌ No backup file found")
            print("Usage: python3 extract-ids-from-backup-v2.py <backup-file>")
            sys.exit(1)

    if not os.path.exists(backup_file):
        print(f"❌ Backup file not found: {backup_file}")
        sys.exit(1)

    print(f"📦 Parsing backup file: {backup_file}")
    print("")

    # Try to extract JSON
    methods = try_extract_json_from_backup(backup_file)

    if not methods:
        print("❌ Could not extract JSON from backup file")
        print("The backup file may be encrypted or in an unsupported format.")
        print("")
        print("Alternative: Use the UniFi web UI or API to get resource IDs")
        sys.exit(1)

    print(f"✅ Found {len(methods)} extraction method(s)")
    print("")

    # Use the first successful method
    method_name, data = methods[0]
    print(f"Using method: {method_name}")
    print("")

    # Extract resource IDs
    resource_types = {
        'network': ('networks', 'networkconf', 'network'),
        'wlan': ('wlans', 'wlanconf', 'wlan'),
        'firewall_group': ('firewallgroups', 'firewallgroup'),
        'dns_record': ('dnsrecords', 'dnsrecord', 'dns_records'),
        'static_route': ('staticroutes', 'static_route', 'routing'),
        'user_group': ('usergroups', 'usergroup'),
        'firewall_rule': ('firewallrules', 'firewallrule')
    }

    output_file = sys.argv[2] if len(sys.argv) > 2 else 'import-ids.txt'

    with open(output_file, 'w') as f:
        f.write("# Terraform Import IDs Extracted from UniFi Backup\n")
        f.write(f"# Backup file: {backup_file}\n")
        f.write(f"# Extraction method: {method_name}\n")
        f.write(f"# Generated: {__import__('datetime').datetime.now()}\n")
        f.write("\n")

        for terraform_type, backup_keys in resource_types.items():
            f.write(f"## {terraform_type}\n")

            found_any = False
            for key in backup_keys:
                if key in data:
                    items = data[key] if isinstance(data[key], list) else [data[key]]
                    for item in items:
                        if isinstance(item, dict):
                            name = item.get('name', item.get('hostname', 'unknown'))
                            _id = item.get('_id', '')
                            if _id:
                                clean_name = name.lower().replace(' ', '_').replace('-', '_').replace('.', '_')
                                f.write(f"# {name}\n")
                                f.write(f"unifi_{terraform_type}.{clean_name} = \"{_id}\"\n")
                                found_any = True

            if not found_any:
                f.write("# No resources found\n")
            f.write("\n")

    print(f"✅ Extraction complete! IDs saved to: {output_file}")
    print("")
    print("📋 Next steps:")
    print("1. Review the extracted IDs in the output file")
    print("2. Match resource names with your Terraform configuration")
    print("3. Use the IDs to import: terraform import <resource_type>.<name> <id>")

if __name__ == '__main__':
    main()

