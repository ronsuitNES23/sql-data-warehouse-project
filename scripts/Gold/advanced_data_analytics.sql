--==============================
/*
Advanced Data Analytics
We will use:
- Complex Queries
- Window Functions
- CTE
- Subqueries
- Reports
*/
--==============================
USE DataWarehouse;

--==============================
-- Change Over-Time Analysis
-- Analyse how a measure evolves over time
-- Helps track and identify seasonality in your data
--==============================


-- Checking total sales, total customers and total quantity by year

SELECT 
YEAR(order_date) AS order_year,
FORMAT(SUM(sales), 'C') AS total_sales,
COUNT(DISTINCT customer_key) AS total_customers,
SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date);

-- Orders by customers over time

SELECT 
MONTH(order_date) AS order_month,
COUNT(DISTINCT order_number) AS total_orders,
COUNT(DISTINCT customer_key) AS total_customers,
SUM(quantity) AS total_quantity
FROM gold.fact_sales A
WHERE order_date IS NOT NULL
GROUP BY MONTH(order_date)
ORDER BY MONTH(order_date);

-- Looking at the months of the years year

SELECT 
YEAR(order_date) AS order_year,
DATENAME(MONTH, order_date) AS order_month,
FORMAT(SUM(sales), 'C') AS total_sales,
COUNT(DISTINCT order_number) AS total_orders,
COUNT(DISTINCT customer_key) AS total_customers,
SUM(quantity) AS total_quantity
FROM gold.fact_sales A
WHERE order_date IS NOT NULL AND YEAR(order_date) = '2012'
GROUP BY YEAR(order_date), DATENAME(MONTH, order_date), MONTH(order_date)
ORDER BY YEAR(order_date), MONTH(order_date);


--==============================
-- Cumulative Analysis
-- Aggregating the data progessively over time
-- Helps track how or whether the business is growing over time
-- working with a cumulative measure by a Date dimension
--==============================

-- Total Sales per month

SELECT
	DATETRUNC(MONTH, order_date) AS order_date,
	SUM(sales) AS total_sales
	/*FORMAT(SUM(sales), 'C') AS total_sales*/
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY DATETRUNC(MONTH, order_date)
	ORDER BY DATETRUNC(MONTH, order_date)


-- Runnning Total Sales by Year
SELECT
	order_date,
	total_sales,
	SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales
FROM
(
SELECT
	DATETRUNC(MONTH, order_date) AS order_date,
	SUM(sales) AS total_sales
	/*FORMAT(SUM(sales), 'C') AS total_sales*/
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY DATETRUNC(MONTH, order_date)
	) t


-- Moving average sales  by Month
SELECT
	order_date,
	FORMAT(total_sales, 'C') AS total_sales,
	SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales,
	AVG(avg_price) OVER (ORDER BY order_date) AS moving_average_price
FROM
(
SELECT
	DATETRUNC(MONTH, order_date) AS order_date,
	SUM(sales) AS total_sales,
	AVG(price) AS avg_price
	/*FORMAT(SUM(sales), 'C') AS total_sales*/
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY DATETRUNC(MONTH, order_date)
	) t


--==============================
-- Performance Analysis
-- Comparing the current value to a target value
-- Helps measure perceived success and compare performance
-- Looking at Current [Measure] Against Target [Measure]
--==============================

/*
Amalyse the yearly performance of products by compring their sales
to both the average sales performance of the product and the previous year's sales
*/

-- In order to look average sales of a product and previous sales, we  will use CTE

WITH yearly_product_sales AS(
SELECT 
	YEAR(f.order_date) AS order_year,
	p.product_name,
	SUM(f.sales) AS current_sales,
	COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
WHERE order_date IS NOT NULL
GROUP BY 
	YEAR(f.order_date),
	p.product_name
)

SELECT 
	order_year,
	product_name,
	FORMAT(current_sales, 'C') AS total_sales,
	AVG(current_sales) OVER (PARTITION BY product_name) AS average_sales, 
	current_sales - AVG(current_sales) OVER(PARTITION BY product_name) AS diff_in_sales,
	CASE WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) > 0 THEN 'Above Avg'
		 WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) < 0 THEN 'Below Avg'
		ELSE 'Avg'
		END AS indicator,
		LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) AS prev_year,
		current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) AS diff_py,
	CASE WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
		 WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
		ELSE 'No change'
		END AS diff_indicator,
	total_orders
FROM yearly_product_sales
ORDER BY product_name, order_year


--==============================
-- Part to Whole Analysis
-- Analysing how the individual part is compared to the whole
-- Allowing us to understand which category has the greatest impact on the business
-- ([Measure] / Total[Measure]) * 100 By [Dimension]
--==============================

SELECT
p.category,
SUM(f.sales) AS total_sales
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
GROUP BY category;

-- Which categories contribute the most to overall sales?

-- Using CTE's

WITH category_sales AS (
SELECT
p.category,
SUM(f.sales) AS total_sales
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
GROUP BY category
)
SELECT
category,
total_sales,
SUM(total_sales) OVER () AS overall_sales,
CONCAT(ROUND(CAST(total_sales AS FLOAT) / SUM(total_sales) OVER() * 100, 2), '%') AS pc_contribution
FROM category_sales
ORDER BY total_sales DESC
-- Too much reliance on the bike sales, a need might be to diversify and improve sales of accessories and clothing



--==============================
-- Data Segmentation
-- Group the data based on a specific range
-- Helps understand the correlation between two measures
-- ([Measure] By [Measure])
-- Total number of customers by age group
-- CASE WHEN is used for this
--==============================

-- Segment products into cost ranges and count how many products fall into each segment

WITH product_segments As (
SELECT
product_key,
product_name,
cost,
CASE WHEN cost < 100 THEN 'Below 100'
	WHEN cost BETWEEN 100 AND 500 THEN '100-500'
	WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
	ELSE 'Above 1000'
END AS cost_range
FROM gold.dim_products
) 
SELECT
cost_range,
COUNT(product_key) AS total_products
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC

-- Group Customers into three segments based on their spending behavior
-- VIP: at least 12 months of history and spending more than $5,000
-- Regular: at least 12 months of history but spending $5,000 or less
-- New: Lifespan less than 12 months
-- Find the total number of customers by each group

WITH customer_spending AS (
	SELECT
		c.customer_key,
		COUNT(f.order_number) AS total_orders,
		SUM(f.sales) total_spending,
		MIN(order_date) AS first_order,
		MAX(order_date) AS last_order,
		DATEDIFF (MONTH, MIN(order_date), MAX(order_date)) AS lifespan
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_customers c
	ON f.customer_key = c.customer_key
	WHERE c.customer_key IS NOT NULL
	GROUP BY c.customer_key
)
SELECT
	customer_segments,
	COUNT(customer_key) AS total_customers
FROM(
	SELECT
	customer_key,
	CASE 
		WHEN total_spending > 5000 AND lifespan >= 12 THEN 'VIP'
		WHEN total_spending < 5000 AND lifespan >= 12 THEN 'Regular'
		ELSE 'New Customer'
	END AS customer_segments
	FROM customer_spending) t
GROUP BY customer_segments





