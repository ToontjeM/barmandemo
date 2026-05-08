#!/bin/bash

#!/bin/bash

if [ -f "/tokens/edb_subscription_token" ]; then
  read -r EDB_SUBSCRIPTION_TOKEN < /tokens/edb_subscription_token
else
  read -r EDB_SUBSCRIPTION_TOKEN < "$HOME/.tokens/edb_subscription_token"
fi

export EDB_SUBSCRIPTION_TOKEN
