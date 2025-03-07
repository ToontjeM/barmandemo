#!/bin/bash

/vagrant_scripts/check_host.sh pghost || exit 1

red=$(tput setaf 1)
green=$(tput setaf 2)
normal=$(tput sgr0)

printf "${green}INSERT INTO test_table (name)
    SELECT 'Item ' || generate_series(1, 100);${normal}\n\n"

psql -c "
INSERT INTO test_table (name) 
SELECT 'Item ' || generate_series(1, 100);" demo_db