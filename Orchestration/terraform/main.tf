# =================================================================================
# MODERN DATA WAREHOUSE - TERRAFORM INFRASTRUCTURE
# 
# Purpose: Infrastructure as Code for Snowflake data warehouse
# Description: Creates complete Snowflake environment for medallion architecture
# Security: All sensitive values are managed via variables and secrets
# =================================================================================

# =================================================================================
# TERRAFORM CONFIGURATION
# =================================================================================
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "~> 0.87"  # Use stable, recent version
    }
  }

  # Optional: Remote state storage for team collaboration
  # backend "s3" {
  #   bucket = "your-terraform-state-bucket"
  #   key    = "snowflake-data-warehouse/terraform.tfstate"
  #   region = "us-east-1"
  # }
}

# =================================================================================
# SNOWFLAKE PROVIDER CONFIGURATION
# =================================================================================
provider "snowflake" {
  # Connection details provided via environment variables for security
  # Recommended: Set these as environment variables in your CI/CD pipeline
  # export SNOWFLAKE_ACCOUNT="your_account"
  # export SNOWFLAKE_USER="terraform_user"
  # export SNOWFLAKE_PASSWORD="your_secure_password"
  # export SNOWFLAKE_ROLE="ACCOUNTADMIN"
  
  account  = var.snowflake_account
  user     = var.snowflake_user
  password = var.snowflake_password
  role     = var.snowflake_role
  region   = var.snowflake_region
}

# =================================================================================
# DATABASE AND SCHEMAS - MEDALLION ARCHITECTURE
# =================================================================================

# Main data warehouse database
resource "snowflake_database" "data_warehouse" {
  name                        = "${var.project_prefix}_DATA_WAREHOUSE"
  comment                     = "Modern Data Warehouse - Medallion Architecture for ${var.project_prefix}"
  data_retention_time_in_days = var.data_retention_days
  
  # Enable Time Travel for data recovery capabilities
  # Default: 1 day (Snowflake Standard), can be increased for Enterprise edition
}

# Bronze Schema - Raw Data Layer
resource "snowflake_schema" "bronze_schema" {
  database = snowflake_database.data_warehouse.name
  name     = "BRONZE"
  comment  = "Raw data layer - immutable source data from external stages"
  
  # Managed schema for internal Snowflake objects
  is_managed = false
}

# Silver Schema - Cleaned Data Layer  
resource "snowflake_schema" "silver_schema" {
  database = snowflake_database.data_warehouse.name
  name     = "SILVER"
  comment  = "Cleaned and validated data - business-ready transformations"
}

# Gold Schema - Business Data Layer
resource "snowflake_schema" "gold_schema" {
  database = snowflake_database.data_warehouse.name
  name     = "GOLD"
  comment  = "Business metrics and dimensions - analytics ready"
}

# =================================================================================
# VIRTUAL WAREHOUSES - SEPARATE COMPUTE FOR EACH LAYER
# =================================================================================

# Bronze Warehouse - Data Loading Operations
resource "snowflake_warehouse" "bronze_wh" {
  name           = "${var.project_prefix}_BRONZE_WH"
  warehouse_size = var.bronze_warehouse_size
  auto_suspend   = var.warehouse_auto_suspend
  auto_resume    = true
  initially_suspended = true
  
  comment = "Warehouse for bronze layer data loading operations from S3"
  
  # Scaling policy for handling variable data volumes
  scaling_policy = "STANDARD"
}

# Silver Warehouse - Transformation Operations
resource "snowflake_warehouse" "silver_wh" {
  name           = "${var.project_prefix}_SILVER_WH"
  warehouse_size = var.silver_warehouse_size
  auto_suspend   = var.warehouse_auto_suspend
  auto_resume    = true
  initially_suspended = true
  
  comment = "Warehouse for silver layer data transformations and cleaning"
  
  # Enable query acceleration for complex transformations
  enable_query_acceleration = true
}

# Gold Warehouse - Analytics Operations
resource "snowflake_warehouse" "gold_wh" {
  name           = "${var.project_prefix}_GOLD_WH"
  warehouse_size = var.gold_warehouse_size
  auto_suspend   = var.warehouse_auto_suspend
  auto_resume    = true
  initially_suspended = true
  
  comment = "Warehouse for gold layer business analytics and reporting"
  
  # Maximize cache for repeated analytical queries
  max_concurrency_level = 16
}

# =================================================================================
# SECURITY ROLES - PRINCIPLE OF LEAST PRIVILEGE
# =================================================================================

# Data Loader Role - Bronze Layer Access
resource "snowflake_role" "loader_role" {
  name    = "${var.project_prefix}_LOADER"
  comment = "Role for ingesting raw data into bronze layer from external stages"
}

# Data Transformer Role - Silver Layer Access
resource "snowflake_role" "transformer_role" {
  name    = "${var.project_prefix}_TRANSFORMER"
  comment = "Role for transforming data between bronze and silver layers"
}

# Data Analyst Role - Gold Layer Access
resource "snowflake_role" "analyst_role" {
  name    = "${var.project_prefix}_ANALYST"
  comment = "Role for querying gold layer business metrics and dimensions"
}

# Pipeline Role - Orchestration Access
resource "snowflake_role" "pipeline_role" {
  name    = "${var.project_prefix}_PIPELINE"
  comment = "Role for Airflow/DAG execution across all data layers"
}

# =================================================================================
# DATABASE AND SCHEMA PRIVILEGES
# =================================================================================

# Database Usage for All Roles
resource "snowflake_database_grant" "database_usage" {
  for_each = toset([
    snowflake_role.loader_role.name,
    snowflake_role.transformer_role.name,
    snowflake_role.analyst_role.name,
    snowflake_role.pipeline_role.name
  ])
  
  database_name = snowflake_database.data_warehouse.name
  privilege     = "USAGE"
  roles         = [each.key]
}

# Bronze Schema Privileges
resource "snowflake_schema_grant" "bronze_usage" {
  schema_name   = snowflake_schema.bronze_schema.name
  database_name = snowflake_database.data_warehouse.name
  privilege     = "USAGE"
  roles         = [
    snowflake_role.loader_role.name,
    snowflake_role.transformer_role.name,
    snowflake_role.pipeline_role.name
  ]
}

resource "snowflake_schema_grant" "bronze_modify" {
  schema_name   = snowflake_schema.bronze_schema.name
  database_name = snowflake_database.data_warehouse.name
  privilege     = "MODIFY"
  roles         = [snowflake_role.loader_role.name]
}

# Silver Schema Privileges
resource "snowflake_schema_grant" "silver_usage" {
  schema_name   = snowflake_schema.silver_schema.name
  database_name = snowflake_database.data_warehouse.name
  privilege     = "USAGE"
  roles         = [
    snowflake_role.transformer_role.name,
    snowflake_role.analyst_role.name,
    snowflake_role.pipeline_role.name
  ]
}

resource "snowflake_schema_grant" "silver_modify" {
  schema_name   = snowflake_schema.silver_schema.name
  database_name = snowflake_database.data_warehouse.name
  privilege     = "MODIFY"
  roles         = [snowflake_role.transformer_role.name]
}

# Gold Schema Privileges
resource "snowflake_schema_grant" "gold_usage" {
  schema_name   = snowflake_schema.gold_schema.name
  database_name = snowflake_database.data_warehouse.name
  privilege     = "USAGE"
  roles         = [
    snowflake_role.transformer_role.name,
    snowflake_role.analyst_role.name,
    snowflake_role.pipeline_role.name
  ]
}

resource "snowflake_schema_grant" "gold_modify" {
  schema_name   = snowflake_schema.gold_schema.name
  database_name = snowflake_database.data_warehouse.name
  privilege     = "MODIFY"
  roles         = [snowflake_role.transformer_role.name]
}

# =================================================================================
# WAREHOUSE PRIVILEGES
# =================================================================================

resource "snowflake_warehouse_grant" "bronze_wh_usage" {
  warehouse_name = snowflake_warehouse.bronze_wh.name
  privilege      = "USAGE"
  roles          = [snowflake_role.loader_role.name]
}

resource "snowflake_warehouse_grant" "silver_wh_usage" {
  warehouse_name = snowflake_warehouse.silver_wh.name
  privilege      = "USAGE"
  roles          = [snowflake_role.transformer_role.name]
}

resource "snowflake_warehouse_grant" "gold_wh_usage" {
  warehouse_name = snowflake_warehouse.gold_wh.name
  privilege      = "USAGE"
  roles          = [
    snowflake_role.transformer_role.name,
    snowflake_role.analyst_role.name
  ]
}

# =================================================================================
# FUTURE GRANTS - AUTOMATIC PRIVILEGES FOR NEW OBJECTS
# =================================================================================

# Future tables in bronze can be used by transformer role
resource "snowflake_schema_grant" "bronze_future_tables" {
  schema_name   = snowflake_schema.bronze_schema.name
  database_name = snowflake_database.data_warehouse.name
  privilege     = "SELECT"
  roles         = [snowflake_role.transformer_role.name]
  on_future     = true
}

# Future tables in silver can be used by analyst role
resource "snowflake_schema_grant" "silver_future_tables" {
  schema_name   = snowflake_schema.silver_schema.name
  database_name = snowflake_database.data_warehouse.name
  privilege     = "SELECT"
  roles         = [snowflake_role.analyst_role.name]
  on_future     = true
}

# =================================================================================
# FILE FORMATS AND STAGES FOR BRONZE LAYER
# =================================================================================

# Standard CSV Format for Bronze Ingestion
resource "snowflake_file_format" "bronze_csv_format" {
  database = snowflake_database.data_warehouse.name
  schema   = snowflake_schema.bronze_schema.name
  name     = "MY_CSV_FORMAT"
  
  format_type = "CSV"
  field_delimiter = ","
  skip_header = 1
  empty_field_as_null = true
  null_if = ["NULL", "null", ""]
  
  comment = "Standard CSV format for bronze layer data ingestion"
}

# External Stage for S3 Data (CRM Source)
resource "snowflake_stage" "crm_stage" {
  database = snowflake_database.data_warehouse.name
  schema   = snowflake_schema.bronze_schema.name
  name     = "CRM_STAGE"
  
  url = "s3://${var.s3_bucket_name}/raw/crm/"
  
  # Credentials should be managed via Snowflake secrets in production
  credentials = "AWS_KEY_ID = '${var.aws_access_key_id}' AWS_SECRET_KEY = '${var.aws_secret_access_key}'"
  
  file_format = snowflake_file_format.bronze_csv_format.name
  comment     = "External stage for CRM source files in S3"
}

# External Stage for S3 Data (ERP Source)
resource "snowflake_stage" "erp_stage" {
  database = snowflake_database.data_warehouse.name
  schema   = snowflake_schema.bronze_schema.name
  name     = "ERP_STAGE"
  
  url = "s3://${var.s3_bucket_name}/raw/erp/"
  
  credentials = "AWS_KEY_ID = '${var.aws_access_key_id}' AWS_SECRET_KEY = '${var.aws_secret_access_key}'"
  
  file_format = snowflake_file_format.bronze_csv_format.name
  comment     = "External stage for ERP source files in S3"
}
