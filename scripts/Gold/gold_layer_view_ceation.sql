/*
Creating master customer information VIEW with the following columns:
silver.crm_cust_info, silver.erp_cust_az12 and silver.erp_LOC_A101
The final table is a dimension so it will be called dim_customer_info and will be created in the gold layer. 
The view will be created using left joins with silver.crm_cust_info as the main table. 
*/
use DataWarehouse;


SELECT *
FROM silver.crm_cust_info;

SELECT *
FROM silver.erp_cust_az12;

SELECT * 
FROM silver.erp_LOC_A101

-- Creating master customer information VIEW with the following columns:	
 

-- View datatypes of columns in crm_cust_info
SELECT
	COLUMN_NAME,
	DATA_TYPE
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'crm_cust_info'
-- View datatypes of columns in erp_cust_az12
SELECT
	COLUMN_NAME,
	DATA_TYPE
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'erp_cust_az12'
-- View datatypes of columns in erp_LOC_A101
SELECT
	COLUMN_NAME,
	DATA_TYPE
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'erp_LOC_A101'

--===============================
-- Create the view for customer information
--===============================

SELECT 	
	cs.cst_id AS customer_id,
	cs.cst_key AS customer_number,
	cs.cst_firstname AS first_name,
	cs.cst_lastname AS last_name,
	cs.cst_marital_status AS marital_status,
	CASE WHEN cs.cst_gndr != 'Unknown' THEN cs.cst_gndr -- CRM is Master for gender
		ELSE COALESCE(er.gen, 'Unknown')
	END AS gender,
	erp.cntry AS country,
	er.bdate AS birthdate,
	cs.cst_create_date AS customer_create_date	
FROM silver.crm_cust_info AS cs
LEFT JOIN silver.erp_cust_az12 AS er
	ON cs.cst_key = er.cid
LEFT JOIN silver.erp_LOC_A101 AS erp
	ON cs.cst_key = erp.CID
WHERE cs.cst_id IS NOT NULL;

--===============================
-- Checking for duplicates in the view
-- Expecting no duplicates as cst_id is the primary key in the source table
--===============================
SELECT cst_id, count(*) FROM 
	(SELECT cs.cst_id,
	cs.cst_key,
	cs.cst_firstname,
	cs.cst_lastname,
	cs.cst_marital_status,
	CASE WHEN cs.cst_gndr != 'Unknown' THEN cs.cst_gndr -- CRM is Master for gender
		ELSE COALESCE(er.gen, 'Unknown')
	END AS gender,
	erp.cntry,
	er.bdate,
	cs.cst_create_date	
FROM silver.crm_cust_info AS cs
LEFT JOIN silver.erp_cust_az12 AS er
	ON cs.cst_key = er.cid
LEFT JOIN silver.erp_LOC_A101 AS erp
	ON cs.cst_key = erp.CID
WHERE cs.cst_id IS NOT NULL
) AS t GROUP BY cst_id
HAVING COUNT(*) > 1;

--===============================
-- Looking at both gender columns to check for consistency
-- Expecting some differences as CRM is Master
--===============================
SELECT DISTINCT
	cs.cst_gndr,
	er.gen,
	CASE WHEN cs.cst_gndr != 'Unknown' THEN cs.cst_gndr -- CRM is Master for gender
		ELSE COALESCE(er.gen, 'Unknown')
	END AS new_gender
FROM silver.crm_cust_info AS cs
LEFT JOIN silver.erp_cust_az12 AS er
	ON cs.cst_key = er.cid
LEFT JOIN silver.erp_LOC_A101 AS erp
	ON cs.cst_key = erp.CID
WHERE cs.cst_id IS NOT NULL
ORDER BY 1,2;

--===============================
-- Using proper names for columns
--===============================
SELECT 	
	cs.cst_id AS customer_id,
	cs.cst_key AS customer_number,
	cs.cst_firstname AS first_name,
	cs.cst_lastname AS last_name,
	cs.cst_marital_status AS marital_status,
	CASE WHEN cs.cst_gndr != 'Unknown' THEN cs.cst_gndr -- CRM is Master for gender
		ELSE COALESCE(er.gen, 'Unknown')
	END AS gender,
	erp.cntry AS country,
	er.bdate AS birthdate,
	cs.cst_create_date AS customer_create_date	
FROM silver.crm_cust_info AS cs
LEFT JOIN silver.erp_cust_az12 AS er
	ON cs.cst_key = er.cid
LEFT JOIN silver.erp_LOC_A101 AS erp
	ON cs.cst_key = erp.CID
WHERE cs.cst_id IS NOT NULL;

--===============================
/*Generatinng a Surrogate Key for the dimension. 
This a system- generated unique identifier for each record in the dimension 
and is not derived from any source system.
It can be generated either by DDL-based generation or Query-based using Window function (Row_Number)
*/
--===============================

--ROW_NUMBER()
SELECT
	ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,
	cs.cst_id AS customer_id,
	cs.cst_key AS customer_number,
	cs.cst_firstname AS first_name,
	cs.cst_lastname AS last_name,
	cs.cst_marital_status AS marital_status,
	CASE WHEN cs.cst_gndr != 'Unknown' THEN cs.cst_gndr -- CRM is Master for gender
		ELSE COALESCE(er.gen, 'Unknown')
	END AS gender,
	erp.cntry AS country,
	er.bdate AS birthdate,
	cs.cst_create_date AS customer_create_date	
FROM silver.crm_cust_info AS cs
LEFT JOIN silver.erp_cust_az12 AS er
	ON cs.cst_key = er.cid
LEFT JOIN silver.erp_LOC_A101 AS erp
	ON cs.cst_key = erp.CID
WHERE cs.cst_id IS NOT NULL;

--==================================
-- Creating the View Now
--==================================

CREATE VIEW gold.dim_customers AS (
SELECT
	ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,
	cs.cst_id AS customer_id,
	cs.cst_key AS customer_number,
	cs.cst_firstname AS first_name,
	cs.cst_lastname AS last_name,
	cs.cst_marital_status AS marital_status,
	CASE WHEN cs.cst_gndr != 'Unknown' THEN cs.cst_gndr -- CRM is Master for gender
		ELSE COALESCE(er.gen, 'Unknown')
	END AS gender,
	erp.cntry AS country,
	er.bdate AS birthdate,
	cs.cst_create_date AS customer_create_date	
FROM silver.crm_cust_info AS cs
LEFT JOIN silver.erp_cust_az12 AS er
	ON cs.cst_key = er.cid
LEFT JOIN silver.erp_LOC_A101 AS erp
	ON cs.cst_key = erp.CID
WHERE cs.cst_id IS NOT NULL
)

/*
Creating master product information VIEW with the following columns:
silver._prd_info and erp_px_cat_g1v2 
The final table is a dimension so it will be called gold.dim_products and will be created in the gold layer. 
The view will be created using left joins with silver._prd_info as the main table. 
*/

--==================================
-- Looking at the Two tables
--==================================

SELECT *
FROM silver.crm_prd_info;

SELECT *
FROM silver.erp_px_cat_g1v2;


--=================================
-- Joining the tables
--=================================

SELECT 
    pn.prd_id,
    pn.cat_id,
    pn.prd_key,
    pn.prd_nm,
    pn.prd_cost,
    pn.prd_line,
    pc.cat,
    pc.subcat,
    pc.maintenance,
    pn.prd_start_dt
FROM silver.crm_prd_info AS pn
LEFT JOIN silver.erp_px_cat_g1v2 AS pc
ON pn.cat_id = pc.id
WHERE prd_end_dt = '9999-12-31' -- Filter out all historic data


--===============================
-- Checking for duplicates in via prd_key
--===============================

SELECT prd_key, COUNT(*) FROM
(
SELECT 
    pn.prd_id,
    pn.cat_id,
    pn.prd_key,
    pn.prd_nm,
    pn.prd_cost,
    pn.prd_line,
    pc.cat,
    pc.subcat,
    pc.maintenance,
    pn.prd_start_dt
FROM silver.crm_prd_info AS pn
LEFT JOIN silver.erp_px_cat_g1v2 AS pc
ON pn.cat_id = pc.id
WHERE prd_end_dt = '9999-12-31' -- Filter out all historic data
) AS t GROUP BY prd_key
HAVING COUNT(*) > 1;

--=============================
-- Sorting the products into logical groups to improve readability
--=============================

SELECT 
    pn.prd_id,
    pn.prd_key,
    pn.prd_nm,
    pn.prd_line, 
    pn.cat_id,
    pc.cat,
    pc.subcat,
    pc.maintenance,
    pn.prd_cost,      
    pn.prd_start_dt
FROM silver.crm_prd_info AS pn
LEFT JOIN silver.erp_px_cat_g1v2 AS pc
ON pn.cat_id = pc.id
WHERE prd_end_dt = '9999-12-31' -- Filter out all historic dat

--==============================
-- Giving the columns friendly, meaningful names
--==============================

SELECT 
    pn.prd_id AS product_id,
    pn.prd_key AS product_number,
    pn.prd_nm AS product_name,
    pn.prd_line AS product_line, 
    pn.cat_id AS category_id,
    pc.cat AS category,
    pc.subcat AS category,
    pc.maintenance,
    pn.prd_cost AS cost,      
    pn.prd_start_dt AS start_date
FROM silver.crm_prd_info AS pn
LEFT JOIN silver.erp_px_cat_g1v2 AS pc
ON pn.cat_id = pc.id
WHERE prd_end_dt = '9999-12-31' -- Filter out all historic data

--===============================
/*Generatinng a Surrogate Key for the dimension. 
This a system- generated unique identifier for each record in the dimension 
and is not derived from any source system.
It can be generated either by DDL-based generation or Query-based using Window function (Row_Number)
*/
-- And then the VIEW
--===============================

SELECT 
    ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key, -- surrogate key
    pn.prd_id AS product_id,
    pn.prd_key AS product_number,
    pn.prd_nm AS product_name,
    pn.prd_line AS product_line, 
    pn.cat_id AS category_id,
    pc.cat AS category,
    pc.subcat AS subcategory,
    pc.maintenance,
    pn.prd_cost AS cost,      
    pn.prd_start_dt AS start_date
FROM silver.crm_prd_info AS pn
LEFT JOIN silver.erp_px_cat_g1v2 AS pc
ON pn.cat_id = pc.id
WHERE prd_end_dt = '9999-12-31' -- Filter out all historic data

--=======================================
-- Creating the View
--=======================================
CREATE VIEW gold.dim_products AS 
(
SELECT 
    ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key, -- surrogate key
    pn.prd_id AS product_id,
    pn.prd_key AS product_number,
    pn.prd_nm AS product_name,
    pn.prd_line AS product_line, 
    pn.cat_id AS category_id,
    pc.cat AS category,
    pc.subcat AS subcategory,
    pc.maintenance,
    pn.prd_cost AS cost,      
    pn.prd_start_dt AS start_date
FROM silver.crm_prd_info AS pn
LEFT JOIN silver.erp_px_cat_g1v2 AS pc
ON pn.cat_id = pc.id
WHERE prd_end_dt = '9999-12-31'
);


/*
Creating master sales information VIEW with the following columns:
silver.crm_sales_details and all other tables
The final table is a FACT so it will be called gold.fact_sales and will be created in the gold layer. 
The view will be created using left joins with silver.crm_sales_details as the main table. 
*/

SELECT *
FROM silver.crm_sales_details

SELECT
	sd.sls_ord_num,
	pr.product_key,
	sd.sls_cust_id,
	sd.sls_order_dt,
	sd.sls_ship_dt,
	sd.sls_due_dt,
	sd.sls_sales,
	sd.sls_quantity,
	sd.sls_price,
FROM silver.crm_sales_details AS sd
LEFT JOIN gold.dim_products pr
ON sd.sls_prd_key = pr.product_number

--==================================
/*
Using data LOOKUP, we will join the dimensions to the Fact Table.
Connecting them via the surrogate keys created for each dimension View
*/
--==================================
SELECT
	sd.sls_ord_num AS order_number,
	pr.product_key,
	cr.customer_key,
	sd.sls_order_dt AS order_date,
	sd.sls_ship_dt AS ship_date,
	sd.sls_due_dt AS due_date,
	sd.sls_sales AS sales,
	sd.sls_quantity AS quantity,
	sd.sls_price AS price
FROM silver.crm_sales_details AS sd
LEFT JOIN gold.dim_products pr
ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cr
ON sd.sls_cust_id = cr.customer_id

--=================================
-- Creating the VIEW
--=================================

CREATE VIEW gold.fact_sales AS 
(
SELECT
	sd.sls_ord_num AS order_number,
	pr.product_key,
	cr.customer_key,
	sd.sls_order_dt AS order_date,
	sd.sls_ship_dt AS ship_date,
	sd.sls_due_dt AS due_date,
	sd.sls_sales AS sales,
	sd.sls_quantity AS quantity,
	sd.sls_price AS price
FROM silver.crm_sales_details AS sd
LEFT JOIN gold.dim_products pr
ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cr
ON sd.sls_cust_id = cr.customer_id
)
