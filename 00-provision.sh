#!/bin/bash

. ./config/config.sh

printf "${G}*** Provisioning new VM's ***${N}\n"
vagrant up --provision
. scripts/copy_ssh_keys.sh
. scripts/first_wal.sh