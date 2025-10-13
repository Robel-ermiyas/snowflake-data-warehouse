"""
Data Pipeline Health Checks
Purpose: Comprehensive health checks for all pipeline components
Usage: Can be run manually or scheduled via Airflow
"""

import snowflake.connector
import requests
import json
from datetime import datetime, timedelta

class PipelineHealthChecker:
    """
    Comprehensive health checks for data pipeline components
    """
    
    def __init__(self, snowflake_config):
        self.snowflake_config = snowflake_config
    
    def check_snowflake_connectivity(self):
        """
        Verify Snowflake database connectivity
        """
        try:
            conn = snowflake.connector.connect(**self.snowflake_config)
            cursor = conn.cursor()
            cursor.execute("SELECT CURRENT_VERSION()")
            version = cursor.fetchone()
            cursor.close()
            conn.close()
            
            return {
                "status": "healthy",
                "version": version[0],
                "timestamp": datetime.now().isoformat()
            }
        except Exception as e:
            return {
                "status": "unhealthy", 
                "error": str(e),
                "timestamp": datetime.now().isoformat()
            }
    
    def check_pipeline_freshness(self):
        """
        Check data freshness across all layers
        """
        checks = {}
        
        try:
            conn = snowflake.connector.connect(**self.snowflake_config)
            cursor = conn.cursor()
            
            # Check bronze layer freshness
            cursor.execute("""
                SELECT 
                    'bronze' as layer,
                    DATEDIFF('hour', MAX(cst_create_date), CURRENT_TIMESTAMP()) as hours_behind
                FROM bronze.crm_cust_info
            """)
            checks['bronze'] = cursor.fetchone()[1]
            
            # Check silver layer freshness  
            cursor.execute("""
                SELECT 
                    'silver' as layer,
                    DATEDIFF('hour', MAX(cst_create_date), CURRENT_TIMESTAMP()) as hours_behind
                FROM silver.crm_cust_info
            """)
            checks['silver'] = cursor.fetchone()[1]
            
            # Check gold layer freshness
            cursor.execute("""
                SELECT 
                    'gold' as layer, 
                    DATEDIFF('hour', MAX(create_date), CURRENT_TIMESTAMP()) as hours_behind
                FROM gold.dim_customers
            """)
            checks['gold'] = cursor.fetchone()[1]
            
            cursor.close()
            conn.close()
            
            return {
                "status": "healthy" if all(hours <= 24 for hours in checks.values()) else "degraded",
                "freshness": checks,
                "timestamp": datetime.now().isoformat()
            }
            
        except Exception as e:
            return {
                "status": "unhealthy",
                "error": str(e),
                "timestamp": datetime.now().isoformat()
            }
    
    def check_data_quality_metrics(self):
        """
        Run comprehensive data quality checks
        """
        quality_checks = {}
        
        try:
            conn = snowflake.connector.connect(**self.snowflake_config)
            cursor = conn.cursor()
            
            # Check for null primary keys
            cursor.execute("SELECT COUNT(*) FROM bronze.crm_cust_info WHERE cst_id IS NULL")
            quality_checks['null_customer_ids'] = cursor.fetchone()[0]
            
            # Check for negative sales
            cursor.execute("SELECT COUNT(*) FROM silver.crm_sales_details WHERE sls_sales < 0")
            quality_checks['negative_sales'] = cursor.fetchone()[0]
            
            # Check referential integrity
            cursor.execute("""
                SELECT COUNT(*) 
                FROM gold.fct_sales fs 
                LEFT JOIN gold.dim_customers dc ON fs.customer_key = dc.customer_key 
                WHERE dc.customer_key IS NULL
            """)
            quality_checks['orphaned_customers'] = cursor.fetchone()[0]
            
            cursor.close()
            conn.close()
            
            # Evaluate overall quality status
            failed_checks = sum(1 for count in quality_checks.values() if count > 0)
            status = "healthy" if failed_checks == 0 else "degraded"
            
            return {
                "status": status,
                "failed_checks": failed_checks,
                "details": quality_checks,
                "timestamp": datetime.now().isoformat()
            }
            
        except Exception as e:
            return {
                "status": "unhealthy",
                "error": str(e),
                "timestamp": datetime.now().isoformat()
            }
    
    def check_airflow_health(self, airflow_url, username, password):
        """
        Check Airflow web server health
        """
        try:
            # Get Airflow health endpoint
            response = requests.get(
                f"{airflow_url}/health",
                auth=(username, password)
            )
            response.raise_for_status()
            
            health_data = response.json()
            
            return {
                "status": "healthy",
                "scheduler": health_data.get('scheduler', {}).get('status'),
                "dag_processor": health_data.get('dag_processor', {}).get('status'),
                "timestamp": datetime.now().isoformat()
            }
            
        except Exception as e:
            return {
                "status": "unhealthy",
                "error": str(e),
                "timestamp": datetime.now().isoformat()
            }
    
    def run_comprehensive_health_check(self):
        """
        Run all health checks and return consolidated report
        """
        report = {
            "timestamp": datetime.now().isoformat(),
            "checks": {}
        }
        
        # Run all health checks
        report["checks"]["snowflake_connectivity"] = self.check_snowflake_connectivity()
        report["checks"]["pipeline_freshness"] = self.check_pipeline_freshness()
        report["checks"]["data_quality"] = self.check_data_quality_metrics()
        
        # Determine overall status
        all_statuses = [check["status"] for check in report["checks"].values()]
        if "unhealthy" in all_statuses:
            report["overall_status"] = "unhealthy"
        elif "degraded" in all_statuses:
            report["overall_status"] = "degraded"
        else:
            report["overall_status"] = "healthy"
        
        return report
