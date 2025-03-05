#!/bin/bash

vagrant ssh pg1 -c "sudo -u postgres bash <<'EOF'
mkdir -p /var/lib/pgsql/.ssh
chmod 700 /var/lib/pgsql/.ssh
ssh-keygen -t rsa -f /var/lib/pgsql/.ssh/id_rsa -N \"\"
touch /var/lib/pgsql/.ssh/authorized_keys
touch /var/lib/pgsql/.ssh/known_hosts
chmod 600 /var/lib/pgsql/.ssh/id_rsa
chmod 644 /var/lib/pgsql/.ssh/id_rsa.pub
chmod 600 /var/lib/pgsql/.ssh/authorized_keys
chmod 600 /var/lib/pgsql/.ssh/known_hosts
EOF"

vagrant ssh pg2 -c "sudo -u postgres bash <<'EOF'
mkdir -p /var/lib/pgsql/.ssh
chmod 700 /var/lib/pgsql/.ssh
ssh-keygen -t rsa -f /var/lib/pgsql/.ssh/id_rsa -N \"\"
touch /var/lib/pgsql/.ssh/authorized_keys
touch /var/lib/pgsql/.ssh/known_hosts
chmod 600 /var/lib/pgsql/.ssh/id_rsa
chmod 644 /var/lib/pgsql/.ssh/id_rsa.pub
chmod 600 /var/lib/pgsql/.ssh/authorized_keys
chmod 600 /var/lib/pgsql/.ssh/known_hosts
EOF"

vagrant ssh backup -c "sudo -u barman bash <<'EOF'
mkdir -p /var/lib/barman/.ssh
chmod 700 /var/lib/barman/.ssh
touch /var/lib/barman/.ssh/known_hosts
ssh-keygen -t rsa -f /var/lib/barman/.ssh/id_rsa -N \"\"
touch /var/lib/barman/.ssh/authorized_keys
chmod 600 /var/lib/barman/.ssh/id_rsa
chmod 644 /var/lib/barman/.ssh/id_rsa.pub
chmod 600 /var/lib/barman/.ssh/authorized_keys
chmod 600 /var/lib/barman/.ssh/known_hosts
EOF"

echo "Copying keys from pg1 to pg2 and backup"
KEY=$(vagrant ssh pg1 -c "sudo -u postgres cat /var/lib/pgsql/.ssh/id_rsa.pub")
printf '\n%s\n' "$KEY" | vagrant ssh pg2 -c "sudo -u postgres tee -a /var/lib/pgsql/.ssh/authorized_keys > /dev/null"
printf '\n%s\n' "$KEY" | vagrant ssh backup -c "sudo -u barman tee -a /var/lib/barman/.ssh/authorized_keys > /dev/null"

echo "Copying keys from pg2 to pg1 and backup"
KEY=$(vagrant ssh pg2 -c "sudo -u postgres cat /var/lib/pgsql/.ssh/id_rsa.pub")
printf '\n%s\n' "$KEY" | vagrant ssh pg1 -c "sudo -u postgres tee -a /var/lib/pgsql/.ssh/authorized_keys > /dev/null"
printf '\n%s\n' "$KEY" | vagrant ssh backup -c "sudo -u barman tee -a /var/lib/barman/.ssh/authorized_keys > /dev/null"

echo "Copying keys from backup to pg1 and pg2"
KEY=$(vagrant ssh backup -c "sudo -u barman cat /var/lib/barman/.ssh/id_rsa.pub")
printf '\n%s\n' "$KEY" | vagrant ssh pg1 -c "sudo -u postgres tee -a /var/lib/pgsql/.ssh/authorized_keys > /dev/null"
printf '\n%s\n' "$KEY" | vagrant ssh pg2 -c "sudo -u postgres tee -a /var/lib/pgsql/.ssh/authorized_keys > /dev/null"

echo "Copying host keys"
vagrant ssh pg1 -c "sudo su - postgres -c 'ssh-keyscan -H pg2 >> /var/lib/pgsql/.ssh/known_hosts'"
vagrant ssh pg1 -c "sudo su - postgres -c 'ssh-keyscan -H backup >> /var/lib/pgsql/.ssh/known_hosts'"
vagrant ssh pg2 -c "sudo su - postgres -c 'ssh-keyscan -H pg1 >> /var/lib/pgsql/.ssh/known_hosts'"
vagrant ssh pg2 -c "sudo su - postgres -c 'ssh-keyscan -H backup >> /var/lib/pgsql/.ssh/known_hosts'"
vagrant ssh backup -c "sudo su - barman -c 'ssh-keyscan -H pg1 >> /var/lib/barman/.ssh/known_hosts'"
vagrant ssh backup -c "sudo su - barman -c 'ssh-keyscan -H pg2 >> /var/lib/barman/.ssh/known_hosts'"

