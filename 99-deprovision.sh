#!/bin/bash

psql -h red -p 5444 -U enterprisedb -c "DROP DATABASE demo_db;" edb