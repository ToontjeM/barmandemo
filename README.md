# Barman demo (WIP)
In this demo we are showing how [Barman](https://pgbarman.org/) can be used to do the following:
- Make continous backup of a PostgreSQL database.
- Perform a Point-In-time restore of a PostgreSQL database.
- Performa full recovery of a PostgreSQL database.

This demo uses.....

## Demo setup
2 VM's
- pghost (Database server running PostgreSQL 17)
- barmanhost (Backup server running barman)

### Installation
`00-provision.sh`

### Check

## Demo flow
**PGHOST**
- `sudo su - postgres`
- `cd /vagrant`

- `01-pghost_create_table.sh`
```
CREATE TABLE test_table (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    
CREATE TABLE
```

- `02-pghost_insert_data.sh`
```
INSERT INTO test_table (name)
    SELECT 'Item ' || generate_series(1, 100);

INSERT 0 100
```

- `03-pghost_verify_data.sh`
```
SELECT COUNT(*) FROM test_table;

 count 
-------
   100
(1 row)
```

**BARMANHOST**
- `sudo su - barman`
- `cd /vagrant`
- `04-barman_check-pghost.sh`

  ```
  Server pghost:
        PostgreSQL: OK
        superuser or standard user with backup privileges: OK
        PostgreSQL streaming: OK
        wal_level: OK
        replication slot: OK
        directories: OK
        retention policy settings: OK
        backup maximum age: OK (no last_backup_maximum_age provided)
        backup minimum size: OK (0 B)
        wal maximum age: OK (no last_wal_maximum_age provided)
        wal size: OK (0 B)
        compression settings: OK
        failed backups: OK (there are 0 failed backups)
        minimum redundancy requirements: OK (have 0 backups, expected at least 0)
        pg_basebackup: OK
        pg_basebackup compatible: OK
        pg_basebackup supports tablespaces mapping: OK
        systemid coherence: OK (no system Id stored on disk)
        pg_receivexlog: OK
        pg_receivexlog compatible: OK
        receive-wal running: OK
        archiver errors: OK
  ```

- `05-barmanhost_backup_pghost.sh`

  ```
  barman backup pghost --wait

  (If the backup waits for the WAL file to be closed, force cloing the WAL file by running ./50-switch_wal.sh on pghost)

  Starting backup using postgres method for server pghost in /var/lib/barman/pghost/base/20250306T162854
  Backup start at LSN: 0/7000060 (000000010000000000000007, 00000060)
  Starting backup copy via pg_basebackup for 20250306T162854
  Copy done (time: less than one second)
  Finalising the backup.
  Backup size: 22.3 MiB
  Backup end at LSN: 0/9000000 (000000010000000000000009, 00000000)
  Backup completed (start time: 2025-03-06 16:28:55.000433, elapsed time: 1 second)
  Waiting for the WAL file 000000010000000000000009 from server 'pghost'
  Processing xlog segments from streaming for pghost
          000000010000000000000007
          000000010000000000000008
  Processing xlog segments from streaming for pghost
          000000010000000000000009
  ```

> [!NOTE]
> As stated in the script file, if backup takes too long o complete, perform a `50-switch_wal.sh` on the Postgres server.

- `06-barmanhost_list_backups.sh`
```
pghost 20250306T162854 - F - Thu Mar  6 16:28:55 2025 - Size: 22.3 MiB - WAL Size: 0 B
pghost 20250306T162800 - F - Thu Mar  6 16:28:01 2025 - Size: 22.3 MiB - WAL Size: 48.2 KiB
pghost 20250306T162722 - F - Thu Mar  6 16:27:23 2025 - Size: 22.3 MiB - WAL Size: 32.2 KiB
```

**PGHOST**
- `07-pghost_add_more_data.sh`
  ```
  INSERT INTO test_table (name)
    SELECT 'Item ' || generate_series(1, 1000);

  INSERT 0 1000
  ```

**BARMANHOST**
- `08-barmanhost_another_backup.sh`
  ```
  barman backup pghost --wait

  Starting backup using postgres method for server pghost in /var/lib/barman/pghost/base/20250306T165805
  Backup start at LSN: 0/A45D398 (00000001000000000000000A, 0045D398)
  Starting backup copy via pg_basebackup for 20250306T165805
  Copy done (time: 2 seconds)
  Finalising the backup.
  Backup size: 29.8 MiB
  Backup end at LSN: 0/C000000 (00000001000000000000000C, 00000000)
  Backup completed (start time: 2025-03-06 16:58:05.051087, elapsed time: 3 seconds)
  Waiting for the WAL file 00000001000000000000000C from server 'pghost'
  Processing xlog segments from streaming for pghost
          00000001000000000000000A
          00000001000000000000000B
  Processing xlog segments from streaming for pghost
          00000001000000000000000C
  ```

**PGHOST**
- `09-human_error.sh`
  ```
  DELETE FROM test_table WHERE name LIKE 'Item 1%';

  DELETE 112
  ```

- `10-show_data.sh`

  ```
     id  |   name   |         created_at         
  ------+----------+----------------------------
      2 | Item 2   | 2025-03-07 08:19:37.699429
      3 | Item 3   | 2025-03-07 08:19:37.699429
      4 | Item 4   | 2025-03-07 08:19:37.699429
      5 | Item 5   | 2025-03-07 08:19:37.699429
      6 | Item 6   | 2025-03-07 08:19:37.699429
      7 | Item 7   | 2025-03-07 08:19:37.699429
      8 | Item 8   | 2025-03-07 08:19:37.699429
      9 | Item 9   | 2025-03-07 08:19:37.699429
     20 | Item 20  | 2025-03-07 08:19:37.699429
     21 | Item 21  | 2025-03-07 08:19:37.699429
     22 | Item 22  | 2025-03-07 08:19:37.699429
     23 | Item 23  | 2025-03-07 08:19:37.699429
     24 | Item 24  | 2025-03-07 08:19:37.699429
     25 | Item 25  | 2025-03-07 08:19:37.699429
     26 | Item 26  | 2025-03-07 08:19:37.699429
     27 | Item 27  | 2025-03-07 08:19:37.699429
     28 | Item 28  | 2025-03-07 08:19:37.699429
  ```

**BARMANHOST**
- `11-list_backups.sh`
  ```
  barman list-backup pghost

  pghost 20250306T170202 - F - Thu Mar  6 17:02:03 2025 - Size: 29.8 MiB - WAL Size: 0 B
  pghost 20250306T165805 - F - Thu Mar  6 16:58:08 2025 - Size: 29.8 MiB - WAL Size: 48.2 KiB
  pghost 20250306T162854 - F - Thu Mar  6 16:28:55 2025 - Size: 22.3 MiB - WAL Size: 1.0 MiB
  pghost 20250306T162800 - F - Thu Mar  6 16:28:01 2025 - Size: 22.3 MiB - WAL Size: 48.2 KiB
  pghost 20250306T162722 - F - Thu Mar  6 16:27:23 2025 - Size: 22.3 MiB - WAL Size: 32.2 KiB
  ```

- `12-barmanhost_recover_db.sh`
  ```
  Shutdown Database
  /usr/pgsql-17/bin/pg_ctl --pgdata=/var/lib/pgsql/17/data stop

  waiting for server to shut down.... done
  server stopped
  
  Backup and remove broken database
  cp -a /var/lib/pgsql/17/data /var/lib/pgsql/17/old_data && rm -rf /var/lib/pgsql/17/data/*

  Recover last backup
  barman recover --remote-ssh-command 'ssh postgres@pghost' pghost latest /var/lib/pgsql/17/data

  Starting remote restore for server pghost using backup 20250307T084612
  Destination directory: /var/lib/pgsql/17/data
  Remote command: ssh postgres@pghost
  Copying the base backup.
  Copying required WAL segments.
  Generating archive status files
  Identify dangerous settings in destination directory.

  Restore operation completed (start time: 2025-03-07 08:51:25.157405+00:00, elapsed time: 5 seconds)
  Your PostgreSQL server has been successfully prepared for recovery!
  
  Start database
  /usr/pgsql-17/bin/pg_ctl --pgdata=/var/lib/pgsql/17/data -l /var/lib/pgsql/17/data/log/pg.log start

  waiting for server to start.... done
  server started
  ```

- `13-pghost_show_data.sh`
```
  id  |   name    |         created_at         
------+-----------+----------------------------
    1 | Item 1    | 2025-03-07 08:19:37.699429
    2 | Item 2    | 2025-03-07 08:19:37.699429
    3 | Item 3    | 2025-03-07 08:19:37.699429
    4 | Item 4    | 2025-03-07 08:19:37.699429
    5 | Item 5    | 2025-03-07 08:19:37.699429
    6 | Item 6    | 2025-03-07 08:19:37.699429
    7 | Item 7    | 2025-03-07 08:19:37.699429
    8 | Item 8    | 2025-03-07 08:19:37.699429
    9 | Item 9    | 2025-03-07 08:19:37.699429
   10 | Item 10   | 2025-03-07 08:19:37.699429
   11 | Item 11   | 2025-03-07 08:19:37.699429
   12 | Item 12   | 2025-03-07 08:19:37.699429
   13 | Item 13   | 2025-03-07 08:19:37.699429
   14 | Item 14   | 2025-03-07 08:19:37.699429
   15 | Item 15   | 2025-03-07 08:19:37.699429
   16 | Item 16   | 2025-03-07 08:19:37.699429
   17 | Item 17   | 2025-03-07 08:19:37.699429
```

## Demo tear down
- `99-deprovision.sh`
