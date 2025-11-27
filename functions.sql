--Aggregate functions 
select max(total_amount) from orders; 
select * from orders where total_amount = (select max(total_amount) from orders); 

-- Count function 
select count(*) from orders; 

-- Like Operator 
select * from customers where first_name LIKE 'F%';


-- Update statement 
UPDATE customers
SET column_name = new_value
WHERE customer_id::TEXT LIKE 'F%';

-- Delete statement 
DELETE FROM weather WHERE city = 'Hayward';


