#!/bin/bash

psql -h red -p 5444 -U enterprisedb -c "SELECT COUNT(*) FROM test_table;" edb
