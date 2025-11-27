-- iMPORT nto table users(id, name, email, signup_date):
COPY users(id, name, email, signup_date)
FROM '/absolute/path/to/users.csv'
WITH (FORMAT csv, HEADER true);


-- Export a table to CSV
COPY orders
TO '/path/to/orders_export.csv'
WITH (FORMAT csv, HEADER true);

-- COPY COMMAND FOR DATA MIGRATION BETWEEN DATABASE SERVERS
COPY customers TO '/tmp/customers_dump.csv' WITH (FORMAT csv, HEADER true);
--tRANSFER data tO OTHER POSTGRESQL DATABASE SERVER
COPY customers FROM '/tmp/customers_dump.csv' WITH (FORMAT csv, HEADER true);
