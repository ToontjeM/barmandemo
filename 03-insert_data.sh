#!/bin/bash

psql -h red -p 5444 -U enterprisedb -c "
INSERT INTO test_table (name) 
SELECT 'Item ' || generate_series(1, 100);" edb