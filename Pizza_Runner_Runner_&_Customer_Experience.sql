-- Runner & Customer Experience 
USE Pizza_runner;

-- Q1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)?

SELECT
      DATEPART(ww,registration_date) AS week,
      COUNT(runner_id) AS runners
FROM runners
GROUP BY DATEPART(ww,registration_date);
-- In the first week of Jan 2021, 1 runner signed up.
-- In the second week of Jan 2021, 2 runners signed up & in the third week of Jan 2021 only 1 runner signed up.

-- Q2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

WITH time_taken_cte AS
(
  SELECT 
    ro.runner_id,
    co.order_id, 
    co.order_time, 
    ro.pickup_time, 
    DATEDIFF(MINUTE, co.order_time, ro.pickup_time) AS pickup_minutes
  FROM customer_orders AS co
  JOIN runner_orders AS ro
    ON co.order_id = ro.order_id
  WHERE ro.distance <> 0
  GROUP BY ro.runner_id,co.order_id, co.order_time, ro.pickup_time
)

SELECT 
  AVG(pickup_minutes) AS avg_pickup_minutes
FROM time_taken_cte; -- It takes 16 mins on avg for each runner to arrive.
	  
-- Q3. Is there any relationship between the number of pizzas and how long the order takes to prepare?

WITH prep_time_cte AS
(
  SELECT 
    co.order_id, 
    co.order_time, 
    ro.pickup_time,
	COUNT(co.order_id) AS no_of_pizzas,
    DATEDIFF(MINUTE, co.order_time, ro.pickup_time) AS prep_time
  FROM customer_orders AS co
  JOIN runner_orders AS ro
    ON co.order_id = ro.order_id
  WHERE ro.distance <> 0
  GROUP BY co.order_id, co.order_time, ro.pickup_time
)
SELECT 
      no_of_pizzas,
	  AVG(prep_time) AS avg_prep_time
FROM prep_time_cte
GROUP BY no_of_pizzas; 
/* The more pizzas there are in an order the more time it takes to prep in total.
Also, it takes about 12 mins on avg to prep a pizza but it takes 18 mins to prep an order with 2 pizzas (9 mins per pizza) 
which means 2 pizzas in a single order is the ultimate efficiency rate.*/

-- Q4. What was the average distance travelled for each customer?

WITH distance_travelled_cte AS
(
  SELECT 
       co.customer_id,
	   ro.distance
  FROM customer_orders AS co
  JOIN runner_orders AS ro
    ON co.order_id = ro.order_id
  WHERE ro.distance <> 0
)
SELECT DISTINCT
      customer_id,
	  AVG(distance) AS distance_travelled
FROM distance_travelled_cte
GROUP BY customer_id;
-- Distance travelled for customer 105 is the highest 25km.

-- Q5. What was the difference between the longest and shortest delivery times for all orders?

WITH max_min_cte AS 
(
  SELECT 
  order_id, duration
  FROM runner_orders
  WHERE duration not like ' '
) 

SELECT 
      MAX(duration) - MIN(duration)
FROM max_min_cte ;
-- The difference between the longest & the shortest delivery times of all orders is 30 mins.

-- Q6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

SELECT 
      runner_id,
	  distance,
	 (distance*60)/duration AS avg_speed 
FROM runner_orders
WHERE distance IS NOT NULL

-- The runners seem to increase their speed from order to order. The increase is not correlated to distance.

-- Q7. What is the successful delivery percentage for each runner?

SELECT 
       runner_id,
       SUM(CASE WHEN cancellation = ' ' OR cancellation IS NULL THEN 1
        ELSE 0 END)/ CAST(COUNT(order_id) AS REAL) * 100 AS success_pct
FROM runner_orders
GROUP BY runner_id; 
-- Runner 1 has 100% successful delivery. No orders were cancelled for runner 1 
-- Runner 2 has 75% successful delivery.
-- Runner 3 has 50% successful delivery


