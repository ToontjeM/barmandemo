#!/bin/bash

. /vagrant_config/config.sh

echo "--- Configuring repo with repo token ${EDB_SUBSCRIPTION_TOKEN} ---"
curl -1sLf "https://downloads.enterprisedb.com/${EDB_SUBSCRIPTION_TOKEN}/enterprise/setup.rpm.sh" | sudo -E bash

echo "--- Running updates ---"
dnf update && dnf upgrade -y
sudo systemctl stop firewalld.service
sudo systemctl disable firewalld.service

echo "--- Installing Postgres 17 ---"
sudo dnf -y install postgresql17-server postgresql17-contrib
sudo /usr/pgsql-17/bin/postgresql-17-setup initdb

# Enable and start PostgreSQL
sudo systemctl enable postgresql-17
sudo systemctl start postgresql-17

echo "--- Create SSH keys for user postgres ---"
sudo -u postgres ssh-keygen -t rsa

# Set PostgreSQL password for easier authentication
sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'postgres';"

# Create a replication user for Barman
echo "Creating replication user for Barman..."
sudo -u postgres psql -c "CREATE ROLE barman WITH REPLICATION LOGIN PASSWORD 'barman';"

# Configure PostgreSQL for remote access
echo "Configuring PostgreSQL..."
sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /var/lib/pgsql/17/data/postgresql.conf

# Enable WAL archiving and streaming replication
cat <<EOF | sudo tee -a /var/lib/pgsql/17/data/postgresql.conf
wal_level = replica
archive_mode = on
archive_command = 'rsync -a %p barman@barman-server:/var/lib/barman/primary-db/incoming/%f'
max_wal_senders = 3
wal_keep_size = 256MB
hot_standby = on
EOF

# Allow Barman to connect for replication and streaming
cat <<EOF | sudo tee -a /var/lib/pgsql/17/data/pg_hba.conf
host replication barman barman-server md5
host all all 0.0.0.0/0 md5
EOF

# Restart PostgreSQL to apply changes
sudo systemctl restart postgresql-17

echo "PostgreSQL installation and WAL streaming configuration completed!"
