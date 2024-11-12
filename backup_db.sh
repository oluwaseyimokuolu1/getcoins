#!/bin/bash

# Description: Script to create a backup of the database used by the crypto-price-checker application.
# Usage:
# ./backup_db.sh backup             - Create a backup of the database
# ./backup_db.sh restore <filename>  - Restore the database from a backup file
# ./backup_db.sh status             - Check the status of the backup process

NAMESPACE="default"
DEPLOYMENT_NAME="crypto-price-checker"
DB_POD_LABEL="app=crypto-price-checker-db" # Update with your DB pod label
BACKUP_DIR="/backups"  # Directory in the container where backups will be stored

# Function to create a backup
backup_db() {
  POD=$(kubectl get pods -n $NAMESPACE -l $DB_POD_LABEL -o jsonpath='{.items[0].metadata.name}')
  
  if [ -z "$POD" ]; then
    echo "Database pod not found. Please check the deployment."
    exit 1
  fi

  echo "Creating backup from pod: $POD"
  
  # Example of PostgreSQL backup command (adjust for your DB type)
  kubectl exec -n $NAMESPACE $POD -- pg_dump -U postgres -F c -b -v -f /tmp/db_backup.dump
  
  # Copy the backup from the pod to the local backup directory
  kubectl cp $NAMESPACE/$POD:/tmp/db_backup.dump $BACKUP_DIR/db_backup_$(date +%Y%m%d%H%M%S).dump
  
  echo "Backup completed and saved to $BACKUP_DIR"
}

# Function to restore the database from a backup file
restore_db() {
  BACKUP_FILE=$1
  
  if [ -z "$BACKUP_FILE" ]; then
    echo "Please specify the backup file to restore. Usage: ./backup_db.sh restore <filename>"
    exit 1
  fi
  
  POD=$(kubectl get pods -n $NAMESPACE -l $DB_POD_LABEL -o jsonpath='{.items[0].metadata.name}')
  
  if [ -z "$POD" ]; then
    echo "Database pod not found. Please check the deployment."
    exit 1
  fi

  echo "Restoring database from backup file: $BACKUP_FILE"
  
  # Copy the backup file to the pod
  kubectl cp $BACKUP_DIR/$BACKUP_FILE $NAMESPACE/$POD:/tmp/db_backup.dump
  
  # Example of PostgreSQL restore command (adjust for your DB type)
  kubectl exec -n $NAMESPACE $POD -- pg_restore -U postgres -d mydb -v /tmp/db_backup.dump
  
  echo "Restore completed successfully."
}

# Function to check the status of the backup
backup_status() {
  echo "Backup directory: $BACKUP_DIR"
  echo "List of backup files:"
  ls -lh $BACKUP_DIR
}

# Main logic to handle different options
if [ "$1" == "backup" ]; then
  backup_db
elif [ "$1" == "restore" ]; then
  restore_db "$2"
elif [ "$1" == "status" ]; then
  backup_status
else
  echo "Invalid argument. Usage: ./backup_db.sh backup, ./backup_db.sh restore <filename>, or ./backup_db.sh status"
  exit 1
fi