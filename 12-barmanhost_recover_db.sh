#!/bin/bash

/vagrant_scripts/check_host.sh barmanhost || exit 1

red=$(tput setaf 1)
green=$(tput setaf 2)
normal=$(tput sgr0)

printf "${green}Shutdown Database${normal}\n\n" 
ssh postgres@pghost /usr/pgsql-17/bin/pg_ctl --pgdata=/var/lib/pgsql/17/data stop

printf "${green}Backup and remove broken database${normal}\n\n" 
ssh postgres@pghost "cp -a /var/lib/pgsql/17/data /var/lib/pgsql/17/old_data && rm -rf /var/lib/pgsql/17/data/*"

printf "${green}Recover last backup${normal}\n\n" 
barman recover --remote-ssh-command 'ssh postgres@pghost' pghost latest /var/lib/pgsql/17/data

printf "${green}Start database${normal}\n\n" 
ssh postgres@pghost "/usr/pgsql-17/bin/pg_ctl --pgdata=/var/lib/pgsql/17/data -l /var/lib/pgsql/17/data/log/pg.log start"
