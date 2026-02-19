/*
===========================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===========================================================================
Script Purpose:
  This stored procedure load data into the 'Silver' schema from Bronze Layer;
  It performs the following actions:
  - Truncates the Silver tables before loading data
  - Uses the 'INSERT' command to load data from bronze tables to silver tables.

Parameters:
  None.
This stored procedure does not accept any parameters or return any values.

Usage Example:
  EXEC silver.load_silver;
===========================================================================
*/
CREATE OR ALTER PROCEDURE silver.load_silver
AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
    
    BEGIN TRY
        PRINT '============================================';
        PRINT 'Loading Silver Layer';
        PRINT '============================================';

        PRINT '--------------------------------------------';
        PRINT 'Loading CRM Tables';
        PRINT '--------------------------------------------';

        --===============================
        -- Inserting into silver.crm_cust_info
        --===============================
            SET @start_time = GETDATE();
            PRINT '>> Truncating Table: silver.crm_cust_info';
            TRUNCATE TABLE silver.crm_cust_info;
            PRINT '>> Inserting data into: silver.crm_cust_info';
            INSERT INTO silver.crm_cust_info(
            cst_id,
            cst_key,
            cst_firstname,
            cst_lastname,
            cst_marital_status,
            cst_gndr,
            cst_create_date
            )
            SELECT
            cst_id,
            cst_key,
            TRIM(cst_firstname) AS cst_firstname,
            TRIM(cst_lastname) AS cst_lastname,
            CASE 
	             WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
	             WHEN UPPER(TRIM(cst_marital_status))= 'M' THEN 'Married'
               ELSE 'Unknown'
                END AS cst_marital_status,
            CASE 
	             WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
	             WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
               ELSE 'Unknown'
                END AS cst_gndr,
            cst_create_date
            FROM(
            SELECT
            *,
            ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC ) as flag_last
            FROM bronze.crm_cust_info) t 
            WHERE flag_last = 1 ;
            PRINT '>> Rows inserted into silver.crm_cust_info: ' + CAST(@@ROWCOUNT AS VARCHAR);
            SET @end_time = GETDATE();
            PRINT '>> Load Duration: '; + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS nvarchar) + ' seconds';
            PRINT '>> ---------------';
           --======================================
          -- Inserting data into silver.crm_sales_details
          --======================================
          SET @start_time = GETDATE();
          PRINT '>> Truncating Table: silver.crm_sales_details';
          TRUNCATE TABLE silver.crm_sales_details;
          PRINT '>> Inserting data into: silver.crm_sales_details';
          INSERT INTO silver.crm_sales_details(
            sls_ord_num ,
            sls_prd_key,
            sls_cust_id,
            sls_order_dt,
            sls_ship_dt,
            sls_due_dt,
            sls_sales,
            sls_quantity,	
            sls_price
            )
  
          SELECT
          sls_ord_num,
          sls_prd_key,
          sls_cust_id,
          CASE WHEN sls_order_dt = 0 OR len(sls_order_dt) != 8 THEN NULL
            ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
          END AS sls_order_dt,
          CASE WHEN sls_ship_dt = 0 OR len(sls_ship_dt) != 8 THEN NULL
            ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
          END AS sls_ship_dt,
          CASE WHEN sls_due_dt = 0 OR len(sls_due_dt) != 8 THEN NULL
            ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
          END AS sls_due_dt,
          CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
            THEN sls_quantity * ABS(sls_price)
          ELSE sls_sales
          END AS sls_sales,
          sls_quantity,
          CASE WHEN sls_price IS NULL OR sls_price <= 0
            THEN sls_sales / NULLIF(sls_quantity,0)
          ELSE sls_price
          END AS sls_price
          FROM bronze.crm_sales_details;
          PRINT '>> Rows inserted into silver.crm_sales_details: ' + CAST(@@ROWCOUNT AS VARCHAR);
          SET @end_time = GETDATE();
          PRINT '>> Load Duration: '; + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS nvarchar) + ' seconds';
          PRINT '>> ---------------';
        --==========================================
        -- Inserting into silver.crm_prd_info
        --=============================================
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.crm_prd_info';
        TRUNCATE TABLE silver.crm_prd_info;
        PRINT '>> Inserting data into: silver.crm_prd_info';
        WITH CTE_Prd AS (
            SELECT
                prd_id,
                REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
                SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
                prd_nm,
                ISNULL(prd_cost, 0) AS prd_cost,
                CASE UPPER(TRIM(prd_line))
                    WHEN 'M' THEN 'Mountain'
                    WHEN 'R' THEN 'Road'
                    WHEN 'T' THEN 'Touring'
                    WHEN 'S' THEN 'Other Sales'
                    ELSE 'n/a'
                END AS prd_line,
                prd_start_dt
            FROM bronze.crm_prd_info
        )
        INSERT INTO silver.crm_prd_info (
            prd_id,
            cat_id,
            prd_key,
            prd_nm,
            prd_cost,
            prd_line,
            prd_start_dt,
            prd_end_dt
        )
        SELECT
            prd_id,
            cat_id,
            prd_key,
            prd_nm,
            prd_cost,
            prd_line,
            prd_start_dt,
            ISNULL(
                DATEADD(
                    DAY,
                    -1,
                    LEAD(prd_start_dt) OVER (
                        PARTITION BY prd_key
                        ORDER BY prd_start_dt
                    )
                ),
                '9999-12-31'
            ) AS prd_end_dt
        FROM CTE_Prd;
        PRINT '>> Rows inserted into silver.crm_prd_info: ' + CAST(@@ROWCOUNT AS VARCHAR);
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: '; + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS nvarchar) + ' seconds';
        PRINT '>> ---------------';
        --=========================
        -- Inserting into silver.erp_cust_az12
        --=========================
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.erp_cust_az12';
        TRUNCATE TABLE silver.erp_cust_az12;
        PRINT '>> inserting data into: silver.erp_cust_az12';
        INSERT INTO silver.erp_cust_az12(
        cid,
        bdate,
        gen
        )

        SELECT
        CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
	        ELSE cid
        END AS cid,
        CASE WHEN bdate > GETDATE() THEN NULL
	        ELSE bdate
        END AS bdate,
        CASE 
	        WHEN gen IS NULL OR gen = '' THEN 'Unknown' 
	        WHEN gen = 'F' THEN 'Female'
	        WHEN gen = 'M' THEN 'Male'
	        ELSE gen
        END AS  gen
        FROM bronze.erp_cust_az12;
        PRINT '>> Rows inserted into silver.erp_cust_az12: ' + CAST(@@ROWCOUNT AS VARCHAR);
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: '; + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS nvarchar) + ' seconds';
        PRINT '>> ---------------';
        --==============================
        -- Inserting into silver.erp_loc_a101
        --==============================
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.erp_loc_a101';
        TRUNCATE TABLE silver.erp_loc_a101;
        PRINT '>> Inserting data into: silver.erp_loc_a101';
        INSERT INTO silver.erp_loc_a101 (
            cid,
            cntry
        )
        SELECT
            REPLACE(cid, '-', '') AS cid,
            CASE 
                WHEN TRIM(cntry) IS NULL OR TRIM(cntry) = '' THEN 'Unknown' 
                WHEN TRIM(cntry) IN ('US', 'USA', 'United States') THEN 'United States'
                WHEN TRIM(cntry) IN ('UK', 'United Kingdom') THEN 'United Kingdom'
                WHEN TRIM(cntry) IN ('DE', 'Germany') THEN 'Germany'
                ELSE TRIM(cntry)
            END AS cntry
        FROM bronze.erp_loc_a101;
        PRINT '>> Rows inserted into silver.erp_loc_a101: ' + CAST(@@ROWCOUNT AS VARCHAR);
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: '; + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS nvarchar) + ' seconds';
        PRINT '>> ---------------';
        --==========================
        -- Inserting into silver.erp_px_cat_g1v2
        --==========================
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.erp_px_cat_g1v2';
        TRUNCATE TABLE silver.erp_px_cat_g1v2;
        PRINT '>> Inserting data into: silver.erp_px_cat_g1v2';
        INSERT INTO silver.erp_px_cat_g1v2(
        id,
        cat,
        subcat,
        maintenance
        )

        SELECT 
        id,
        TRIM(cat) AS cat,
        TRIM(subcat) AS subcat, 
        TRIM(maintenance) AS maintenance
        FROM bronze.erp_px_cat_g1v2;
        PRINT '>> Rows inserted into silver.erp_px_cat_g1v2: ' + CAST(@@ROWCOUNT AS VARCHAR);
        COMMIT TRANSACTION;
        PRINT '>> Silver layer load completed successfully!';
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: '; + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS nvarchar) + ' seconds';
        PRINT '>> ---------------';

        SER @batch_end_time = GETDATE();
        PRINT '=========================================';
        PRINT 'Loading Silver Layer is Completer';
        PRINT '  - Total load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
        PRINT '=========================================';

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        PRINT '>> ERROR: ' + @ErrorMessage;
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
        PRINT '=========================================';
        PRINT 'ERROR OCCURED DURING LOADING SILVER LAYER';
        PRINT 'Error Message' + @ErrorMessage;
        PRINT 'Error Severity' + @ErrorSeverity;
        PRINT 'Error State' + @ErrorState;
        PRINT '=========================================';
    END CATCH
END;
GO
