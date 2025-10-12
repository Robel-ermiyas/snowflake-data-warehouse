-- =================================================================================
-- SILVER LAYER - LEGACY TRANSFORMATION PROCEDURE
-- 
-- Procedure: silver.load_silver
-- Purpose: Full refresh ETL from Bronze to Silver layer
-- Strategy: TRUNCATE and RELOAD (Full Refresh)
-- 
-- This is the legacy implementation that will be replaced by dbt incremental models
-- =================================================================================

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME; 
    DECLARE @rows_affected INT;
    
    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '================================================';
        PRINT 'SILVER LAYER - LEGACY ETL PROCESS';
        PRINT 'Started: ' + CONVERT(NVARCHAR, @batch_start_time, 120);
        PRINT 'Strategy: FULL REFRESH (TRUNCATE & RELOAD)';
        PRINT '================================================';

		PRINT '------------------------------------------------';
		PRINT 'PHASE 1: LOADING CRM TABLES';
		PRINT '------------------------------------------------';

		-- Loading silver.crm_cust_info (Customer Dimension)
        SET @start_time = GETDATE();
		PRINT '>> Processing: silver.crm_cust_info';
		PRINT '   - Operation: TRUNCATE and INSERT';
		PRINT '   - Logic: Deduplication + Data Standardization';
		
		TRUNCATE TABLE silver.crm_cust_info;
		
		INSERT INTO silver.crm_cust_info (
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
			TRIM(cst_first_name) AS cst_firstname,  -- Clean names
			TRIM(cst_last_name) AS cst_lastname,
			CASE 
				WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
				WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
				ELSE 'n/a'
			END AS cst_marital_status, -- Business logic: Code to Description
			CASE 
				WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
				WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
				ELSE 'n/a'
			END AS cst_gndr, -- Business logic: Standardize gender values
			cst_create_date
		FROM (
			SELECT
				*,
				ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
			FROM bronze.crm_cust_info
			WHERE cst_id IS NOT NULL  -- Data quality: Remove records without PK
		) t
		WHERE flag_last = 1; -- Deduplication: Keep most recent record
		
		SET @rows_affected = @@ROWCOUNT;
        SET @end_time = GETDATE();
        PRINT '   - Status: COMPLETED';
        PRINT '   - Rows Loaded: ' + CAST(@rows_affected AS NVARCHAR);
        PRINT '   - Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '   - -------------';

		-- Loading silver.crm_prd_info (Product Dimension)
        SET @start_time = GETDATE();
		PRINT '>> Processing: silver.crm_prd_info';
		PRINT '   - Operation: TRUNCATE and INSERT';
		PRINT '   - Logic: Key Parsing + Date Calculation';
		
		TRUNCATE TABLE silver.crm_prd_info;
		
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
			REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id, -- Transformation: Extract category
			SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,        -- Transformation: Clean product key
			prd_nm,
			ISNULL(prd_cost, 0) AS prd_cost,                       -- Data quality: Handle null costs
			CASE 
				WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
				WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
				WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
				WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
				ELSE 'n/a'
			END AS prd_line, -- Business logic: Code to Description
			CAST(prd_start_dt AS DATE) AS prd_start_dt,
			CAST(
				LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - 1 
				AS DATE
			) AS prd_end_dt -- Business logic: Calculate end dates
		FROM bronze.crm_prd_info;
		
		SET @rows_affected = @@ROWCOUNT;
        SET @end_time = GETDATE();
        PRINT '   - Status: COMPLETED';
        PRINT '   - Rows Loaded: ' + CAST(@rows_affected AS NVARCHAR);
        PRINT '   - Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '   - -------------';

        -- Loading silver.crm_sales_details (Sales Facts)
        SET @start_time = GETDATE();
		PRINT '>> Processing: silver.crm_sales_details';
		PRINT '   - Operation: TRUNCATE and INSERT';
		PRINT '   - Logic: Date Conversion + Amount Validation';
		
		TRUNCATE TABLE silver.crm_sales_details;
		
		INSERT INTO silver.crm_sales_details (
			sls_ord_num,
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
			CASE 
				WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
				ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)  -- Transformation: INT to DATE
			END AS sls_order_dt,
			CASE 
				WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
				ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)   -- Transformation: INT to DATE
			END AS sls_ship_dt,
			CASE 
				WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
				ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)    -- Transformation: INT to DATE
			END AS sls_due_dt,
			CASE 
				WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) 
					THEN sls_quantity * ABS(sls_price)            -- Business logic: Recalculate if invalid
				ELSE sls_sales
			END AS sls_sales,
			sls_quantity,
			CASE 
				WHEN sls_price IS NULL OR sls_price <= 0 
					THEN sls_sales / NULLIF(sls_quantity, 0)     -- Business logic: Derive price
				ELSE sls_price
			END AS sls_price
		FROM bronze.crm_sales_details;
		
		SET @rows_affected = @@ROWCOUNT;
        SET @end_time = GETDATE();
        PRINT '   - Status: COMPLETED';
        PRINT '   - Rows Loaded: ' + CAST(@rows_affected AS NVARCHAR);
        PRINT '   - Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '   - -------------';

		PRINT '------------------------------------------------';
		PRINT 'PHASE 2: LOADING ERP TABLES';
		PRINT '------------------------------------------------';

        -- Loading silver.erp_cust_az12 (ERP Customer Dimension)
        SET @start_time = GETDATE();
		PRINT '>> Processing: silver.erp_cust_az12';
		PRINT '   - Operation: TRUNCATE and INSERT';
		PRINT '   - Logic: ID Cleaning + Data Standardization';
		
		TRUNCATE TABLE silver.erp_cust_az12;
		
		INSERT INTO silver.erp_cust_az12 (
			cid,
			bdate,
			gen
		)
		SELECT
			CASE
				WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid)) -- Transformation: Remove prefix
				ELSE cid
			END AS cid, 
			CASE
				WHEN bdate > GETDATE() THEN NULL                     -- Data quality: Future dates to NULL
				ELSE bdate
			END AS bdate,
			CASE
				WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
				WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
				ELSE 'n/a'
			END AS gen -- Business logic: Standardize gender values
		FROM bronze.erp_cust_az12;
		
		SET @rows_affected = @@ROWCOUNT;
	    SET @end_time = GETDATE();
        PRINT '   - Status: COMPLETED';
        PRINT '   - Rows Loaded: ' + CAST(@rows_affected AS NVARCHAR);
        PRINT '   - Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '   - -------------';

        -- Loading silver.erp_loc_a101 (ERP Location Dimension)
        SET @start_time = GETDATE();
		PRINT '>> Processing: silver.erp_loc_a101';
		PRINT '   - Operation: TRUNCATE and INSERT';
		PRINT '   - Logic: ID Cleaning + Country Standardization';
		
		TRUNCATE TABLE silver.erp_loc_a101;
		
		INSERT INTO silver.erp_loc_a101 (
			cid,
			cntry
		)
		SELECT
			REPLACE(cid, '-', '') AS cid,                          -- Transformation: Remove hyphens
			CASE
				WHEN TRIM(cntry) = 'DE' THEN 'Germany'
				WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
				WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'  -- Data quality: Handle missing values
				ELSE TRIM(cntry)
			END AS cntry -- Business logic: Standardize country names
		FROM bronze.erp_loc_a101;
		
		SET @rows_affected = @@ROWCOUNT;
	    SET @end_time = GETDATE();
        PRINT '   - Status: COMPLETED';
        PRINT '   - Rows Loaded: ' + CAST(@rows_affected AS NVARCHAR);
        PRINT '   - Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '   - -------------';
		
		-- Loading silver.erp_px_cat_g1v2 (ERP Product Categories)
		SET @start_time = GETDATE();
		PRINT '>> Processing: silver.erp_px_cat_g1v2';
		PRINT '   - Operation: TRUNCATE and INSERT';
		PRINT '   - Logic: Direct copy (minimal transformation)';
		
		TRUNCATE TABLE silver.erp_px_cat_g1v2;
		
		INSERT INTO silver.erp_px_cat_g1v2 (
			id,
			cat,
			subcat,
			maintenance
		)
		SELECT
			id,
			cat,
			subcat,
			maintenance
		FROM bronze.erp_px_cat_g1v2;  -- No transformation needed
		
		SET @rows_affected = @@ROWCOUNT;
		SET @end_time = GETDATE();
		PRINT '   - Status: COMPLETED';
        PRINT '   - Rows Loaded: ' + CAST(@rows_affected AS NVARCHAR);
        PRINT '   - Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '   - -------------';

		-- COMPLETION SUMMARY
		SET @batch_end_time = GETDATE();
		PRINT '================================================';
		PRINT 'SILVER LAYER ETL - COMPLETED SUCCESSFULLY';
		PRINT 'Completed: ' + CONVERT(NVARCHAR, @batch_end_time, 120);
        PRINT 'Total Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT 'Strategy: FULL REFRESH (Legacy)';
		PRINT 'Next: Migrate to dbt incremental models';
		PRINT '================================================';
		
	END TRY
	BEGIN CATCH
		PRINT '================================================';
		PRINT 'ERROR: SILVER LAYER ETL FAILED';
		PRINT 'Error Time: ' + CONVERT(NVARCHAR, GETDATE(), 120);
		PRINT 'Error Message: ' + ERROR_MESSAGE();
		PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error State: ' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '================================================';
		THROW;  -- Re-raise error for calling process
	END CATCH
END
GO

PRINT '================================================';
PRINT 'Legacy Silver Layer Procedure Created: silver.load_silver';
PRINT 'Usage: EXEC silver.load_silver;';
PRINT 'Note: This will be replaced by dbt incremental models';
PRINT '================================================';
