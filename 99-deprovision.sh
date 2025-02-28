#!/bin/bash

. ./config/config.sh

printf "${G}*** De-provisioning VM's ***${N}\n"
vagrant destroy -f