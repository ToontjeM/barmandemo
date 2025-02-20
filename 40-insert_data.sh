#!/bin/bash

psql -d demo_db -c "INSERT INTO test_table VALUES (generate_series(1,100));"
