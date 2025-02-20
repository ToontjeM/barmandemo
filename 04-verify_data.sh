#!/bin/bash

psql -d demo_db -U postgres -c "SELECT COUNT(*) FROM test_table;"
