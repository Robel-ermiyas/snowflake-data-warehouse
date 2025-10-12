-- =================================================================================
-- BRONZE LAYER - FILE FORMAT CONFIGURATIONS
-- 
-- Purpose: Define standardized file formats for S3 data ingestion
-- Description: Centralized configuration for parsing CSV files from source systems
-- =================================================================================

-- =================================================================================
-- STANDARD CSV FORMAT FOR BRONZE LAYER
-- 
-- This format ensures consistent parsing of all CSV files from S3
-- Features: Header skipping, null handling, and comma delimiters
-- =================================================================================
CREATE OR REPLACE FILE FORMAT bronze.my_csv_format
    TYPE = CSV                          -- Source files are in CSV format
    FIELD_DELIMITER = ','               -- Use comma as field separator
    SKIP_HEADER = 1                     -- Ignore first row as header
    EMPTY_FIELD_AS_NULL = TRUE          -- Treat empty fields as NULL values
    NULL_IF = ('NULL', 'null', '')      -- Standardize NULL representations
    COMMENT = 'Standard CSV format for bronze layer data ingestion from S3';
