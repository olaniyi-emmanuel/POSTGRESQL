-- The commands below are required for User and Permission Management

-- Create a new role.
CREATE ROLE [role_name]; 

-- Allow role to log in.
CREATE ROLE [username] LOGIN PASSWORD 'password';
ALTER ROLE [role_name] WITH LOGIN;

--Grant a role to another, which allows the grantee to use the privileges of the role they've been granted:
GRANT [parent_role] TO [child_role];

--List All Roles
\du

--List Privileges of a Table
\dp [table_name]

-- Query the pg_roles system catalog to get role information 
SELECT rolname, rolsuper, rolinherit, rolcreaterole, rolcreatedb, rolcanlogin FROM pg_roles;


--Allow a role to create more roles
ALTER ROLE [username] CREATEROLE;

--Make a user superuser
ALTER ROLE [username] SUPERUSER;

--Allow a role to create databases
ALTER ROLE [username] CREATEDB;


-- Create a new user.
CREATE USER [user_name] WITH PASSWORD '[password]';

-- Grant all privileges on a database to a user.
GRANT ALL PRIVILEGES ON DATABASE [database_name] TO [user_name]; 

-- Revoke all privileges from a user.
REVOKE ALL PRIVILEGES ON DATABASE [database_name] FROM [user_name];

-- Remove a role.
DROP ROLE [role_name]; 

--Create a role that can inherit permissions from another role
CREATE ROLE [new_role] INHERIT;

-- Granting privileges on a database 
GRANT CONNECT ON DATABASE [database_name] TO [username];

--Granting usage on a schema in a database
GRANT USAGE ON SCHEMA [schema_name] TO username;

-- Granting the required privileges on all tables in a schema
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES ON SCHEMA [schema_name] TO [username];

--Granting required privilges on a specific tables in a schema
GRANT SELECT ON [table_name] TO [username];

--Granting execution rights on all functions in a schema:
GRANT EXECUTE ON ALL FUNCTIONS ON SCHEMA [schema_name] TO [username];

--To allow a user to create objects in a schema
GRANT CREATE ON SCHEMA [schema_name] TO [username];

--You can query the information_schema.table_privileges view to check Permissions on a Table 
SELECT * FROM information_schema.table_privileges WHERE grantee = 'username';

--Find All Permissions Granted to a Role
SELECT grantee, privilege_type
FROM information_schema.role_table_grants
WHERE grantee = 'role_name';


--

