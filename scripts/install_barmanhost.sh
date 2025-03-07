#!/bin/bash

. /vagrant_config/config.sh

echo "--- Configuring repo with repo token ${EDB_SUBSCRIPTION_TOKEN} ---"
curl -1sLf "https://downloads.enterprisedb.com/${EDB_SUBSCRIPTION_TOKEN}/enterprise/setup.rpm.sh" | sudo -E bash

echo "--- Running updates ---"
dnf update && dnf upgrade -y
sudo systemctl stop firewalld.service
sudo systemctl disable firewalld.service
sudo setenforce 0
sudo sed -i 's/^%wheel  ALL=(ALL)       ALL/%wheel  ALL=(ALL)       NOPASSWD:ALL/' /etc/sudoers

echo "--- Installing barman---"
sudo dnf -y install barman barman-cli postgresql17-contrib rsync

# Create Barman directories
sudo usermod -aG wheel barman
sudo mkdir -p /var/lib/barman
sudo chown barman:barman /var/lib/barman
sudo tee /var/lib/barman/.pgpass > /dev/null <<EOL
pghost:5432:*:barman:barman
pghost:5432:replication:streaming_barman:barman
EOL
sudo chmod 600 /var/lib/barman/.pgpass
sudo chown barman:barman /var/lib/barman/.pgpass
sudo tee /var/lib/barman/.bash_profile >/dev/null <<EOL
# ~/.bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User-specific environment and startup programs

# Set PATH to include custom bin directory
export PATH="/usr/pgsql-17/bin/:$HOME/bin:$PATH"

# Alias definitions
alias ll='ls -lah'
alias grep='grep --color=auto'

# Enable color support for ls
if [ -x /usr/bin/dircolors ]; then
    eval "$(dircolors -b)"
fi
EOL

sudo chown barman:barman /var/lib/barman/.bash_profile

# Configure Barman for streaming and WAL archiving
echo "Configuring Barman..."
sudo tee /etc/barman.conf > /dev/null <<EOL
[barman]
barman_user = barman
barman_home = /var/lib/barman
path_prefix = /usr/pgsql-17/bin
configuration_files_directory = /etc/barman.d
log_file = /var/log/barman/barman.log
compression = gzip
EOL

sudo touch /etc/barman.d/pghost.conf 
sudo tee /etc/barman.d/pghost.conf > /dev/null <<EOL
[pghost]
description = "Primary PostgreSQL Server"
conninfo = host=pghost user=barman password=barman dbname=demo_db
streaming_conninfo = host=pghost user=streaming_barman password=barman
backup_method = postgres
streaming_archiver = on
slot_name = barman
create_slot = auto
EOL
