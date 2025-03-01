# Barman demo (WIP)
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
- `01-create_database.sh`
```
[barman@barman ~]$ psql -h red -U enterprisedb -c "CREATE DATABASE demo_db;" edb
CREATE DATABASE
[barman@barman ~]$ 
```

- `02-create_table.sh`
```
psql -h red -p 5444 -U enterprisedb -c "
CREATE TABLE test_table (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT now());"
```

- `03-insert_data.sh`
```
psql -h red -p 5444 -U enterprisedb -c "
INSERT INTO test_table (name) 
SELECT 'Item ' || generate_series(1, 100);" edb
```

- `04-verify_data.sh`
```
psql -h red -p 5444 -U enterprisedb -c "SELECT COUNT(*) FROM test_table;" edb
```

- `sudo su - barman`
- `barman check red`
```
[barman@barman ~]$ barman check red
Server red:
    PostgreSQL: OK
    superuser or standard user with backup privileges: OK
    PostgreSQL streaming: OK
    wal_level: OK
    replication slot: OK
    directories: OK
    retention policy settings: OK
    backup maximum age: OK (interval provided: 7 days, latest backup age: 1 day, 6 hours, 25 minutes, 15 seconds)
    backup minimum size: OK (328.3 MiB)
    wal maximum age: OK (no last_wal_maximum_age provided)
    wal size: OK (8.0 MiB)
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
- `barman backup red`
```
[barman@barman ~]$ barman backup red

```
- `barman list-backup red`
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

- `barman restore --target-time "2025-01-21 10:00:00" red  DESTINATION_PATH`

- `psql -h red -p 5444 -U enterprisedb -c "DROP DATABASE demo_db;" edb`

- `barman show-backup red latest`
```
[barman@barman ~]$ barman show-backup red latest
Backup 20250227T103040:
  Server Name            : red
  System Id              : 7464612433885959675
  Status                 : DONE
  PostgreSQL Version     : 160006
  PGDATA directory       : /opt/postgres/data
  Estimated Cluster Size : 248.5 MiB

  Server information:
    Checksums            : on

  Base backup information:
    Backup Method        : rsync-concurrent
    Backup Size          : 45.4 MiB (45.4 MiB with WALs)
    WAL Size             : 41.9 KiB
    Resources saved      : 215.7 MiB (86.81%)
    Timeline             : 1
    Begin WAL            : 000000010000000000000070
    End WAL              : 000000010000000000000070
    WAL number           : 1
    WAL compression ratio: 99.74%
    Begin time           : 2025-02-27 09:30:41.086704+00:00
    End time             : 2025-02-27 09:34:09.391747+00:00
    Copy time            : 8 seconds + 4 seconds startup
    Estimated throughput : 5.1 MiB/s
    Begin Offset         : 40
    End Offset           : 81416
    Begin LSN            : 0/70000028
    End LSN              : 0/70013E08

  WAL information:
    No of files          : 0
    Disk usage           : 0 B
    Last available       : 000000010000000000000070

  Catalog information:
    Retention Policy     : VALID
    Previous Backup      : 20250226T040006
    Next Backup          : - (this is the latest base backup)
```
- `barman recover red latest /var/lib/edb/as17/data --target-time "YYYY-MM-DD HH:MM:SS"`

- `psql -h red -p 5444 -U enterprisedb -c "SELECT COUNT(*) FROM test_table;" edb` 

- `psql -h red -p 5444 -U enterprisedb -c "INSERT INTO test_table VALUES (generate_series(1,100));" edb`

- `barman switch-wal --force red`


## Demo tear down
- `99-deprovision.sh`

Kf6l#ZH@b98Nd*511wCH@#uxxsrvgopm