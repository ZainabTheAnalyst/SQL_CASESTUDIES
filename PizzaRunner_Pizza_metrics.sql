/*To clean the customer_orders table: I created a new table called customer_orders1
 and cleaned it to avoid any data loss of the original table.*/


update customer_orders set 
exclusions = case exclusions when 'null' then null else exclusions end,
extras = case extras when 'null' then null else extras end;

-- Copying table and cleaning data

UPDATE runner_orders set 
duration =  case 
 when duration like '%minutes' then trim('minutes' from duration)
 when duration like '%mins' then trim('mins' from duration)
 when duration like '%minute' then trim('minute' from duration)
 else duration
end,
distance = case
 when distance like '%km' then trim('km' from distance)
 else distance 
end;

update runner_orders
set 
pickup_time = case pickup_time when 'null' then null else pickup_time end,
distance = case distance when 'null' then null else distance end,
duration = case duration when 'null' then null else duration end,
cancellation = case cancellation when 'null' then null else cancellation end;

-- update datatypes for runner table
alter table runner_orders
ALTER COLUMN duration INT 

alter table runner_orders
ALTER COLUMN pickup_time DATETIME

alter table runner_orders
ALTER COLUMN distance FLOAT
-- Copying table to new table
drop table if exists customer_orders1;
create table customer_orders1 as
(select order_id, customer_id, pizza_id, exclusions, extras, order_time 
from customer_orders);
-- Cleaning data
update customer_orders1
set 
exclusions = case exclusions when 'null' then null else exclusions end,
extras = case extras when 'null' then null else extras end;

-- For Runner's order table 

-- Copying table and cleaning data
drop table if exists runner_orders1;
create table runner_orders1 as 
(select order_id, runner_id, pickup_time,
case
 when distance like '%km' then trim('km' from distance)
 else distance 
end as distance,
case
 when duration like '%minutes' then trim('minutes' from duration)
 when duration like '%mins' then trim('mins' from duration)
 when duration like '%minute' then trim('minute' from duration)
 else duration
end as duration, cancellation 
from runner_orders);
-- cleaning data
update runner_orders1
set 
pickup_time = case pickup_time when 'null' then null else pickup_time end,
distance = case distance when 'null' then null else distance end,
duration = case duration when 'null' then null else duration end,
cancellation = case cancellation when 'null' then null else cancellation end;
-- cleaning data
update runner_orders1
set 
pickup_time = case pickup_time when 'null' then null else pickup_time end,
distance = case distance when 'null' then null else distance end,
duration = case duration when 'null' then null else duration end,
cancellation = case cancellation when 'null' then null else cancellation end;

-- update datatypes for runner table
ALTER TABLE runner_orders1
ALTER COLUMN pickup_time DATETIME,
ALTER COLUMN distance FLOAT, 
ALTER COLUMN duration INT;

-- A. PIZZA METRICS
-- Q1. How many pizzas were ordered?
 
 SELECT 
       COUNT(order_id)
FROM customer_orders1; -- 14 pizzas were ordered

-- Q2. How many unique customer orders were made?

SELECT 
      COUNT(DISTINCT order_id)
FROM customer_orders1; -- A total of 10 unique orders were placed.

-- Q3. How many successful orders were delivered by each runner?

SELECT
      runner_id,
      COUNT(runner_id)
FROM runner_orders1
WHERE distance IS NOT NULL
GROUP BY 1
ORDER BY 1; 
-- Runner 1 has 4 successful delivered orders.
-- Runner 2 has 3 successful delivered orders.
-- Runner 3 has 1 successful delivered order.

-- Q4. How many of each type of pizza was delivered?

SELECT 
     pn.pizza_name,
     COUNT(co.order_id)
FROM customer_orders1 co
   JOIN runner_orders1 ro ON ro.order_id = co.order_id
   JOIN pizza_names pn ON co.pizza_id = pn.pizza_id
WHERE ro.distance IS NOT NULL   
GROUP BY 1;
-- There are 9 delivered Meatlovers pizzas and 3 Vegetarian pizzas.

-- Q5. How many Vegetarian and Meatlovers were ordered by each customer?
SELECT 
    co.customer_id,
    COUNT(CASE WHEN pizza_name = 'Vegetarian' then order_id ELSE NULL END) AS vegetarian,
    COUNT(CASE WHEN pizza_name = 'Meatlovers' then order_id ELSE NULL END) AS meatlovers 
FROM customer_orders1 co
   JOIN pizza_names pn ON pn.pizza_id = co.pizza_id
GROUP BY 1
ORDER BY 1;

-- Q6. What was the maximum number of pizzas delivered in a single order? pizza_count
WITH pizza_count_cte AS
(
SELECT 
     co.order_id,
     COUNT(co.pizza_id) AS pizza_per_order
FROM runner_orders1 ro
  JOIN customer_orders1 co ON co.order_id = ro.order_id 
WHERE distance IS NOT NULL
GROUP BY 1
ORDER BY 1)

SELECT 
     MAX(pizza_per_order)
FROM pizza_count_cte; -- Maximum number of pizza delivered in a single order is 3 pizzas.

-- Q7. For each customer, how many delivered pizzas had at least 1 change, and how many had no changes?

SELECT 
     co.customer_id,
     COUNT(CASE WHEN co.exclusion >= 1 AND co.extras >= 1 THEN co.order_id ELSE NULL END) AS atleast_1_change,
     COUNT(CASE WHEN co.exclusions < 1 co.extras < 1 THEN co.order_id ELSE NULL END) AS no_change
FROM customer_orders1 co 
JOIN runner_orders1 ro ON co.order_id = ro.order_id 
WHERE ro.distance IS NOT NULL 
GROUP BY 1;

-- Q8. How many pizzas were delivered that had both exclusions and extras?

SELECT  
	 SUM(
     CASE WHEN exclusions IS NOT NULL AND extras IS NOT NULL THEN 1
     ELSE 0
     END) AS pizza_count_w_exclusions_extras
FROM customer_orders AS c
JOIN runner_orders AS r
  ON c.order_id = r.order_id
WHERE r.distance >= 1 
  AND exclusions <> ' ' 
  AND extras <> ' ';









































