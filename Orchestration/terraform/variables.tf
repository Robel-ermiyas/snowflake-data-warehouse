# =================================================================================
# TERRAFORM VARIABLES CONFIGURATION
# 
# Purpose: Centralized configuration for environment-specific values
# Security: Sensitive variables should be set via environment variables or secrets
# =================================================================================

# =================================================================================
# REQUIRED VARIABLES - Must be provided by user
# =================================================================================

variable "snowflake_account" {
  description = "Snowflake account identifier (e.g., xy12345.us-east-2.aws)"
  type        = string
  sensitive   = true
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]+\\.[a-zA-Z0-9_-]+\\.[a-zA-Z0-9_-]+$", var.snowflake_account))
    error_message = "Snowflake account must be in format: account.region.cloud"
  }
}

variable "snowflake_user" {
  description = "Snowflake username for Terraform to authenticate with"
  type        = string
  sensitive   = true
  
  validation {
    condition     = can(regex("^[A-Za-z_][A-Za-z0-9_]*$", var.snowflake_user))
    error_message = "Snowflake user must start with a letter and contain only alphanumeric characters and underscores"
  }
}

variable "snowflake_password" {
  description = "Password for the Snowflake user (consider using key pair auth in production)"
  type        = string
  sensitive   = true
  
  validation {
    condition     = length(var.snowflake_password) >= 8
    error_message = "Snowflake password must be at least 8 characters long"
  }
}

variable "project_prefix" {
  description = "Short identifier for the project used in resource naming (e.g., acme, fin_dwh)"
  type        = string
  
  validation {
    condition     = can(regex("^[A-Za-z][A-Za-z0-9_]{2,15}$", var.project_prefix))
    error_message = "Project prefix must start with a letter, be 3-16 characters long, and contain only alphanumeric characters and underscores"
  }
}

# =================================================================================
# OPTIONAL VARIABLES - Default values provided
# =================================================================================

variable "snowflake_role" {
  description = "Snowflake role for Terraform to use (must have sufficient privileges)"
  type        = string
  default     = "ACCOUNTADMIN"
  
  validation {
    condition     = contains(["ACCOUNTADMIN", "SYSADMIN", "SECURITYADMIN"], var.snowflake_role)
    error_message = "Snowflake role must be one of: ACCOUNTADMIN, SYSADMIN, SECURITYADMIN"
  }
}

variable "snowflake_region" {
  description = "Snowflake region (leave empty for default region)"
  type        = string
  default     = ""
}

variable "data_retention_days" {
  description = "Number of days to retain data in the database (Time Travel)"
  type        = number
  default     = 1
  
  validation {
    condition     = var.data_retention_days >= 0 && var.data_retention_days <= 90
    error_message = "Data retention days must be between 0 and 90 (Snowflake Standard edition limit)"
  }
}

# =================================================================================
# WAREHOUSE CONFIGURATION VARIABLES
# =================================================================================

variable "bronze_warehouse_size" {
  description = "Size of the bronze layer warehouse for data loading operations"
  type        = string
  default     = "X-Small"
  
  validation {
    condition     = contains(["X-Small", "Small", "Medium", "Large", "X-Large", "2X-Large", "3X-Large", "4X-Large"], var.bronze_warehouse_size)
    error_message = "Warehouse size must be a valid Snowflake warehouse size"
  }
}

variable "silver_warehouse_size" {
  description = "Size of the silver layer warehouse for transformation operations"
  type        = string
  default     = "X-Small"
  
  validation {
    condition     = contains(["X-Small", "Small", "Medium", "Large", "X-Large", "2X-Large", "3X-Large", "4X-Large"], var.silver_warehouse_size)
    error_message = "Warehouse size must be a valid Snowflake warehouse size"
  }
}

variable "gold_warehouse_size" {
  description = "Size of the gold layer warehouse for analytics operations"
  type        = string
  default     = "Small"
  
  validation {
    condition     = contains(["X-Small", "Small", "Medium", "Large", "X-Large", "2X-Large", "3X-Large", "4X-Large"], var.gold_warehouse_size)
    error_message = "Warehouse size must be a valid Snowflake warehouse size"
  }
}

variable "warehouse_auto_suspend" {
  description = "Number of seconds to wait before automatically suspending warehouses"
  type        = number
  default     = 300  # 5 minutes
  
  validation {
    condition     = var.warehouse_auto_suspend >= 60
    error_message = "Warehouse auto-suspend must be at least 60 seconds"
  }
}

# =================================================================================
# EXTERNAL STORAGE VARIABLES
# =================================================================================

variable "s3_bucket_name" {
  description = "Name of the S3 bucket containing raw data files"
  type        = string
  default     = "robel-data-lake"
  
  validation {
    condition     = can(regex("^[a-z0-9.-]{3,63}$", var.s3_bucket_name))
    error_message = "S3 bucket name must be between 3 and 63 characters and contain only lowercase letters, numbers, hyphens, and periods"
  }
}

variable "aws_access_key_id" {
  description = "AWS access key ID for S3 stage authentication"
  type        = string
  sensitive   = true
  default     = ""
}

variable "aws_secret_access_key" {
  description = "AWS secret access key for S3 stage authentication"
  type        = string
  sensitive   = true
  default     = ""
}

# =================================================================================
# ENVIRONMENT SPECIFIC VARIABLES
# =================================================================================

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod"
  }
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {
    Project     = "Modern Data Warehouse"
    ManagedBy   = "Terraform"
    Environment = "dev"
  }
}

# =================================================================================
# FEATURE FLAGS
# =================================================================================

variable "enable_future_grants" {
  description = "Whether to enable future grants for automatic privilege management"
  type        = bool
  default     = true
}

variable "enable_external_stages" {
  description = "Whether to create external stages for S3 integration"
  type        = bool
  default     = true
}
