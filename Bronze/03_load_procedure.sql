-- =================================================================================
-- BRONZE LAYER DATA INGESTION PIPELINE
-- 
-- Purpose: Load raw data from S3 into Snowflake bronze layer tables
-- Description: This pipeline extracts CSV files from S3 buckets and loads them
--              into staging tables without transformation (ELT approach)
-- Architecture: S3 → Snowflake Stages → Bronze Tables (Raw Data Layer)
-- =================================================================================

-- =================================================================================
-- MAIN DATA LOADING PROCEDURE: load_bronze_layer
-- 
-- Purpose: Orchestrates the complete bronze layer data ingestion process
-- Features: 
--   - Idempotent design (safe for multiple executions)
--   - Comprehensive error handling and logging
--   - Performance monitoring with timing metrics
--   - Pattern-based file matching for flexible source management
-- =================================================================================
CREATE OR REPLACE PROCEDURE bronze.load_bronze_layer()
RETURNS STRING
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
DECLARE
    load_start_time TIMESTAMP;      -- Track procedure start time for performance monitoring
    procedure_result STRING;        -- Final result message to return to caller
    rows_loaded INTEGER DEFAULT 0;  -- Track rows loaded for each table (for logging)
    files_processed INTEGER DEFAULT 0; -- Count of successfully processed tables
    error_message STRING;           -- Capture error details for exception handling
    result RESULTSET;               -- Handle query results for row counting
BEGIN
    -- =============================================================================
    -- INITIALIZATION PHASE
    -- =============================================================================
    load_start_time := CURRENT_TIMESTAMP();  -- Record start time for performance tracking
    
    -- Log procedure initiation for audit trail
    SYSTEM$LOG('INFO', 'Starting bronze layer load procedure - loading raw data from S3');

    -- =============================================================================
    -- CRM DATA LOADING PHASE
    -- Loads Customer Relationship Management data from CRM S3 bucket
    -- =============================================================================
    
    -- TABLE: CRM Customer Information
    -- Source: Customer master data from CRM system
    BEGIN
        TRUNCATE TABLE bronze.crm_cust_info;  -- Clear existing data for idempotent reload
        COPY INTO bronze.crm_cust_info        -- Load data from S3 stage to table
        FROM @bronze.crm_stage                -- Use CRM external stage
        PATTERN = '.*cust_info.*\\.csv'       -- Match files containing 'cust_info' in name
        ON_ERROR = 'CONTINUE';                -- Skip problematic rows but continue processing
        
        -- Calculate and log rows loaded for monitoring
        LET c1 CURSOR FOR SELECT COUNT(*) AS row_count FROM bronze.crm_cust_info;
        OPEN c1;
        FETCH c1 INTO rows_loaded;
        CLOSE c1;
        
        SYSTEM$LOG('INFO', 'Loaded ' || rows_loaded || ' rows into crm_cust_info');
        files_processed := files_processed + 1;  -- Increment success counter
    EXCEPTION
        WHEN OTHER THEN
            error_message := 'Failed to load crm_cust_info: ' || SQLERRM;
            SYSTEM$LOG('ERROR', error_message);  -- Log detailed error
            RAISE;  -- Re-raise exception to halt procedure on critical failures
    END;
    
    -- TABLE: CRM Product Information  
    -- Source: Product catalog and master data from CRM system
    BEGIN
        TRUNCATE TABLE bronze.crm_prd_info;   -- Clear existing data
        COPY INTO bronze.crm_prd_info         -- Load product data
        FROM @bronze.crm_stage                -- Use CRM external stage
        PATTERN = '.*prd_info.*\\.csv'        -- Match product information files
        ON_ERROR = 'CONTINUE';                -- Tolerant error handling
        
        -- Count and log loaded rows
        LET c2 CURSOR FOR SELECT COUNT(*) AS row_count FROM bronze.crm_prd_info;
        OPEN c2;
        FETCH c2 INTO rows_loaded;
        CLOSE c2;
        
        SYSTEM$LOG('INFO', 'Loaded ' || rows_loaded || ' rows into crm_prd_info');
        files_processed := files_processed + 1;
    EXCEPTION
        WHEN OTHER THEN
            error_message := 'Failed to load crm_prd_info: ' || SQLERRM;
            SYSTEM$LOG('ERROR', error_message);
            RAISE;
    END;
    
    -- TABLE: CRM Sales Details
    -- Source: Sales transactions and order details from CRM system
    BEGIN
        TRUNCATE TABLE bronze.crm_sales_details;  -- Clear existing sales data
        COPY INTO bronze.crm_sales_details        -- Load sales transaction data
        FROM @bronze.crm_stage                    -- Use CRM external stage
        PATTERN = '.*sales_details.*\\.csv'       -- Match sales detail files
        ON_ERROR = 'CONTINUE';                    -- Continue on non-fatal errors
        
        -- Track row count for monitoring
        LET c3 CURSOR FOR SELECT COUNT(*) AS row_count FROM bronze.crm_sales_details;
        OPEN c3;
        FETCH c3 INTO rows_loaded;
        CLOSE c3;
        
        SYSTEM$LOG('INFO', 'Loaded ' || rows_loaded || ' rows into crm_sales_details');
        files_processed := files_processed + 1;
    EXCEPTION
        WHEN OTHER THEN
            error_message := 'Failed to load crm_sales_details: ' || SQLERRM;
            SYSTEM$LOG('ERROR', error_message);
            RAISE;
    END;
    
    -- =============================================================================
    -- ERP DATA LOADING PHASE
    -- Loads Enterprise Resource Planning data from ERP S3 bucket
    -- =============================================================================
    
    -- TABLE: ERP Customer Data (AZ12 System)
    -- Source: Customer master from ERP system (different schema than CRM)
    BEGIN
        TRUNCATE TABLE bronze.erp_cust_az12;  -- Clear existing ERP customer data
        COPY INTO bronze.erp_cust_az12        -- Load ERP customer information
        FROM @bronze.erp_stage                -- Use ERP external stage
        PATTERN = '.*CUST_AZ12.*\\.csv'       -- Match ERP customer files
        ON_ERROR = 'CONTINUE';                -- Error tolerance for data variances
        
        -- Monitor load performance
        LET c4 CURSOR FOR SELECT COUNT(*) AS row_count FROM bronze.erp_cust_az12;
        OPEN c4;
        FETCH c4 INTO rows_loaded;
        CLOSE c4;
        
        SYSTEM$LOG('INFO', 'Loaded ' || rows_loaded || ' rows into erp_cust_az12');
        files_processed := files_processed + 1;
    EXCEPTION
        WHEN OTHER THEN
            error_message := 'Failed to load erp_cust_az12: ' || SQLERRM;
            SYSTEM$LOG('ERROR', error_message);
            RAISE;
    END;
    
    -- TABLE: ERP Location Data (A101 System)
    -- Source: Customer geographic and location data from ERP
    BEGIN
        TRUNCATE TABLE bronze.erp_loc_a101;   -- Clear existing location data
        COPY INTO bronze.erp_loc_a101         -- Load customer location information
        FROM @bronze.erp_stage                -- Use ERP external stage
        PATTERN = '.*LOC_A101.*\\.csv'        -- Match location data files
        ON_ERROR = 'CONTINUE';                -- Handle data quality issues gracefully
        
        -- Track loading metrics
        LET c5 CURSOR FOR SELECT COUNT(*) AS row_count FROM bronze.erp_loc_a101;
        OPEN c5;
        FETCH c5 INTO rows_loaded;
        CLOSE c5;
        
        SYSTEM$LOG('INFO', 'Loaded ' || rows_loaded || ' rows into erp_loc_a101');
        files_processed := files_processed + 1;
    EXCEPTION
        WHEN OTHER THEN
            error_message := 'Failed to load erp_loc_a101: ' || SQLERRM;
            SYSTEM$LOG('ERROR', error_message);
            RAISE;
    END;
    
    -- TABLE: ERP Product Category Data (G1V2 System)
    -- Source: Product categorization and hierarchy from ERP
    BEGIN
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;  -- Clear existing category data
        COPY INTO bronze.erp_px_cat_g1v2        -- Load product category information
        FROM @bronze.erp_stage                  -- Use ERP external stage
        PATTERN = '.*PX_CAT_G1V2.*\\.csv'       -- Match product category files
        ON_ERROR = 'CONTINUE';                  -- Continue on partial failures
        
        -- Final row count tracking
        LET c6 CURSOR FOR SELECT COUNT(*) AS row_count FROM bronze.erp_px_cat_g1v2;
        OPEN c6;
        FETCH c6 INTO rows_loaded;
        CLOSE c6;
        
        SYSTEM$LOG('INFO', 'Loaded ' || rows_loaded || ' rows into erp_px_cat_g1v2');
        files_processed := files_processed + 1;
    EXCEPTION
        WHEN OTHER THEN
            error_message := 'Failed to load erp_px_cat_g1v2: ' || SQLERRM;
            SYSTEM$LOG('ERROR', error_message);
            RAISE;
    END;
    
    -- =============================================================================
    -- COMPLETION PHASE
    -- Generate performance metrics and return final status
    -- =============================================================================
    
    -- Calculate execution duration and prepare success message
    procedure_result := 'SUCCESS: Bronze layer load completed. ' || 
                       files_processed || ' tables loaded in ' || 
                       DATEDIFF('second', load_start_time, CURRENT_TIMESTAMP()) || ' seconds.';
    
    -- Log successful completion for audit purposes
    SYSTEM$LOG('INFO', procedure_result);
    
    -- Return result to calling process (Airflow, manual execution, etc.)
    RETURN procedure_result;
    
END;
$$;

-- =================================================================================
-- USAGE INSTRUCTIONS:
-- 
-- 1. Execute the loader: CALL bronze.load_bronze_layer();
-- 2. Monitor progress: Check Snowflake query history and logs
-- 3. Validate results: Use bronze validation procedures
-- 4. Schedule: Integrate with Airflow for automated daily execution
-- 
-- EXPECTED OUTPUT: 
-- 'SUCCESS: Bronze layer load completed. 6 tables loaded in X seconds.'
-- =================================================================================
