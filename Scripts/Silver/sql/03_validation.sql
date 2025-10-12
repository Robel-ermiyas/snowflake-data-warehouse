-- =================================================================================
-- SILVER LAYER - LEGACY VALIDATION QUERIES
-- 
-- Purpose: Data quality and completeness checks for Silver layer
-- Usage: Run these queries after executing silver.load_silver
-- =================================================================================

PRINT '================================================';
PRINT 'SILVER LAYER - DATA VALIDATION CHECKS';
PRINT '================================================';

-- 1. TABLE COUNTS VALIDATION
PRINT '1. TABLE RECORD COUNTS:';
SELECT 
    'crm_cust_info' AS table_name,
    COUNT(*) AS record_count,
    (SELECT COUNT(DISTINCT cst_id) FROM silver.crm_cust_info) AS distinct_customers
FROM silver.crm_cust_info

UNION ALL

SELECT 
    'crm_prd_info',
    COUNT(*),
    (SELECT COUNT(DISTINCT prd_id) FROM silver.crm_prd_info)
FROM silver.crm_prd_info

UNION ALL

SELECT 
    'crm_sales_details',
    COUNT(*),
    (SELECT COUNT(DISTINCT sls_ord_num) FROM silver.crm_sales_details)
FROM silver.crm_sales_details

UNION ALL

SELECT 
    'erp_cust_az12',
    COUNT(*),
    (SELECT COUNT(DISTINCT cid) FROM silver.erp_cust_az12)
FROM silver.erp_cust_az12

UNION ALL

SELECT 
    'erp_loc_a101',
    COUNT(*),
    (SELECT COUNT(DISTINCT cid) FROM silver.erp_loc_a101)
FROM silver.erp_loc_a101

UNION ALL

SELECT 
    'erp_px_cat_g1v2',
    COUNT(*),
    (SELECT COUNT(DISTINCT id) FROM silver.erp_px_cat_g1v2)
FROM silver.erp_px_cat_g1v2;

-- 2. DATA QUALITY CHECKS
PRINT '2. DATA QUALITY CHECKS:';

-- Check for NULL primary keys
PRINT '   - NULL Primary Keys:';
SELECT 
    'crm_cust_info' AS table_name,
    COUNT(*) AS null_primary_keys
FROM silver.crm_cust_info 
WHERE cst_id IS NULL

UNION ALL

SELECT 
    'crm_prd_info',
    COUNT(*)
FROM silver.crm_prd_info 
WHERE prd_id IS NULL

UNION ALL

SELECT 
    'crm_sales_details',
    COUNT(*)
FROM silver.crm_sales_details 
WHERE sls_ord_num IS NULL;

-- 3. BUSINESS RULE VALIDATION
PRINT '3. BUSINESS RULE VALIDATION:';

-- Check for invalid sales amounts
PRINT '   - Invalid Sales Amounts:';
SELECT 
    COUNT(*) AS negative_sales_count
FROM silver.crm_sales_details 
WHERE sls_sales < 0;

-- Check for future dates
PRINT '   - Future Dates:';
SELECT 
    'crm_cust_info' AS table_name,
    COUNT(*) AS future_dates
FROM silver.crm_cust_info 
WHERE cst_create_date > GETDATE()

UNION ALL

SELECT 
    'erp_cust_az12',
    COUNT(*)
FROM silver.erp_cust_az12 
WHERE bdate > GETDATE();

-- 4. TRANSFORMATION VALIDATION
PRINT '4. TRANSFORMATION VALIDATION:';

-- Verify gender standardization
PRINT '   - Gender Standardization:';
SELECT 
    cst_gndr,
    COUNT(*) AS count
FROM silver.crm_cust_info 
GROUP BY cst_gndr;

-- Verify marital status standardization  
PRINT '   - Marital Status Standardization:';
SELECT 
    cst_marital_status,
    COUNT(*) AS count
FROM silver.crm_cust_info 
GROUP BY cst_marital_status;

-- Verify product line mapping
PRINT '   - Product Line Mapping:';
SELECT 
    prd_line,
    COUNT(*) AS count
FROM silver.crm_prd_info 
GROUP BY prd_line;

-- 5. COMPLETENESS CHECK
PRINT '5. COMPLETENESS CHECK:';

-- Check if all sales have valid customer and product references
SELECT 
    'Sales with missing customers' AS check_type,
    COUNT(*) AS issue_count
FROM silver.crm_sales_details s
LEFT JOIN silver.crm_cust_info c ON s.sls_cust_id = c.cst_id
WHERE c.cst_id IS NULL

UNION ALL

SELECT 
    'Sales with future order dates',
    COUNT(*)
FROM silver.crm_sales_details 
WHERE sls_order_dt > GETDATE()

UNION ALL

SELECT 
    'Products with invalid date ranges',
    COUNT(*)
FROM silver.crm_prd_info 
WHERE prd_end_dt < prd_start_dt;

PRINT '================================================';
PRINT 'VALIDATION COMPLETED';
PRINT 'Review results above for any data quality issues';
PRINT '================================================';
