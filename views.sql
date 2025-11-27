-- Views help us to logically have and see a table from another query because you dont want to keep running the 
-- same query over and over agin 
create VIEW myview AS 
select * from customers where first_name LIKE 'F%';

 -- fetching records from view 
 SELECT * FROM myview

 