CREATE database dannys_dinner;
USE dannys_diner;

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
  
  SHOW TABLES;
  SELECT * FROM members;
  SELECT * FROM MENU;
  SELECT * FROM sales s
  LEFT JOIN menu m
  ON s.product_id = m.product_id;
  
    -- What is the total amount each customer spent at the restaurant?
SELECT s.customer_id, 
SUM(m.price) AS Total_amount
FROM sales s
LEFT JOIN menu m
ON s.product_id = m.product_id
GROUP BY s.customer_id;

-- How many days has each customer visited the restaurant?
SELECT customer_id,
COUNT(DISTINCT order_date) AS Total_visits
FROM sales 
GROUP BY customer_id;

-- What was the first item from the menu purchased by each customer?

SELECT customer_id AS ID, product_name AS first_order FROM(
SELECT s.customer_id, m.product_name,
RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) AS rnk FROM  sales s
LEFT JOIN menu m
ON s.product_id = m.product_id) AS Z
WHERE Z.rnk = 1
; 

-- What is the most purchased item on the menu and how many times was it purchased by all customers?
  
SELECT * FROM 
(SELECT *,RANK() OVER(ORDER BY Most_purchased DESC) AS Ranking
FROM (
    SELECT m.product_name, COUNT(m.product_name) AS Most_purchased
    FROM sales s
    LEFT JOIN menu m ON s.product_id = m.product_id
    GROUP BY m.product_name
) AS SUBQUERY) AS X
WHERE Ranking = 1;
 
 -- How many times it product is purchased by all?

SELECT * FROM 
(SELECT *, DENSE_RANK() OVER(ORDER BY Most_purchased DESC) AS RANKING FROM 
(SELECT m.product_name, s.customer_id,COUNT(m.product_name) AS Most_purchased
FROM sales s
LEFT JOIN menu m ON s.product_id = m.product_id
GROUP BY m.product_name, s.customer_id
ORDER BY Most_purchased DESC) AS X) AS Subquery
WHERE RANKING =1;

-- Which item was the most popular for each customer?

SELECT * FROM
(SELECT * FROM
(SELECT *,  
DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY Total_orders DESC) AS RANKING 
FROM 
(SELECT COUNT(m.product_name) AS Total_orders,m.product_name, s.customer_id
FROM sales s
LEFT JOIN menu m ON s.product_id = m.product_id
GROUP BY s.customer_id,m.product_name) AS Subquery) AS Z 
WHERE RANKING = 1)AS X;

-- Which item was purchased first by the customer after they became a member?


SELECT * FROM
(
SELECT s.customer_id,s.order_date,m.product_id,m.product_name,m2.join_date,
DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) AS RANKING
FROM sales s
LEFT JOIN menu m ON s.product_id = m.product_id
LEFT JOIN members m2
ON m2.customer_id = s.customer_id
WHERE s.order_date >= m2.join_date)
AS Z
WHERE RANKING =1;

-- Which item was purchased just before the customer became a member?

SELECT * FROM
(
SELECT s.customer_id,s.order_date,m.product_id,m.product_name,m2.join_date,
DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date DESC) AS RANKING
FROM sales s
LEFT JOIN menu m ON s.product_id = m.product_id
LEFT JOIN members m2
ON m2.customer_id = s.customer_id
WHERE s.order_date < m2.join_date)
AS Z
WHERE RANKING =1;

        
-- What is the total items and amount spent for each member before they became a member?

SELECT s.customer_id,SUM(m.price) AS AMOUNT_SPENT,
COUNT(DISTINCT m.product_id) AS TOTAL_ITEMS FROM sales s
LEFT JOIN menu m ON s.product_id = m.product_id
LEFT JOIN members m2
ON m2.customer_id = s.customer_id
WHERE s.order_date < m2.join_date
GROUP BY s.customer_id;
 
-- If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

SELECT customer_id,SUM(points_earned) FROM
(SELECT s.customer_id, m.product_id,m.price, 
CASE 
WHEN m.product_name = 'sushi' THEN 20 * m.price
ELSE 10 * m.price 
END AS points_earned
FROM 
sales s
LEFT JOIN 
menu m ON s.product_id = m.product_id) AS X
GROUP BY s.customer_id;




