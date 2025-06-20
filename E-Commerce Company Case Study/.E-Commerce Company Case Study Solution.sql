USE case_study;

# Analyze the Data
DESC customers;
DESC orderdetails;
DESC orders;
DESC products;

# Top  3 Cities with the highest number of customers
SELECT 
	location, 
    COUNT(customer_id) AS number_of_customers
FROM customers
GROUP BY location
ORDER BY number_of_customers DESC
LIMIT 3;

# Customer Segmentation
WITH CTE AS(
	SELECT  
		customer_id, 
		COUNT(order_id) AS total_orders
	FROM orders
	GROUP BY customer_id),
CTE2 AS(
	SELECT *,
		CASE
			WHEN total_orders = 1 THEN 'one-time buyers'
			WHEN total_orders BETWEEN 2 AND 4 THEN 'occasional shoppers'
			WHEN total_orders > 4 THEN 'regular customers'
		END AS customer_segment
	FROM CTE)
SELECT
	customer_segment,
    COUNT(customer_id) AS customer_count
FROM CTE2
GROUP BY customer_segment;

# High-Value Products
# Identify products where the average purchase quantity per order is 2 but with a high total revenue, suggesting premium product trends.
SELECT 
	product_id, 
    AVG(quantity) AS avg_quantity,
    SUM(quantity * price_per_unit) AS total_revenue
FROM orderdetails
GROUP BY product_id
HAVING avg_quantity = 2
ORDER BY total_revenue DESC;

# Category-wise Customer Reach
SELECT 
    category, 
    COUNT(DISTINCT customer_id) AS unique_customers
FROM OrderDetails od
JOIN Orders o 
ON od.order_id = o.order_id
JOIN Products p 
ON od.product_id = p.product_id
GROUP BY category
ORDER BY unique_customers DESC;

# MoM Sales Trend Analysis
WITH CTE AS(
	SELECT
		DATE_FORMAT(order_date, '%Y-%m') AS Month,
		SUM(total_amount) AS Current_Month_Sales
	FROM orders
	GROUP BY Month
	ORDER BY Month)
SELECT *,
       LAG(Current_Month_Sales) OVER() AS Previous_Month_Sales,
	   ROUND(((Current_Month_Sales - (LAG(Current_Month_Sales) OVER()))/(LAG(Current_Month_Sales) OVER())) * 100, 2) AS Percent_Change
FROM CTE;

# MoM Average Order Value Fluctuation
WITH CTE AS(
	SELECT
		DATE_FORMAT(order_date, '%Y-%m') AS Month,
		AVG(total_amount) AS Current_Month_Value
	FROM orders
	GROUP BY Month
	ORDER BY Month)
SELECT *,
       LAG(Current_Month_Value) OVER() AS Previous_Month_Value,
	   ROUND((Current_Month_Value - (LAG(Current_Month_Value) OVER())), 2) AS Change_In_Value
FROM CTE;

# Top selling products by no. of orders
SELECT DISTINCT
		product_id, 
		COUNT(order_id) AS SalesFrequency
FROM OrderDetails
GROUP BY product_id
ORDER BY SalesFrequency DESC
LIMIT 5;	

# Low Engagement Products
SELECT 
    p.Product_id,
    p.Name,
    COUNT(DISTINCT c.customer_id) AS UniqueCustomerCount
FROM OrderDetails od
JOIN Orders o 
ON od.order_id = o.order_id
JOIN Products p 
ON od.product_id = p.product_id
JOIN Customers c 
ON o.customer_id = c.customer_id
GROUP BY p.product_id , p.name
HAVING UniqueCustomerCount< 0.4*(SELECT COUNT(*) as TotalCustomers FROM customers);

# Customer Acquisition Trends    
WITH CTE AS(
	SELECT
		customer_id,
		DATE_FORMAT(MIN(order_date), '%Y-%m') AS first_purchase_month
	FROM orders
	GROUP BY customer_id
	ORDER BY customer_id)
SELECT
	first_purchase_month,
    COUNT(customer_id) AS total_new_customers
FROM CTE
GROUP BY first_purchase_month
ORDER BY first_purchase_month;

# Peak Sales Period Identification
SELECT 
    DATE_FORMAT(order_date, '%Y-%m') AS Month,
    SUM(total_amount) AS TotalSales
FROM orders
GROUP BY Month
ORDER BY TotalSales DESC
LIMIT 3;
	