/*
=====================================================
-- Creating Tables for the Silver layer. 
* All names names must start with the sourcve system name, and the table names must 
match their original names without renaming.
* <sourcesystem>_<entity>
	* <sourcesystem>: Nmae of the source system (e.g crm, erp)
	* <entity>: Extract table name from the source system
	* Exmaple: crm_customer_info - Customer information form the CRM system.
=======================================================
*/

-- for crm

-- for crm_cust_info

IF OBJECT_ID ('silver.crm_cust_info', 'U') IS NOT NULL
DROP TABLE silver.crm_cust_info;
GO
CREATE TABLE silver.crm_cust_info (
cst_id	INT,
cst_key	NVARCHAR(50),
cst_firstname NVARCHAR(50),
cst_lastname	NVARCHAR(50),
cst_marital_status	NVARCHAR(50),
cst_gndr NVARCHAR(50),
cst_create_date DATE,
dwl_create_date DATETIME2 DEFAULT GETDATE()
);

-- for prd_info

IF OBJECT_ID ('silver.crm_prd_info', 'U') IS NOT NULL
DROP TABLE silver.crm_prd_info;
GO
CREATE TABLE silver.crm_prd_info(
prd_id INT,
cat_id NVARCHAR(50),
prd_key NVARCHAR(50),
prd_nm NVARCHAR(50),
prd_cost INT,
prd_line NVARCHAR(50),
prd_start_dt DATE,
prd_end_dt DATE,
dwl_create_date DATETIME2 DEFAULT GETDATE()
);
GO

-- for sales_details

IF OBJECT_ID ('silver.crm_sales_details', 'U') IS NOT NULL
DROP TABLE silver.crm_sales_details;
GO

CREATE TABLE silver.crm_sales_details (
    sls_ord_num   NVARCHAR(50) ,
    sls_prd_key   NVARCHAR(50),
    sls_cust_id   INT,
    sls_order_dt  DATE,
    sls_ship_dt   DATE,
    sls_due_dt    DATE,
    sls_sales     INT,
    sls_quantity  INT,	
    sls_price     INT,
    dwl_create_date DATETIME2 DEFAULT GETDATE()
);
GO


-- creating table for erp

-- For CUST_AZ12
IF OBJECT_ID ('silver.erp_CUST_AZ12', 'U') IS NOT NULL
DROP TABLE silver.erp_CUST_AZ12;
GO

CREATE TABLE silver.erp_cust_az12 (
    cid   NVARCHAR(50),
    bdate DATE,
    gen   NVARCHAR(50),
    dwl_create_date DATETIME2 DEFAULT GETDATE()
);
GO

-- For LOC_A101
IF OBJECT_ID ('silver.erp_LOC_A101', 'U') IS NOT NULL
DROP TABLE silver.erp_LOC_A101;
GO
CREATE TABLE silver.erp_LOC_A101(
CID	NVARCHAR(50), 
CNTRY NVARCHAR(50),
dwl_create_date DATETIME2 DEFAULT GETDATE()
);
GO

-- For PX_CAT_G1V2
IF OBJECT_ID ('silver.erp_px_cat_g1v2', 'U') IS NOT NULL
DROP TABLE silver.erp_px_cat_g1v2;
GO

CREATE TABLE silver.erp_px_cat_g1v2 (
    id          NVARCHAR(50),
    cat         NVARCHAR(50),
    subcat      NVARCHAR(50),
    maintenance NVARCHAR(50),
    dwl_create_date DATETIME2 DEFAULT GETDATE()
);
GO
