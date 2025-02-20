#!/bin/bash

psql -d demo_db -U postgres -c "
INSERT INTO test_table (name) 
SELECT 'Item ' || generate_series(1, 100);"
