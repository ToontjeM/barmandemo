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

echo "--- Installing Postgres 17 ---"
sudo dnf -y install postgresql17-server postgresql17-contrib
sudo /usr/pgsql-17/bin/postgresql-17-setup initdb

# Enable and start PostgreSQL
sudo usermod -aG wheel postgres
sudo systemctl enable postgresql-17
sudo systemctl start postgresql-17

# Set PostgreSQL password for easier authentication
sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'postgres';"

# Create a replication user for Barman
echo "Creating replication user for Barman..."
sudo su - postgres -c "createuser --superuser --replication barman"
sudo su - postgres -c "createuser --replication streaming_barman"
sudo -u postgres psql -c "ALTER ROLE barman WITH REPLICATION LOGIN PASSWORD 'barman';"
sudo -u postgres psql -c "ALTER ROLE streaming_barman WITH REPLICATION LOGIN PASSWORD 'barman';"

# Create demo database
sudo -u postgres psql -c "CREATE DATABASE demo_db;"

# Configure PostgreSQL for remote access
echo "Configuring PostgreSQL..."
sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /var/lib/pgsql/17/data/postgresql.conf

# Allow Barman to connect for replication and streaming
cat <<EOF | sudo tee -a /var/lib/pgsql/17/data/pg_hba.conf
host replication streaming_barman all md5
host all all 0.0.0.0/0 md5
EOF

# Restart PostgreSQL to apply changes
sudo systemctl restart postgresql-17

echo "PostgreSQL installation and WAL streaming configuration completed!"
