-- =================================================================================
-- BRONZE LAYER - EXTERNAL STAGE CONFIGURATIONS
-- 
-- Purpose: Create secure connections to S3 buckets for data access
-- Description: Stages act as pointers to cloud storage locations
-- Security: AWS credentials should be managed via Snowflake secrets in production
-- =================================================================================

-- =================================================================================
-- CRM DATA STAGE
-- 
-- Points to CRM source files in S3 data lake
-- Source System: Customer Relationship Management
-- Data Types: Customer profiles, product catalog, sales transactions
-- =================================================================================
CREATE OR REPLACE STAGE bronze.crm_stage
  URL = 's3://robel-data-lake/raw/crm/'          -- S3 path for CRM source files
  CREDENTIALS = (AWS_KEY_ID = ' ' AWS_SECRET_KEY = ' ')
  FILE_FORMAT = bronze.my_csv_format             -- Apply standardized CSV parsing
  COMMENT = 'External stage for CRM source files (customer, product, sales data)';

-- =================================================================================
-- ERP DATA STAGE
-- 
-- Points to ERP source files in S3 data lake  
-- Source System: Enterprise Resource Planning
-- Data Types: Customer master, location data, product categories
-- =================================================================================
CREATE OR REPLACE STAGE bronze.erp_stage
  URL = 's3://robel-data-lake/raw/erp/'          -- S3 path for ERP source files
  CREDENTIALS = (AWS_KEY_ID = ' ' AWS_SECRET_KEY = ' ')
  FILE_FORMAT = bronze.my_csv_format             -- Apply standardized CSV parsing
  COMMENT = 'External stage for ERP source files (customer, location, product category data)';

-- =================================================================================
-- STAGE VALIDATION QUERIES
-- 
-- Use these to verify stage configurations and list available files
-- =================================================================================

/*
-- Verify CRM stage configuration and list files
LIST @bronze.crm_stage;

-- Verify ERP stage configuration and list files  
LIST @bronze.erp_stage;

-- Expected output: Should show CSV files for each data source
*/
