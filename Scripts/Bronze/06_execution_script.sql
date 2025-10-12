-- =================================================================================
-- BRONZE LAYER - EXECUTION SCRIPT
-- 
-- Purpose: Demonstrate the complete bronze layer execution workflow
-- Usage: Run this script to execute the entire bronze layer pipeline
-- =================================================================================

-- =============================================================================
-- STEP 1: Execute Bronze Layer Load Procedure
-- =============================================================================
CALL bronze.load_bronze_layer();

-- =============================================================================
-- STEP 2: Validate Data Ingestion
-- =============================================================================
CALL bronze.check_data_loaded();
CALL bronze.get_ingestion_report();
CALL bronze.validate_ingestion_success();
-- =============================================================================
-- STEP 3: Review Load Results
-- =============================================================================
-- Check the most recent copy history for detailed results
SELECT 
    table_name,
    file_name,
    status,
    rows_loaded,
    rows_parsed,
    errors_seen,
    first_error_message
FROM TABLE(INFORMATION_SCHEMA.COPY_HISTORY(
    START_TIME => DATEADD(HOURS, -1, CURRENT_TIMESTAMP())
))
WHERE table_name LIKE 'BRONZE.%'
ORDER BY last_load_time DESC;
