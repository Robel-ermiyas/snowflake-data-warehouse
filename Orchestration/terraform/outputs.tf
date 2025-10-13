# =================================================================================
# TERRAFORM OUTPUTS CONFIGURATION
# 
# Purpose: Export important resource attributes for other systems and documentation
# Description: These outputs are used by orchestration tools, documentation, and CI/CD
# =================================================================================

# =================================================================================
# DATABASE AND SCHEMA OUTPUTS
# =================================================================================

output "database_name" {
  description = "Name of the created data warehouse database"
  value       = snowflake_database.data_warehouse.name
}

output "schema_names" {
  description = "Names of the created medallion architecture schemas"
  value = {
    bronze = snowflake_schema.bronze_schema.name
    silver = snowflake_schema.silver_schema.name
    gold   = snowflake_schema.gold_schema.name
  }
}

# =================================================================================
# WAREHOUSE OUTPUTS
# =================================================================================

output "warehouse_names" {
  description = "Names of the created virtual warehouses for each data layer"
  value = {
    bronze = snowflake_warehouse.bronze_wh.name
    silver = snowflake_warehouse.silver_wh.name
    gold   = snowflake_warehouse.gold_wh.name
  }
}

output "warehouse_details" {
  description = "Detailed information about created warehouses"
  value = {
    bronze = {
      name = snowflake_warehouse.bronze_wh.name
      size = snowflake_warehouse.bronze_wh.warehouse_size
    }
    silver = {
      name = snowflake_warehouse.silver_wh.name
      size = snowflake_warehouse.silver_wh.warehouse_size
    }
    gold = {
      name = snowflake_warehouse.gold_wh.name
      size = snowflake_warehouse.gold_wh.warehouse_size
    }
  }
}

# =================================================================================
# SECURITY ROLE OUTPUTS
# =================================================================================

output "role_names" {
  description = "Names of the created custom roles for the data platform"
  value = {
    loader      = snowflake_role.loader_role.name
    transformer = snowflake_role.transformer_role.name
    analyst     = snowflake_role.analyst_role.name
    pipeline    = snowflake_role.pipeline_role.name
  }
}

output "role_descriptions" {
  description = "Descriptions and purposes of each created role"
  value = {
    loader      = "Ingests raw data into bronze layer from external stages"
    transformer = "Transforms data between bronze and silver layers"
    analyst     = "Queries gold layer business metrics and dimensions"
    pipeline    = "Orchestrates data pipelines across all layers"
  }
}

# =================================================================================
# EXTERNAL STAGE OUTPUTS
# =================================================================================

output "external_stages" {
  description = "Configuration of external stages for data ingestion"
  value = {
    crm_stage = {
      name = snowflake_stage.crm_stage.name
      url  = snowflake_stage.crm_stage.url
    }
    erp_stage = {
      name = snowflake_stage.erp_stage.name
      url  = snowflake_stage.erp_stage.url
    }
  }
}

output "file_format" {
  description = "Standard file format created for data ingestion"
  value = {
    name = snowflake_file_format.bronze_csv_format.name
    type = snowflake_file_format.bronze_csv_format.format_type
  }
}

# =================================================================================
# CONNECTION STRINGS AND URLs
# =================================================================================

output "snowflake_connection_info" {
  description = "Snowflake connection information for applications and tools"
  value = {
    account  = var.snowflake_account
    database = snowflake_database.data_warehouse.name
    schemas  = {
      bronze = snowflake_schema.bronze_schema.name
      silver = snowflake_schema.silver_schema.name
      gold   = snowflake_schema.gold_schema.name
    }
  }
  sensitive = true
}

# =================================================================================
# ORCHESTRATION INTEGRATION OUTPUTS
# =================================================================================

output "airflow_connection_config" {
  description = "Snowflake connection configuration for Airflow"
  value = {
    conn_type = "snowflake"
    host      = "${var.snowflake_account}.snowflakecomputing.com"
    schema    = snowflake_database.data_warehouse.name
    login     = var.snowflake_user
    password  = var.snowflake_password
    extra = jsonencode({
      "warehouse" = snowflake_warehouse.bronze_wh.name
      "database"  = snowflake_database.data_warehouse.name
      "role"      = snowflake_role.pipeline_role.name
      "region"    = var.snowflake_region
    })
  }
  sensitive = true
}

output "dbt_profiles_config" {
  description = "dbt profiles.yml configuration for silver and gold layers"
  value = {
    silver_layer = {
      type      = "snowflake"
      account   = var.snowflake_account
      user      = var.snowflake_user
      password  = var.snowflake_password
      role      = snowflake_role.transformer_role.name
      database  = snowflake_database.data_warehouse.name
      warehouse = snowflake_warehouse.silver_wh.name
      schema    = snowflake_schema.silver_schema.name
    }
    gold_layer = {
      type      = "snowflake"
      account   = var.snowflake_account
      user      = var.snowflake_user
      password  = var.snowflake_password
      role      = snowflake_role.transformer_role.name
      database  = snowflake_database.data_warehouse.name
      warehouse = snowflake_warehouse.gold_wh.name
      schema    = snowflake_schema.gold_schema.name
    }
  }
  sensitive = true
}

# =================================================================================
# MONITORING AND ALERTING OUTPUTS
# =================================================================================

output "monitoring_resources" {
  description = "Resources that should be monitored in observability tools"
  value = {
    database = snowflake_database.data_warehouse.name
    warehouses = [
      snowflake_warehouse.bronze_wh.name,
      snowflake_warehouse.silver_wh.name,
      snowflake_warehouse.gold_wh.name
    ]
    schemas = [
      snowflake_schema.bronze_schema.name,
      snowflake_schema.silver_schema.name,
      snowflake_schema.gold_schema.name
    ]
  }
}

# =================================================================================
# DEPLOYMENT INFORMATION
# =================================================================================

output "deployment_summary" {
  description = "Summary of the deployed Snowflake infrastructure"
  value = <<EOT
Modern Data Warehouse Deployment Complete!

Database: ${snowflake_database.data_warehouse.name}
Environment: ${var.environment}

Schemas:
  - Bronze: ${snowflake_schema.bronze_schema.name} (Raw Data)
  - Silver: ${snowflake_schema.silver_schema.name} (Cleaned Data)  
  - Gold: ${snowflake_schema.gold_schema.name} (Business Data)

Warehouses:
  - Bronze: ${snowflake_warehouse.bronze_wh.name} (${snowflake_warehouse.bronze_wh.warehouse_size})
  - Silver: ${snowflake_warehouse.silver_wh.name} (${snowflake_warehouse.silver_wh.warehouse_size})
  - Gold: ${snowflake_warehouse.gold_wh.name} (${snowflake_warehouse.gold_wh.warehouse_size})

Roles:
  - Loader: ${snowflake_role.loader_role.name}
  - Transformer: ${snowflake_role.transformer_role.name}
  - Analyst: ${snowflake_role.analyst_role.name}
  - Pipeline: ${snowflake_role.pipeline_role.name}

Next Steps:
1. Configure Airflow connections using the airflow_connection_config output
2. Set up dbt profiles using the dbt_profiles_config output
3. Deploy your data pipelines using the provided orchestration DAGs
4. Set up monitoring for the resources listed in monitoring_resources

EOT
}
