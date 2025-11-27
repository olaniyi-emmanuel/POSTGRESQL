-- Command to see the number of pages and rows/tuples in a table
SELECT relpages, reltuples FROM pg_class WHERE relname = 'tenk1';


 -- Commands to run explain plan for a query
EXPLAIN SELECT * FROM tenk1 WHERE unique1 = 5000;

-- To run Explain and Analyze 
EXPLAIN ANALYZE SELECT * FROM tenk1 WHERE unique1 = 5000;


-- Command to get the Analyze statistics for a table
-- This might not be really correct as it not updated in real time 
SELECT relname, relkind, reltuples, relpages
FROM pg_class
WHERE relname LIKE 'tenk1%';

-- Create extended Statistics in case of correlated columns
CREATE STATISTICS stats_tenk1 ON even, unique1 FROM tenk1;
CREATE STATISTICS s1 (dependencies) ON a, b FROM t1;
