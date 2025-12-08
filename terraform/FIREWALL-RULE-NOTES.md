# Firewall Rule: Allow Management to Production

## Overview

This firewall rule allows access from VLAN 15 (Management) to VLAN 10 (Production), enabling your desktop on the management network to access the Plex VM directly.

**Important**: VLAN 5 (Family) does NOT have direct access to VLAN 10. Family devices must access services through Traefik reverse proxy for proper security and routing.

## Configuration

### Firewall Rule

- **Name**: "Allow Mgmt to Production"
- **Action**: Accept
- **Ruleset**: LAN_IN (applies to traffic coming into the network)
- **Protocol**: All (TCP, UDP, ICMP, etc.)
- **Source**: VLAN 15 (172.16.15.0/24) - Management network only
- **Destination**: VLAN 10 (172.16.10.0/24) - Production network
- **Rule Index**: 20000 (5-digit range for newer UniFi Network Application versions)

## Benefits

✅ **No Static IPs Required**: Uses network-based rules (CIDR ranges), so your desktop can use DHCP on VLAN 15

✅ **Direct Management Access**: Desktop on VLAN 15 can directly access production services:

- Plex web UI (port 32400)
- SSH (port 22)
- Any other services on VLAN 10

✅ **Security**: VLAN 5 (Family) is properly isolated - must go through Traefik reverse proxy, not direct access

## Deployment

```bash
cd /Users/michaelheaton/Projects/HomeLab/unifi/terraform
terraform plan   # Review changes
terraform apply  # Apply firewall rule
```

## Verification

After applying, test access from your desktop:

```bash
# Test Plex web UI
curl -I http://172.16.10.20:32400

# Test SSH (if configured)
ssh packer@172.16.10.20

# Test DNS resolution
nslookup plex-vm-01.specterrealm.com
```

## Notes

- The rule allows **all traffic** from VLAN 15 to VLAN 10. If you want to restrict to specific ports (e.g., only Plex port 32400), we can create a more specific rule.
- **VLAN 5 (Family) does NOT have direct access** - this is intentional for security. Family devices should access services via Traefik reverse proxy.
- Rule index 20000 ensures it runs after default UniFi rules (5-digit range for newer UniFi versions)
- Logging is disabled by default (set `logging = true` if you want to monitor these connections)
