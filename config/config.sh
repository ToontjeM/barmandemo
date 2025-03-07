#!/bin/bash

# Token
if [ -f "/tokens/.edb_subscription_token" ]; then   # Running inside a VM
  export EDB_SUBSCRIPTION_TOKEN=(`cat /tokens/.edb_subscription_token`)
fi


