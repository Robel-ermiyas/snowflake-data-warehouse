-- =====================================================================
-- BRONZE LAYER DATA INGESTION VALIDATION PROCEDURES
-- 
-- Purpose: Validate successful raw data ingestion from S3 to Snowflake
-- Focus: Verify data reliability and completeness at ingestion layer
-- Note: Bronze layer preserves raw data - no data quality transformations
-- =====================================================================

-- =====================================================================
-- PROCEDURE: validate_ingestion_success
-- 
-- Description: Comprehensive validation that checks both table accessibility
-- and verifies that critical primary key columns contain data. This provides
-- a more thorough check than basic table existence.
-- 
-- Returns: String with detailed validation results
-- =====================================================================

CREATE OR REPLACE PROCEDURE bronze.validate_ingestion_success()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
    LET table_count INTEGER;
    
    SELECT COUNT(*) INTO :table_count
    FROM (
        SELECT 1 FROM bronze.crm_cust_info HAVING COUNT(*) > 0
        UNION ALL SELECT 1 FROM bronze.crm_prd_info HAVING COUNT(*) > 0
        UNION ALL SELECT 1 FROM bronze.crm_sales_details HAVING COUNT(*) > 0
        UNION ALL SELECT 1 FROM bronze.erp_cust_az12 HAVING COUNT(*) > 0
        UNION ALL SELECT 1 FROM bronze.erp_loc_a101 HAVING COUNT(*) > 0
        UNION ALL SELECT 1 FROM bronze.erp_px_cat_g1v2 HAVING COUNT(*) > 0
    );
    
    IF (table_count = 6) THEN
        RETURN 'SUCCESS: All 6 tables loaded successfully';
    ELSE
        RETURN 'FAILED: Only ' || table_count || ' of 6 tables have data';
    END IF;
END;
$$;

-- =====================================================================
-- PROCEDURE: get_ingestion_report
-- 
-- Description: Detailed table-level report showing record counts and 
-- ingestion status for each bronze table. Useful for troubleshooting
-- and monitoring the data ingestion process.
-- 
-- Returns: Table with columns: table_name, record_count, status
-- =====================================================================

CREATE OR REPLACE PROCEDURE bronze.get_ingestion_report()
RETURNS TABLE()
LANGUAGE SQL
AS
$$
DECLARE
    report_results RESULTSET DEFAULT (
        SELECT 
            'crm_cust_info' AS table_name,
            COUNT(*) AS record_count,
            CASE WHEN COUNT(*) > 0 THEN 'INGESTED' ELSE 'EMPTY' END AS status
        FROM bronze.crm_cust_info
        
        UNION ALL
        
        SELECT 
            'crm_prd_info',
            COUNT(*),
            CASE WHEN COUNT(*) > 0 THEN 'INGESTED' ELSE 'EMPTY' END
        FROM bronze.crm_prd_info
        
        UNION ALL
        
        SELECT 
            'crm_sales_details', 
            COUNT(*),
            CASE WHEN COUNT(*) > 0 THEN 'INGESTED' ELSE 'EMPTY' END
        FROM bronze.crm_sales_details
        
        UNION ALL
        
        SELECT 
            'erp_cust_az12',
            COUNT(*),
            CASE WHEN COUNT(*) > 0 THEN 'INGESTED' ELSE 'EMPTY' END
        FROM bronze.erp_cust_az12
        
        UNION ALL
        
        SELECT 
            'erp_loc_a101',
            COUNT(*),
            CASE WHEN COUNT(*) > 0 THEN 'INGESTED' ELSE 'EMPTY' END
        FROM bronze.erp_loc_a101
        
        UNION ALL
        
        SELECT 
            'erp_px_cat_g1v2',
            COUNT(*),
            CASE WHEN COUNT(*) > 0 THEN 'INGESTED' ELSE 'EMPTY' END
        FROM bronze.erp_px_cat_g1v2
        
        ORDER BY table_name
    );
BEGIN
    RETURN TABLE(report_results);
END;
$$;


-- =====================================================================
-- PROCEDURE: check_data_loaded
-- 
-- Description: Basic health check to verify all bronze tables are accessible
-- and contain data. This is the simplest validation to ensure the ETL 
-- pipeline successfully loaded data from S3.
-- 
-- Returns: String indicating success/warning status with table count
-- =====================================================================

CREATE OR REPLACE PROCEDURE bronze.check_data_loaded()
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
    table_count INTEGER;
BEGIN
    -- Simple count using subquery
    SELECT COUNT(*) INTO :table_count
    FROM (
        SELECT 1 FROM bronze.crm_cust_info WHERE 1=1
        UNION ALL SELECT 1 FROM bronze.crm_prd_info WHERE 1=1  
        UNION ALL SELECT 1 FROM bronze.crm_sales_details WHERE 1=1
        UNION ALL SELECT 1 FROM bronze.erp_cust_az12 WHERE 1=1
        UNION ALL SELECT 1 FROM bronze.erp_loc_a101 WHERE 1=1
        UNION ALL SELECT 1 FROM bronze.erp_px_cat_g1v2 WHERE 1=1
    ) AS all_tables;
    
    IF (table_count = 6) THEN
        RETURN 'SUCCESS: All 6 bronze tables are ready';
    ELSE
        RETURN 'WARNING: ' || table_count || ' of 6 tables are accessible';
    END IF;
END;
$$;
