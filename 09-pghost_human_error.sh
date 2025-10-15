#!/bin/bash

/scripts/check_host.sh pghost || exit 1

red=$(tput setaf 1)
green=$(tput setaf 2)
normal=$(tput sgr0)

printf "${green}DELETE FROM test_table WHERE name LIKE 'Item 1%%';${normal}\n\n" 

psql -c "DELETE FROM test_table WHERE name LIKE 'Item 1%';" demo_db