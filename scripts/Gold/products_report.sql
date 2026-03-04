
/*
=========================================================================================
Customer Report
=========================================================================================
Purpose:
	- This report consolidates key customer metrics and behaviors

Highlights:
	1. Gathers essential fields such as names, ages and transaction details.
	2. Segments customers into categories (VIP, Regular, New) and age groups
	3. Aggregates customer-level mnetrics:
		- total orders
		- total sales 
		- quantity purchased
		- total products
		-lifespan (in months)
	4. Calculates valuable KPIs:
		- recency (months since last order)
		- average order value
		- average monthly spend

=========================================================================================
*/

--==========================================
-- Steps
--==========================================

CREATE VIEW gold.report_customers AS
WITH base_query AS(
/*----------------------------------------------------------------------------
1. Base Query: This will retrieve the core columns from tables
-----------------------------------------------------------------------------*/
SELECT
	f.order_number,
	f.product_key,
	f.order_date,
	f.sales,
	f.quantity,
	c.customer_key,
	c.customer_number,
	CONCAT(c.first_name,' ', c.last_name) AS customer_name,
	DATEDIFF(YEAR, c.birthdate, GETDATE()) AS age
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
WHERE f.order_date IS NOT NULL
)
/*----------------------------------------------------------------------------
2. Segmenting customers and creating KPI's
-----------------------------------------------------------------------------*/
, customer_aggregation AS(
SELECT 
	customer_key,
	customer_number,
	customer_name,
	age,
	COUNT(DISTINCT order_number) AS total_orders,
	SUM(sales) AS total_sales,
	SUM(quantity) AS total_quantity,
	COUNT(DISTINCT product_key) AS total_products,
	MAX(order_date) AS last_order_date,
	DATEDIFF (MONTH, MIN(order_date), MAX(order_date)) AS lifespan
FROM base_query
GROUP BY 
	customer_key,
	customer_number,
	customer_name,
	age
	)
SELECT 
	customer_key,
	customer_number,
	customer_name,
	age,
	CASE WHEN age < 20 THEN 'Under 20'
		 WHEN age BETWEEN 20 AND 29 THEN '20-29'
		 WHEN age BETWEEN 30 AND 39 THEN '30-39'
		 WHEN age BETWEEN 40 AND 49 THEN '40-49'
		 WHEN age BETWEEN 50 AND 59 THEN '50-59'
		 ELSE '60 and Above'
	END AS age_group,
	CASE 
		WHEN total_sales > 5000 AND lifespan >= 12 THEN 'VIP'
		WHEN total_sales < 5000 AND lifespan >= 12 THEN 'Regular'
		ELSE 'New Customer'
	END AS customer_segments,
	total_orders,
	FORMAT(total_sales, 'C') AS total_sales,
	total_quantity,
	total_products,
	last_order_date,
	DATEDIFF(MONTH, last_order_date, GETDATE()) AS recency,
	lifespan,
	-- Compute Average Order Value (AVO)
	CASE WHEN total_orders = 0 THEN 0
		 ELSE total_sales / total_orders 
	END AS avg_order_value,	
	-- Compute average monthly spend total_sales divided by lifespan
	CASE WHEN lifespan = 0 THEN total_sales
		ELSE total_sales / lifespan
	END AS avg_monthly_spend
FROM customer_aggregation;


SELECT *
FROM gold.report_customers;
