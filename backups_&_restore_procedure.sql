--Backup and Restore Operations


--This command creates a compressed (tar format) backup of the database
pg_dump -U [username] -W -F t [database_name] > database_backup.tar

--Restores a database from a backup file
pg_restore -U [username] -W -d [database_name] database_backup.tar
