--- Create Table retail_sales
CREATE TABLE retail_sales
(
		transactions_id	INT PRIMARY KEY,
		sale_date DATE,	
		sale_time TIME,	
		customer_id INT,	
		gender VARCHAR(15),	
		age	INT,
		category VARCHAR(15),	
		quantiy INT, 	
		price_per_unit FLOAT,
		cogs FLOAT,
		total_sale FLOAT
	);

-- check null values
SELECT * FROM retail_sales
WHERE 
transactions_id IS NULL
OR
sale_date IS NULL
OR
sale_time IS NULL
OR
customer_id IS NULL
OR
gender IS NULL
OR
age IS NULL
OR
category IS NULL
OR
quantity IS NULL
OR
price_per_unit IS NULL
OR
cogs IS NULL
OR
total_sale IS NULL;

-- Rename Quantity
ALTER TABLE retail_sales
RENAME COLUMN quantiy TO quantity;

-- Set null values ages with avg age from the table
UPDATE retail_sales
SET age = (SELECT(ROUND(AVG(AGE)))FROM retail_sales)
WHERE age IS NULL;

-- DATA cleaning (Delete the NULL values or quantity, price_per_unit, cogs & total_sale)
DELETE FROM retail_sales
WHERE 
transactions_id IS NULL
OR
sale_date IS NULL
OR
sale_time IS NULL
OR
customer_id IS NULL
OR
gender IS NULL
OR
age IS NULL
OR
category IS NULL
OR
quantity IS NULL
OR
price_per_unit IS NULL
OR
cogs IS NULL
OR
total_sale IS NULL;

-- Data explorartion
-- How much sales we have?
SELECT COUNT(*) as Total_sale FROM retail_sales;

-- How many customers we have? Unique customers only
SELECT COUNT(DISTINCT customer_id) as Total_Customers FROM retail_sales;

-- How many cateogory we have? Unique customers only
SELECT DISTINCT category FROM retail_sales;

-- Data Analysis & Business Key Problems and Answers

-- 1) write a sql qury to retreive all columns for sales made on 2022-11-05
SELECT * FROM retail_sales
WHERE sale_date = '2022-11-05';

-- 2) all transactions where category is clothing and the quantity sold is more than 4 in the month of nov
SELECT *
FROM retail_sales
WHERE 
category = 'Clothing'
AND
TO_CHAR(sale_date,'YYYY-MM') = '2022-11'
AND
quantity >= 4
GROUP BY 1;

-- Find out total sales of each category
SELECT category, 
SUM(total_sale) AS Net_sales,
COUNT(*) as Total_Orders
FROM retail_sales
GROUP BY 1;

-- find the avg age of the customer who purchased from the 'beauty' category
SELECT ROUND(AVG(age)) as avg_age
FROM retail_sales
WHERE category = 'Beauty';

-- FIND ALL TXNS WHERE TOTAL SALE IS GREATER THAN 1000
SELECT * FROM retail_sales
WHERE total_sale > 1000;

--- find out the total number of txns(Transaction_id) made by each gender
SELECT 
category,
gender,
COUNT(*) as total_transaction
FROM retail_sales
GROUP BY category,gender
ORDER BY 1;

--- Calculate the avg sales for each month. Find out the best selling month in each year

SELECT 
Year,
Month,
Total_sales
FROM
(
	SELECT 
	EXTRACT (Year FROM sale_date) as Year,
	EXTRACT (MONTH FROM sale_date) as Month,
	AVG(total_sale) AS Total_sales,
	RANK() OVER ( PARTITION BY EXTRACT (YEAR FROM sale_date) ORDER BY AVG (total_sale) DESC) as rank
	FROM retail_sales
	GROUP BY 1, 2
) as t1
WHERE rank = 1;

-- Write a query to find out the top 5 customers based on the highest total sales

SELECT DISTINCT customer_id,
SUM (total_sale) as Total_Sales_Done_by_customer
FROM retail_sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- Find the Unique customers who purchased items in each category
SELECT 
category,
COUNT(DISTINCT customer_id) as Unique_Customers
FROM retail_sales 
GROUP BY category;

--- create a each shift and number of orders (Eg Morning <= 12, afternoon between 12 - 17, Evening >17)

WITH hourly_sales
as 
(
SELECT *,
	CASE
	WHEN EXTRACT (HOUR FROM sale_time) <= 12 THEN 'Morning'
	WHEN EXTRACT (HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
	ELSE 'Evening'
	END AS shift
FROM retail_sales
)
SELECT
shift,
count(*) as total_orders
FROM hourly_sales
GROUP BY Shift;

