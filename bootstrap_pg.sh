#!/bin/bash

set -e

# Install PostgreSQL 17
echo "Installing PostgreSQL 17..."
sudo apt update
sudo apt install -y wget gnupg2
wget -qO - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
echo "deb http://apt.postgresql.org/pub/repos/apt jammy-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list
sudo apt update
sudo apt install -y postgresql-17 postgresql-contrib

# Enable and start PostgreSQL
sudo systemctl enable postgresql
sudo systemctl start postgresql

# Set PostgreSQL password for easier authentication
sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'postgres';"

# Create a replication user for Barman
echo "Creating replication user for Barman..."
sudo -u postgres psql -c "CREATE ROLE barman WITH REPLICATION LOGIN PASSWORD 'barman';"

# Configure PostgreSQL for remote access
echo "Configuring PostgreSQL..."
sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /etc/postgresql/17/main/postgresql.conf

# Enable WAL archiving and streaming replication
cat <<EOF | sudo tee -a /etc/postgresql/17/main/postgresql.conf
wal_level = replica
archive_mode = on
archive_command = 'rsync -a %p barman@barman-server:/var/lib/barman/primary-db/incoming/%f'
max_wal_senders = 3
wal_keep_size = 256MB
hot_standby = on
EOF

# Allow Barman to connect for replication and streaming
cat <<EOF | sudo tee -a /etc/postgresql/17/main/pg_hba.conf
host replication barman barman-server md5
host all all 0.0.0.0/0 md5
EOF

# Restart PostgreSQL to apply changes
sudo systemctl restart postgresql

echo "PostgreSQL installation and WAL streaming configuration completed!"
