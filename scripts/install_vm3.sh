#!/bin/bash

. /vagrant_config/config.sh

echo "--- Configuring repo with repo token ${EDB_SUBSCRIPTION_TOKEN} ---"
curl -1sLf "https://downloads.enterprisedb.com/${EDB_SUBSCRIPTION_TOKEN}/enterprise/setup.rpm.sh" | sudo -E bash

echo "--- Running updates ---"
dnf update && dnf upgrade -y
sudo systemctl stop firewalld.service
sudo systemctl disable firewalld.service

echo "--- Installing barman---"
sudo dnf -y install barman barman-cli rsync postgresql17-contrib

echo "--- Installing barman service---"
sudo tee /etc/systemd/system/barman.service <<EOF
[Unit]
Description=Barman backup service
After=network.target postgresql.service

[Service]
Type=simple
User=barman
Group=barman
ExecStart=/bin/barman receive-wal --wait
Restart=always

[Install]
WantedBy=multi-user.target
EOF

echo "--- Create SSH keys for user barman ---"
sudo -u barman ssh-keygen -t rsa
sudo -u barman ssh-copy-id -i .ssh/id_rsa postgres@pg1 

# Create Barman directories
sudo mkdir -p /var/lib/barman
sudo chown barman:barman /var/lib/barman
sudo tee /var/lib/barman/.pgpass > /dev/null <<EOL
pg1:5432:postgres:barman:barman
pg2:5432:postgres:barman:barman
EOL
sudo chmod 600 /var/lib/barman/.pgpass
sudo chown barman:barman /var/lib/barman/.pgpass

# Configure Barman for streaming and WAL archiving
echo "Configuring Barman..."
sudo tee /etc/barman.conf > /dev/null <<EOL
[barman]
barman_user = barman
barman_home = /var/lib/barman
configuration_files_directory = /etc/barman.d
log_file = /var/log/barman/barman.log
compression = gzip
EOL

sudo tee /etc/barman.conf.d/pg1.conf > /dev/null <<EOL
[pg1]
description = "Primary PostgreSQL Server"
conninfo = host=pg1 user=barman password=barman dbname=postgres
backup_method = postgres
streaming_conninfo = host=pg1 user=barman password=barman
streaming_archiver = on
slot_name = barman
EOL

# Restart Barman
sudo systemctl restart barman
sudo systemctl status barman

# Perform initial check
barman check pg1

echo "Barman installation with WAL streaming configuration completed!"
