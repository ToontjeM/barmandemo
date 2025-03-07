#!/bin/bash

/vagrant_scripts/check_host.sh barmanhost || exit 1

red=$(tput setaf 1)
green=$(tput setaf 2)
normal=$(tput sgr0)

printf "${green}barman list-backup pghost${normal}\n\n"


barman list-backup pghost