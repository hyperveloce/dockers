#!/bin/bash
#chmod +x docker-backup.sh

# Read the passphrase from Docker secret and export it
export BORG_PASSPHRASE=$(cat /run/secrets/borg-passphrase)

# Define backup repository
REPO="/home/kanasu/kserver/docker.backup"

# Define directories and volumes to backup
DIRECTORIES=(
    "/srv/data/nextcloud_data"
    "/srv/data/nextcloud_config"
    "/srv/data/nextcloud_themes"
    "/srv/data/pihole_etc-pihole"
    "/srv/data/pihole_etc-dnsmasq.d"
    "/srv/data/homarr_config"
)

VOLUMES=(
    "/srv/volume/nextclouddb_data"
)

# Define pruning policy
KEEP_DAILY=7
KEEP_WEEKLY=4
KEEP_MONTHLY=6

# Backup Directories
for dir in "${DIRECTORIES[@]}"; do
    backup_name=$(basename "$dir")-$(date +%Y-%m-%d)
    borg create --stats "$REPO::$backup_name" "$dir"
done

# Backup Docker Volumes
for vol in "${VOLUMES[@]}"; do
    backup_name=$(basename "$vol")-$(date +%Y-%m-%d)
    borg create --stats "$REPO::$backup_name" "$vol"
done

# Prune old backups according to the policy
echo "Pruning old backups..."
borg prune --list --keep-daily=$KEEP_DAILY --keep-weekly=$KEEP_WEEKLY --keep-monthly=$KEEP_MONTHLY "$REPO"

echo "Backup and pruning complete."
