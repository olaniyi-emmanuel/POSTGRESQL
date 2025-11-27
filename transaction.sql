-- Transaction are expected to be all or mothhing in term of transaction 

BEGIN;
UPDATE accounts SET balance = balance - 100.00
    WHERE name = 'Alice';
-- etc etc
COMMIT;

--SAVEPOINT 
BEGIN;
UPDATE accounts SET balance = balance - 100.00
    WHERE name = 'Alice';
SAVEPOINT my_savepoint;
UPDATE accounts SET balance = balance + 100.00
    WHERE name = 'Bob';
-- oops ... forget that and use Wally's account
ROLLBACK TO my_savepoint;
UPDATE accounts SET balance = balance + 100.00
    WHERE name = 'Wally';
COMMIT;


-- Incase of issues or braking 
ROLLBACK; 

-- Incase of SAVEPOINT
ROLLBACK TO SAVEPOINT; 

