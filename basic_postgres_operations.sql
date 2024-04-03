--Launch the PostgreSQL command-line interface.
psql -h host -p 5432 - d [database_name] -U [username]

-- Quit psql.
\q 

-- - List all databases.
\l or \list 

-- Connect to a specific database.
\c [database_name] 

-- List all tables in the current database.
\dt 

-- Describe a table structure.
\d [table_name] 

-- Create a new database.
CREATE DATABASE [database_name]; 

-- Delete a database.
DROP DATABASE [database_name]; 