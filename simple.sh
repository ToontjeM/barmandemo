#!/bin/bash

SERVER1="pg1"
SERVER2="backup"

echo "Checking SSH connection to $SERVER1..."
vagrant ssh $SERVER1 -c "whoami"

echo "Checking SSH connection to $SERVER2..."
vagrant ssh $SERVER2 -c "whoami"

echo "Checking postgres user on $SERVER1..."
vagrant ssh $SERVER1 -c "sudo -u postgres whoami"

echo "Checking postgres user on $SERVER2..."
vagrant ssh $SERVER2 -c "sudo -u postgres whoami"

echo "Generating SSH key for postgres on $SERVER1..."
vagrant ssh $SERVER1 -c "sudo -u postgres bash -c 'mkdir -p /var/lib/pgsql/.ssh && ssh-keygen -t rsa -b 4096 -N \"\" -f /var/lib/pgsql/.ssh/id_rsa'"

echo "Verifying key exists on $SERVER1..."
vagrant ssh $SERVER1 -c "sudo ls -l /var/lib/pgsql/.ssh"

echo "Copying postgres key from $SERVER1 to $SERVER2..."
POSTGRES_PUB_KEY=$(vagrant ssh $SERVER1 -c "sudo cat /var/lib/pgsql/.ssh/id_rsa.pub" | tail -n +2 | tr -d '\r')
echo "Key: $POSTGRES_PUB_KEY"


