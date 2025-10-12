-- =================================================================================
-- BRONZE LAYER - TABLE CREATION DDL
-- 
-- Purpose: Create raw data tables for S3 data ingestion
-- Description: These tables store data exactly as received from source systems
-- Philosophy: Preserve raw data without transformation (ELT approach)
-- =================================================================================

-- =================================================================================
-- CRM DATA TABLES
-- 
-- Customer Relationship Management system tables
-- These store raw data from CRM source files
-- =================================================================================

-- CRM Customer Information Table
-- Source: Customer master data from CRM system
CREATE TABLE IF NOT EXISTS bronze.crm_cust_info (
    cst_id INT,                     -- Customer identifier
    cst_key VARCHAR(50),            -- Customer business key
    cst_first_name VARCHAR(50),     -- Customer first name (raw)
    cst_last_name VARCHAR(50),      -- Customer last name (raw)
    cst_marital_status VARCHAR(50), -- Marital status indicator
    cst_gndr VARCHAR(50),           -- Gender code (raw format)
    cst_create_date DATE            -- Customer creation date
)
COMMENT = 'Raw CRM customer information - preserved exactly as received from source';

-- CRM Product Information Table  
-- Source: Product catalog from CRM system
CREATE TABLE IF NOT EXISTS bronze.crm_prd_info (
    prd_id INT,                     -- Product identifier
    prd_key VARCHAR(50),            -- Product business key
    prd_nm VARCHAR(50),             -- Product name (raw)
    prd_cost INT,                   -- Product cost amount
    prd_line VARCHAR(50),           -- Product line/category
    prd_start_dt TIMESTAMP,         -- Product effective start date
    prd_end_dt TIMESTAMP            -- Product effective end date
)
COMMENT = 'Raw CRM product information - preserved exactly as received from source';

-- CRM Sales Details Table
-- Source: Sales transactions from CRM system
CREATE TABLE IF NOT EXISTS bronze.crm_sales_details (
    sls_ord_num VARCHAR(50),        -- Sales order number
    sls_prd_key VARCHAR(50),        -- Product key (matches prd_key)
    sls_cust_id INT,                -- Customer ID (matches cst_id)
    sls_order_dt INT,               -- Order date (raw integer format)
    sls_ship_dt INT,                -- Ship date (raw integer format)
    sls_due_dt INT,                 -- Due date (raw integer format)
    sls_sales INT,                  -- Sales amount
    sls_quantity INT,               -- Quantity sold
    sls_price INT                   -- Unit price
)
COMMENT = 'Raw CRM sales transaction details - preserved exactly as received from source';

-- =================================================================================
-- ERP DATA TABLES
-- 
-- Enterprise Resource Planning system tables
-- These store raw data from ERP source files (different schema than CRM)
-- =================================================================================

-- ERP Customer Data Table (AZ12 System)
-- Source: Customer master from ERP system
CREATE TABLE IF NOT EXISTS bronze.erp_cust_az12 (
    CID VARCHAR(50),                -- Customer identifier (ERP format)
    BDATE DATE,                     -- Birth date
    GEN VARCHAR(50)                 -- Gender code (ERP format)
)
COMMENT = 'Raw ERP customer data from AZ12 system - preserved exactly as received';

-- ERP Location Data Table (A101 System)
-- Source: Customer geographic data from ERP system
CREATE TABLE IF NOT EXISTS bronze.erp_loc_a101 (
    cid VARCHAR(50),                -- Customer identifier (matches ERP CID)
    cntry VARCHAR(50)               -- Country code
)
COMMENT = 'Raw ERP location data from A101 system - preserved exactly as received';

-- ERP Product Category Data Table (G1V2 System)
-- Source: Product categorization from ERP system
CREATE TABLE IF NOT EXISTS bronze.erp_px_cat_g1v2 (
    id VARCHAR(50),                 -- Product category identifier
    cat VARCHAR(50),                -- Main category
    subcat VARCHAR(50),             -- Sub-category
    maintenance VARCHAR(50)         -- Maintenance indicator
)
COMMENT = 'Raw ERP product category data from G1V2 system - preserved exactly as received';

-- =================================================================================
-- TABLE VALIDATION QUERIES
-- 
-- Use these to verify table creation and structure
-- =================================================================================

/*
-- Show all bronze tables
SHOW TABLES IN SCHEMA bronze;

-- Describe table structures
DESC TABLE bronze.crm_cust_info;
DESC TABLE bronze.crm_prd_info;
DESC TABLE bronze.crm_sales_details;
DESC TABLE bronze.erp_cust_az12;
DESC TABLE bronze.erp_loc_a101;
DESC TABLE bronze.erp_px_cat_g1v2;
*/
