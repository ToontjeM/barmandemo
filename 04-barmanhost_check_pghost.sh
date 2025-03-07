#!/bin/bash

/vagrant_scripts/check_host.sh barmanhost || exit 1

red=$(tput setaf 1)
green=$(tput setaf 2)
normal=$(tput sgr0)

printf "${green}barman chech pghost${normal}\n\n"

barman check pghost
