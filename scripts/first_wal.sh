#!/bin/bash

vagrant ssh barmanhost -c "sudo su - barman -c bash <<'EOF'
rm -rf /var/lib/barman/pghost/incoming/*
barman cron
barman switch-wal --force --archive pghost
barman check pghost
EOF"