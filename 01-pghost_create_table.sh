#!/bin/bash

/vagrant_scripts/check_host.sh pghost || exit 1

red=$(tput setaf 1)
green=$(tput setaf 2)
normal=$(tput sgr0)

printf "${green}CREATE TABLE test_table (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT now()
);${normal}\n\n"

psql -c "
CREATE TABLE test_table (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT now()
);" demo_db
