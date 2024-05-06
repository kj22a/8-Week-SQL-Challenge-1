##################################
  SQL challenge #1: DANNY'S DINER 
##################################

Q1.) What is the total amount each customer spent at the restaurant?

SELECT customer_id, SUM(price) AS Total_Spent
FROM dannys_diner.sales
INNER JOIN dannys_diner.menu
ON menu.product_id = sales.product_id
GROUP BY customer_id
LIMIT 10;


Q2.) How many days has each customer visited the restaurant?

SELECT customer_id, COUNT(DISTINCT order_date) AS Number_of_visits
FROM dannys_diner.sales
GROUP BY customer_id
lIMIT 10;


Q3.) What was the first item from the menu purchased by each customer?

SELECT t.customer_id, m.product_name
FROM (
    SELECT DISTINCT order_date, product_id, customer_id,
        DENSE_RANK() OVER (ORDER BY order_date) AS date_rank
    FROM dannys_diner.sales
     ) AS t
INNER JOIN dannys_diner.menu AS m
ON t.product_id = m.product_id
WHERE date_rank = 1;


Q4.) What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT *
FROM (
	SELECT m.product_name, COUNT(s.product_id) AS Number_of_times
	FROM dannys_diner.sales AS S
	INNER JOIN dannys_diner.menu AS m
	ON s.product_id = m.product_id 
	GROUP BY m.product_name 
    ) AS t
ORDER BY Number_of_times DESC
LIMIT 1;


Q5.) Which item was the most popular for each customer?

SELECT *
FROM (
	SELECT s.customer_id, m.product_name, COUNT(m.product_name) AS Number_of_products,
		DENSE_RANK() OVER (
							PARTITION BY s.customer_id
							ORDER BY COUNT(m.product_name) DESC
						  ) AS rk
	FROM dannys_diner.sales AS s
	INNER JOIN dannys_diner.menu AS m
	ON s.product_id = m.product_id
	GROUP BY s.customer_id, m.product_name
	) AS t
WHERE rk = 1
ORDER BY customer_id
LIMIT 10;


Q6.) Which item was purchased first by the customer after they became a member?

SELECT s0.customer_id,  m0.product_name, s0.order_date
FROM (
	SELECT s.customer_id, MIN(s.order_date) AS date_order
	FROM dannys_diner.sales AS s
	INNER JOIN dannys_diner.members as m
	ON s.customer_id = m.customer_id
	WHERE s.order_date >=  m.join_date
	GROUP BY s.customer_id
    ) AS t
INNER JOIN dannys_diner.sales as s0
ON t.date_order = s0.order_date AND t.customer_id = s0.customer_id
INNER JOIN dannys_diner.menu AS m0
ON s0.product_id = m0.product_id
ORDER BY s0.customer_id
lIMIT 10;


Q7.) Which item was purchased just before the customer became a member?

SELECT s0.customer_id,  m0.product_name, s0.order_date
FROM (
	SELECT s.customer_id, MAX(s.order_date) AS date_order
	FROM dannys_diner.sales AS s
	INNER JOIN dannys_diner.members AS m
	ON s.customer_id = m.customer_id
	WHERE s.order_date <  m.join_date
	GROUP BY s.customer_id
    ) AS t
INNER JOIN dannys_diner.sales AS s0
ON t.date_order = s0.order_date AND t.customer_id = s0.customer_id
INNER JOIN dannys_diner.menu AS m0
ON s0.product_id = m0.product_id
ORDER BY s0.customer_id
lIMIT 10;


Q8.) What is the total items and amount spent for each member before they became a member?

SELECT s.customer_id, COUNT(s.customer_id) AS Number_of_order, SUM(men.price) AS Total_spent
FROM dannys_diner.sales AS s
INNER JOIN dannys_diner.members AS m
ON s.customer_id = m.customer_id
INNER JOIN dannys_diner.menu AS men
ON men.product_id = s.product_id
WHERE s.order_date <  m.join_date
GROUP BY s.customer_id
ORDER BY s.customer_id
LIMIT 10;


Q9.) If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

SELECT s.customer_id, SUM(t.points) AS total_points
FROM (
    SELECT *, 
			CASE
			WHEN product_name = 'sushi' THEN price*20
			ELSE price*10
			END AS points
	FROM dannys_diner.menu
	) AS t
INNER JOIN dannys_diner.sales AS s
ON t.product_id = s.product_id
GROUP BY s.customer_id
ORDER BY s.customer_id
LIMIT 10;


Q10.) In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

SELECT customer_id, SUM(points) AS total_points
FROM (
    SELECT m.product_id AS menu_product_id, m.product_name, m.price,
           s.product_id AS sales_product_id, s.customer_id, s.order_date,
           mem.join_date,
           CASE
		   WHEN s.order_date BETWEEN mem.join_date AND DATE_ADD(mem.join_date, INTERVAL 6 DAY)  THEN m.price*20
		   WHEN m.product_name = 'sushi' THEN m.price*20
		   ELSE m.price*10
		   END AS points
    FROM dannys_diner.menu AS m
    INNER JOIN dannys_diner.sales AS s
    ON s.product_id = m.product_id
    INNER JOIN dannys_diner.members AS mem
    ON s.customer_id = mem.customer_id
    WHERE s.order_date < '2021-02-01' AND s.order_date >= mem.join_date
    ORDER BY s.customer_id, s.order_date
    ) AS t
GROUP BY customer_id
ORDER BY customer_id
LIMIT 10;