CREATE SCHEMA dannys_diner;


CREATE SCHEMA dannys_diner;
SET search_path = dannys_diner;

CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);

INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
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
  
  
  CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
  
  
  
  -- Case Study Questions
-- Each of the following case study questions can be answered using a single SQL statement:


-- What is the total amount each customer spent at the restaurant?

SELECT 
customer_id,
SUM(price) as total_spend
FROM sales as S
INNER JOIN menu as M on S.product_id = M.product_id
GROUP BY customer_id;


-- How many days has each customer visited the restaurant?

SELECT
customer_id,
COUNT(DISTINCT order_date) as days
FROM sales
GROUP BY customer_id;

-- What was the first item from the menu purchased by each customer?
WITH CTE AS (
SELECT 
customer_id,
product_name,
order_date,
RANK() OVER(PARTITION BY customer_id ORDER BY order_date ASC) as rnk,
ROW_NUMBER () OVER(PARTITION BY customer_id ORDER BY order_date ASC) as rn
FROM sales as S
INNER JOIN menu as M on S.product_id = M.product_id
)
SELECT 
customer_id,
product_name
FROM CTE
WHERE rnk = 1;

-- What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT
product_name,
COUNT(order_date) as orders
FROM sales as S
INNER JOIN menu as M on S.product_id = M.product_id
GROUP BY product_name
ORDER BY COUNT(order_date) DESC
LIMIT 1;

-- Which item was the most popular for each customer?

With CTE AS (
SELECT
product_name,
customer_id,
COUNT(order_date) as orders,
RANK() OVER(PARTITION BY customer_id ORDER BY COUNT(order_date) DESC) as rnk,
ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY COUNT(order_date) DESC) as rn
FROM sales as S
INNER JOIN menu as M on S.product_id = M.product_id
GROUP BY product_name,
customer_id
)
SELECT
customer_id,
product_name
FROM CTE
WHERE rnk = 1;


-- Which item was purchased first by the customer after they became a member?
WITH CTE AS (

SELECT 
s.customer_id
, order_date
, join_date
, product_name,
RANK() OVER(PARTITION BY S.customer_id ORDER BY order_date) as rnk,
ROW_NUMBER() OVER(PARTITION BY S.customer_id ORDER BY order_date)  as rn
FROM sales as S
INNER JOIN members as MEN on MEN.customer_id = S.customer_id
INNER JOIN menu as M on S. product_id = M.product_id
WHERE order_date >= join_date
)

SELECT 
customer_id,
product_name
FROM CTE
WHERE rnk = 1;

-- Which item was purchased just before the customer became a member?

WITH CTE AS (

SELECT 
s.customer_id
, order_date
, join_date
, product_name,
RANK() OVER(PARTITION BY S.customer_id ORDER BY order_date DESC) as rnk,
ROW_NUMBER() OVER(PARTITION BY S.customer_id ORDER BY order_date)  as rn
FROM sales as S
INNER JOIN members as MEN on MEN.customer_id = S.customer_id
INNER JOIN menu as M on S. product_id = M.product_id
WHERE order_date >= join_date
)

SELECT 
*
FROM sales;

-- What is the total items and amount spent for each member before they became a member?


SELECT 
S.customer_id,
count(product_name) as total_itens,
sum(price) as amount_spent
FROM sales as S
INNER JOIN members as MEN on MEN.customer_id = S.customer_id
INNER JOIN menu as M on S.product_id = M.product_id
WHERE order_date < join_date
GROUP BY S.customer_id;

-- If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?


SELECT
customer_id, 
SUM(CASE
WHEN product_name= 'sushi' THEN price * 10 * 2
ELSE price * 10
END) as points
FROM MENU AS M
INNER JOIN SALES AS S ON s.product_id = M.product_id
GROUP BY customer_id;


-- In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

SELECT
S.customer_id, 
sum(
CASE
    WHEN order_date BETWEEN MEN.join_date AND DATEADD ('DAY',6, MEN.join_date) THEN  price * 10 * 2
    WHEN product_name = 'sushi' THEN price * 10 * 2
	ELSE price * 10
END 
) as points
FROM MENU AS M
INNER JOIN SALES AS S ON S.product_id = M.product_id
INNER JOIN MEMBERS AS MEN ON MEN.customer_id = S.customer_id
WHERE 
  DATE_TRUNC('month', S.order_date) = '2021-01-01' 
GROUP BY 
  S.customer_id;

