-- Setting default value on a column in 
CREATE TABLE products (
product_no integer,
name text,
price numeric DEFAULT 9.99
);

-- Examples of the default values that uses an expression 
CREATE TABLE products (
product_no integer DEFAULT nextval('products_product_no_seq'),
...
);

-- Genereated Columns in a table 
CREATE TABLE people (
...,
height_cm numeric,
height_in numeric GENERATED ALWAYS AS (height_cm / 2.54) STORED
); 

-- check contraints : This checks for a boolean truthy value 
CREATE TABLE products (
product_no integer,
name text,
price numeric CHECK (price > 0)
);



