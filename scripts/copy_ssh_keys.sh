#!/bin/bash

vagrant ssh pghost -c "sudo -u postgres bash <<'EOF'
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

vagrant ssh barmanhost -c "sudo -u barman bash <<'EOF'
mkdir -p /var/lib/barman/.ssh
chmod 700 /var/lib/barman/.ssh
touch /var/lib/barman/.ssh/known_hosts
ssh-keygen -t rsa -f /var/lib/barman/.ssh/id_rsa -N \"\"
touch /var/lib/barman/.ssh/authorized_keys
chmod 600 /var/lib/barman/.ssh/id_rsa
chmod 644 /var/lib/barman/.ssh/id_rsa.pub
chmod 600 /var/lib/barman/.ssh/authorized_keys
chmod 644 /var/lib/barman/.ssh/known_hosts
EOF"

echo "Copying SSH keys"
KEY=$(vagrant ssh pghost -c "sudo -u postgres cat /var/lib/pgsql/.ssh/id_rsa.pub")
printf '\n%s\n' "$KEY" | vagrant ssh barmanhost -c "sudo -u barman tee -a /var/lib/barman/.ssh/authorized_keys > /dev/null"
KEY=$(vagrant ssh barmanhost -c "sudo -u barman cat /var/lib/barman/.ssh/id_rsa.pub")
printf '\n%s\n' "$KEY" | vagrant ssh pghost -c "sudo -u postgres tee -a /var/lib/pgsql/.ssh/authorized_keys > /dev/null"
vagrant ssh pghost -c "sudo su - postgres -c 'ssh-keyscan -H barmanhost >> /var/lib/pgsql/.ssh/known_hosts'"
vagrant ssh barmanhost -c "sudo su - barman -c 'ssh-keyscan -H pghost >> /var/lib/barman/.ssh/known_hosts'"


