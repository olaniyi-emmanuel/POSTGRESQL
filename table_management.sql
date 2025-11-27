--Describe a table with associated columns 
\d TABLE_NAME 

-- select an expression from a 
SELECT (COLUMN1 / COLUMN2) AS AVG_GAS_PRICE; 
-- Remember to use AS in the QUERY 

-- Order Result output according to a specific order 
SELECT * FROM weather
    ORDER BY city;

-- Select disticnt non-repittive recors from a table
--  duplicate rows will be removed from the result of a query
SELECT DISTINCT total_amount from orders; 

/* To drop a table
Just becareful because droppped table cannot be retrieved 
*/
DROP TABLE my_first_table;

-- Check if table exists first before dropping the table 
DROP TABLE IF EXISTS products;
-- Join Queries


