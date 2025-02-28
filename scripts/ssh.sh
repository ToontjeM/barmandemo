#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <machine_name> <port_number>"
    exit 1
fi

machine_name=$1
port_number=$2

ssh -i ".vagrant/machines/$machine_name/virtualbox/private_key" -p "$port_number" vagrant@127.0.0.1
