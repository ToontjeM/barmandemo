#!/bin/bash

/scripts/check_host.sh barmanhost || exit 1

red=$(tput setaf 1)
green=$(tput setaf 2)
normal=$(tput sgr0)

printf "${green}barman backup pghost --wait${normal}\n\n"

barman backup pghost --wait