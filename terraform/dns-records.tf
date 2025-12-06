# UniFi Static DNS Records
# These records were successfully imported from the UniFi controller
#
# DNS Suffix Legend (VLAN-based naming convention):
# =================================================
# VLAN 1  (Default):     {hostname}.specterrealm.com
# VLAN 5  (Family):      {hostname}.specterrealm.com
# VLAN 10 (Production):  {hostname}-prod.specterrealm.com
# VLAN 12 (Cluster):     {hostname}-cl.specterrealm.com
# VLAN 15 (Mgmt-Admin):  {hostname}-mgmt.specterrealm.com
# VLAN 20 (Lab):         {hostname}-lab.specterrealm.com
# VLAN 30 (Storage):     {hostname}-storage.specterrealm.com
# VLAN 40 (DMZ):         {hostname}-dmz.specterrealm.com
# VLAN 99 (Parking):     {hostname}-parking.specterrealm.com
# VLAN 101 (Guest):      {hostname}-guest.specterrealm.com
# VLAN 200 (IoT):        {hostname}-iot.specterrealm.com
#
# Examples:
#   - gpu01.specterrealm.com          → 172.16.15.x (Mgmt, but no suffix for primary interface)
#   - gpu01-cl.specterrealm.com       → 172.16.12.x (Cluster network)
#   - nas01-storage.specterrealm.com  → 172.16.30.x (Storage network)
#   - nas01-mgmt.specterrealm.com     → 172.16.15.x (Management network)
#   - unifi-mgmt.specterrealm.com     → 172.16.15.1 (UniFi UDM Pro management)
#
# Planned (not yet built):
#   - jumpbox-mgmt.specterrealm.com   → 172.16.15.50 (Jumpbox - planned)
#

# Unifi UDM Pro
resource "unifi_dns_record" "unifi_mgmt" {
  name        = "unifi-mgmt.specterrealm.com"
  record_type = "A"
  value       = "172.16.15.1"
  port        = 0
}

# Storage Network
## Synology DSM NAS01
resource "unifi_dns_record" "synology_ds1621" {
  name        = "nas01.specterrealm.com"
  record_type = "A"
  value       = "172.16.5.5"
  port        = 0
}

resource "unifi_dns_record" "nas01_mgmt" {
  name        = "nas01-mgmt.specterrealm.com"
  record_type = "A"
  value       = "172.16.15.5"
  port        = 0
}

resource "unifi_dns_record" "synology_ds1621_storage" {
  name        = "nas01-storage.specterrealm.com"
  record_type = "A"
  value       = "172.16.30.5"
  port        = 0
}

## UniFi UNAS Pro NAS02
resource "unifi_dns_record" "unas_pro_nas02" {
  name        = "nas02-storage.specterrealm.com"
  record_type = "A"
  value       = "172.16.30.4"
  port        = 0
}

# Proxmox Cluster
## GPU01
resource "unifi_dns_record" "gpu01" {
  name        = "gpu01.specterrealm.com"
  record_type = "A"
  value       = "172.16.15.10"
  port        = 0
}

resource "unifi_dns_record" "gpu01_cl" {
  name        = "gpu01-cl.specterrealm.com"
  record_type = "A"
  value       = "172.16.12.10"
  port        = 0
}

resource "unifi_dns_record" "gpu01_storage" {
  name        = "gpu01-storage.specterrealm.com"
  record_type = "A"
  value       = "172.16.30.10"
  port        = 0
}

## NUC01
resource "unifi_dns_record" "nuc01" {
  name        = "nuc01.specterrealm.com"
  record_type = "A"
  value       = "172.16.15.11"
  port        = 0
}

resource "unifi_dns_record" "nuc01_cl" {
  name        = "nuc01-cl.specterrealm.com"
  record_type = "A"
  value       = "172.16.12.11"
  port        = 0
}

resource "unifi_dns_record" "nuc01_storage" {
  name        = "nuc01-storage.specterrealm.com"
  record_type = "A"
  value       = "172.16.30.11"
  port        = 0
}

## NUC02
resource "unifi_dns_record" "nuc02" {
  name        = "nuc02.specterrealm.com"
  record_type = "A"
  value       = "172.16.15.12"
  port        = 0
}

resource "unifi_dns_record" "nuc02_cl" {
  name        = "nuc02-cl.specterrealm.com"
  record_type = "A"
  value       = "172.16.12.12"
  port        = 0
}

resource "unifi_dns_record" "nuc02_storage" {
  name        = "nuc02-storage.specterrealm.com"
  record_type = "A"
  value       = "172.16.30.12"
  port        = 0
}

# Docker Swarm Cluster
## swarm-pi5-01
resource "unifi_dns_record" "swarm_pi5_01" {
  name        = "swarm-pi5-01.specterrealm.com"
  record_type = "A"
  value       = "172.16.15.13"
  port        = 0
}

resource "unifi_dns_record" "swarm_pi5_01_storage" {
  name        = "swarm-pi5-01-storage.specterrealm.com"
  record_type = "A"
  value       = "172.16.30.13"
  port        = 0
}

## swarm-pi5-02
resource "unifi_dns_record" "swarm_pi5_02" {
  name        = "swarm-pi5-02.specterrealm.com"
  record_type = "A"
  value       = "172.16.15.14"
  port        = 0
}

resource "unifi_dns_record" "swarm_pi5_02_storage" {
  name        = "swarm-pi5-02-storage.specterrealm.com"
  record_type = "A"
  value       = "172.16.30.14"
  port        = 0
}

## swarm-pi5-03
resource "unifi_dns_record" "swarm_pi5_03" {
  name        = "swarm-pi5-03.specterrealm.com"
  record_type = "A"
  value       = "172.16.15.15"
  port        = 0
}

resource "unifi_dns_record" "swarm_pi5_03_storage" {
  name        = "swarm-pi5-03-storage.specterrealm.com"
  record_type = "A"
  value       = "172.16.30.15"
  port        = 0
}

## swarm-pi5-04
resource "unifi_dns_record" "swarm_pi5_04" {
  name        = "swarm-pi5-04.specterrealm.com"
  record_type = "A"
  value       = "172.16.15.16"
  port        = 0
}

resource "unifi_dns_record" "swarm_pi5_04_storage" {
  name        = "swarm-pi5-04-storage.specterrealm.com"
  record_type = "A"
  value       = "172.16.30.16"
  port        = 0
}
