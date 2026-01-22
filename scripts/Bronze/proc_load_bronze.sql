/*
===========================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronz)
===========================================================================
Script Purpose:
  This stored procedure load data into the 'bronze' schema from external CSV file;
  It performs the following actions:
  - Truncates the bronze tables before loading data
  - Uses the 'BULK INSERT' command to load data from csv Files to bronze tables.

Parameters:
  None.
This stored procedure does not accept any parameters or return any values.

Usage Example:
  EXEC bronze.load_bronze;
===========================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze 
AS
BEGIN 
	SET NOCOUNT ON;
		DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
		BEGIN TRY
			SET @batch_start_time = GETDATE();
			PRINT '==================================================';
			PRINT 'Loading data into Bronze Layer Tables';
			PRINT '==================================================';

			PRINT '---------------------------------------------------';
			PRINT 'Loading CRM Source Tables';	
			PRINT '---------------------------------------------------';

			-- for cust_info
			SET @start_time = GETDATE();
			PRINT '>> Truncating and Loading bronze.crm_cust_info';
			TRUNCATE TABLE bronze.crm_cust_info

			PRINT '.. Inserting data into bronze.crm_cust_info';
			BULK INSERT bronze.crm_cust_info
			FROM 'C:\Users\rekva\Downloads\datawarehouse project files\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
			WITH(
				FIRSTROW = 2,
				FIELDTERMINATOR = ',',
				TABLOCK 
			);
			SET @end_time = GETDATE();
			PRINT '.. Time taken to load bronze.crm_cust_info: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' seconds';
			PRINT '---------------------------------------------------';

			-- FOR prd_info
			SET @start_time = GETDATE();
			PRINT '>> Truncating and Loading bronze.crm_prd_info';
			TRUNCATE TABLE bronze.crm_prd_info

			PRINT '.. Inserting data into bronze.crm_prd_info';
			BULK INSERT bronze.crm_prd_info
			FROM 'C:\Users\rekva\Downloads\datawarehouse project files\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
			WITH (
				FIRSTROW = 2,
				FIELDTERMINATOR = ',',
				TABLOCK 
			);
			SET @end_time = GETDATE();
			PRINT '.. Time taken to load bronze.crm_prd_info: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' seconds';
			PRINT '---------------------------------------------------';

			-- FOR sales_details
			SET @start_time = GETDATE();
			PRINT '>> Truncating and Loading bronze.crm_sales_details';
			TRUNCATE TABLE bronze.crm_sales_details

			PRINT '.. Inserting data into bronze.crm_sales_details';
			BULK INSERT bronze.crm_sales_details
			FROM 'C:\Users\rekva\Downloads\datawarehouse project files\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
			WITH (
				FIRSTROW = 2,
				FIELDTERMINATOR = ',',
				TABLOCK 
			);
			SET @end_time = GETDATE();
			PRINT '.. Time taken to load bronze.crm_sales_details: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' seconds';
			PRINT '---------------------------------------------------';

			PRINT '--------------------------------------------------';
			PRINT 'Loading ERP Source Tables';
			PRINT '--------------------------------------------------';

			-- for cust_az12
			SET @start_time = GETDATE();
			PRINT '>> Truncating and Loading bronze.erp_cust_az12';
			TRUNCATE TABLE bronze.erp_cust_az12

			PRINT '.. Inserting data into bronze.erp_cust_az12';
			BULK INSERT bronze.erp_cust_az12
			FROM 'C:\Users\rekva\Downloads\datawarehouse project files\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
			WITH (
				FIRSTROW = 2,
				FIELDTERMINATOR = ',',
				TABLOCK 
			);
			SET @end_time = GETDATE();
			PRINT '.. Time taken to load bronze.erp_cust_az12: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' seconds';
			PRINT '--------------------------------------------------';
			
			-- for loc_a101	
			SET @start_time = GETDATE();
			PRINT '>> Truncating and Loading bronze.erp_loc_a101';
			TRUNCATE TABLE bronze.erp_loc_a101

			PRINT '.. Inserting data into bronze.erp_loc_a101';
			BULK INSERT bronze.erp_loc_a101
			FROM 'C:\Users\rekva\Downloads\datawarehouse project files\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
			WITH (
				FIRSTROW = 2,
				FIELDTERMINATOR = ',',
				TABLOCK 
			);
			SET @end_time = GETDATE();
			PRINT '.. Time taken to load bronze.erp_loc_a101: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' seconds';
			PRINT '--------------------------------------------------';

			-- for px_cat_g1v2
			SET @start_time = GETDATE();
			PRINT '>> Truncating and Loading bronze.erp_px_cat_g1v2';
			TRUNCATE TABLE bronze.erp_px_cat_g1v2

			PRINT '.. Inserting data into bronze.erp_px_cat_g1v2';
			BULK INSERT bronze.erp_px_cat_g1v2
			FROM 'C:\Users\rekva\Downloads\datawarehouse project files\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
			WITH (
				FIRSTROW = 2,
				FIELDTERMINATOR = ',',
				TABLOCK 
			);
			SET @end_time = GETDATE();
			PRINT '.. Time taken to load bronze.erp_px_cat_g1v2: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' seconds';
			PRINT '-----------------------------------------------------';
			

			SET @batch_end_time = GETDATE();

			PRINT '==================================================';
			PRINT 'Data loading into Bronze Layer Tables completed successfully';
			PRINT 'Total Time taken to load data into Bronze Layer Tables: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR(10)) + ' seconds';
			PRINT '==================================================';

	END TRY
		BEGIN CATCH
			PRINT '==================================================';
			PRINT 'Error occurred while loading data into Bronze Layer Tables';
			PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR(10));
			PRINT 'Error Message: ' + ERROR_MESSAGE();
			PRINT '==================================================';
		END CATCH
END;
GO
