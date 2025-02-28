#!/bin/bash

# Token
if [ -f "/tokens/.edb_subscription_token" ]; then   # Running inside a VM
  export EDB_SUBSCRIPTION_TOKEN=(`cat /tokens/.edb_subscription_token`)
fi

export VM1_NAME="pg1"
export VM1_MEMORY="1024"
export VM1_CPU="1"
export VM1_PUBLIC_IP="192.168.56.11"
export VM1_SSH_PORT="2211"

export VM2_NAME="pg2"
export VM2_MEMORY="1024"
export VM2_CPU="1"
export VM2_PUBLIC_IP="192.168.56.12"
export VM2_SSH_PORT="2212"

export VM3_NAME="backup"
export VM3_MEMORY="1024"
export VM3_CPU="1"
export VM3_PUBLIC_IP="192.168.56.13"
export VM3_SSH_PORT="2213"