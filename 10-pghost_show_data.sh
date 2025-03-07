#!/bin/bash

/vagrant_scripts/check_host.sh pghost || exit 1

red=$(tput setaf 1)
green=$(tput setaf 2)
normal=$(tput sgr0)

printf "${green}SELECT * FROM test_table;${normal}\n\n" 

psql -c "SELECT * FROM test_table;" demo_db