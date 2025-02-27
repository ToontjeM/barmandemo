#!/bin/bash

psql -h red -p 5444 -U enterprisedb -c "
CREATE TABLE test_table (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT now()
);" edb