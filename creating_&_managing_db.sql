--Creating database in postgres 
CREATE DATABASE database_name; 

-- Drop databas e
DROP DATABASE database_name; 



-- Accessing the database 
psql  - h hostnamr - U username -d DATABASE -p portnumber 

-- get the version if the posgres runnning in postgres commandline 
SELECT VERSION();

--get current date 
SELECT current_date;


--quit the command shell 
\q

--Create table command 
CREATE TABLE table_name (
 city varchar(80),
 temp_lo int, -- low temperature
 temp_hi int, -- high temperature
 prcp real, -- precipitation
 date date
);


--Delete a table from a database 
DROP TABLE tablename;

--Insert query 
INSERT INTO weather (city, temp_lo, temp_hi, prcp, date)
 VALUES ('San Francisco', 43, 57, 0.0, '1994-11-29');

-- Copy command in loading data from flat files 
COPY weather FROM '/home/user/weather.txt'