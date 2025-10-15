#!/bin/bash

/scripts/check_host.sh pghost || exit 1

red=$(tput setaf 1)
green=$(tput setaf 2)
normal=$(tput sgr0)

printf "${green}SELECT pg_switch_wal();${normal}\n\n" 

psql -c "SELECT pg_switch_wal();" demo_db