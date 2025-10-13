"""
Custom Snowflake Operators for Airflow
Purpose: Extend Airflow with Snowflake-specific functionality
"""

from airflow.models import BaseOperator
from airflow.providers.snowflake.hooks.snowflake import SnowflakeHook
from airflow.utils.decorators import apply_defaults

class SnowflakeDataQualityOperator(BaseOperator):
    """
    Custom operator for Snowflake data quality checks
    """
    
    @apply_defaults
    def __init__(
        self,
        sql_checks,
        snowflake_conn_id='snowflake_default',
        *args, **kwargs
    ):
        super(SnowflakeDataQualityOperator, self).__init__(*args, **kwargs)
        self.sql_checks = sql_checks
        self.snowflake_conn_id = snowflake_conn_id

    def execute(self, context):
        hook = SnowflakeHook(snowflake_conn_id=self.snowflake_conn_id)
        
        for check_name, check_sql in self.sql_checks.items():
            self.log.info(f"Running data quality check: {check_name}")
            result = hook.get_first(check_sql)
            
            if result and result[0] > 0:
                raise ValueError(f"Data quality check failed: {check_name}")
            
            self.log.info(f"Data quality check passed: {check_name}")
