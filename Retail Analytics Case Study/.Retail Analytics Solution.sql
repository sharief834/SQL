USE project;

# Remove Duplicates
# Write a query to identify the number of duplicates in "sales_transaction" table.
SELECT TransactionID, COUNT(*)
FROM sales_transaction
GROUP BY TransactionID
HAVING COUNT(*) > 1; 

# Create a separate table containing the unique values and 
# remove the the original table from the databases and 
# replace the name of the new table with the original name.
CREATE TABLE temp(
SELECT DISTINCT * FROM sales_transaction);

DROP TABLE IF EXISTS sales_transaction;

ALTER TABLE temp
RENAME TO sales_transaction;

# Fix Incorrect Prices
# Write a query to identify the discrepancies in the price of the same product in "sales_transaction" and "product_inventory" tables. 
# Update those discrepancies to match the price in both the tables.
SELECT DISTINCT 
	s.ProductID, 
    p.ProductID,
    s.Price,
    p.Price
FROM sales_transaction s
JOIN product_inventory p
ON s.ProductID = p.ProductID
WHERE s.Price <> p.Price;

UPDATE sales_transaction s
SET Price = (SELECT Price
			 FROM product_inventory p
             WHERE s.ProductID = p.ProductID)
WHERE ProductID IN (SELECT ProductID
				   FROM product_inventory p
                   WHERE s.Price <> p.Price);
                   
# Fixing Null Values
# Write a SQL query to identify the null values in the `customer_profiles` dataset and replace those by “Unknown”.
SELECT COUNT(*)
FROM customer_profiles
WHERE Location IS NULL OR Location = '';

UPDATE customer_profiles
SET Location = "Unknown"
WHERE Location IS NULL OR Location = '';

# Cleaning Date
# Write a SQL query to clean the DATE column in the `sales_transaction` dataset
UPDATE sales_transaction
SET TransactionDate = STR_TO_DATE(TransactionDate, '%d/%m/%y');

ALTER TABLE sales_transaction
MODIFY COLUMN TransactionDate DATE;

# Total Sales Summary
# Write a SQL query to summarize the total sales and quantities sold per product by the company.
SELECT 
    ProductID,
    SUM(QuantityPurchased) AS TotalUnitsSold,
    ROUND(SUM(QuantityPurchased * Price),2) AS TotalSales
FROM Sales_transaction
GROUP BY ProductID
ORDER BY TotalSales DESC;

# Customer Purchase Frequency
# Write a SQL query to count the number of transactions per customer to understand purchase frequency.
SELECT 
    customerID, 
    COUNT(TransactionID) AS NumberOfTransactions
FROM Sales_transaction
GROUP BY customerID
ORDER BY NumberOfTransactions DESC;

# Product Categories Performance
SELECT 
	Category,
    SUM(QuantityPurchased) AS TotalUnitsSold,
    ROUND(SUM(QuantityPurchased * s.Price), 2) AS TotalSales
FROM sales_transaction s
JOIN product_inventory p 
ON s.ProductID = p.ProductID
GROUP BY Category
ORDER BY TotalSales DESC;

# High Sales Products
SELECT 
    ProductID, 
    ROUND(SUM(QuantityPurchased * Price), 2) AS TotalRevenue
FROM Sales_transaction
GROUP BY ProductID
ORDER BY TotalRevenue DESC
LIMIT 10;
    
# Low Sales Products (QUANTITY)
SELECT 
    ProductID, 
    SUM(QuantityPurchased) AS TotalPurchaseQuantity
FROM Sales_transaction
GROUP BY ProductID
ORDER BY TotalPurchaseQuantity
LIMIT 10;

# Sales Trend
SELECT DISTINCT
	TransactionDate, 
    COUNT(TransactionID) AS Transaction_count,
    SUM(QuantityPurchased) AS TotalUnitsSold,
    ROUND(SUM(QuantityPurchased * Price), 2) AS TotalSales
FROM Sales_transaction
GROUP BY TransactionDate
ORDER BY TransactionDate DESC;

# Growth Rate of Sales
WITH CTE AS(
SELECT 
	MONTH(TransactionDate) AS Month,
    ROUND(SUM(QuantityPurchased * Price), 2) AS TotalSales
FROM sales_transaction
GROUP BY Month
ORDER BY Month)
SELECT 
	TotalSales,
    LAG(TotalSales) OVER() AS Previous_Month_Sales,
    ROUND(((TotalSales - LAG(TotalSales) OVER (ORDER BY Month)) / LAG(TotalSales) OVER (ORDER BY Month)) * 100, 2) AS MOM_Growth_Percentage
FROM CTE;
    
# High Purchase Frequency [number of transactions > 10 and TotalSpent > 1000]
SELECT 
    CustomerID,
    COUNT(TransactionID) AS NumberOfTransactions,
    ROUND(SUM(QuantityPurchased * Price), 2) AS TotalSpent
FROM sales_transaction
GROUP BY CustomerID
HAVING NumberOfTransactions > 10
   AND TotalSpent > 1000
ORDER BY TotalSpent DESC;

# Occasional Customers [number of transactions <= 2]
SELECT 
    CustomerID,
    COUNT(TransactionID) AS NumberOfTransactions,
    SUM(QuantityPurchased * Price) AS TotalSpent
FROM sales_transaction
GROUP BY CustomerID
HAVING NumberOfTransactions <= 2
ORDER BY NumberOfTransactions ASC , TotalSpent DESC;

# Repeat Purchases
# Write a SQL query that describes the total number of purchases made by each customer against each productID to understand the repeat customers in the company.
SELECT 
	CustomerID, 
    ProductID,
    COUNT(TransactionID) AS TimesPurchased
FROM sales_transaction
GROUP BY CustomerID, ProductID
HAVING TimesPurchased > 1
ORDER BY TimesPurchased DESC;

# Loyalty Indicators [duration between the first and the last purchase of the customer]
SELECT 
	CustomerID, 
    MIN(TransactionDate) AS FirstPurchase,
    MAX(TransactionDate) AS LastPurchase,
    DATEDIFF(MAX(TransactionDate), MIN(TransactionDate)) AS DaysBetweenPurchases
FROM sales_transaction
GROUP BY CustomerID
HAVING DaysBetweenPurchases > 0
ORDER BY DaysBetweenPurchases DESC;

 # Customer Segmentation
WITH CTE AS(
SELECT
	CustomerID,
    SUM(QuantityPurchased) Total_Purchase_Quantity
FROM sales_transaction
GROUP BY CustomerID
HAVING Total_Purchase_Quantity > 0),
CTE2 AS(
SELECT *,
	(CASE 
		WHEN Total_Purchase_Quantity BETWEEN 1 AND 10 THEN 'Low'
        WHEN Total_Purchase_Quantity BETWEEN 11 AND 30 THEN 'Mid'
        WHEN Total_Purchase_Quantity > 30 THEN 'High'
	END) AS CustomerSegment
FROM CTE)
SELECT
	CustomerSegment,
    COUNT(CustomerID)
FROM CTE2
GROUP BY CustomerSegment;









