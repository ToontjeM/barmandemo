# Barman demo
In this demo we are showing how [Barman](https://pgbarman.org/) can be used to do the following:
- Make continous backup of a PostgreSQL database.
- Perform a Pint-In-time restore of a PostgreSQL database.
- Performa full recovery of a PostgreSQL database.

This demo uses.....

## Demo setup
3 VM's
- pg1 (primary)
- pg2 (standby)
- backup (barman)

### Installation
`00-provision.sh`

### Check
#### On PG:
- `ps aux | grep wal`
- `barman switch-wal --force primary-db`
- `sudo journalctl -u postgresql | grep "archived"`

#### On backup:
- `barman list-backup primary-db`
- `ls -lh /var/lib/barman/primary-db/incoming/`

## Demo flow
- `psql -U postgres -c "CREATE DATABASE demo_db;"`
```
    [barman@barman ~]$ psql -h red -U enterprisedb -c "CREATE DATABASE demo_db;" edb
    Password for user enterprisedb: 
    CREATE DATABASE
    [barman@barman ~]$ 
    ```
- `01-create_table.sh`
```
psql -d demo_db -U postgres -c "
CREATE TABLE test_table (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT now()
);"
```
- `02-insert_data.sh`
```
psql -d demo_db -U postgres -c "
INSERT INTO test_table (name) 
SELECT 'Item ' || generate_series(1, 100);"
```
- `03-verify_data.sh`
```
psql -d demo_db -U postgres -c "SELECT COUNT(*) FROM test_table;"
```

- `sudo su - barman`
- `barman check primary`
```
[barman@barman ~]$ barman check pg1
Server pg1:
        PostgreSQL: OK
        superuser or standard user with backup privileges: OK
        PostgreSQL streaming: OK
        wal_level: OK
        replication slot: OK
        directories: OK
        retention policy settings: OK
        backup maximum age: FAILED (interval provided: 7 days, latest backup age: 12 days, 12 hours, 55 minutes, 59 seconds)
        backup minimum size: OK (337.9 MiB)
        wal maximum age: OK (no last_wal_maximum_age provided)
        wal size: OK (10.7 MiB)
        compression settings: OK
        failed backups: OK (there are 0 failed backups)
        minimum redundancy requirements: OK (have 7 backups, expected at least 3)
        ssh: OK (PostgreSQL server)
        systemid coherence: OK
        pg_receivexlog: OK
        pg_receivexlog compatible: OK
        receive-wal running: OK
        archiver errors: OK
[barman@barman ~]$ 
```
- `barman backup pg1`
```
[barman@barman ~]$ barman backup pg1
Starting backup using rsync-concurrent method for server pg1 in /var/lib/barman/red/base/20250220T170048
Backup start at LSN: 0/52000028 (000000010000000000000052, 00000028)
Starting backup copy via rsync/SSH for 20250220T170048
Copy done (time: 5 seconds)
Asking PostgreSQL server to finalize the backup.
Backup size: 254.3 MiB. Actual size on disk: 28.2 MiB (-88.90% deduplication ratio).
Backup end at LSN: 0/52000138 (000000010000000000000052, 00000138)
Backup completed (start time: 2025-02-20 17:00:49.941381, elapsed time: 12 seconds)
Processing xlog segments from streaming for red
        000000010000000000000051
        000000010000000000000052
```
- `barman list-backup pg1`
```
[barman@barman ~]$ barman list-backup red
red 20250220T170048 - R - Thu Feb 20 16:00:59 2025 - Size: 254.4 MiB - WAL Size: 0 B
red 20250208T040006 - R - Sat Feb  8 03:00:21 2025 - Size: 338.0 MiB - WAL Size: 10.9 MiB
red 20250205T040006 - R - Wed Feb  5 03:00:26 2025 - Size: 337.4 MiB - WAL Size: 17.9 MiB
red 20250201T040007 - R - Sat Feb  1 03:00:24 2025 - Size: 295.1 MiB - WAL Size: 24.2 MiB
red 20250129T040006 - R - Wed Jan 29 03:00:27 2025 - Size: 253.4 MiB - WAL Size: 17.5 MiB
red 20250127T161944 - R - Mon Jan 27 15:19:49 2025 - Size: 74.2 MiB - WAL Size: 30.5 MiB
red 20250127T161927 - R - Mon Jan 27 15:19:32 2025 - Size: 74.2 MiB - WAL Size: 111.3 KiB
red 20250127T161910 - R - Mon Jan 27 15:19:18 2025 - Size: 74.2 MiB - WAL Size: 36.2 KiB
```


## Demo tear down
