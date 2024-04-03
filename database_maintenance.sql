-- Database Maintenance  Operations

-- Clean and analyze a database/table.
VACUUM (VERBOSE, ANALYZE) [table_name]; 


--Analyze a Specific Table
ANALYZE verbose [tablename];

-- Reindex a specific table.
REINDEX TABLE [table_name]; 

-- Change a database setting.
ALTER DATABASE [database_name] SET [parameter] TO [value];

-- Backup a database.
pg_dump [database_name] > [filename.sql]; 

-- Restore a database.
pg_restore -d [database_name] [filename.dump]; 


