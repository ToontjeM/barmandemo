#!/bin/bash

set -e

# Install Barman
echo "Installing Barman..."
sudo apt update
sudo apt install -y barman postgresql-client-17 rsync

# Create Barman directories
sudo mkdir -p /var/lib/barman
sudo chown barman:barman /var/lib/barman

# Configure Barman for streaming and WAL archiving
echo "Configuring Barman..."
sudo tee /etc/barman.conf > /dev/null <<EOL
[barman]
barman_user = barman
barman_home = /var/lib/barman
log_file = /var/log/barman/barman.log
compression = gzip

[primary-db]
description = "Primary PostgreSQL Server"
conninfo = host=primary-db user=barman password=barman
backup_method = postgres
streaming_conninfo = host=primary-db user=barman password=barman
streaming_archiver = on
minimum_redundancy = 1
retention_policy = RECOVERY WINDOW OF 7 DAYS
EOL

# Restart Barman
sudo systemctl restart barman

# Perform initial check
barman check primary-db

echo "Barman installation with WAL streaming configuration completed!"
