-- PIZZA RUNNER 
--CLEANING DATA

update customer_orders set 
exclusions = case exclusions when 'null' then null else exclusions end,
extras = case extras when 'null' then null else extras end

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

-- Pizza Metrics
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
  SUM(
    CASE WHEN co.exclusions <> ' ' OR co.extras <> ' ' THEN 1
    ELSE 0
    END) AS at_least_1_change,
  SUM(
    CASE WHEN co.exclusions = ' ' AND co.extras = ' ' THEN 1 
    ELSE 0
    END) AS no_change
FROM customer_orders AS co
JOIN runner_orders AS ro
  ON co.order_id = ro.order_id
WHERE ro.distance <> 0
GROUP BY  co.customer_id
ORDER BY  co.customer_id; 
-- Customers 101 and 102 had no changes and customers 103,104,105 had atleast 1 change.

-- Q8. How many pizzas were delivered that had both exclusions and extras?
SELECT 
  SUM(
     CASE WHEN exclusions IS NOT NULL AND extras IS NOT NULL THEN 1
     ELSE 0
     END) AS pizza_w_changes
FROM customer_orders AS co
JOIN runner_orders AS ro
  ON co.order_id = ro.order_id
WHERE ro.distance <> 0
AND exclusions <> ' ' 
AND extras <> ' '; --  Only 1 pizza delivered had both exclusions & extras.

-- Q9. What was the total volume of pizzas ordered for each hour of the day? 
SELECT
	  DATEPART(hh,order_time) AS hour,
	  COUNT(order_id) AS volume
FROM customer_orders
GROUP BY DATEPART(hh,order_time)
ORDER BY DATEPART(hh,order_time); 
-- Highest volume at 1 pm, 6 pm, 9 pm and 11 pm 
-- Lowest volume at 11 amd and 7 pm 

-- Q10. What was the volume of orders for each day of the week?
SELECT
	  DATENAME(weekday,order_time) AS day,
	  COUNT(order_id) AS volume
FROM customer_orders
GROUP BY DATENAME(weekday,order_time)
ORDER BY COUNT(order_id) DESC;
-- 5 pizzas were ordered both on Sat & Wed 
-- 3 pizzas on Thursday & only 1 pizza on Friday 