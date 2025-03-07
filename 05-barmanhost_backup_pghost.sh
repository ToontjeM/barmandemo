#!/bin/bash

/vagrant_scripts/check_host.sh barmanhost || exit 1

red=$(tput setaf 1)
green=$(tput setaf 2)
normal=$(tput sgr0)

printf "${green}barman backup pghost --wait${normal}\n\n"
printf "${green}(If the backup waits for the WAL file to be closed, force cloing the WAL file by running ${red}./50-switch_wal.sh${green} on pghost)${normal}\n\n"

barman backup pghost --wait