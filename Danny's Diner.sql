CREATE TABLE sales (
customer_id VARCHAR(1),
order_date DATE,
product_id INT);

INSERT INTO sales VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');

CREATE TABLE members (
customer_id VARCHAR(1),
join_date DATE
);

INSERT INTO members VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');

CREATE TABLE menu (
product_id INT,
product_name VARCHAR(5), 
price INT
);

INSERT INTO menu VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');

SELECT * 
FROM dbo.sales

SELECT *
FROM dbo.members

SELECT * 
FROM dbo.menu

 --Q1. What is the total amount each customer spent at restaurant?
 SELECT sal.customer_id,  SUM(men.price) AS spent 
 FROM dbo.sales AS sal
 JOIN dbo.menu AS men
 ON sal.product_id = men.product_id
 GROUP BY sal.customer_id;

 --Q2. How many days has each customer visited the restaurant?
 SELECT customer_id, COUNT(DISTINCT order_date) AS no_of_days
 FROM dbo.sales 
 GROUP BY customer_id

 --Q3. What was the first item from the menu purchased by each customer?
WITH cust_orders_cte AS(
	SELECT
		customer_id,
		order_date,
		product_name,
		row_number() over (partition by customer_id 
		order by order_date) as first_order
	FROM
		sales sal,
		menu men
	WHERE men.product_id = sal.product_id
)

SELECT 
	customer_id,
	product_name
FROM cust_orders_cte
WHERE first_order = 1

--Q4. What is the most purchased item on the menu and how many times was it purchased by all customers?
 SELECT TOP(1)
       product_name, COUNT(men.product_name)     
 FROM dbo.sales AS sal
 JOIN dbo.menu AS men
 ON sal.product_id = men.product_id
 GROUP BY product_name
 ORDER BY COUNT(men.product_name)  DESC

 --Q5. Which item was the most popular for each customer?
 WITH popular_item_cte AS(
	SELECT customer_id,product_name,
		COUNT(sal.product_id) AS popular_count,
		DENSE_RANK() OVER(PARTITION BY customer_id 
		ORDER BY COUNT(sal.product_id) desc) as rank
	FROM sales sal,
		 menu men
	WHERE sal.product_id = men.product_id
	GROUP BY 
		customer_id,
		product_name
)
SELECT customer_id,product_name,popular_count
FROM popular_item_cte
WHERE rank = 1;

--Q6. Which item was first purchased by the customer after they became a member?
WITH member_cte AS(
SELECT sal.customer_id, men.product_name,
DENSE_RANK() OVER (PARTITION BY sal.customer_id ORDER BY sal.order_date) AS rank 
FROM sales AS sal 
JOIN menu AS men 
ON sal.product_id = men.product_id
JOIN members AS mem
ON sal.customer_id = mem.customer_id
WHERE sal.order_date >= mem.join_date)

SELECT *
FROM member_cte
WHERE rank = 1

--Q7. Which item was purchased just before the customer became the member?
WITH member_2_cte AS ( 
SELECT sal.customer_id, men.product_name,
DENSE_RANK() OVER (PARTITION BY sal.customer_id ORDER BY sal.order_date) AS rank
FROM sales AS sal 
JOIN menu AS men
ON sal.product_id = men.product_id
JOIN members AS mem
ON sal.customer_id = mem.customer_id
WHERE sal.order_date < mem.join_date
)
SELECT * 
FROM member_2_cte
WHERE rank = 1


--Q8. What is the total items and amount spent for each member before they became a member?
SELECT sal.customer_id,COUNT(sal.product_id) AS total_items, SUM(men.price) AS total_spent
FROM sales sal
JOIN members mem
ON sal.customer_id = mem.customer_id
JOIN menu men
ON sal.product_id = men.product_id
WHERE sal.order_date < mem.join_date
GROUP BY sal.customer_id

--Q9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
With loyalty_points_cte AS
(SELECT *, CASE WHEN product_id = 1 THEN price*20
                ELSE price*10
	            END AS Points
FROM menu
)
SELECT sal.customer_id, SUM(lp.points) AS Points
FROM sales sal
JOIN loyalty_points_cte lp
ON lp.product_id = sal.product_id
GROUP BY sal.customer_id

--Q10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, 
--not just sushi - how many points do customer A and B have at the end of January?
WITH dates_cte AS(
	SELECT *, 
		DATEADD(DAY, 6, join_date) AS valid_date, 
		EOMONTH('2021-01-1') AS last_date
	FROM members
)
SELECT
	sal.customer_id,
	SUM(CASE
		WHEN sal.product_id = 1 THEN price*20
		WHEN sal.order_date BETWEEN d.join_date AND d.valid_date THEN price*20
		ELSE price*10 
	END) as total_points
FROM dates_cte d,
	 sales sal,
	 menu men
WHERE
	d.customer_id = sal.customer_id
	AND
	men.product_id = sal.product_id
	AND
	sal.order_date <= d.last_date
GROUP BY sal.customer_id;

