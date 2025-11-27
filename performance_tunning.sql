Performance Tuninng 

--View Active Connections
SELECT * FROM pg_stat_activity;

--Active Connections count
SELECT COUNT(*) AS active_connections
FROM pg_stat_activity
WHERE state = 'active';


--Check for Locks
SELECT * FROM pg_locks WHERE not granted;


--Find the Size of a Table
SELECT pg_size_pretty(pg_total_relation_size('tablename'));

--Alter Table Tablespace
ALTER TABLE tablename SET TABLESPACE new_tablespace;

--Check PostgreSQL Version
SELECT version();


--Show All Configurations
SHOW ALL;

--Check Replication Status
SELECT * FROM pg_stat_replication;


--Index Hit Rate
SELECT relname, 100 * idx_scan / (seq_scan + idx_scan) AS index_hit_rate_percent
FROM pg_stat_user_tables
WHERE seq_scan + idx_scan > 0
ORDER BY index_hit_rate_percent;


--Autovacuum Activity
SELECT pid, relid::regclass, phase, heap_blks_total, heap_blks_scanned, heap_blks_vacuumed, index_vacuum_count, max_dead_tuples, num_dead_tuples
FROM pg_stat_progress_vacuum
WHERE phase IS NOT NULL;


--Long Running Queries
SELECT pid, now() - pg_stat_activity.query_start AS duration, query
FROM pg_stat_activity
WHERE state != 'idle'
AND now() - pg_stat_activity.query_start > interval '5 minutes';

--View Locks 
SELECT pid, relation::regclass, mode, granted
FROM pg_locks
JOIN pg_stat_activity ON pg_locks.pid = pg_stat_activity.pid
WHERE NOT granted;


--Buffer Cache Hit Rate
SELECT 'heap read' AS type, sum(heap_blks_read) AS reads, sum(heap_blks_hit)  AS hits,
       (sum(heap_blks_hit) - sum(heap_blks_read)) / sum(heap_blks_hit) AS ratio
FROM pg_statio_user_tables
UNION ALL
SELECT 'index read' AS type, sum(idx_blks_read) AS reads, sum(idx_blks_hit) AS hits,
       (sum(idx_blks_hit) - sum(idx_blks_read)) / sum(idx_blks_hit) AS ratio
FROM pg_statio_user_indexes;


--