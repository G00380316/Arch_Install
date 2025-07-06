#!/bin/bash

# Directory to store the backup
BACKUP_DIR="$HOME/.config/backups"
BACKUP_FILE="$BACKUP_DIR/mousepad-dconf.conf"

# Ensure backup directory exists
mkdir -p "$BACKUP_DIR"

usage() {
  echo "Usage: $0 [backup|restore]"
  exit 1
}

case "$1" in
  backup)
    echo "Backing up Mousepad settings to $BACKUP_FILE..."
    dconf dump /org/xfce/mousepad/ > "$BACKUP_FILE"
    echo "Backup complete."
    ;;
  restore)
    if [ -f "$BACKUP_FILE" ]; then
      echo "Restoring Mousepad settings from $BACKUP_FILE..."
      dconf load /org/xfce/mousepad/ < "$BACKUP_FILE"
      echo "Restore complete."
    else
      echo "No backup found at $BACKUP_FILE."
      exit 1
    fi
    ;;
  *)
    usage
    ;;
esac
